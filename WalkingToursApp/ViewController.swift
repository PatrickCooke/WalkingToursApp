//
//  ViewController.swift
//  WalkingToursApp
//
//  Created by Patrick Cooke on 6/14/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var backendless  = Backendless.sharedInstance()
    var loginManager = LoginManager.sharedInstance
    var routeArray   = [Route]()
    
    @IBOutlet private weak var RouteTable  :UITableView!
    
    //MARK: - Table Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeArray.count 
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let selectedRoute = routeArray[indexPath.row]
        cell.textLabel!.text = selectedRoute.routeName
        if selectedRoute.routeActive! .containsString("1") {
            cell.detailTextLabel!.text = "Public: \(selectedRoute.routeWaypoints.count) stops"
        } else {
            cell.detailTextLabel!.text = "Private: \(selectedRoute.routeWaypoints.count) stops"
        }
        
        return cell
    }
    
    //MARK: - Segue Methods
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "seeSelectedRoute" {
            let destController = segue.destinationViewController as! RouteViewController
            let indexPath = RouteTable.indexPathForSelectedRow!
            let selectedRoute = routeArray[indexPath.row]
            destController.selectedRoute = selectedRoute
            let backItem = UIBarButtonItem()
            backItem.title = "Menu"
            navigationItem.backBarButtonItem = backItem
            RouteTable.deselectRowAtIndexPath(indexPath, animated: true)
        } else if segue.identifier == "addNewRoute" {
            let destController = segue.destinationViewController as! newRouteViewController
            destController.selectedRoute = nil
            let backItem = UIBarButtonItem()
            backItem.title = "Menu"
            navigationItem.backBarButtonItem = backItem
        }
    }
    
    //MARK: - Fetch Methods
    
    private func fetchData() {
        let dataQuery = BackendlessDataQuery()
        let whereClause = "ownerId = '\(loginManager.currentuser.objectId)'"
        dataQuery.whereClause = whereClause
        
        var error: Fault?
        let result = backendless.data.of(Route.ofClass()).find(dataQuery, fault: &error)
        if error == nil {
            routeArray = result.getCurrentPage() as! [Route]
        } else {
            routeArray = [Route]()
        }
    }
    
    func reloadTable() {
        RouteTable.reloadData()
    }
    
    //MARK: - Reoccuring Functions
    
    func refetchAndReload(){
        fetchData()
        RouteTable.reloadData()
        
    }
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refetchAndReload()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadTable), name: "routeDeleted", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refetchAndReload()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}

