//
//  ViewController.swift
//  Project 37. Psychic Tster
//
//  Created by Eugene Ilyin on 31.12.2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import AVFoundation
import UIKit
import WatchConnectivity

class ViewController: UIViewController {

    // MARK: - Properties
    var allCards = [CardViewController]()
    var music: AVAudioPlayer!
    var lastMessage: CFAbsoluteTime = 0
    
    // MARK: - Outlets
    @IBOutlet weak var cardContainer: UIView!
    @IBOutlet weak var gradientView: GradientView!
    
    // MARK: - View life cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let instructions = "Please ensure your Apple Watch is configured correctly. On your iPhone, launch Apple's 'Watch' configuration app then choose General > Wake Screen. On that screen, please disable Wake Screen On Wrist Raise, then select Wake For 70 Seconds. On you Apple Watch, please swipe up on your watch face and enable Silent Mode. You're done!"
        let ac = UIAlertController(title: "Adjust your settings",
                                   message: instructions,
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "I'm ready",
                                   style: .default))
        present(ac,
                animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createParticles()
        
        loadCards()
        
        view.backgroundColor = .red
        UIView.animate(withDuration: 20, delay: 0, options: [.allowUserInteraction, .autoreverse, .repeat], animations: {
            self.view.backgroundColor = .blue
        })
        
        playMusic()
        
        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    // MARK: - View Controller Methods
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: cardContainer)
        
        for card in allCards {
            if card.view.frame.contains(location) {
                if view.traitCollection.forceTouchCapability == .available {
                    if touch.force == touch.maximumPossibleForce {
                        card.front.image = UIImage(named: "cardStar")
                        card.isCorrect = true
                    }
                }
                
                if card.isCorrect {
                    sendWatchMessage()
                }
            }
        }
    }

    // MARK: - Methods
    @objc
    func loadCards() {
        // Remove any existing cards
        for card in allCards {
            card.view.removeFromSuperview()
            card.removeFromParent()
        }
        allCards.removeAll(keepingCapacity: true)
        
        // Card positions
        let positions = [
            CGPoint(x: 75, y: 85),
            CGPoint(x: 185, y: 85),
            CGPoint(x: 295, y: 85),
            CGPoint(x: 405, y: 85),
            CGPoint(x: 75, y: 235),
            CGPoint(x: 185, y: 235),
            CGPoint(x: 295, y: 235),
            CGPoint(x: 405, y: 235)
        ]
        
        // Load and unwrap Zener card images
        let circle = UIImage(named: "cardCircle")!
        let cross = UIImage(named: "cardCross")!
        let lines = UIImage(named: "cardLines")!
        let square = UIImage(named: "cardSquare")!
        let star = UIImage(named: "cardStar")!
        
        var images = [circle, circle, cross, cross, lines, lines, square, star]
        images.shuffle()
        
        for (index, position) in positions.enumerated() {
            let card = CardViewController()
            card.delegate = self
            
            // Use view controller containment and also add the card's view to out cardContainer view
            addChild(card)
            cardContainer.addSubview(card.view)
            card.didMove(toParent: self)
            
            // Position the card appropriately, then give it an image from out array
            card.view.center = position
            card.front.image = images[index]
            
            // If we just gave the new card the start image, mark this as the correct answer
            if card.front.image == star {
                card.isCorrect = true
            }
            
            // Add the new card view controller to out array for easier tracking
            allCards.append(card)
        }
        
        view.isUserInteractionEnabled = true
    }
    
    func cardTapped(_ tapped: CardViewController) {
        guard view.isUserInteractionEnabled == true else { return }
        view.isUserInteractionEnabled = false
        
        for card in allCards {
            if card == tapped {
                card.wasTapped()
                card.perform(#selector(card.wasntTapped),
                             with: nil,
                             afterDelay: 1)
            } else {
                card.wasntTapped()
            }
        }
        
        perform(#selector(loadCards),
                with: nil,
                afterDelay: 2)
    }
    
    func createParticles() {
        let particleEmitter = CAEmitterLayer()
        
        particleEmitter.emitterPosition = CGPoint(x: view.frame.width / 2.0,
                                                  y: -50)
        particleEmitter.emitterShape = .line
        particleEmitter.emitterSize = CGSize(width: view.frame.width,
                                             height: 1)
        particleEmitter.renderMode = .additive
        
        let cell = CAEmitterCell()
        cell.birthRate = 2
        cell.lifetime = 5.0
        cell.velocity = 100
        cell.velocityRange = 50
        cell.emissionLongitude = .pi
        cell.spinRange = 5
        cell.scale = 0.5
        cell.scaleRange = 0.25
        cell.color = UIColor(white: 1, alpha: 0.1).cgColor
        cell.alphaSpeed = -0.025
        cell.contents = UIImage(named: "particle")?.cgImage
        particleEmitter.emitterCells = [cell]
        
        gradientView.layer.addSublayer(particleEmitter)
    }
    
    func playMusic() {
        guard let musicURL = Bundle.main.url(forResource: "PhantomFromSpace", withExtension: "mp3") else { return }
        guard let audioPlayer = try? AVAudioPlayer(contentsOf: musicURL) else { return }
        music = audioPlayer
        music.numberOfLoops = -1
        music.play()
    }
    
    func sendWatchMessage() {
        let currentTime = CFAbsoluteTimeGetCurrent()
        
        // If less than a half a second has passed, bail out
        if lastMessage + 0.5 > currentTime {
            return
        }
        // Send a message to the watch if it's reachable
        if (WCSession.default.isReachable) {
            // Meaningless message
            let message = ["Message" : "Hello"]
            WCSession.default.sendMessage(message,
                                          replyHandler: nil)
        }
        
        // Update our rate limiting property
        lastMessage = CFAbsoluteTimeGetCurrent()
    }
}

// MARK: - WCSessionDelegate Methods
extension ViewController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    
}
