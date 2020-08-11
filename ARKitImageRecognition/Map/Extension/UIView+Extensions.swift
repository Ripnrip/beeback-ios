//
//  UIView+Extensions.swift
//  ARKitImageRecognition
//
//  Created by Duy Nguyen on 8/10/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
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

    
    func slideIn(_ duration: TimeInterval? = 0.2, distance: CGFloat = 70.0, onCompletion: (() -> Void)? = nil) {

        let finalYPosition = self.frame.origin.y + (distance * locationYOnScreen())
        self.isHidden = false
        self.alpha = 0
        
        UIView.animate(withDuration: duration!,
                       delay: 0.0,
                       options: .curveEaseOut,
                       animations: {
                        self.frame.origin.y = finalYPosition
                        self.alpha = 1
        },
                       completion: { (value: Bool) in
        })
    }
    
    func slideOut(_ duration: TimeInterval? = 0.2, distance: CGFloat = 70.0, onCompletion: (() -> Void)? = nil) {
        
        let finalYPosition = self.frame.origin.y - (distance * locationYOnScreen())
        UIView.animate(withDuration: duration!,
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: {
                        self.frame.origin.y = finalYPosition
                        self.alpha = 0
        },
                       completion: { (value: Bool) in
                        self.isHidden = true
        })
    }
    
    func locationYOnScreen() -> CGFloat {
        if self.frame.origin.y <= UIScreen.main.bounds.height / 2 {
            return 1.0
        } else {
            return -1.0
        }
    }
}
