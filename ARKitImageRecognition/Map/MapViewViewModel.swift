//
//  MapViewViewModel.swift
//  ARKitImageRecognition
//
//  Created by Duy Nguyen on 8/14/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import MapKit


struct MapViewViewModel {
    let annotationIndex : String?
    let displayRegion : MKCoordinateRegion?
    var locations : [Location] = [Location]()
    var annotationIsSelected : Bool
}
