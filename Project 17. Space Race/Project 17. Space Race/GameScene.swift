//
//  GameScene.swift
//  Project 17. Space Race
//
//  Created by Eugene Ilyin on 22.11.2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Properties
    var starField: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    var possibleEnemies = ["ball", "hammer", "tv"]
    var gameTimer: Timer?
    var isGameOver = false
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    // MARK: - View Life Cycle
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        starField = SKEmitterNode(fileNamed: "starfield")!
        starField.position = CGPoint(x: 1024, y: 384)
        starField.advanceSimulationTime(10)
        addChild(starField)
        starField.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.35,
                                         target: self,
                                         selector: #selector(createEnemy),
                                         userInfo: nil,
                                         repeats: true)
        
        gameTimer?.fireDate = Date.init(timeInterval: timeInterval, since: Date())
    }
    var timeInterval: TimeInterval = 1.0
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position = location
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let expostion = SKEmitterNode(fileNamed: "explosion")!
        expostion.position = player.position
        addChild(expostion)
        
        player.removeFromParent()
        gameTimer?.invalidate()
        isGameOver = true
    }
    
    // MARK: - Methods
    var enemies = 0
    @objc
    func createEnemy() {
        enemies += 1
        
        if enemies % 20 == 0 && timeInterval - 0.1 != 0{
            gameTimer?.invalidate()
            timeInterval -= 0.1
            
            // TODO: Is there a way to customize current timer?
            gameTimer = Timer.scheduledTimer(timeInterval: 0.35,
                                             target: self,
                                             selector: #selector(createEnemy),
                                             userInfo: nil,
                                             repeats: true)
            
            gameTimer?.fireDate = Date.init(timeInterval: timeInterval, since: Date())
            gameTimer?.fire()
        }
        
        guard let enemy = possibleEnemies.randomElement() else { return }
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200,
                                  y: Int.random(in: 50...736))
        addChild(sprite)
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!,
                                           size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
    }
}
