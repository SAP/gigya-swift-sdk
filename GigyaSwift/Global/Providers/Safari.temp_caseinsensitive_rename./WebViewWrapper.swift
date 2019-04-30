//
//  WebViewWrapper.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 23/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import SafariServices

class WebViewWrapper: NSObject, ProviderWrapperProtocol {
    var clientID: String?

    var safariController: SFSafariViewController?

    private var completionHandler: (String?, Error?) -> Void = { _, _  in }

    override init() {

        super.init()
        let urlString = "https://google.com"

        guard let url = URL(string: urlString) else {
            return
        }
        safariController = SFSafariViewController(url: url, entersReaderIfAvailable: true)

    }

    func login(params: [String: Any]?, viewController: UIViewController?, completion: @escaping (String?, Error?) -> Void) {
        completionHandler = completion

        safariController?.delegate = self
        viewController?.present(safariController!, animated: true, completion: nil)
    }

    func logout() {

    }

    deinit {
        print("[WebViewWra deinit]")
    }
}

extension WebViewWrapper: SFSafariViewControllerDelegate {
    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        print(URL)
    }
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {

    }
}
