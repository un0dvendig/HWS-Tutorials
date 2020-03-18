//
//  ViewController.swift
//  Project 28. Secret Swift
//
//  Created by Eugene Ilyin on 01.12.2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import LocalAuthentication
import UIKit

class ViewController: UIViewController {

    // MARK: - Properties
    private let password = "q1w2e3"
    
    // MARK: - Outlets
    private lazy var lefBarButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .done,
                               target: self,
                               action: #selector(ViewController.saveSecretMessage))
    }()
    @IBOutlet weak var secret: UITextView!
    @IBAction func authenticateTapped(_ sender: UIButton) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] (success, authenticationError) in
                DispatchQueue.main.async {
                    if success {
                        self?.unlockSecretMessage()
                    } else {
                        self?.promptForPassword()
                        
                    }
                }
            }
        } else {
            promptForPassword()
        }
    }

    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nothing to see here"
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillHideNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillChangeFrameNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(saveSecretMessage),
                                       name: UIApplication.willResignActiveNotification,
                                       object: nil)
        
        KeychainWrapper.standard.set(password,
                                     forKey: "UserPassword")
    }

    // MARK: - Private methods
    @objc
    private func adjustForKeyboard(_ notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame,
                                                from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        } else {
            secret.contentInset = UIEdgeInsets(top: 0,
                                               left: 0,
                                               bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom,
                                               right: 0)
        }
        
        secret.scrollIndicatorInsets = secret.contentInset
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
    
    private func unlockSecretMessage() {
        secret.isHidden = false
        title = "Secret stuff!"
        
        secret.text = KeychainWrapper.standard.string(forKey: "SecretMessage") ?? ""
        
        navigationItem.leftBarButtonItem = lefBarButton
    }
    
    @objc
    private func saveSecretMessage() {
        guard secret.isHidden == false else { return }
        
        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
        secret.resignFirstResponder()
        secret.isHidden = true
        title = "Nothing to see here"
        
        navigationItem.leftBarButtonItem = nil
    }
    
    @objc
    private func promptForPassword() {
        let ac = UIAlertController(title: "Enter your answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            
            // Assume the password somehow was set previously (too lazy to write full password system now)
            guard let password = KeychainWrapper.standard.string(forKey: "UserPassword") else { return }
            
            if answer == password {
                self?.unlockSecretMessage()
            } else {
                let ac = UIAlertController(title: "Wrong password!",
                                           message: nil,
                                           preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { (action) in
                    self?.dismiss(animated: true, completion: {
                        self?.promptForPassword()
                    })
                }))
                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                
                self?.present(ac, animated: true)
            }
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
}

