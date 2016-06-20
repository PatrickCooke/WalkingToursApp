//
//  Route.swift
//  WalkingToursApp
//
//  Created by Patrick Cooke on 6/14/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import Foundation

class Route : NSObject {
    
    var objectId : String?
    var routeName : String?
    var routeDistance : String?
    var routeDiscription : String?
    var routePicName : String?
    var routeActive :String?
    var created: NSDate?
    var updated: NSDate?
    var routeWaypoints: [Waypoint] = []
}