//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Yang Ji on 11/17/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class FlickrClient: NSObject {
    
    // MARK: -Properties
    var session : URLSession
    var sharedContext : NSManagedObjectContext{
        return CoreDataStack.sharedInstance().persistentContainer.viewContext
    }
    
    // MARK: -Init
    override init() {
        session = URLSession.shared
        super.init()
    }
    
    // MARK: Singleton Instance
    
    private static var sharedInstance = FlickrClient()
    
    class func sharedClient() -> FlickrClient {
        return sharedInstance
    }
    
    // Flickr Documents: https://www.flickr.com/services/api/flickr.photos.search.htm
    // Flickr will return at most the first 4,000 results for any given search query
    // Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500
    // The page of results to return. If this argument is omitted, it defaults to 1.
    
    /*
     For here, we request 30 per page, up to 4000 results, we get max total pages is 100
     */
    
    func downloadImagesForPin(curPin: Pin, completionHandler: @escaping (_ sucess: Bool, _ error: NSError?)-> Void) {
        // tell curPin is downloading right now
        curPin.isDownlaoding = true
        
        // random a page as parameters to garuantee a random photos
        var pageNum = 1
        if let numPages = curPin.numPages {
            var pageLimits = numPages as Int
            if pageLimits > 100 {
                pageLimits = 100
            }
            pageNum = Int(arc4random_uniform(UInt32(pageLimits))) + 1
            print("Getting photos for page number \(pageNum) in \(numPages) total pages")
        }
        // create parameters to form a URL
        let parameters = [
                    FlickrParameterKeys.APIKey : FlickrParameterValues.APIKey,
                    FlickrParameterKeys.Method : FlickrParameterValues.SearchMethod,
                    FlickrParameterKeys.Extras : FlickrParameterValues.MediumURL,
                    FlickrParameterKeys.Format : FlickrParameterValues.ResponseFormat,
                    FlickrParameterKeys.NoJSONCallback : FlickrParameterValues.DisableJSONCallback,
                    FlickrParameterKeys.SafeSearch : FlickrParameterValues.UseSafeSearch,
                    FlickrParameterKeys.PerPage : FlickrParameterValues.ThirtyPerPage,
                    FlickrParameterKeys.Page : pageNum,
                    FlickrParameterKeys.BoundingBox : createBoundingBoxString(pin: curPin)
                ] as [String : Any]
        // create URL to request using parameters above
        let url = createURLFromParameters(parameters: parameters as [String:AnyObject])
        self.taskForGETMethodWithURL(curURL: url, completionHandler: {(JSONResults, error) in
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completionHandler(false, error)
                return
            }
            
            guard let photosDictionary = JSONResults?[FlickrResponseKeys.Photos] as? [String: AnyObject],
                let photoDictionary = photosDictionary[FlickrResponseKeys.Photo] as? [[String:AnyObject]],
                let numPages = photosDictionary[FlickrResponseKeys.Pages] as? Int else {
                completionHandler(false, NSError(domain: FlickrError.DomainErrorNotFoundPhotoKey, code: 0, userInfo: nil))
                return
            }
            
            // update current pin's numPages if pin doesn't save numPages before
            if (curPin.numPages == nil) {
                self.updateNumPagesIntoExistingPin(context: self.sharedContext, curPin: curPin, numPages: numPages)
            }
            
            // Save photo object in Core Data
            for photoObject in photoDictionary {
                guard let photoURL = photoObject[FlickrResponseKeys.MediumURL] as? String else {
                    completionHandler(false, NSError(domain: FlickrError.DomainErrorNotFoundURLKey, code: 0, userInfo: nil))
                    return
                }
                performUIUpdatesOnMain {
                    do {
                        let imageData = try Data(contentsOf: URL(string: photoURL)!) as NSData
                        self.savePhotoObject(context: self.sharedContext, photoURL: photoURL, curPin: curPin, data: imageData)
                        
                    } catch {
                        completionHandler(false, NSError(domain: FlickrError.DomainErrorFailTryImageData, code: 0, userInfo: nil))
                    }
                }
            }
            // tell current Pin download finish
            curPin.isDownlaoding = false

            completionHandler(true, nil)
        })
        
    }

}
