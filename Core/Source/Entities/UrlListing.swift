//
//  UrlListing.swift
//  Core
//
//  Created by Rafael Miranda Salas on 15/11/23.
//  Copyright © 2023 Yalantis. All rights reserved.
//

import Foundation

public struct UrlListing: Codable{
    
    public let main: String?
    public let share: String?
    
    public init(main: String?, share: String?) {
        self.main = main
        self.share = share
    }
    
}
