//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Yang Ji on 11/7/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let sharedContext = CoreDataStack.sharedInstance().persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self

        let uilpr = UILongPressGestureRecognizer(target: self, action: #selector(longPressDropAnnotation))
        uilpr.minimumPressDuration = 2.0
        
        mapView.addGestureRecognizer(uilpr)
        
        mapView.addAnnotations(fetchAllPins())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //loads a user's saved map zoom/pan/location setting from NSUserDefaults; this is performed in viewDIDappear rather than viewWILLappear because the map gets initially set to an app-determined location and regionDidChangeAnimated method gets called in BETWEEN viewWillAppear and viewDidAppear (and this initial location is NOT related to the loaded/saved location), so the code to load a user's saved preferences is delayed until now so that the saved location is loaded AFTER the app pre-sets the map, rather then before (and thus being overwritten, or "shifted" to a different location); it is ensured that the initial auotmatica "pre-set" region of the map is not saved as a user-based save (thus overwriting a user's save) via the mapViewRegionDidChangeFromUserInteraction method, which checks to make sure that when regionDidChangeAnimated is invoked, it is in response to user-generated input
        if let savedRegion = UserDefaults.standard.object(forKey: RegionPersistent.regionKey) as? [String: Double] {
            let center = CLLocationCoordinate2D(latitude: savedRegion[MapRegion.mapRegionCenterLat]!, longitude: savedRegion[MapRegion.mapRegionCenterLon]!)
            let span = MKCoordinateSpan(latitudeDelta: savedRegion[MapRegion.mapRegionSpanLat]!, longitudeDelta: savedRegion[MapRegion.mapRegionSpaLon]!)
            mapView.region = MKCoordinateRegion(center: center, span: span)
        }
    }
    
    func longPressDropAnnotation(gestureRecognizer: UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchCoordinate : CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        if UIGestureRecognizerState.began == gestureRecognizer.state {
            let pin = Pin(coordinate: touchCoordinate, context: sharedContext)
            mapView.addAnnotation(pin)
            CoreDataStack.sharedInstance().saveContext()
        }
    }
    
    // fetching our Pins and adding them to our map when starting our app
    func fetchAllPins() -> [Pin] {
        let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
        var pins : [Pin] = []
        do {
            let results = try sharedContext.fetch(fetchRequest)
            pins = results 
        } catch let error as NSError {
            //showAlert("Ooops", message: "Something went wrong when trying to load existing data")
            print("An error occured accessing managed object context \(error.localizedDescription)")
        }
        return pins
    }

}

extension MapViewController: MKMapViewDelegate {
    
    
    /* Persistent the map region data.
        The center of the map and the zoom level should be persistent. If the app is turned off, the map should return to the same state when it is turned on again.
    */
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let regionPersistent = [
            MapRegion.mapRegionCenterLat : mapView.region.center.latitude,
            MapRegion.mapRegionCenterLon : mapView.region.center.longitude,
            MapRegion.mapRegionSpanLat : mapView.region.span.latitudeDelta,
            MapRegion.mapRegionSpaLon : mapView.region.span.longitudeDelta
        ]
        UserDefaults.standard.setValue(regionPersistent, forKey: RegionPersistent.regionKey)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
            let identifier = "pin"
            let view : MKPinAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = false
                view.animatesDrop = true
                view.isDraggable = false
            }
            return view
        
    }
    
}

extension MapViewController {
    
    struct MapRegion {
        static let mapRegionCenterLat = "mapRegionCenterLat"
        static let mapRegionCenterLon = "mapRegionCenterLon"
        static let mapRegionSpanLat = "mapRegionSpanLat"
        static let mapRegionSpaLon = "mapRegionSpaLon"
        
    }
    
    struct RegionPersistent {
        static let regionKey = "regionPersistentKey"
    }
}
