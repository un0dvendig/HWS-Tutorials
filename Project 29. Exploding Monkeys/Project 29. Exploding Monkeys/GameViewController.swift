//
//  GameViewController.swift
//  Project 29. Exploding Monkeys
//
//  Created by Eugene Ilyin on 01.12.2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    // MARK: - Properties
    var currentGame: GameScene?
    var player1Score: Int = 0 {
        didSet {
            player1ScoreLabel.text = "Score: \(player1Score)"
        }
    }
    var player2Score: Int = 0 {
        didSet {
            player2ScoreLabel.text = "Score: \(player2Score)"
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var angleSlider: UISlider!
    @IBOutlet weak var angleLabel: UILabel!
    @IBOutlet weak var velocitySlider: UISlider!
    @IBOutlet weak var velocityLabel: UILabel!
    @IBOutlet weak var launchButton: UIButton!
    @IBOutlet weak var playerNumber: UILabel!
    @IBOutlet weak var player1ScoreLabel: UILabel!
    @IBOutlet weak var player2ScoreLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                
                currentGame = scene as? GameScene
                currentGame?.viewController = self
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        angleChanged(self)
        velocityChanged(self)
        player1Score = 0
        player2Score = 0
        updateWindLabel(dx: 0, dy: 0)
    }

    // MARK: - UIViewController methods
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Outlets Methods
    @IBAction func angleChanged(_ sender: Any) {
        angleLabel.text = "Angle: \(Int(angleSlider.value))°"
    }
    
    @IBAction func velocityChanged(_ sender: Any) {
        velocityLabel.text = "Velocity: \(Int(velocitySlider.value))"
    }
    
    @IBAction func launch(_ sender: Any) {
        angleSlider.isHidden = true
        angleLabel.isHidden = true
        
        velocitySlider.isHidden = true
        velocityLabel.isHidden = true
        
        launchButton.isHidden = true
        
        currentGame?.launch(angle: Int(angleSlider.value),
                           velocity: Int(velocitySlider.value))
    }
    
    // MARK: - Methods
    func activatePlayer(number: Int) {
        if number == 1 {
            playerNumber.text = "<<< PLAYER ONE"
        } else {
            playerNumber.text = "PLAYER TWO >>>"
        }
        
        angleSlider.isHidden = false
        angleLabel.isHidden = false
        
        velocitySlider.isHidden = false
        velocityLabel.isHidden = false
        
        launchButton.isHidden = false
    }
    
    func gameOver() {
        let gameOverLabel = UILabel()
        gameOverLabel.textAlignment = .center
        gameOverLabel.numberOfLines = 0
        gameOverLabel.translatesAutoresizingMaskIntoConstraints = false
        gameOverLabel.font = .systemFont(ofSize: 30, weight: .bold)
        gameOverLabel.backgroundColor = .black
        gameOverLabel.textColor = .white
        gameOverLabel.text = "GAME OVER \n Player\(player1Score > player2Score ? "1" : "2") won!"
        gameOverLabel.sizeToFit()
        
        view.addSubview(gameOverLabel)
        gameOverLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        gameOverLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func updateWindLabel(dx: CGFloat, dy: CGFloat) {
        windLabel.text = "Wind\ndx: \(Int(dx))\ndy: \(Int(dy))"
    }
    
}
