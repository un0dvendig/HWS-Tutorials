//
//  Petition.swift
//  Project 07. Whitehouse Petitions
//
//  Created by Eugene Ilyin on 02/09/2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import Foundation

struct Petition: Codable {
    var title: String
    var body: String
    var signatureCount: Int
}
