//
//  ScheduleTableViewCell.swift
//  DipMatBeacon
//
//  Created by Diego Russo on 30/05/2016.
//  Copyright © 2016 Diego Russo. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {
    // This class represents the single cell and
    // The logic to setup the cell should be in this class and nowhere else!
    
    var schedule: Schedule? {
        didSet{
            // didSet is called immediately after the new value is stored.
            updateCell()
        }
    }
    
    // Labels dragged from the View
    @IBOutlet weak var shortDescription: UILabel!
    @IBOutlet weak var professor: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var time: UILabel!
    
    func updateCell(){
        // Set all the labels within the cell
        shortDescription.text = schedule?.shortDescription
        professor.text = schedule?.professor
        location.text = schedule?.location.name
        time.text = "\(timeFromDate(schedule!.startingTime)) - \(timeFromDate(schedule!.endTime))"
    }
}
