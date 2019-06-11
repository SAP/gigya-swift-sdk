//
//  FakeUIViewController.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 04/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import UIKit

class FakeUIViewController: UIViewController {
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        completion?()
    }
}
