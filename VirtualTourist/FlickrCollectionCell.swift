//
//  FlickrCollectionCell.swift
//  VirtualTourist
//
//  Created by Yang Ji on 11/16/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import Foundation
import UIKit

class FlickrCollectionCell : UICollectionViewCell {
    
    @IBOutlet weak var flickrImageView: UIImageView!
    @IBOutlet var activeIndicator: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
//        if flickrImageView.image == nil {
//            flickrImageView.isHidden = true
//            activeIndicator.isHidden = false
//            activeIndicator.color = UIColor.red
//            activeIndicator.startAnimating()
//            flickrImageView.backgroundColor = UIColor.blue
//        }
        
    }
}
