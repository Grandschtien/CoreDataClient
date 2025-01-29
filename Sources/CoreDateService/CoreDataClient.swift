// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import CoreData

protocol CoreDataClient<Item> {
    associatedtype Item: ItemConvertable
    func saveAll(items: [Item])
    func getItems() -> [Item]
    func getItem() -> Item
    func save(item: Item)
    func clearDatabase()
}

final class CoreDataClientImpl<
    Item: ItemConvertable,
    CDModel: NSManagedObject,
    Mapper: CDMapper
>: CoreDataClient where Item.CDModel == CDModel, Mapper.Item == Item, Mapper.CDModel == CDModel {
    private let persistentContainer: NSPersistentContainer
    private let mapper: Mapper
    
    init(
        modelName: String,
        mapper: Mapper
    ) {
        self.mapper = mapper
        self.persistentContainer = NSPersistentContainer(name: modelName)
        
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    
    private var context: NSManagedObjectContext {
        let context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }
    
    func saveAll(items: [Item]) {
        persistentContainer.performBackgroundTask { [weak self] context in
            for post in items {
                _ = self?.mapper.convert(from: post, context: context)
            }
                        
            do {
                try context.save()
                debugPrint("[INFO] Saved \(items.count) records")
            } catch {
                context.rollback()
                debugPrint("[ERROR] Storing value failed with error: \(error.localizedDescription)")
            }
        }
    }
    
    func getItems() -> [Item] {
        var items: [Item] = []

        context.performAndWait {
            let fetchRequest = CDModel.fetchRequest()
            do {
                let result = try context.fetch(fetchRequest).compactMap { $0 as? CDModel }
                debugPrint("[INFO] successfully retrieved \(result.count) records")
                items = result.map {
                    mapper.convert(from: $0)
                }
            } catch {
                context.rollback()
                debugPrint("[ERROR] Fetching faild with error: \(error.localizedDescription)")
            }
            
        }

        return items
    }
    
    func clearDatabase() {
        persistentContainer.performBackgroundTask { context in
            let fetchRequest = CDModel.fetchRequest()

            do {
                let objects = try context.fetch(fetchRequest).compactMap { $0 as? CDModel }
        
                for object in objects {
                    context.delete(object)
                }
                try context.save()
                debugPrint("[INFO] Database cleared successfully")
            } catch {
                context.rollback()
                debugPrint("[ERROR] Resetting databaes failed")
            }
        }
    }

    func getItem() -> Item {
        fatalError()
    }
    
    func save(item: Item) {
        fatalError()
    }
}
