//
//  Schedule.swift
//  DipMatBeacon
//
//  Created by Diego Russo on 29/05/2016.
//  Copyright © 2016 Diego Russo. All rights reserved.
//

import Foundation


class Schedule {
    // Schedule Model
    
    // Data Encapsulation - can be set only within the class
    private(set) var id:String
    private(set) var shortDescription:String
    private(set) var location:Location
    private(set) var startingTime:NSDate
    private(set) var endTime:NSDate
    private(set) var duration:String
    private(set) var longDescription:String
    private(set) var correspondence:String
    private(set) var bookingType:String
    private(set) var createdBy:String
    private(set) var approved:Bool
    private(set) var professor:String
    private(set) var exam:Bool
    private(set) var degree:String
    private(set) var lastChange:NSDate
    
    
    init(id:String, shortDescription:String, location:Location, startingTime:NSDate,
         endTime:NSDate, duration:String, longDescription:String, correspondence:String,
         bookingType:String, createdBy:String, approved:Bool, professor:String, exam:Bool,
         degree:String, lastChange:NSDate) {
        // This is the constructor
        
        self.id = id
        self.shortDescription = shortDescription
        self.location = location
        self.startingTime = startingTime
        self.endTime = endTime
        self.duration = duration
        self.longDescription = longDescription
        self.correspondence = correspondence
        self.bookingType = bookingType
        self.createdBy = createdBy
        self.approved = approved
        self.professor = professor
        self.exam = exam
        self.degree = degree
        self.lastChange = lastChange
    }
}