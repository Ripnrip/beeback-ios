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
    
    public let locations : BehaviorSubject<[Location]> = BehaviorSubject<[Location]>(value: [])
    
    public let coordinateSpan : BehaviorSubject<MKCoordinateSpan> = BehaviorSubject<MKCoordinateSpan>(value: MKCoordinateSpan())
    
    public let coordinateToDisplay: BehaviorSubject<CLLocationCoordinate2D> = BehaviorSubject<CLLocationCoordinate2D>(value: CLLocationCoordinate2D())
    
    public func regionToDisplay() -> Observable<MKCoordinateRegion>{
        return Observable.combineLatest(coordinateSpan.asObservable(), coordinateToDisplay.asObservable()){
            (coordinateSpanOb, coordinateToDisplayOb) in
            
            return MKCoordinateRegion(
                center: coordinateToDisplayOb,
                span: coordinateSpanOb
            )
        }
    }
    
    public let annotationIndexToDisplay : BehaviorSubject<String> = BehaviorSubject<String>(value: String())
    
}

let testData = [
    Location(name: "Computer History Museum",
             description: "Exhibits on early computers, the growth of the Internet, industry pioneers & more.",
             address: "1401 N Shoreline Blvd, Mountain View, CA 94043",
             longtitude: -122.077049,
             latitude: 37.414459,
             type: "locationPinPerson"),
    Location(name: "Googleplex",
             description: "The global headquarters of Google",
             address: "1600 Amphitheatre Pkwy, Mountain View, CA 94043",
            longtitude: -122.084068,
             latitude: 37.423199,
             type: "locationPinTicket"),
    Location(name: "Dana Street Roasting Company",
             description: "A relaxed space with specialty & housemade blends, along with light eats, free WiFi & live jazz.",
             address: "744 W Dana St, Mountain View, CA 94041",
            longtitude: -122.078918,
             latitude: 37.392471,
             type: "locationPinMessage"),
    Location(name: "Palo Alto Junior Museum",
             description: "Free, child-oriented venue with animals like birds & turtles, plus interactive educational exhibits.",
             address: "4050 Middlefield Rd, Palo Alto, CA 94303",
            longtitude: -122.0951445,
             latitude: 37.4170641,
             type: "locationPinBook"),
]
