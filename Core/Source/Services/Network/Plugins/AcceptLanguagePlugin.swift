//
//  AcceptLanguagePlugin.swift
//  Core
//
//  Created by Alya Filon  on 21.01.2021.
//  Copyright © 2021 Yalantis. All rights reserved.
//

import YALAPIClient

final class AcceptLanguagePlugin: PluginType {

    func prepare(_ request: APIRequest) -> APIRequest {
        var requestProxy = APIRequestProxy(request: request)
        applyHeader(&requestProxy)

        return requestProxy
    }

    private func applyHeader(_ request: inout APIRequestProxy) {
        var headers = request.headers ?? [:]
        headers["Accept-Language"] = localeName()
        request.headers = headers
    }

    private func localeName() -> String {
        let esCode = "es"
        let enCode = "en"

        if let locale = NSLocale.current.languageCode,
           locale.contains(esCode) {
            return esCode
        }

        return enCode
    }
    
}
