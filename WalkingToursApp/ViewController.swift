//
//  ViewController.swift
//  WalkingToursApp
//
//  Created by Patrick Cooke on 6/14/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    
    
    //MARK: - Temp Add Records
    var backendless = Backendless.sharedInstance()
    
    func saveNewRoute() {
        let route = Route()
        route.routeName = "IronPints Spring 2016"
        route.routeDiscription = "Stops made by Iron Yard Students in the spring of 2016"
        route.routeDistance = 2.5
        
        let dataStore = backendless.data.of(Route.ofClass())
        // save object asynchronously
        dataStore.save(
            route,
            response: { (result: AnyObject!) -> Void in
                let obj = result as! Route
                print("Contact has been saved: \(obj.objectId)")
            },
            error: { (fault: Fault!) -> Void in
                print("fServer reported an error: \(fault)")
        })
    }
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveNewRoute()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

