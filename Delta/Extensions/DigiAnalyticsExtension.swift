//
//  DigiAnalyticsExtension.swift
//  Delta
//
//  Created by Nathan FALLET on 15/05/2021.
//  Copyright © 2021 Nathan FALLET. All rights reserved.
//

import DigiAnalytics

extension DigiAnalytics {
    
    #if DEBUG
    static let shared = DigiAnalytics(baseURL: "https://debug.delta-algorithms.com/")
    #else
    static let shared = DigiAnalytics(baseURL: "https://app.delta-algorithms.com/")
    #endif
    
}
