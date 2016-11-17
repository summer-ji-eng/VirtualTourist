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
    
    @IBOutlet weak var activeIndicator: UIActivityIndicatorView!
    @IBOutlet weak var flickrImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if flickrImageView.image == nil {
            activeIndicator.isHidden = false
            activeIndicator.startAnimating()
        }
        
    }
}
