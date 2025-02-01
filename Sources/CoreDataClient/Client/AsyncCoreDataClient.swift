//
//  AsyncCoreDataClient.swift
//  CoreDataClient
//
//  Created by Егор Шкарин on 30.01.2025.
//

import Foundation
import CoreData

public protocol AsyncCoreDataClient<Item> {
    associatedtype Item: ItemConvertable
    associatedtype CDModel: NSManagedObject where Item.CDModel == CDModel

    func saveAll(
        items: [Item]
    ) async throws
    
    func getItems(
        predicate: NSPredicate?,
        configuration: FetchRequestConfiguration?
    ) async throws -> [Item]
    
    func deleteItems(
        via predicate: NSPredicate
    ) async throws
    
    func deleteAll() async throws

    func updateItem(
        predicate: NSPredicate,
        updateBlock: @escaping (CDModel) -> Void
    ) async throws
    
    func refreshViewContext()
}

public extension AsyncCoreDataClient {
    /// Method returns first item from selection
    func getItem() async throws -> Item? {
        let configuration = FetchRequestConfiguration(fetchLimit: 1)
        return try await getItems(predicate: nil, configuration: configuration).first
    }
    
    /// Method returns first item from selection according to given predicate
    func getItem(with predicate: NSPredicate? = nil) async throws -> Item? {
        let configuration = FetchRequestConfiguration(fetchLimit: 1)
        return try await getItems(predicate: predicate, configuration: configuration).first
    }
    
    func save(item: Item) async throws {
        try await saveAll(items: [item])
    }
}
