//
//  WalkingRouteViewController.swift
//  WalkingToursApp
//
//  Created by Patrick Cooke on 6/16/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

class WalkingRouteViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let locManager = LocationManager.sharedInstance
    let backendless = Backendless.sharedInstance()
    var selectedRoute :Route!
    var waypointArray = [Waypoint]()
    var nextStop = 0
    var locationManager = CLLocationManager()
    var stepsArray = [MKRouteStep]()
    
    
    @IBOutlet weak var wpStopNum    :UILabel!
    @IBOutlet weak var wpName       :UILabel!
    @IBOutlet weak var wpAddress    :UILabel!
    @IBOutlet weak var wpDescript   :UILabel!
    @IBOutlet weak var wpDirections :UITextView!
    @IBOutlet weak var wpMapView    :MKMapView!
    @IBOutlet weak var wpDistTime   :UILabel!
    @IBOutlet weak var wpRouteTable :UITableView!
    @IBOutlet weak var wpDirectionsButton :UIButton!
    
    
    var directionsArray: [String]!
    
    
    //MARK: - Fill Methods
    
    func fillAllInfo(stop: Int) {
        let currentWaypoint = waypointArray[nextStop]
        if let stops = currentWaypoint.wpStopNum {
            wpStopNum.text = "Destination #\(stops)"
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
        wpMapView.removeOverlays(wpMapView.overlays)
        if nextStop < (waypointArray.count - 1) {
            nextStop += 1
        } else {
            nextStop = 0
        }
        fillAllInfo(nextStop)
        stepsArray.removeAll()
        wpRouteTable.reloadData()
    }
    
    @IBAction func previousButtonPressed(sender: UIButton) {
        wpMapView.removeAnnotations(wpMapView.annotations)
        wpMapView.removeOverlays(wpMapView.overlays)
        if nextStop > 0  {
            nextStop -= 1
        } else {
            nextStop = (waypointArray.count - 1)
        }
        fillAllInfo(nextStop)
        stepsArray.removeAll()
        wpRouteTable.reloadData()
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
    
    @IBAction func updateDirectionsPushed() {
        getDirections(nextStop)
        //wpRouteTable.reloadData()
    }
    
    func getDirections(stop: Int ){
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
        let userLoc = wpMapView.userLocation.location
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (userLoc?.coordinate.latitude)!, longitude: (userLoc?.coordinate.longitude)!), addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latDouble, longitude: lonDouble), addressDictionary: nil))
        request.requestsAlternateRoutes = false
        request.transportType = .Walking
        
        let directions = MKDirections(request: request)
        
        directions.calculateDirectionsWithCompletionHandler { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            self.stepsArray = unwrappedResponse.routes.first!.steps
            self.wpRouteTable.reloadData()
            
            for route in unwrappedResponse.routes {
                self.wpMapView.addOverlay(route.polyline)
                self.wpMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                //let totalRouteDistance = String(format: "Total Distance: %0.2f",route.distance / 1609.344)
                //let totalRouteTime = "Expected Time: \(route.expectedTravelTime)"
                //print("\(totalRouteDistance),\(totalRouteTime)")
            }
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor().BeccaBlue()
        return renderer
    }
    
    //MARK: - Table View Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stepsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        let routeStep = stepsArray[indexPath.row]
        cell.textLabel!.text = routeStep.instructions
        let distanceInMiles = String(format: "%0.2f mi",routeStep.distance / 1609.344)
        cell.detailTextLabel!.text = distanceInMiles
        
        return cell
    }
    
    
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = selectedRoute.routeName
        waypointArray = selectedRoute.routeWaypoints
        waypointArray.sortInPlace { $0.wpStopNum < $1.wpStopNum }
        fillAllInfo(nextStop)
        
        /*
        if location isn't available {
            wpDirectionsButton.enabled = false
        }
        */
        locManager.setupLocationMonitoring()
        wpMapView.showsUserLocation=true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
