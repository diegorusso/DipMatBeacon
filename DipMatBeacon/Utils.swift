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
    // The function converts a string to a NSDate object
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    let date: NSDate = dateFormatter.dateFromString(dateString)!
    return date
}

func stringFromDate(date:NSDate, with format:String) -> String {
    // The function returns a string representing a formatted date
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = format
    let string: String = dateFormatter.stringFromDate(date)
    return string
}

func timeFromDate(date:NSDate) -> String {
    // This function extracts the time from the date
    return stringFromDate(date, with: "HH:mm")
}

func ISODateFromDate(date:NSDate) -> String {
    // This function extracts the ISO date from the date
    return stringFromDate(date, with: "yyyy-MM-dd")
}

func completeDateFromDate(date:NSDate) -> String {
    // This function extracts the ISO date from the date
    return stringFromDate(date, with: "E, dd MMM yyyy HH:mm:ss")
}

func sectionHeaderFromDate(date:NSDate) -> String {
    // This function extracts the ISO date and time form date
    return stringFromDate(date, with: "yyyy-MM-dd HH:mm")
}


func correspondenceColor(correspondence:String) -> UIColor {
    // Depending on correspondence value, it returns a different color. These colors match the ones on the website
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
    // Function to register an observer
    NSNotificationCenter.defaultCenter().addObserver(instance, selector: selector, name: observerName, object: nil)
}

func deregisterObserver(observerName: String, instance: AnyObject){
    // Function to deregister an observer
    NSNotificationCenter.defaultCenter().removeObserver(instance, name: observerName, object: nil)
}


public extension SequenceType {
    // This an extension of SequenceType objects (eg. array)
    
    func categorise<U: Hashable>(@noescape keyFunc: Generator.Element -> U) -> [U:[Generator.Element]] {
        // Categorises elements of self into a dictionary, with the keys given by keyFunc
        var dict: [U:[Generator.Element]] = [:]
        for el in self {
            let key = keyFunc(el)
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
}


// The following three functions are used to compare NSDate objects
func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    // The two operands are equal
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

func <(lhs: NSDate, rhs: NSDate) -> Bool {
    // The left operand is smaller than the right operand
    return lhs.compare(rhs) == .OrderedAscending
}

func >(lhs: NSDate, rhs: NSDate) -> Bool {
    // The left operand is greater than the right operand
    return lhs.compare(rhs) == .OrderedDescending
}

// The following function si used to compare Location objects
func ==(lhs: Location, rhs: Location) -> Bool {
    // The two operands are equal - applied to Location
    return lhs.id == rhs.id
}