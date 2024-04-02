//
//  TrackerRecordStore.swift
//  TrackerApp
//
//  Created by Александр Акимов on 21.03.2024.
//

import UIKit
import CoreData

private enum TrackerRecordStoreErrors: Error {
    case failedToFetchTracker
    case failedToFetchRecord
}

protocol TrackerRecordStoreProtocol {
    func fetchRecords() throws -> [TrackerRecord]
    func createRecord(id: UUID, date: Date) throws
    func deleteRecord(id: UUID, date: Date) throws
}

final class TrackerRecordStore: NSObject, TrackerRecordStoreProtocol {
    private let context: NSManagedObjectContext
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    func fetchRecords() throws -> [TrackerRecord] {
        let request = TrackerRecordCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        let objects = try context.fetch(request)
        let records = objects.compactMap { object -> TrackerRecord? in
            guard let date = object.date, let id = object.id else { return nil }
            return TrackerRecord(id: id, date: date)
        }
        return records
    }
    
    private func fetchTrackerCoreData(for id: UUID) throws -> TrackerCoreData? {
        let request = TrackerCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(
            format: "%K = %@",
            #keyPath(TrackerCoreData.idTracker), id as CVarArg
        )
        return try context.fetch(request).first
    }
    
    private func fetchTrackerRecordCoreData(for id: UUID, and date: Date) throws -> TrackerRecordCoreData? {
        let request = TrackerRecordCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(
            format: "%K = %@ AND %K = %@",
            #keyPath(TrackerRecordCoreData.tracker.idTracker), id as CVarArg,
            #keyPath(TrackerRecordCoreData.date), date as CVarArg
        )
        return try context.fetch(request).first
    }
    
    private func saveContext() throws {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
    
    func createRecord(id: UUID, date: Date) throws {
        guard let trackerCoreData = try fetchTrackerCoreData(for: id) else {
            throw TrackerRecordStoreErrors.failedToFetchTracker
        }
        
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.id = id
        trackerRecordCoreData.date = date
        trackerRecordCoreData.tracker = trackerCoreData
        
        try saveContext()
    }
    
    func deleteRecord(id: UUID, date: Date) throws {
        guard let trackerRecordCoreData = try fetchTrackerRecordCoreData(for: id, and: date) else {
            throw TrackerRecordStoreErrors.failedToFetchRecord
        }
        print(trackerRecordCoreData)
        context.delete(trackerRecordCoreData)
        try saveContext()
    }
}
