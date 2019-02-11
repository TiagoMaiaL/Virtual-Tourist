//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 11/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: Properties

    /// The main window of the app.
    var window: UIWindow?

    /// The data controller of the app, in charge of handling core data.
    var dataController: DataController!

    // MARK: App life cycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Load core data.
        dataController = DataController(modelName: "Virtual_Tourist")
        dataController.load { description, error in
            print("Stack loaded =D.")
        }

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        try? dataController.save()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        try? dataController.save()
    }
}

