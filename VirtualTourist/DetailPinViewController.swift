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

class DetailPinViewController: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: -Properties
    var curPin : Pin!
    var curMapRegion : MKCoordinateRegion!
    let flickrClient = FlickrClient.sharedClient()
    fileprivate let reuseIdentifier = "FlickrCollectionViewCell"
    let pinFinishedDownloadingNotification = "pinFinishedDownloadNotification"
    var sharedContext : NSManagedObjectContext{
        return CoreDataStack.sharedInstance().persistentContainer.viewContext
    }
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    // store updated indexes
    var selectedIndexes   = [NSIndexPath]()
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths : [NSIndexPath]!
    var updatedIndexPaths : [NSIndexPath]!

    // MARK: -IBOutles
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButtonOutlet: UIButton!
    @IBOutlet weak var noImageLabel: UILabel!
    
    // MARK: -LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        noImageLabel.isHidden = true
        collectionView.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /* setup top map to display the pin on the map*/
        configureMapView(pin: curPin, mapRegion: curMapRegion)
        
        /* comform collectionView delegate and dataSource */
        collectionView.delegate = self
        collectionView.dataSource = self
        
        /* setup the fetchedResultsController*/
        initializeFetchedResultsController()

        print("CurPin's numpages :\(curPin.numPages)")
        print("fetchObjects nums: \(fetchedResultsController.fetchedObjects?.count)")
        if fetchedResultsController.fetchedObjects?.count == 0 {
            // fail gracfully - download new collection
            downloadNewCollectionSet()
        }
        
        //disable new collection button if we are already downloading
        if curPin.isDownlaoding {
            newCollectionButtonOutlet.isEnabled = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(pinFinishedDownload), name: NSNotification.Name(rawValue: pinFinishedDownloadingNotification), object: nil)
    
    }
    
    // MARK: Creating a Fetched Results Controller -- initi
    func initializeFetchedResultsController() {
        
        let request = NSFetchRequest<Photo>(entityName: "Photo")
        request.predicate = NSPredicate(format: "pin = %@", self.curPin)
        request.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            print("perform fetchedResultsController")
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
    }
    
    

    // MARK: -MapView properity configurate and add annotation
    private func configureMapView(pin: Pin, mapRegion: MKCoordinateRegion) {
        // display current Pin
        mapView.addAnnotation(curPin)
        // set mapview properties
        mapView.setCenter(curPin.coordinate, animated: true)
        mapView.setRegion(curMapRegion, animated: true)
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.sizeToFit()
    }
    
    // MARK: -Communicate data changes to the Collection View
    private func controllerWillChangeContent(controller: NSFetchedResultsController<Photo>) {
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths  = [NSIndexPath]()
        updatedIndexPaths  = [NSIndexPath]()
    }
    
    private func controller(controller: NSFetchedResultsController<Photo>, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
        case .update:
            updatedIndexPaths.append(indexPath!)
        case .delete:
            deletedIndexPaths.append(indexPath!)
        default:
            break
        }
    }
    
    private func controllerDidChangeContent(controller: NSFetchedResultsController<Photo>) {
        collectionView.performBatchUpdates({
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath as IndexPath])
            }
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath as IndexPath])
            }
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath as IndexPath])
            }
        }, completion: nil)
    }
    
    // MARK: -download new collection set associate of pin
    private func downloadNewCollectionSet() {
        // delete existing photos
        for photo in fetchedResultsController.fetchedObjects! as [Photo] {
            sharedContext.delete(photo)
        }
        CoreDataStack.sharedInstance().saveContext()
        
        // when downloading unenable button
        self.newCollectionButtonOutlet.isEnabled = false
        print("passing curPin's numPages is \(curPin.numPages)")
        flickrClient.downloadImagesForPin(curPin: curPin, completionHandler: {(sucess, error) in
            guard (error == nil) else {
                print(error!.localizedDescription)
                // TODO: Show alert error
                return
            }
            if sucess {
                self.pinFinishedDownload()
                //print("sucess download image")
            }
        })
        
    }
    
    @objc private func pinFinishedDownload() {
        self.initializeFetchedResultsController()
        if curPin.isDownlaoding {
            return
        }
        self.newCollectionButtonOutlet.isEnabled = true
        if let objects = fetchedResultsController.fetchedObjects {
            if objects.count == 0 {
                self.collectionView.isHidden = true
                self.noImageLabel.isHidden = false
                self.newCollectionButtonOutlet.isEnabled = true
            }
            print("pinFinishedDownload the fetchedresults objects is \(objects.count)")
        }
    }
    
}

// Integrating the Fetched Results Controller with the Table View Data Source
extension DetailPinViewController {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FlickrCollectionCell
        let photo = fetchedResultsController.object(at: indexPath) 
        
        if photo.imageData != nil {
            cell.activeIndicator.stopAnimating()
            cell.flickrImageView.image = photo.image
        }
        return cell
    }
}


