//
//  UIImage.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 26/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit

extension UIImage {
    func parseQR() -> [String] {
        guard let image = CIImage(image: self) else {
            return []
        }

        let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                  context: nil,
                                  options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])

        let features = detector?.features(in: image) ?? []

        return features.compactMap { feature in
            return (feature as? CIQRCodeFeature)?.messageString
        }
    }
}
