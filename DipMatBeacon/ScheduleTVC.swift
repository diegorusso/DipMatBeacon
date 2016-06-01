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
    
    var sectionSchedules = [String: [Schedule]]()
    var sortedSections = [String]()
    
    @IBOutlet weak var nowButton: UIBarButtonItem!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        registerObserver("ReachStatusChanged", instance: self, with: #selector(ScheduleTVC.reachabilityStatusChanged))
        
        // Just call it the first time
        reachabilityStatusChanged()
    }
}

extension ScheduleTVC{
    
    func didLoadData(schedules: [Schedule]) {
        
        self.schedules = schedules
    
        // This is done through an extension of SequenceType (see Utils.swift)
        self.sectionSchedules = self.schedules.categorise{sectionHeaderFromDate($0.startingTime)}
        
        // Let's have an array of sorted String
        self.sortedSections = self.sectionSchedules.keys.elements.sort({$0.compare($1) == NSComparisonResult.OrderedAscending })
        
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: LIGHTGREY]
        navigationController?.navigationBar.barTintColor = DARKGREY
        navigationController?.navigationBar.tintColor = LIGHTGREY
        navigationController?.toolbar.barTintColor = DARKGREY
        nowButton.enabled = true
        nowButton.tintColor = LIGHTGREY
        
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
    
    @IBAction func moveToCurrentSchedule(sender: UIBarButtonItem) {
        let now = NSDate()
        let currentTimeSectionHeader = sectionHeaderFromDate(now)
        var nearestSection = 0
        
        for (index, section) in sortedSections.enumerate(){
            if currentTimeSectionHeader < section {
                nearestSection = index
                break
            }
        }
        
        let indexPath = NSIndexPath(forItem: 0, inSection: nearestSection)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }
    
}

extension ScheduleTVC {
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.sectionSchedules.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sectionSchedules[sortedSections[section]]!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ScheduleTableViewCell
        
        // get the items in this section
        let sectionItems = self.sectionSchedules[sortedSections[indexPath.section]]
        // get the item for the row in this section
        cell.schedule = sectionItems![indexPath.row]

        return cell
    }
    
    
    // This method changes the color of the cells
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // get the items in this section
        let sectionItems = self.sectionSchedules[sortedSections[indexPath.section]]
        // get the item for the row in this section
        let schedule = sectionItems![indexPath.row]
        
        cell.backgroundColor = correspondenceColor(schedule.correspondence)
    }
    

    
    // This method changes the color of the section header
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 30))
        returnedView.backgroundColor = LIGHTGREY
        
        let label = UILabel(frame: CGRectMake(10, 0, tableView.bounds.size.width, 30))
        label.text = self.sortedSections[section]
        label.textColor = DARKGREY
        returnedView.addSubview(label)
        
        return returnedView
    }
}

extension ScheduleTVC {
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "scheduleDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                
                // get the items in this section
                let sectionItems = self.sectionSchedules[sortedSections[indexPath.section]]
                // get the item for the row in this section
                let schedule = sectionItems![indexPath.row]
            
                let dvc = segue.destinationViewController as! ScheduleDetailsVC
                dvc.schedule = schedule
            }
        }
    }

}

