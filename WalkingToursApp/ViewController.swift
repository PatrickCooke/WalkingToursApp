//
//  ViewController.swift
//  WalkingToursApp
//
//  Created by Patrick Cooke on 6/14/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var backendless = Backendless.sharedInstance()
        var routeArray = [Route]()
    
        @IBOutlet private weak var RouteTable  :UITableView!
    
        ////MARK: - Table Methods
    
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return routeArray.count
        }
    
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            let selectedRoute = routeArray[indexPath.row]
            cell.textLabel!.text = selectedRoute.routeName
            cell.detailTextLabel!.text = "\(selectedRoute.routeDistance!) mi"
    
            return cell
        }
    
        //MARK: - Segue Methods
    
        override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            let destController = segue.destinationViewController as! RouteViewController
            if segue.identifier == "seeSelectedRoute" {
                let indexPath = RouteTable.indexPathForSelectedRow!
                let selectedRoute = routeArray[indexPath.row]
                destController.selectedRoute = selectedRoute
                let backItem = UIBarButtonItem()
                backItem.title = "Menu"
                navigationItem.backBarButtonItem = backItem
                RouteTable.deselectRowAtIndexPath(indexPath, animated: true)
            } else if segue.identifier == "addNewRoute" {
                destController.selectedRoute = nil
                let backItem = UIBarButtonItem()
                backItem.title = "Menu"
                navigationItem.backBarButtonItem = backItem
            }
    
        }
    
    //MARK: - Fetch Methods
    
        private func fetchData() {
            let dataQuery = BackendlessDataQuery()
            var error: Fault?
            let result = backendless.data.of(Route.ofClass()).find(dataQuery, fault: &error)
            if error == nil {
                routeArray = result.getCurrentPage() as! [Route]
                print("requests: \(routeArray.count)")
            } else {
                print("server error \(error)")
                routeArray = [Route]()
            }
        }
    
    //MARK: - Reoccuring Functions
    
        func refetchAndReload(){
            fetchData()
            RouteTable.reloadData()
        }
    
    
    
    ////MARK: - Temp Add Records
    
    func saveNewRoute() {
        let route = Route()
        route.routeName = "D-town Brew Tours  2016"
        route.routeDiscription = "Brews in the D 2016"
        route.routeDistance = "4"
        
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
    
    ////MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //saveNewRoute()
        refetchAndReload()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refetchAndReload()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}

