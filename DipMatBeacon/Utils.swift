//
//  Utils.swift
//  DipMatBeacon
//
//  Created by Diego Russo on 29/05/2016.
//  Copyright © 2016 Diego Russo. All rights reserved.
//

import Foundation


func dateFromString(dateString:String) -> NSDate {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'.000Z'"
    dateFormatter.timeZone = NSTimeZone(name: "UTC")
    let date: NSDate? = dateFormatter.dateFromString(dateString)
    return date!
}