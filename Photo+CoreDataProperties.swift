//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Yang Ji on 11/16/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var imageData: NSData?
    @NSManaged public var photoURL: String?
    @NSManaged public var pin: Pin?

}
