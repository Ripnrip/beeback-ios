//
//  MainCoordinator.swift
//  ARKitImageRecognition
//
//  Created by Gurinder Singh on 3/28/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import UIKit

class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = PTTabBarViewController.instantiate()
        //let vc = ProfileViewController.instantiate()

        navigationController.pushViewController(vc, animated: false)
    }
}
