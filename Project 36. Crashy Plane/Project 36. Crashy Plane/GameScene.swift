//
//  GameScene.swift
//  Project 36. Crashy Plane
//
//  Created by Eugene Ilyin on 23.12.2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import SpriteKit

enum GameState {
    case showingLogo
    case playing
    case dead
}

class GameScene: SKScene {
    
    // MARK: - Properties
    var gameState = GameState.showingLogo
    var score = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }
    let rockTexture = SKTexture(imageNamed: "rock")
    var rockPhysics: SKPhysicsBody!
    
    // MARK: - Nodes
    var backgroundMusic: SKAudioNode!
    let explosion = SKEmitterNode(fileNamed: "PlayerExplosion")!
    var logo: SKSpriteNode!
    var gameOver: SKSpriteNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    // MARK: - View life cycle
    override func didMove(to view: SKView) {
        createPlayer()
        createSky()
        createBackground()
        createGround()
        createScore()
        
        rockPhysics = SKPhysicsBody(texture: rockTexture,
                                    size: rockTexture.size())
        
        physicsWorld.gravity = CGVector(dx: 0.0,
                                        dy: -5.0)
        physicsWorld.contactDelegate = self
        
        guard let musicURL = Bundle.main.url(forResource: "music", withExtension: "m4a") else { return}
        backgroundMusic = SKAudioNode(url: musicURL)
        addChild(backgroundMusic)
        
        createLogos()
    }
    
    // MARK: - SKScene methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        switch gameState {
        case .showingLogo:
            gameState = .playing
            
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            let wait = SKAction.wait(forDuration: 0.5)
            let activatePlayer = SKAction.run { [unowned self] in
                self.player.physicsBody?.isDynamic = true
                self.scoreLabel.alpha = 1
                self.startRocks()
            }
            
            let sequence = SKAction.sequence([fadeOut, wait, activatePlayer, remove])
            logo.run(sequence)
            
        case .playing:
            player.physicsBody?.velocity = CGVector(dx: 0,
                                                    dy: 0)
            player.physicsBody?.applyImpulse(CGVector(dx: 0,
                                                      dy: 20))
            
        case .dead:
            guard let scene = GameScene(fileNamed: "GameScene") else { return }
            scene.scaleMode = .aspectFill
            let transition = SKTransition.moveIn(with: .right,
                                                 duration: 1)
            view?.presentScene(scene,
                               transition: transition)
        }
        

    }
    
    override func update(_ currentTime: TimeInterval) {
        guard player != nil else { return }
        
        let value = player.physicsBody!.velocity.dy * 0.001
        let rotate = SKAction.rotate(toAngle: value,
                                     duration: 0.1)
        
        player.run(rotate)
    }
    
    // MARK: - Private methods
    private func createPlayer() {
        let playerTexture = SKTexture(imageNamed: "player-1")
        player = SKSpriteNode(texture: playerTexture)
        player.zPosition = 10
        player.position = CGPoint(x: frame.width / 6,
                                  y: frame.height * 0.75)
        
        addChild(player)
        
        player.physicsBody = SKPhysicsBody(texture: playerTexture,
                                           size: playerTexture.size())
        player.physicsBody!.contactTestBitMask = player.physicsBody!.collisionBitMask
        player.physicsBody?.isDynamic = false
        
        player.physicsBody?.collisionBitMask = 0
        
        let frame2 = SKTexture(imageNamed: "player-2")
        let frame3 = SKTexture(imageNamed: "player-3")
        let animation = SKAction.animate(with: [playerTexture, frame2, frame3],
                                         timePerFrame: 0.01)
        let runForever = SKAction.repeatForever(animation)
        
        player.run(runForever)
    }
    
    private func createSky() {
        let topSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.14, brightness: 0.97, alpha: 1),
                                  size: CGSize(width: frame.width, height: frame.height * 0.67))
        topSky.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        let bottomSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.16, brightness: 0.96, alpha: 1),
                                     size: CGSize(width: frame.width, height: frame.height * 0.33))
        bottomSky.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        topSky.position = CGPoint(x: frame.midX, y: frame.height)
        bottomSky.position = CGPoint(x: frame.midX, y: bottomSky.frame.height)
        
        addChild(topSky)
        addChild(bottomSky)
        
        bottomSky.zPosition = -40
        topSky.zPosition = -40
    }
    
    private func createBackground() {
        let backgroundTexture = SKTexture(imageNamed: "background")
        
        for i in 0 ... 1 {
            let background = SKSpriteNode(texture: backgroundTexture)
            background.zPosition = -30
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: (backgroundTexture.size().width * CGFloat(i)) - CGFloat(1 * i),
                                          y: 100)
            addChild(background)
            
            let moveLeft = SKAction.moveBy(x: -backgroundTexture.size().width,
                                           y: 0,
                                           duration: 20)
            let moveReset = SKAction.moveBy(x: backgroundTexture.size().width,
                                            y: 0,
                                            duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            background.run(moveForever)
        }
    }
    
    private func createGround() {
        let groundTexture = SKTexture(imageNamed: "ground")
        
        for i in 0 ... 1 {
            let ground = SKSpriteNode(texture: groundTexture)
            ground.zPosition = -10
            ground.position = CGPoint(x: (groundTexture.size().width / 2.0 + (groundTexture.size().width * CGFloat(i))),
                                      y: groundTexture.size().height / 2)
            
            ground.physicsBody = SKPhysicsBody(texture: ground.texture!,
                                               size: ground.texture!.size())
            ground.physicsBody?.isDynamic = false
            
            addChild(ground)
            
            let moveLeft = SKAction.moveBy(x: -groundTexture.size().width,
                                           y: 0,
                                           duration: 5)
            let moveReset = SKAction.moveBy(x: groundTexture.size().width,
                                            y: 0,
                                            duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            ground.run(moveForever)
        }
    }
    
    private func createRocks() {
//        let rockTexture = Bool.random() ? SKTexture(imageNamed: "rock") : SKTexture(imageNamed: "pipe")
        let rockTexture = Bool.random() ? SKTexture(imageNamed: "rock") : SKTexture(imageNamed: "rock")
        
        let topRock = SKSpriteNode(texture: rockTexture)
        topRock.physicsBody = rockPhysics.copy() as? SKPhysicsBody
        topRock.physicsBody?.isDynamic = false
        topRock.zRotation = .pi
        topRock.xScale = -1.0
        
        let bottomRock = SKSpriteNode(texture: rockTexture)
        bottomRock.physicsBody = rockPhysics.copy() as? SKPhysicsBody
        bottomRock.physicsBody?.isDynamic = false
        
        topRock.zPosition = -20
        bottomRock.zPosition = -20
        
        let rockCollision = SKSpriteNode(color: .clear,
                                         size: CGSize(width: 32, height: frame.height))
        
        rockCollision.physicsBody = SKPhysicsBody(rectangleOf: rockCollision.size)
        rockCollision.physicsBody?.isDynamic = false
        rockCollision.name = "scoreDetect"
        
        addChild(topRock)
        addChild(bottomRock)
        addChild(rockCollision)
        
        let xPosition = frame.width + topRock.frame.width
        
        let max = CGFloat(frame.height / 3)
        let yPosition = CGFloat.random(in: -50 ... max)
        
        /// this value affects the width of the gap between rocks
        let rockDistance: CGFloat = 70
        
        topRock.position = CGPoint(x: xPosition,
                                   y: yPosition + topRock.size.height + rockDistance)
        bottomRock.position = CGPoint(x: xPosition,
                                      y: yPosition - rockDistance)
        rockCollision.position = CGPoint(x: xPosition + (rockCollision.size.width * 2),
                                         y: frame.midY)
        
        let endPosition = frame.width + (topRock.frame.width * 2)
        
        let moveAction = SKAction.moveBy(x: -endPosition, y: 0, duration: 6.2)
        let moveSequence = SKAction.sequence([moveAction, SKAction.removeFromParent()])
        
        topRock.run(moveSequence)
        bottomRock.run(moveSequence)
        rockCollision.run(moveSequence)
    }
    
    private func startRocks() {
        let create = SKAction.run { [unowned self] in
            self.createRocks()
        }
        
        let wait = SKAction.wait(forDuration: 3)
        let sequence = SKAction.sequence([create, wait])
        let repeatForever = SKAction.repeatForever(sequence)
        
        run(repeatForever)
    }
    
    private func createScore() {
        scoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        scoreLabel.fontSize = 24
        
        scoreLabel.position = CGPoint(x: frame.midX,
                                      y: frame.maxY - 60)
        scoreLabel.text = "SCORE: 0"
        scoreLabel.fontColor = .black
        scoreLabel.alpha = 0
        
        addChild(scoreLabel)
    }
    
    private func createLogos() {
        logo = SKSpriteNode(imageNamed: "logo")
        logo.position = CGPoint(x: frame.midX,
                                y: frame.midY)
        addChild(logo)
        
        gameOver = SKSpriteNode(imageNamed: "gameover")
        gameOver.position = CGPoint(x: frame.midX,
                                    y: frame.midY)
        gameOver.alpha = 0
        addChild(gameOver)
    }
}

// MARK: - SKPhysicsContactDelegate methods
extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "scoreDetect" || contact.bodyB.node?.name == "scoreDetect" {
            if contact.bodyA.node == player {
                contact.bodyB.node?.removeFromParent()
            } else {
                contact.bodyA.node?.removeFromParent()
            }
            
            let sound = SKAction.playSoundFileNamed("coin.wav",
                                                    waitForCompletion: false)
            run(sound)
            
            score += 1
            
            return
        }
        
        guard contact.bodyA.node != nil && contact.bodyB.node != nil else { return }
        
        if contact.bodyA.node == player || contact.bodyB.node == player {
            explosion.position = player.position
            addChild(explosion)
            
            let sound = SKAction.playSoundFileNamed("explosion.wav",
                                                    waitForCompletion: false)
            run(sound)
            
            gameOver.alpha = 1
            gameState = .dead
            backgroundMusic.run(SKAction.stop())
            
            player.removeFromParent()
            speed = 0
        }
    }
}
