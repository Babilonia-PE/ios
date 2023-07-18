//
//  AppConfigRequests.swift
//  Core
//
//  Created by Anna Sahaidak on 7/16/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import YALAPIClient

struct AppConfigRequest: APIRequest, DecoratableRequest {
    
    let method: APIRequestMethod = .get
    let path = "app_config"
    let authRequired: Bool = false
    
}
