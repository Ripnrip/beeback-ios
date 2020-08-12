//
//  Location.swift
//  ARKitImageRecognition
//
//  Created by Duy Nguyen on 8/11/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation

struct Location {
    let name: String?
    let description: String?
    let address: String?
    let longtitude: Float
    let latitude: Float
    
    init(name: String?, description: String?, address: String?, longtitude: Float, latitude: Float) {
        self.name = name
        self.description = description
        self.address = address
        self.longtitude = longtitude
        self.latitude = latitude
    }

}
