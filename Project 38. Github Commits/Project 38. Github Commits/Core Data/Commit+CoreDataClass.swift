//
//  Commit+CoreDataClass.swift
//  task38.Github Commits
//
//  Created by Eugene Ilyin on 07.01.2020.
//  Copyright © 2020 Eugene Ilyin. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Commit)
public class Commit: NSManagedObject {
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        print("Init called!")
    }
}
