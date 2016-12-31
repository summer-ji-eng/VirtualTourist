//
//  MapVCHelperFunction.swift
//  VirtualTourist
//
//  Created by Yang Ji on 12/18/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//
import MapKit
import CoreData

extension MapViewController {
    
    // MARK: - init function and configuration function
    func initilizeGlobleVar() {
        
        isEditMode = false
        sharedContext = CoreDataStack.sharedInstance().persistentContainer.viewContext
        flickrClient = FlickrClient.sharedClient()
        controllerUtilities = ControllerUtilites.sharedUtilites()
        
        mapView.delegate = self
        
    }
    
    func configureLongPressGestureRecognizer() {
        
        let uilpr = UILongPressGestureRecognizer(target: self, action: #selector(longPressDropAnnotation))
        uilpr.minimumPressDuration = 0.5
        
        mapView.addGestureRecognizer(uilpr)
        
        mapView.addAnnotations(fetchAllPins())
    }
    
    // long press on the mapView to drop annotation on the screen
    func longPressDropAnnotation(gestureRecognizer: UIGestureRecognizer) {
        
        // if is in the edit mode, not allow user add pin
        if isEditMode == true {
            return
        }
        
        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchCoordinate : CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        if UIGestureRecognizerState.ended == gestureRecognizer.state {
            let lastAddPin = Pin(coordinate: touchCoordinate, context: sharedContext)
            mapView.addAnnotation(lastAddPin)
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
            self.controllerUtilities.showErrorAlert(title: "Error Fetching All Pins", message: error.localizedDescription)
        }
        return pins
    }
    
    // show alert function ask user if he/she want to delete the select PIN
    func showDeletePinAlertViewController(selectedPin: Pin, vcTitle: String, vcMessage: String) {
        let alert = UIAlertController(title: vcTitle, message: vcMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alert.AlertActionTitle.cancelTitle, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: Alert.AlertActionTitle.deleteTilte, style: .default, handler: { (action) in
            self.deleteSelectedPin(pin: selectedPin)
        }))
        present(alert, animated: true, completion: (() -> Void)? {})
        
    }
    
    // Delete selected pin function
    func deleteSelectedPin(pin: Pin) {
        let pinInCoreData = CoreDataStack.sharedInstance().fetchSelectedPinInCoreData(selectedPin: pin)
        mapView.removeAnnotation(pin)
        sharedContext.delete(pinInCoreData)
        CoreDataStack.sharedInstance().saveContext()
    }
    



}
