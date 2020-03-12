//
//  NssViewController.swift
//  GigyaE2ETestsApp
//
//  Created by Shmuel, Sagi on 12/03/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import UIKit
import Gigya
import GigyaNss

class NssViewController: UIViewController {
    var initialViewController: ResultsViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    @IBAction func showLoginScreen(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Results", bundle: nil)
        initialViewController = storyboard.instantiateViewController(withIdentifier: "Results") as? ResultsViewController

        self.initialViewController?.presentationController?.delegate = self
        self.navigationController?.present(self.initialViewController!, animated: true) {

            GigyaNss.shared
                .load(asset: "init")
                .setScreen(name: "login")
                .show(viewController: self.initialViewController!)

        }
    }

    @IBAction func showRegisterScreen(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Results", bundle: nil)
        initialViewController = storyboard.instantiateViewController(withIdentifier: "Results") as? ResultsViewController

        self.initialViewController?.presentationController?.delegate = self
        self.navigationController?.present(self.initialViewController!, animated: true) {

            GigyaNss.shared
                .load(asset: "init")
                .setScreen(name: "register")
                .show(viewController: self.initialViewController!)

        }    }


    @IBAction func showUpdateProfile(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Results", bundle: nil)

         initialViewController = storyboard.instantiateViewController(withIdentifier: "Results") as? ResultsViewController
         self.navigationController?.present(self.initialViewController!, animated: true) {


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

extension NssViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {

    }
}
