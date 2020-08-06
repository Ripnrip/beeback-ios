//
//  CardCollectionViewCell.swift
//  ARKitImageRecognition
//
//  Created by Duy Nguyen on 8/4/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cardContentView: CardContentView!
    
    override func awakeFromNib() {
        backgroundColor = .clear
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = .init(width: 0, height: 4)
        layer.shadowRadius = 12
    }
}
