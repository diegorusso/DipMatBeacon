//
//  ViewController.swift
//  DipMatBeacon
//
//  Created by Diego Russo on 28/05/2016.
//  Copyright © 2016 Diego Russo. All rights reserved.
//

import UIKit

class ScheduleTVC: UITableViewController {
    
    // Gobal Variables - cannot be in the extension
    var schedules = [Schedule]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        registerObserver("ReachStatusChanged", instance: self, with: #selector(ScheduleTVC.reachabilityStatusChanged))
        
        // Just call it the first time
        reachabilityStatusChanged()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ScheduleTVC{
    
    func didLoadData(schedules: [Schedule]) {
        
        self.schedules = schedules
        
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: LIGHTGREY]
        navigationController?.navigationBar.barTintColor = DARKGREY
        navigationController?.navigationBar.tintColor = LIGHTGREY
        navigationController?.toolbar.barTintColor = DARKGREY
        
        title = ("MRBS")
        
        tableView.reloadData()
        
    }
    
    func runAPI() {
        // Call API
        let api = APIManager()
        let urlApi = "https://ibeacon.stamplayapp.com/api/cobject/v1/schedule?per_page=all&populate=true&sort=start"
        api.loadData(urlApi, completion: didLoadData)
    }
    
    // method to execute every time the ReachStatusChanged notification is received
    func reachabilityStatusChanged(){
        switch reachabilityStatus {
        case NOACCESS:
            //view.backgroundColor = UIColor.redColor()
            // Move back to the main queue
            dispatch_async(dispatch_get_main_queue()){
                let alert = UIAlertController(title: "No Internet Access", message: "Please make sure you are connected to the Internet", preferredStyle: .Alert)
                
                let okAction = UIAlertAction(title: "OK", style: .Default){
                    action -> Void in
                    print("OK")
                    
                    // do something if you want
                }
                
                alert.addAction(okAction)
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        default:
            //view.backgroundColor = UIColor.greenColor()
            if schedules.count > 0 {
                print("Do not refresh API")
            } else {
                runAPI()
            }
        }
    }
}

extension ScheduleTVC {
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedules.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ScheduleTableViewCell
        
        cell.schedule = schedules[indexPath.row]

        return cell
    }
    
    
    // This method is to change the color of the cells
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let schedule = schedules[indexPath.row]
        
        cell.backgroundColor = correspondenceColor(schedule.correspondence)
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
}

extension ScheduleTVC {
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "scheduleDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                
                let schedule = schedules[indexPath.row]
            
                let dvc = segue.destinationViewController as! ScheduleDetailsVC
                dvc.schedule = schedule
            }
        }
    }

}

