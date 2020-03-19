//
//  InterfaceController.swift
//  Project 37. Psychic Tester WatchKit Extension
//
//  Created by Eugene Ilyin on 31.12.2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {

    // MARK: - Outlets
    @IBOutlet weak var welcomeText: WKInterfaceLabel!
    @IBOutlet weak var hideButton: WKInterfaceButton!
    
    // MARK: - Actions
    @IBAction func hideWelcomeText() {
        welcomeText.setHidden(true)
        hideButton.setHidden(true)
    }
    
    // MARK: - Interface Life Cycle
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}

// MARK: - WCSessionDelegate Methods
extension InterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        WKInterfaceDevice().play(.click)
    }
    
}
