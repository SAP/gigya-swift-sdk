//
//  LoadHelper.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 20/01/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Foundation
import Gigya

enum ScreenLoadType {
     case asset(value: String), id(value: String)
}

class LoaderFileHelper {
    private let busnessApi: BusinessApiDelegate?

    var errorClosure: (NetworkError) -> Void = { _ in }

    init(busnessApi: BusinessApiDelegate) {
        self.busnessApi = busnessApi
    }

    func fileToDic(name: String) -> [String: Any]? {
        guard let filePath = Bundle.main.url(forResource: name, withExtension: "json") else {
            GigyaLogger.log(with: LoaderFileHelper.self, message: "`\(name))` file not found.")
            return nil
        }

        do {
            let data = try Data(contentsOf: filePath, options: .mappedIfSafe)
            let decodedObject = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject] ?? [:]

            return decodedObject
        } catch {
            // handle error
        }

        return nil
    }

    func load(asset: ScreenLoadType, defaultLang: String?, response: @escaping ([String: Any]) -> Void = { _ in }) {

        switch asset {
        case .asset(let value):
            // load the `screenSets` file from bundle. (example: `init.json`)
            guard var loadAsset = fileToDic(name: value) else {
                GigyaLogger.error(with: LoaderFileHelper.self, message: "the asset: \(value) is not found.")
            }

            // load the `theme` file from bundle. (example: `init.theme.json`)
            let loadFileTheme = fileToDic(name: "\(value).\(GigyaNss.themePrefix))")

            // load the `i18n` file from bundle. (example: `init.theme.json`)
            let loadLangFile = fileToDic(name: "\(value).\(GigyaNss.langPrefix)")

            if let lang = defaultLang {
                loadAsset["lang"] = lang
            }

            if let i18n = loadLangFile {
                loadAsset["i18n"] = i18n
            }

            if let themeFile = loadFileTheme {
                if let themeMap = themeFile["theme"] {
                    loadAsset["theme"] = themeMap
                }

                if let customThemes = themeFile["customThemes"] {
                     loadAsset["customThemes"] = customThemes
                 }
            }

            response(loadAsset)

        case .id(let value):
            var params = ["screenSetId": value]
            if let defaultLang = defaultLang {
                params["lang"] = defaultLang
            }
            
            busnessApi?.sendApi(api: "accounts.getNativeScreenSet", params: ["screenSetId": value, "lang": defaultLang ?? ""]) { [weak self] (result) in
                switch result {
                case .success(data: let data):
                    guard let decodedObject = try? JSONSerialization.jsonObject(with: JSONEncoder().encode(data)) as? [String: AnyObject] else {
                          assertionFailure("Failed to serialize account object")
                          return
                    }
                    var screenSet = decodedObject["screenSet"] as! [String : Any]
                    if let lang = defaultLang {
                        screenSet["lang"] = lang
                    }

                    response(screenSet)
                case .failure(let error):
                    self?.errorClosure(error)
                }
            }
            break
        }

    }

}
