//
//  ViewController.swift
//  Project 22. Detect-a-Beacon
//
//  Created by Eugene Ilyin on 24.11.2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var distanceReading: UILabel!
    @IBOutlet weak var beaconName: UILabel!
    @IBOutlet weak var circle: UIView!
    
    // MARK: - Properties
    var locationManager: CLLocationManager?
    var detected = false
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        circle.layer.cornerRadius = 128
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        view.backgroundColor = .gray
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        let uuid0 = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
        let uuid1 = UUID(uuidString: "74278BDA-B644-4520-8F0C-720EAF059936")!
        let uuid2 = UUID(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!
        
        let beaconConstraint0 = CLBeaconIdentityConstraint(uuid: uuid0, major: 123, minor: 456)
        let beaconRegion0 = CLBeaconRegion(beaconIdentityConstraint: beaconConstraint0, identifier: "MyBeacon0")
        let beaconConstraint1 = CLBeaconIdentityConstraint(uuid: uuid1)
        let beaconRegion1 = CLBeaconRegion(beaconIdentityConstraint: beaconConstraint1, identifier: "MyBeacon1")
        let beaconConstraint2 = CLBeaconIdentityConstraint(uuid: uuid2)
        let beaconRegion2 = CLBeaconRegion(beaconIdentityConstraint: beaconConstraint2, identifier: "MyBeacon2")
        
        locationManager?.startMonitoring(for: beaconRegion0)
        locationManager?.startRangingBeacons(satisfying: beaconConstraint0)
        locationManager?.startMonitoring(for: beaconRegion1)
        locationManager?.startRangingBeacons(satisfying: beaconConstraint1)
        locationManager?.startMonitoring(for: beaconRegion2)
        locationManager?.startRangingBeacons(satisfying: beaconConstraint2)
    }
    
    func update(distance: CLProximity) {
        UIView.animate(withDuration: 1) {
            switch distance{
            case .far:
                self.view.backgroundColor = .blue
                self.distanceReading.text = "FAR"
                self.circle.transform = CGAffineTransform.init(scaleX: 0.25, y: 0.25)
                
            case .near:
                self.view.backgroundColor = .orange
                self.distanceReading.text = "NEAR"
                self.circle.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
                
            case .immediate:
                self.view.backgroundColor = .red
                self.distanceReading.text = "RIGHT HERE"
                self.circle.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
                
            default:
                self.view.backgroundColor = .gray
                self.distanceReading.text = "UNKNOWN"
                self.circle.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        if !detected {
            detected.toggle()
            let ac = UIAlertController(title: "Detected", message: "The beacon has been detected!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            
            present(ac, animated: true)
        }
        if let beacon = beacons.first {
            self.beaconName.text = "Reading:\n\(beaconConstraint.uuid.uuidString)"
            update(distance: beacon.proximity)
        } else {
            self.beaconName.text = "Reading:\n\(beaconConstraint.uuid.uuidString)"
            update(distance: .unknown)
        }
    }
}

