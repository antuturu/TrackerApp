//
//  ScheduleModel.swift
//  TrackerApp
//
//  Created by Александр Акимов on 11.03.2024.
//

import Foundation

struct ScheduleModel {
    let day: WeekDayModel
    let isOn: Bool
}

enum WeekDayModel: Int, CaseIterable {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1

    var value: String {
            switch self {
            case .monday:
                return NSLocalizedString("Monday", comment: "")
            case .tuesday:
                return NSLocalizedString("Tuesday", comment: "")
            case .wednesday:
                return NSLocalizedString("Wednesday", comment: "")
            case .thursday:
                return NSLocalizedString("Thursday", comment: "")
            case .friday:
                return NSLocalizedString("Friday", comment: "")
            case .saturday:
                return NSLocalizedString("Saturday", comment: "")
            case .sunday:
                return NSLocalizedString("Sunday", comment: "")
            }
        }

    var shortValue: String {
            switch self {
            case .monday:
                return NSLocalizedString("Mon", comment: "")
            case .tuesday:
                return NSLocalizedString("Tue", comment: "")
            case .wednesday:
                return NSLocalizedString("Wed", comment: "")
            case .thursday:
                return NSLocalizedString("Thu", comment: "")
            case .friday:
                return NSLocalizedString("Fri", comment: "")
            case .saturday:
                return NSLocalizedString("Sat", comment: "")
            case .sunday:
                return NSLocalizedString("Sun", comment: "")
            }
        }
    
    static func calculateScheduleValue(for schedule: [WeekDayModel]) -> Int16 {
        var scheduleValue: Int16 = 0
        for day in schedule {
            let dayRawValue = Int16(1 << day.rawValue)
            scheduleValue |= dayRawValue
        }
        return scheduleValue
    }
    
    static func calculateScheduleArray(from value: Int16) -> [WeekDayModel] {
        var schedule: [WeekDayModel] = []
        for day in WeekDayModel.allCases {
            if value & (1 << day.rawValue) != 0 {
                schedule.append(day)
            }
        }
        return schedule
    }
}
