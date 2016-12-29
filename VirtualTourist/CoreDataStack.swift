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
    
    func fetchSelectedPinInCoreData(selectedPin: Pin) -> Pin {
        let context = persistentContainer.viewContext
        var curPin : Pin!
        let request : NSFetchRequest<Pin> = Pin.fetchRequest()
        request.predicate = NSPredicate.init(format: "latitude <= \(selectedPin.latitude) + 0.01 AND latitude >= \(selectedPin.latitude) - 0.01 AND longtitude <= \(selectedPin.longtitude) + 0.01 AND longtitude >= \(selectedPin.longtitude) - 0.01")
        do {
            let fetchResults = try context.fetch(request)
            if let pin = fetchResults.first {
                curPin = pin
            }
        } catch let error as NSError {
            print("Could not fetch result of Pin on Selected Pin, error is \(error.localizedDescription)")
        }
        return curPin
    }
}
