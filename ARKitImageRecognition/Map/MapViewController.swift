//
//  MapViewController.swift
//  ARKitImageRecognition
//
//  Created by Duy Nguyen on 8/3/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa

// TODO: - Convert to RxMap, and use rx with collection view
class MapViewController: UIViewController, MKMapViewDelegate, Storyboarded {
    
    //TESTING DATA
    var locationData: Array<LocationContentViewModel> = Array<LocationContentViewModel>()
    let pinImages: Array<UIImage> = [
        UIImage(named: "locationPinPerson")!,
        UIImage(named: "locationPinTicket")!,
        UIImage(named: "locationPinMessage")!,
        UIImage(named: "locationPinBook")!,
    ]
    // END TESTING
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBarView: SearchBarView?
    @IBOutlet weak var collectionView: UICollectionView!
    @IBInspectable var labelTitle: String?
    
    var mapReceivedDoubleTap = false
    var searchBarShadowView: UIView!
    var defaultCoordinateSpan: MKCoordinateSpan = MKCoordinateSpan()
    
    private let disposeBag = DisposeBag()
}

// MARK: - View Lifecycle
extension MapViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        registerXib()
        
        locationData = getTestData()
        
        mapView.delegate = self
        generateMapPointAnnotations()
        
        searchBarViewFormat()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapMap))
        tap.delegate = self
        self.mapView.addGestureRecognizer(tap)
        
        // TODO: - Move constants to a config file
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.showsHorizontalScrollIndicator = false
        
    }
    
    func getTestData() -> Array<LocationContentViewModel> {
        var testData = Array<LocationContentViewModel>()
        
        testData.append(LocationContentViewModel(image: nil,
                                                 name: "Computer History Museum",
                                                 subtitle: "Exhibits on early computers, the growth of the Internet, industry pioneers & more.",
                                                 address: "1401 N Shoreline Blvd, Mountain View, CA 94043",
                                                 distance: "0.5 mi",
                                                 coordinate: CLLocationCoordinate2D(latitude: 37.414459, longitude: -122.077049)))
        
        testData.append(LocationContentViewModel(image: nil,
                                                 name: "Googleplex",
                                                 subtitle: "The global headquarters of Google",
                                                 address: "1600 Amphitheatre Pkwy, Mountain View, CA 94043",
                                                 distance: "3.2 mi",
                                                 coordinate: CLLocationCoordinate2D(latitude: 37.423199, longitude: -122.084068)))
        
        testData.append(LocationContentViewModel(image: nil,
                                                 name: "Dana Street Roasting Company",
                                                 subtitle: "A relaxed space with specialty & housemade blends",
                                                 address: "744 W Dana St, Mountain View, CA 94041",
                                                 distance: "5.0 mi",
                                                 coordinate: CLLocationCoordinate2D(latitude: 37.392471, longitude: -122.078918)))
        return testData
    }
    
    func registerXib() {
        collectionView.register(UINib(nibName: "LocationCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "LocationCollectionViewCell")
    }
    
    func searchBarViewFormat() {
        if let searchBar = searchBarView {
            searchBar.translatesAutoresizingMaskIntoConstraints = false
            let textFieldHeight = UIScreen.main.bounds.height * 0.06
            let cornerRadius = textFieldHeight / 2
            searchBar.addConstraint(NSLayoutConstraint(item: searchBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: textFieldHeight))
            
            searchBar.layer.cornerRadius = textFieldHeight / 2
            searchBar.layer.masksToBounds = true
            
            searchBarShadowView = searchBar.createShadowView(shadowOffset: .init(width: 0, height: 5), shadowRadius: 4.0, cornerRadius: cornerRadius)
            
            searchBar.superview?.insertSubview(searchBarShadowView, belowSubview: searchBar)
        }
        else {
            print("searchBarView is not available")
        }
        
        

        
    }
    
    func generateMapPointAnnotations(){
        var totalLat: Array<CLLocationDegrees> = Array<CLLocationDegrees>()
        var totalLong: Array<CLLocationDegrees> = Array<CLLocationDegrees>()
        
        for viewmodel in locationData{
            //            let pointAnnotation = MKPointAnnotation()
            let pointAnnotation = CustomPinAnnotation()
            pointAnnotation.title = viewmodel.locationName
            pointAnnotation.coordinate = viewmodel.coordinate
            
            let pinImagesIndex = locationData.firstIndex(of: viewmodel)! % pinImages.count
            pointAnnotation.image = pinImages[pinImagesIndex]
            
            totalLat.append(viewmodel.coordinate.latitude)
            totalLong.append(viewmodel.coordinate.longitude)
            
            mapView.addAnnotation(pointAnnotation)
        }
        
        let centerCoordinate = CLLocationCoordinate2D(
            latitude: (totalLat.reduce(0.0, +) / Double(totalLat.count))  - 0.01,
            longitude: totalLong.reduce(0.0, +) / Double(totalLong.count)
        )
        let coordinateSpanLat = Double(totalLat.max()! - totalLat.min()!) * 3
        let coordinateSpanLong = Double(totalLong.max()! - totalLong.min()!) * 3
        
        let coordinateSpan = MKCoordinateSpan(latitudeDelta: coordinateSpanLat, longitudeDelta: coordinateSpanLong)
        defaultCoordinateSpan = MKCoordinateSpan(latitudeDelta: coordinateSpanLat / 2, longitudeDelta: coordinateSpanLong / 2)
        
        let initalRegion = MKCoordinateRegion(center: centerCoordinate, span: coordinateSpan)
        mapView.setRegion(initalRegion, animated: true)
    }
}
// MARK: Rx Setup
//extension MapViewController {
//    func setupLocationObserver() {
//        LocationDataManager.locationDataManager.locations.asObservable().subscribe(onNext: {
//            [unowned self] locations in
//            self.locationData = self.convertLocationToViewModel(locations: locations)
//            }).disposed(by: disposeBag)
//    }
//
//
//    private func convertLocationToViewModel(locations: Array<Location>) -> Array<LocationContentViewModel> {
//        var locationViewModels: Array<LocationContentViewModel> = []
//        for location in locations {
//            locationViewModels.append(LocationContentViewModel(location: location))
//        }
//
//        return locationViewModels
//    }
//}

// MARK: MKMapViewDelegate
extension MapViewController {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !annotation.isKind(of: CustomPinAnnotation.self){
            var pinAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "DefaultPinView")
            
            if pinAnnotationView == nil {
                pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "DefaultPinView")
            }
            return pinAnnotationView
        }
        
        var view: CustomPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: "customPinAnnotation") as? CustomPinAnnotationView
        
        if view == nil {
            view = CustomPinAnnotationView(annotation: annotation, reuseIdentifier: "customPinAnnotation")
        }
        
        let annotation = annotation as! CustomPinAnnotation
        view?.image = annotation.image
        view?.annotation = annotation
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.setRegion(MKCoordinateRegion(center: view.annotation!.coordinate, span: defaultCoordinateSpan), animated: true)
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                        view.centerOffset = CGPoint(x: 0, y: -view.frame.size.height / 2)
        })
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        view.transform = CGAffineTransform(scaleX: 1, y: 1)
                        view.centerOffset = CGPoint(x: 0, y: -view.frame.size.height / 2)
        })
    }
    
}

// MARK: UIGestureRecognizerDelegate

// TODO: - Need to adjust gestureRecognizer to not hide searchbar and collectionview when selecting a pin
extension MapViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !touch.isKind(of: MKAnnotationView.self)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if otherGestureRecognizer.isKind(of: UITapGestureRecognizer.self) {
            let tr = otherGestureRecognizer as! UITapGestureRecognizer
            if tr.numberOfTapsRequired == 2 {
                mapReceivedDoubleTap = true
            }
        }
        
        return false
    }
    
    @objc func didTapMap(){
        if mapReceivedDoubleTap {
            mapReceivedDoubleTap = false
            return
        }
        guard let searchBar = searchBarView else {
            print("searchBarView is not available")
            return
        }
        
        if searchBar.isHidden {
            searchBar.slideIn()
            searchBarShadowView.slideIn()
            collectionView.slideIn()
        } else {
            searchBar.slideOut()
            searchBarShadowView.slideOut()
            collectionView.slideOut()
        }
    }
    
}


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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! LocationCollectionViewCell
        cell.locationContentView.viewModel = locationData[indexPath.row]
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectAnnotationOnMap(locationData[indexPath.row].locationName)
    }
    
    private func selectAnnotationOnMap(_ locationName: String) {
        for annotation in mapView.annotations {
            if annotation.title! == locationName {
                mapView.setRegion(MKCoordinateRegion(center: annotation.coordinate, span: defaultCoordinateSpan), animated: true)
                mapView.selectAnnotation(annotation, animated: true)
                return
            }
        }
    }
}


// MARK: - UICollectioNViewDelegateFlowLayout
extension MapViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width * 2 / 3
        let height = width * 9 / 20
        
        return CGSize(width: width, height: height)
    }
}

