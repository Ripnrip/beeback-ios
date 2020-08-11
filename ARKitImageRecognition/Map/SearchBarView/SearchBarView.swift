//
//  SearchBarView.swift
//  ARKitImageRecognition
//
//  Created by Duy Nguyen on 8/6/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class SearchBarView: NibView {
    
    @IBOutlet weak var searchBarTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        searchBarFormat()
        
    }
    
    func searchBarFormat() {
        searchBarTextField.backgroundColor = UIColor.clear
        searchBarTextField.borderStyle = .none
        searchBarTextField.translatesAutoresizingMaskIntoConstraints = false
        let textFieldHeight = UIScreen.main.bounds.height * 0.06
        searchBarTextField.addConstraint(NSLayoutConstraint(item: searchBarTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: textFieldHeight))
    }
}
