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
        
        let lastAddPin = Pin(coordinate: touchCoordinate, context: sharedContext)
        if UIGestureRecognizerState.began == gestureRecognizer.state {
            mapView.addAnnotation(lastAddPin)
            CoreDataStack.sharedInstance().saveContext()
        }
        if UIGestureRecognizerState.ended == gestureRecognizer.state {
            // get the current pin the numpages of flickr
            flickrClient.downloadImagesForPin(curPin: lastAddPin, completionHandler: { (sucess, error) in
                lastAddPin.isDownlaoding = false
                guard (error == nil) else {
                    self.controllerUtilities.showErrorAlert(title: "Error in Downloading", message: (error?.localizedDescription)!)
                    return
                }
                if (sucess) {
                    print("after request numpages is \(CoreDataStack.sharedInstance().fetchLastAddPin().numPages)")
                } else {
                    print("get pages fail")
                }
            })
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
        let pinInCoreData = CoreDataStack.sharedInstance().fetchSelectedPinInCoreData(selectedPin: pin)
        mapView.removeAnnotation(pin)
        sharedContext.delete(pinInCoreData)
        CoreDataStack.sharedInstance().saveContext()
    }
    
    // MARK: -Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.detailPinIdentifier {
            mapView.deselectAnnotation(selectedPin, animated: false)
            let controller = segue.destination as! DetailPinViewController
            controller.curPin = selectedPin
            controller.curMapRegion = mapView.region
            print("prepare segue to DetailVC curPin's numpages: \(selectedPin.numPages)")
        }
    }


}
