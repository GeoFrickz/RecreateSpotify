//
//  AppDelegate.swift
//  RecreateSpotify
//
//  Created by George Maximillian Theodore on 02/09/26.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let initialViewController = MainTabBarController()
        window?.rootViewController = initialViewController
        
        window?.makeKeyAndVisible()
        
        return true
    }


}

