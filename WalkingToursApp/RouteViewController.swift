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
    @IBOutlet weak var routeDescriptionTXTView: UITextView!
    @IBOutlet weak var waypointTableView:       UITableView!
    
    //MARK: - Interactivity Methods
    
    @IBAction func deleteButtonPressed(sender: UIBarButtonItem){
        
        let alertView = UIAlertController(title: "Sorry, you can't directly delete this Routes", message: "To protect the routes created by other, you'll have to email me to delete this route for you.", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    func deleteListing() {
        print("delete Listing")
        //        self.navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func resignAll(selector: UIGestureRecognizer){
        resignFirstRespond()
    }
    
    func resignFirstRespond() {
        routeDistTXTField.resignFirstResponder()
        routeTitleTXTField.resignFirstResponder()
        routeDescriptionTXTView.resignFirstResponder()
    }
    
    @IBAction func saveRouteInfo(sender: UIBarButtonItem) {
        resignFirstRespond()
        print("route saved pressed")
        if selectedRoute == nil {
            let newRoute = Route()
            if let routeName = routeTitleTXTField.text {
                newRoute.routeName = routeName
            }
            if let routeDistance = routeDistTXTField.text {
                newRoute.routeDistance = routeDistance
            }
            if let routeDescription = routeDescriptionTXTView.text {
                newRoute.routeDiscription=routeDescription
            }
            let dataStore = backendless.data.of(Route.ofClass())
            dataStore.save(
                newRoute,
                response: { (result) in
                    print("entry saved")
            }) { (fault) in
                print("server reported error:\(fault)")
            }
        } else {
            let dataStore = Backendless.sharedInstance().data.of(Route.ofClass())
            selectedRoute!.routeName = routeTitleTXTField.text
            selectedRoute!.routeDiscription = routeDescriptionTXTView.text
            selectedRoute!.routeDistance = routeDistTXTField.text
            dataStore.save(
                selectedRoute,
                response: { (result: AnyObject!) -> Void in
                    let updatedRoute = result as! Route
                    print("Contact has been updated: \(updatedRoute.objectId)")
                },
                error: { (fault: Fault!) -> Void in
                    print("Server reported an error (2): \(fault)")
            })
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
        cell.detailTextLabel?.text = selectedWP.wpAddress
        
        return cell
    }
    
    //MARK: - Fetch Methods
    
    private func fetchData() {
        
        var error: Fault?
        if error == nil {
            selectedRoute = backendless.data.of(Route.ofClass()).load(selectedRoute, relations: ["routeWaypoints"], fault: &error) as? Route
            if error == nil {
                print("Waypoints has been retrieved)")
                waypointArray.removeAll()
                for point in (selectedRoute?.routeWaypoints)! {
                    print("\(point.wpStopNum) - \(point.wpName), \(point.wpAddress), \(point.wpDescript)")
                    waypointArray.append(point)
                    print("Stops count: \(waypointArray.count)")
                }
            }
            else {
                print("Server reported an error: \(error)")
            }
        }
        else {
            print("Server reported an error: \(error)")
        }
    }
    
    //MARK: - Segue Methods
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destController = segue.destinationViewController as! WayPointViewController
        if segue.identifier == "seeSelectedWP" {
            let indexPath = waypointTableView.indexPathForSelectedRow!
            let selectedWP = waypointArray[indexPath.row]
            destController.selectedWP = selectedWP
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
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
            if let routeDist = selRoute.routeDistance {
                routeDistTXTField.text = routeDist
            }
            if let routeDescript = selRoute.routeDiscription {
                routeDescriptionTXTView.text = routeDescript
            }
        } else {
            routeTitleTXTField.text = ""
            routeDistTXTField.text = "0"
            routeDescriptionTXTView.text = ""
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        fetchData()
        waypointTableView.reloadData()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "reload", object: nil))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
