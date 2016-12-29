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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellIdentifier.reuseIdentifier, for: indexPath) as! FlickrCollectionCell
        let photo = fetchedResultsController.object(at: indexPath) 
        
        if photo.imageData != nil {
            performUIUpdatesOnMain {
                cell.activeIndicator.isHidden = true
                cell.flickrImageView.isHidden = false
                cell.activeIndicator.stopAnimating()
                cell.flickrImageView.image = photo.image
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print("prefetchItemsAt \(indexPaths)")
        for i in indexPaths {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellIdentifier.reuseIdentifier, for: i) as! FlickrCollectionCell
            let photo = fetchedResultsController.object(at: i)
            if photo.imageData != nil {
                performUIUpdatesOnMain {
                    cell.activeIndicator.isHidden = true
                    cell.flickrImageView.isHidden = false
                    cell.activeIndicator.stopAnimating()
                    cell.flickrImageView.image = photo.image
                }
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        print("cancel prefetching for items at \(indexPaths)")
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
        }))
        present(alert, animated: true, completion: nil)
    }
}


