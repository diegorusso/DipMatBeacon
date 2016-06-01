//
//  Utils.swift
//  DipMatBeacon
//
//  Created by Diego Russo on 29/05/2016.
//  Copyright © 2016 Diego Russo. All rights reserved.
//

import Foundation
import UIKit


func dateFromString(dateString:String) -> NSDate {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'.000Z'"
    dateFormatter.timeZone = NSTimeZone(name: "Europe/London")
    let date: NSDate = dateFormatter.dateFromString(dateString)!
    return date
}

func timeFromDate(date:NSDate) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    dateFormatter.timeZone = NSTimeZone(name: "Europe/London")
    let time: String = dateFormatter.stringFromDate(date)
    return time
}

func sectionHeaderFromDate(date:NSDate) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    dateFormatter.timeZone = NSTimeZone(name: "Europe/London")
    let time: String = dateFormatter.stringFromDate(date)
    return time

}


func correspondenceColor(correspondence:String) -> UIColor {
    var bgColor: UIColor
    
    switch correspondence {
    case "CdS interno del Dipartimento":
        bgColor = LIGHTGREEN
    case "Altro":
        bgColor = LIGHTBLUE
    default:
        bgColor = LIGHTGREY
    }
    
    return bgColor
}


func registerObserver(observerName: String, instance: AnyObject, with selector: Selector){
    // Add observer: when I receive kReachabilityChangedNotification I execute reachabilityChanged
    // _: after the selector means there is a parameter
    NSNotificationCenter.defaultCenter().addObserver(instance, selector: selector, name: observerName, object: nil)
}

func deregisterObserver(observerName: String, instance: AnyObject){
    // Remove the observer added at the top
    NSNotificationCenter.defaultCenter().removeObserver(instance, name: observerName, object: nil)
}


public extension SequenceType {
    
    /// Categorises elements of self into a dictionary, with the keys given by keyFunc
    
    func categorise<U : Hashable>(@noescape keyFunc: Generator.Element -> U) -> [U:[Generator.Element]] {
        var dict: [U:[Generator.Element]] = [:]
        for el in self {
            let key = keyFunc(el)
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
}