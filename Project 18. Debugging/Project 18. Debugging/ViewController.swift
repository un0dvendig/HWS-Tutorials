//
//  ViewController.swift
//  Project 18. Debugging
//
//  Created by Eugene Ilyin on 23.11.2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print("I'm inside the viewDidLoad() method.")
//        print(1, 2, 3, 4, 5, separator: "-")
//        print("Some message", terminator: "")
//        print(" khm")
        
//        assert(1 == 1, "Math failure!")
//        assert(1 == 2, "Math failure!")
//        assert(myReallySlowMethods() == true, "The slow method returned false, which is a bad thing.")
        
        for i in 1...100 {
            print("Got number \(i).")
        }
    }


}

