//
//  MyTabBarViewController.swift
//  MyLocations
//
//  Created by Borzy on 03.09.18.
//  Copyright © 2018 Borzy. All rights reserved.
//

import UIKit

class MyTabBarViewController: UITabBarController {

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent;
    }
    
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return nil;
    }

}
