//
//  FirstViewController.swift
//  WalkingToursApp
//
//  Created by Patrick Cooke on 6/16/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, CLLocationManagerDelegate {
    
    var locManager = LocationManager.sharedInstance
    var backendless = Backendless.sharedInstance()
    var routeArray = [Route]()
    var locationManager = CLLocationManager()
    
    @IBOutlet private weak var RouteTable  :UITableView!
    
    ////MARK: - Table Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let selectedRoute = routeArray[indexPath.row]
        cell.textLabel!.text = selectedRoute.routeName
        cell.detailTextLabel!.text = "\(selectedRoute.routeWaypoints.count) stops"
        
        return cell
    }
    
    //MARK: - Segue Methods
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        if segue.identifier == "seeSelectedRoute" {
            let destController = segue.destinationViewController as! WalkingRouteViewController
            let indexPath = RouteTable.indexPathForSelectedRow!
            let selectedRoute = routeArray[indexPath.row]
            destController.selectedRoute = selectedRoute
            let backItem = UIBarButtonItem()
            backItem.title = "Done"
            navigationItem.backBarButtonItem = backItem
            RouteTable.deselectRowAtIndexPath(indexPath, animated: true)
        } else if segue.identifier == "admin" {
            //let destController = segue.destinationViewController as! LoginViewController
            let backItem = UIBarButtonItem()
            backItem.title = "Menu"
            navigationItem.backBarButtonItem = backItem
        }
        
    }
    
    //MARK: - Fetch Methods
    
    private func fetchData() {
        
        let dataQuery = BackendlessDataQuery()
        
        let queryOptions = QueryOptions()
        queryOptions.sortBy = ["routeName"]
        dataQuery.queryOptions = queryOptions
        
        var error: Fault?
        let result = backendless.data.of(Route.ofClass()).find(dataQuery, fault: &error)
        if error == nil {
            routeArray = result.getCurrentPage() as! [Route]
            //rint("requests: \(routeArray.count)")
        } else {
            print("server error \(error)")
            routeArray = [Route]()
        }

    }

    //MARK: - Reoccuring Functions
    
    func refetchAndReload(){
        fetchData()
        RouteTable.reloadData()
        locManager.setupLocationMonitoring()
    }
    
    
    //MARK: - Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
