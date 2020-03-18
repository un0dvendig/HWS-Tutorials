//
//  ViewController.swift
//  Project 27. Core Graphics
//
//  Created by Eugene Ilyin on 30.11.2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Properties
    private var currentDrawType = 0
    
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func redrawTapped(_ sender: UIButton) {
        currentDrawType += 1
        
        if currentDrawType > 8 {
            currentDrawType = 0
        }
        
        switch currentDrawType {
        case 0:
            drawRectange()
            
        case 1:
            drawCircle()
            
        case 2:
            drawCheckerboard()
            
        case 3:
            drawRotatedSquares()
            
        case 4:
            drawLines()
            
        case 5:
            drawImagesAndText()
            
        case 6:
            draw😐()
            
        case 7:
            drawLightning()
            
        case 8:
            drawTWIN()
            
        default:
            break
        }
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        drawRectange()
    }

    // MARK: - Private Methods
    private func drawRectange() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512)) // canvas + metadata
        
        let image = renderer.image { (context) in
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512)
            
            context.cgContext.setFillColor(UIColor.red.cgColor)
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.setLineWidth(10) // 5 inside and 5 outside
            
            context.cgContext.addRect(rectangle)
            context.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = image
    }
    
    private func drawCircle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512)) // canvas + metadata
        
        let image = renderer.image { (context) in
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 5, dy: 5)
            
            context.cgContext.setFillColor(UIColor.red.cgColor)
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.setLineWidth(10) // 5 inside and 5 outside
            
            context.cgContext.addEllipse(in: rectangle)
            context.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = image
    }
    
    private func drawCheckerboard() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512)) // canvas + metadata
        
        let image = renderer.image { (context) in
            context.cgContext.setFillColor(UIColor.black.cgColor)
            
            for row in 0 ..< 8 {
                for column in 0 ..< 8 {
                    if (row + column) % 2 == 0 {
                        context.cgContext.fill(CGRect(x: column * 64, y: row * 64,
                                                      width: 64, height: 64)) // 64 * 8 = 512
                    }
                }
            }
        }
        
        imageView.image = image
    }
    
    private func drawRotatedSquares() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512)) // canvas + metadata
        
        let image = renderer.image { (context) in
            context.cgContext.translateBy(x: 256, y: 256) // to draw and rotate from the center, not from top-left corner
            
            let rotations = 16
            let amount = Double.pi / Double(rotations)
            
            for _ in 0 ..< rotations {
                context.cgContext.rotate(by: CGFloat(amount))
                context.cgContext.addRect(CGRect(x: -128, y: -128, // since drawing from the center
                                                 width: 256, height: 256))
            }
            
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.strokePath()
        }
        
        imageView.image = image
    }
    
    private func drawLines() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512)) // canvas + metadata
        
        let image = renderer.image { (context) in
            context.cgContext.translateBy(x: 256, y: 256) // draw from the center of the canvas
            
            var first = true
            var length: CGFloat = 256
            
            for _ in 0 ..< 256 {
                // here
                context.cgContext.rotate(by: .pi / 2)
                if first {
                    context.cgContext.move(to: CGPoint(x: length, y: 50))
                    first = false
                } else {
                    context.cgContext.addLine(to: CGPoint(x: length, y: 50))
                }
                
                length *= 0.99
            }
            
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.strokePath()
        }
        
        imageView.image = image
    }
    
    private func drawImagesAndText() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512)) // canvas + metadata
        
        let image = renderer.image { (context) in
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36),
                .paragraphStyle: paragraphStyle
            ]
            
            let string = "The best-laid schemes o'\nmice an' men gang aft agley"
            
            let attributedString = NSAttributedString(string: string, attributes: attributes)
            
            attributedString.draw(with: CGRect(x: 32, y: 32,
                                               width: 448, height: 448),
                                  options: .usesLineFragmentOrigin,
                                  context: nil)
            
            let mouse = UIImage(named: "mouse")
            mouse?.draw(at: CGPoint(x: 300, y: 150))
        }
        
        imageView.image = image
    }
    
    private func draw😐() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512)) // canvas + metadata
        
        let image = renderer.image { (context) in
            context.cgContext.translateBy(x: 256, y: 256) // draw from the center of the canvas
                    
            // face
            context.cgContext.setFillColor(UIColor.yellow.cgColor)
            context.cgContext.fillEllipse(in: CGRect(x: -128, y: -128,
                                                     width: 256, height: 256))
            
            // eyes
            context.cgContext.setFillColor(UIColor.brown.cgColor)
            context.cgContext.fillEllipse(in: CGRect(x: -64, y: -64,
                                                     width: 40, height: 40))
            context.cgContext.fillEllipse(in: CGRect(x: 20, y: -64,
                                                     width: 40, height: 40))
            
            // mouth
            context.cgContext.fill(CGRect(x: -64, y: 32,
                                          width: 128, height: 20))
            
        }
        
        imageView.image = image
    }

    private func drawLightning() {
        // ⚡️
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512)) // canvas + metadata
        
        let image = renderer.image { (context) in
            context.cgContext.move(to: CGPoint(x: 512, y: 0))
            context.cgContext.addLine(to: CGPoint(x: 0, y: 300))
            context.cgContext.addLine(to: CGPoint(x: 240, y: 300))
            context.cgContext.addLine(to: CGPoint(x: 0, y: 512))
            context.cgContext.addLine(to: CGPoint(x: 512, y: 240))
            context.cgContext.addLine(to: CGPoint(x: 260, y: 240))
            context.cgContext.addLine(to: CGPoint(x: 512, y: 0))
            
            context.cgContext.setStrokeColor(UIColor.brown.cgColor)
            context.cgContext.setFillColor(UIColor.yellow.cgColor)
            
            context.cgContext.drawPath(using: .fillStroke)
            
        }
        
        imageView.image = image
    }
    
    private func drawTWIN() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512)) // canvas + metadata
        
        let image = renderer.image { (context) in
            // T
            context.cgContext.move(to: CGPoint(x: 0, y: 100))
            context.cgContext.addLine(to: CGPoint(x: 100, y: 100))
            context.cgContext.move(to: CGPoint(x: 50, y: 100))
            context.cgContext.addLine(to: CGPoint(x: 50, y: 300))
            
            // W
            context.cgContext.move(to: CGPoint(x: 120, y: 100))
            context.cgContext.addLine(to: CGPoint(x: 120 + 25, y: 300))
            context.cgContext.addLine(to: CGPoint(x: 120 + 50, y: 150))
            context.cgContext.addLine(to: CGPoint(x: 120 + 75, y: 300))
            context.cgContext.addLine(to: CGPoint(x: 120 + 100, y: 100))
            
            // I
            context.cgContext.move(to: CGPoint(x: 240, y: 100))
            context.cgContext.addLine(to: CGPoint(x: 240, y: 300))
            
            // N
            context.cgContext.move(to: CGPoint(x: 260, y: 300))
            context.cgContext.addLine(to: CGPoint(x: 260, y: 100))
            context.cgContext.addLine(to: CGPoint(x: 360, y: 300))
            context.cgContext.addLine(to: CGPoint(x: 360, y: 100))
            
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            
            context.cgContext.drawPath(using: .stroke)
            
        }
        
        imageView.image = image
    }
    
}

