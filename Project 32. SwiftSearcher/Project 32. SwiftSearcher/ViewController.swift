//
//  ViewController.swift
//  Project 32. SwiftSearcher
//
//  Created by Eugene Ilyin on 20.12.2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import CoreSpotlight
import MobileCoreServices
import SafariServices
import UIKit

class ViewController: UITableViewController {

    // MARK: - Properties
    private var projects = [Project]()
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateTableView),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
        
        let defaults = UserDefaults.standard
        if let savedProjects = defaults.object(forKey: "projects") as? Data {
            if let decodedProjects = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedProjects) as? [Project] {
                projects = decodedProjects
            }
        } else {
            projects.append(Project(title: "Project 1: Storm Viewer",
                                    subtitle: "Constants and variables, UITableView, UIImageView, FileManager, storyboards"))
            projects.append(Project(title: "Project 2: Guess the Flag",
                                    subtitle: "@2x and @3x images, asset catalogs, integers, doubles, floats, operators (+= and -=), UIButton, enums, CALayer, UIColor, random numbers, actions, string interpolation, UIAlertController"))
            projects.append(Project(title: "Project 3: Social Media",
                                    subtitle: "UIBarButtonItem, UIActivityViewController, the Social framework, URL"))
            projects.append(Project(title: "Project 4: Easy Browser",
                                    subtitle: "loadView(), WKWebView, delegation, classes and structs, URLRequest, UIToolbar, UIProgressView., key-value observing"))
            projects.append(Project(title: "Project 5: Word Scramble",
                                    subtitle: "Closures, method return values, booleans, NSRange"))
            projects.append(Project(title: "Project 6: Auto Layout",
                                    subtitle: "Get to grips with Auto Layout using practical examples and code"))
            projects.append(Project(title: "Project 7: Whitehouse Petitions",
                                    subtitle: "JSON, Data, UITabBarController"))
            projects.append(Project(title: "Project 8: 7 Swifty Words",
                                    subtitle: "addTarget(), enumerated(), count, index(of:), property observers, range operators."))
            
            save()
        }
        
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: UIContentSizeCategory.didChangeNotification,
                                                  object: nil)
    }

    // MARK: - UITableView data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let project = projects[indexPath.row]
        cell.textLabel?.attributedText = makeAttributedString(title: project.title,
                                                              subtitle: project.subtitle)
        
        if project.favorited {
            cell.editingAccessoryType = .checkmark
        } else {
            cell.editingAccessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showTutorial(indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        let project = projects[indexPath.row]
        if project.favorited {
            return .delete
        } else {
            return .insert
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .insert {
            projects[indexPath.row].favorited = true
            index(item: indexPath.row)
        } else {
            projects[indexPath.row].favorited = false
            deindex(item: indexPath.row)
        }
        
        save()
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    // MARK: - Methods
    func showTutorial(_ which: Int) {
        guard let url = URL(string: "https://www.hackingwithswift.com/read/\(which + 1)") else { return }
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        
        let vc = SFSafariViewController(url: url, configuration: config)
        present(vc, animated: true)
    }
    
    // MARK: - Private methods
    private func save() {
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: projects, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "projects")
        }
    }
    
    private func makeAttributedString(title: String, subtitle: String) -> NSAttributedString {
        let titleAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline),
                               NSAttributedString.Key.foregroundColor: UIColor.purple]
        let subtitleAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline)]
        
        let titleString = NSMutableAttributedString(string: "\(title)\n", attributes: titleAttributes)
        let subtitleString = NSAttributedString(string: subtitle, attributes: subtitleAttributes)
        
        titleString.append(subtitleString)
        
        return titleString
    }
    
    private func index(item: Int) {
        let project = projects[item]
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        attributeSet.title = project.title
        attributeSet.contentDescription = project.subtitle
        
        let item = CSSearchableItem(uniqueIdentifier: "\(item)",
            domainIdentifier: "com.hackingwithswift",
            attributeSet: attributeSet)
        item.expirationDate = Date.distantFuture
        
        CSSearchableIndex.default().indexSearchableItems([item]) { (error) in
            if let error = error {
                print("Indexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully indexed!")
            }
        }
    }
    
    private func deindex(item: Int) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(item)"]) { (error) in
            if let error = error {
                print("Deindexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully removed!")
            }
        }
    }
    
    @objc
    private func updateTableView(_ notification: Notification) {
        tableView.reloadData()
    }
}

