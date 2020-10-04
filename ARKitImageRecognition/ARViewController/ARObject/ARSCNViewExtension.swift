//
//  ARSCNViewExtension.swift
//  ARKitImageRecognition
//
//  Created by Duy Nguyen on 9/25/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import ARKit

extension ARSCNView {
    /**
     Type conversion wrapper for original `unprojectPoint(_:)` method.
     Used in contexts where sticking to SIMD3<Float> type is helpful.
     */
    func unprojectPoint(_ point: SIMD3<Float>) -> SIMD3<Float> {
        return SIMD3<Float>(unprojectPoint(SCNVector3(point)))
    }
    
    // - Tag: CastRayForFocusSquarePosition
    func castRay(for query: ARRaycastQuery) -> [ARRaycastResult] {
        return session.raycast(query)
    }

    // - Tag: GetRaycastQuery
    func getRaycastQuery(for alignment: ARRaycastQuery.TargetAlignment = .any) -> ARRaycastQuery? {
        return raycastQuery(from: screenCenter, allowing: .estimatedPlane, alignment: alignment)
    }
    
    func getRaycastQuery(from locationPoint: CGPoint) -> ARRaycastQuery? {
        return raycastQuery(from: locationPoint, allowing: .estimatedPlane, alignment: .any)

    }
    
    
    var screenCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
}
