//
//  Location.swift
//  DipMatBeacon
//
//  Created by Diego Russo on 29/05/2016.
//  Copyright © 2016 Diego Russo. All rights reserved.
//

import Foundation


class Location{
    
    // Data Encapsulation - can be set within the class
    private(set) var id:String
    private(set) var name:String
    private(set) var building:String
    private(set) var floor:String
    private(set) var mayor:Int
    private(set) var minor:Int
    
    init(id:String, name:String, building:String, floor:String, minor:Int, mayor:Int){
        
        self.id = id
        self.name = name
        self.building = building
        self.floor = floor
        self.minor = minor
        self.mayor = mayor

    }
    
}