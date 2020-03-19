//
//  GradientView.swift
//  Project 37. Psychic Tester
//
//  Created by Eugene Ilyin on 31.12.2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {

    @IBInspectable var topColor: UIColor = UIColor.white
    @IBInspectable var bottomColor: UIColor = UIColor.black
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        (layer as! CAGradientLayer).colors = [topColor.cgColor, bottomColor.cgColor]
    }

}
