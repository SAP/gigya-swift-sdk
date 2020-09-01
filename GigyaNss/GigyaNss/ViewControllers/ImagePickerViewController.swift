//
//  ImagePickerViewController.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 24/08/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import UIKit
import Gigya

class ImagePickerViewController: NSObject {
    var didSelectImage: ((UIImage) -> Void) = { _ in }
    var didCancel: (() -> Void) = { }

    func showSelectPicker(vc: UIViewController, text: String?) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self

        let actionsheet = UIAlertController(title: text ?? "Choose photo from", message: nil, preferredStyle: .actionSheet)

        actionsheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction)in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePickerController.sourceType = .camera
                vc.present(imagePickerController, animated: true, completion: nil)
            } else {
                GigyaLogger.log(with: self, message: "")
                print("Camera is Not Available")
            }
        }))

        actionsheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            actionsheet.dismiss(animated: true, completion: nil)

            vc.present(imagePickerController, animated: true, completion: nil)
        }))

        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] (action:UIAlertAction) in
            self?.didCancel()
        }))

        vc.present(actionsheet,animated: true, completion: nil)

    }

    deinit {
        print("deinit")
    }
}

extension ImagePickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            GigyaLogger.log(with: self, message: "image not found: \(info)")
            return
        }

        didSelectImage(selectedImage)

        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        didCancel()
        picker.dismiss(animated:  true, completion: nil)
    }
}
