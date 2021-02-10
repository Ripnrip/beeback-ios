//
//  FocusPlaneSelector.swift
//  ARKitImageRecognition
//
//  Created by Duy Nguyen on 9/25/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import ARKit

struct FocusPlaneSelectorConfig {
    // MARK: - Configuration Properties
    
    // Original size of the focus square in meters.
    let size: Float = 0.17
    
    // Thickness of the focus square lines in meters.
    let thickness: Float = 0.018
    
    // Scale factor for the focus square when it is closed, w.r.t. the original size.
    let scaleForClosedSquare: Float = 0.97
    
    // Side length of the focus square segments when it is open (w.r.t. to a 1x1 square).
    let sideLengthForOpenSegments: CGFloat = 0.2
    
    // Duration of the open/close animation
    let animationDuration = 0.7
    
    let primaryColor = #colorLiteral(red: 1, green: 0.8, blue: 0, alpha: 1)
    
    // Color of the focus square fill.
     let fillColor = #colorLiteral(red: 1, green: 0.9254901961, blue: 0.4117647059, alpha: 1)
}

class FocusPlaneSelector: SCNNode {
    // MARK: - Types
    
    enum State: Equatable {
        case initializing
        case detecting(raycastResult: ARRaycastResult, camera: ARCamera?)
    }
    
    let focusPlaneSelectorConfig = FocusPlaneSelectorConfig()
    
    // MARK: - Properties
    
    /// The most recent position of the focus square based on the current state.
    var lastPosition: SIMD3<Float>? {
        switch state {
        case .initializing: return nil
        case .detecting(let raycastResult, _): return raycastResult.worldTransform.translation
        }
    }
    
    var state: State = .initializing {
        didSet {
            guard state != oldValue else { return }
            
            switch state {
            case .initializing:
                displayAsBillboard()
                
            case let .detecting(raycastResult, camera):
                if let planeAnchor = raycastResult.anchor as? ARPlaneAnchor {
                    displayAsClosed(for: raycastResult, planeAnchor: planeAnchor, camera: camera)
                } else {
                    displayAsOpen(for: raycastResult, camera: camera)
                }
            }
        }
    }
    
    /// Indicates whether the segments of the focus square are disconnected.
    private var isOpen = false
    
    /// Indicates if the square is currently being animated for opening or closing.
    private var isAnimating = false
    
    /// Indicates if the square is currently changing its orientation when the camera is pointing downwards.
    private var isChangingOrientation = false
    
    /// Indicates if the camera is currently pointing towards the floor.
    private var isPointingDownwards = true
    
    /// The focus square's most recent positions.
    var recentFocusSquarePositions: [SIMD3<Float>] = []
    
    /// Previously visited plane anchors.
    private var anchorsOfVisitedPlanes: Set<ARAnchor> = []
    
    /// List of the segments in the focus square.
    private var segments: [FocusPlaneSelector.Segment] = []
    
    /// The primary node that controls the position of other `FocusSquare` nodes.
    let positioningNode = SCNNode()
    
    /// A counter for managing orientation updates of the focus square.
    private var counterToNextOrientationUpdate: Int = 0
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        opacity = 0.0
        
        /*
         The focus square consists of eight segments as follows, which can be individually animated.
         
             s1  s2
             _   _
         s3 |     | s4
         
         s5 |     | s6
             -   -
             s7  s8
         */
        let s1 = Segment(name: "s1", corner: .topLeft, alignment: .horizontal)
        let s2 = Segment(name: "s2", corner: .topRight, alignment: .horizontal)
        let s3 = Segment(name: "s3", corner: .topLeft, alignment: .vertical)
        let s4 = Segment(name: "s4", corner: .topRight, alignment: .vertical)
        let s5 = Segment(name: "s5", corner: .bottomLeft, alignment: .vertical)
        let s6 = Segment(name: "s6", corner: .bottomRight, alignment: .vertical)
        let s7 = Segment(name: "s7", corner: .bottomLeft, alignment: .horizontal)
        let s8 = Segment(name: "s8", corner: .bottomRight, alignment: .horizontal)
        segments = [s1, s2, s3, s4, s5, s6, s7, s8]
        
        let sl: Float = 0.5  // segment length
        let c: Float = focusPlaneSelectorConfig.thickness / 2 // correction to align lines perfectly
        s1.simdPosition += [-(sl / 2 - c), -(sl - c), 0]
        s2.simdPosition += [sl / 2 - c, -(sl - c), 0]
        s3.simdPosition += [-sl, -sl / 2, 0]
        s4.simdPosition += [sl, -sl / 2, 0]
        s5.simdPosition += [-sl, sl / 2, 0]
        s6.simdPosition += [sl, sl / 2, 0]
        s7.simdPosition += [-(sl / 2 - c), sl - c, 0]
        s8.simdPosition += [sl / 2 - c, sl - c, 0]
        
        positioningNode.eulerAngles.x = .pi / 2 // Horizontal
        positioningNode.simdScale = [1.0, 1.0, 1.0] * (focusPlaneSelectorConfig.size * focusPlaneSelectorConfig.scaleForClosedSquare)
        for segment in segments {
            positioningNode.addChildNode(segment)
        }
        positioningNode.addChildNode(fillPlane)
        
        // Always render focus square on top of other content.
        displayNodeHierarchyOnTop(true)
        
        addChildNode(positioningNode)
        
        // Start the focus square as a billboard.
//        displayAsBillboard()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    // MARK: - Appearance
    
    /// Hides the focus square.
    func hide() {
        guard action(forKey: "hide") == nil else { return }
        
        displayNodeHierarchyOnTop(false)
        runAction(.fadeOut(duration: 0.5), forKey: "hide")
    }
    
    /// Unhides the focus square.
    func unhide() {
        guard action(forKey: "unhide") == nil else { return }
        
        displayNodeHierarchyOnTop(true)
        runAction(.fadeIn(duration: 0.5), forKey: "unhide")
    }
    
    /// Displays the focus square parallel to the camera plane.
    private func displayAsBillboard() {
        simdTransform = matrix_identity_float4x4
        eulerAngles.x = .pi / 2
        simdPosition = [0, 0, -0.8]
        unhide()
        performOpenAnimation()
    }

    /// Called when a surface has been detected.
    private func displayAsOpen(for raycastResult: ARRaycastResult, camera: ARCamera?) {
        performOpenAnimation()
        setPosition(with: raycastResult, camera)
    }
        
    /// Called when a plane has been detected.
    private func displayAsClosed(for raycastResult: ARRaycastResult, planeAnchor: ARPlaneAnchor, camera: ARCamera?) {
        performCloseAnimation(flash: !anchorsOfVisitedPlanes.contains(planeAnchor))
        anchorsOfVisitedPlanes.insert(planeAnchor)
        setPosition(with: raycastResult, camera)
    }
    
    // - Tag: Set3DPosition
    func setPosition(with raycastResult: ARRaycastResult, _ camera: ARCamera?) {
        let position = raycastResult.worldTransform.translation
        recentFocusSquarePositions.append(position)
        updateTransform(for: raycastResult, camera: camera)
    }

    // MARK: Helper Methods
    
    // - Tag: Set3DOrientation
    func updateOrientation(basedOn raycastResult: ARRaycastResult) {
//        print(raycastResult.description)
        self.simdOrientation = raycastResult.worldTransform.orientation
    }
    
    /// Update the transform of the focus square to be aligned with the camera.
    private func updateTransform(for raycastResult: ARRaycastResult, camera: ARCamera?) {
        // Average using several most recent positions.
        recentFocusSquarePositions = Array(recentFocusSquarePositions.suffix(10))
        
        // Move to average of recent positions to avoid jitter.
        let average = recentFocusSquarePositions.reduce([0, 0, 0], { $0 + $1 }) / Float(recentFocusSquarePositions.count)
        self.simdPosition = average
        self.simdScale = [1.0, 1.0, 1.0] * scaleBasedOnDistance(camera: camera)
        
        // Correct y rotation when camera is close to horizontal
        // to avoid jitter due to gimbal lock.
        guard let camera = camera else { return }
        let tilt = abs(camera.eulerAngles.x)
        let threshold: Float = .pi / 2 * 0.75
        
        if tilt > threshold {
            if !isChangingOrientation {
                let yaw = atan2f(camera.transform.columns.0.x, camera.transform.columns.1.x)
                
                isChangingOrientation = true
                SCNTransaction.begin()
                SCNTransaction.completionBlock = {
                    self.isChangingOrientation = false
                    self.isPointingDownwards = true
                }
                SCNTransaction.animationDuration = isPointingDownwards ? 0.0 : 0.5
                self.simdOrientation = simd_quatf(angle: yaw, axis: [0, 1, 0])
                SCNTransaction.commit()
            }
        } else {
            // Update orientation only twice per second to avoid jitter.
            if counterToNextOrientationUpdate == 30 || isPointingDownwards {
                counterToNextOrientationUpdate = 0
                isPointingDownwards = false
                
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                updateOrientation(basedOn: raycastResult)
                SCNTransaction.commit()
            }
            
            counterToNextOrientationUpdate += 1
        }
    }

    /**
     Reduce visual size change with distance by scaling up when close and down when far away.
     
     These adjustments result in a scale of 1.0x for a distance of 0.7 m or less
     (estimated distance when looking at a table), and a scale of 1.2x
     for a distance 1.5 m distance (estimated distance when looking at the floor).
     */
    private func scaleBasedOnDistance(camera: ARCamera?) -> Float {
        guard let camera = camera else { return 1.0 }

        let distanceFromCamera = simd_length(simdWorldPosition - camera.transform.translation)
        if distanceFromCamera < 0.7 {
            return distanceFromCamera / 0.7
        } else {
            return 0.25 * distanceFromCamera + 0.825
        }
    }
    
    // MARK: Animations
    
    private func performOpenAnimation() {
        guard !isOpen, !isAnimating else { return }
        isOpen = true
        isAnimating = true

        
        // Open animation
        SCNTransaction.begin()
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
        SCNTransaction.animationDuration = focusPlaneSelectorConfig.animationDuration / 4
        positioningNode.opacity = 1.0
        for segment in segments {
            segment.open()
        }
        SCNTransaction.completionBlock = {
            self.positioningNode.runAction(pulseAction(), forKey: "pulse")
            
//            self.fillPlane.runAction(pulseAction(), forKey: "pulse")
            
            // This is a safe operation because `SCNTransaction`'s completion block is called back on the main thread.
            self.isAnimating = false
        }
        SCNTransaction.commit()
        
        // Add a scale/bounce animation.
        SCNTransaction.begin()
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
        SCNTransaction.animationDuration = focusPlaneSelectorConfig.animationDuration / 4
        positioningNode.simdScale = [1.0, 1.0, 1.0] * focusPlaneSelectorConfig.size
        SCNTransaction.commit()
    }

    private func performCloseAnimation(flash: Bool = false) {
        guard isOpen, !isAnimating else { return }
        isOpen = false
        isAnimating = true
        
        positioningNode.removeAction(forKey: "pulse")
        positioningNode.opacity = 0.5
        
        // Close animation
        SCNTransaction.begin()
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
        SCNTransaction.animationDuration = focusPlaneSelectorConfig.animationDuration / 2
        positioningNode.opacity = 0.99
        SCNTransaction.completionBlock = {
            SCNTransaction.begin()
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
            SCNTransaction.animationDuration = self.focusPlaneSelectorConfig.animationDuration / 4
            for segment in self.segments {
                segment.close()
            }
            SCNTransaction.completionBlock = { self.isAnimating = false }
            SCNTransaction.commit()
        }
        SCNTransaction.commit()
        
        // Scale/bounce animation
        positioningNode.addAnimation(scaleAnimation(for: "transform.scale.x"), forKey: "transform.scale.x")
        positioningNode.addAnimation(scaleAnimation(for: "transform.scale.y"), forKey: "transform.scale.y")
        positioningNode.addAnimation(scaleAnimation(for: "transform.scale.z"), forKey: "transform.scale.z")
        
        if flash {
            let waitAction = SCNAction.wait(duration: focusPlaneSelectorConfig.animationDuration * 0.75)
            
            let flashSquareAction = flashAnimation(duration: focusPlaneSelectorConfig.animationDuration * 0.25)
            for segment in segments {
                segment.runAction(.sequence([waitAction, flashSquareAction]))
            }
         }
    }
    
    // MARK: Convenience Methods
    
    private func scaleAnimation(for keyPath: String) -> CAKeyframeAnimation {
        let scaleAnimation = CAKeyframeAnimation(keyPath: keyPath)
        
        let easeOut = CAMediaTimingFunction(name: .easeOut)
        let easeInOut = CAMediaTimingFunction(name: .easeInEaseOut)
        let linear = CAMediaTimingFunction(name: .linear)
        
        let size = focusPlaneSelectorConfig.size
        let ts = focusPlaneSelectorConfig.size * focusPlaneSelectorConfig.scaleForClosedSquare
        let values = [size, size * 1.15, size * 1.15, ts * 0.97, ts]
        let keyTimes: [NSNumber] = [0.00, 0.25, 0.50, 0.75, 1.00]
        let timingFunctions = [easeOut, linear, easeOut, easeInOut]
        
        scaleAnimation.values = values
        scaleAnimation.keyTimes = keyTimes
        scaleAnimation.timingFunctions = timingFunctions
        scaleAnimation.duration = focusPlaneSelectorConfig.animationDuration
        
        return scaleAnimation
    }
    
    /// Sets the rendering order of the `positioningNode` to show on top or under other scene content.
    func displayNodeHierarchyOnTop(_ isOnTop: Bool) {
        // Recursivley traverses the node's children to update the rendering order depending on the `isOnTop` parameter.
        func updateRenderOrder(for node: SCNNode) {
            node.renderingOrder = isOnTop ? 2 : 0
            
            for material in node.geometry?.materials ?? [] {
                material.readsFromDepthBuffer = !isOnTop
            }
            
            for child in node.childNodes {
                updateRenderOrder(for: child)
            }
        }
        
        updateRenderOrder(for: positioningNode)
    }

    private lazy var fillPlane: SCNNode = {
        let correctionFactor = focusPlaneSelectorConfig.thickness / 2 // correction to align lines perfectly
        let length = CGFloat(1.0 - focusPlaneSelectorConfig.thickness * 2 + correctionFactor)
        
        
        let plane = SCNPlane(width: length, height: length)
        let node = SCNNode(geometry: plane)
        node.name = "fillPlane"
        node.opacity = 0.9

        let displayImage = UIImage(named: "tracker")?.flipRotate(radians: .pi)
        
        let material = plane.firstMaterial!
//        material.diffuse.contents = focusPlaneSelectorConfig.fillColor
        material.diffuse.contents = displayImage
        material.isDoubleSided = true
        material.ambient.contents = UIColor.black
        material.lightingModel = .constant
//        material.emission.contents = focusPlaneSelectorConfig.fillColor

        return node
    }()
    
    func getSegmentPosition() -> SCNVector3{
        print("segments[0].position: \(segments[0].position)")
        print("segments[0].worldPosition: \(segments[0].worldPosition)")
        print("segments[0].simdPosition: \(segments[0].simdPosition)")
        return segments[0].position
    }
}

// MARK: - Animations and Actions

private func pulseAction() -> SCNAction {
    let pulseOutAction = SCNAction.fadeOpacity(to: 0.4, duration: 0.5)
    let pulseInAction = SCNAction.fadeOpacity(to: 1.0, duration: 0.5)
    pulseOutAction.timingMode = .easeInEaseOut
    pulseInAction.timingMode = .easeInEaseOut
    
    return SCNAction.repeatForever(SCNAction.sequence([pulseOutAction, pulseInAction]))
}

private func flashAnimation(duration: TimeInterval) -> SCNAction {
    let action = SCNAction.customAction(duration: duration) { (node, elapsedTime) -> Void in
        // animate color from HSB 48/100/100 to 48/30/100 and back
        let elapsedTimePercentage = elapsedTime / CGFloat(duration)
        let saturation = 2.8 * (elapsedTimePercentage - 0.5) * (elapsedTimePercentage - 0.5) + 0.3
        if let material = node.geometry?.firstMaterial {
            material.diffuse.contents = UIColor(hue: 0.1333, saturation: saturation, brightness: 1.0, alpha: 1.0)
        }
    }
    return action
}



extension FocusPlaneSelector {

    /*
    The focus square consists of eight segments as follows, which can be individually animated.

        s1  s2
        _   _
    s3 |     | s4

    s5 |     | s6
        -   -
        s7  s8
    */
    enum Corner {
        case topLeft // s1, s3
        case topRight // s2, s4
        case bottomRight // s6, s8
        case bottomLeft // s5, s7
    }
    
    enum Alignment {
        case horizontal // s1, s2, s7, s8
        case vertical // s3, s4, s5, s6
    }
    
    enum Direction {
        case up, down, left, right

        var reversed: Direction {
            switch self {
                case .up:   return .down
                case .down: return .up
                case .left:  return .right
                case .right: return .left
            }
        }
    }

    class Segment: SCNNode {

        // MARK: - Configuration & Initialization

        /// Thickness of the focus square lines in m.
        static let thickness: CGFloat = 0.018

        /// Length of the focus square lines in m.
        static let length: CGFloat = 0.5  // segment length

        /// Side length of the focus square segments when it is open (w.r.t. to a 1x1 square).
        static let openLength: CGFloat = 0.2

        let corner: Corner
        let alignment: Alignment
        let plane: SCNPlane

        init(name: String, corner: Corner, alignment: Alignment) {
            self.corner = corner
            self.alignment = alignment
            let focusConfig = FocusPlaneSelectorConfig()
            
            switch alignment {
            case .vertical:
                plane = SCNPlane(width: Segment.thickness, height: Segment.length)
            case .horizontal:
                plane = SCNPlane(width: Segment.length, height: Segment.thickness)
            }
            super.init()
            self.name = name
            
            let material = plane.firstMaterial!
            material.diffuse.contents = focusConfig.primaryColor
            material.isDoubleSided = true
            material.ambient.contents = UIColor.black
            material.lightingModel = .constant
            material.emission.contents = focusConfig.primaryColor
            geometry = plane
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("\(#function) has not been implemented")
        }

        // MARK: - Animating Open/Closed

        var openDirection: Direction {
            switch (corner, alignment) {
                case (.topLeft,     .horizontal):   return .left
                case (.topLeft,     .vertical):     return .up
                case (.topRight,    .horizontal):   return .right
                case (.topRight,    .vertical):     return .up
                case (.bottomLeft,  .horizontal):   return .left
                case (.bottomLeft,  .vertical):     return .down
                case (.bottomRight, .horizontal):   return .right
                case (.bottomRight, .vertical):     return .down
            }
        }

        func open() {
            if alignment == .horizontal {
                plane.width = Segment.openLength
            } else {
                plane.height = Segment.openLength
            }

            let offset = Segment.length / 2 - Segment.openLength / 2
            updatePosition(withOffset: Float(offset), for: openDirection)
        }

        func close() {
            let oldLength: CGFloat
            if alignment == .horizontal {
                oldLength = plane.width
                plane.width = Segment.length
            } else {
                oldLength = plane.height
                plane.height = Segment.length
            }

            let offset = Segment.length / 2 - oldLength / 2
            updatePosition(withOffset: Float(offset), for: openDirection.reversed)
        }
        
        private func updatePosition(withOffset offset: Float, for direction: Direction) {
            switch direction {
            case .left:     position.x -= offset
            case .right:    position.x += offset
            case .up:       position.y -= offset
            case .down:     position.y += offset
            }
        }

    }
}