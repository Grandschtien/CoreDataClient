import Foundation
import CoreData

final class CoreDataClientImpl<
    Item: ItemConvertable,
    CDModel: NSManagedObject,
    Mapper: CDMapper
> {
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
        return persistentContainer.viewContext
    }
}

// MARK: - CoreDataClient
extension CoreDataClientImpl: CoreDataClient where Item.CDModel == CDModel, Mapper.Item == Item, Mapper.CDModel == CDModel {
    func saveAll(items: [Item], completion: ((Error?) -> Void)?) {
        persistentContainer.performBackgroundTask { [weak self] context in
            for post in items {
                _ = self?.mapper.convert(from: post, context: context)
            }
                        
            do {
                try context.save()
                completion?(nil)
                debugPrint("[INFO] Saved \(items.count) records")
            } catch {
                context.rollback()
                completion?(error)
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

    func deleteItems(
        via predicate: NSPredicate,
        completion: ((Error?) -> Void)?
    ) {
        persistentContainer.performBackgroundTask { context in
            let fetchRequest = CDModel.fetchRequest()
            fetchRequest.predicate = predicate
            
            do {
                let objects = try context.fetch(fetchRequest).compactMap { $0 as? CDModel }
                
                objects.forEach {
                    context.delete($0)
                }
                
                try context.save()
                completion?(nil)
                debugPrint("[INFO] Droped all item via predicate: \(predicate.predicateFormat)")
            } catch {
                context.rollback()
                completion?(error)
                debugPrint("[ERROR] Dropping items failed for predicate: \(predicate.predicateFormat)")
            }
        }
    }
    
    func updateItem(
        predicate: NSPredicate,
        updateBlock: @escaping (CDModel) -> Void,
        completion: ((Error?) -> Void)?
    ) {
        persistentContainer.performBackgroundTask { context in
            let fetchRequest = CDModel.fetchRequest()
            do {
                let objects = try context.fetch(fetchRequest).compactMap { $0 as? CDModel }
                
                if let object = objects.first {
                    updateBlock(object)
                }
                
                try context.save()
                completion?(nil)
                debugPrint("[INFO] Item updated")
            } catch {
                context.rollback()
                completion?(error)
                debugPrint("[ERROR] Item update failed")
            }
        }
    }
    
    func deleteAll(completion: ((Error?) -> Void)?) {
        persistentContainer.performBackgroundTask { context in
            let fetchRequest = CDModel.fetchRequest()
            
            do {
                let objects = try context.fetch(fetchRequest).compactMap { $0 as? CDModel }
                
                for object in objects {
                    context.delete(object)
                }
                try context.save()
                completion?(nil)
                debugPrint("[INFO] Database cleared successfully")
            } catch {
                context.rollback()
                completion?(error)
                debugPrint("[ERROR] Resetting databaes failed")
            }
        }
    }
}

// MARK: - AsyncCoreDataClient
extension CoreDataClientImpl: AsyncCoreDataClient where Item.CDModel == CDModel, Mapper.Item == Item, Mapper.CDModel == CDModel {
    func saveAll(items: [Item]) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            saveAll(items: items) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    func deleteItems(via predicate: NSPredicate) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            deleteItems(via: predicate) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    func deleteAll() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            deleteAll { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    func updateItem(
        predicate: NSPredicate,
        updateBlock: @escaping (CDModel) -> Void
    ) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            updateItem(predicate: predicate, updateBlock: updateBlock) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    func refreshViewContext() {
        context.performAndWait {
            context.refreshAllObjects()
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
