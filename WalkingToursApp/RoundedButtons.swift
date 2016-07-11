//
//  RoundedButtons.swift
//  WalkingToursApp
//
//  Created by Patrick Cooke on 6/22/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButtons: UIButton {

    @IBInspectable var cornerRadius : CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
}
