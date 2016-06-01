//
//  APIManager.swift
//  DipMatBeacon
//
//  Created by Diego Russo on 29/05/2016.
//  Copyright © 2016 Diego Russo. All rights reserved.
//

import Foundation

class APIManager{
    
    func loadData(urlString: String, completion: [Schedule]-> Void){
        
        // An ephemeral session has no persistent disk storage for cookies,
        // cache or credentials.
        //let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        //let session = NSURLSession(configuration: config)
        
        // Singleton disegn pattern
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: urlString)!
        
        // Async communication call in background thread
        // Started in suspended state
        let task = session.dataTaskWithURL(url) {
            (data, response, error) -> Void in
            
            if error != nil { // oops, there is an error
                print(error!.localizedDescription)
            } else { // OK, everything looks good
                
                let schedules = self.parseJson(data)
                
                let priority = DISPATCH_QUEUE_PRIORITY_HIGH //highest priority possible
                dispatch_async(dispatch_get_global_queue(priority, 0)){
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(schedules)
                    }
                }
            }
        }
        
        // It executes the background process
        task.resume()
        
    }
    
    func parseJson(data: NSData?) -> [Schedule] {
        // JSONSerialization
        do {
            /* .AllowFragments - top level object is not Array or Dictionary
             Any type of string or value
             NSJSONSerialization requires the Do / Try /Catch
             Converts the NSDATA into an AnyObject and pass it to extracScheduleDataFromJson */
            if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as AnyObject?{
                return JSONDataExtractor.extractScheduleDataFromJson(json)
            }
        } catch {
            print("Failed to parse data: \(error)")
        }
        return [Schedule]()
    }
}
