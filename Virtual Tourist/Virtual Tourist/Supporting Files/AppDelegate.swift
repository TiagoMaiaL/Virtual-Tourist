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

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {
        // Inject the initial dependencies of the app.
        guard let splashController = window?.rootViewController as? SplashViewController else {
            preconditionFailure("Couldn't get the initial app controller.")
        }

        dataController = DataController(modelName: "Virtual_Tourist")
        splashController.dataController = dataController

        // TODO: Remove this test code later on.
        let pinRequest: NSFetchRequest<PinMO> = PinMO.fetchRequest()
        let pins = try! dataController.viewContext.fetch(pinRequest)
        if let firstPin = pins.first {
            // Test the images request.
            let client = APIClient(session: .shared)
            let service = FlickrService(apiClient: client)
            service.requestPinRelatedImages(fromPin: firstPin) { flickrResponseData, error in
                guard error == nil, let flickrReponseData = flickrResponseData else {
                    print(error)
                    return
                }

                // TODO: Continue with the save process.
            }
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

