//
//  APIManager.swift
//  DipMatBeacon
//
//  Created by Diego Russo on 29/05/2016.
//  Copyright © 2016 Diego Russo. All rights reserved.
//

import Foundation

class APIManager{
    
    func loadData(urlString: String, completion: ([Schedule], [Location])-> Void){
        // The method gets the data from usrlString and builds two lists, one for Schedule and for for Location. It passes then these two lists to completion methods passed as argument
        NSLog("loadData")
        
        // An ephemeral session has no persistent disk storage for cookies,
        // cache or credentials.
        // let config = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        // let session = NSURLSession(configuration: config)
        
        // Singleton disegn pattern
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: urlString)!
        
        // Async communication call in background thread started in suspended state
        let task = session.dataTaskWithURL(url) {
            // dataTaskWithURL creates a task that retrieves the contents of the specified URL, then calls a handler upon completion
            (data, response, error) -> Void in
            // This is the callback
            if error != nil { // oops, there is an error
                NSLog(error!.localizedDescription)
            } else { // OK, everything looks good
                let (schedules, locations) = self.parseJson(data)
                //Set the highest priority possible
                let priority = DISPATCH_QUEUE_PRIORITY_HIGH
                dispatch_async(dispatch_get_global_queue(priority, 0)){
                    dispatch_async(dispatch_get_main_queue()) {
                        // this is the function passed as argument
                        completion(schedules, locations)
                    }
                }
            }
        }
        
        // It executes the background process
        task.resume()
    }
    
    func parseJson(data: NSData?) -> ([Schedule], [Location]) {
        // The method serialises the JSON data and it creates two arrays of Schedule and Location models
        do {
            // .AllowFragments - top level object is not Array or Dictionary
            // Any type of string or value
            // NSJSONSerialization requires the Do / Try /Catch
            // Converts the NSDATA into an AnyObject and pass it to extracScheduleDataFromJson */
            if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as AnyObject? {
                return JSONDataExtractor.extractDataFromJson(json)
            }
        } catch {
            NSLog("Failed to parse data: \(error)")
        }
        // There has been an error, I return empty lists
        return ([Schedule](), [Location]())
    }
}
