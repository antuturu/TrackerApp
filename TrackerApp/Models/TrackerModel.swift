//
//  TrackerModel.swift
//  TrackerApp
//
//  Created by Александр Акимов on 20.02.2024.
//

import UIKit

struct Tracker {
    let idTracker: UUID
    let name: String
    let color: UIColor
    let colorString: String
    let emoji: String
    let schedule: [WeekDayModel]
}
