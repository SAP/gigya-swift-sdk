//
//  EngineViewController.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 13/01/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import UIKit
import Flutter

class NativeScreenSetsViewController: FlutterViewController {
    var flutterMainChannel: MainPlatformChannelHandler?

    let engineBundle = "Gigya.GigyaNssEngine"
    let engineId = "io.flutter"

    init() {
        let bundle = Bundle(identifier: engineBundle)
        let project = FlutterDartProject(precompiledDartBundle: bundle)

        let engine = FlutterEngine(name: engineId, project: project)
        engine.run()
        super.init(engine: engine, nibName: nil, bundle: nil)

        configureFlutterEngine()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureFlutterEngine() {
        guard let engine = engine else {
            return
        }

        flutterMainChannel = MainPlatformChannelHandler(engine: engine)
//        engine.run(withEntrypoint: "lunch")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
