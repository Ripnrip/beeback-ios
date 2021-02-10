//
//  MapViewController+UIGestureRecognizerDelegate.swift
//  ARKitImageRecognition
//
//  Created by Duy Nguyen on 8/31/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa


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
            self.mapDataSource.isSearchBarHidden.onNext(false)
            self.mapDataSource.isCollectionViewHidden.onNext(false)
        } else {
            self.mapDataSource.isSearchBarHidden.onNext(true)
            self.mapDataSource.isCollectionViewHidden.onNext(true)
        }
    }
    
}
