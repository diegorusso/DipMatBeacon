//
//  ScheduleDetailsVC.swift
//  DipMatBeacon
//
//  Created by Diego Russo on 31/05/2016.
//  Copyright © 2016 Diego Russo. All rights reserved.
//

import UIKit

class ScheduleDetailsVC: UIViewController {
    
    var schedule:Schedule!
    
    @IBOutlet weak var shortDescription: UILabel!
    @IBOutlet weak var longDescription: UILabel!
    @IBOutlet weak var professor: UILabel!
    @IBOutlet weak var exam: UIImageView!
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var fromTo: UILabel!
    @IBOutlet weak var duration: UILabel!
    
    @IBOutlet weak var room: UILabel!
    @IBOutlet weak var floor: UILabel!
    @IBOutlet weak var building: UILabel!
    
    @IBOutlet weak var approved: UIImageView!
    @IBOutlet weak var createdBy: UILabel!
    @IBOutlet weak var correspondence: UILabel!
    @IBOutlet weak var bookingType: UILabel!
    @IBOutlet weak var lastChange: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        setLabels()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        view.backgroundColor = correspondenceColor(schedule.correspondence)
    }

}

extension ScheduleDetailsVC {

    func setLabels(){
        title = schedule.location.name
        
        shortDescription.text = schedule.shortDescription
        longDescription.text = schedule.longDescription
        professor.text = schedule.professor
        
        if schedule.exam {
            exam.image = UIImage(named: "exam.png")
        } else {
            exam.image = UIImage(named: "lecture.png")
        }
        
        date.text = ISODateFromDate(schedule.startingTime)
        fromTo.text = "\(timeFromDate(schedule.startingTime)) - \(timeFromDate(schedule.endTime))"
        duration.text = schedule.duration
        
        room.text = schedule.location.name
        floor.text = schedule.location.floor
        building.text = schedule.location.building
        
        if schedule.approved {
            approved.image = UIImage(named: "approved.png")
        } else {
            approved.image = UIImage(named: "notApproved.png")
        }
        
        createdBy.text = schedule.createdBy
        correspondence.text = schedule.correspondence
        bookingType.text = schedule.bookingType
        lastChange.text = completeDateFromDate(schedule.lastChange)
    }

}
