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

class MapViewViewModel {
    static let sharedViewModel = MapViewViewModel()
    
    public let regionToDisplay : BehaviorSubject<MKCoordinateRegion> = BehaviorSubject<MKCoordinateRegion>(value: MKCoordinateRegion())
    
    public let locations : BehaviorSubject<[Location]> = BehaviorSubject<[Location]>(value: [])
    
    public let coordinateSpan : BehaviorSubject<MKCoordinateSpan> = BehaviorSubject<MKCoordinateSpan>(value: MKCoordinateSpan())
}
