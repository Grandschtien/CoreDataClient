import Foundation
import CoreData

final class CoreDataClientImpl<
    Item: ItemConvertable,
    CDModel: NSManagedObject,
    Mapper: CDMapper
>: CoreDataClient where Item.CDModel == CDModel, Mapper.Item == Item, Mapper.CDModel == CDModel {
    private let persistentContainer: NSPersistentContainer
    private let mapper: Mapper
    
    public init(
        mapper: Mapper,
        persistentContainer: NSPersistentContainer
    ) {
        self.mapper = mapper
        self.persistentContainer = persistentContainer
        
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    
    public init(
        mapper: Mapper,
        modelName: String
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
    
    func getItems(
        predicate: NSPredicate?,
        configuration: FetchRequestConfiguration?
    ) -> [Item] {
        var items: [Item] = []
        
        context.performAndWait {
            guard let fetchRequest = makeFetchRequest(
                with: predicate,
                configuration: configuration
            ) else { return }
            
            do {
                let result = try context.fetch(fetchRequest)
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
}

// MARK: - Private
private extension CoreDataClientImpl {
    func makeFetchRequest(
        with predicate: NSPredicate?,
        configuration: FetchRequestConfiguration?
    ) -> NSFetchRequest<CDModel>? {
        guard let fetchRequest = CDModel.fetchRequest() as? NSFetchRequest<CDModel> else {
            assertionFailure("Cannot cast fetch request of type \(CDModel.self)")
            return nil
        }

        fetchRequest.predicate = predicate
        
        guard let configuration else { return fetchRequest }
        
        let builder = FetchRequestBuilder(fetchRequst: fetchRequest)
        
        builder.add(sortDescriptors: configuration.sortDescriptors)
        builder.add(fetchLimit: configuration.fetchLimit)
        builder.add(resultType: configuration.resultType)
        builder.add(returnsObjectsAsFaults: configuration.returnsObjectsAsFaults)
        builder.add(
            relationshipKeyPathsForPrefetching: configuration.relationshipKeyPathsForPrefetching
        )
        builder.add(fetchBatchSize: configuration.fetchBatchSize)

        return builder.build()
    }
    
}
