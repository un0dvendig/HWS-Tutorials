//
//  Person.swift
//  Project 10. Names to Faces
//
//  Created by Eugene Ilyin on 26.10.2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import UIKit

class Person: NSObject {
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
