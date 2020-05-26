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

class NativeScreenSetsViewController<T: GigyaAccountProtocol>: FlutterViewController, UIGestureRecognizerDelegate {
    var viewModel: NativeScreenSetsViewModel<T>?

    var initialRoute: String?

    init(viewModel: NativeScreenSetsViewModel<T>, createEngineFactory: CreateEngineFactory) {
        self.viewModel = viewModel

        let engine = createEngineFactory.create()
        engine.run()

        super.init(engine: engine, nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func build() {
        guard let engine = engine else {
            GigyaLogger.error(with: NativeScreenSetsViewController.self, message: "engine not exists.")
        }

        viewModel?.loadChannels(with: engine)

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        let gestureRecognizer = UIGestureRecognizer()
        gestureRecognizer.delegate = self
        self.view.addGestureRecognizer(gestureRecognizer)
    }

    private func disableDismissalRecognizers() {
        presentationController?.presentedView?.gestureRecognizers?.forEach {
            $0.isEnabled = false
        }
    }

    private func enableDismissalRecognizers() {
        presentationController?.presentedView?.gestureRecognizers?.forEach {
            $0.isEnabled = true
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.location(in: touch.view).y > 65.0 {
            disableDismissalRecognizers()
        }
        else {
            enableDismissalRecognizers()
        }
        return false
    }

    deinit {
        GigyaLogger.log(with: self, message: "deinit")
    }

}

