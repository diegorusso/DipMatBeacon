//
//  JSONDataExtractor.swift
//  DipMatBeacon
//
//  Created by Diego Russo on 30/05/2016.
//  Copyright © 2016 Diego Russo. All rights reserved.
//

import Foundation

class JSONDataExtractor {
    
    static func extractLocationDataFromJSon(locationDataObject: AnyObject) -> Location {
        
        // Initialise variables
        var id = "", name = "", building = "", floor = "", minor = 0, mayor = 0
        let _emptyLocation = Location(id: id, name: name, building: building, floor: floor, minor: minor, mayor: mayor)
        
        guard let data = locationDataObject as? JSONDictionary else { return _emptyLocation}
        
        // id
        if let locationId = data["id"] as? String {
            id = locationId
        }
        
        // name
        if let locationName = data["name"] as? String {
            name = locationName
        }
        
        // building
        if let locationBuilding = data["building"] as? String {
             building = locationBuilding
        }
        
        // floor
        if let locationFloor = data["floor"] as? String {
            floor = locationFloor
        }
        
        // minor
        if let locationMinor = data["minor"] as? Int {
            minor = locationMinor
        }
        
        // mayor
        if let locationMayor = data["mayor"] as? Int {
            mayor = locationMayor
        }
        
        let currentLocation =  Location(id: id, name: name, building: building, floor: floor, minor: minor, mayor: mayor)
        return currentLocation
    }
    
    static func extractScheduleDataFromJson(scheduleDataObject: AnyObject) -> [Schedule] {
        
        // guard is like an assert: in this case we check if scheduleDataObject is a JSONDictionary. If so, we continue otherwise we return an empty array. scheduleData will be available in the entire function
        guard let scheduleData = scheduleDataObject as? JSONDictionary else { return [Schedule]()}
        
        var schedules = [Schedule]()
        
        if let entries = scheduleData["data"] as? JSONArray {
            for data in entries {
                
                // Initialise variables
                let _emptyLocation = Location(id: "", name: "", building: "", floor: "", minor: 0, mayor: 0)
                
                var scheduleId = "", shortDescription = "", location = _emptyLocation, startingTime = NSDate(), endTime = NSDate(), duration = "", longDescription = "",
                correspondence = "", bookingType = "", createdBy = "", approved = false, professor = "", exam = false, degree = "", lastChange = NSDate()
                
                // id
                if let dataId = data["id"] as? String {
                    scheduleId = dataId
                }
                
                // short_description
                if let dataShortDescription = data["short_description"] as? String {
                    shortDescription = dataShortDescription
                }
                
                // location
                if let dataLocationArray = data["location"] as? JSONArray,
                    let dataLocation = dataLocationArray[0] as? JSONDictionary{
                    location = JSONDataExtractor.extractLocationDataFromJSon(dataLocation)
                }
                
                // starting_time
                if let dataStartingTime = data["starting_time"] as? String {
                    startingTime = timestampFromString(dataStartingTime)
                }
                
                // end_time
                if let dataEndTime = data["end_time"] as? String {
                    endTime = timestampFromString(dataEndTime)
                }
                
                // duration
                if let dataDuration = data["duration"] as? String {
                    duration = dataDuration
                }
                
                // long_description
                if let dataLongDescription = data["long_description"] as? String {
                    longDescription = dataLongDescription
                }
                
                // correspondence
                if let dataCorrespondence = data["correspondence"] as? String {
                    correspondence = dataCorrespondence
                }
                
                // booking_type
                if let dataBookingType = data["booking_type"] as? String {
                    bookingType = dataBookingType
                }
                
                // created_by
                if let dataCreatedBy = data["created_by"] as? String {
                    createdBy = dataCreatedBy
                }
                
                // approved
                if let dataApproved = data["approved"] as? Bool {
                    approved = dataApproved
                }
                
                // professor
                if let dataProfessor = data["professor"] as? String {
                    professor = dataProfessor
                }
                
                // exam
                if let dataExam = data["exam"] as? Bool {
                    exam = dataExam
                }
                
                // degree
                if let dataDegree = data["degree"] as? String {
                    degree = dataDegree
                }
                
                // last_change
                if let dataLastChange = data["last_change"] as? String {
                    lastChange = timestampFromString(dataLastChange)
                }

                let currentSchedule = Schedule(id: scheduleId, shortDescription: shortDescription, location: location, startingTime: startingTime, endTime: endTime, duration: duration, longDescription: longDescription, correspondence: correspondence, bookingType: bookingType, createdBy: createdBy, approved: approved, professor: professor, exam: exam, degree: degree, lastChange: lastChange)
                
                schedules.append(currentSchedule)
            }
        }
        return schedules
    }
}

