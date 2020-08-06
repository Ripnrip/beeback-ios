//
//  LocationCollectionViewCell.swift
//  ARKitImageRecognition
//
//  Created by Duy Nguyen on 8/5/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class LocationCollectionViewCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setup()
    }
    
    func setup() {
        backgroundColor = .green
        print("cell width: \(bounds.width)")
        
//        let view = loadViewFromNib()
//        view.frame = bounds
//        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        
        let nib = UINib(nibName: "LocationCollectionViewCell", bundle: bundle)
        
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
        
    }
}
