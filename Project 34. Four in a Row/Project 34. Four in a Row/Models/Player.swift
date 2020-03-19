//
//  Player.swift
//  Project 34. Four in a Row
//
//  Created by Eugene Ilyin on 21.12.2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import GameplayKit
import UIKit

class Player: NSObject, GKGameModelPlayer {
    
    // MARK: - Properties
    var chip: ChipColor
    var colour: UIColor
    var name: String
    var playerId: Int
    
    static var allPlayers = [Player(chip: .red), Player(chip: .black)]
    
    var opponent: Player {
        if chip == .red {
            return Player.allPlayers[1]
        } else {
            return Player.allPlayers[0]
        }
    }
    
    // MARK: - Initialization
    init(chip: ChipColor) {
        self.chip = chip
        self.playerId = chip.rawValue
        
        if chip == .red {
            colour = .red
            name = "Red"
        } else {
            colour = .black
            name = "Black"
        }
        
        super.init()
    }
}
