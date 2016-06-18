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
    
    //MARK: - Interactivty Methods
    
    @IBAction func saveRouteInfo() {
        print("route saved pressed")
        if selectedRoute == nil {
            let newRoute = Route()
            if let routeName = routeTitleTXTField.text {
                newRoute.routeName = routeName
            }
            if let routeDescription = routeDescriptionTXTField.text {
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
        }
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    //MARK: - Life Cycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
