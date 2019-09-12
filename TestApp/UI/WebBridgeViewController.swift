//
//  WebBridgeViewController.swift
//  TestApp
//
//  Created by Shmuel, Sagi on 04/09/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit
import WebKit
import Gigya

class WebBridgeViewController: UIViewController, WKUIDelegate {

    var webView: WKWebView!
    let createWebBridge = Gigya.sharedInstance(UserHost.self).createWebBridge()

    override func loadView() {
        super.loadView()

        let webConfiguration = WKWebViewConfiguration()

        let contentController = WKUserContentController()
        webConfiguration.userContentController = contentController

        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView

        createWebBridge.registerWebView(webView: webView, viewController: self) { [weak self] (event) in
            switch event {
            case .onLogin(let account):
                self?.navigationController?.popViewController(animated: true)
            default:
                break
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let myURL = URL(string: "http://localhost:3232/simple/invisible-captcha.html")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
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
