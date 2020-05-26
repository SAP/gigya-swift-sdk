//
//  CreateEngineFactory.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 27/02/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Foundation
import Flutter

class CreateEngineFactory {
    func create() -> FlutterEngine {
        let bundle = Bundle(identifier: GigyaNss.engineBundle)
        let project = FlutterDartProject(precompiledDartBundle: bundle)

        let engine = FlutterEngine(name: GigyaNss.engineId, project: project, allowHeadlessExecution: false)

        return engine
    }
}
