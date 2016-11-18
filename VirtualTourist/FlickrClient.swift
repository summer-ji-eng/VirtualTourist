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
     For here, we request 40 per page, up to 4000 results, we get max total pages is 100
     */
    
    
    // TODO: After getting totalpages, random pick a page to download photos
    // func getPhotoDictionary by given pin, totalpages return photo dictionary
    func downloadImagesForPinWithPages(curPin: Pin, pages: Int, completionHandler: @escaping (_ sucess: Bool, _ error: NSError?)->Void) {
        // Flickr will return at most the first 4,000 results for any given search query
        let pageLimits = min(pages, 40)
        let randomPage = Int(arc4random_uniform(UInt32(pageLimits)))
        let parameters = [
            FlickrParameterKeys.APIKey : FlickrParameterValues.APIKey,
            FlickrParameterKeys.Method : FlickrParameterValues.SearchMethod,
            FlickrParameterKeys.Extras : FlickrParameterValues.MediumURL,
            FlickrParameterKeys.Format : FlickrParameterValues.ResponseFormat,
            FlickrParameterKeys.NoJSONCallback : FlickrParameterValues.DisableJSONCallback,
            FlickrParameterKeys.SafeSearch : FlickrParameterValues.UseSafeSearch,
            FlickrParameterKeys.PerPage : FlickrParameterValues.FortyPerPage,
            FlickrParameterKeys.Page : randomPage,
            FlickrParameterKeys.BoundingBox : createBoundingBoxString(pin: curPin)
        ] as [String : Any]
        let url = createURLFromParameters(parameters: parameters as [String:AnyObject])
        print("When call 'downloardImagesForPinWithPages', the request url is \(url)")
        taskForGETMethodWithURL(curURL: url, completionHandler: { (JSONResults, error) in
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completionHandler(false, error)
                return
            }
            
            guard let photosDictionary = JSONResults?[FlickrResponseKeys.Photos] as? [String: AnyObject],
                let photoDictionary = photosDictionary[FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                completionHandler(false, NSError(domain: FlickrError.DomainErrorNotFoundPhotoKey, code: 0, userInfo: nil))
                    return
            }
            
            for photoObject in photoDictionary {
                guard let photoURL = photoObject[FlickrResponseKeys.MediumURL] as? String else {
                    completionHandler(false, NSError(domain: FlickrError.DomainErrorNotFoundURLKey, code: 0, userInfo: nil))
                    return
                }
                performUIUpdatesOnMain {
                    // save photo object in Core Data
                    let photo = Photo(photoURL: photoURL, pin: curPin, context: self.sharedContext)

                    do {
                        let imageData = try Data(contentsOf: URL(string: photoURL)!)
                        photo.imageData = imageData as NSData
                    } catch {
                        completionHandler(false, NSError(domain: FlickrError.DomainErrorFailTryImageData, code: 0, userInfo: nil))
                    }
                    CoreDataStack.sharedInstance().saveContext()
                    completionHandler(true, nil)
                }
            }
        })
    }
    
    // Get total pages of photos by given Pin in JSONResult from taskForGetMethodWithURL
    func getTotalPagesOfPin(curPin: Pin, completionHandler : @escaping (_ sucess: Bool, _ error: NSError?)->Void) {
        
        let parameters = [
            FlickrParameterKeys.APIKey : FlickrParameterValues.APIKey,
            FlickrParameterKeys.Method : FlickrParameterValues.SearchMethod,
            FlickrParameterKeys.Extras : FlickrParameterValues.MediumURL,
            FlickrParameterKeys.Format : FlickrParameterValues.ResponseFormat,
            FlickrParameterKeys.NoJSONCallback : FlickrParameterValues.DisableJSONCallback,
            FlickrParameterKeys.SafeSearch : FlickrParameterValues.UseSafeSearch,
            FlickrParameterKeys.PerPage : FlickrParameterValues.FortyPerPage,
            FlickrParameterKeys.BoundingBox : createBoundingBoxString(pin: curPin)
            ] as [String : Any]
        
        let url = createURLFromParameters(parameters: parameters as [String : AnyObject])
        print("When call 'getTotalPagesOfPin', the request url is \(url)")
        taskForGETMethodWithURL(curURL: url, completionHandler: { (JSONResult, error) in
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completionHandler(false, error)
                return
            }
            /* GUARD: Is status 'ok'? */
            guard (JSONResult?[FlickrResponseKeys.Status] as! String == "ok") else {
                print("The status of requesting data is 'fail'")
                completionHandler(false, NSError(domain: FlickrError.DomainErrorStatusFail, code: 0, userInfo: nil))
                return
            }
            
            if let photosDictionary = JSONResult?[FlickrResponseKeys.Photos] as? [String: AnyObject],
                let totalPages = photosDictionary[FlickrResponseKeys.Pages] as? Int {
                performUIUpdatesOnMain {
                    // save numPages in Pin Object core data
                    curPin.numPages = Int16(totalPages)
                    CoreDataStack.sharedInstance().saveContext()
                    completionHandler(true, nil)
                }
                
            } else {
                completionHandler(false, NSError(domain: FlickrError.DomainErrorNotFoundPagesKey, code: 0, userInfo: nil))
            }
        })
    }
    
    // Get data by sending GET request to service return JSON DATA
    private func taskForGETMethodWithURL(curURL: URL, completionHandler : @escaping (_ results: [String : AnyObject]?, _ error: NSError?)->Void) {
        
        let request = URLRequest(url: curURL)
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completionHandler(nil, NSError(domain: FlickrError.DomainErrorParseData, code: 2, userInfo: nil))
                return
            }
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode < 299 else {
                var errorCode = 0 /* technical error */
                if let response = response as? HTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                    errorCode = response.statusCode
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                
                performUIUpdatesOnMain {
                    completionHandler(nil, NSError(domain: FlickrError.DomainErrorGETImage, code: errorCode, userInfo: nil))
                }
                return
            }
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                completionHandler(nil, NSError(domain: FlickrError.DomainErrorGETJSONData, code: 3, userInfo: nil))
                return
            }
            let parseResult : [String : AnyObject]
            do {
                parseResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : AnyObject]
                completionHandler(parseResult, nil)
            } catch {
                let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
                completionHandler(nil, NSError(domain: FlickrError.DomainErrorParseData, code: 1, userInfo: userInfo))
            }
            
        })
        
        task.resume()
    }

    
    
    
    // MARK: -Helper Function
    // Create URL by given parameters NSURLComponent()
    private func createURLFromParameters(parameters: [String: AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Flickr.APIScheme
        components.host = Flickr.APIHost
        components.path = Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems?.append(queryItem)
        }
        
        return components.url!
    }
    
    // Create BoundingBox (parameters of Flickr API) using given pin object
    private func createBoundingBoxString(pin: Pin) -> String {
        
        let latitude = pin.coordinate.latitude
        let longitude = pin.coordinate.longitude
        
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - BBoxParameters.BOUNDING_BOX_HALF_WIDTH, BBoxParameters.LON_MIN)
        let bottom_left_lat = max(latitude - BBoxParameters.BOUNDING_BOX_HALF_HEIGHT, BBoxParameters.LAT_MIN)
        let top_right_lon = min(longitude + BBoxParameters.BOUNDING_BOX_HALF_HEIGHT, BBoxParameters.LON_MAX)
        let top_right_lat = min(latitude + BBoxParameters.BOUNDING_BOX_HALF_HEIGHT, BBoxParameters.LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
}
