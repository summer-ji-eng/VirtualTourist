//
//  ControllerUtilities.swift
//  VirtualTourist
//
//  Created by Yang Ji on 12/19/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import Foundation
import UIKit

class ControllerUtilites: UIViewController {
    
    // MARK: Singleton Instance
    
    private static var sharedInstance = ControllerUtilites()
    
    class func sharedUtilites() -> ControllerUtilites {
        return sharedInstance
    }
    
    
    // return alert controller
    func showErrorAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) in
            return
        }
        alertController.addAction(defaultAction)
        present(alertController, animated: false, completion: nil)
    }
    
}
