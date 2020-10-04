//
//  ViewController+ARSCNViewDelegate.swift
//  ARKitImageRecognition
//
//  Created by Duy Nguyen on 9/23/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import ARKit

extension ViewController: ARSCNViewDelegate {
    
    /// Creates a new AR configuration to run on the `session`.
    /// - Tag: ARReferenceImage-Loading
    func resetTracking() {
        
        didDectectPlane = false
        didGameStart = false
        focusPlaneSelector.hide()
        
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.detectionImages = referenceImages
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        statusViewController.showMessage("Look around to discover nearby items", autoHide: true)
    }
    
    func detectPlane(_ type: ARWorldTrackingConfiguration.PlaneDetection){
        
        arTrackingBox.removeFromParentNode()
        
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = type
            activateGuidanceOverlay(automatically: true, forDetectionType: .horizontalPlane)

        configuration.detectionImages = referenceImages
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        
    }
    
    // MARK: - ARSCNViewDelegate (Image detection results)
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        
        DispatchQueue.main.async {
            if self.didDectectPlane && !self.didGameStart {
                self.updateFocusPlaneSelector(isObjectVisible: false)
            }
            
            // If the object selection menu is open, update availability of items
            }
        }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        DispatchQueue.main.async {
            self.statusViewController.cancelScheduledMessage(for: .trackingStateEscalation)
            self.statusViewController.showMessage("SURFACE DETECTED")
        }
    }
    
    
    /// - Tag: ARImageAnchor-Visualizing
    func rendererBKP(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        updateQueue.async {
            
            // Create a plane to visualize the initial position of the detected image.
            let plane = SCNPlane(width: referenceImage.physicalSize.width,
                                 height: referenceImage.physicalSize.height)
            let planeNode = SCNNode(geometry: plane)
            planeNode.opacity = 0.25
            
            /*
             `SCNPlane` is vertically oriented in its local coordinate space, but
             `ARImageAnchor` assumes the image is horizontal in its local space, so
             rotate the plane to match.
             */
            planeNode.eulerAngles.x = -.pi / 2
            
            /*
             Image anchors are not tracked after initial detection, so create an
             animation that limits the duration for which the plane visualization appears.
             */
            planeNode.runAction(self.imageHighlightAction)
            
            // Add the plane visualization to the scene.
            node.addChildNode(planeNode)
            
            //add item to plane
            //animate item
            // Create a new scene
            let scene = SCNScene(named: "art.scnassets/ship.scn")!
            //scene.rootNode.position = planeNode.position
            // Set the scene to the view
            self.sceneView.scene.rootNode.addChildNode(scene.rootNode)
            
            //let grow = SCNAction.scale(to: 1 * 2 + 1, duration: 1)
            //scene.rootNode.runAction(grow)
            
            //scene.rootNode.scale = SCNVector3(-3,1,1)
            let tempScale: CGFloat = 1.0
            scene.rootNode.scale = SCNVector3(tempScale, tempScale, tempScale)
            // grow from 1 to tempScale, then back to 1
            let grow = SCNAction.scale(to: tempScale, duration: 4.1)
            let shrink = SCNAction.scale(to: 0.1, duration: 2.1)
            let sequence = SCNAction.sequence([shrink, grow])
            //scene.rootNode.runAction(SCNAction.repeatForever(sequence))
            scene.rootNode.runAction(sequence)
            //let action = SCNAction.repeatForever(SCNAction.rotate(by: .pi, around: SCNVector3(0, 1 , 0), duration: 0.5))
            //scene.rootNode.runAction(SCNAction.repeatForever(action))
            
            //scene.rootNode.runAction(SCNAction.repeatForever(grow))
            //planeNode.addChildNode(scene.rootNode)
        }
        DispatchQueue.main.async {
            let imageName = referenceImage.name ?? ""
            self.statusViewController.cancelAllScheduledMessages()
            self.statusViewController.showMessage("Detected image “\(imageName)”")
        }
    }
    
    func addARTrackingBox() {
//        arTrackingBox.position = SCNVector3(0,-0.2,-0.5)
        setARTrackingBoxPosition()
        //animate node
        let action = SCNAction.repeatForever(SCNAction.rotate(by: .pi, around: SCNVector3(0, 1, 0), duration: 5))
        arTrackingBox.runAction(action)
        
        self.sceneView.tag = 0
        self.sceneView.scene.rootNode.addChildNode(arTrackingBox)
        
    }
    
    var imageHighlightAction: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOut(duration: 0.5),
            .removeFromParentNode()
        ])
    }
    
    
    func setARTrackingBoxPosition() {
        if let query = sceneView.getRaycastQuery(for: .any),
           let result = sceneView.castRay(for: query).first
           {
            self.arTrackingBox.simdWorldTransform = result.worldTransform
            self.arTrackingBox.simdPosition = result.worldTransform.translation
        }
    }
    
    func getPositionFromRaycast() -> ARRaycastResult? {
        guard let camera = session.currentFrame?.camera, case .normal = camera.trackingState,
              let query = sceneView.getRaycastQuery(for: .horizontal),
              let result = sceneView.castRay(for: query).first else {
            print("Failed to get position")
            return nil
        }
        return result
    }
    
}
