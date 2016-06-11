//
//  Utils.swift
//  DipMatBeacon
//
//  Created by Diego Russo on 29/05/2016.
//  Copyright © 2016 Diego Russo. All rights reserved.
//

import Foundation
import UIKit


// The function converts a string to a NSDate object
func timestampFromString(dateString:String) -> NSDate {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    dateFormatter.timeZone = NSTimeZone(name: "Europe/London")
    let date: NSDate = dateFormatter.dateFromString(dateString)!
    return date
}


// The function returns a string representing a formatted date
func stringFromDate(date:NSDate, with format:String) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.timeZone = NSTimeZone(name: "Europe/London")
    let string: String = dateFormatter.stringFromDate(date)
    return string
}

// This function extracts the time from the date
func timeFromDate(date:NSDate) -> String {
    return stringFromDate(date, with: "HH:mm")
}

// This function extracts the ISO date from the date
func ISODateFromDate(date:NSDate) -> String {
    return stringFromDate(date, with: "yyyy-MM-dd")
}

// This function extracts the ISO date from the date
func completeDateFromDate(date:NSDate) -> String {
    return stringFromDate(date, with: "E, dd MMM yyyy HH:mm:ss")
}

// This function extracts the ISO date and time form date
func sectionHeaderFromDate(date:NSDate) -> String {
    return stringFromDate(date, with: "yyyy-MM-dd HH:mm")
}


// Depending on correspondence value, it returns a different color. These colors match the ones on the website
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


// Function to register an observer
func registerObserver(observerName: String, instance: AnyObject, with selector: Selector){
    NSNotificationCenter.defaultCenter().addObserver(instance, selector: selector, name: observerName, object: nil)
}

// Function to deregister an observer
func deregisterObserver(observerName: String, instance: AnyObject){
    NSNotificationCenter.defaultCenter().removeObserver(instance, name: observerName, object: nil)
}


// This an extension of SequenceType objects (eg. array)
public extension SequenceType {
    // Categorises elements of self into a dictionary, with the keys given by keyFunc
    func categorise<U: Hashable>(@noescape keyFunc: Generator.Element -> U) -> [U:[Generator.Element]] {
        var dict: [U:[Generator.Element]] = [:]
        for el in self {
            let key = keyFunc(el)
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
}


// The following three functions are used to compare NSDate objects
// The two operands are equal
func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

// The left operand is smaller than the right operand
func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

// The left operand is greater than the right operand
func >(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedDescending
}

// The two operands are equal - applied to Location
func ==(lhs: Location, rhs: Location) -> Bool {
    return lhs.id == rhs.id
}
