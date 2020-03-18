//
//  DetailViewController.swift
//  Project 03. Social Media
//
//  Created by Eugene Ilyin on 29/08/2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    // MARK: - Properties
    var selectedImage: String?
    var selectedImageNumber = 0
    var totalPictures = 0
    
    // MARK: Outlets
    @IBOutlet var imageView: UIImageView!
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //title = selectedImage
        title = "Picture \(selectedImageNumber) of \(totalPictures)"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        navigationItem.largeTitleDisplayMode = .never
        
        if let imageToLoad = selectedImage {
            imageView.image = UIImage(named: imageToLoad)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
    
    @objc func shareTapped() {
        guard let image = imageView.image?.jpegData(compressionQuality: 0.8) else {
            print("No image found")
            return
        }
        
        guard let originalImage = imageView.image else { return }
        let imageSize = originalImage.size
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        let imageWithText = renderer.image { (context) in
            originalImage.draw(at: CGPoint(x: 0, y: 0))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36),
                .paragraphStyle: paragraphStyle
            ]
            
            let string = "STORM VIEWER"
            
            let attributedString = NSAttributedString(string: string, attributes: attributes)
            attributedString.draw(at: CGPoint(x: imageSize.width / 2 - attributedString.size().width / 2, y: imageSize.height / 2))
        }
        
        let vc = UIActivityViewController(activityItems: [imageWithText], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
}
