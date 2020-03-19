//
//  File.swift
//  Project 32. SwiftSearcher
//
//  Created by Eugene Ilyin on 20.12.2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import Foundation

class Project: NSObject, NSCoding {
    var title: String
    var subtitle: String
    var favorited: Bool
    
    init(title: String, subtitle: String, favorited: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.favorited = favorited
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(title, forKey: "title")
        coder.encode(subtitle, forKey: "subtitle")
        coder.encode(favorited, forKey: "favorited")
    }
    
    required init?(coder: NSCoder) {
        title = coder.decodeObject(forKey: "title") as? String ?? ""
        subtitle = coder.decodeObject(forKey: "subtitle") as? String ?? ""
        favorited = coder.decodeBool(forKey: "favorited")
     }
}
