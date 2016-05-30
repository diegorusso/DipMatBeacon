//
//  ViewController.swift
//  DipMatBeacon
//
//  Created by Diego Russo on 28/05/2016.
//  Copyright © 2016 Diego Russo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Gobal Variables - cannot be in the extension
    var schedules = [Schedule]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        runAPI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController{
    
    func didLoadData(schedules: [Schedule]) {
        
        self.schedules = schedules
        print(self.schedules)
        
    }
    
    func runAPI() {
        // Call API
        let api = APIManager()
        let urlApi = "https://ibeacon.stamplayapp.com/api/cobject/v1/schedule?per_page=all&populate=true&sort=start"
        api.loadData(urlApi, completion: didLoadData)
    }

}

