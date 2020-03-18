//
//  GameScene.swift
//  Project 23. Swifty Ninja
//
//  Created by Eugene Ilyin on 29.11.2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import AVFoundation
import SpriteKit

enum ForceBomb {
    case never, always, random
}

enum SequenceType: CaseIterable {
    case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain
}

class GameScene: SKScene {
    // MARK: - Constants
    let yPositionBelowTheScreenToRemoveNode: CGFloat = -140
    let yPositionBelowTheScreenToCreateNode: Int = -128
    let xPositionLeftPartOfTheScreen: CGFloat = 256
    let xPositionMiddlePartOfTheScreen: CGFloat = 512
    let xPositionRightPartOfTheScreen: CGFloat = 768
    
    let xRandomPositionMin: Int = 64
    let xRandomPositionMax: Int = 960
    
    let xRandomVelocityMinNormal: Int = 3
    let xRandomVelocityMaxNormal: Int = 5
    let xRandomVelocityMinFast: Int = 8
    let xRandomVelocityMaxFast: Int = 15
    let yRandomVelocityMinNormal: Int = 24
    let yRandomVelocityMaxNormal: Int = 32
    
    let normalVelocityMultiplier: Int = 40
    let fastVelocityMultiplier: Int = 45
    
    // MARK: - Properties
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    var lives = 3
    var activeSlipePoints = [CGPoint]()
    var isSwooshSoundActive = false
    var bombSoundEffect: AVAudioPlayer?
    var popupTime = 0.9
    var sequence = [SequenceType]()
    var sequencePosition = 0
    var chainDelay = 3.0
    var nextSequenceQueued = true
    var isGameEnded = false
    
    // MARK: - Outlets
    var gameScore: SKLabelNode!
    var livesImages = [SKSpriteNode]()
    var activeSliceBG: SKShapeNode! // background
    var activeSliceFG: SKShapeNode! // foreground
    var activeEnemies = [SKSpriteNode]()
    
    // MARK: - Scene Life Cycle
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: xPositionMiddlePartOfTheScreen,
                                      y: 384)
        background.zPosition = -1
        addChild(background)
        
        physicsWorld.gravity = CGVector(dx: 0,
                                        dy: -6)
        physicsWorld.speed = 0.85
        
        createScore()
        createLives()
        createSlices()
        
        sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain]
        
        for _ in 0...1000 {
            if let nextSequence = SequenceType.allCases.randomElement() {
                sequence.append(nextSequence)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.tossEnemies()
        }
    }
    
    // MARK: - Scene Methods
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isGameEnded == false else { return }
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        activeSlipePoints.append(location)
        redrawActiveSlice()
        
        if !isSwooshSoundActive {
            playSwooshSound()
        }
        
        let nodesAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtPoint {
            if node.name == "enemy" || node.name == "fastEnemy" {
                // destroy the penguin
                if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
                    emitter.position = node.position
                    addChild(emitter)
                }
                
                node.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                let seq = SKAction.sequence([group, .removeFromParent()])
                node.run(seq)
                
                if node.name == "fastEnemy" {
                    score += 100
                } else {
                    score += 1
                }
                node.name = ""
                
                if let index = activeEnemies.firstIndex(of: node) {
                    activeEnemies.remove(at: index)
                }
                
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            } else if node.name == "bomb" {
                // destroy the bomb
                guard let bombContainer = node.parent as? SKSpriteNode else { continue }
                
                if let emitter = SKEmitterNode(fileNamed: "sliceHitBomb") {
                    emitter.position = bombContainer.position
                    addChild(emitter)
                }
                
                node.name = ""
                
                bombContainer.physicsBody?.isDynamic = false
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                let seq = SKAction.sequence([group, .removeFromParent()])
                bombContainer.run(seq)
                
                if let index = activeEnemies.firstIndex(of: node) {
                    activeEnemies.remove(at: index)
                }
                
                run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
                endGame(triggeredByBomb: true)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        activeSlipePoints.removeAll(keepingCapacity: true)
        
        let location = touch.location(in: self)
        activeSlipePoints.append(location)
        
        redrawActiveSlice()
        
        activeSliceBG.removeAllActions()
        activeSliceFG.removeAllActions()
        activeSliceBG.alpha = 1
        activeSliceFG.alpha = 1
    }
    
    override func update(_ currentTime: TimeInterval) {
        if activeEnemies.count > 0 {
            for (index, node) in activeEnemies.enumerated().reversed() {
                if node.position.y < yPositionBelowTheScreenToRemoveNode {
                    node.removeAllActions()
                    
                    if node.name == "enemy" || node.name == "fastEnemy" {
                        node.name = ""
                        
                        substractLife()
                        
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    } else if node.name == "bombContainer" {
                        node.name = ""
                        
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    }
                }
            }
        } else {
            if !nextSequenceQueued {
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [weak self] in
                    self?.tossEnemies()
                }
                
                nextSequenceQueued = true
            }
        }
        
        var bombCount = 0
        
        for node in activeEnemies {
            if node.name == "bombContainer" {
                bombCount += 1
                break
            }
        }
        
        if bombCount == 0 {
            // no bombs - stop the fuse sound!
            bombSoundEffect?.stop()
            bombSoundEffect = nil
        }
    }
    
    // MARK: - Methods
    func createScore() {
        gameScore = SKLabelNode(fontNamed : "Chalkduster")
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        gameScore.position = CGPoint(x: 8, y: 8)
        score = 0
    }
    
    func createLives() {
        for i in 0..<3 {
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
            spriteNode.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720)
            addChild(spriteNode)
            livesImages.append(spriteNode)
        }
    }
    
    func createSlices() {
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2
        
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 3
        
        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 9
        
        activeSliceFG.strokeColor = .white
        activeSliceFG.lineWidth = 5
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }
    
    func redrawActiveSlice() {
        if activeSlipePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }
        
        if activeSlipePoints.count > 12 {
            activeSlipePoints.removeFirst(activeSlipePoints.count - 12)
        }
        
        let path = UIBezierPath()
        path.move(to: activeSlipePoints[0])
        
        for i in 1..<activeSlipePoints.count {
            path.addLine(to: activeSlipePoints[i])
        }
        
        activeSliceBG.path = path.cgPath
        activeSliceFG.path = path.cgPath
    }
    
    func playSwooshSound() {
        isSwooshSoundActive = true
        
        let randomNumber = Int.random(in: 1...3)
        let soundName = "swoosh\(randomNumber).caf"
        
        let swooshSound = SKAction.playSoundFileNamed(soundName,
                                                      waitForCompletion: true)
        
        run(swooshSound) { [weak self] in
            self?.isSwooshSoundActive = false
        }
    }
    
    func createEnemy(forceBomb: ForceBomb = .random) {
        let enemy: SKSpriteNode
        
        var enemyType = Int.random(in: 0...6)
        
        if forceBomb == .never {
            enemyType = 1
        } else if forceBomb == .always {
            enemyType == 0
        }
        
        if enemyType == 0 {
            enemy = SKSpriteNode()
            enemy.zPosition = 1
            enemy.name = "bombContainer"
            
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)
            
            if bombSoundEffect != nil {
                bombSoundEffect?.stop()
                bombSoundEffect = nil
            }
            
            if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf") {
                if let sound = try? AVAudioPlayer(contentsOf: path) {
                    bombSoundEffect = sound
                    sound.play()
                }
            }
            
            if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
                emitter.position = CGPoint(x: 76, y: 64)
                enemy.addChild(emitter)
            }
            
        } else if enemyType == 6 {
            enemy = SKSpriteNode(imageNamed: "penguin")
            
            addGlow(node: enemy)
            
            run(SKAction.playSoundFileNamed("launch.caf",
                                            waitForCompletion: false))
            enemy.name = "fastEnemy"
        }
        else {
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(SKAction.playSoundFileNamed("launch.caf",
                                            waitForCompletion: false))
            enemy.name = "enemy"
        }
        
        let randomPosition = CGPoint(x: Int.random(in: xRandomPositionMin...xRandomPositionMax),
                                     y: yPositionBelowTheScreenToCreateNode)
        enemy.position = randomPosition
        
        let randomAngularVelocity = CGFloat.random(in: -3...3)
        let randomXVelocity: Int
        
        if randomPosition.x < xPositionLeftPartOfTheScreen {
            randomXVelocity = Int.random(in: xRandomVelocityMinFast...xRandomVelocityMaxFast)
        } else if randomPosition.x < xPositionMiddlePartOfTheScreen {
            randomXVelocity = Int.random(in: xRandomVelocityMinNormal...xRandomVelocityMaxNormal)
        } else if randomPosition.x < xPositionRightPartOfTheScreen {
            randomXVelocity = -Int.random(in: xRandomVelocityMinNormal...xRandomVelocityMaxNormal)
        } else {
            randomXVelocity = -Int.random(in: xRandomVelocityMinFast...xRandomVelocityMaxFast)
        }
        
        let randomYVelocity = Int.random(in: yRandomVelocityMinNormal...yRandomVelocityMaxNormal)
        
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        if enemy.name == "fastEnemy" {
            enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * fastVelocityMultiplier,
                                                   dy: randomYVelocity * fastVelocityMultiplier)
        } else {
            enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * normalVelocityMultiplier,
                                                   dy: randomYVelocity * normalVelocityMultiplier)
        }
        
        enemy.physicsBody?.angularVelocity = randomAngularVelocity
        enemy.physicsBody?.collisionBitMask = 0
        
        addChild(enemy)
        activeEnemies.append(enemy)
    }
    
    func tossEnemies() {
        guard isGameEnded == false else { return }
        
        popupTime *= 0.991
        chainDelay *= 0.99
        physicsWorld.speed *= 1.02
        
        let sequenceType = sequence[sequencePosition]
        
        switch sequenceType {
        case .oneNoBomb:
            createEnemy(forceBomb: .never)
            
        case .one:
            createEnemy()
            
        case .twoWithOneBomb:
            createEnemy(forceBomb: .never)
            createEnemy(forceBomb: .always)
            
        case .two:
            createEnemy()
            createEnemy()
            
        case .three:
            createEnemy()
            createEnemy()
            createEnemy()
            
        case .four:
            createEnemy()
            createEnemy()
            createEnemy()
            createEnemy()
            
        case .chain:
            createEnemy()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0)) { [weak self] in
                self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 2)) { [weak self] in
                self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 3)) { [weak self] in
                self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 4)) { [weak self] in
                self?.createEnemy()
            }
            
        case .fastChain:
            createEnemy()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0)) { [weak self] in
                self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 2)) { [weak self] in
                self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 3)) { [weak self] in
                self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 4)) { [weak self] in
                self?.createEnemy()
            }
        }
        sequencePosition += 1
        nextSequenceQueued = false
    }
    
    
    func endGame(triggeredByBomb: Bool) {
        guard isGameEnded == false else { return }
        
        isGameEnded = true
        physicsWorld.speed = 0
        isUserInteractionEnabled = false
        
        bombSoundEffect?.stop()
        bombSoundEffect = nil
        
        if triggeredByBomb {
            livesImages[0].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[1].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[2].texture = SKTexture(imageNamed: "sliceLifeGone")
        }
        
        let endGameLabel = SKLabelNode(fontNamed : "Chalkduster")
        endGameLabel.text = "GAME OVER"
        endGameLabel.fontSize = 100
        endGameLabel.position = CGPoint(x: 512, y: 384)
        addChild(endGameLabel)
    }
    
    func substractLife() {
        lives -= 1
        
        run(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))
        
        var life: SKSpriteNode
        
        if lives == 2 {
            life = livesImages[0]
        } else if lives == 1 {
            life = livesImages[1]
        } else {
            life = livesImages[2]
            endGame(triggeredByBomb: false)
        }
        
        life.texture = SKTexture(imageNamed: "sliceLifeGone")
        life.xScale = 1.3
        life.yScale = 1.3
        life.run(SKAction.scale(to: 1, duration: 0.1))
    }
    
    func addGlow(node: SKSpriteNode,
                 radius: CGFloat = 30) {
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        node.addChild(effectNode)
        effectNode.addChild(SKSpriteNode(texture: node.texture))
        effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": radius])
    }
    
}
