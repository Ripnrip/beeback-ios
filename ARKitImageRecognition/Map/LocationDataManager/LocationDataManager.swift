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
import MapKit

let testData = [
    Location(name: "Computer History Museum",
             description: "Exhibits on early computers, the growth of the Internet, industry pioneers & more.",
             address: "1401 N Shoreline Blvd, Mountain View, CA 94043",
             longtitude: -122.077049,
             latitude: 37.414459),
    Location(name: "Googleplex",
             description: "The global headquarters of Google",
             address: "1600 Amphitheatre Pkwy, Mountain View, CA 94043",
            longtitude: -122.084068,
             latitude: 37.423199),
    Location(name: "Dana Street Roasting Company",
             description: "A relaxed space with specialty & housemade blends, along with light eats, free WiFi & live jazz.",
             address: "744 W Dana St, Mountain View, CA 94041",
            longtitude: -122.078918,
             latitude: 37.392471),
    Location(name: "Palo Alto Junior Museum",
             description: "Free, child-oriented venue with animals like birds & turtles, plus interactive educational exhibits.",
             address: "4050 Middlefield Rd, Palo Alto, CA 94303",
            longtitude: -122.0951445,
             latitude: 37.4170641),
]


class LocationDataManager {
    
    static let locationDataManager = LocationDataManager()
    var locations: BehaviorRelay<[Location]> = BehaviorRelay(value: testData)
}

//MARK: - Get Data
extension LocationDataManager{
    func toLocationContentViewModels() -> Observable<[LocationContentViewModel]> {
        return locations.asObservable().map { (locations) -> [LocationContentViewModel] in
            var viewmodels : [LocationContentViewModel] = []
            for location in locations {
                viewmodels.append(LocationContentViewModel(location: location))
            }
            return viewmodels
        }
    }
    
}

// MARK: - Data Conversion
extension LocationDataManager {
}
