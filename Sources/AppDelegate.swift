//
//  AppDelegate.swift
//  Reddit
//
//  Created by Alex Pawlowski on 2/16/18.
//  Copyright © 2018 Alex Pawlowski. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, DependencyProvider {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }

    var window: UIWindow?
    let dependencyList = DependencyList()
        .with(type: RedditAPIType.self, instance: RedditAPI.default)
        .with(type: ImageManagerType.self, instance: ImageManager())
}

// MARK: - Couldn't come up with a better way to DI via responder chain
extension AppDelegate {
    @IBAction func dependencyProvider() {}
}
