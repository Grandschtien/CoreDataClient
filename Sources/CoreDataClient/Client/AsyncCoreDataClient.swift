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
    
    func saveAll(items: [Item]) async throws
    
    func getItems(
        predicate: NSPredicate?,
        configuration: FetchRequestConfiguration?
    ) async throws -> [Item]
    
    func deleteItems(
        items: [Item],
        predicate: NSPredicate
    ) async throws
    
    func updateItems(
        items: [Item],
        predicate: NSPredicate
    ) async throws
}
