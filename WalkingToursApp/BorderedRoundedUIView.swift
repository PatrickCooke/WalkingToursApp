//
//  BorderedRoundedUIView.swift
//  iDesign
//
//  Created by Patrick Cooke on 5/26/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

@IBDesignable
class BorderedRoundedUIView: UITableView {

    //This creates 3 more properties which can be set for any UIView which is clased to "BorderedRoundedUIView"
    //adding @IBInspectable makes each property accessable on the StoryBoard
    // adding @IBDesignable allows each property to be viewable on the Storyboard
    
    @IBInspectable var cornerRadius : CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0 //MASK TO BOUNDS makes the corners which are cut off to show up as clear
        }
    }
    
    @IBInspectable var borderWidth : CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor : UIColor? {
        didSet {
            layer.borderColor = borderColor?.CGColor
        }
    }
    
}
