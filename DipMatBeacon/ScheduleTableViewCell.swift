//
//  ScheduleTableViewCell.swift
//  DipMatBeacon
//
//  Created by Diego Russo on 30/05/2016.
//  Copyright © 2016 Diego Russo. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {


    // The logic to setup the cell should be in this class and nowhere else!
    var schedule: Schedule? {
        didSet{
            updateCell()
        }
    }
    
    @IBOutlet weak var shortDescription: UILabel!
    @IBOutlet weak var professor: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var time: UILabel!
    
    func updateCell(){
        shortDescription.text = schedule?.shortDescription
        professor.text = schedule?.professor
        location.text = schedule?.location.name
        time.text = _getTime(schedule!.startingTime, to: schedule!.endTime)
    }
    
    func _getTime(startingTime:NSDate, to endTime:NSDate) -> String {
        let from: String = timeFromDate(startingTime)
        let to: String = timeFromDate(endTime)
        return "\(from) - \(to)"
    }

}
