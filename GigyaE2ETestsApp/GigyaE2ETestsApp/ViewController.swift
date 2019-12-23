//
//  ViewController.swift
//  GigyaE2ETestsApp
//
//  Created by Shmuel, Sagi on 11/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit
import Gigya

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.modalPresentationStyle = .formSheet
    }

    @IBAction func logout(_ sender: Any) {
        Gigya.sharedInstance().logout { (result) in
            
        }
    }


}

