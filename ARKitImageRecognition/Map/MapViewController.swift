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
    
    weak var coordinator: MainCoordinator?
    
    let mapDataSource = MapDataSource.mapDataSource
    
    private lazy var locationCollectionVC: LocationCollectionViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        var viewController = storyboard.instantiateViewController(
            withIdentifier: "LocationCollectionViewController") as! LocationCollectionViewController
        
        self.add(asChildViewController: viewController, to: locationCollectionView)
        
        return viewController
    }()
    
    var mapReceivedDoubleTap = false
    var searchBarShadowView: UIView!
    
    
    
    private let disposeBag = DisposeBag()
    
    public func mapViewViewModel() -> Observable<MapViewViewModel>{
        return Observable.combineLatest(
            mapDataSource.annotationIndexToDisplay.asObservable(),
            mapDataSource.regionToDisplay().asObservable(),
            mapDataSource.locations.asObservable(),
            mapDataSource.annotationIsSelected.asObservable()) {
                (index,
                regionToDisplay,
                locations,
                annotationIsSelected) in
                    return MapViewViewModel(annotationIndex: index,
                                            displayRegion: regionToDisplay,
                                            locations: locations,
                                            annotationIsSelected:annotationIsSelected)
        }
    }
}

// MARK: - View Lifecycle
extension MapViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapDataSource.locations.observeOn(MainScheduler.instance).map(locationContentViewModels).bind(
            to: locationCollectionVC.locationContentViewModels).disposed(by: disposeBag)
            
        
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
    
    func customPinAnnotationViews(from mapVM: MapViewViewModel) -> [CustomPinAnnotation]{
        var annotations : [CustomPinAnnotation] = [CustomPinAnnotation]()
        
        for location in  mapVM.locations {
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
}


// MARK: MKMapViewDelegate
extension MapViewController {
    private func mapViewSetup() {
        
        mapViewViewModel().subscribe(onNext: { [weak self] (mapVM) in
            self!.mapView.setRegion(mapVM.displayRegion!, animated: true)
            
            if mapVM.annotationIsSelected == true {
                // display annotations if selected
                if let annotations = self?.mapView.annotations {
                    for annotation in annotations {
                        if annotation.title == mapVM.annotationIndex {
                            self?.mapView.selectAnnotation(annotation, animated: true)
                        }
                    }
                }
            }
            
            if self?.mapView.annotations.count == self!.customPinAnnotationViews(from: mapVM).count {
                return
            }
            
            self!.mapView.addAnnotations(self!.customPinAnnotationViews(from: mapVM))
            
            
        }).disposed(by: disposeBag)
        
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
//            self!.mapDataSource.coordinateSpan.onNext(
//                MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.025))
//
//            self!.mapDataSource.coordinateToDisplay.onNext(
//                annotationView.annotation!.coordinate)
            
            UIView.animate(withDuration: 0.2,
                           delay: 0.0,
                           options: .curveEaseInOut,
                           animations: {
                            annotationView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                            annotationView.centerOffset = CGPoint(x: 0, y: -annotationView.frame.size.height / 2)
            }
            )
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
        mapDataSource.isSearchBarHidden.subscribe(onNext: { [weak self] (value) in
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
        mapDataSource.isCollectionViewHidden.subscribe(onNext: { [weak self] (value) in
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



