//
//  PublicTableViewCell.swift
//  WalkingToursApp
//
//  Created by Patrick Cooke on 7/5/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

class PublicTableViewCell: UITableViewCell {

    @IBOutlet weak var routeNameLabel   :UILabel!
    @IBOutlet weak var routeStartPoint  :UILabel!
    @IBOutlet weak var routeDescript    :UILabel!
    @IBOutlet weak var routeMapView     :MKMapView!
    @IBOutlet weak var routeDist        :UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib() 
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
