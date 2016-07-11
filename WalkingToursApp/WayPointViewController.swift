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
    var selectedWP  = Waypoint?()
    var sourceRoute : Route!
    @IBOutlet weak var wpNameTxtField           :UITextField!
    @IBOutlet weak var wpaddressTxtField        :UITextField!
    @IBOutlet weak var wpCityTxtField           :UITextField!
    @IBOutlet weak var wpStateTxtField          :UITextField!
    @IBOutlet weak var wpZipTxtField            :UITextField!
    @IBOutlet weak var wpDescriptionTxtField    :UITextField!
    @IBOutlet weak var wpstopNumberLabel        :UILabel!
    @IBOutlet weak var wpLatTxtField            :UITextField!
    @IBOutlet weak var wpLonTxtField            :UITextField!
    @IBOutlet weak var wpMapView                :MKMapView!
    @IBOutlet weak var messageView              :UIView!
    @IBOutlet weak var messageLabel             :UILabel!
    @IBOutlet weak var charRemainLabel          :UILabel!
    var latCoord = String()
    var lonCoord = String()
    
    
    
    //MARK: - Interactivity Methods
    
    @IBAction func saveRouteInfo(sender: UIBarButtonItem) {
        saveWayPoint(sourceRoute)
        resignAllFirstResponders()
    }
    
    @IBAction func checkMaxLength() {
        if (wpDescriptionTxtField.text?.characters.count > 500) {
            wpDescriptionTxtField.deleteBackward()
        }
        if (wpNameTxtField.text?.characters.count > 500) {
            wpNameTxtField.deleteBackward()
        }
    }
    
    @IBAction func charRemaining() {
        let descript = wpDescriptionTxtField.text
        let charUsed = 500 - descript!.characters.count
        charRemainLabel.text = "Characters Remaining: \(charUsed)"
    }
    
    func saveWayPoint(route: Route) {
        fadeInMessageView("Saving")
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
            newWP.wpStopNum = Int(wpstopNumberLabel.text!)!
            newWP.wpLat = latCoord
            newWP.wpLon = lonCoord
            
            route.routeWaypoints.append(newWP)
            var error: Fault?
            let result = backendless.data.save(route, error: &error) as? Route
            if error == nil {
                print(result)
                self.fadeOutMessageView()
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "wpsaved", object: nil))
                self.messageLabel.text = "Saved"
            } else {
                //                print("Server reported an error: \(error)")
                self.messageLabel.text = "Error"
                self.fadeOutMessageView()
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
            selectedWP!.wpStopNum = Int(wpstopNumberLabel.text!)!
            selectedWP!.wpLat = latCoord
            selectedWP!.wpLon = lonCoord
            
            dataStore.save(
                selectedWP,
                response: { (result: AnyObject!) -> Void in
                    let updatedRoute = result as! Waypoint
                    if let saveMessage = updatedRoute.wpName {
                        self.messageLabel.text = "\(saveMessage) has been saved"
                        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "wpsaved", object: nil))
                    }
                    self.fadeOutMessageView()
                },
                error: { (fault: Fault!) -> Void in
                    if let errorMessage = self.selectedWP?.wpName {
                        //                        print(errorMessage)
                        self.messageLabel.text = "There has been an error, \(errorMessage) has not been saved"
                        self.fadeOutMessageView()
                    }
            })
        }
    }
    
    @IBAction func deleteButtonPressed(sender: UIBarButtonItem){
        deleteListing()
    }
    
    func deleteListing() {
        let dataStore = backendless.data.of(Route.ofClass())
        dataStore.save(
            selectedWP,
            response: { (result: AnyObject!) -> Void in
                let savedWP = result as! Waypoint
                dataStore.remove(
                    savedWP,
                    response: { (result: AnyObject!) -> Void in
                        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "wpdeleted", object: nil))
                    },
                    error: { (fault: Fault!) -> Void in
                })
            },
            error: { (fault: Fault!) -> Void in
        })
        self.navigationController!.popViewControllerAnimated(true)
        
    }
    
    
    func resignAllFirstResponders() {
        wpNameTxtField.resignFirstResponder()
        wpaddressTxtField.resignFirstResponder()
        wpCityTxtField.resignFirstResponder()
        wpStateTxtField.resignFirstResponder()
        wpZipTxtField.resignFirstResponder()
        wpDescriptionTxtField.resignFirstResponder()
        wpLatTxtField.resignFirstResponder()
        wpLonTxtField.resignFirstResponder()
    }
    
    //MARK: - Onscreen Alert Methods
    
    func fadeInMessageView(message : String) {
        self.messageLabel.text = message
        self.messageView.alpha = 1.0
    }
    
    func fadeOutMessageView() {
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(3.0 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.messageView.alpha = 0.0
                }, completion: nil)
        })
    }
    
    
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
                }
                if let placemark = placemarks?.first {
                    let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                    self.latCoord = "\(coordinates.latitude)"
                    self.lonCoord = "\(coordinates.longitude)"
                    self.wpLatTxtField.text = "\(coordinates.latitude)"
                    self.wpLonTxtField.text = "\(coordinates.longitude)"
                    if plotOnMap {
                        self.wpMapView.removeAnnotations(self.wpMapView.annotations)
                        
                        let addDict = placemark.addressDictionary
                        guard let streetNum = addDict!["SubThoroughfare"] as? String else{
                            return
                        }
                        guard let streetName = addDict!["Thoroughfare"] as? String else{
                            return
                        }
                        let street1 = "\(streetNum) \(streetName)"
                        guard let city1 = addDict!["City"] as? String else {
                            return
                        }
                        guard let zip1 = addDict!["ZIP"] as? String else {
                            return
                        }
                        guard let state1 = addDict!["State"] as? String else {
                            return
                        }
                        
                        let pin = WayPointAnnotation()
                        pin.coordinate = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
                        pin.title = placemark.name
                        pin.subtitle = street1
                        let waypoint = Waypoint()
                        waypoint.wpAddress = street1
                        waypoint.wpCity = city1
                        waypoint.wpState = state1
                        waypoint.wpZip = zip1
                        waypoint.wpLat = "\(coordinates.latitude)"
                        waypoint.wpLon = "\(coordinates.longitude)"
                        self.latCoord = "\(coordinates.latitude)"
                        self.lonCoord = "\(coordinates.longitude)"
                        pin.waypoint = waypoint
                        self.wpMapView.addAnnotation(pin)
                        self.wpMapView.showAnnotations(self.wpMapView.annotations, animated: true)
                    } else {
                        
                    }
                }
            })
        }
    }
    
    //MARK: - Search Methods
    
    @IBAction func pressedPlotGPS() {
        wpLatTxtField.resignFirstResponder()
        wpLonTxtField.resignFirstResponder()
        resignAllFirstResponders()
        guard let latDub = Double(wpLatTxtField.text!) else {
            return
        }
        guard let lonDub = Double(wpLonTxtField.text!) else {
            return
        }
        self.latCoord = wpLatTxtField.text!
        self.lonCoord = wpLonTxtField.text!
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latDub, longitude: lonDub)
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            let addDict = placeMark.addressDictionary
            
            //Address Info
            guard let streetNum = addDict!["SubThoroughfare"] as? String else{
                return
            }
            guard let streetName = addDict!["Thoroughfare"] as? String else{
                return
            }
            let street = "\(streetNum) \(streetName)"
            guard let city = addDict!["City"] as? String else {
                return
            }
            guard let zip = addDict!["ZIP"] as? String else {
                return
            }
            guard let state = addDict!["State"] as? String else {
                return
            }
            
            self.wpMapView.removeAnnotations(self.wpMapView.annotations)
            let pin = WayPointAnnotation()
            pin.coordinate = location.coordinate
            if let name = self.wpNameTxtField.text {
                pin.title = name
            } else {
                pin.title = ""
            }
            pin.coordinate = location.coordinate
            pin.subtitle = street
            let waypoint = Waypoint()
            waypoint.wpAddress = street
            waypoint.wpCity = city
            waypoint.wpState = state
            waypoint.wpZip = zip
            waypoint.wpLat = "\(location.coordinate.latitude)"
            waypoint.wpLon = "\(location.coordinate.longitude)"
            self.latCoord = "\(location.coordinate.latitude)"
            self.lonCoord = "\(location.coordinate.longitude)"
            pin.waypoint = waypoint
            self.wpMapView.addAnnotation(pin)
            self.wpMapView.showAnnotations(self.wpMapView.annotations, animated: true)
        })
    }
    
    //MARK: - Apple Local Search
    
    @IBAction func localSearch() {
        resignAllFirstResponders()
        wpNameTxtField.resignFirstResponder()
        self.wpMapView.removeAnnotations(self.wpMapView.annotations)
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = wpNameTxtField.text
        request.region = wpMapView.region
        
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { (response, error) in
            guard let response = response else {
                return
            }
            for item in response.mapItems {
                guard let name = item.name else {
                    return
                }
                let location = item.placemark
                let addDict = item.placemark.addressDictionary
                
                guard let streetNum = addDict!["SubThoroughfare"] as? String else{
                    return
                }
                guard let streetName = addDict!["Thoroughfare"] as? String else{
                    return
                }
                let street = "\(streetNum) \(streetName)"
                guard let city = addDict!["City"] as? String else {
                    return
                }
                guard let zip = addDict!["ZIP"] as? String else {
                    return
                }
                guard let state = addDict!["State"] as? String else {
                    return
                }
                
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
                self.latCoord = "\(location.coordinate.latitude)"
                self.lonCoord = "\(location.coordinate.longitude)"
                pin.waypoint = waypoint
                self.wpMapView.addAnnotation(pin)
                self.wpMapView.showAnnotations(self.wpMapView.annotations, animated: true)
            }
        }
        
    }
    
    //MARK: - Long Press Gesture
    
    @IBAction func mapLongPressed(gesture: UILongPressGestureRecognizer ) {
        if gesture.state == UIGestureRecognizerState.Ended {
            wpMapView.removeAnnotations(wpMapView.annotations)
            let point = gesture.locationInView(self.wpMapView)
            let pointCoord = self.wpMapView .convertPoint(point, toCoordinateFromView: self.wpMapView)
            let geoCoder = CLGeocoder()
            
            let location = CLLocation(latitude: pointCoord.latitude, longitude: pointCoord.longitude)
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                var placeMark: CLPlacemark!
                placeMark = placemarks?[0]
                let addDict = placeMark.addressDictionary
                
                //Address Info
                guard let streetNum = addDict!["SubThoroughfare"] as? String else{
                    return
                }
                guard let streetName = addDict!["Thoroughfare"] as? String else{
                    return
                }
                let street = "\(streetNum) \(streetName)"
                guard let city = addDict!["City"] as? String else {
                    return
                }
                guard let zip = addDict!["ZIP"] as? String else {
                    return
                }
                guard let state = addDict!["State"] as? String else {
                    return
                }
                
                let pin = WayPointAnnotation()
                pin.coordinate = pointCoord
                pin.title = placeMark.name
                pin.subtitle = street
                let waypoint = Waypoint()
                waypoint.wpAddress = street
                waypoint.wpCity = city
                waypoint.wpState = state
                waypoint.wpZip = zip
                waypoint.wpLat = "\(location.coordinate.latitude)"
                waypoint.wpLon = "\(location.coordinate.longitude)"
                self.latCoord = "\(location.coordinate.latitude)"
                self.lonCoord = "\(location.coordinate.longitude)"
                pin.waypoint = waypoint
                self.wpMapView.addAnnotation(pin)
                self.wpMapView.showAnnotations(self.wpMapView.annotations, animated: true)
            })
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
                let waypointPin = pin as! WayPointAnnotation
                guard let wp = waypointPin.waypoint else {
                    return
                }
                wpaddressTxtField.text = wp.wpAddress
                wpCityTxtField.text = wp.wpCity
                wpStateTxtField.text = wp.wpState
                wpZipTxtField.text = wp.wpZip
            }
            wpLatTxtField.text = String(pin.coordinate.latitude)
            wpLonTxtField.text = String(pin.coordinate.longitude)
            latCoord = String(pin.coordinate.latitude)
            lonCoord = String(pin.coordinate.longitude)
            if let name = pin.title {
                wpNameTxtField.text = name
            }
            wpaddressTxtField.text = pin.subtitle!
        }
    }
    
    //MARK: - Textfield Delegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        switch textField {
        case wpNameTxtField:
            wpNameTxtField.resignFirstResponder()
            localSearch()
        case wpaddressTxtField:
            wpaddressTxtField.resignFirstResponder()
            mapAddress()
        case wpCityTxtField:
            wpCityTxtField.resignFirstResponder()
            mapAddress()
        case wpStateTxtField:
            wpStateTxtField.resignFirstResponder()
            mapAddress()
        case wpZipTxtField:
            wpZipTxtField.resignFirstResponder()
            mapAddress()
        case wpLonTxtField:
            wpLonTxtField.resignFirstResponder()
            pressedPlotGPS()
        case wpLatTxtField:
            wpLatTxtField.resignFirstResponder()
            pressedPlotGPS()
        default:
            resignAllFirstResponders()
        }
        return true
    }
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wpMapView.delegate = self
        wpNameTxtField.delegate = self
        messageView.alpha = 0.0
        
        if let selWP = selectedWP {
            let stopnum = selWP.wpStopNum
            wpstopNumberLabel.text = "\(stopnum)"
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
            charRemaining()
            geocodeAddress(true)
        } else {
            wpstopNumberLabel.text = "\(sourceRoute.routeWaypoints.count + 1)"
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
