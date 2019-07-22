//
//  RootTabBarViewController.swift
//  HealthFestivalToApp
//
//  Created by 李保君 on 2019/5/29.
//  Copyright © 2019 JG. All rights reserved.
//

import UIKit

class RootTabBarController: UITabBarController,UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.title = "常用方式"
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        switch tabBarController.selectedIndex {
        case 0:
            self.title = "常用方式"
        case 1:
            self.title = "扩展方式"
        default:
            break
        }
    }
}
