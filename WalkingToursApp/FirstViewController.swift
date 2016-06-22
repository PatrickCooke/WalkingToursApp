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
            
            for stop in selectedRoute.routeWaypoints {
                let lat = Double(stop.wpLat!)
                let lon = Double(stop.wpLon!)
                let location = CLLocation(latitude: lat!, longitude: lon!)
                let pin = MKPointAnnotation()
                pin.coordinate = location.coordinate
                cell.routeMapView.addAnnotation(pin)
                cell.routeMapView.showAnnotations(cell.routeMapView.annotations, animated: false)
            }
            
            //How to plot the route line
            
            let pointsArray = ["\(selectedRoute.routeWaypoints[indexPath.row].wpLat), \(selectedRoute.routeWaypoints[indexPath.row].wpLon)"]
            
            let pointsCount = pointsArray.count
            
            var pointsToUse: [CLLocationCoordinate2D] = []
            
            for i in 0...pointsCount-1 {
                let p = CGPointFromString(pointsArray[i] as String)
                pointsToUse += [CLLocationCoordinate2DMake(CLLocationDegrees(p.x), CLLocationDegrees(p.y))]
                
                let myPolyline = MKPolyline(coordinates: &pointsToUse, count: pointsCount)
                
                cell.routeMapView.addOverlay(myPolyline)
                
//                func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
//                    if overlay is MKPolyline {
//                        let lineView = MKPolylineRenderer(overlay: overlay)
//                        lineView.strokeColor = UIColor().BeccaBlue()
//                        
//                        return lineView
//                    }
//                    
//                    return nil
//                }
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
            featuredArray = routeArray.filter {$0.routeFeatured}
            /*
             featuredArray.removeAll()
             var tempArray = [Route]()
             for route in routeArray {
             if route.routeFeatured {
             tempArray.append(route)
             }
             }
             featuredArray = tempArray
             */
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //        refetchAndReload()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
