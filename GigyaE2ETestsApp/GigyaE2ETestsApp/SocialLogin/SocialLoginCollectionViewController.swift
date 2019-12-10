//
//  SocialLoginCollectionViewController.swift
//  GigyaE2ETestsApp
//
//  Created by Shmuel, Sagi on 11/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit
import Gigya

private let reuseIdentifier = "Cell"

class SocialLoginCollectionViewController: UICollectionViewController {

    let providers = ["facebook", "googleplus", "twitter", "yahoo", "line"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        self.collectionView!.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")


        // Do any additional setup after loading the view.
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        switch kind {

        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)

            headerView.backgroundColor = UIColor.systemBlue

            let label = UILabel()
            label.text = "Select a provider:"
            label.textColor = .white
            label.frame = headerView.frame
            label.textAlignment = .center

            headerView.addSubview(label)

            return headerView
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath)

            footerView.backgroundColor = UIColor.systemBlue

            let label = UILabel()
            label.text = "Force Pendding Registration:"
            label.textColor = .white
            label.textAlignment = .center

            let switchButton = UISwitch()
            switchButton.isEnabled = true
            switchButton.addTarget(self, action: #selector(switchValueChanged(sender:)), for: .valueChanged)
            switchButton.accessibilityIdentifier = "penddingRegSwitch"
            let stackView = UIStackView(arrangedSubviews: [label, switchButton])
            stackView.alignment = .center
            stackView.distribution = .fillProportionally
            stackView.axis = .horizontal
            stackView.spacing = 10

            footerView.addSubview(stackView)

            stackView.translatesAutoresizingMaskIntoConstraints = false

            stackView.widthAnchor.constraint(equalTo: footerView.widthAnchor).isActive = true
            stackView.heightAnchor.constraint(equalTo: footerView.heightAnchor).isActive = true

//            stackView.leadingAnchor.constraint(equalTo: footerView.leadingAnchor).isActive = true
//            stackView.trailingAnchor.constraint(equalTo: footerView.trailingAnchor).isActive = true
//            stackView.topAnchor.constraint(equalTo: footerView.topAnchor).isActive = true
//            stackView.bottomAnchor.constraint(equalTo: footerView.bottomAnchor).isActive = true

            return footerView

        default:
            assert(false, "Unexpected element kind")
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50.0)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return providers.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let provider = providers[indexPath.row]

        // Configure the cell
        let button = UIButton()
        button.setImage(UIImage(named: provider), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        button.center = CGPoint(x: cell.frame.width/2, y: cell.frame.height/2)
        button.addTarget(self, action: #selector(gigyaSocialLogin(sender:)), for: .touchUpInside)
        button.tag = indexPath.row
        button.accessibilityIdentifier = provider
        cell.addSubview(button)

        return cell
    }

    @objc func gigyaSocialLogin(sender: UIButton) {

        let provider = GigyaSocialProviders(rawValue: providers[sender.tag])

        Gigya.sharedInstance().login(with: provider!, viewController: self) { (result) in

            let storyboard = UIStoryboard(name: "Results", bundle: nil)

            let initialViewController: ResultsViewController = storyboard.instantiateViewController(withIdentifier: "Results") as! ResultsViewController
            self.navigationController?.present(initialViewController, animated: true, completion: {
                switch result {
                case .success(let data):
                    initialViewController.status.text = "success"
                    initialViewController.uid.text = data.UID ?? ""
                case .failure(let error):
                    initialViewController.status.text = error.error.localizedDescription
                @unknown default:
                    break
                }
            })

        }
    }

    @objc func switchValueChanged(sender: UISwitch!) {
        if sender.isOn {

            Gigya.sharedInstance().initFor(apiKey: "3_5FIA8jNk1LTw_spOzIYLVU-GJVm93TAfJjqTjACQCnfxfRm0kZghGH1lx7zoNMbD")

        } else {

        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension SocialLoginCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

    let collectionWidth = collectionView.bounds.width
    return CGSize(width: collectionWidth/3, height: collectionWidth/3)

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0

    }
}
