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

    override func loadView() {
        super.loadView()

        webView = WKWebView(frame: .zero)
        webView.uiDelegate = self
        view = webView
        let webBridge = Gigya.sharedInstance(UserHost.self).createWebBridge()

        webBridge.attachTo(webView: webView, viewController: self) { [weak self] (event) in
            print(event)
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
//        let myURL = URL(string: "http://localhost:3232/simple/invisible-captcha.html")
        let myURL = URL(string: "http://localhost:3333/saml/sp.html")


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
