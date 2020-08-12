//
//  LocationDataManager.swift
//  ARKitImageRecognition
//
//  Created by Duy Nguyen on 8/11/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

let testData = [
    Location(name: "Computer History Museum",
             description: "Exhibits on early computers, the growth of the Internet, industry pioneers & more.",
             address: "1401 N Shoreline Blvd, Mountain View, CA 94043",
             longtitude: 37.414459,
             latitude: -122.077049),
    Location(name: "Googleplex",
             description: "The global headquarters of Google",
             address: "1600 Amphitheatre Pkwy, Mountain View, CA 94043",
             longtitude: 37.423199,
             latitude: -122.084068),
    Location(name: "Computer History Museum",
             description: "Exhibits on early computers, the growth of the Internet, industry pioneers & more.",
             address: "1401 N Shoreline Blvd, Mountain View, CA 94043",
             longtitude: 37.392471,
             latitude: -122.078918),
]


class LocationDataManager {
    
    static let locationDataManager = LocationDataManager()
    var locations: BehaviorRelay<[Location]> = BehaviorRelay(value: testData)
}

//MARK: - Get Data
extension LocationDataManager{
}

// MARK: - Data Conversion
extension LocationDataManager {

}
