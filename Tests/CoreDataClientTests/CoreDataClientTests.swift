import XCTest
import CoreData
@testable import CoreDataClient

final class CoreDateServiceTests: XCTestCase {
    private var sut: (any CoreDataClient<TestItem>)!
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
        sut = CoreDataFactory().buildClient(
            persistantContainer: inMemoryPersistentContainer,
            mapper: CDTestMapper()
        )
    }
    
    override func tearDown() {
        sut = nil
        inMemoryPersistentContainer = nil
    }
    
    func test_save_all() throws {
        // Given
        let expectation = XCTestExpectation(description: "Background task completed")
        let context = inMemoryPersistentContainer.viewContext

        // When
        sut.saveAll(items: testData) { _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
        
        // Then
        
        let request = CDTestEntity.fetchRequest()

        let items = try context.fetch(request).map { TestItem(cdModel: $0) }
        
        XCTAssertEqual(testData, items.sorted(by: { $0.id < $1.id }))
    }
    
    func test_get_items() throws {
        // Given
        let context = inMemoryPersistentContainer.viewContext
        
        for item in testData {
            let cdTestItem = CDTestEntity(context: context)
            cdTestItem.id = item.id
        }
        
        try context.save()
        
        // When
        
        let items = sut.getItems(predicate: nil, configuration: nil)
        
        // Then
        
        XCTAssertEqual(testData, items.sorted(by: { $0.id < $1.id }))
    }
    
    func test_clear_database() throws {

    }
    
    func test_get_item() throws {
        
    }
    
    func test_save_item() throws {
        
    }
    
    func test_delete_item() throws {
        
    }
    
    func test_delete_items() throws {
        
    }
    
    func test_update_item() throws {
        
    }
}

private extension CoreDateServiceTests {
    struct TestItem: ItemConvertable, Equatable {
        let id: Int64
    
        init(id: Int64) {
            self.id = id
        }

        init(cdModel: CDTestEntity) {
            self.id = cdModel.id
        }
    }

    struct CDTestMapper: CDMapper {
        func convert(from cdModel: CDTestEntity) -> TestItem {
            return TestItem(cdModel: cdModel)
        }
        
        func convert(
            from item: TestItem,
            context: NSManagedObjectContext
        ) -> CDTestEntity {
            let entity = CDTestEntity(context: context)
            entity.id = item.id
            return entity
        }
    }
}
