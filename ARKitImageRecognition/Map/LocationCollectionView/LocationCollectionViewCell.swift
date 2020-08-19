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
    var disabledHighlightedAnimation = false
    let cardHighlightedFactor: CGFloat = 0.95
    
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
        let shadowView = locationContentView.createShadowView(
                shadowOffset: .init(width: 0, height: 12),
                shadowRadius: 6.0,
                cornerRadius: cornerRadius)
        insertSubview(shadowView, at: 0)
    }
    
}

// MARK: - Animation when touch
extension LocationCollectionViewCell {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animate(isHighlighted: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animate(isHighlighted: false)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animate(isHighlighted: false)
    }
    
    private func animate(isHighlighted: Bool, completion: ((Bool) -> Void)?=nil){
        if disabledHighlightedAnimation{
            return
        }
        
        let animationOptions: UIView.AnimationOptions = [.allowUserInteraction]
        
        if isHighlighted {
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 0,
                           options: animationOptions,
                           animations: {
                            self.transform = .init(scaleX: self.cardHighlightedFactor,
                                                   y: self.cardHighlightedFactor)
            }, completion: completion)
        } else {
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 0,
                           options: animationOptions,
                           animations: {
                            self.transform = .identity
            }, completion: completion)
        }
    }
}
