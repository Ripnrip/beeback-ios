//
//  ARObjectLoader.swift
//  ARKitImageRecognition
//
//  Created by Duy Nguyen on 9/29/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import ARKit

/**
 Loads multiple `ARObject`s on a background queue to be able to display the
 objects quickly once they are needed.
*/
class ARObjectLoader {
    private(set) var loadedObjects = [ARObject]()
    
    private(set) var isLoading = false
    
    // MARK: - Loading object

    /**
     Loads a `ARObject` on a background queue. `loadedHandler` is invoked
     on a background queue once `object` has been loaded.
    */
    func loadARObject(_ object: ARObject, loadedHandler: @escaping (ARObject) -> Void) {
        isLoading = true
        loadedObjects.append(object)
        
        // Load the content into the reference node.
        DispatchQueue.global(qos: .userInitiated).async {
            object.load()
            self.isLoading = false
            loadedHandler(object)
        }
    }
    
    // MARK: - Removing Objects
    
    func removeAllARObjects() {
        // Reverse the indices so we don't trample over indices as objects are removed.
        for index in loadedObjects.indices.reversed() {
            removeARObject(at: index)
        }
    }

    /// - Tag: RemoveVirtualObject
    func removeARObject(at index: Int) {
        guard loadedObjects.indices.contains(index) else { return }
        
        // Stop the object's tracked ray cast.
        loadedObjects[index].stopTrackedRaycast()
        
        // Remove the visual node from the scene graph.
        loadedObjects[index].removeFromParentNode()
        // Recoup resources allocated by the object.
        loadedObjects[index].unload()
        loadedObjects.remove(at: index)
    }
}
