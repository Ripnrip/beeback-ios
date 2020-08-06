//
//  MapViewController.swift
//  ARKitImageRecognition
//
//  Created by Duy Nguyen on 8/3/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, Storyboarded {
    
    //TESTING DATA
    var locationData: Array<LocationContentViewModel> = Array<LocationContentViewModel>()
    
    // END TESTING
    

    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBInspectable var labelTitle: String?
    
    // MARK: - Properties
    let initialRegion = CLLocation(latitude: 37.4133144, longitude: -122.151307)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerXib()
        
        locationData = getTestData()
        
        // TODO: - Move constants to a config file
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 20
            layout.minimumInteritemSpacing = 0
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        centerToLocation(initialRegion, regionSpan: 0.03)
    }
    
    
    private func centerToLocation(_ location: CLLocation, regionSpan: CLLocationDegrees) {
        let region = MKCoordinateRegion(center: location.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: regionSpan, longitudeDelta: regionSpan))
        mapView.setRegion(region, animated: true)
        
        
    }
    
    
    func getTestData() -> Array<LocationContentViewModel> {
        var testData = Array<LocationContentViewModel>()
        
        testData.append(LocationContentViewModel(image: nil,
                                          name: "Computer History Museum",
                                          subtitle: "Exhibits on early computers, the growth of the Internet, industry pioneers & more.",
                                          address: "1401 N Shoreline Blvd, Mountain View, CA 94043",
                                          distance: "0.5 miles",
                                          coordinate: CLLocationCoordinate2D(latitude: 37.414459, longitude: -122.077049)))
        
        testData.append(LocationContentViewModel(image: nil,
                                          name: "Googleplex",
                                          subtitle: "The global headquarters of Google",
                                          address: "1600 Amphitheatre Pkwy, Mountain View, CA 94043",
                                          distance: "3.2 miles",
                                          coordinate: CLLocationCoordinate2D(latitude: 37.423199, longitude: -122.084068)))
        
        testData.append(LocationContentViewModel(image: nil,
                                          name: "Dana Street Roasting Company",
                                          subtitle: "A relaxed space with specialty & housemade blends",
                                          address: "744 W Dana St, Mountain View, CA 94041",
                                          distance: "5.0 miles",
                                          coordinate: CLLocationCoordinate2D(latitude: 37.392471, longitude: -122.078918)))
        
        return testData
    }
    
    func registerXib() {
        collectionView.register(UINib(nibName: "LocationCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "LocationCollectionViewCell")
//        collectionView.register(UINib(nibName: "\(CardContentView.self)", bundle: nil), forCellWithReuseIdentifier: "cardContentView")
    }
}


// MARK: MKMapViewDelegate
//extension MapViewController: MKMapViewDelegate {
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        <#code#>
//    }
//}


// MARK: - UICollectionViewDataSource
extension MapViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locationData.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "LocationCollectionViewCell", for: indexPath)
    }
    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        let cell = cell as! CardCollectionViewCell
//        cell.cardContentView.viewModel = locationData[indexPath.row]
//    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! LocationCollectionViewCell
//        cell.label.text = locationData[indexPath.row].locationName
    }
    
}


// MARK: - UICollectioNViewDelegateFlowLayout
extension MapViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width * 2 / 3
        let height = width * 2 / 5
        
        print("width: \(width)")
        print("height: \(height)")
        
        return CGSize(width: width, height: height)
    }
}

