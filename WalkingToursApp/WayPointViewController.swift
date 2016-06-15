//
//  WayPointViewController.swift
//  walkaroundbackend
//
//  Created by Patrick Cooke on 6/13/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

class WayPointViewController: UIViewController {
    
    let backendless = Backendless.sharedInstance()
    var selectedWP = Waypoint?()
    var sourceRoute :Route!
    @IBOutlet weak var wpNameTxtField           :UITextField!
    @IBOutlet weak var wpaddressTxtField        :UITextField!
    @IBOutlet weak var wpCityTxtField           :UITextField!
    @IBOutlet weak var wpStateTxtField          :UITextField!
    @IBOutlet weak var wpZipTxtField            :UITextField!
    @IBOutlet weak var wpDescriptionTxtField    :UITextField!
    @IBOutlet weak var wpstopNumberTxtField     :UITextField!
    @IBOutlet weak var wpMapView                :MKMapView!
    @IBOutlet weak var latCoordLabel            :UILabel!
    @IBOutlet weak var lonCoordLabel            :UILabel!
    var latCoord = String()
    var lonCoord = String()
    
    //MARK: - Get map data
    
    func longPressMap(gestureRecognizer:UILongPressGestureRecognizer) {
        print("test")
        let touchPoint = gestureRecognizer.locationInView(self.wpMapView)
        let newCoordinate:CLLocationCoordinate2D = wpMapView.convertPoint(touchPoint, toCoordinateFromView: self.wpMapView)
        //var newAnnotation = MKPointAnnotation()
        
        print("Coords: \(newCoordinate.latitude),\(newCoordinate.longitude)")
        
    }
    
    //MARK: - Geocode address
    
    @IBAction func mapAddress() {
        geocodeAddress()
        resignAllFirstResponders()
    }
    
    func geocodeAddress() {
        if let add = wpaddressTxtField.text {
            let city = wpCityTxtField.text ?? ""
            let state = wpStateTxtField.text ?? ""
            let zip = wpZipTxtField.text ?? ""
            
            let address = "\(add) \(city) \(state) \(zip)"
            let geocoder = CLGeocoder()
            
            geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
                if((error) != nil){
                    print("Error", error)
                }
                if let placemark = placemarks?.first {
                    let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                    //                    print("coords: \(coordinates.latitude),\(coordinates.longitude)")
                    
                    //need to remove all previous pins...
                    
                    let pin = MKPointAnnotation()
                    pin.title = self.wpNameTxtField.text
                    pin.coordinate = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
                    
                    self.wpMapView.addAnnotation(pin)
                    let region: MKCoordinateRegion = MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
                    self.wpMapView.setRegion(region, animated: true)
                    self.latCoord = "\(coordinates.latitude)"
                    self.lonCoord = "\(coordinates.longitude)"
                    //                    print(self.latCoord)
                    //                    print(self.lonCoord)
                }
            })
        }
        
        
        
    }
    
    //MARK: - Interactivity Methods
    
    @IBAction func saveRouteInfo(sender: UIBarButtonItem) {
        saveWayPoint(sourceRoute)//what to do here? I want to put the source route's object ID in...
        resignAllFirstResponders()
    }
    
    func saveWayPoint(route: Route) {
        print("wp saved pressed")
        if selectedWP == nil {
            let newWP = Waypoint()
            if let routeName = wpNameTxtField.text {
                newWP.wpName = routeName
            }
            if let descript = wpDescriptionTxtField.text {
                newWP.wpDescript = descript
            }
            if let address = wpaddressTxtField.text {
                newWP.wpAddress = address
            }
            if let city = wpCityTxtField.text {
                newWP.wpCity = city
            }
            if let state = wpStateTxtField.text {
                newWP.wpState = state
            }
            if let zip = wpZipTxtField.text {
                newWP.wpZip = zip
            }
            if let stopNum = wpstopNumberTxtField.text {
                newWP.wpStopNum = Int(stopNum)!
            } else {
                newWP.wpStopNum = 0
            }
            newWP.wpLat = latCoord
            newWP.wpLon = lonCoord
            
            
            route.routeWaypoints.append(newWP)
            
            var error: Fault?
            let result = backendless.data.save(route, error: &error) as? Route
            if error == nil {
                print("Route havs been updated: \(result)")
            }
            else {
                print("Server reported an error: \(error)")
            }
            
        } else {
            
            
            let dataStore = Backendless.sharedInstance().data.of(Waypoint.ofClass())
            
            selectedWP!.wpName = wpNameTxtField.text
            selectedWP!.wpDescript = wpDescriptionTxtField.text
            selectedWP!.wpAddress = wpaddressTxtField.text
            if let city = wpCityTxtField.text {
                selectedWP!.wpCity = city
            }
            if let state = wpStateTxtField.text {
                selectedWP!.wpState = state
            }
            if let zip = wpZipTxtField.text {
                selectedWP!.wpZip = zip
            }
            if let stopNum = wpstopNumberTxtField.text {
                selectedWP!.wpStopNum = Int(stopNum)!
            } else {
                selectedWP!.wpStopNum = 0
            }
            selectedWP!.wpLat = latCoord
            selectedWP!.wpLon = lonCoord
            
            dataStore.save(
                selectedWP,
                response: { (result: AnyObject!) -> Void in
                    let updatedRoute = result as! Waypoint
                    print("Contact has been updated: \(updatedRoute.objectId)")
                },
                error: { (fault: Fault!) -> Void in
                    print("Server reported an error (2): \(fault)")
            })
        }
    }
    
    
    func resignAllFirstResponders() {
        wpNameTxtField.resignFirstResponder()
        wpaddressTxtField.resignFirstResponder()
        wpDescriptionTxtField.resignFirstResponder()
        wpstopNumberTxtField.resignFirstResponder()
        wpCityTxtField.resignFirstResponder()
        wpStateTxtField.resignFirstResponder()
        wpZipTxtField.resignFirstResponder()
    }
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let selWP = selectedWP {
            if let name = selWP.wpName {
                wpNameTxtField.text = name
                self.title = name
            }
            if let address = selWP.wpAddress {
                wpaddressTxtField.text = address
                geocodeAddress()
            }
            if let descript = selWP.wpDescript {
                wpDescriptionTxtField.text = descript
            }
            
        } else {
            wpNameTxtField.text = ""
            wpaddressTxtField.text = ""
            wpDescriptionTxtField.text = ""
            wpstopNumberTxtField.text = ""
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
