//
//  UIAlertController.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 16/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

extension UIAlertController {
    func show() {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindow.Level.alert + 1
        win.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
    }
}
