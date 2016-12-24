//
//  GCDBlackBox.swift
//  VirtualTourist
//
//  Created by Yang Ji on 11/17/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(updates: @escaping ()->Void) {
    DispatchQueue.main.async {
        updates()
    }
}

func performUpdatesOnBackground(updates: @escaping ()-> Void) {
    DispatchQueue.global().async {
        updates()
    }
}


