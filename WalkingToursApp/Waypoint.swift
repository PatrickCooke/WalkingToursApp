//
//  Waypoint.swift
//  walkaroundbackend
//
//  Created by Patrick Cooke on 6/13/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import Foundation

class Waypoint: NSObject {

    var wpName          :String?
    var wpAddress       :String?
    var wpLat           :String?
    var wpLon           :String?
    var wpDescript      :String?
    var wpStopNum       :Int8 = 0
    var wpPicName       :String?
    var wpAudioName     :String?
    var objectId        :String?
    var created         :NSDate?
    var updated         :NSDate?
}
