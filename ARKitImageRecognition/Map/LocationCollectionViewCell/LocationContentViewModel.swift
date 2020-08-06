//
//  LocationContentViewModel.swift
//  ARKitImageRecognition
//
//  Created by Duy Nguyen on 8/4/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import MapKit
import UIKit

/**
 ViewModel for LocationContentViewModel
 # Properties
 ```
 let locationImage: UIImage?
 let locationName: String
 let locationSubtitle: String
 let address: String
 let distance: String
 let coordinate: CLLocationCoordinate2D
 ```
 
 */
class LocationContentViewModel: NSObject, MKAnnotation {
    
    let locationImage: UIImage?
    let locationName: String
    let locationSubtitle: String
    let address: String
    let distance: String
    let coordinate: CLLocationCoordinate2D
    
    init(image: UIImage?, name: String, subtitle: String, address: String, distance: String, coordinate: CLLocationCoordinate2D) {
        self.locationImage = image
        self.locationName = name
        self.locationSubtitle = subtitle
        self.address = address
        self.distance = distance
        self.coordinate = coordinate
    }
    
}
