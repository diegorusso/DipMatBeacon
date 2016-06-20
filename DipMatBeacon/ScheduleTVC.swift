//
//  ViewController.swift
//  DipMatBeacon
//
//  Created by Diego Russo on 28/05/2016.
//  Copyright © 2016 Diego Russo. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

class ScheduleTVC: UITableViewController {
    
    // Global Variables - cannot be in the extension
    var schedules = [Schedule]()
    var locations = [Location]()
    
    var sectionSchedules = [String: [Schedule]]()
    var sortedSections = [String]()
    
    // That's for the search
    var filterSearch = [Schedule]()
    let resultSearchController = UISearchController(searchResultsController: nil)
    
    // Initial label
    var loadingLabel = UILabel()
    
    // Variables used for beaconing
    var lastProximity: CLProximity?
    var locationManager = CLLocationManager()
    var nearSchedule: Schedule?
    
    // Bottom navigation buttons
    @IBOutlet weak var nextScheduleButton: UIBarButtonItem!
    @IBOutlet weak var nearScheduleButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        // Called after the controller's view is loaded into memory.
        NSLog("viewDidLoad")
        super.viewDidLoad()
        // Initial setup
        setup()
    }
    
    @IBAction func moveToNextSchedule(sender: UIBarButtonItem) {
        // This method is executed whenever the user taps on nextSchedule button
        NSLog("moveToNextSchedule")
        
        // Find the nearest section
        let now = NSDate()
        let currentTimeSectionHeader = sectionHeaderFromDate(now)
        var nearestSection = 0
        
        for (index, section) in sortedSections.enumerate(){
            if currentTimeSectionHeader < section {
                nearestSection = index
                break
            }
        }
        
        if nearestSection > 0 {
            // Get the indePath of the nearestSection
            let indexPath = NSIndexPath(forItem: 0, inSection: nearestSection)
            // Scroll the table to the section just found
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        } else {
            // Create the alert
            let alert = UIAlertController(title: "Non ci sono più lezioni", message: "", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            // Show the alert
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in // unowned is like weak bun unlike weak it is assumed to always have a value
                self.presentViewController(alert, animated: true, completion: nil)
            }
        
        }
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        // The method is executed whenever the user pulls down the table and forces the refresh
        NSLog("refresh")
        
        // It is not allow to refresh while searching
        if resultSearchController.active {
            refreshControl?.attributedTitle = NSAttributedString(string: "Aggiornamento non permesso durante la ricerca")
        } else {
            // Get the new data
            runAPI()
        }
        
        // Tells the control that a refresh operation has ended.
        refreshControl?.endRefreshing()
    }
    
    @IBAction func showNearScheduleDetail(sender: UIBarButtonItem) {
        // This method is executed whenere the user tap on nearSchedule button
        NSLog("showNearScheduleDetail")
        performSegueWithIdentifier("nearScheduleDetail", sender: sender)
    }
    
    deinit {
        // Destructor: observers need to be deregistered
        deregisterObserver("ReachStatusChanged", instance: self)
        deregisterObserver("ReceivedLocalNotification", instance: self)
    }
}


extension ScheduleTVC {
    // The extension contains method used for setting up/initialise things
    
    func setup(){
        // The method performs an intial setup
        
        // creating the label while data is loading
        loadingLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        loadingLabel.text = "Caricamento dati..."
        loadingLabel.backgroundColor = LIGHTGREY
        loadingLabel.textColor = DARKGREY
        loadingLabel.numberOfLines = 0
        loadingLabel.textAlignment = NSTextAlignment.Center
        loadingLabel.sizeToFit()
        self.tableView.backgroundView = loadingLabel
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        // Hide bottom buttons
        nextScheduleButton.title = ""
        disableNearScheduleButton()
        
        // Register the observer for reachability
        registerObserver("ReachStatusChanged", instance: self, with: #selector(ScheduleTVC.reachabilityStatusChanged))
        // Register the observer for local notification
        registerObserver("ReceivedLocalNotification", instance: self, with: #selector(ScheduleTVC.receivedLocalNotification))
        
        // Just call it the first time. It will call runAPI() eventually
        reachabilityStatusChanged()
        
        // Beacon setup
        setupBeacon()
    }
}

extension ScheduleTVC {
    // The extension contains methods related to reachability
    
    
    func reachabilityStatusChanged(){
        // method to execute every time the ReachStatusChanged notification is received (registered through the observer)
        NSLog(reachabilityStatus)
        
        // reachabilityStatus is a global variable set in AppDelegate.swift
        switch reachabilityStatus {
        case NOACCESS:
            // Move back to the main queue
            dispatch_async(dispatch_get_main_queue()){
                // Display the alert
                let alert = UIAlertController(title: "Accesso Internet Assente", message: "Si pregra di connettersi ad internet", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(okAction)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        default:
            // Well, I have internet access (WIFI or WWAN I don't care)
            if schedules.count == 0 {
                // Get data form Internet because schedules is empty
                runAPI()
            }
        }
    }
    
    func runAPI() {
        // The method updates the time when data was downloaded
        NSLog("runAPI")
        
        setRefreshTimestamp()
        
        // Instantiate the APIManager
        let api = APIManager()
        let urlSchedulesApi = "https://ibeacon.stamplayapp.com/api/cobject/v1/schedule?per_page=all&populate=true&sort=start"
        // Load the data in background and call didLoadData as callback
        api.loadData(urlSchedulesApi, completion: didLoadData)
    }
    
    func didLoadData(schedules: [Schedule], locations: [Location]) {
        // This is the callback of loadData
        NSLog("didLoadData")
        
        self.schedules = schedules
        self.locations = locations
        
        // Create the sections used to render the table
        updateSections(self.schedules)
        
        // Setup the title
        title = ("DMI - MRBS")
        
        // NavigationController is the bottom part of the view
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: LIGHTGREY]
        navigationController?.navigationBar.barTintColor = DARKGREY
        navigationController?.navigationBar.tintColor = LIGHTGREY
        navigationController?.toolbar.barTintColor = DARKGREY
        nextScheduleButton.title = "Prossima Lezione"
        nextScheduleButton.enabled = true
        
        // That's the search
        resultSearchController.searchResultsUpdater = self
        definesPresentationContext = true
        // That's very important: if it is true, during search I cannot do anything and when you click on a cell you come back to the original view
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.searchBar.placeholder = "Cerca..."
        resultSearchController.searchBar.searchBarStyle = UISearchBarStyle.Prominent
        tableView.tableHeaderView = resultSearchController.searchBar
        
        // Hide the loadingLabel
        loadingLabel.hidden = true
        
        // Reloads the rows and sections of the table view.
        tableView.reloadData()
    }
}

extension ScheduleTVC: UISearchResultsUpdating{
    // This extension contains methods related to the search
    
    func filterSearch(searchText: String){
        // The method implements the actual search: it filters elements from schedules depending on the conditions below
        NSLog("filterSearch")
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
            // Recreate the sections depending the search results
            updateSections(filterSearch)
        } else {
            // Restore the sections with not filtered data
            updateSections(self.schedules)
        }
        
        // Reloads the rows and sections of the table view.
        tableView.reloadData()
        
    }
    
    func updateSections(schedules: [Schedule]){
        // The method categorises schedules array by section header
        // This is done through an extension of SequenceType (see Utils.swift)
        self.sectionSchedules = schedules.categorise{sectionHeaderFromDate($0.startingTime)}
        
        // Let's have an array of sorted String: this array is used to manage the section itself
        self.sortedSections = self.sectionSchedules.keys.elements.sort({$0.compare($1) == NSComparisonResult.OrderedAscending })
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        // Called when the search bar becomes the first responder or when the user makes changes inside the search bar.
        // Let's make everything lowercase
        searchController.searchBar.text!.lowercaseString
        // Does the actual search
        filterSearch(searchController.searchBar.text!)
    }
    
    func setRefreshTimestamp(){
        // The method shows when the API were run
        let refreshDate = completeDateFromDate(NSDate())
        refreshControl?.attributedTitle = NSAttributedString(string: "\(refreshDate)")
    }
    
}

extension ScheduleTVC {
    // This extension contains method related the rendering of the tableView.
    // All the methods are implemented because UITableViewController has the following protocols: UITableViewDelegate, UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Asks the data source to return the number of sections in the table view
        NSLog("Sezioni nella tabella: \(self.sectionSchedules.count)")
        if self.schedules.count > 0 {
            // It counts how many sections I have
            return self.sectionSchedules.count
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Tells the data source to return the number of rows in a given section of a table view.
        return self.sectionSchedules[sortedSections[section]]!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Asks the data source for a cell to insert in a particular location of the table view.
        
        // Get the cell from the tableViewController with a specific identifier and reuse the cell to render the data
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ScheduleTableViewCell
        // get the items in this section
        let sectionItems = self.sectionSchedules[sortedSections[indexPath.section]]
        // get the item for the row in this section and assign it to the cell
        cell.schedule = sectionItems![indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Tells the delegate the table view is about to draw a cell for a particular row.
        // In this method the color of the cells will be changed depending on the correspondence type
        
        // get the items in this section
        let sectionItems = self.sectionSchedules[sortedSections[indexPath.section]]
        // get the item for the row in this section
        let schedule = sectionItems![indexPath.row]
        
        // Change the background color depending on the correspondence type
        cell.backgroundColor = correspondenceColor(schedule.correspondence)
        // Set a border around the cell
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = DARKGREY.CGColor
    }
    
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Asks the delegate for a view object to display in the header of the specified section of the table view.
        // In this method the color of the section header will be changed
        
        // Crate a view
        let returnedView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 30))
        // Set the background colo
        returnedView.backgroundColor = LIGHTGREY
        
        // Create a label
        let label = UILabel(frame: CGRectMake(10, 0, tableView.bounds.size.width, 30))
        // Set the text and the color
        label.text = self.sortedSections[section]
        label.textColor = DARKGREY
        
        // Add the label to the view
        returnedView.addSubview(label)
        return returnedView
    }
}

extension ScheduleTVC {
    // This extension contains methods related to the navigation between views
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Notifies the view controller that a segue is about to be performed.
        // In a storyboard-based application, you will often want to do a little preparation before navigation
        NSLog("Segue: \(segue.identifier)")
        
        // This segue is triggered when the user tap on a cell
        if segue.identifier == "scheduleDetail" {
            // Get the path of the cell tapped
            if let indexPath = tableView.indexPathForSelectedRow {
                // get the items in this section
                let sectionItems = self.sectionSchedules[sortedSections[indexPath.section]]
                // get the item for the row in this section
                let schedule = sectionItems![indexPath.row]
                // Instantiate the ScheduleDetailsVC
                let dvc = segue.destinationViewController as! ScheduleDetailsVC
                // Set the schedule in the ScheduleDetailsVC
                dvc.schedule = schedule
            }
        }
        
        // This segue is triggered when the user tap on the nearScheduleButton
        if segue.identifier == "nearScheduleDetail"{
            // Instantiate the ScheduleDetailsVC
            let dvc = segue.destinationViewController as! ScheduleDetailsVC
            // Set the schedule in the ScheduleDetailsVC
            dvc.schedule = self.nearSchedule
        }
    }
    
}

extension ScheduleTVC: CLLocationManagerDelegate {
    // This extension contains methods related to the beacon
    
    func setupBeacon(){
        // Setup the beacon
        let uuidString = UUIDBeaconApp
        let beaconIdentifier = "jaalee"
        let beaconUUID:NSUUID = NSUUID(UUIDString: uuidString)!
        let beaconRegion:CLBeaconRegion = CLBeaconRegion(proximityUUID: beaconUUID, identifier: beaconIdentifier)
        
        // Requests permission to use location services whenever the app is running
        if(locationManager.respondsToSelector(#selector(CLLocationManager.requestAlwaysAuthorization))) {
            locationManager.requestAlwaysAuthorization()
        }
        
        // Set the delegate to itself: all the methods are in this class extension
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = false
        
        // Starts monitoring the specified region: you must call this method once for each region you want to monitor.
        locationManager.startMonitoringForRegion(beaconRegion)
        
        // Starts the delivery of notifications for beacons in the specified region.
        // Once registered, the location manager reports any encountered beacons to its delegate by calling the
        // locationManager:didRangeBeacons:inRegion: method.
        locationManager.startRangingBeaconsInRegion(beaconRegion)
        
        // Starts the generation of updates that report the user’s current location.
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        // Tells the delegate that one or more beacons are in range or change (eg. get closer)
        // I have some beacon around
        if(beacons.count > 0) {
            // Get the nearest beacon
            let nearestBeacon:CLBeacon = beacons[0]
            
            // If the beacon's proximity didn't change from last time or it is uknown, it exits
            if(nearestBeacon.proximity == lastProximity || nearestBeacon.proximity == CLProximity.Unknown) {
                return;
            }
            
            // Get the new proximity
            lastProximity = nearestBeacon.proximity;
            
            // Depending on the proximity it takes the proper action
            switch nearestBeacon.proximity {
            case CLProximity.Far:
                NSLog("Beacon \(nearestBeacon.minor)-\(nearestBeacon.major) è lontano")
                disableNearScheduleButton()
            case CLProximity.Near:
                NSLog("Beacon \(nearestBeacon.minor)-\(nearestBeacon.major) è vicino")
                disableNearScheduleButton()
            case CLProximity.Immediate:
                NSLog("Beacon \(nearestBeacon.minor)-\(nearestBeacon.major) è immediato")
                searchLocationSchedule(nearestBeacon)
            case CLProximity.Unknown:
                return
            }
        } else {
            // There are no beacons around
            if(lastProximity == CLProximity.Unknown) {
                return;
            }
            // So the proximity is unknown
            lastProximity = CLProximity.Unknown
        }
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // Tells the delegate that the user entered the specified region.
        NSLog("Entrato nella regione \(region.identifier)")
        // Starts the delivery of notifications for beacons in the specified region.
        manager.startRangingBeaconsInRegion(region as! CLBeaconRegion)
        // Starts the generation of updates that report the user’s current location.
        manager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        // Tells the delegate that the user left the specified region.
        NSLog("Uscito dalla regione \(region.identifier)")
        // Stops the delivery of notifications for the specified beacon region.
        manager.stopRangingBeaconsInRegion(region as! CLBeaconRegion)
        // Stops the generation of location updates.
        manager.stopUpdatingLocation()
        // It disable the nearCheduleButton too
        disableNearScheduleButton()
    }
    
    func receivedLocalNotification(){
        // This method is executed whenever a nearScheduleDetail notification is posted
        // It is the method registered through the observer
        NSLog("Notifica locale ricevuta")
        performSegueWithIdentifier("nearScheduleDetail", sender: nil)
    }
    
    func searchLocationSchedule(nearestBeacon: CLBeacon) {
        // The method performs the actual search of the location and schedule of the beacon received
        
        // The the baacon minor and major
        let locationMinor = nearestBeacon.minor
        let locationMajor = nearestBeacon.major
        
        // Those are the nearest locations, filtering the Location array
        let nearestLocations = self.locations.filter{$0.minor == locationMinor && $0.major == locationMajor}
        
        // Get the first one matching
        guard let nearestLocation = nearestLocations.first else {return}
        
        // Get schedules happening now and in the nearest location
        let now = NSDate()
        let schedulesLocation = self.schedules.filter{$0.location == nearestLocation && now > $0.startingTime && now < $0.endTime}
        
        // Get the first one matching
        guard let schedule = schedulesLocation.first else {return}
        
        // Depending of the app state, it peforms different actions
        switch UIApplication.sharedApplication().applicationState {
        case .Active:
            //The app is running in the foreground and is receiving events. This is the normal mode for foreground apps.
            // It enables nearSchedukeButton
            NSLog("App attiva")
            enableNearScheduleButton(schedule)
        case .Inactive:
            // The app is running in the foreground but is currently not receiving events. (It may be executing other code though.)
            //An app usually stays in this state only briefly as it transitions to a different state.
            // Send a local notification
            NSLog("App inattiva")
            sendLocalNotification(schedule, nearestLocation: nearestLocation)
        case .Background:
            // The app is in the background and executing code
            // Send a local notification
            NSLog("App in background")
            sendLocalNotification(schedule, nearestLocation: nearestLocation)
        }
    }
    
    func enableNearScheduleButton(schedule: Schedule){
        // The method enable nearScheduleButton
        NSLog("enableNearScheduleButton")
        self.nearSchedule = schedule
        // Set the title of the button
        nearScheduleButton.title = schedule.location.name
        // Enable the buttin
        nearScheduleButton.enabled = true
        // Play a sound notification in app
        // create a sound ID - https://github.com/TUNER88/iOSSystemSoundsLibrary
        let systemSoundID: SystemSoundID = 1113
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        AudioServicesPlaySystemSound(systemSoundID)
    }
    
    func disableNearScheduleButton(){
        // The method disables nearScheduleButton
        NSLog("disableNearScheduleButton")
        nearScheduleButton.title = ""
        nearScheduleButton.enabled = false
        self.nearSchedule = nil
    }
    
    func sendLocalNotification(schedule: Schedule, nearestLocation: Location){
        // This is very important: nearSchedule has now schedule which will be used when the user opens the app from the notification
        NSLog("sendLocalNotification")
        
        self.nearSchedule = schedule
        var notificationMessage = ""
        // Notification message depends on the schedule type
        if schedule.exam == true {
            notificationMessage = "Esame di \"\(schedule.shortDescription)\" in corso in \"\(nearestLocation.name)\""
        } else {
            notificationMessage = "Lezione di \"\(schedule.shortDescription)\" in corso in \"\(nearestLocation.name)\""
        }
        
        // Send out the notification
        sendLocalNotificationWithMessage(notificationMessage, playSound: true)
    }
    
    func sendLocalNotificationWithMessage(message: String!, playSound: Bool) {
        // The method sends a local notification
        NSLog("sendLocalNotificationWithMessage: \(message)")
        
        // Create the notification
        let notification:UILocalNotification = UILocalNotification()
        // Set the message
        notification.alertBody = message
        
        // Set the notification sound
        if(playSound) {
            notification.soundName = UILocalNotificationDefaultSoundName
        }
        // Schedule the notification
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
}