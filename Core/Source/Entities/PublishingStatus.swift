//
//  PublishingStatus.swift
//  Core
//
//  Created by Alya Filon  on 25.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Foundation

public enum PublishingStatusType: String, Codable {
    case new
    case paymentFailed = "payment_failed"
    case processing
    case succeeded
}

public struct PublishingStatus: Codable {

    public var status: PublishingStatusType

}
