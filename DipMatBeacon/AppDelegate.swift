//
//  AppDelegate.swift
//  DipMatBeacon
//
//  Created by Diego Russo on 28/05/2016.
//  Copyright © 2016 Diego Russo. All rights reserved.
//

import UIKit

var reachability: Reachability?
var reachabilityStatus = " "

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var internetCheck: Reachability?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        addObserver(kReachabilityChangedNotification, with: #selector(AppDelegate.reachabilityChanged(_:)))
        
        checkInternet()
        
        return true
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
        
        removeObserver(kReachabilityChangedNotification)
    }
    
    
}

extension AppDelegate{
    
    func addObserver(observerName: String, with selector: Selector){
        // Add observer: when I receive kReachabilityChangedNotification I execute reachabilityChanged
        // _: after the selector means there is a parameter
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: observerName, object: nil)
    }
    
    func removeObserver(observerName: String){
        // Remove the observer added at the top
        NSNotificationCenter.defaultCenter().removeObserver(self, name: observerName, object: nil)
    }
    
    func checkInternet(){
        // I need to run this because the first time I don't have a notification to tell me if I have internet or not.
        internetCheck = Reachability.reachabilityForInternetConnection()
        internetCheck?.startNotifier()
        statusChangedWithReachability(internetCheck!)
    }
    
    func reachabilityChanged(notification: NSNotification){
        // as? is casting to Reachability
        reachability = notification.object as? Reachability
        statusChangedWithReachability(reachability!)
    }
    
    func statusChangedWithReachability(currentReachabilityStatus: Reachability){
        let networkStatus: NetworkStatus = currentReachabilityStatus.currentReachabilityStatus()
        
        switch networkStatus.rawValue{
        case NotReachable.rawValue:
            print(NOACCESS)
            reachabilityStatus = NOACCESS
        case ReachableViaWiFi.rawValue:
            print(WIFI)
            reachabilityStatus = WIFI
        case ReachableViaWWAN.rawValue:
            print(WWAN)
            reachabilityStatus = WWAN
        default:
            return
        }
        
        // I post a notification which will be listen by an listener
        NSNotificationCenter.defaultCenter().postNotificationName("ReachStatusChanged", object: nil)
        
    }
    
}
