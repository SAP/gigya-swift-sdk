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

    var flutterEngine : FlutterEngine?

    public func showScreenSet(with name: String, viewController: UIViewController) {
        if self.flutterEngine == nil {
            let bundle = Bundle(identifier: "Gigya.GigyaNssEngine")
            let project = FlutterDartProject(precompiledDartBundle: bundle)
            print(project)

            self.flutterEngine = FlutterEngine(name: "io.flutter", project: project)
            self.flutterEngine?.run(withEntrypoint: nil)
        }

        let flutterViewController = FlutterViewController(engine: flutterEngine!, nibName: nil, bundle: nil)
        viewController.present(flutterViewController, animated: true, completion: nil)

    }

    public func test() {

    }
}
