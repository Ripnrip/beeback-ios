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

    override func viewDidLoad() {
        let vc1 = LabelViewController(title: "Home")
        let vc2 =  ViewController.instantiate()
        let vc3 = ProfileViewController.instantiate()
        
        vc1.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "map"), tag: 1)
        vc1.tabBarItem.image = UIImage(named: "map")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        vc2.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "ar"), tag: 2)
        vc2.tabBarItem.image = UIImage(named: "ar")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        vc3.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "user"), tag: 3)
        vc3.tabBarItem.image = UIImage(named: "user")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)

        self.viewControllers = [vc1, vc2, vc3]
        self.selectedIndex = 1
        super.viewDidLoad()
        
    }
}
