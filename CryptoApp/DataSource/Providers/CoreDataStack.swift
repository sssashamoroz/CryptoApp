//
//  CoreDataStack.swift
//  CryptoApp
//
//  Created by Aleksandr Morozov on 22/10/24.
//
import Foundation
import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()
    private let persistentContainerName = "CryptoAppDataModel"

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: persistentContainerName)
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Failed to load persistent stores: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
}

// MARK: - Extension for Saving and Fetching
extension CoreDataStack {
    // Save context with error handling
    func saveContext() {
        guard viewContext.hasChanges else { return }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            NSLog("Unresolved error saving context: \(nsError), \(nsError.userInfo)")
        }
    }

    func fetchEntities<T: NSManagedObject>(_ entity: T.Type, predicate: NSPredicate? = nil) -> [T] {
        let request = T.fetchRequest()
        request.predicate = predicate

        do {
            return try viewContext.fetch(request) as? [T] ?? []
        } catch {
            print("Fetch failed with error: \(error)")
            return []
        }
    }
    
    func fetchFavoriteCryptoEntities() -> [FavoriteCrypto] {
        return fetchEntities(FavoriteCrypto.self)
    }
}
