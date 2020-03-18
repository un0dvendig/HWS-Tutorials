//
//  ViewController.swift
//  Project 02. Guess the flag
//
//  Created by Eugene Ilyin on 29/08/2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import UIKit
import UserNotifications

// Mark: Extensions

extension String {
    func capitalizeFirst() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}

class ViewController: UIViewController {
    // MARK: - Properties
    var highScore = 0
    var center = UNUserNotificationCenter.current()
    
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
        
        registerLocalNotifications()
        scheduleLocalNotification()
        
        let defaults = UserDefaults.standard
        highScore = defaults.integer(forKey: "previousHighScore")
        
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
        
        UIView.animate(withDuration: 0.25, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { (_) in
            UIView.animate(withDuration: 0.25, animations: {
                sender.transform = .identity
            })
        }
        
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
            
            if score > highScore {
                let ac = UIAlertController(title: "Congrats! New high score!", message: "Your final score is \(score)", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Finish", style: .default, handler: askQuestion))
                
                highScore = score
                save()
                
                present(ac, animated: true)
            } else {
                let ac = UIAlertController(title: title, message: "Your final score is \(score)", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Finish", style: .default, handler: askQuestion))
                present(ac, animated: true)
            }
        }
    }
    
    func save() {
        let defaults = UserDefaults.standard
        defaults.set(highScore, forKey: "previousHighScore")
    }
    
    func registerLocalNotifications() {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh!")
            }
        }
    }
    
    func scheduleLocalNotification() {
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Come back dude"
        content.body = "Come back and play diz game"
        
        var dateComponents = DateComponents()
        dateComponents.day = 7
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
}

