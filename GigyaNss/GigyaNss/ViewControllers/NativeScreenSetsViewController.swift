//
//  EngineViewController.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 13/01/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import UIKit
import Flutter
import Gigya

class NativeScreenSetsViewController<T: GigyaAccountProtocol>: FlutterViewController {
    var viewModel: NativeScreenSetsViewModel<T>

    init(viewModel: NativeScreenSetsViewModel<T>) {
        self.viewModel = viewModel

        let engine = viewModel.createEngine()

        super.init(engine: engine, nibName: nil, bundle: nil)

        viewModelHandlers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func build(asset: String) {
        guard let engine = engine else {
            GigyaLogger.error(with: NativeScreenSetsViewController.self, message: "engine not exists.")
        }

        viewModel.loadChannels(with: engine, asset: asset)
    }

    func viewModelHandlers() {
        viewModel.dismissClosure = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
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
