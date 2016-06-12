//
//  ScheduleDetailsVC.swift
//  DipMatBeacon
//
//  Created by Diego Russo on 31/05/2016.
//  Copyright © 2016 Diego Russo. All rights reserved.
//

import UIKit
import LocalAuthentication

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
        // Called after the controller's view is loaded into memory.
        NSLog("viewDidLoad")
        super.viewDidLoad()
        // It sets all the labels in the view
        setLabels()
    }
    
    override func viewWillAppear(animated: Bool) {
        // This method is called before the view controller's view is about to be added to a view
        // hierarchy and before any animations are configured for showing the view.
        // You can override this method to perform custom tasks associated with displaying the view.
        NSLog("viewWillAppear")
        super.viewWillAppear(false)
        view.backgroundColor = correspondenceColor(schedule.correspondence)
    }
    
    @IBAction func shareSchedule(sender: UIBarButtonItem) {
        // This is executed whenever the user tap on share button
        NSLog("shareSchedule")
        touchIDCheck()
    }

}

extension ScheduleDetailsVC {
    // In this class extension I define all custom methods

    func setLabels(){
        // It sets all the labels in the view
        
        // The title is the location name
        title = schedule.location.name
        
        // Top side of the view
        shortDescription.text = schedule.shortDescription
        longDescription.text = schedule.longDescription
        professor.text = schedule.professor
        
        // Depending on the exam value, the icon changes
        if schedule.exam {
            exam.image = UIImage(named: "exam.png")
        } else {
            exam.image = UIImage(named: "lecture.png")
        }
        
        // Temporal data
        date.text = ISODateFromDate(schedule.startingTime)
        fromTo.text = "\(timeFromDate(schedule.startingTime)) - \(timeFromDate(schedule.endTime))"
        duration.text = schedule.duration
        
        // Location data
        room.text = schedule.location.name
        floor.text = schedule.location.floor
        building.text = schedule.location.building
        
        // Depending on the approval, the icon changes
        if schedule.approved {
            approved.image = UIImage(named: "approved.png")
        } else {
            approved.image = UIImage(named: "notApproved.png")
        }
        
        // Other details
        createdBy.text = schedule.createdBy
        correspondence.text = schedule.correspondence
        bookingType.text = schedule.bookingType
        lastChange.text = completeDateFromDate(schedule.lastChange)
    }
    
    func shareScheduleDetails(){
        // I creates the UIActivityViewController filled with the right information
        NSLog("shareScheduleDetails")
        
        // Those strings will be used to create the UIActivityViewController
        let activity1, activity2, activity3, activity4, activity5, activity6, activity7:String
        
        // Depeding on the exam value, activity1 and activity5 change
        if schedule.exam {
            activity1 = "L'esame \"\(schedule.shortDescription)\""
            activity5 = "Si prega di arrivare in orario altrimenti non si avrà diritto a sostenere l'esame."
        } else {
            activity1 = "La lezione \"\(schedule.shortDescription)\""
            activity5 = ""
        }
        // It sets other strings activity
        activity2 = "del professore \(schedule.professor)"
        activity3 = "si svolgerà il giorno \(ISODateFromDate(schedule.startingTime)) dalle \(timeFromDate(schedule.startingTime)) alle \(timeFromDate(schedule.endTime))"
        activity4 = "in \"\(schedule.location.name)\" (piano \(schedule.location.floor) di \(schedule.location.building))."
        activity6 = "L'utilizzo di dispositivi mobili non è ammesso."
        activity7 = "\n\n(Condiviso automaticamente tramite l'app DipMatBeacon)"
        
        // Create the UIActivityViewController with above strings
        let activityViewController = UIActivityViewController(activityItems: [activity1, activity2, activity3, activity4, activity5, activity6, activity7], applicationActivities: nil)
        
        // I might disable email sharing
        //activityViewController.excludedActivityTypes = [UIActivityTypeMail]
        
        // I might define a handler to complete the sharing action
        /*activityViewController.completionWithItemsHandler = {
            (activity, success, items, error) in
            
            if activity == UIActivityTypeMail {
                NSLog("Email selected")
            }
        }*/
        
        // Finally I present theUIActivityViewController
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    func touchIDCheck(){
        // This method is responsible to authenticate the user through TouchID
        NSLog("touchIDCheck")
        
        // Create the local Authentication Context
        let context = LAContext()
        // NSError to store errors
        var touchIDError:NSError?
        // This is the reason we need access to TouchID
        let reasonString = "Autenticazione tramite TouchID necessaria per condividere i dettagli"
        
        // Check if we can access local device authentication
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error:&touchIDError) {
            // Check what the authentication response was
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success, policyError) -> Void in
                if success {
                    // User authenticated using Local Device Authentication Successfully
                    dispatch_async(dispatch_get_main_queue()) {[unowned self] in
                        self.shareScheduleDetails()
                    }
                } else {
                    // Set the error alert message with more information
                    let message: String?
                    switch LAError(rawValue: policyError!.code)!{
                    case .AppCancel:
                        message = "Autenticazione cancellata dall'applicazione"
                    case .AuthenticationFailed:
                        message = "Autenticazione fallita"
                    case .PasscodeNotSet:
                        message = "Passcode non impostato sul dispositivo"
                    case .SystemCancel:
                        message = "Autenticazione cancellata dal sistema"
                    case .TouchIDLockout:
                        message = "Troppi tentativi falliti"
                    case .UserCancel:
                        message = "Autenticazione cancellata dall'utente"
                    case .UserFallback:
                        message = "Password non accettata, TouchID deve essere utilizzato"
                    default:
                        message = "Impossibile autenticare"
                    }
                    
                    // Create the alert
                    let alert = UIAlertController(title: "Senza Successo", message: message, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Continua", style: .Cancel, handler: nil))
                    
                    // Show the alert
                    dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }) // ends evaluatePolicy
        } else {
            // Unable to access local device authentication
            
            // Set the error alert message with more information
            let message: String?
            switch LAError(rawValue: touchIDError!.code)! {
            case .TouchIDNotEnrolled:
                message = "TouchID non configurato"
            case .TouchIDNotAvailable:
                message = "TouchID non disponibile"
            case .PasscodeNotSet:
                message = "Passcode non impostato"
            case .InvalidContext:
                message = "Il contesto é invalido"
            default:
                message = "Autenticazione Locale non disponibile"
            }
            
            // Create the alert
            let alert = UIAlertController(title: "Errore", message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Continua", style: .Cancel, handler: nil))
            
            // Show the alert
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
}
