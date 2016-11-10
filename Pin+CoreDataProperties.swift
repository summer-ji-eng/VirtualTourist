//
//  Pin+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Yang Ji on 11/9/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import Foundation
import CoreData


extension Pin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin");
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longtitude: Double

}
