//
//  DetailPinViewController.swift
//  VirtualTourist
//
//  Created by Yang Ji on 11/10/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import UIKit
import MapKit

class DetailPinViewController: UIViewController {
    
    // MARK: -Properties
    var curPin : Pin!
    var curMapRegion : MKCoordinateRegion!

    // MARK: -IBOutles
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureMapView(pin: curPin, mapRegion: curMapRegion)
        
    }
    
    // MARK: -MapView properity configurate and add annotation
    private func configureMapView(pin: Pin, mapRegion: MKCoordinateRegion) {
        // display current Pin
        mapView.addAnnotation(curPin)
        // set mapview properties
        mapView.setCenter(curPin.coordinate, animated: true)
        mapView.setRegion(curMapRegion, animated: true)
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.sizeToFit()
    }
}


