//
//  ViewController.swift
//  DipMatBeacon
//
//  Created by Diego Russo on 28/05/2016.
//  Copyright © 2016 Diego Russo. All rights reserved.
//

import UIKit
import CoreLocation

class ScheduleTVC: UITableViewController {
    
    // Gobal Variables - cannot be in the extension
    var schedules = [Schedule]()
    var locations = [Location]()
    
    var sectionSchedules = [String: [Schedule]]()
    var sortedSections = [String]()
    
    // That's for the search
    var filterSearch = [Schedule]()
    let resultSearchController = UISearchController(searchResultsController: nil)
    
    var loadingLabel = UILabel()
    
    var lastProximity: CLProximity?
    var locationManager = CLLocationManager()
    var nearSchedule: Schedule?
    
    @IBOutlet weak var nowButton: UIBarButtonItem!
    @IBOutlet weak var nearScheduleButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        
        loadingLabel.text = "Caricamento dati..."
        loadingLabel.backgroundColor = LIGHTGREY
        loadingLabel.textColor = DARKGREY
        loadingLabel.numberOfLines = 0
        loadingLabel.textAlignment = NSTextAlignment.Center
        loadingLabel.sizeToFit()
        
        self.tableView.backgroundView = loadingLabel
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        disableNavigationButton()
        
        // Do any additional setup after loading the view, typically from a nib.
        registerObserver("ReachStatusChanged", instance: self, with: #selector(ScheduleTVC.reachabilityStatusChanged))
        
        // Just call it the first time
        reachabilityStatusChanged()
        
        // Setup Beacon
        setupBeacon()
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        refreshControl?.endRefreshing()
        
        if resultSearchController.active {
            refreshControl?.attributedTitle = NSAttributedString(string: "No refresh allowed in search")
        } else {
            runAPI()
        }
    }
}

extension ScheduleTVC: UISearchResultsUpdating{
    
    func didLoadData(schedules: [Schedule], locations: [Location]) {
        
        self.schedules = schedules
        self.locations = locations
        
        updateSections(self.schedules)
        
        //NavigationController
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: LIGHTGREY]
        navigationController?.navigationBar.barTintColor = DARKGREY
        navigationController?.navigationBar.tintColor = LIGHTGREY
        navigationController?.toolbar.barTintColor = DARKGREY
        nowButton.enabled = true
        nowButton.tintColor = LIGHTGREY
        
        title = ("DMI - MRBS")
        
        // That's the search
        resultSearchController.searchResultsUpdater = self
        definesPresentationContext = true
        // That's very important: if it is true, during search I cannot do anything and when you click on a video you come back to the original view
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.searchBar.placeholder = "Cerca..."
        resultSearchController.searchBar.searchBarStyle = UISearchBarStyle.Prominent
        tableView.tableHeaderView = resultSearchController.searchBar
        
        loadingLabel.hidden = true
        
        tableView.reloadData()
        
    }
    
    func updateSections(schedules: [Schedule]){
        // This is done through an extension of SequenceType (see Utils.swift)
        self.sectionSchedules = schedules.categorise{sectionHeaderFromDate($0.startingTime)}
        
        // Let's have an array of sorted String
        self.sortedSections = self.sectionSchedules.keys.elements.sort({$0.compare($1) == NSComparisonResult.OrderedAscending })
    }
    
    func runAPI() {
        setRefreshTimestamp()
        
        // Call API
        let api = APIManager()
        let urlSchedulesApi = "https://ibeacon.stamplayapp.com/api/cobject/v1/schedule?per_page=all&populate=true&sort=start"
        api.loadData(urlSchedulesApi, completion: didLoadData)
    }
    
    // method to execute every time the ReachStatusChanged notification is received
    func reachabilityStatusChanged(){
        switch reachabilityStatus {
        case NOACCESS:
            // Move back to the main queue
            dispatch_async(dispatch_get_main_queue()){
                let alert = UIAlertController(title: "No Internet Access", message: "Please make sure you are connected to the Internet", preferredStyle: .Alert)
                
                let okAction = UIAlertAction(title: "OK", style: .Default){
                    action -> Void in
                    // do something if you want
                }
                
                alert.addAction(okAction)
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        default:
            if schedules.count == 0 {
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
    
    func filterSearch(searchText: String){
        filterSearch = schedules.filter { schedule in
            return schedule.shortDescription.lowercaseString.containsString(searchText.lowercaseString) ||
                schedule.longDescription.lowercaseString.containsString(searchText.lowercaseString) ||
                schedule.professor.lowercaseString.containsString(searchText.lowercaseString) ||
                schedule.location.name.lowercaseString.containsString(searchText.lowercaseString) ||
                schedule.location.building.lowercaseString.containsString(searchText.lowercaseString) ||
                schedule.createdBy.lowercaseString.containsString(searchText.lowercaseString) ||
                schedule.correspondence.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        if resultSearchController.active {
            updateSections(filterSearch)
        } else {
            updateSections(self.schedules)
        }
        
        tableView.reloadData()
        
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        searchController.searchBar.text!.lowercaseString
        filterSearch(searchController.searchBar.text!)
    }
    
    func setRefreshTimestamp(){
        // Let's show when the API were run
        let refreshDate = completeDateFromDate(NSDate())
        refreshControl?.attributedTitle = NSAttributedString(string: "\(refreshDate)")
    }
    
}

extension ScheduleTVC {
    // MARK: - Table view data source
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        
        if self.schedules.count > 0 {
            return self.sectionSchedules.count
        } else {
            return 0
        }
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
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = DARKGREY.CGColor
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
        if segue.identifier == "nearScheduleDetail"{
            let dvc = segue.destinationViewController as! ScheduleDetailsVC
            dvc.schedule = self.nearSchedule
        }
    }
    
}

extension ScheduleTVC: CLLocationManagerDelegate {
    
    func setupBeacon(){
        let uuidString = UUIDBeaconApp
        let beaconIdentifier = "jalee"
        let beaconUUID:NSUUID = NSUUID(UUIDString: uuidString)!
        let beaconRegion:CLBeaconRegion = CLBeaconRegion(proximityUUID: beaconUUID, identifier: beaconIdentifier)
        
        if(locationManager.respondsToSelector(#selector(CLLocationManager.requestAlwaysAuthorization))) {
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = false
        
        locationManager.startMonitoringForRegion(beaconRegion)
        locationManager.startRangingBeaconsInRegion(beaconRegion)
        locationManager.startUpdatingLocation()
    }
    
    func sendLocalNotificationWithMessage(message: String!, playSound: Bool) {
        let notification:UILocalNotification = UILocalNotification()
        notification.alertBody = message
        
        if(playSound) {
            notification.soundName = UILocalNotificationDefaultSoundName
        }
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        if(beacons.count > 0) {
            let nearestBeacon:CLBeacon = beacons[0]
            if(nearestBeacon.proximity == lastProximity || nearestBeacon.proximity == CLProximity.Unknown) {
                return;
            }
            
            lastProximity = nearestBeacon.proximity;
            
            switch nearestBeacon.proximity {
            case CLProximity.Far:
                print("far")
                disableNavigationButton()
            case CLProximity.Near:
                print("near")
                disableNavigationButton()
            case CLProximity.Immediate:
                print("immediate")
                searchLocation(nearestBeacon)
            case CLProximity.Unknown:
                return
            }
        } else {
            if(lastProximity == CLProximity.Unknown) {
                return;
            }
            lastProximity = CLProximity.Unknown
        }
    }
    
    func searchLocation(nearestBeacon: CLBeacon) {
        let locationMinor = nearestBeacon.minor
        let locationMajor = nearestBeacon.major
        
        let now = NSDate()
        
        let nearestLocations = self.locations.filter{$0.minor == locationMinor && $0.major == locationMajor}
        
        guard let nearestLocation = nearestLocations.first else {return}
        let schedulesLocation = self.schedules.filter{$0.location == nearestLocation && now > $0.startingTime && now < $0.endTime}
        guard let schedule = schedulesLocation.first else {return}
        
        switch UIApplication.sharedApplication().applicationState {
        case .Active:
            //The app is running in the foreground and is receiving events. This is the normal mode for foreground apps.
            enableNavigationButton(schedule)
        case .Inactive:
            // The app is running in the foreground but is currently not receiving events. (It may be executing other code though.) An app usually stays in this state only briefly as it transitions to a different state.
            sendLocalNotification(schedule, nearestLocation: nearestLocation)
        case .Background:
            // The app is in the background and executing code
            sendLocalNotification(schedule, nearestLocation: nearestLocation)
        }
    }
    
    
    @IBAction func showNearScheduleDetail(sender: UIBarButtonItem) {
        performSegueWithIdentifier("nearScheduleDetail", sender: sender)
    }
    
    func enableNavigationButton(schedule: Schedule){
        nearScheduleButton.title = schedule.location.name
        nearScheduleButton.enabled = true
        self.nearSchedule = schedule
    }
    
    func disableNavigationButton(){
        nearScheduleButton.title = ""
        nearScheduleButton.enabled = false
        self.nearSchedule = nil
    }
    
    func sendLocalNotification(schedule: Schedule, nearestLocation: Location){
        var notificationMessage = ""
        if schedule.exam == true {
            notificationMessage = "Esame di \"\(schedule.shortDescription)\" in corso in \"\(nearestLocation.name)\""
        } else {
            notificationMessage = "Lezione di \"\(schedule.shortDescription)\" in corso in \"\(nearestLocation.name)\""
        }
        
        sendLocalNotificationWithMessage(notificationMessage, playSound: true)
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        manager.startRangingBeaconsInRegion(region as! CLBeaconRegion)
        manager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        manager.stopRangingBeaconsInRegion(region as! CLBeaconRegion)
        manager.stopUpdatingLocation()
        disableNavigationButton()
    }
}



