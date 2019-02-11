//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 11/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData

/// The class in charge of handling the core data stack.
class DataController {

    // MARK: Properties

    /// The persistent container of the core data stack.
    let persistentContainer: NSPersistentContainer

    /// The core data context associated with the main queue.
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: Initializers

    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }

    // MARK: Imperatives

    /// Initializes the core data stack.
    /// - Parameter completionHandler: the completion handler called when core data is loaded,
    ///                                with an error, if occurred.
    func load(_ completionHandler: @escaping (NSPersistentStoreDescription?, Error?) -> Void) {
        persistentContainer.loadPersistentStores(completionHandler: completionHandler)
    }

    /// Persists the main context changes, if any.
    func save() throws {
        if viewContext.hasChanges {
            try viewContext.save()
        }
    }
}
