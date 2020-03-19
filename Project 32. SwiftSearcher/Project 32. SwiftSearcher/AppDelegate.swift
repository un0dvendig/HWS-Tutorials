//
//  AppDelegate.swift
//  Project 32. SwiftSearcher
//
//  Created by Eugene Ilyin on 20.12.2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import CoreSpotlight
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == CSSearchableItemActionType {
            guard let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String else { return true }
            guard let navigationController = window?.rootViewController as? UINavigationController else { return true }
            guard let viewController = navigationController.topViewController as? ViewController else { return true }
            viewController.showTutorial(Int(uniqueIdentifier)!)
        }
        return true
    }
}

