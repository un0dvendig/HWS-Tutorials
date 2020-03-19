//
//  ViewController.swift
//  Project 31. Multibrowser
//
//  Created by Eugene Ilyin on 16.12.2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    // MARK: - Properties
    private weak var activeWebView: WKWebView?
    
    // MARK: - Subviews
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = "Press + button to add WebView"
        label.font = UIFont.systemFont(ofSize: 40, weight: .heavy)
        return label
    }()
    
    // MARK: - Outlets
    @IBOutlet weak var addressBar: UITextField!
    @IBOutlet weak var stackView: UIStackView!
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaultTitle()
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWebView))
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteWebView))
        navigationItem.rightBarButtonItems = [delete, add]
    }
    
    // MARK: - UITraitCollection
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.horizontalSizeClass == .compact {
            stackView.axis = .vertical
        } else {
            stackView.axis = .horizontal
        }
    }
    
    // MARK: - Private methods
    private func setDefaultTitle() {
        title = "Multibrowser"
        
        self.view.addSubview(placeholderLabel)
        placeholderLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        placeholderLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        placeholderLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    @objc
    private func addWebView() {
        if stackView.arrangedSubviews.count == 0 {
            placeholderLabel.removeFromSuperview()
        }
        
        let webView = WKWebView()
        webView.navigationDelegate = self
        
        stackView.addArrangedSubview(webView)
        
        let url = URL(string: "https://www.hackingwithswift.com")!
        webView.load(URLRequest(url: url))
        
        webView.layer.borderColor = UIColor.blue.cgColor
        selectWebView(webView)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(webViewTapped))
        recognizer.delegate = self
        webView.addGestureRecognizer(recognizer)
    }
    
    @objc
    private func deleteWebView() {
        guard let webView = activeWebView else { return }
        guard let index = stackView.arrangedSubviews.firstIndex(of: webView) else { return }
        webView.removeFromSuperview()
        
        if stackView.arrangedSubviews.count == 0 {
            // if no webview left, set default title
            setDefaultTitle()
        } else {
            // convert the `index` value into an integer
            var currentIndex = Int(index)
            
            // if that was the last webView in the stack, go back one
            if currentIndex == stackView.arrangedSubviews.count {
                currentIndex = stackView.arrangedSubviews.count - 1
            }
            
            // find the webView at the new index and select it
            guard let newSelectedWebView = stackView.arrangedSubviews[currentIndex] as? WKWebView else { return }
            selectWebView(newSelectedWebView)
        }
    }
    
    private func selectWebView(_ webView: WKWebView) {
        for view in stackView.arrangedSubviews {
            view.layer.borderWidth = 0
        }
        
        activeWebView = webView
        webView.layer.borderWidth = 3
        
        updateUI(for: webView)
    }
    
    @objc
    private func webViewTapped(_ recognizer: UITapGestureRecognizer) {
        guard let selectedWebView = recognizer.view as? WKWebView else { return }
        selectWebView(selectedWebView)
    }
    
    private func updateUI(for webView: WKWebView) {
        title = webView.title
        addressBar.text = webView.url?.absoluteString ?? ""
    }
}

// MARK: - WKNavigationDelegate methods
extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView == activeWebView {
            updateUI(for: webView)
        }
    }
}

// MARK: - UITextFieldDelegate methods
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            if !text.hasPrefix("https://") || !text.hasPrefix("http://") {
                let newText = "https://" + text
                textField.text = newText
            }
        }
        
        if let webView = activeWebView, let address = addressBar.text {
            if let url = URL(string: address) {
                webView.load(URLRequest(url: url))
            }
        }
        
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UIGestureRecognizerDelegate methods
extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
