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
    
    
    @IBAction func shareSchedule(sender: UIBarButtonItem) {
        shareScheduleDetails()
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
    
    func shareScheduleDetails(){
        let activity1:String
        let activity5:String
        
        if schedule.exam {
            activity1 = "L'esame \"\(schedule.shortDescription)\""
            activity5 = "Si prega di arrivare in orario altrimenti non si avrà diritto a sostenere l'esame."
        } else {
            activity1 = "La lezione \"\(schedule.shortDescription)\""
            activity5 = ""
        }
        let activity2 = "del professore \(schedule.professor)"
        let activity3 = "si svolgerà il giorno \(ISODateFromDate(schedule.startingTime)) dalle \(timeFromDate(schedule.startingTime)) alle \(timeFromDate(schedule.endTime))"
        let activity4 = "in \"\(schedule.location.name)\" (piano \(schedule.location.floor) di \(schedule.location.building))."
        let activity6 = "L'utilizzo di dispositivi mobili non è ammesso."
        
        let activity7 = "\n\n(Condiviso automaticamente tramite l'app DipMatBeacon)"
        
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [activity1, activity2, activity3, activity4, activity5, activity6, activity7], applicationActivities: nil)
        
        // To disable email sharing
        //activityViewController.excludedActivityTypes = [UIActivityTypeMail]
        
        activityViewController.completionWithItemsHandler = {
            (activity, success, items, error) in
            
            if activity == UIActivityTypeMail {
                NSLog("Email selected")
            }
        }
        
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }

}
