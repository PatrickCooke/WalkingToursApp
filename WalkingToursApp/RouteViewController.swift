//
//  RouteViewController.swift
//  walkaroundbackend
//
//  Created by Patrick Cooke on 6/13/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

class RouteViewController: UIViewController {
    
    let backendless = Backendless.sharedInstance()
    var selectedRoute = Route?()
    var waypointArray = [Waypoint]()
    @IBOutlet weak var routeTitleTXTField:      UITextField!
    @IBOutlet weak var routeDistTXTField:       UITextField!
    @IBOutlet weak var routeDescriptionTXTField: UITextField!
    @IBOutlet weak var waypointTableView:       UITableView!
    @IBOutlet weak var routeActiveSwitch:        UISwitch!
    var stopCount = 0
    
    //MARK: - Interactivity Methods
    
    @IBAction func deleteButtonPressed(sender: UIBarButtonItem){
        //deleteListing()
    }
    
    func deleteListing() {
        print("delete Listing")
        let dataStore = backendless.data.of(Route.ofClass())
        // save object asynchronously
        dataStore.save(
            selectedRoute,
            response: { (result: AnyObject!) -> Void in
                let savedRoute = result as! Route
                print("Contact has been saved: \(savedRoute.objectId)")
                // now delete the saved object
                dataStore.remove(
                    savedRoute,
                    response: { (result: AnyObject!) -> Void in
                        print("Route has been deleted: \(result)")
                    },
                    error: { (fault: Fault!) -> Void in
                        print("Server reported an error (2): \(fault)")
                })
            },
            error: { (fault: Fault!) -> Void in
                print("Server reported an error (1): \(fault)")
        })
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func resignAll(selector: UIGestureRecognizer){
        resignFirstRespond()
    }
    
    func resignFirstRespond() {
        routeTitleTXTField.resignFirstResponder()
        routeDescriptionTXTField.resignFirstResponder()
    }
    
    @IBAction func saveRouteInfo() {
        //resignFirstRespond()
        print("route saved pressed")
        if selectedRoute == nil {
            selectedRoute = Route()
        }
        if let routeName = routeTitleTXTField.text {
            selectedRoute!.routeName = routeName
        }
        if let routeDescription = routeDescriptionTXTField.text {
            selectedRoute!.routeDiscription = routeDescription
        }
        if routeActiveSwitch.on {
            selectedRoute!.routeActive = "1"
        } else {
            selectedRoute!.routeActive = "0"
        }
        let dataStore = backendless.data.of(Route.ofClass())
        dataStore.save(
            selectedRoute!,
            response: { (result) in
                print("entry saved")
        }) { (fault) in
            print("server reported error:\(fault)")
        }
    }
    
    //MARK: - Table Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return waypointArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let selectedWP = waypointArray[indexPath.row]
        cell.textLabel?.text = selectedWP.wpName
        if let stop = selectedWP.wpStopNum {
            cell.detailTextLabel?.text = "Stop: \(stop)"
        }
        return cell
    }
    
    //MARK: - Fetch Methods
    
    private func fetchData() {
        
        if selectedRoute == nil {
            
        } else {
            
            var error: Fault?
            if error == nil {
                
                //add sorting stuff
                
                selectedRoute = backendless.data.of(Route.ofClass()).load(selectedRoute, relations: ["routeWaypoints"], fault: &error) as? Route
                if error == nil {
                    print("Waypoints has been retrieved")
                    waypointArray.removeAll()
                    for point in (selectedRoute?.routeWaypoints)! {
                        waypointArray.append(point)
                    }
                } else {
                    print("Server reported an error: \(error)")
                }
            } else {
                print("Server reported an error: \(error)")
            }
        }
    }
    
    //MARK: - Segue Methods
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let destController = segue.destinationViewController as! WayPointViewController
        destController.sourceRoute = selectedRoute!
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        
        if segue.identifier == "seeSelectedWP" {
            let indexPath = waypointTableView.indexPathForSelectedRow!
            let selectedWP = waypointArray[indexPath.row]
            destController.selectedWP = selectedWP
            waypointTableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else if segue.identifier == "addNewWP" {
            destController.selectedWP = nil
        }
        
    }
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let selRoute = selectedRoute {
            if let routeName = selRoute.routeName{
                routeTitleTXTField.text = routeName
                self.title = routeName
                
            }
            if let routeDescript = selRoute.routeDiscription {
                routeDescriptionTXTField.text = routeDescript
            }
        } else {
            routeTitleTXTField.text = ""
            //            routeDistTXTField.text = "0"
            routeDescriptionTXTField.text = ""
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        fetchData()
        waypointTableView.reloadData()
        if selectedRoute == nil {
            stopCount = 0
        } else {
            stopCount = (selectedRoute?.routeWaypoints.count)!
        }
        //print("stops: \(stopCount)")
        guard let route = selectedRoute else {
            return
        }
        if route.routeActive == "1" {
            routeActiveSwitch.on = true
            print("active")
        } else if route.routeActive == "0" {
            routeActiveSwitch.on = false
            print("not active")
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "reload", object: nil))
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
