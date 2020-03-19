//
//  Commit+CoreDataProperties.swift
//  task38.Github Commits
//
//  Created by Eugene Ilyin on 07.01.2020.
//  Copyright © 2020 Eugene Ilyin. All rights reserved.
//
//

import Foundation
import CoreData


extension Commit {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Commit> {
        return NSFetchRequest<Commit>(entityName: "Commit")
    }

    @NSManaged public var date: Date
    @NSManaged public var message: String
    @NSManaged public var sha: String
    @NSManaged public var url: String
    @NSManaged public var author: Author

}
