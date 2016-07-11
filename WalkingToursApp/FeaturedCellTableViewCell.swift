//
//  FeaturedCellTableViewCell.swift
//  WalkingToursApp
//
//  Created by Patrick Cooke on 6/22/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

class FeaturedCellTableViewCell: UITableViewCell {

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
