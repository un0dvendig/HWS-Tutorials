//
//  ViewController.swift
//  Project 25. Selfie Share
//
//  Created by Eugene Ilyin on 29.11.2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import MultipeerConnectivity
import UIKit

class ViewController: UICollectionViewController,
                      UINavigationControllerDelegate,
                      UIImagePickerControllerDelegate,
                      MCSessionDelegate,
                      MCBrowserViewControllerDelegate {

    // MARK: - Properties
    var images = [UIImage]()
    var peerID = MCPeerID(displayName: UIDevice.current.name)
    var mcSession: MCSession?
    var mcAdvertiserAssistant: MCAdvertiserAssistant?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Selfie Share"
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .camera,
                            target: self,
                            action: #selector(importPicture)),
            UIBarButtonItem(barButtonSystemItem: .fastForward,
                            target: self,
                            action: #selector(sendTestString))]

        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add,
                            target: self,
                            action: #selector(showConnectionPrompt)),
            UIBarButtonItem(barButtonSystemItem: .search,
                            target: self,
                            action: #selector(showConnectedPeers))]
        
        mcSession = MCSession(peer: peerID,
                              securityIdentity: nil,
                              encryptionPreference: .required)
        mcSession?.delegate = self
    }
    
    // MARK: - UICollectionViewController methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageView", for: indexPath)
        
        if let imageView = cell.viewWithTag(1000) as? UIImageView {
            imageView.image = images[indexPath.item]
        }
        
        return cell
    }
    
    // MARK: - UIImagePickerControllerDelegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        
        images.insert(image, at: 0)
        collectionView.reloadData()
        
        guard let mcSession = mcSession else { return }
        if mcSession.connectedPeers.count > 0 {
            if let imageData = image.pngData() {
                do {
                    try mcSession.send(imageData,
                                       toPeers: mcSession.connectedPeers,
                                       with: .reliable)
                } catch {
                    let ac = UIAlertController(title: "Send error",
                                               message: error.localizedDescription,
                                               preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK",
                                               style: .default))
                    present(ac,
                            animated: true)
                }
            }
        }
    }
    
    // MARK: - MCSessionDelegate methods
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            print("Not Connected: \(peerID.displayName)")
            DispatchQueue.main.async { [weak self] in
                let ac = UIAlertController(title: nil,
                                           message: "\(peerID.displayName) has disconnected!",
                                           preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK",
                                           style: .default))
                self?.present(ac, animated: true)
            }
            
        case .connecting:
            print("Connecting: \(peerID.displayName)")
            
        case .connected:
            print("Connected: \(peerID.displayName)")
            
        @unknown default:
            print("Unknown state received: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [weak self] in
            if let image = UIImage(data: data) {
                self?.images.insert(image, at: 0)
                self?.collectionView.reloadData()
            } else {
                let text = String(decoding: data,
                                  as: UTF8.self)
                let ac = UIAlertController(title: nil,
                                           message: text,
                                           preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK",
                                           style: .default))
                self?.present(ac,
                              animated: true)
            }
            
        }
    }
    
    // MARK: - MCBrowserViewControllerDelegate methods
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    // MARK: - Methods
    @objc
    func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc
    func showConnectionPrompt() {
        let ac = UIAlertController(title: "Connect to others",
                                   message: nil,
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Host a session",
                                   style: .default,
                                   handler: startHosting))
        ac.addAction(UIAlertAction(title: "Join a session",
                                   style: .default,
                                   handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac,
                animated: true)
    }
    
    func startHosting(action: UIAlertAction) {
        guard let mcSession = mcSession else { return }
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "un0-task25",
                                                      discoveryInfo: nil,
                                                      session: mcSession)
        mcAdvertiserAssistant?.start()
    }
    
    func joinSession(action: UIAlertAction) {
        guard let mcSession = mcSession else { return }
        let mcBrowser = MCBrowserViewController(serviceType: "un0-task25",
                                                session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser,
                animated: true)
    }
    
    @objc
    func sendTestString() {
        guard let mcSession = mcSession else { return }
        if mcSession.connectedPeers.count > 0 {
            
            DispatchQueue.main.async {
                let ac = UIAlertController(title: "Enter the message",
                                           message: nil,
                                           preferredStyle: .alert)
                ac.addTextField()
                
                let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
                    
                    guard let answer = ac.textFields![0].text else { return }
                    let textData = Data(answer.utf8)
                    
                    do {
                        try mcSession.send(textData,
                                           toPeers: mcSession.connectedPeers,
                                           with: .reliable)
                    } catch {
                        let ac = UIAlertController(title: "Send error",
                                                   message: error.localizedDescription,
                                                   preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK",
                                                   style: .default))
                        self.present(ac,
                                     animated: true)
                    }
                }
                
                ac.addAction(submitAction)
                
                self.present(ac,
                             animated: true)
            }
        }
    }
    
    @objc
    func showConnectedPeers() {
        guard let mcSession = mcSession else { return }
        
        let message = mcSession.connectedPeers.count != 0 ? nil : "No peers connected"
        
        DispatchQueue.main.async { [weak self] in
            let ac = UIAlertController(title: "Connected peers",
                                       message: message,
                                       preferredStyle: .actionSheet)
            
            if mcSession.connectedPeers.count != 0 {
                for peer in mcSession.connectedPeers {
                    ac.addAction(UIAlertAction(title: peer.displayName, style: .default))
                }
            }
            
            
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            self?.present(ac,
                        animated: true)
        }
        
    }

}

