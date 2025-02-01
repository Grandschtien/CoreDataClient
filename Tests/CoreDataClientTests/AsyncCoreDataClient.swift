//
//  AsyncCoreDataClient.swift
//  CoreDataClient
//
//  Created by Егор Шкарин on 01.02.2025.
//

import XCTest
import CoreData
@testable import CoreDataClient

final class AsyncCoreDataClientTest: XCTestCase {
    private var sut: (any AsyncCoreDataClient<TestItem>)!
    private var inMemoryPersistentContainer: NSPersistentContainer!
    
    private let testData = [
        TestItem(id: 1),
        TestItem(id: 2),
        TestItem(id: 3),
        TestItem(id: 4),
        TestItem(id: 5)
    ]
    
    override func setUp() {
        let modelName = "TestModel"
        
        guard let modelURL = Bundle.module.url(forResource: modelName, withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL)
        else {
            fatalError("Не удалось загрузить Core Data модель из пакета")
        }
        
        inMemoryPersistentContainer = NSPersistentContainer(
            name: modelName,
            managedObjectModel: model
        )
        
        inMemoryPersistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        inMemoryPersistentContainer.persistentStoreDescriptions = [description]
        sut = CoreDataClientImpl(
            mapper: CDTestMapper(),
            persistentContainer: inMemoryPersistentContainer
        )
    }
    
    override func tearDown() {
        sut = nil
        inMemoryPersistentContainer = nil
    }
    
    func test_save_all_async() async throws {
        // Given
        let context = inMemoryPersistentContainer.viewContext

        // When
        try await sut.saveAll(items: testData)
        
        // Then
        try context.performAndWait {
            let request = CDTestEntity.fetchRequest()

            let items = try context.fetch(request).map { TestItem(cdModel: $0) }
            
            XCTAssertEqual(testData, items.sorted(by: { $0.id < $1.id }))
        }
    }
    
    func test_get_items() async throws {
        // Given
        let context = inMemoryPersistentContainer.viewContext
        
        try context.performAndWait {
            for item in testData {
                let cdTestItem = CDTestEntity(context: context)
                cdTestItem.id = item.id
            }
            
            try context.save()
        }
        // When
        
        let items = try await sut.getItems(predicate: nil, configuration: nil)
        
        // Then
        
        XCTAssertEqual(testData, items.sorted(by: { $0.id < $1.id }))
    }
    
    func test_delete_all() async throws {
        // Given
        let context = inMemoryPersistentContainer.viewContext
        try context.performAndWait {
            for item in testData {
                let cdTestItem = CDTestEntity(context: context)
                cdTestItem.id = item.id
            }
            
            try context.save()
        }
        // when
        try await sut.deleteAll()
                
        // Then
        try context.performAndWait {
            let request = CDTestEntity.fetchRequest()
            
            let items = try context.fetch(request).map { TestItem(cdModel: $0) }
            
            XCTAssertTrue(items.isEmpty)
        }
    }
    
    func test_get_item() async throws {
        // Given
        let context = inMemoryPersistentContainer.viewContext
        try context.performAndWait {
            let cdTestItem = CDTestEntity(context: context)
            cdTestItem.id = 1
            try context.save()
        }

        // When
        let predicate = NSPredicate(format: "id == %d", 1)
        let item = try await sut.getItem(with: predicate)
        
        // Then
        XCTAssertEqual(testData.first, item)
    }
    
    func test_save_item() async throws {
        // Given
        let context = inMemoryPersistentContainer.viewContext
        let expectedItem = TestItem(id: 1)
        
        // When
        try await sut.save(item: expectedItem)
                
        // Then
        
        try context.performAndWait {
            let request = CDTestEntity.fetchRequest()
            
            let fetchedItem = try context.fetch(request).map { TestItem(cdModel: $0) }.first
            
            XCTAssertEqual(expectedItem, fetchedItem)
        }
    }
    
    func test_delete_item() async throws {
        // Given
        
        let context = inMemoryPersistentContainer.viewContext
        
        try context.performAndWait {
            for item in testData {
                let cdTestItem = CDTestEntity(context: context)
                cdTestItem.id = item.id
            }
            
            try context.save()
        }
        
        // When
        let predicate = NSPredicate(format: "id == %d", 1)
        try await sut.deleteItems(via: predicate)
                
        // Then
        try context.performAndWait {
            let request = CDTestEntity.fetchRequest()
            
            let fetchedItems = try context.fetch(request).map { TestItem(cdModel: $0) }
            
            XCTAssertFalse(fetchedItems.contains(where: { $0.id == 1}))
        }
    }
    
    func test_update_item() async throws {
        // Given
        let context = inMemoryPersistentContainer.viewContext
        
        try context.performAndWait {
            let cdTestItem = CDTestEntity(context: context)
            cdTestItem.id = 1
            
            try context.save()
        }
        
        // When
        let predicate = NSPredicate(format: "id == %d", 1)
        
        try await sut.updateItem(predicate: predicate) { model in
            model.id = 2
        }
                
        // Then
        try context.performAndWait {
            context.refreshAllObjects()
            
            let request = CDTestEntity.fetchRequest()
            
            request.predicate =  NSPredicate(format: "id == %d", 2)
            
            let fetchedItems = try context.fetch(request)
            
            XCTAssertTrue(fetchedItems.first?.id == 2)
        }
    }
}
