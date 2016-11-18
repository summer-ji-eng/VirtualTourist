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

    // MARK: -IBoutlet
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    // MARK: -Properties
    let sharedContext = CoreDataStack.sharedInstance().persistentContainer.viewContext
    var selectedPin : Pin!
    var isEditMode = false
    let flickrClient = FlickrClient.sharedClient()
    
    // MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self

        let uilpr = UILongPressGestureRecognizer(target: self, action: #selector(longPressDropAnnotation))
        uilpr.minimumPressDuration = 0.5
        
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
    
    // MARK: -IBAction functions
    // once the user toggle the EditBarButton on the top right, it will change the isEditMode status
    @IBAction func toggleEditBarButton(_ sender: UIBarButtonItem) {
        if isEditMode {
            isEditMode = false
            editBarButton.title = EditBarButtonTitle.editTitle
        } else {
            isEditMode = true
            editBarButton.title = EditBarButtonTitle.doneTitle
        }
    }
    
    // MARK: -Helper functions
    // long press on the mapView to drop annotation on the screen
    func longPressDropAnnotation(gestureRecognizer: UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchCoordinate : CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let pin = Pin(coordinate: touchCoordinate, context: sharedContext)
        if UIGestureRecognizerState.began == gestureRecognizer.state {
            mapView.addAnnotation(pin)
            CoreDataStack.sharedInstance().saveContext()
        }
        if UIGestureRecognizerState.ended == gestureRecognizer.state {
            // TODO: get photos from flickr
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

// MARK: -MKMapViewDelegate class extends MapViewController
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
    
    /*
     display annotations
    */
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        selectedPin = view.annotation as! Pin
        if isEditMode {
            // if it is editMode
            // pop out an alert message, ask user if want to delete the pin
            showDeletePinAlertViewController(vcTitle: Alert.alertTitle, vcMessage: Alert.alertMessage)
            // TODO: change the isEditMode status after showing Alert
        } else {
            // if it is not editMode
            // present DetailPinViewController
            performSegue(withIdentifier: SegueIdentifier.detailPinIdentifier, sender: self)
        }
    }
    
    // MARK: -Helper Funcions
    // show alert function ask user if he/she want to delete the select PIN
    func showDeletePinAlertViewController(vcTitle: String, vcMessage: String) {
        let alert = UIAlertController(title: vcTitle, message: vcMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alert.AlertActionTitle.cancelTitle, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: Alert.AlertActionTitle.deleteTilte, style: .default, handler: { (action) in
            self.deleteSelectedPin(pin: self.selectedPin)
            self.selectedPin = nil
        }))
        present(alert, animated: true, completion: (() -> Void)? {
            self.isEditMode = false;
            self.editBarButton.title = EditBarButtonTitle.editTitle
            })
        
    }
    
    // Delete selected pin function
    func deleteSelectedPin(pin: Pin) {
        mapView.removeAnnotation(pin)
        sharedContext.delete(pin)
        CoreDataStack.sharedInstance().saveContext()
    }
    
    // MARK: -Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.detailPinIdentifier {
            let controller = segue.destination as! DetailPinViewController
            controller.curPin = selectedPin
            controller.curMapRegion = mapView.region
        }
    }
    
    
}

// MARK: -Constant Class of MapViewController
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
    
    struct SegueIdentifier {
        static let detailPinIdentifier = "detailPinSegue"
    }
    
    struct EditBarButtonTitle {
        static let editTitle = "Edit"
        static let doneTitle = "Done"
    }
    
    struct Alert {
        
        static let alertTitle = "Delete Pin"
        static let alertMessage = "Do you want to delete this pin?"
        
        struct AlertActionTitle {
            static let cancelTitle = "Cancel"
            static let deleteTilte = "Delete"
        }
    }
}
