//
//  TutorialCoordinator.swift
//  ARKitImageRecognition
//
//  Created by Gurinder Singh on 4/12/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import UIKit

class TutorialCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    let currentUserInfo: OnboardingUserInfo

    init(navigationController: UINavigationController, currentUserInfo: OnboardingUserInfo) {
        self.navigationController = navigationController
        self.currentUserInfo = currentUserInfo
    }

    func start() {
        let vc = TutorialViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func userFinishedTutorial(){
        let onboardingFlow = OnboardinCoordinator(navigationController: navigationController, currentUserInfo: currentUserInfo)
        onboardingFlow.start()
        
        //let mainFlow = MainCoordinator(navigationController: navigationController)
        //mainFlow.start()
    }
}
