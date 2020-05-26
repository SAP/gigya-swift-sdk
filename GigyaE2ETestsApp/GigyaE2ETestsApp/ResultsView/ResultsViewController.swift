//
//  ResultsViewController.swift
//  GigyaE2ETestsApp
//
//  Created by Shmuel, Sagi on 11/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit
import Gigya

class ResultsViewController: UIViewController {
    let gigya = Gigya.sharedInstance(GigyaAccount.self)

    var statusValue: String = "" {
        didSet {
            status?.text = statusValue
        }
    }

    var uidValue: String = "" {
        didSet {
            uid?.text = uidValue
        }
    }

    @IBOutlet weak var status: UILabel!

    @IBOutlet weak var uid: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        status.text = statusValue
        uid.text = uidValue

    }

    override func viewDidAppear(_ animated: Bool) {

        let isLoggedIn = gigya.isLoggedIn()
        if (isLoggedIn) {
            gigya.getAccount() { [weak self] result in
                switch result {
                case .success(let data):
                    self?.status.text = "success"
                    self?.uid.text = data.UID ?? ""
                case .failure(_):
                    break
                }
            }
        } else {
            self.status.text = "Logged out"
        }
    }
    

    @IBAction func done(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
