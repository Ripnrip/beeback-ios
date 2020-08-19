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
import RxMKMapView


class MapViewController: UIViewController, MKMapViewDelegate, Storyboarded {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBarView: SearchBarView?
    @IBInspectable var labelTitle: String?
    
    @IBOutlet weak var locationCollectionView: UIView!
    
    private lazy var locationCollectionVC: LocationCollectionViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        var viewController = storyboard.instantiateViewController(
            withIdentifier: "LocationCollectionViewController") as! LocationCollectionViewController
        
        self.add(asChildViewController: viewController, to: locationCollectionView)
        
        return viewController
    }()
    
    var mapReceivedDoubleTap = false
    var searchBarShadowView: UIView!
    
    var mapViewViewModel = MapViewViewModel.sharedViewModel
    private let disposeBag = DisposeBag()
}

// MARK: - View Lifecycle
extension MapViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapViewViewModel.locations.onNext(testData)
        mapViewViewModel.locations.observeOn(MainScheduler.instance).map(locationContentViewModels).bind(
            to: locationCollectionVC.locationContentViewModels).disposed(by: disposeBag)
        
        
        initialLocationSetup()
        searchBarViewFormat()
        mapViewSetup()
    }
    
    func locationContentViewModels(from locations: [Location]) -> [LocationContentViewModel] {
        var viewmodels : [LocationContentViewModel] = []
        for location in locations {
            viewmodels.append(LocationContentViewModel(location: location))
        }
        return viewmodels
    }
    
    func customPinAnnotationViews(from locations: [Location]) -> [CustomPinAnnotation]{
        var annotations : [CustomPinAnnotation] = [CustomPinAnnotation]()
        for location in locations {
            let pointAnnotation = CustomPinAnnotation()
            pointAnnotation.getData(from: location)
            annotations.append(pointAnnotation)
        }
        return annotations
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
    
    func initialLocationSetup(){
        mapViewViewModel.coordinateSpan.onNext(MKCoordinateSpan(latitudeDelta: 0.09218215942382812, longitudeDelta: 0.054290771484375))
        mapViewViewModel.coordinateToDisplay.onNext(CLLocationCoordinate2D(latitude: 37.40179847717285, longitude: -122.08379554748535))
    }
    
    
}


// MARK: MKMapViewDelegate
extension MapViewController {
    private func mapViewSetup() {
        mapViewViewModel.regionToDisplay().asObservable().subscribe(onNext: {
            [weak self] (region) in
            self!.mapView.setRegion(region, animated: true)
            
        }).disposed(by: disposeBag)
        
        mapViewViewModel.annotationIndexToDisplay.asObservable().subscribe(onNext: {
            [weak self] index in
            if let annotations = self?.mapView.annotations{
                for annotation in annotations {
                    if annotation.title == index {
                        self!.mapView.selectAnnotation(annotation, animated: true)
                    }
                }
            }
            
        }).disposed(by: disposeBag)
        
        mapViewViewModel.locations.asDriver(onErrorJustReturn: []).map(customPinAnnotationViews).drive(mapView.rx.annotations).disposed(by: disposeBag)
        
        rxDidSelectAnnotationView()
        rxDidDeselectAnnotationView()
        
        mapView.rx.setDelegate(self).disposed(by: disposeBag)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapMap))
        tap.delegate = self
        self.mapView.addGestureRecognizer(tap)
        hideSearchBarSetup()
        hideCollectionViewSetup()
    }
    
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
    
    
    func rxDidSelectAnnotationView() {
        mapView.rx.didSelectAnnotationView.asDriver().drive(onNext: { [weak self] (annotationView) in
            self!.mapViewViewModel.coordinateSpan.onNext(MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.025))
            self!.mapViewViewModel.coordinateToDisplay.onNext(annotationView.annotation!.coordinate)
            UIView.animate(withDuration: 0.2,
                           delay: 0.0,
                           options: .curveEaseInOut,
                           animations: {
                            annotationView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                            annotationView.centerOffset = CGPoint(x: 0, y: -annotationView.frame.size.height / 2)
            })
        }).disposed(by: disposeBag)
    }
    
    func rxDidDeselectAnnotationView() {
        mapView.rx.didDeselectAnnotationView.asDriver().drive(onNext: { (annotationView) in
            UIView.animate(withDuration: 0.2,
                           delay: 0.0,
                           options: .curveEaseInOut,
                           animations: {
                            annotationView.transform = CGAffineTransform(scaleX: 1, y: 1)
                            annotationView.centerOffset = CGPoint(x: 0, y: -annotationView.frame.size.height / 2)
            })
        }).disposed(by: disposeBag)
    }
    
    func hideSearchBarSetup(){
        mapViewViewModel.isSearchBarHidden.subscribe(onNext: { [weak self] (value) in
            if value == self?.searchBarView!.isHidden {
                return
            }
            
            if value {
                self?.searchBarView?.slideOut()
                self?.searchBarShadowView?.slideOut()
            } else {
                self?.searchBarView?.slideIn()
                self?.searchBarShadowView?.slideIn()
            }
        }).disposed(by: disposeBag)
    }
    
    func hideCollectionViewSetup(){
        mapViewViewModel.isCollectionViewHidden.subscribe(onNext: { [weak self] (value) in
            if value == self?.locationCollectionView!.isHidden {
                return
            }
            
            if value {
                self?.locationCollectionView?.slideOut()
            } else {
                self?.locationCollectionView?.slideIn()
            }
        }).disposed(by: disposeBag)
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
            self.mapViewViewModel.isSearchBarHidden.onNext(false)
            self.mapViewViewModel.isCollectionViewHidden.onNext(false)
        } else {
            self.mapViewViewModel.isSearchBarHidden.onNext(true)
            self.mapViewViewModel.isCollectionViewHidden.onNext(true)
        }
    }
    
}
