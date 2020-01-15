//
//  GigyaNss.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 08/01/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import UIKit
import Flutter

public class GigyaNss {
    public static var shared = GigyaNss()

    // main channel id
    static var mainChannel = "gigya_nss_engine/method/platform"

    /**
    Show ScreenSet

    - Parameter name:           ScreenSet name.
    - Parameter viewController: Shown view controller.
    */

    public func showScreenSet(with name: String, viewController: UIViewController) {
        let screenSetViewController = NativeScreenSetsViewController()
        viewController.present(screenSetViewController, animated: true, completion: nil)
    }
}
