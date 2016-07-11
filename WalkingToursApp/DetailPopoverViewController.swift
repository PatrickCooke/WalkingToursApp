//
//  DetailPopoverViewController.swift
//  WalkingToursApp
//
//  Created by Patrick Cooke on 6/27/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

class DetailPopoverViewController: UIViewController {
    
    @IBOutlet weak var wpDetailTextView:    UITextView!
    var detail : String!
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLayoutSubviews() {
        self.wpDetailTextView.setContentOffset(CGPointZero, animated: false)
    }
    
    override func viewDidLoad() { 
        super.viewDidLoad()
        self.preferredContentSize = CGSizeMake(400, 200)
        wpDetailTextView.text = detail
        wpDetailTextView.setContentOffset(CGPointZero, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
