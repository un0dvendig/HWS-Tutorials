//
//  CardViewController.swift
//  Project 37. Psychic Tster
//
//  Created by Eugene Ilyin on 31.12.2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {

    // MARK: - Subviews
    var front: UIImageView!
    var back: UIImageView!
    
    // MARK: - Properties
    weak var delegate: ViewController!
    var isCorrect = false
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.bounds = CGRect(x: 0, y: 0, width: 100, height: 140)
        front = UIImageView(image: UIImage(named: "cardBack"))
        back = UIImageView(image: UIImage(named: "cardBack"))
        
        view.addSubview(front)
        view.addSubview(back)
        
        front.isHidden = true
        back.alpha = 0
        
        UIView.animate(withDuration: 0.2) {
            self.back.alpha = 1
        }
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(cardTapped))
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(tap)
        
        perform(#selector(wiggle),
                with: nil,
                afterDelay: 1)
    }

    // MARK: - Methods
    @objc
    func cardTapped(_ recognizer: UITapGestureRecognizer) {
        delegate.cardTapped(self)
    }
    
    @objc
    func wasntTapped() {
        UIView.animate(withDuration: 0.7) {
            self.view.transform = CGAffineTransform(scaleX: 0.00001, y: 0.00001)
            self.view.alpha = 0
        }
    }
    
    func wasTapped() {
        UIView.transition(with: view,
                          duration: 0.7,
                          options: [.transitionFlipFromRight],
                          animations: { [unowned self] in
            self.back.isHidden = true
            self.front.isHidden = false
        })
    }
    
    @objc
    func wiggle() {
        if Int.random(in: 0 ... 3) == 1 {
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: .allowUserInteraction,
                           animations: {
                self.back.transform = CGAffineTransform(scaleX: 1.01,
                                                        y: 1.01)
            }) { (_) in
                self.back.transform = .identity
            }
            
            perform(#selector(wiggle),
                    with: nil,
                    afterDelay: 8)
        } else {
            perform(#selector(wiggle),
                    with: nil,
                    afterDelay: 2)
        }
    }
    
}
