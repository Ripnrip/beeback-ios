//
//  UIViewExtension.swift
//  ARKitImageRecognition
//
//  Created by Duy Nguyen on 8/6/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func createShadowView(shadowOffset: CGSize, shadowRadius: CGFloat, cornerRadius: CGFloat) -> UIView {
        let shadowView = UIView(frame: self.frame)
        
        shadowView.backgroundColor = .clear
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.35
        shadowView.layer.shadowOffset = shadowOffset
        shadowView.layer.shadowRadius = shadowRadius
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
        
        return shadowView
    }
    
}
