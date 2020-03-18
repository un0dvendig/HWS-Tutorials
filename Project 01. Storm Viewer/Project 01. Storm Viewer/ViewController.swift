//
//  ViewController.swift
//  Project 01. Storm Viewer
//
//  Created by Eugene Ilyin on 29/08/2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    // MARK: - Properties
    var pictureDictionary = [String: Int]()
    var pictures = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storm Viewer"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        let defaults = UserDefaults.standard
        pictureDictionary = defaults.object(forKey: "savedDictionary") as? [String: Int] ?? [String: Int]()
        
        for item in items {
            if item.hasPrefix("nssl"){
                pictures.append(item)
                
                // read saved data here
                if pictureDictionary[item] == nil {
                    pictureDictionary[item] = 0
                }
            }
        }
        pictures.sort(by: { $0 < $1 } )
        print(pictures)
        print(pictureDictionary)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        cell.textLabel?.text = pictures[indexPath.row]
        
        if let shown = pictureDictionary[pictures[indexPath.row]] {

            cell.detailTextLabel?.text = "was shown \(shown) times"
        } else {
            print("Something happened")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1: try loading the "Detail" view controller and typecasting it to be DetailViewController
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            // 2: success! Set its selectedImage property
            vc.selectedImage = pictures[indexPath.row]
            vc.selectedImageNumber = indexPath.row + 1
            vc.totalPictures = pictures.count
            
            let picture = pictures[indexPath.row]
            guard let shownTimes = pictureDictionary[picture] else { return }
            pictureDictionary[picture] = shownTimes+1
            save()
            tableView.reloadData()
            
            // 3: now push it onto the navigation controller
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func save() {
        let defaults = UserDefaults.standard
        defaults.set(pictureDictionary, forKey: "savedDictionary")
    }

}

