//
//  PluginViewWrapper.swift
//  GigyaSwift
//
//  Created by Tal Mirmelshtein on 01/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

protocol PluginViewWrapperProtocol {
    
    func presentPluginController<T: GigyaAccountProtocol>(viewController: UIViewController, dataType: T.Type, screenSet: String?)
}

class PluginViewWrapper<T: GigyaAccountProtocol>: PluginViewWrapperProtocol {
    
    let config: GigyaConfig
    
    let sessionService: IOCSessionServiceProtocol
    
    let businessApiService: IOCBusinessApiServiceProtocol

    var completion: (PluginEvent<T>) -> Void?
    
    var plugin: String
    
    var params: [String:Any]
    
    init(config: GigyaConfig, sessionService: IOCSessionServiceProtocol, businessApiService: IOCBusinessApiServiceProtocol,
         plugin: String, params: [String: Any], completion: @escaping (PluginEvent<T>) -> Void) {
        self.config = config
        self.sessionService = sessionService
        self.businessApiService = businessApiService
        self.completion = completion
        self.plugin = plugin
        self.params = params
    }
    
    /**
     Present the PluginViewController with requested screenSet.
     
     - Parameter viewController: Current active view controller.
     - Parameter dataType: Account scheme.
     - Parameter screenSet: Requested screen set.
     */
    func presentPluginController<T: GigyaAccountProtocol>(viewController: UIViewController, dataType: T.Type, screenSet: String? = nil) {
        if let screenSet = screenSet {
            params["screenSet"] =  screenSet
        }
        
        let html = getHtml(self.plugin)
//        GigyaLogger.log(with: self, message: "Initial HTML:\n\(html)")

        // Present plugin view controller.
        let pluginViewController = PluginViewController(config: config, sessionService: sessionService, businessApiService: businessApiService, completion: completion)
        let navigationController = UINavigationController(rootViewController: pluginViewController)
        viewController.present(navigationController, animated: true) {
            pluginViewController.load(html: html)
        }
    }
    
    // MARK: - HTML
    
    private func getHtml(_ plugin: String) -> String {
        guard let apiKey = config.apiKey else { return "" }

        let apiDomain = config.apiDomain
        // Organize parameters.
        params["containerID"] = "pluginContainer"
        params["deviceType"] = "mobile"
        if (params.keys.contains("commentsUI")) {
            params["hideShareButtons"] = true
            if let version = params["version"] as? Int {
                if (version == -1) {
                    params["version"] = 2
                }
            }
        }
        if (params.keys.contains("RatingUI") && params.keys.contains("showCommentButton")) {
            params["showCommentButton"] = false
        }
        
        let enableTestNetworksScript = """
            gigya._.providers.arProviders.push(new gigya._.providers.Provider(6016, 'testnetwork3', 650, 400, \'login,friends,actions,status,photos,places,checkins', true));\
            gigya._.providers.arProviders.push(new gigya._.providers.Provider(6017, 'testnetwork4', 650, 400, 'login,friends,actions,status,photos,places,checkins', true));
            """
        
        let html = """
        <head>
            <meta name='viewport' content='initial-scale=1,maximum-scale=1,user-scalable=no' />
            <script>
                function onJSException(ex) {
                document.location.href = 'gsapi://on_js_exception?ex=' + encodeURIComponent(ex);
                }
                function onJSLoad() {
                if (gigya && gigya.isGigya)
                window.__wasSocializeLoaded = true;
                }
                setTimeout(function() {
                if (!window.__wasSocializeLoaded)
                document.location.href = 'gsapi://on_js_load_error';
                }, 10000);
            </script>
            <script src='https://cdns.\(apiDomain)/JS/gigya.js?apikey=\(apiKey)' type='text/javascript' onLoad='onJSLoad();'>
                {
                    deviceType: 'mobile' // consoleLogLevel: 'error'
                }
            </script>
        </head>
            <body>
                <div id='pluginContainer'></div>
                <script>
                    "\(enableTestNetworksScript)"
                    try {
                    gigya._.apiAdapters.mobile.showPlugin('\(plugin)', \(params.asJson));
                    } catch (ex) { onJSException(ex); }
                </script>
            </body>
        """
        return html
    }
    
}
