//
//  GeneralUtilsMock.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 24/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit
@testable import Gigya

class GeneralUtilsMock: GeneralUtils {
    var showNotificationTextTestClosure: (String) -> () = { _ in }

    override func show(vc: UIViewController, title: String, message: String, result: @escaping (Bool) -> Void) {
        result(true)
    }

    override func getTopViewController() -> UIViewController? {
        return UIViewController()
    }

    override func showNotification(title: String, body: String, id: String, userInfo: [AnyHashable : Any] = [:]) {
        showNotificationTextTestClosure(body)
    }
}
