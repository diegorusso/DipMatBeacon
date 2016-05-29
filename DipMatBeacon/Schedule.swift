//
//  Schedule.swift
//  DipMatBeacon
//
//  Created by Diego Russo on 29/05/2016.
//  Copyright © 2016 Diego Russo. All rights reserved.
//

import Foundation


class Schedule {
    
    // Data Encapsulation - can be set within the class
    private(set) var id:String
    private(set) var title:String
    private(set) var description:String
    private(set) var type:String
    private(set) var location:Location
    private(set) var professor:String
    private(set) var start:NSDate
    private(set) var end:NSDate
    
    init(id:String, title:String, description:String, type:String, location:Location, professor:String, start:NSDate, end:NSDate){
        
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.location = location
        self.professor = professor
        self.start = start
        self.end = end
        
    }
    
    
}