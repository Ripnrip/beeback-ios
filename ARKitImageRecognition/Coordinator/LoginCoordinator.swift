//
//  LoginCoordinator.swift
//  ARKitImageRecognition
//
//  Created by Gurinder Singh on 3/28/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import UIKit

class LoginCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = LoginViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func userSignedIn(withUserInfo info: OnboardingUserInfo){
        //TODO: check if user has already seen tutorial or not
        //let mainFlow = MainCoordinator(navigationController: navigationController)
        //mainFlow.start()
        
        let tutorialFlow = TutorialCoordinator(navigationController: navigationController, currentUserInfo: info)
        tutorialFlow.start()
    }
}
