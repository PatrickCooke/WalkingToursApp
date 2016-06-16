//
//  WalkingRouteViewController.swift
//  WalkingToursApp
//
//  Created by Patrick Cooke on 6/16/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

class WalkingRouteViewController: UIViewController {

    let backendless = Backendless.sharedInstance()
    var selectedRoute = Route?()
    //var waypointArray = [Waypoint]()
    var nextStop = 0
    
    @IBOutlet weak var wpStopNum    :UILabel!
    @IBOutlet weak var wpName       :UILabel!
    @IBOutlet weak var wpAddress    :UILabel!
    @IBOutlet weak var wpDescript   :UILabel!
    @IBOutlet weak var wpDirections :UITextView!

    func fillAllInfo() {
        wpStopNum.text = selectedRoute?.routeWaypoints[nextStop].wpStopNum
        wpName.text = selectedRoute?.routeWaypoints[nextStop].wpName
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = selectedRoute?.routeName
        fillAllInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
