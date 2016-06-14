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
    @IBOutlet weak var wpNameTxtField   :UITextField!
    @IBOutlet weak var wpaddressTxtField   :UITextField!
    @IBOutlet weak var wpDescriptionTxtField   :UITextField!
    @IBOutlet weak var wpstopNumberTxtField   :UITextField!
    

    //MARK: - Temp Add Data
    func addNewData() {
        let wp = Waypoint()
        wp.wpName = "University Of Phoenix"
        wp.wpDescript = "Yeah, we're still here"
        wp.wpAddress = "1001 woodward ave detroit mi"
        wp.wpStopNum = 2
        wp.wpLat = "42.3320134"
        wp.wpLon = "-83.0476329"
        
        
        let dataStore = backendless.data.of(Waypoint.ofClass())

        dataStore.save(
            wp,
            response: { (result: AnyObject!) -> Void in
                let obj = result as! Waypoint
                print("Contact has been saved: \(obj.objectId)")
            },
            error: { (fault: Fault!) -> Void in
                print("fServer reported an error: \(fault)")
        })
    }


    //MARK: - Interactivity Methods

    @IBAction func saveButtonPressed(sender: UIBarButtonItem) {
        print("save button pressed")
        
    }
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //addNewData()
//        if let selWP = selectedWP {
//            if let name = selWP.wpName {
//                wpNameTxtField.text = name
//            }
//            if let address = selWP.wpAddress {
//                wpaddressTxtField.text = address
//            }
//            if let descript = selWP.wpDescript {
//                wpDescriptionTxtField.text = descript
//            }
//            
//        } else {
//            wpNameTxtField.text = ""
//            wpaddressTxtField.text = ""
//            wpDescriptionTxtField.text = ""
//            wpstopNumberTxtField.text = ""
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
