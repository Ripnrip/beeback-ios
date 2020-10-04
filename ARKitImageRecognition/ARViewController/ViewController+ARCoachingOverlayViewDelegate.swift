//
//  ViewController+ARCoachingOverlayViewDelegate.swift
//  ARKitImageRecognition
//
//  Created by Duy Nguyen on 9/23/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import ARKit

extension ViewController: ARCoachingOverlayViewDelegate {
    
    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
    }
    
    
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        didDectectPlane = true
        statusViewController.scheduleMessage("Tap Screen to Select Plane", inSeconds: 2, messageType: .contentPlacement)
    }
    
    
    func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {}
    
    func setOverlay(){
        
        //1. Link The GuidanceOverlay To Our Current Session
        self.guidanceOverlay.session = self.sceneView.session
        self.guidanceOverlay.delegate = self
        self.sceneView.addSubview(self.guidanceOverlay)
        
        //2. Set It To Fill Our View
        NSLayoutConstraint.activate([
          self.guidanceOverlay.topAnchor.constraint(equalTo: self.view.topAnchor),
          self.guidanceOverlay.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
          self.guidanceOverlay.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
          self.guidanceOverlay.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
          ])
        
        guidanceOverlay.translatesAutoresizingMaskIntoConstraints = false
        
        self.guidanceOverlay.activatesAutomatically = false

    }
    
    func activateGuidanceOverlay(automatically: Bool, forDetectionType goal: ARCoachingOverlayView.Goal) {
        //3. Enable The Overlay To Activate Automatically Based On User Preference
        self.guidanceOverlay.activatesAutomatically = automatically
        
        //4. Set The Purpose Of The Overlay Based On The User Preference
        self.guidanceOverlay.goal = goal
    }
}
