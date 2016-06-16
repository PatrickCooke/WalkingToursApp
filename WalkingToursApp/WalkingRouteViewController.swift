//
//  WalkingRouteViewController.swift
//  WalkingToursApp
//
//  Created by Patrick Cooke on 6/16/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

class WalkingRouteViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let locManager = LocationManager.sharedInstance
    let backendless = Backendless.sharedInstance()
    var selectedRoute :Route!
    var waypointArray = [Waypoint]()
    var nextStop = 0
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var wpStopNum    :UILabel!
    @IBOutlet weak var wpName       :UILabel!
    @IBOutlet weak var wpAddress    :UILabel!
    @IBOutlet weak var wpDescript   :UILabel!
    @IBOutlet weak var wpDirections :UITextView!
    @IBOutlet weak var wpMapView    :MKMapView!
    
    //MARK: - Fill Methods
    
    func fillAllInfo(stop: Int) {
        let currentWaypoint = waypointArray[nextStop]
        if let stops = currentWaypoint.wpStopNum {
        wpStopNum.text = "Stop #\(stops)"
        }
        wpName.text = currentWaypoint.wpName
        if let address = currentWaypoint.wpAddress {
            let city = currentWaypoint.wpCity ?? ""
            let state = currentWaypoint.wpCity ?? ""
            wpAddress.text = "\(address), \(city) \(state)"
        } else {
            wpAddress.text = ""
        }
        wpDescript.text = currentWaypoint.wpDescript
        plotWayPoint(stop)
//        if stop < waypointArray.count - 1 {
//            plotWayPoint(stop + 1)
//        } else {
//            plotWayPoint(0)
//        }
    }
    
    func clearAllInfo() {
        wpStopNum.text = ""
        wpName.text = ""
        wpAddress.text = ""
        wpDescript.text = ""
        wpDirections.text = ""
        
    }
    
    @IBAction func nextButtonPressed(sender: UIButton) {
        wpMapView.removeAnnotations(wpMapView.annotations)
        if nextStop < (waypointArray.count - 1) {
            nextStop += 1
        } else {
            nextStop = 0
        }
        fillAllInfo(nextStop)
    }
    
    @IBAction func previousButtonPressed(sender: UIButton) {
        wpMapView.removeAnnotations(wpMapView.annotations)
        if nextStop > 0  {
            nextStop -= 1
        } else {
            nextStop = (waypointArray.count - 1)
        }
        fillAllInfo(nextStop)
    }
    
    //MARK: - Mapping Methods
    
    func plotWayPoint(stop: Int ) {
        let currentWaypoint = waypointArray[stop]
        guard let lat = currentWaypoint.wpLat else {
            return
        }
        guard let lon = currentWaypoint.wpLon else {
            return
        }
        guard let latDouble = Double(lat) else {
            return
        }
        guard let lonDouble = Double(lon) else {
            return
        }
        let pin = MKPointAnnotation()
        pin.coordinate = CLLocationCoordinate2D(latitude: latDouble, longitude: lonDouble)
        wpMapView.addAnnotation(pin)
        
        wpMapView.showAnnotations(wpMapView.annotations, animated: true)
    }
    
//    func getDirections(stop: Int ){
//        let currentWaypoint = waypointArray[stop]
//        guard let lat = currentWaypoint.wpLat else {
//            return
//        }
//        guard let lon = currentWaypoint.wpLon else {
//            return
//        }
//        guard let latDouble = Double(lat) else {
//            return
//        }
//        guard let lonDouble = Double(lon) else {
//            return
//        }
//        let userLoc = wpMapView.userLocation.location
//        let endLoc = CLLocation(latitude: latDouble, longitude: lonDouble)
//        let directions = MKDirectionsRequest.
//        
//    }


    //MARK: - Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = selectedRoute.routeName
        waypointArray = selectedRoute.routeWaypoints
        waypointArray.sortInPlace { $0.wpStopNum < $1.wpStopNum }
        fillAllInfo(nextStop)
        
        locManager.setupLocationMonitoring()
        wpMapView.showsUserLocation=true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
