//
//  ViewController.swift
//  Project 16. Capital Cities
//
//  Created by Eugene Ilyin on 22.11.2019.
//  Copyright © 2019 Eugene Ilyin. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationController()
        
        let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home to the 2012 Summer Olympics.")
        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago.")
        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3506), info: "Often called the City of Light.")
        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.")
        let washington = Capital(title: "Washington", coordinate: CLLocationCoordinate2D(latitude: 48.895111, longitude: -77.036667), info: "Named after George himself.")
        
        mapView.addAnnotations([london, oslo, paris, rome, washington])
    }
    
    func setupNavigationController() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(selectMapType))
    }
    
    @objc
    func selectMapType() {
        let ac = UIAlertController(title: "Select Map Type", message: nil, preferredStyle: .actionSheet)
        
        let hybridAction = UIAlertAction(title: "Hybrid", style: .default, handler: { (_) in
            self.mapView.mapType = .hybrid
        })
        let hybridFlyoverAction = UIAlertAction(title: "HybridFlyover", style: .default, handler: { (_) in
            self.mapView.mapType = .hybridFlyover
        })
        let mutedStandardAction = UIAlertAction(title: "MutedStandard", style: .default, handler: { (_) in
            self.mapView.mapType = .mutedStandard
        })
        let satelliteAction = UIAlertAction(title: "Satellite", style: .default, handler: { (_) in
            self.mapView.mapType = .satellite
        })
        let satelliteFlyoverAction = UIAlertAction(title: "SatelliteFlyover", style: .default, handler: { (_) in
            self.mapView.mapType = .satelliteFlyover
        })
        let standardAction = UIAlertAction(title: "Standard", style: .default, handler: { (_) in
            self.mapView.mapType = .standard
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        ac.addAction(hybridAction)
        ac.addAction(hybridFlyoverAction)
        ac.addAction(mutedStandardAction)
        ac.addAction(satelliteAction)
        ac.addAction(satelliteFlyoverAction)
        ac.addAction(standardAction)
        ac.addAction(cancelAction)
        
        present(ac, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Capital else { return nil }
        
        let identifier = "Capital"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            let btn = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
        } else {
            annotationView?.annotation = annotation
        }
        
        if let view = annotationView as? MKPinAnnotationView {
            view.pinTintColor = .green
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let capital = view.annotation as? Capital else { return }
        
        let placeName = capital.title
        let placeInfo = capital.info
        let vc = WebViewController()
        
        vc.link = "https://en.wikipedia.org/wiki/\(placeName!)"
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
