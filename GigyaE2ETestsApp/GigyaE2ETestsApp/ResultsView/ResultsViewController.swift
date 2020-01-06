//
//  ResultsViewController.swift
//  GigyaE2ETestsApp
//
//  Created by Shmuel, Sagi on 11/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController {

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
