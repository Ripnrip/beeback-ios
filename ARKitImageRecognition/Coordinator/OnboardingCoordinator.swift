//
//  TutorialCoordinator.swift
//  ARKitImageRecognition
//
//  Created by Gurinder Singh on 4/12/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import FirebaseAuth
import Foundation
import UIKit

class OnboardinCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var user: User? = Auth.auth().currentUser
    let currentUserInfo: OnboardingUserInfo


    init(navigationController: UINavigationController, currentUserInfo: OnboardingUserInfo) {
        self.navigationController = navigationController
        self.currentUserInfo = currentUserInfo
    }

    func start() {
        let vc = OnboardingViewController.instantiate()
        vc.currentUserInfo = self.currentUserInfo
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func userFinishedSetup(){
       let mainFlow = MainCoordinator(navigationController: navigationController)
       mainFlow.start()
    }
}
