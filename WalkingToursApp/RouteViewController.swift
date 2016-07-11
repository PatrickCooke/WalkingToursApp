//
//  RouteViewController.swift
//  walkaroundbackend
//
//  Created by Patrick Cooke on 6/13/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

class RouteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let backendless   = Backendless.sharedInstance()
    var selectedRoute = Route?()
    var waypointArray = [Waypoint]()
    @IBOutlet weak var routeTitleTXTField       :UITextField!
    @IBOutlet weak var routeDescriptionTXTField :UITextField!
    @IBOutlet weak var waypointTableView        :UITableView!
    @IBOutlet weak var routeActiveSwitch        :UISwitch!
    @IBOutlet weak var messageView              :UIView!
    @IBOutlet weak var messageLabel             :UILabel!
    @IBOutlet weak var charRemainLabel          :UILabel!
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
        //        print("reloading")
        waypointTableView.reloadData()
    }
    
    func deleteListing() {
        let dataStore = backendless.data.of(Route.ofClass())
        dataStore.save(
            selectedRoute,
            response: { (result: AnyObject!) -> Void in
                let savedRoute = result as! Route
                dataStore.remove(
                    savedRoute,
                    response: { (result: AnyObject!) -> Void in
                    },
                    error: { (fault: Fault!) -> Void in
                })
            },
            error: { (fault: Fault!) -> Void in
        })
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "routeDeleted", object: nil))
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
        }) { (fault) in
            if let error = fault {
                self.messageLabel.text = "Error in saving: \(error)"
            }
            self.fadeOutMessageView()
        }
    }
    
    
    
    //MARK: - Alert Method
    
    func userAlertView(message : String) {
        
    }
    
    //MARK: - Table Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
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
    
    //MARK: - WPTableview Sort Method
    
    @IBAction func startEditing(sender: UIButton) {
        waypointTableView.editing = !waypointTableView.editing
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        //        print("From \(sourceIndexPath.row) To \(destinationIndexPath.row) ")
        let itemMoved = waypointArray[sourceIndexPath.row]
        waypointArray.removeAtIndex(sourceIndexPath.row)
        waypointArray.insert(itemMoved, atIndex: destinationIndexPath.row)
        for (index, waypoint) in waypointArray.enumerate() {
            waypoint.wpStopNum = index + 1
            thcSaveWaypoint(waypoint)
            
        }
        reloadTable()
    }
    
    func thcSaveWaypoint(waypoint: Waypoint) {
        let dataStore = Backendless.sharedInstance().data.of(Waypoint.ofClass())
        dataStore.save(
            waypoint,
            response: { (result: AnyObject!) -> Void in
                let updatedRoute = result as! Waypoint
                if let saveMessage = waypoint.wpName {
                    //                    print("\(saveMessage) has been saved")
                    self.messageLabel.text = "\(saveMessage) has been saved"
                }
                self.fadeOutMessageView()
                self.messageLabel.text = "\(updatedRoute.wpName)"
            },
            error: { (fault: Fault!) -> Void in
                if let errorMessage = waypoint.wpName {
                    self.messageLabel.text = "There has been an error, \(errorMessage) has not been saved"
                    self.fadeOutMessageView()
                }
        })
    }
    
    //MARK: - Fetch Methods
    
    @objc private func refetchTableData() {
        
        if selectedRoute == nil {
            
        } else {
            var error: Fault?
            if error == nil {
                selectedRoute = backendless.data.of(Route.ofClass()).load(selectedRoute, relations: ["routeWaypoints"], fault: &error) as? Route
                if error == nil {
                    waypointArray.removeAll()
                    for point in (selectedRoute?.routeWaypoints)! {
                        waypointArray.append(point)
                        organizeArray()
                    }
                    reloadTable()
                } else {
                }
            } else {
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
    
    //MARK: - TextField Limit Methods
    
    @IBAction func checkMaxLength() {
        if (routeTitleTXTField.text?.characters.count > 500) {
            routeTitleTXTField.deleteBackward()
        }
        if (routeDescriptionTXTField.text?.characters.count > 500) {
            routeDescriptionTXTField.deleteBackward()
        }
    }
    
    @IBAction func charRemaining() {
        let descript = routeDescriptionTXTField.text
        let charUsed = 500 - descript!.characters.count
        charRemainLabel.text = "Characters Remaining: \(charUsed)"
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
            charRemaining()
        } else {
            routeTitleTXTField.text = ""
            routeDescriptionTXTField.text = ""
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refetchTableData), name: "wpdeleted", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refetchTableData), name: "wpsaved", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refetchTableData), name: "routeCreated", object: nil)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refetchTableData()
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
