//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Yang Ji on 11/9/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import Foundation
import CoreData
import MapKit

@objc(Pin)
public class Pin: NSManagedObject, MKAnnotation {
    
    var isDownlaoding = false
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(coordinate: CLLocationCoordinate2D, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context)
        super.init(entity: entity!, insertInto: context)
        latitude = coordinate.latitude
        longtitude = coordinate.longitude
    }
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)
    }
    
}
