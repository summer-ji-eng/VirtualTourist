//
//  DetailPinViewController.swift
//  VirtualTourist
//
//  Created by Yang Ji on 11/10/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import UIKit
import MapKit

class DetailPinViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: -Properties
    var curPin : Pin!
    var curMapRegion : MKCoordinateRegion!
    fileprivate let reuseIdentifier = "FlickrCollectionViewCell"

    // MARK: -IBOutles
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureMapView(pin: curPin, mapRegion: curMapRegion)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Test FlickrClient
        // using Pin to create http parameters to form url by func of createURLFromParameters
        // using URL to get JSON data by func of taskForGetMethodWithURL
        // using JSON data get photos' url, using url to save imagedata into core data
        
        let flickrClient = FlickrClient.sharedClient()
        flickrClient.getTotalPagesOfPin(curPin: curPin, completionHandler: {(pages, error) in
            
            if (error != nil) {
                print(error!.localizedDescription)
            }
            
            print("Total page is \(pages!)")
        })
        
        flickrClient.downloadImagesForPinWithPages(curPin: curPin, pages: Int(curPin.numPages), completionHandler: { (sucess, error) in
            if (error != nil) {
                print(error!.localizedDescription)
            }
            
            print("download sucess")
        })
        
        
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

extension DetailPinViewController {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FlickrCollectionCell
        return cell
    }
}


