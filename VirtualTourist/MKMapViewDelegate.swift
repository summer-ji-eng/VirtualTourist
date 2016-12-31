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
        
        let localSP = view.annotation as! Pin
        
        if isEditMode == true {
            // if it is editMode
            // pop out an alert message, ask user if want to delete the pin
            showDeletePinAlertViewController(selectedPin: localSP, vcTitle: Alert.alertTitle, vcMessage: Alert.alertMessage)
        } else {
            // if it is not editMode
            // present DetailPinViewController
//            performUIUpdatesOnMain {
                self.performSegue(withIdentifier: SegueIdentifier.detailPinIdentifier, sender: localSP)
//            }
            
        }
    }
    
    // MARK: -Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.detailPinIdentifier {
            let localSp = sender as! Pin
            mapView.deselectAnnotation(localSp, animated: false)
            let controller = segue.destination as! DetailPinViewController
            controller.curPin = localSp
            controller.curMapRegion = mapView.region
            controller.curMapRegion.center = localSp.coordinate
        }
    }
}
