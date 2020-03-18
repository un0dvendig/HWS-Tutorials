//
//  ViewController.swift
//  Project 10. Names to Faces
//
//  Created by Eugene Ilyin on 26.10.2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Properties
    var people = [Person]()
    
    // MARK: - View Life Cycle    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                           target: self,
                                                           action: #selector(addNewPerson))
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showDummyVC),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        
        showDummyVC()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue PersonCell.")
        }
        
        let person = people[indexPath.item]
        
        cell.name.textColor = .black
        cell.name.text = person.name
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           guard let image = info[.editedImage] as? UIImage else { return }
           
           let imageName = UUID().uuidString
           let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
           
           if let jpegData = image.jpegData(compressionQuality: 0.8) {
               try? jpegData.write(to: imagePath)
           }
           
           let person = Person(name: "Unknown", image: imageName)
           people.append(person)
           collectionView.reloadData()
           
           dismiss(animated: true)
       }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
        
        let ac = UIAlertController(title: "What do you want to do?", message: nil, preferredStyle: .actionSheet)
        
        let renameAction = UIAlertAction(title: "Delete cell", style: .default) { _ in
            self.showAlertController(person: person,
                                     itemNumber: indexPath.item,
                                     title: "Delete?",
                                     textFieldNeeded: false)
        }
        
        let deleteAction = UIAlertAction(title: "Rename cell", style: .default) { _ in
            self.showAlertController(person: person,
                                     itemNumber: indexPath.item,
                                     title: "Rename?",
                                     textFieldNeeded: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ac.addAction(renameAction)
        ac.addAction(deleteAction)
        ac.addAction(cancelAction)
        
        present(ac, animated: true)
    }
    
    private func showAlertController(person: Person,
                                     itemNumber: Int,
                                     title: String,
                                     textFieldNeeded: Bool) {
        let ac = UIAlertController(title: title,
                                   message: nil,
                                   preferredStyle: .alert)
        
        if textFieldNeeded {
            ac.addTextField()
            ac.addAction(UIAlertAction(title: "OK",
                                       style: .default) { [weak self, weak ac] _ in
                guard let newName = ac?.textFields?[0].text else {  return }
                person.name = newName
                self?.collectionView.reloadData()
            })
        } else {
            ac.addAction(UIAlertAction(title: "Delete",
                                       style: .destructive) { _ in
                self.people.remove(at: itemNumber)
                self.collectionView.reloadData()
            })
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    //
    let imagePicker = UIImagePickerController()
    
    @objc
    private func addNewPerson() {
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo Source",
                                            message: "Choose a source for photo",
                                            preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            
            let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
            switch cameraAuthorizationStatus {
            case .notDetermined:
                self.requestCameraPermission()
            case .authorized:
                self.presentCamera()
            case .restricted, .denied:
                self.alertCameraAccessNeeded()
            @unknown default:
                // handle possibly added (in future) values
                break
            }
        }
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(photoLibraryAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true)
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { (access) in
            guard access == true else { return }
            self.presentCamera()
        }
    }
    
    private func presentCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true)
        } else {
            let ac = UIAlertController(title: "Camera is not available", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            ac.addAction(okAction)
            self.present(ac, animated: true)
        }
    }
    
    private func alertCameraAccessNeeded() {
        guard let settingsAppURL = URL(string: UIApplication.openSettingsURLString) else { return }
        
        let ac = UIAlertController(title: "Need Camera Access",
                                   message: "Camera access is required to make full use of this app.",
                                   preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let allowCameraAction = UIAlertAction(title: "Allow Camera", style: .default) { (_) in
            UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        }
        ac.addAction(cancelAction)
        ac.addAction(allowCameraAction)
        
        present(ac, animated: true)
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @objc
    private func showDummyVC() {
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "DummyViewController") as? DummyViewController else { return }
        vc.modalPresentationStyle = .fullScreen
        present(vc,
                animated: false)
    }
}

