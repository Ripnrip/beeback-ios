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
    
    
    func slideIn(_ duration: TimeInterval? = 0.3, distance: CGFloat = 70.0, onCompletion: (() -> Void)? = nil) {
        self.isHidden = false
        self.alpha = 0
        
        UIView.animate(withDuration: duration!,
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: {
                        self.alpha = 1
                        self.transform = CGAffineTransform.identity
        })
    }
    
    func slideOut(_ duration: TimeInterval? = 0.3, distance: CGFloat = 70.0, onCompletion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration!,
                       delay: 0.0,
                       options: .curveEaseOut,
                       animations: {
                        self.alpha = 0
                        self.transform = CGAffineTransform(translationX: 0,
                                                           y: distance * self.slideDirection())},
                       completion: { (value: Bool) in
                        self.isHidden = true
        })
    }
    
    func slideDirection() -> CGFloat {
        if self.frame.origin.y <= UIScreen.main.bounds.height / 2 {
            return -1.0
        } else {
            return 1.0
        }
    }
    
    func slideOut1(_ duration: TimeInterval? = 0.3,
                   distance: CGFloat = 70.0,
                   onCompletion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration!,
                       delay: 0.0,
                       options: .curveEaseOut,
                       animations: {
                        self.alpha = 0
                        self.transform = CGAffineTransform(translationX: 0,
                                                           y: distance * self.slideDirection())},
                       completion: { (value: Bool) in
                        onCompletion?(value)
//                        self.isHidden = true
        })
    }
}

extension UIViewController {
    public func add(asChildViewController viewController: UIViewController,to parentView:UIView) {
        // Add Child View Controller
        addChild(viewController)
        
        // Add Child View as Subview
        parentView.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = parentView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    public func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParent()
    }
}
