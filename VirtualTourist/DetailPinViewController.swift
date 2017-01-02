//
//  DetailPinViewController.swift
//  VirtualTourist
//
//  Created by Yang Ji on 11/10/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class DetailPinViewController: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: -Properties
    var curPin : Pin!
    var curMapRegion : MKCoordinateRegion!
    var flickrClient : FlickrClient!
    var controllerUtilities : ControllerUtilites!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var sharedContext : NSManagedObjectContext{
        return CoreDataStack.sharedInstance().persistentContainer.viewContext
    }
    var photoCount : NSInteger = 0
    
    // MARK: -IBOutles
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButtonOutlet: UIButton!
    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var cvFlowLayout: UICollectionViewFlowLayout!
    
    // store updated indexes, this is used in fetch result delegate
    var blockOperations: [BlockOperation] = []
    
    // MARK: -LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        noImageLabel.isHidden = true
        collectionView.isHidden = false
        
        // initialize all the shits with global variable
        initializeAllGlobalVars()
        
        self.refreshFetchResult()
        
        if self.fetchedResultsController.fetchedObjects?.count == 0 {
            self.downloadNewSetOfImages()
        } else {
            performUIUpdatesOnMain {
                self.collectionView.reloadData()
            }
        }
    }
    
    @IBAction func pressNewCollectionButton(_ sender: UIButton) {
        self.newCollectionButtonOutlet.isEnabled = false
        deleteExistingPhototsInCoreData()
        performUIUpdatesOnMain {
            self.collectionView.reloadData()
        }
        downloadNewSetOfImages()
    }
    
    func downloadNewSetOfImages() {
        self.newCollectionButtonOutlet.isEnabled = false
        flickrClient.downloadImagesForPin(curPin: self.curPin) { (sucess, photoDictionary,error) in
            guard (error == nil) else {
                self.controllerUtilities.showErrorAlert(title: "Download Fail in Detail VC", message: (error?.localizedDescription)!)
                return
            }
            if sucess {
                self.photoCount = photoDictionary.count
                // Save photo object in Core Data
                for photoObject in photoDictionary {
                    guard let photoURL = photoObject[FlickrClient.FlickrResponseKeys.MediumURL] as? String else {
                        fatalError(FlickrClient.FlickrError.DomainErrorNotFoundURLKey)
                    }
                    do {
                        let imageData = try Data(contentsOf: URL(string: photoURL)!) as NSData
                        
                        self.savePhotoObject(context: self.sharedContext, photoURL: photoURL, curPin: self.curPin, data: imageData)
                        
                        self.refreshFetchResult()
                        performUIUpdatesOnMain {
                            self.collectionView.reloadData()
                        }
                    }
                    catch {
                        print("dude, something is wrong!")
                    }
                    
                }
                
            }
            
            self.newCollectionButtonOutlet.isEnabled = true
        }
    }
    
    // save Photo object with photoURL, Pin, photoDat into CoreData
    func savePhotoObject(context: NSManagedObjectContext,photoURL: String, curPin: Pin, data: NSData) {
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
    
}

