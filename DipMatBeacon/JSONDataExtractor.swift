//
//  JSONDataExtractor.swift
//  DipMatBeacon
//
//  Created by Diego Russo on 30/05/2016.
//  Copyright © 2016 Diego Russo. All rights reserved.
//

import Foundation

class JSONDataExtractor {
    
    static private func extractLocationDataFromJson(locationDataObject: AnyObject) -> Location {
        // Private method to create Location instance with data passed as argument
        
        // Initialise variables
        var id = "", name = "", building = "", floor = "", minor = 0, major = 0
        
        // That's an empty Location
        let _emptyLocation = Location(id: id, name: name, building: building, floor: floor, minor: minor, major: major)
        
        // guard is like an assert: in this case we check if locationDataObject is a JSONDictionary
        // If so we continue and locationDataObject will be available in the entire function, otherwise we return an empty Location
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
        
        // major
        if let locationMajor = data["major"] as? Int {
            major = locationMajor
        }
        
        // it returns Location with all the data set
        return Location(id: id, name: name, building: building, floor: floor, minor: minor, major: major)
    }
    
    static func extractDataFromJson(scheduleDataObject: AnyObject) -> ([Schedule], [Location]) {
        
        // guard is like an assert: in this case we check if scheduleDataObject is a JSONDictionary
        // If so we continue and scheduleData will be available in the entire function, otherwise we return an empty tuple
        guard let scheduleData = scheduleDataObject as? JSONDictionary else { return ([Schedule](), [Location]())}
        
        var schedules = [Schedule]()
        // There will be a lot of duplicates, so I create a Set
        var locations = Set<Location>()
        
        if let entries = scheduleData["data"] as? JSONArray {
            for data in entries {
                
                // Initialise variables
                let _emptyLocation = Location(id: "", name: "", building: "", floor: "", minor: 0, major: 0)
                
                var scheduleId = "", shortDescription = "", location = _emptyLocation, startingTime = NSDate(), endTime = NSDate(),
                    duration = "", longDescription = "", correspondence = "", bookingType = "", createdBy = "", approved = false,
                    professor = "", exam = false, degree = "", lastChange = NSDate()
                
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
                    location = JSONDataExtractor.extractLocationDataFromJson(dataLocation)
                    locations.insert(location)
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
        
        // locations is a Set(), hence need to be converted in Array
        return (schedules, Array(locations))
    }
}

