//
//  FlickrClientHelperFunction.swift
//  VirtualTourist
//
//  Created by Yang Ji on 12/19/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension FlickrClient {
    
    // Get data by sending GET request to service return JSON DATA
    func taskForGETMethodWithURL(curURL: URL, completionHandler : @escaping (_ results: [String : AnyObject]?, _ error: NSError?)->Void) {
        
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
                
                completionHandler(nil, NSError(domain: FlickrError.DomainErrorGETImage, code: errorCode, userInfo: nil))
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
    
    
    // Create URL by given parameters NSURLComponent()
    func createURLFromParameters(parameters: [String: AnyObject]) -> URL {
        
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
    func createBoundingBoxString(pin: Pin) -> String {
        
        let latitude = pin.coordinate.latitude
        let longitude = pin.coordinate.longitude
        
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - BBoxParameters.BOUNDING_BOX_HALF_WIDTH, BBoxParameters.LON_MIN)
        let bottom_left_lat = max(latitude - BBoxParameters.BOUNDING_BOX_HALF_HEIGHT, BBoxParameters.LAT_MIN)
        let top_right_lon = min(longitude + BBoxParameters.BOUNDING_BOX_HALF_HEIGHT, BBoxParameters.LON_MAX)
        let top_right_lat = min(latitude + BBoxParameters.BOUNDING_BOX_HALF_HEIGHT, BBoxParameters.LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    // save the total num of pages to existing Pin onject
    func updateNumPagesIntoExistingPin(context: NSManagedObjectContext, curPin: Pin, numPages: Int) {
        let selectedPin = CoreDataStack.sharedInstance().fetchSelectedPinInCoreData(selectedPin: curPin)
        selectedPin.numPages = numPages as NSNumber
        do {
            try context.save()
        } catch let error as NSError {
            print(error)
        }
    }
    
    
}
