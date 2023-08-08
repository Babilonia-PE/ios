//
//  RecentLocation.swift
//  Babilonia
//
//  Created by Emily Lope on 7/25/21.
//  Copyright © 2021 Yalantis. All rights reserved.
//

import Core

public final class RecentLocation {
    public static let shared = RecentLocation()
    public var locations: [SearchLocation] = []
    public var currentLocation: SearchLocation?
    public var mapCenter = false
    public var searchSession = false
}
