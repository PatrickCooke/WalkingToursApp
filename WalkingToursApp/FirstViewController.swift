//
//  FirstViewController.swift
//  WalkingToursApp
//
//  Created by Patrick Cooke on 6/16/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var locManager = LocationManager.sharedInstance
    var backendless = Backendless.sharedInstance()
    var routeArray = [Route]()
    var featuredArray = [Route]()
    var locationManager = CLLocationManager()
    @IBOutlet weak var featuredSegCtrl:   UISegmentedControl!
    
    @IBOutlet private weak var RouteTable  :UITableView!
    
    ////MARK: - Table Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch featuredSegCtrl.selectedSegmentIndex {
        case 0:
            return featuredArray.count
        case 1:
            return routeArray.count
        default:
            return routeArray.count
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch featuredSegCtrl.selectedSegmentIndex {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("fcell", forIndexPath: indexPath) as! FeaturedCellTableViewCell
            let selectedRoute = featuredArray[indexPath.row]
            cell.routeNameLabel.text = selectedRoute.routeName
            cell.routeDescript.text = selectedRoute.routeDiscription
            cell.routeStartPoint.text = selectedRoute.routeWaypoints[indexPath.row].wpCity! + ", " + selectedRoute.routeWaypoints[indexPath.row].wpState!
            //How to plot the map points
            
            
//            var tempCoordsArray = [CLLocationCoordinate2D]()
            
            for stop in selectedRoute.routeWaypoints {
                let lat = Double(stop.wpLat!)
                let lon = Double(stop.wpLon!)
                let location = CLLocation(latitude: lat!, longitude: lon!)
                let pin = MKPointAnnotation()
                pin.coordinate = location.coordinate
                //cell.routeMapView.addAnnotation(pin)
            }
            //cell.routeMapView.showAnnotations(cell.routeMapView.annotations, animated: false)
            
            //How to plot the route line
            
            
            for (index, stop) in selectedRoute.routeWaypoints.enumerate() {
                let sourceLat = Double(stop.wpLat!)
                let sourceLon = Double(stop.wpLon!)
                let source = CLLocationCoordinate2D(latitude: sourceLat!, longitude: sourceLon!)
                
                var nextStop = index + 1
                if index == selectedRoute.routeWaypoints.count - 1 {
                    nextStop = 0
                }
                let destLat = Double(selectedRoute.routeWaypoints[nextStop].wpLat!)
                let destLon = Double(selectedRoute.routeWaypoints[nextStop].wpLon!)
                let dest = CLLocationCoordinate2D(latitude: destLat!, longitude: destLon!)
                
                
                let request = MKDirectionsRequest()
                
                request.source = MKMapItem(placemark: MKPlacemark(coordinate: source, addressDictionary: nil))
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: dest, addressDictionary: nil))
                request.requestsAlternateRoutes = false
                request.transportType = .Walking
                
                let directions = MKDirections(request: request)
                
                directions.calculateDirectionsWithCompletionHandler({ (response, error) in
                    guard let unwrappedResponse = response else { return }
                    for route in unwrappedResponse.routes {
                        print("Add polyline")
                        cell.routeMapView.addOverlay(route.polyline)

                    }
                })
                
            }

            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            let selectedRoute = routeArray[indexPath.row]
            cell.textLabel!.text = selectedRoute.routeName
            cell.detailTextLabel!.text = "\(selectedRoute.routeWaypoints.count) stops"
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            let selectedRoute = routeArray[indexPath.row]
            cell.textLabel!.text = selectedRoute.routeName
            cell.detailTextLabel!.text = "\(selectedRoute.routeWaypoints.count) stops"
            
            return cell
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor().BeccaBlue() .colorWithAlphaComponent(0.7)
        return renderer
    }

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch featuredSegCtrl.selectedSegmentIndex {
        case 0:
            return 265
        default:
            return 44
        }
    }


    
    //MARK: - Segue Methods
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "seeFeaturedRoute" {
            let destController = segue.destinationViewController as! WalkingRouteViewController
            let indexPath = RouteTable.indexPathForSelectedRow!
            let selectedRoute = featuredArray[indexPath.row]
            destController.selectedRoute = selectedRoute
            let backItem = UIBarButtonItem()
            backItem.title = "Done"
            navigationItem.backBarButtonItem = backItem
            RouteTable.deselectRowAtIndexPath(indexPath, animated: true)
        } else if segue.identifier == "seeSelectedRoute" {
            let destController = segue.destinationViewController as! WalkingRouteViewController
            let indexPath = RouteTable.indexPathForSelectedRow!
            let selectedRoute = routeArray[indexPath.row]
            destController.selectedRoute = selectedRoute
            let backItem = UIBarButtonItem()
            backItem.title = "Done"
            navigationItem.backBarButtonItem = backItem
            RouteTable.deselectRowAtIndexPath(indexPath, animated: true)
        } else if segue.identifier == "admin" {
            //let destController = segue.destinationViewController as! LoginViewController
            let backItem = UIBarButtonItem()
            backItem.title = "Menu"
            navigationItem.backBarButtonItem = backItem
        }
        
    }
    
    //MARK: - Fetch Methods
    
    private func fetchData() {
        
        let dataQuery = BackendlessDataQuery()
        
        let whereClause = "routeActive = '1' AND routeWpCount > 0"
        dataQuery.whereClause = whereClause
        
        let queryOptions = QueryOptions()
        queryOptions.sortBy = ["routeName"]
        dataQuery.queryOptions = queryOptions
        
        var error: Fault?
        let result = backendless.data.of(Route.ofClass()).find(dataQuery, fault: &error)
        if error == nil {
            routeArray = result.getCurrentPage() as! [Route]
            //featuredArray = routeArray.filter {$0.routeFeatured}
            
            featuredArray.removeAll()
            var tempArray = [Route]()
            for route in routeArray {
                if route.routeFeatured == "1" {
                    tempArray.append(route)
                }
            }
            featuredArray = tempArray
 
            //rint("requests: \(routeArray.count)")
        } else {
            print("server error \(error)")
            routeArray = [Route]()
        }
        
    }
    
    //MARK: - Reoccuring Functions
    
    func refetchAndReload(){
        fetchData()
        RouteTable.reloadData()
        locManager.setupLocationMonitoring()
    }
    
    @IBAction func switchTableContents() {
        RouteTable.reloadData()
    }
    
    
    //MARK: - Life Cycle Method
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refetchAndReload()
        print(featuredArray.count)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        RouteTable.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
