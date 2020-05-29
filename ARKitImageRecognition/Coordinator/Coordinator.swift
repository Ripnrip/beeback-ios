//
//  Coordinator.swift
//  ARKitImageRecognition
//
//  Created by Gurinder Singh on 3/28/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] {get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}
