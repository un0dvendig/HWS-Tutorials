//
//  ViewController.swift
//  Project 06a. Auto Layout
//
//  Created by Eugene Ilyin on 29/08/2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import UIKit

// Mark: Extensions

extension String {
    func capitalizeFirst() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}

class ViewController: UIViewController {
    
    // Mark: Outlets
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    // Mark: Options
    var countries = [String]()
    var correctAnswer = 0
    var score = 0
    var questionsAsked = 0
    
    // Mark: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showScore))
        
        askQuestion()
    }

    @objc func showScore() {
        let playerScore = "Your score is \(score)"
        let vc = UIActivityViewController(activityItems: [playerScore], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    func askQuestion(action: UIAlertAction! = nil) {
        countries.shuffle()
        
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        
        correctAnswer = Int.random(in: 0...2)
        
        title = "Country: \(countries[correctAnswer].uppercased()) | Your Score is \(score)"
    }

    // Mark: Actions
    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String
        
        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
        } else {
            // TODO: Write extension to String to capitalize first letter
            if countries[sender.tag].count <= 3 {
                title = "Wrong! That's the flag of \(countries[sender.tag].uppercased())"
            } else {
                title = "Wrong! That's the flag of \(countries[sender.tag].capitalizeFirst())"
            }
            
            score -= 1
        }
        
        if questionsAsked < 9 {
            questionsAsked += 1
            print("Question №\(questionsAsked) has been asked")
            
            let ac = UIAlertController(title: title, message: "Your score is \(score)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
            present(ac, animated: true)
        } else if questionsAsked == 9 {
            questionsAsked += 1
            print("Question №\(questionsAsked) has been asked")
            
            let ac = UIAlertController(title: title, message: "Your final score is \(score)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Finish", style: .default, handler: askQuestion))
            present(ac, animated: true)
        }
    }
}

