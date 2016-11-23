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
    var blockOperations: [BlockOperation] = []

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
        
        // reload data for UICollectionView
        collectionView.reloadData()
        
    }
    
    

    // MARK: -MapView properity configurate and add annotation
    func configureMapView(pin: Pin, mapRegion: MKCoordinateRegion) {
        // display current Pin
        mapView.addAnnotation(curPin)
        // set mapview properties
        mapView.setCenter(curPin.coordinate, animated: true)
        mapView.setRegion(curMapRegion, animated: true)
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.sizeToFit()
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

// MARK: -Communicate data changes to the Collection View
extension DetailPinViewController {
    
    
    func controller(controller: NSFetchedResultsController<Photo>, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .insert:
            print("Insert Object: \(newIndexPath)")
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.insertItems(at: [newIndexPath! as IndexPath])
                    }
                })
            )
        case .update:
            print("Update Object: \(indexPath)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.reloadItems(at: [indexPath! as IndexPath])
                    }
                })
            )
        case .delete:
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.deleteItems(at: [indexPath! as IndexPath])
                    }
                })
            )
        default:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController<Photo>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.insertSections(NSIndexSet(index: sectionIndex) as IndexSet)
                    }
                })
            )
        case .update:
            print("Update Section: \(sectionIndex)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet)
                    }
                })
            )
        case .delete:
            print("Delete Section: \(sectionIndex)")
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet)
                    }
                })
            )
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController<Photo>) {
        collectionView!.performBatchUpdates({ () -> Void in
            for operation: BlockOperation in self.blockOperations {
                operation.start()
            }
        }, completion: { (finished) -> Void in
            self.blockOperations.removeAll(keepingCapacity: false)
        })
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


