//
//  LocationCollectionViewCell.swift
//  ARKitImageRecognition
//
//  Created by Duy Nguyen on 8/5/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class LocationCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var locationContentView: LocationContentView!
    
    let cornerRadius: CGFloat = 10.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setup()
    }
    
    func setup() {
        backgroundColor = .clear
        
        locationContentView.layer.cornerRadius = cornerRadius
        locationContentView.layer.masksToBounds = true
        shadowSetup(for: locationContentView)
    }
    
    func shadowSetup(for contentView: UIView) {
        let shadowView = locationContentView.createShadowView(shadowOffset: .init(width: 0, height: 12), shadowRadius: 6.0, cornerRadius: cornerRadius)
        insertSubview(shadowView, at: 0)
    }
}
