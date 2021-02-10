//
//  messagePanelView.swift
//  ARKitImageRecognition
//
//  Created by Duy Nguyen on 9/24/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class MessagePanelView: UIView {

    var messageLabel : UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configLabel()
        setVisualEffectViews()
        
        accessibilityIdentifier = "MessagePanelView"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setMessage(_ message: String) {
        messageLabel.text = message
    }
    
    func configLabel(){
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = .systemFont(ofSize: 18)
        messageLabel.lineBreakMode = .byTruncatingTail
    }
    
    func setVisualEffectViews() {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        let blurEffect = UIBlurEffect(style: .extraLight)
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let visualEffectLabelView = UIVisualEffectView(effect: vibrancyEffect)
        visualEffectLabelView.translatesAutoresizingMaskIntoConstraints = false
        
        visualEffectLabelView.contentView.addSubview(messageLabel)
        visualEffectView.contentView.addSubview(visualEffectLabelView)

        addSubview(visualEffectView)
        
        NSLayoutConstraint.activate([
            visualEffectView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.7),
            visualEffectView.widthAnchor.constraint(equalTo: messageLabel.widthAnchor, constant: 16),
            
            visualEffectLabelView.heightAnchor.constraint(equalTo: visualEffectView.contentView.heightAnchor),
            visualEffectLabelView.widthAnchor.constraint(equalTo: messageLabel.widthAnchor),
            visualEffectLabelView.centerXAnchor.constraint(equalTo: visualEffectView.centerXAnchor),
            visualEffectLabelView.centerYAnchor.constraint(equalTo: visualEffectView.centerYAnchor),
            
            messageLabel.centerYAnchor.constraint(equalTo: visualEffectLabelView.contentView.centerYAnchor),
            messageLabel.centerXAnchor.constraint(equalTo: visualEffectLabelView.contentView.centerXAnchor),
        ])
        
    }
    
}
