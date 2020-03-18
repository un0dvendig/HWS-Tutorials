//
//  WebViewController.swift
//  Project 16. Capital Cities
//
//  Created by Eugene Ilyin on 22.11.2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    // MARK: - Properties
    var link: String?
    var webView = WKWebView()
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        
        self.view.addSubview(webView)
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 10).isActive = true
        
        guard link != nil else { return }
        guard let url = URL(string: link!) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
