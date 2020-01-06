//
//  ScreenSetsViewController.swift
//  GigyaE2ETestsApp
//
//  Created by Shmuel, Sagi on 12/12/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit
import Gigya

class ScreenSetsViewController: UIViewController {
    var initialViewController: ResultsViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func showLoginScreen(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Results", bundle: nil)

        initialViewController = storyboard.instantiateViewController(withIdentifier: "Results") as? ResultsViewController
        self.navigationController?.present(self.initialViewController!, animated: true) {

            Gigya.sharedInstance().showScreenSet(with: "Default-RegistrationLogin", viewController: self.initialViewController!) { [weak self] (result) in
                guard let self = self else { return }

                switch result {
                case .onLogin(let account):
                    self.initialViewController?.statusValue = "success"
                    self.initialViewController?.uidValue = account.UID ?? ""
                case .error(let event):
                    self.initialViewController?.statusValue = event.debugDescription
                default:
                    break
                }
            }
        }
    }

    @IBAction func showRegisterScreen(_ sender: Any) {
        showLoginScreen(sender)
    }


    @IBAction func showUpdateProfile(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Results", bundle: nil)

         initialViewController = storyboard.instantiateViewController(withIdentifier: "Results") as? ResultsViewController
         self.navigationController?.present(self.initialViewController!, animated: true) {

             Gigya.sharedInstance().showScreenSet(with: "Default-ProfileUpdate", viewController: self.initialViewController!) { [weak self] (result) in
                 guard let self = self else { return }

                 switch result {
                 case .onHide:
                    Gigya.sharedInstance().getAccount { (result) in
                        switch result {
                        case .success(let account):
                            self.initialViewController?.statusValue = "success"
                            self.initialViewController?.uidValue = account.profile?.firstName ?? ""
                        case .failure(let error):
                            self.initialViewController?.statusValue = error.localizedDescription
                        }
                    }

                    break
                 case .error(let event):
                     self.initialViewController?.statusValue = event.debugDescription
                 default:
                     break
                 }
             }
         }
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
