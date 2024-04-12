//
//  AnalyticsService.swift
//  TrackerApp
//
//  Created by Александр Акимов on 09.04.2024.
//

import Foundation
import AppMetricaCore

struct AnalyticsService {
    
    func report(event: String, params : [AnyHashable : Any]) {
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
    
}
