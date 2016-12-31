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

// Integrating the Fetched Results Controller with the Table View Data Source
extension DetailPinViewController {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let section = fetchedResultsController.sections?.count {
            return section
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let num = fetchedResultsController.sections?[section].numberOfObjects {
            return max(self.photoCount, num)
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellIdentifier.reuseIdentifier, for: indexPath) as! FlickrCollectionCell
        
        cell.activeIndicator.isHidden = false
        cell.activeIndicator.startAnimating()
        
        let count = fetchedResultsController.fetchedObjects?.count
        
        if count! > indexPath.row {
            let photo = fetchedResultsController.object(at: indexPath)
            
            cell.flickrImageView.image = photo.image
            cell.activeIndicator.isHidden = true
            cell.activeIndicator.stopAnimating()
        } else {
            print("loading not complete yet")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        newCollectionButtonOutlet.titleLabel?.text = ButtonTitle.RemoveSelectedPictures
        
        let alert = UIAlertController(title: Alert.ControllerDeleteMessage, message: Alert.ControllerDeleteMessage, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: Alert.ActionCancelTitle, style: .cancel, handler: { (action) in
            collectionView.deselectItem(at: indexPath, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: Alert.ActionDeleteTitle, style: .default, handler: { (action) in
            let selectedPhoto = self.fetchedResultsController.object(at: indexPath)
            collectionView.deselectItem(at: indexPath, animated: true)
            self.sharedContext.delete(selectedPhoto)
            CoreDataStack.sharedInstance().saveContext()
            self.photoCount -= 1
            
            self.refreshFetchResult()
            performUIUpdatesOnMain {
                self.collectionView.reloadData()
            }
        }))
        present(alert, animated: true, completion: nil)
        
    }
}


