//
//  CoreDataStack.swift
//  VirtualTourist
//
//  Created by Yang Ji on 11/9/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    // MARK: - Shared Instance
    
    /**
     *  This class variable provides an easy way to get access
     *  to a shared instance of the CoreDataStackManager class.
     */
    class func sharedInstance() -> CoreDataStack {
        struct Static {
            static let instance = CoreDataStack()
        }
        return Static.instance
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "VirtualTourist")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func saveNumPages(numPages: Int) {
        let context = persistentContainer.viewContext
        let entity =  NSEntityDescription.entity(forEntityName: "Pin", in: context)
        let pin = NSManagedObject(entity: entity!, insertInto: context)
        pin.setValue(numPages as NSNumber, forKey: "numPages")
        print("saving numpages \(numPages)")
        do {
            try context.save()
            print("save pin's numPages sucess")
            print(context)
        } catch let error as NSError {
            print("Could not save numPages in pin, error is \(error.localizedDescription)")
        }
    }
    
    // save image in same photo
//    func saveImageData(imageData: NSData) {
//        let context = persistentContainer.viewContext
//        let entity =  NSEntityDescription.entity(forEntityName: "Photo", in: context)
//        let photo = NSManagedObject(entity: entity!, insertInto: context)
//        photo.setValue(imageData, forKey: "imageData")
//        do {
//            try context.save()
//        } catch let error as NSError {
//            fatalError("Could not save Photo's imageData, error \(error.localizedDescription)")
//        }
//    }
    
    func savePhotoObject(photoURL: String, curPin: Pin, data: NSData) {
        let context = persistentContainer.viewContext
        let photo = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: context) as! Photo
        photo.photoURL = photoURL
        photo.pin = curPin
        photo.imageData = data
        do {
            try context.save()
        } catch let error as NSError {
            fatalError("Could not save Photo, error \(error.localizedDescription)")
        }
    }
    
    func fetchLastAddPin()-> Pin {
        let context = persistentContainer.viewContext
        var curPin : Pin?
        let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
        //fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            let fetchResults = try context.fetch(fetchRequest)
            if let pin = fetchResults.last {
                curPin = pin
            }
        } catch let error as NSError {
            print("Could not fetch result of Pin, error is \(error.localizedDescription)")
        }
        return curPin!
    }
}
