//
//  AppDelegate.swift
//  SMSDKTest
//
//  Created by Fernando León on 3/25/20.
//  Copyright © 2020 Fernando León. All rights reserved.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let navController = UINavigationController(rootViewController: TestViewController())
        window?.makeKeyAndVisible()
        window?.rootViewController = navController
        return true
    }
}

