//
//  WebLinkModel.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/16/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

// TODO: Turn "Allow arbitrary loads" back in Info.plist!!!
enum WebLinkEvent: Event {
    case close
}

final class WebLinkModel: EventNode {
    
    let urlString: String
    
    init(parent: EventNode, urlString: String) {
        self.urlString = urlString
        
        super.init(parent: parent)
    }
    
    func close() {
        raise(event: WebLinkEvent.close)
    }
    
}
