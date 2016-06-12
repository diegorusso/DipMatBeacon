//
//  AppDelegate.swift
//  DipMatBeacon
//
//  Created by Diego Russo on 28/05/2016.
//  Copyright © 2016 Diego Russo. All rights reserved.
//

import UIKit


// Global variables
var reachability: Reachability?
var reachabilityStatus = " "


// This is the ID of the beacons: it should be the same on all the beacons used with this app
let UUIDBeaconApp = "A7DBE84C-62A6-40ED-944B-A32C76C44DB2"


@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var internetCheck: Reachability?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // This is the application entry point
        
        // Register the observer to check whenever the connection changes
        registerObserver(kReachabilityChangedNotification, instance: self, with: #selector(AppDelegate.reachabilityChanged(_:)))
        
        // Set the cache for NSUrl request
        setCache()
        
        // I need to run this because the first time I don't have a notification to tell me if I have internet or not.
        checkInternet()
        
        // Register local notifications
        setupNotifications(application)
        
        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        // This is when the app is launched starting from a notification
        
        // I post a notification which tells I received a local notification
        NSNotificationCenter.defaultCenter().postNotificationName("ReceivedLocalNotification", object: nil)
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        // To free up memory I need to deregister every observer I registered
        deregisterObserver(kReachabilityChangedNotification, instance: self)
    }
    
    
}

extension AppDelegate {
    // This extensions contains all custom methods used by the AppDelegate
    
    func setCache(){
        // Set the cache for NSURL
        let URLCache = NSURLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        NSURLCache.setSharedURLCache(URLCache)
    }
    
    func checkInternet(){
        // Checks whether the default route is available
        internetCheck = Reachability.reachabilityForInternetConnection()
        // Start listening for reachability notifications
        internetCheck?.startNotifier()
        statusChangedWithReachability(internetCheck!)
    }
    
    func reachabilityChanged(notification: NSNotification){
        // This method is executed by the observer
        reachability = notification.object as? Reachability
        statusChangedWithReachability(reachability!)
    }
    
    func statusChangedWithReachability(currentReachabilityStatus: Reachability){
        // The method gets the reachability status and it sets reachabilityStatus variable
        let networkStatus: NetworkStatus = currentReachabilityStatus.currentReachabilityStatus()
        
        // It sets reachabilityStatus to the correct value (this will be read by ScheduleTVC.swift)
        switch networkStatus.rawValue{
        case NotReachable.rawValue:
            NSLog(NOACCESS)
            reachabilityStatus = NOACCESS
        case ReachableViaWiFi.rawValue:
            NSLog(WIFI)
            reachabilityStatus = WIFI
        case ReachableViaWWAN.rawValue:
            NSLog(WWAN)
            reachabilityStatus = WWAN
        default:
            return
        }
        
        // Creates a notification with a given name and sender and posts it to the receiver (in ScheduleTVC.swift)
        NSNotificationCenter.defaultCenter().postNotificationName("ReachStatusChanged", object: nil)
    }
    
    func setupNotifications(application: UIApplication){
        // It requests permission from the user to post local notifications
        if(application.respondsToSelector(#selector(UIApplication.registerUserNotificationSettings(_:)))) {
            application.registerUserNotificationSettings(
                UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            )
        }
    }
}
