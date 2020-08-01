//
//  AppDelegate.swift
//  SubstituteApp
//
//  Created by Ashwin Gupta on 12/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var databaseController: DatabaseProtocol?
    var window: UIWindow?
 
    
    // This is used for logging out as we cannot simply pop a navigation view controller
    private lazy var mainViewController: UITabBarController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "HomeSearchViewController")
        
        let navigationController = UINavigationController(rootViewController: initialViewController)
        
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([navigationController], animated: false)
        return tabBarController
        
    }()

    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Listens to changes in the authentication
        databaseController = FirebaseController()
        window = UIWindow()
        Auth.auth().addStateDidChangeListener( { (auth, user) in
            if (user != nil) {
                
                self.window?.rootViewController = self.mainViewController
                self.window?.makeKeyAndVisible()
            }
        })
        
        
        return true

    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

