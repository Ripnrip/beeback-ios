//
//  ProfileTrophesCollectionViewCell.swift
//  ARKitImageRecognition
//
//  Created by Gurinder Singh on 5/29/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class ProfileTrophesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var trophyImageView: UIImageView!
    @IBOutlet weak var trophyLabel: UILabel!
    @IBOutlet weak var trophyEarnedDateLabel: UILabel!
    
    static let reuseIdentifier = "trophyCell"
}
