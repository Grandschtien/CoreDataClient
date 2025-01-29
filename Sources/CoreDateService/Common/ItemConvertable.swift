//
//  File.swift
//  CoreDateService
//
//  Created by Егор Шкарин on 29.01.2025.
//

import Foundation
import CoreData

public protocol ItemConvertable<CDModel> {
    associatedtype CDModel: NSManagedObject
    init(cdModel: CDModel)
}
