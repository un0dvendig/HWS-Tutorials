//
//  Capital.swift
//  Project 16. Capital Cities
//
//  Created by Eugene Ilyin on 22.11.2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import MapKit
import UIKit

class Capital: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
    }
}
