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

    // MARK: -Properties
    var sharedContext : NSManagedObjectContext!
    var isEditMode : Bool!
    var flickrClient : FlickrClient!
    var controllerUtilities : ControllerUtilites!
    
    
    // MARK: -IBoutlet
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    // MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initilizeGlobleVar()
        
        configureLongPressGestureRecognizer()
    
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
        if isEditMode == true {
            isEditMode = false
            editBarButton.title = EditBarButtonTitle.editTitle
        } else {
            isEditMode = true
            editBarButton.title = EditBarButtonTitle.doneTitle
        }
    }
    
 
}
