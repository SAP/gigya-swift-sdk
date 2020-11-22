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

class NativeScreenSetsViewController<T: GigyaAccountProtocol>: FlutterViewController, LoadingContainer, UIGestureRecognizerDelegate {

    var spinnerView = SpinnerView()

    var viewModel: NativeScreenSetsViewModel<T>?

    var initialRoute: String?

    init(viewModel: NativeScreenSetsViewModel<T>, createEngineFactory: CreateEngineFactory) {
        self.viewModel = viewModel

        let engine = createEngineFactory.create()
        engine.run()

        super.init(engine: engine, nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
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

        self.view.backgroundColor = .clear
        self.view.subviews[0].alpha = 0

        showSpinner()

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

typealias SpinnerView = UIView

protocol LoadingContainer {
    var spinnerView: SpinnerView {get set}

    mutating func showSpinner()

    func removeSpinner()
}

extension LoadingContainer where Self: UIViewController {
    func showSpinner() {
        if self.spinnerView.superview != nil {
            return
        }

        let spinnerView = UIView()

        spinnerView.backgroundColor = .clear
        let ai = UIActivityIndicatorView(style: .gray)
        ai.transform = CGAffineTransform(scaleX: 2, y: 2)
        ai.startAnimating()
        ai.center = spinnerView.center

        spinnerView.addSubview(ai)
        self.spinnerView.addSubview(spinnerView)
        self.view.addSubview(self.spinnerView)

        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = spinnerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        let verticalConstraint = spinnerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint])

    }

    func removeSpinner() {
        DispatchQueue.main.async { [weak self] in
            self?.view.subviews[0].alpha = 1.0

            (self?.spinnerView.subviews[0] as? UIActivityIndicatorView)?.stopAnimating()
            self?.spinnerView.removeFromSuperview()
        }
    }
}
