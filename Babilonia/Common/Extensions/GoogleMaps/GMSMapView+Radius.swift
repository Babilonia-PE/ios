//
//  GMSMapView+Radius.swift
//  Babilonia
//
//  Created by Denis on 7/28/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import GoogleMaps

/// based on this answer https://stackoverflow.com/a/40531001

extension GMSMapView {
    
    func getCenterCoordinate() -> CLLocationCoordinate2D {
        let centerPoint = center
        let centerCoordinate = projection.coordinate(for: centerPoint)
        
        return centerCoordinate
    }
    
    func getTopCenterCoordinate() -> CLLocationCoordinate2D {
        let topCenterCoordinate = convert(CGPoint(x: frame.size.width / 2, y: 0), from: self)
        let point = projection.coordinate(for: topCenterCoordinate)
        
        return point
    }
    
    func getRadius() -> CLLocationDistance {
        let centerCoordinate = getCenterCoordinate()
        let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        let topCenterCoordinate = getTopCenterCoordinate()
        let topCenterLocation = CLLocation(
            latitude: topCenterCoordinate.latitude,
            longitude: topCenterCoordinate.longitude
        )
        let radius = CLLocationDistance(centerLocation.distance(from: topCenterLocation))
        
        return radius
    }
    
}
