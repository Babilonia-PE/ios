//
//  Constants.swift
//  Core
//
//  Created by Denis on 7/2/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import CoreLocation.CLLocation

public enum Constants {
    
    public enum API {
        
        public static let baseURL: URL = {
            return Environment.default.hostURL
        }()
        
        public static let paymentBaseURL: URL = {
            let url = Environment.default.paymentURL
            return url
        }()
        
    }
    
    public enum Location {
        
    //    public static let defaultLocation = CLLocationCoordinate2D(latitude: -12.0264987, longitude: -77.0679746)
        public static let defaultLocation = CLLocationCoordinate2D(latitude: -12.119031, longitude: -77.028803)

    }
    
    public enum Currency {
    
        public static let defaultCode = "USD"
        
    }
    
}
