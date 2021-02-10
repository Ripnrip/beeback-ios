//
//  float4x4Extension.swift
//  ARKitImageRecognition
//
//  Created by Duy Nguyen on 9/25/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import ARKit


extension float4x4 {
    var translation: SIMD3<Float> {
        get {
            let translation = self.columns.3
            return [translation.x, translation.y, translation.z]
        }
        set(newValue) {
            columns.3 = [newValue.x, newValue.y, newValue.z, columns.3.w]
        }
    }
    
    var orientation: simd_quatf {
        return simd_quaternion(self)
    }
}
