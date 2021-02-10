//
//  MapDataSource.swift
//  ARKitImageRecognition
//
//  Created by Duy Nguyen on 8/31/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import MapKit

class MapDataSource {
    
    static let mapDataSource = MapDataSource()
    
    
    
    public let locations : BehaviorSubject<[Location]> = BehaviorSubject<[Location]>(value: TestData.locations)
    
    public let coordinateSpan : BehaviorSubject<MKCoordinateSpan> = BehaviorSubject<MKCoordinateSpan>(value: TestData.initialSpan)
    
    public let coordinateToDisplay: BehaviorSubject<CLLocationCoordinate2D> = BehaviorSubject<CLLocationCoordinate2D>(value: TestData.initialCoordinate)
    
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
    
    public let isSearchBarHidden : BehaviorSubject<Bool> = BehaviorSubject<Bool>(value: false)
    public let isCollectionViewHidden: BehaviorSubject<Bool> = BehaviorSubject<Bool>(value: false)
    
    public let annotationIsSelected : BehaviorSubject<Bool> = BehaviorSubject<Bool>(value: false)
}


struct TestData{

    static let initialSpan = MKCoordinateSpan(latitudeDelta: 0.09218215942382812, longitudeDelta: 0.054290771484375)
    static let initialCoordinate = CLLocationCoordinate2D(latitude: 37.40179847717285, longitude: -122.08379554748535)
    
    static let defaultSelectedSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.025)

    static let locations = [
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

}
