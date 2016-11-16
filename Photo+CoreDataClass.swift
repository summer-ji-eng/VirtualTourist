//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Yang Ji on 11/16/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(Photo)
public class Photo: NSManagedObject {

    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(photoURL: String, pin: Pin, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context)
        super.init(entity: entity!, insertInto: context)
        self.photoURL = photoURL
        self.pin = pin
    }
    
    var image : UIImage? {
        if let imageData = imageData as? Data {
            return UIImage(data: imageData)
        }
        return nil
    }
    
}
