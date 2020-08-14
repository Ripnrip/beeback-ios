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
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    public var locationContentViewModels = BehaviorSubject<[LocationContentViewModel]>(
        value: [])
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // TODO: - Move constants to a config file
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
        
        setupBinding()
    }

    private func setupBinding() {
        collectionView.register(UINib(nibName: "LocationCollectionViewCell", bundle: nil),
        forCellWithReuseIdentifier: "LocationCollectionViewCell")
        
        
        
        locationContentViewModels.bind(to: collectionView.rx.items(cellIdentifier: "LocationCollectionViewCell", cellType: LocationCollectionViewCell.self)){
            (row, viewmodel, cell) in
            cell.locationContentView.viewModel = viewmodel
        }.disposed(by: disposeBag)

        
        
        // TODO: Need to select Annotation too 
        collectionView.rx.modelSelected(LocationContentViewModel.self).subscribe(onNext: {
            viewmodel in
            
            do {
                let coordinateSpan = try MapViewViewModel.sharedViewModel.coordinateSpan.value()
                let region = MKCoordinateRegion(
                    center: viewmodel.coordinate,
                    span: coordinateSpan)
                
                MapViewViewModel.sharedViewModel.regionToDisplay.onNext(region)
            
            } catch {
                print("error")
            }
            
            

        }).disposed(by: disposeBag)
    }
}

extension LocationCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width * 2 / 3
        let height = width * 9 / 20
        
        print("width: \(width)")
        print("height: \(height)")
        
        
        return CGSize(width: width, height: height)
    }
}
