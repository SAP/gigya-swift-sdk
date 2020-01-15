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

    // initalizeing the flutter engine

    public func showScreenSet(with name: String, viewController: UIViewController) {

        let flutterViewController = NativeScreenSetsViewController()
        viewController.present(flutterViewController, animated: true, completion: nil)

    }

    public func test() {

    }
}
