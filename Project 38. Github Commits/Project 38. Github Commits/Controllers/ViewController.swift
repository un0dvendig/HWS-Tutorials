//
//  ViewController.swift
//  Project 38. Github Commits
//
//  Created by Eugene Ilyin on 07.01.2020.
//  Copyright © 2020 Eugene Ilyin. All rights reserved.
//

import CoreData
import UIKit

class ViewController: UITableViewController {

    // MARK: - Properties
    var container: NSPersistentContainer!
    var commitPredicate: NSPredicate?
    var fetchedResulstsController: NSFetchedResultsController<Commit>!
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        container = NSPersistentContainer(name: "Project38") // Note: must be given the name of the Core Data model file
        
        container.loadPersistentStores { (storeDescription, error) in // Load the save DB or create one
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
        
        performSelector(inBackground: #selector(fetchCommits),
                        with: nil)
        
        loadSavedData()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(changeFilter))
    }

    // MARK: - Methods
    /// Save changes permamently (i.e., save them to disk)
    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
    
    @objc
    func fetchCommits() {
        let newestCommitDate = getNewestCommitDate()
        
        if let data = try? String(contentsOf: URL(string: "https://api.github.com/repos/apple/swift/commits?per_page=100&since=\(newestCommitDate)")!) {
            // give the data to SwiftyJSON to parse
            let jsonCommits = JSON(parseJSON: data)
            
            // read the commits back out
            let jsonCommitArray = jsonCommits.arrayValue
            
            print("Received \(jsonCommitArray.count) new commits.")
            
            DispatchQueue.main.async { [unowned self] in
                for jsonCommit in jsonCommitArray {
                    let commit = Commit(context: self.container.viewContext)
                    self.configure(commit: commit,
                                   usingJSON: jsonCommit)
                }
                
                self.saveContext()
                self.loadSavedData()
            }
        }
    }
    
    func getNewestCommitDate() -> String {
        let formatter = ISO8601DateFormatter()
        
        let newest = Commit.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        newest.sortDescriptors = [sort]
        newest.fetchLimit = 1
        
        if let commits = try? container.viewContext.fetch(newest) {
            if commits.count > 0 {
                return formatter.string(from: commits[0].date.addingTimeInterval(1))
            }
        }
        
        return formatter.string(from: Date(timeIntervalSince1970: 0))
    }
    
    func configure(commit: Commit, usingJSON json: JSON) {
        commit.sha = json["sha"].stringValue
        commit.message = json["commit"]["message"].stringValue
        commit.url = json["html_url"].stringValue
        
        let formatter = ISO8601DateFormatter()
        commit.date = formatter.date(from: json["commit"]["committer"]["date"].stringValue) ?? Date()
        
        var commitAuthor: Author!
        // check if this author exists already
        let authorRequest = Author.createFetchRequest()
        authorRequest.predicate = NSPredicate(format: "name == %@", json["commit"]["committer"]["name"].stringValue)
        
        if let authors = try? container.viewContext.fetch(authorRequest) {
            if authors.count > 0 {
                // we have this author already
                commitAuthor = authors[0]
            }
        }
        
        if commitAuthor == nil {
            // we didn't find a saved author - create a new one!
            let author = Author(context: container.viewContext)
            author.name = json["commit"]["committer"]["name"].stringValue
            author.email = json["commit"]["committer"]["email"].stringValue
            commitAuthor = author
        }
        
        // use the author, eighter saved of new
        commit.author = commitAuthor
    }
    
    func loadSavedData() {
        if fetchedResulstsController == nil {
            let request = Commit.createFetchRequest()
            let sort = NSSortDescriptor(key: "author.name", ascending: true)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 20
            
            fetchedResulstsController = NSFetchedResultsController(fetchRequest: request,
                                                                   managedObjectContext: container.viewContext,
                                                                   sectionNameKeyPath: "author.name",
                                                                   cacheName: nil)
            fetchedResulstsController.delegate = self
        }
        
        fetchedResulstsController.fetchRequest.predicate = commitPredicate
        
        do {
            try fetchedResulstsController.performFetch()
            tableView.reloadData()
        } catch {
            print("Fetch failed")
        }
    }
    
    @objc
    func changeFilter() {
        let ac = UIAlertController(title: "Filter commits...",
                                   message: nil,
                                   preferredStyle: .actionSheet)
        
        // 1. This predicate matches only objects that contain a string somewhere in their message – in our case, that's the text "fix". The [c] part is predicate-speak for "case-insensitive", which means it will match "FIX", "Fix", "fix" and so on.
        ac.addAction(UIAlertAction(title: "Show only fixes",
                                   style: .default,
                                   handler: { [unowned self] (_) in
            self.commitPredicate = NSPredicate(format: "message CONTAINS[c] 'fix'")
            self.loadSavedData()
        }))
        
        // 2. BEGINSWITH works just like CONTAINS except the matching text must be at the start of a string. This action below will match only objects that don't begin with 'Merge pull request'.
        ac.addAction(UIAlertAction(title: "Ignore Pull Requests",
                                   style: .default,
                                   handler: { [unowned self] (_) in
            self.commitPredicate = NSPredicate(format: "NOT message BEGINSWITH 'Merge pull request'")
            self.loadSavedData()
        }))
        
        // 3. Request only commits that took place 43,200 seconds ago, which is equivalent to half a day
        ac.addAction(UIAlertAction(title: "Show only recent",
                                   style: .default,
                                   handler: { [unowned self] (_) in
            let twelveHoursAgo = Date().addingTimeInterval(-43200)
            self.commitPredicate = NSPredicate(format: "date > %@", twelveHoursAgo as NSDate)
            self.loadSavedData()
        }))
        
        // 4. Show all commits.
        ac.addAction(UIAlertAction(title: "Show all commits",
                                   style: .default,
                                   handler: { [unowned self] (_) in
            self.commitPredicate = nil
            self.loadSavedData()
        }))
        
        // 5.
        ac.addAction(UIAlertAction(title: "Show only Durian commits",
                                   style: .default,
                                   handler: { [unowned self] (_) in
            self.commitPredicate = NSPredicate(format: "author.name == 'Joe Groff'")
            self.loadSavedData()
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel",
                                   style: .cancel))
        present(ac,
                animated: true)
    }
    
    // MARK: - Table view methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResulstsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResulstsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Commit",
                                                 for: indexPath)
        
        let commit = fetchedResulstsController.object(at: indexPath)
        cell.textLabel!.text = commit.message
        cell.detailTextLabel!.text = "By \(commit.author.name) on \(commit.date.description)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.detailItem = fetchedResulstsController.object(at: indexPath)
            navigationController?.pushViewController(vc,
                                                     animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let commit = fetchedResulstsController.object(at: indexPath)
            container.viewContext.delete(commit)
            saveContext()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResulstsController.sections![section].name
    }

}

// MARK: - NSFetchedResultsControllerDelegate methods
extension ViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            print(tableView.numberOfRows(inSection: indexPath!.section))
            let currentNumberOfRows = tableView.numberOfRows(inSection: indexPath!.section)
            if currentNumberOfRows - 1 == 0 {
                let indexSet = NSMutableIndexSet()
                indexSet.add(indexPath!.section)
                tableView.deleteSections(indexSet as IndexSet,
                                         with: .automatic)
            } else {
                tableView.deleteRows(at: [indexPath!],
                                     with: .automatic)
            }
        default:
            break
        }
    }
}
