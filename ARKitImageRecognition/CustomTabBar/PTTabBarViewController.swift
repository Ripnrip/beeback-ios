//
//  PTTabBarViewController.swift
//  PTCardTabBar_Example
//
//  Created by Selwan IOS on 9/11/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//
//
import UIKit
import PTCardTabBar
class PTTabBarViewController: PTCardTabBarController, Storyboarded {

    weak var coordinator: MainCoordinator?
    
    var mapViewController: MapViewController
    var arViewController: ViewController
    var profileViewCotroller: ProfileViewController

    override func viewDidLoad() {
        mapViewController = MapViewController.instantiate()
        mapViewController.coordinator = coordinator
        
        arViewController = ViewController.instantiate()
        profileViewCotroller = ProfileViewController.instantiate()
        
        vc1.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "map"), tag: 1)
        vc1.tabBarItem.image = UIImage(named: "map")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        vc2.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "ar"), tag: 2)
        vc2.tabBarItem.image = UIImage(named: "ar")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        vc3.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "user"), tag: 3)
        vc3.tabBarItem.image = UIImage(named: "user")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)

        self.viewControllers = [mapViewController, arViewController, profileViewCotroller]
        

        
        self.selectedIndex = 1
        super.viewDidLoad()
        
    }
}
