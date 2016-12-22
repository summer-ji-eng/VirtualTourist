//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Yang Ji on 11/7/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

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
