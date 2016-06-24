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
    @IBOutlet weak var routeTitleTXTField       :UITextField!
    @IBOutlet weak var routeDistTXTField        :UITextField!
    @IBOutlet weak var routeDescriptionTXTField :UITextField!
    @IBOutlet weak var waypointTableView        :UITableView!
    @IBOutlet weak var routeActiveSwitch        :UISwitch!
    @IBOutlet weak var messageView              :UIView!
    @IBOutlet weak var messageLabel             :UILabel!
    var stopCount = 0
    var routeFeatured = "0"
    
    //MARK: - Onscreen Alert Methods
    
    func fadeInMessageView(message : String) {
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.messageLabel.text = message
            self.messageView.alpha = 1.0
            }, completion: nil)
    }
    
    func fadeOutMessageView() {
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(3.0 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            //            self.fadeOutView() //maybe don't need a second function?
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.messageView.alpha = 0.0
                }, completion: nil)
        })
    }
    
    //MARK: - Interactivity Methods
    
    @IBAction func deleteButtonPressed(sender: UIBarButtonItem){
        deleteListing()
    }
    
    func reloadTable() {
        waypointTableView.reloadData()
    }
    
    func deleteListing() {
//        print("delete Listing")
        let dataStore = backendless.data.of(Route.ofClass())
        // save object asynchronously
        dataStore.save(
            selectedRoute,
            response: { (result: AnyObject!) -> Void in
                let savedRoute = result as! Route
//                print("Contact has been saved: \(savedRoute.objectId)")
                // now delete the saved object
                dataStore.remove(
                    savedRoute,
                    response: { (result: AnyObject!) -> Void in
//                        print("Route has been deleted: \(result)")
                    },
                    error: { (fault: Fault!) -> Void in
//                        print("Server reported an error (2): \(fault)")
                })
            },
            error: { (fault: Fault!) -> Void in
//                print("Server reported an error (1): \(fault)")
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
    
    //MARK: - Textfield Delegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        switch textField {
        case routeTitleTXTField:
            routeDescriptionTXTField.becomeFirstResponder()
        case routeDescriptionTXTField:
            resignFirstResponder()
        default:
            resignFirstResponder()
        }
        return true
    }
    
    //MARK: - Save Method
    
    @IBAction func saveRouteInfo() {
        fadeInMessageView("Saving...")
        resignFirstRespond()
//        print("route saved pressed")
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
        if let routeCount = selectedRoute?.routeWaypoints.count {
            selectedRoute?.routeWpCount = routeCount
//            print(routeCount)
        }
        selectedRoute?.routeFeatured = routeFeatured
        
        let dataStore = backendless.data.of(Route.ofClass())
        dataStore.save(
            selectedRoute!,
            response: { (result) in
                if let name = self.selectedRoute?.routeName {
                    self.messageLabel.text = "\(name) has been saved"
                }
                self.fadeOutMessageView()
//                print("entry saved")
        }) { (fault) in
            if let error = fault {
                self.messageLabel.text = "Error in saving: \(error)"
            }
            self.fadeOutMessageView()
//            print("server reported error:\(fault)")
        }
    }
    
    
    
    //MARK: - Alert Method
    
    func userAlertView(message : String) {
        
    }
    
    //MARK: - Table Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return waypointArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let selectedWP = waypointArray[indexPath.row]
        let stop = selectedWP.wpStopNum
        if let name = selectedWP.wpName {
            cell.textLabel?.text = "\(stop): \(name)"
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
//                    print("Waypoints has been retrieved")
                    waypointArray.removeAll()
                    for point in (selectedRoute?.routeWaypoints)! {
                        waypointArray.append(point)
                        organizeArray()
                    }
                } else {
//                    print("Server reported an error: \(error)")
                }
            } else {
//                print("Server reported an error: \(error)")
            }
        }
    }
    
    func organizeArray() {
        waypointArray.sortInPlace { $0.wpStopNum < $1.wpStopNum}
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
        waypointTableView.reloadData()
        messageView.alpha = 0.0
        if let selRoute = selectedRoute {
            if let feat = selRoute.routeFeatured{
                routeFeatured = feat
            }
            if let routeName = selRoute.routeName{
                routeTitleTXTField.text = routeName
                self.title = routeName
                
            }
            if let routeDescript = selRoute.routeDiscription {
                routeDescriptionTXTField.text = routeDescript
            }
        } else {
            routeTitleTXTField.text = ""
            routeDescriptionTXTField.text = ""
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
        reloadTable()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadTable), name: "wpdeleted", object: nil)
                guard let route = selectedRoute else {
            return
        }
        if route.routeActive == "1" {
            routeActiveSwitch.on = true
        } else if route.routeActive == "0" {
            routeActiveSwitch.on = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if selectedRoute == nil {
            stopCount = 0
        } else {
            stopCount = (selectedRoute?.routeWaypoints.count)!
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
