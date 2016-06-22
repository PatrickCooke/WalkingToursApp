//
//  newRouteViewController.swift
//  WalkingToursApp
//
//  Created by Patrick Cooke on 6/18/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

class newRouteViewController: UIViewController {

    let backendless = Backendless.sharedInstance()
    var selectedRoute = Route?()
    @IBOutlet weak var routeTitleTXTField:      UITextField!
    @IBOutlet weak var routeDescriptionTXTField:UITextField!
    @IBOutlet weak var messageView              :UIView!
    @IBOutlet weak var messageLabel             :UILabel!
    
    
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
    
    //MARK: - Interactivty Methods
    
    @IBAction func saveRouteInfo() {
        fadeInMessageView("Saving")
        print("route saved pressed")
        
        let newRoute = Route()
        if let routeName = routeTitleTXTField.text {
            newRoute.routeName = routeName
        }
        if let routeDescription = routeDescriptionTXTField.text {
            newRoute.routeDiscription=routeDescription
        }
        newRoute.routeActive = "0"
        
        let dataStore = backendless.data.of(Route.ofClass())
        dataStore.save(
            newRoute,
            response: { (result) in
                print("entry saved")
                self.messageLabel.text = "Route Saved!"
                self.fadeOutMessageView()
        }) { (fault) in
            print("server reported error:\(fault)")
            self.messageLabel.text = "Error"
            self.fadeOutMessageView()
            
        }
        
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    //MARK: - Textfield Delegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        switch textField {
        case routeTitleTXTField:
            routeDescriptionTXTField.becomeFirstResponder()
        case routeDescriptionTXTField:
            saveRouteInfo()
        default:
            routeTitleTXTField.resignFirstResponder()
            routeDescriptionTXTField.resignFirstResponder()
        }
        return true
    }
    
    //MARK: - Life Cycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageView.alpha = 0.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
