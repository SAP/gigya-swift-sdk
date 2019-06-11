//
//  WebViewController.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 29/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import WebKit

class WebViewController: UIViewController {
    let webView: WKWebView

    var userDidCancel: () -> Void = { }

    init(configuration: WKWebViewConfiguration = WKWebViewConfiguration()) {
        webView = WKWebView(frame: .zero, configuration: configuration)

        super.init(nibName: nil, bundle: nil)

        self.view.backgroundColor = .white
    }

    override func viewDidLoad() {
        buildUI()

        setWebViewLayout()
    }

    private func buildUI() {
        self.view.backgroundColor = .white

        self.view.addSubview(webView)

        webView.translatesAutoresizingMaskIntoConstraints = false

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissView))

    }

    private func setWebViewLayout() {
        let margins: UILayoutGuide

        if #available(iOS 11.0, *) {
            margins = view.safeAreaLayoutGuide
        } else {
            margins = view.layoutMarginsGuide
        }

        webView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDelegate(delegate: WKNavigationDelegate) {
        webView.navigationDelegate = delegate
    }

    func loadUrl(url: URL) {
        webView.load(URLRequest(url: url))
    }

    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
        userDidCancel()
    }
}
