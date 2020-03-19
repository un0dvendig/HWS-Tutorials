//
//  ViewController.swift
//  Project 34. Four in a Row
//
//  Created by Eugene Ilyin on 21.12.2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import GameplayKit
import UIKit

enum GameType {
    case vsPlayer, vsAI
}

class ViewController: UIViewController {

    // MARK: - Properties
    var placedChips = [[UIView]]()
    var board: Board!
    var strategist: GKMinmaxStrategist!
    var currentGameType: GameType = .vsAI
    
    // MARK: - Outlets
    @IBOutlet var columnButtons: [UIButton]!
    
    // MARK: - Actions
    @IBAction func makeMove(_ sender: UIButton) {
        let column = sender.tag
        
        if let row = board.nextEmptySlot(in: column) {
            board.add(chip: board.currentPlayer.chip,
                      in: column)
            addChip(inColumn: column,
                    row: row,
                    colour: board.currentPlayer.colour)
            continueGame()
        }
    }
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0 ..< Board.width {
            placedChips.append([UIView]())
        }
        
        strategist = GKMinmaxStrategist()
        strategist.maxLookAheadDepth = 7
        strategist.randomSource = nil // "Just return the first best move"
//        strategist.randomSource = GKARC4RandomSource() // Random best move
        
        chooseGameType()
    }

    // MARK: - Methods
    
    // MARK: - Private methods
    private func resetBoard() {
        board = Board()
        strategist.gameModel = board
        
        updateUI()
        
        for i in 0 ..< placedChips.count {
            for chip in placedChips[i] {
                chip.removeFromSuperview()
            }
            
            placedChips[i].removeAll(keepingCapacity: true)
        }
    }
    
    private func addChip(inColumn column: Int, row: Int, colour: UIColor) {
        let button = columnButtons[column]
        let size = min(button.frame.width, button.frame.height / 6)
        let rect = CGRect(x: 0, y: 0, width: size, height: size)
        
        if (placedChips[column].count < row + 1) {
            let newChip = UIView()
            newChip.frame = rect
            newChip.isUserInteractionEnabled = false
            newChip.backgroundColor = colour
            newChip.layer.cornerRadius = size / 2
            newChip.center = positionForChip(inColumn: column, row: row)
            newChip.transform = CGAffineTransform(translationX: 0, y: -800)
            view.addSubview(newChip)
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                newChip.transform = CGAffineTransform.identity
            })
            
            placedChips[column].append(newChip)
        }
    }
    
    private func positionForChip(inColumn column: Int, row: Int) -> CGPoint {
        let button = columnButtons[column]
        let size = min(button.frame.width, button.frame.height / 6)
        
        let xOffset = button.frame.midX
        var yOffset = button.frame.maxY - size / 2
        yOffset -= size * CGFloat(row)
        return CGPoint(x: xOffset, y: yOffset)
    }
    
    private func updateUI() {
        title = "\(board.currentPlayer.name)'s Turn"
        
        if board.currentPlayer.chip == .black && currentGameType == .vsAI {
            startAIMove()
        }
    }
    
    private func continueGame() {
        var gameOverTitle: String? = nil
        
        if board.isWin(for: board.currentPlayer) {
            gameOverTitle = "\(board.currentPlayer.name) Wins!"
        } else  if board.isFull() {
            gameOverTitle = "Draw!"
        }
        
        if gameOverTitle != nil {
            let alert = UIAlertController(title: gameOverTitle,
                                          message: nil,
                                          preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Play Again", style: .default) { [unowned self] (action) in
                self.chooseGameType()
            }
            
            alert.addAction(alertAction)
            present(alert, animated: true)
            
            return
        }
        
        board.currentPlayer = board.currentPlayer.opponent
        updateUI()
    }
    
    private func columnForAIMove() -> Int? {
        if let aiMove = strategist.bestMove(for: board.currentPlayer) as? Move {
            return aiMove.column
        }
        
        return nil
    }
    
    private func makeAIMove(in column: Int) {
        columnButtons.forEach { $0.isEnabled = true }
        navigationItem.leftBarButtonItem = nil
        
        if let row = board.nextEmptySlot(in: column) {
            board.add(chip: board.currentPlayer.chip,
                      in: column)
            addChip(inColumn: column,
                    row: row,
                    colour: board.currentPlayer.colour)
            
            continueGame()
        }
    }
    
    private func startAIMove() {
        columnButtons.forEach { $0.isEnabled = false }
        
        let spinner = UIActivityIndicatorView()
        if #available(iOS 13, *) {
            spinner.style = .medium
        } else {
           spinner.style = .gray
        }
        spinner.startAnimating()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: spinner)
        
        DispatchQueue.global().async { [unowned self] in
            let strategistTime = CFAbsoluteTimeGetCurrent()
            guard let column = self.columnForAIMove() else { return }
            let delta = CFAbsoluteTimeGetCurrent() - strategistTime
            
            let aiTimeCeiling = 1.0
            let delay = aiTimeCeiling - delta
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.makeAIMove(in: column)
            }
        }
    }
    
    private func chooseGameType() {
        let ac = UIAlertController(title: "Game Type",
                                   message: "Choose game type",
                                   preferredStyle: .alert)
        let aiAction = UIAlertAction(title: "vsAI", style: .default) { [unowned self] (action) in
            self.currentGameType = .vsAI
            self.chooseAIDifficulty()
        }
        let playerAction = UIAlertAction(title: "vsPlayer", style: .default) { [unowned self] (action) in
            self.currentGameType = .vsPlayer
        }
        ac.addAction(aiAction)
        ac.addAction(playerAction)
        
        present(ac, animated: true) { [unowned self] in
            self.resetBoard()
        }
    }
    
    private func chooseAIDifficulty() {
        let ac = UIAlertController(title: "AI difficulty",
                                   message: "Choose difficulty",
                                   preferredStyle: .alert)
        let easyAction = UIAlertAction(title: "Easy", style: .default) { [unowned self] (action) in
            self.strategist.maxLookAheadDepth = 4
        }
        let mediumAction = UIAlertAction(title: "Medium", style: .default) { [unowned self] (action) in
            self.strategist.maxLookAheadDepth = 7
        }
        let hardAction = UIAlertAction(title: "Hard", style: .default) { [unowned self] (action) in
            self.strategist.maxLookAheadDepth = 8
        }
        ac.addAction(easyAction)
        ac.addAction(mediumAction)
        ac.addAction(hardAction)
        
        present(ac,
                animated: true)
    }
}

