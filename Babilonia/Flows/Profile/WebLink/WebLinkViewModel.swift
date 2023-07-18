//
//  WebLinkViewModel.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/16/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation

final class WebLinkViewModel {
    
    var url: URL? {
        return URL(string: model.urlString)
    }
    
    let title: String
    
    private let model: WebLinkModel
    
    init(model: WebLinkModel, title: String) {
        self.model = model
        self.title = title
    }
    
    func close() {
        model.close()
    }
    
}
