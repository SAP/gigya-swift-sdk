//
//  JsEvaluatorHelper.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 05/11/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import JavaScriptCore
import Gigya

class JsEvaluatorHelper {
    private func setData(context: JSContext, data: [String: Any]) {
        for (key, value) in data {
            context.setObject(value, forKeyedSubscript: key as NSString)
        }
    }

    private func makeExpressions(data: [String: Any]) -> String {
        let result = data.map { (key, value) in
            return "\(key):(\(value)).toString()"
        }
        .joined(separator: ", ")

        return "{\(result)}"
    }

    func eval(data: [String: Any], expressions: [String: Any]) -> String {
        let context = JSContext()!
        setData(context: context, data: data)
        
        let jsExp = makeExpressions(data: expressions)

        let result = context
            .evaluateScript("JSON.stringify(\(jsExp))")
            .toString() ?? "{}"

        return result == "undefined" ? "{}" : result
    }
}
