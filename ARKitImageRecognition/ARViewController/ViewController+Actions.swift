//
//  ViewController+Actions.swift
//  ARKitImageRecognition
//
//  Created by Duy Nguyen on 9/29/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import SceneKit
import ARKit


extension ViewController: UIGestureRecognizerDelegate {
    @objc func handleTap(sender: UITapGestureRecognizer) {
        if didDectectPlane {
            if didGameStart && !guidanceOverlay.isActive {
                gameShoot()
            } else {
                gameSetup()
            }
        } else {
            setupTracking(sender: sender)
        }
    }
    
    func setupTracking(sender: UITapGestureRecognizer) {
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        
        print("touchCoordinates = \(touchCoordinates)")
        
//        if let distanceFromBox = getDistanceFromARBox(touchCoordinates) {
//            if distanceFromBox < 2 {
//                self.detectPlane(.horizontal)
//            } else {
//                let alert = UIAlertController(title: "Alert", message: "You are too far from the mystery box", preferredStyle: UIAlertController.Style.alert)
//                alert.addAction(UIAlertAction(title: "Open", style: UIAlertAction.Style.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//            }
//        } else {
//            print("didn't touch anything")
//        }
        self.detectPlane(.horizontal)
    }
    
    func getDistanceFromARBox(_ touchLocation: CGPoint) -> Float?{
                
        guard let query = sceneView.getRaycastQuery(from: touchLocation),
           let result = sceneView.castRay(for: query).first else
           {
            print("unable to get ")
            return nil
        }
        return simd.distance(self.arTrackingBox.simdPosition, result.worldTransform.translation)
    }
    

}

// createTrackedRaycastAndSet3DPosition
// - Tag: ProcessRaycastResults
extension ViewController: SCNPhysicsContactDelegate {
    
    func gameSetup() {

        
        sceneView.scene.physicsWorld.contactDelegate = self
        
        if let arRaycastResult = getPositionFromRaycast() {
            
            container.simdWorldTransform = arRaycastResult.worldTransform
            container.simdPosition = arRaycastResult.worldTransform.translation
            container.simdScale = SIMD3(x: 1, y: 1, z: 1)
            container.isHidden = false
            
            focusPlaneSelector.removeFromParentNode()
            arTrackingBox.removeFromParentNode()
            
            self.sceneView.scene.rootNode.addChildNode(container)
            didGameStart = true
            
        } else {
            print("NOT FOUND worldTransform when adding game")
            
        }
    }
    
    func gameShoot() {
        let ballNum = ballCount % ballNodes.count
        
        let ballNode = ballNodes[ballNum]
        
        //Handle the shooting
        guard let frame = sceneView.session.currentFrame else { return }
        let camMatrix = SCNMatrix4(frame.camera.transform)
        let direction = SCNVector3Make(-camMatrix.m31, -camMatrix.m32, -camMatrix.m33)
        let position = SCNVector3Make(camMatrix.m41, camMatrix.m42, camMatrix.m43)
        
        ballNode.position = position
//        ballNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        ballNode.physicsBody?.categoryBitMask = 3
        ballNode.physicsBody?.contactTestBitMask = 1
        
        sceneView.scene.rootNode.addChildNode(ballNode)
        ballNode.runAction(SCNAction.sequence([SCNAction.wait(duration: 10.0), SCNAction.removeFromParentNode()]))
        print("direction: \(direction)")
        print("position: \(position)")
        ballNode.physicsBody?.applyForce(direction, asImpulse: true)
        ballCount += 1
        
    }
    
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let ball = contact.nodeA.physicsBody!.contactTestBitMask == 3 ? contact.nodeA : contact.nodeB
        let explosion = SCNParticleSystem(named: "art.scnassets/Explosion.scnp", inDirectory: nil)!
        let explosionNode = SCNNode()
        explosionNode.position = ball.presentation.position
        sceneView.scene.rootNode.addChildNode(explosionNode)
        explosionNode.addParticleSystem(explosion)
        ball.removeFromParentNode()
    }
    
    func gamePosition(position: SCNVector3) -> SCNVector3 {
        return SCNVector3(position.x, position.y, position.z)
    }
    
}

