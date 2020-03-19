//
//  PlayData.swift
//  Project 39. Unit testing with XCTest
//
//  Created by Eugene Ilyin on 09.01.2020.
//  Copyright © 2020 Eugene Ilyin. All rights reserved.
//

import Foundation

class PlayData {
    
    // MARK: - Properties
    var allWords = [String]()
    private(set) var filteredWords = [String]()
    var wordCounts: NSCountedSet!
    
    // MARK: - Initialization
    init() {
        guard let path = Bundle.main.path(forResource: "plays", ofType: "txt") else { return }
        if let plays = try? String(contentsOfFile: path) {
            allWords = plays.components(separatedBy: CharacterSet.alphanumerics.inverted)
            allWords = allWords.filter { $0 != "" }
            
            wordCounts = NSCountedSet(array: allWords)
            let sorted = wordCounts.allObjects.sorted { wordCounts.count(for: $0) > wordCounts.count(for: $1) }
            allWords = sorted as! [String]
        }
        applyUserFilter("swift")
    }
    
    // MARK: - Methods
    func applyUserFilter(_ input: String) {
        if input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            filteredWords = allWords
        } else if let userNumber = Int(input) {
            applyFilter { self.wordCounts.count(for: $0) >= userNumber }
        } else {
            applyFilter { $0.range(of: input, options: .caseInsensitive) != nil }
        }
    }
    
    func applyFilter(_ filter: (String) -> Bool) {
        filteredWords = allWords.filter(filter)
    }
}
