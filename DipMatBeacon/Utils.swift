//
//  Utils.swift
//  DipMatBeacon
//
//  Created by Diego Russo on 29/05/2016.
//  Copyright © 2016 Diego Russo. All rights reserved.
//

import Foundation
import UIKit


func timestampFromString(dateString:String) -> NSDate {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'.000Z'"
    dateFormatter.timeZone = NSTimeZone(name: "Europe/London")
    let date: NSDate = dateFormatter.dateFromString(dateString)!
    return date
}


// Functions to extract part of the timestamp

func stringFromDate(date:NSDate, with format:String) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.timeZone = NSTimeZone(name: "Europe/London")
    let string: String = dateFormatter.stringFromDate(date)
    return string
}

func timeFromDate(date:NSDate) -> String {
    return stringFromDate(date, with: "HH:mm")
}

func ISODateFromDate(date:NSDate) -> String {
    return stringFromDate(date, with: "yyyy-MM-dd")
}

func completeDateFromDate(date:NSDate) -> String {
    return stringFromDate(date, with: "E, dd MMM yyyy HH:mm:ss")
}


func sectionHeaderFromDate(date:NSDate) -> String {
    return stringFromDate(date, with: "yyyy-MM-dd HH:mm")
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