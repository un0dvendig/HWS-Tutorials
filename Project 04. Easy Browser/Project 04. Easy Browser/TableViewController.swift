//
//  TableViewController.swift
//  Project 04. Easy Browser
//
//  Created by Eugene Ilyin on 02/09/2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    var websites = ["apple.com", "hackingwithswift.com"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Easy Browser"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addButtonTapped))
        
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return websites.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Site", for: indexPath)
        cell.textLabel?.text = websites[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let webVC = storyboard?.instantiateViewController(withIdentifier: "WebVC") as? ViewController {
            webVC.websiteList = websites
            webVC.websiteChoice = indexPath.row
            navigationController?.pushViewController(webVC, animated: true)
        }
    }
    
    @objc func addButtonTapped() {
        print("AddButton pressed")
    }

}
