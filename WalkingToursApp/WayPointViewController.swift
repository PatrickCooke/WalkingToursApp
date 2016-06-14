//
//  WayPointViewController.swift
//  walkaroundbackend
//
//  Created by Patrick Cooke on 6/13/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

class WayPointViewController: UIViewController {

    var selectedWP = Waypoint?()
    @IBOutlet weak var wpNameLabel   :UILabel!
    
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let selWP = selectedWP {
            wpNameLabel.text = selWP.wpName
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
