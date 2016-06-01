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
    }

}
