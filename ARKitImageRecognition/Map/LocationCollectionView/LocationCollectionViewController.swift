//
//  LocationCollectionViewController.swift
//  ARKitImageRecognition
//
//  Created by Duy Nguyen on 8/14/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MapKit

class LocationCollectionViewController: UIViewController {
    
    weak var coordinator: MainCoordinator?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    public var locationContentViewModels = BehaviorSubject<[LocationContentViewModel]>(
        value: [])
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .clear
        
        // TODO: - Move constants to a config file
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        collectionView.delaysContentTouches = false
                
        setupBinding()
    }
    
    private func setupBinding() {
        collectionView.register(UINib(nibName: "LocationCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "LocationCollectionViewCell")
        
        
        
        locationContentViewModels.bind(to: collectionView.rx.items(cellIdentifier: "LocationCollectionViewCell", cellType: LocationCollectionViewCell.self)){
            (row, viewmodel, cell) in
            cell.locationContentView.viewModel = viewmodel
        }.disposed(by: disposeBag)
        
        
        collectionView.rx.modelSelected(LocationContentViewModel.self).subscribe(onNext: {
            viewmodel in
            self.setLocation(viewmodel: viewmodel)
        }).disposed(by: disposeBag)
        
//        Observable.zip(collectionView.rx.itemSelected, collectionView.rx.modelSelected(LocationContentViewModel.self)).bind {
//            indexPath, model in
//
//
//            self.coordinator?.updateMapLocation()
//
//            OldMapViewViewModel.sharedViewModel.isSearchBarHidden.onNext(true)
//
//            OldMapViewViewModel.sharedViewModel.coordinateSpan.onNext(MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.025))
//            OldMapViewViewModel.sharedViewModel.coordinateToDisplay.onNext(model.coordinate)
//            OldMapViewViewModel.sharedViewModel.annotationIndexToDisplay.onNext(model.locationName)
//        }
//    .disposed(by: disposeBag)
    }
    
    
    func setLocation(viewmodel: LocationContentViewModel) {
        MapDataSource.mapDataSource.isSearchBarHidden.onNext(true)

        MapDataSource.mapDataSource.coordinateToDisplay.onNext(viewmodel.coordinate)
        MapDataSource.mapDataSource.coordinateSpan.onNext(MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.025))
        MapDataSource.mapDataSource.annotationIndexToDisplay.onNext(viewmodel.locationName)
    }
}

extension LocationCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width * 2 / 3
        let height = width * 9 / 20
        return CGSize(width: width, height: height)
    }
}
