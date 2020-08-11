//
//  LocationContentView.swift
//  ARKitImageRecognition
//
//  Created by Duy Nguyen on 8/5/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class LocationContentView: NibView {


    
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var locationSubtitle: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    var viewModel: LocationContentViewModel? {
        didSet {
            locationName.text = viewModel?.locationName
            locationSubtitle.text = viewModel?.locationSubtitle
            address.text = viewModel?.address
            distance.text = viewModel?.distance
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        additionalFormatting()
        
    }
    
    func additionalFormatting() {
        let cornerRadius = distance.bounds.height * 0.25
        print("cornerRadius = \(cornerRadius)")
        distance.layer.cornerRadius = cornerRadius
        distance.layer.masksToBounds = true
    }
    
}
