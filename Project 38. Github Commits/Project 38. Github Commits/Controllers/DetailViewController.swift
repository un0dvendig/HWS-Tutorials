//
//  DetailViewController.swift
//  Project 38. Github Commits
//
//  Created by Eugene Ilyin on 07.01.2020.
//  Copyright © 2020 Eugene Ilyin. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    // MARK: - Subviews
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var detailWebView: WKWebView!
    
    // MARK: - Properties
    var detailItem: Commit?
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let detail = self.detailItem {
            detailLabel.text = detail.message
            
            guard let url = URL(string: detail.url) else { return }
            let request = URLRequest(url: url)
            detailWebView.load(request)
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Commit 1/\(detail.author.commits.count)",
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(showAuthorCommits))
        }
    }
    
    // MARK: - Methods
    @objc
    func showAuthorCommits() {
        guard let detail = detailItem else { return }
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "AuthorCommits") as? AuthorCommitsTableViewController else { return }
        vc.author = detail.author
        
        navigationController?.pushViewController(vc,
                                                 animated: true)        
    }

}
