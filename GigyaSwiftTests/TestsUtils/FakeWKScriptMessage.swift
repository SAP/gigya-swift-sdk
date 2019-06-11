//
//  fakeWKScriptMessage.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 05/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import WebKit

class FakeWKScriptMessage: WKScriptMessage {
    let data: Any

    override var body: Any {
        return data
    }

    init(data: Any) {
        self.data = data

        super.init()
    }
}
