//
//  WalkingRouteViewController.swift
//  WalkingToursApp
//
//  Created by Patrick Cooke on 6/16/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

class WalkingRouteViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    
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
    @IBOutlet weak var wpMapView    :MKMapView!
    @IBOutlet weak var wpRouteTable :UITableView!
    
    
    
    var directionsArray: [String]!
    
    //MARK: - Popover methods
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailPopoverSegue" {
            let currentWaypoint = waypointArray[nextStop]
            let destController = segue.destinationViewController as! DetailPopoverViewController
            destController.detail = currentWaypoint.wpDescript
            destController.popoverPresentationController!.delegate = self
        }
    }
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    
    //MARK: - Fill Methods
    
    func fillAllInfo(stop: Int) {
        let currentWaypoint = waypointArray[nextStop]
        let stops = currentWaypoint.wpStopNum
        wpStopNum.text = "Destination #\(stops)"
        wpName.text = currentWaypoint.wpName
        if let address = currentWaypoint.wpAddress {
            let city = currentWaypoint.wpCity ?? ""
            let state = currentWaypoint.wpState ?? ""
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
    }
    
    //MARK: - Interactivity Methods
    
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
        updateDirectionsPushed()
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
        updateDirectionsPushed()
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
        wpMapView.removeOverlays(wpMapView.overlays)
        getDirections(nextStop)
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
                let mapEdgePadding = UIEdgeInsets(top: 60, left: 50, bottom: 20, right: 50)
                self.wpMapView.addOverlay(route.polyline)
                self.wpMapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: mapEdgePadding, animated: true)
            }
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor().BeccaBlue() .colorWithAlphaComponent(0.7)
        return renderer
    }
    
    //MARK: - Table View Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stepsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let routeStep = stepsArray[indexPath.row]
        let distanceInMiles = String(format: "%0.2f mi",routeStep.distance / 1609.344)
        cell.textLabel!.text = "\(routeStep.instructions) - \(distanceInMiles)"
        
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 28.0
    }
    
    
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
