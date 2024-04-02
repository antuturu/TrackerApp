//
//  TrackerStore.swift
//  TrackerApp
//
//  Created by Александр Акимов on 21.03.2024.
//

import UIKit
import CoreData

struct TrackerStoreUpdate {
    let insertedSections: IndexSet
    let insertedIndexPaths: [IndexPath]
}

private enum TrackerStoreError: Error {
    case decodingErrorInvalidID
}

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidUpdate(_ update: TrackerStoreUpdate)
}

protocol TrackerStoreProtocol {
    func setDelegate(_ delegate: TrackerStoreDelegate)
    func fetchTracker(_ trackerCoreData: TrackerCoreData) throws -> Tracker
    func addTracker(_ tracker: Tracker, toCategory category: TrackerCategory) throws
}

final class TrackerStore: NSObject {
    
    weak var delegate: TrackerStoreDelegate?
    
    private lazy var trackerCategoryStore: TrackerCategoryStoreProtocol = {
        TrackerCategoryStore(context: context)
    }()
    private let context: NSManagedObjectContext
    private var insertedSections: IndexSet = []
    private var insertedIndexPaths: [IndexPath] = []
    private var trackers: [Tracker] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let trackers = try? objects.map({ try self.fetchTracker($0) })
        else { return [] }
        return trackers
    }
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)
        ]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }()
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
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
    
}


extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedSections.removeAll()
        insertedIndexPaths.removeAll()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerStoreDidUpdate(
            TrackerStoreUpdate(
                insertedSections: insertedSections,
                insertedIndexPaths: insertedIndexPaths
            )
        )
        insertedSections.removeAll()
        insertedIndexPaths.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            insertedSections.insert(sectionIndex)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexPaths.append(indexPath)
            }
        default:
            break
        }
    }
}

extension TrackerStore: TrackerStoreProtocol {
    func setDelegate(_ delegate: TrackerStoreDelegate) {
        self.delegate = delegate
    }
    
    func fetchTracker(_ trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.idTracker,
              let name = trackerCoreData.name,
              let colorString = trackerCoreData.color,
              let emoji = trackerCoreData.emoji else {
            throw TrackerStoreError.decodingErrorInvalidID
        }
        
        let color = UIColor(named: colorString) ?? .red
        let schedule = WeekDayModel.calculateScheduleArray(from: trackerCoreData.schedule)
        
        return Tracker(
            idTracker: id,
            name: name,
            color: color,
            colorString: colorString,
            emoji: emoji,
            schedule: schedule
        )
    }
    
    func addTracker(_ tracker: Tracker, toCategory category: TrackerCategory) throws {
        let trackerCategoryCoreData = try trackerCategoryStore.fetchCategoryCoreData(for: category)
        let trackerCoreData = TrackerCoreData(context: context)
        
        trackerCoreData.idTracker = tracker.idTracker
        trackerCoreData.name = tracker.name
        trackerCoreData.color = tracker.colorString
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = WeekDayModel.calculateScheduleValue(for: tracker.schedule)
        trackerCoreData.trackerCategory = trackerCategoryCoreData
        
        try saveContext()
    }
}
