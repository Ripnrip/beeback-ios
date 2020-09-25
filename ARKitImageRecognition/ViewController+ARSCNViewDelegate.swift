//
//  ViewController+ARSCNViewDelegate.swift
//  ARKitImageRecognition
//
//  Created by Duy Nguyen on 9/23/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import ARKit

extension ViewController: ARSCNViewDelegate {

    // MARK: - ARSCNViewDelegate (Image detection results)
    /// - Tag: ARImageAnchor-Visualizing
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
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
            
//            if let statusVC = self.statusViewController {
//                self.statusViewController.cancelAllScheduledMessages()
//                self.statusViewController.showMessage("Detected image “\(imageName)”")
//            }
            self.statusViewController.cancelAllScheduledMessages()
            self.statusViewController.showMessage("Detected image “\(imageName)”")
            
//            self.statusViewController.cancelAllScheduledMessages()
//            self.statusViewController.showMessage("Detected image “\(imageName)”")
        }
    }
    
    func addNode() {
        //// General Declarations
         UIGraphicsBeginImageContextWithOptions(self.sceneView.frame.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        
        
        //// Image Declarations
        let beeBackAR = UIImage(named: "BeeBackAR.png")!
        
        //// Picture Drawing
        let picturePath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 50, height: 50))
        context.saveGState()
        picturePath.addClip()
        context.translateBy(x: 0, y: 0)
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -beeBackAR.size.height)
        context.draw(beeBackAR.cgImage!, in: CGRect(x: 0, y: 0, width: beeBackAR.size.width, height: beeBackAR.size.height))
        context.restoreGState()
        
        let scnShape = SCNShape(path: picturePath, extrusionDepth: 0.2)
        let node = SCNNode(geometry: SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.1/2))
        //node.geometry = scnShape
        node.position = SCNVector3(0,0,-0.5)
        
        node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "BeeBackAR.png")!
        //node.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
        
        //animate node
        let action = SCNAction.repeatForever(SCNAction.rotate(by: .pi, around: SCNVector3(0, 1, 0), duration: 5))
        node.runAction(action)
        
        box = node
        self.sceneView.tag = 0
        self.sceneView.scene.rootNode.addChildNode(box!)
        
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
}
