//
//  DetailViewController.swift
//  Project 01. Storm Viewer
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
        
        navigationItem.largeTitleDisplayMode = .never
        
        if let imageToLoad = selectedImage {
            imageView.image = UIImage(named: imageToLoad)
        }
        
        assert(selectedImage != nil, "Selected image is nil!")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
}
