//
//  WayPointViewController.swift
//  walkaroundbackend
//
//  Created by Patrick Cooke on 6/13/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit
import CoreLocation

class WayPointViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
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
    @IBOutlet weak var wpLatTxtField            :UITextField!
    @IBOutlet weak var wpLonTxtField            :UITextField!
    @IBOutlet weak var wpMapView                :MKMapView!
    @IBOutlet weak var latCoordLabel            :UILabel!
    @IBOutlet weak var lonCoordLabel            :UILabel!
    var latCoord = String()
    var lonCoord = String()
    
    //MARK: - Geocode address
    
    @IBAction func mapAddress() {
        geocodeAddress(true)
        resignAllFirstResponders()
    }
    
    func geocodeAddress(plotOnMap: Bool) {
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
                    
                    self.latCoord = "\(coordinates.latitude)"
                    self.lonCoord = "\(coordinates.longitude)"
                    self.wpLatTxtField.text = "\(coordinates.latitude)"
                    self.wpLonTxtField.text = "\(coordinates.longitude)"
                    
                    if plotOnMap {
                        self.wpMapView.removeAnnotations(self.wpMapView.annotations)
                        print("did plot")
                        let pin = MKPointAnnotation()
                        pin.coordinate = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
                        self.wpMapView.addAnnotation(pin)
                        self.wpMapView.showAnnotations(self.wpMapView.annotations, animated: true)
                    } else {
                     print("did not plot")
                    }
                }
            })
        }
    }
    
    //MARK: - Interactivity Methods
    
    @IBAction func saveRouteInfo(sender: UIBarButtonItem) {
        saveWayPoint(sourceRoute)
        resignAllFirstResponders()
    }
    
    func saveWayPoint(route: Route) {
        print("wp saved pressed")
        geocodeAddress(false)
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
                newWP.wpStopNum = stopNum
            } else {
                newWP.wpStopNum = "0"
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
                selectedWP!.wpStopNum = stopNum
            } else {
                selectedWP!.wpStopNum = "0"
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
        wpLatTxtField.resignFirstResponder()
        wpLonTxtField.resignFirstResponder()
    }
    
    //MARK: - Search Methods
    
    @IBAction func pressedPlotGPS() {
        resignAllFirstResponders()
        guard let latDub = Double(wpLatTxtField.text!) else {
            return
        }
        guard let lonDub = Double(wpLonTxtField.text!) else {
            return
        }
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latDub, longitude: lonDub)
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Address dictionary
            print(placeMark.addressDictionary)
            let addDict = placeMark.addressDictionary
            
            //Address Info
            guard let streetNum = addDict!["SubThoroughfare"] as? NSString else{
                return
            }
            guard let streetName = addDict!["Thoroughfare"] as? NSString else{
                return
            }
            let street = "\(streetNum) \(streetName)"
            print("street: \(street)")
            guard let city = addDict!["City"] as? NSString else {
                return
            }
            print("city - \(city)")
            guard let zip = addDict!["ZIP"] as? NSString else {
                return
            }
            print("zip: \(zip)")
            guard let state = addDict!["State"] as? NSString else {
                return
            }
            print(state)
            guard let country = addDict!["Country"] as? NSString else {
                return
            }
            print(country)
            
            self.wpMapView.removeAnnotations(self.wpMapView.annotations)
            print("did plot")
            let pin = MKPointAnnotation()
            pin.coordinate = location.coordinate
            pin.title = "\(street), \(city), \(state) \(zip)"
            pin.subtitle = country as String
            
            self.wpMapView.addAnnotation(pin)
            self.wpMapView.showAnnotations(self.wpMapView.annotations, animated: true)
        })
        
    }
    
    //MARK: - Apple Local Search
    
    @IBAction func localSearch() {
        self.wpMapView.removeAnnotations(self.wpMapView.annotations)
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = wpNameTxtField.text
        request.region = wpMapView.region
        
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { (response, error) in
            guard let response = response else {
                print("Search error: \(error)")
                return
            }
            for item in response.mapItems {
                guard let name = item.name else {
                    return
                }
                let location = item.placemark
                let addDict = item.placemark.addressDictionary
                print(name)
                //Address Info
                
                guard let streetNum = addDict!["SubThoroughfare"] as? String else{
                    return
                }
                guard let streetName = addDict!["Thoroughfare"] as? String else{
                    return
                }
                let street = "\(streetNum) \(streetName)"
                print("street: \(street)")
                guard let city = addDict!["City"] as? String else {
                    return
                }
                print("city - \(city)")
                guard let zip = addDict!["ZIP"] as? String else {
                    return
                }
                print("zip: \(zip)")
                guard let state = addDict!["State"] as? String else {
                    return
                }
                print(state)
                
                let pin = WayPointAnnotation()
                pin.coordinate = location.coordinate
                pin.title = name
                pin.subtitle = street
                let waypoint = Waypoint()
                waypoint.wpName = name
                waypoint.wpAddress = street
                waypoint.wpCity = city
                waypoint.wpState = state
                waypoint.wpZip = zip
                waypoint.wpLat = "\(location.coordinate.latitude)"
                waypoint.wpLon = "\(location.coordinate.longitude)"
                pin.waypoint = waypoint
                self.wpMapView.addAnnotation(pin)
                self.wpMapView.showAnnotations(self.wpMapView.annotations, animated: true)
            }
        }
        
    }
    
    //MARK: - Map Annotation Methods
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "pin"
        var pin = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier) as? MKPinAnnotationView
        if pin == nil {
            pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            pin!.pinTintColor = UIColor().BeccaBlue()
            pin!.canShowCallout = true
            pin!.rightCalloutAccessoryView = UIButton(type: .ContactAdd)
        } else {
            pin!.annotation = annotation
        }
        return pin
    }
    
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == annotationView.rightCalloutAccessoryView {
            guard let pin = annotationView.annotation else {
                return
            }
            if pin.isKindOfClass(WayPointAnnotation) {
                print("Got WPA")
                let waypointPin = pin as! WayPointAnnotation
                guard let wp = waypointPin.waypoint else {
                    return
                }
                wpCityTxtField.text = wp.wpCity
                wpStateTxtField.text = wp.wpState
                wpZipTxtField.text = wp.wpZip
            }
            wpLatTxtField.text = String(pin.coordinate.latitude)
            wpLonTxtField.text = String(pin.coordinate.longitude)
            wpNameTxtField.text = pin.title!
            wpaddressTxtField.text = pin.subtitle!
          
        }
    }
    
    //MARK: - Textfield Delegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()  //if desired
        switch textField {
        case wpNameTxtField:
            localSearch()
        case wpaddressTxtField, wpCityTxtField, wpStateTxtField, wpZipTxtField:
            mapAddress()
        case wpLonTxtField, wpLatTxtField:
            pressedPlotGPS()
        default:
            print("nothing")
        }
        return true
    }
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wpMapView.delegate = self
        
        wpNameTxtField.delegate = self
        
        
        if let selWP = selectedWP {
            if let stopnum = selWP.wpStopNum{
                wpstopNumberTxtField.text = stopnum
            }
            
            if let name = selWP.wpName {
                wpNameTxtField.text = name
                self.title = name
            }
            
            if let address = selWP.wpAddress {
                wpaddressTxtField.text = address
            }
            
            if let city = selWP.wpCity{
                wpCityTxtField.text = city
            }
            
            if let state = selWP.wpState{
                wpStateTxtField.text = state
            }
            
            if let zip = selWP.wpZip {
                wpZipTxtField.text = zip
            }
            
            if let descript = selWP.wpDescript {
                wpDescriptionTxtField.text = descript
            }
            geocodeAddress(true)
            
        } else {
            wpstopNumberTxtField.text = "\(sourceRoute.routeWaypoints.count + 1)"
            wpNameTxtField.text = ""
            wpaddressTxtField.text = ""
            wpCityTxtField.text = ""
            wpStateTxtField.text = ""
            wpZipTxtField.text = ""
            wpDescriptionTxtField.text = ""

        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
