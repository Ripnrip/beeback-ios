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
    var tabBarViewController: PTTabBarViewController?
    //TODO: add a location repository and make it part of the initializer

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
    }

    func start() {
        tabBarViewController = PTTabBarViewController.instantiate()
        tabBarViewController?.coordinator = self
        
        navigationController.pushViewController(tabBarViewController!, animated: false)
    }
    
    func updateMapLocation() {
        
        //TODO: do something here with the mapviewController, lookup the coordinate repo stuff from here
//        tabBarViewController.mapViewController
    }
}
