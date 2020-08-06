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
    
    var viewModel: LocationContentViewModel? {
        didSet {
            locationName.text = viewModel?.locationName
            locationSubtitle.text = viewModel?.locationSubtitle
            address.text = viewModel?.address
        }
    }
    
}
