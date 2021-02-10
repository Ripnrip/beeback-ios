//
//  TutorialViewController.swift
//  ARKitImageRecognition
//
//  Created by Gurinder Singh on 4/12/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import paper_onboarding

class TutorialViewController: UIViewController, Storyboarded, PaperOnboardingDelegate, PaperOnboardingDataSource {
    
    var coordinator: TutorialCoordinator?
    
    let onboarding = PaperOnboarding()

    @IBOutlet weak var getStartedButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        onboarding.delegate = self
        onboarding.dataSource = self
        onboarding.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(onboarding)

        // add constraints
        for attribute: NSLayoutConstraint.Attribute in [.left, .right, .top, .bottom] {
          let constraint = NSLayoutConstraint(item: onboarding,
                                              attribute: attribute,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: attribute,
                                              multiplier: 1,
                                              constant: 0)
          view.addConstraint(constraint)
        }
    }
    
     func onboardingItem(at index: Int) -> OnboardingItemInfo {

      return [
        OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "BeeBackAR"),
                                      title: "Welcome to BeeBack!",
                                description: "Welcome to the BeeBack ‘discover’ page! (add the tab icon for discover page here). Here is where you’ll discover content nearby our partnered locations.",
                                   pageIcon: #imageLiteral(resourceName: "BeeBackAR"),
                                   color: UIColor.random,
                                 titleColor: UIColor.random,
                           descriptionColor: UIColor.random,
                                  titleFont: UIFont(name: "Poppins-Medium", size: 30)!,
                            descriptionFont: UIFont(name: "Poppins-Medium", size: 18)!),

        OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "BeeBackAR"),
                                       title: "Coming soon!",
                                 description: "Upon finding a LEGENDARY beeback box, you will immediately receive an exclusive package in the REAL WORLD! ",
                                    pageIcon: #imageLiteral(resourceName: "BeeBackAR"),
                                    color: UIColor.random,
                                    titleColor: UIColor.random,
                                    descriptionColor: UIColor.random,
                                    titleFont: UIFont(name: "Poppins-Medium", size: 30)!,
                             descriptionFont: UIFont(name: "Poppins-Medium", size: 18)!),

        OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "BeeBackAR"),
                                    title: "title",
                              description: "description",
                                 pageIcon: #imageLiteral(resourceName: "BeeBackAR"),
                                    color: UIColor.random,
                               titleColor: UIColor.random,
                         descriptionColor: UIColor.random,
                                titleFont: UIFont(name: "Poppins-Medium", size: 30)!,
                          descriptionFont: UIFont(name: "Poppins-Medium", size: 18)!)
        ][index]
    }

    func onboardingItemsCount() -> Int {
       return 3
     }
    
    func onboardingConfigurationItem(item: OnboardingContentViewItem, index: Int) {

    //    item.titleLabel?.backgroundColor = .redColor()
    //    item.descriptionLabel?.backgroundColor = .redColor()
    //    item.imageView = ...
      }

    func onboardingWillTransitonToIndex(_ index: Int) {
        print("transitioning to \(index)")
        guard index >= 2 else { return }
        onboarding.addSubview(getStartedButton)
    }
    
    
    @IBAction func getStarted(_ sender: Any) {
        coordinator?.userFinishedTutorial()
    }
    
}
