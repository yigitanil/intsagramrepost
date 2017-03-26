//
//  AppDelegate.swift
//  instagramrepost
//
//  Created by Yigit Anil on 02/02/2017.
//  Copyright © 2017 Yigit Anil. All rights reserved.
//

import UIKit
import CoreData
import InMobiSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        IMSdk.initWithAccountID("397817c54fc14eb9ac3c477f77cbe74c");
        let mgr = CLLocationManager()
        let loc = mgr.location
        IMSdk.setLocation(loc)
        IMSdk.setGender(.female)
        IMSdk.setAgeGroup(.between21And24)
        
        
        let memoryCapacity = 500 * 1024 * 1024
        
        let urlCache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: memoryCapacity, diskPath: "instagram-repost-path")
        URLCache.shared = urlCache
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        window?.rootViewController = CustomTabBarController()
        
        UINavigationBar.appearance().barTintColor = UIColor.rgb(42, green: 95, blue: 239)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        
        
        
        return true
    }
    
    var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
    }
    
    
    
    
}

