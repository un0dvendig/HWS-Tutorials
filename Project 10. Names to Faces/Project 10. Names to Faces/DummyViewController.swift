//
//  DummyViewController.swift
//  Project 10. Names to Faces
//
//  Created by Eugene Ilyin on 01.12.2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import LocalAuthentication
import UIKit

class DummyViewController: UIViewController {

    // MARK: - Outlets
    @IBAction func authenticateButton(_ sender: UIButton) {
        requestAuthentication()
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Private Methods
    private func requestAuthentication() {
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please identify yourself"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] (success, authenticationError) in
                DispatchQueue.main.async {
                    if success{
                        self?.dismiss(animated: false)
                    } else {
                        // handle authenticationError
                    }
                }
            }
        } else {
            // TODO: handle no biometric
        }
    }

}
