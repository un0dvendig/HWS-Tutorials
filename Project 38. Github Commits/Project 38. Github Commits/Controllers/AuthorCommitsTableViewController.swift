//
//  AuthoCommitsTableViewController.swift
//  Project 38. Github Commits
//
//  Created by Eugene Ilyin on 10.01.2020.
//  Copyright © 2020 Eugene Ilyin. All rights reserved.
//

import UIKit

class AuthorCommitsTableViewController: UITableViewController {

    // MARK: - Properties
    var author: Author?
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let author = author else { return }
        let title = "\(author.name)'s \(author.commits.count) commits"
        navigationItem.title = title
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return author?.commits.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Commit",
                                                 for: indexPath)
        
        if let commit = author?.commits[indexPath.row] as? Commit {
            cell.textLabel?.text = commit.message
            cell.detailTextLabel?.text = commit.date.description
        }
        
        return cell
    }
    
}
