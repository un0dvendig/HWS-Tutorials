//
//  Move.swift
//  Project 34. Four in a Row
//
//  Created by Eugene Ilyin on 21.12.2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import GameplayKit
import UIKit

class Move: NSObject, GKGameModelUpdate {

    // MARK: - Properties
    var value: Int = 0
    var column: Int
    
    // MARK: - Initialization
    init(column: Int) {
        self.column = column
    }
}
