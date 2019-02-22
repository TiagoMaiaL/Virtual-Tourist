//
//  SplashViewController.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 11/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit
//import CoreData

/// The controller in charge of initializng the app's main resources.
class SplashViewController: UIViewController {

    // MARK: Properties

    /// The data controller class used to initialize the core data stack.
    var dataController: DataController!

    /// The pin store used to create new pins.
    var pinStore: PinMOStoreProtocol!

    /// The album store used to manage the albums related to the pins to be added.
    var albumStore: AlbumMOStoreProtocol!

    /// The flickr service used to get images and persist them in an album.
    var flickrService: FlickrServiceProtocol!

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(dataController != nil)
        precondition(pinStore != nil)
        precondition(albumStore != nil)
        precondition(flickrService != nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        dataController.load { storeDescription, error in
            guard error == nil else {
                print("\(error!)")
                // TODO: Display an error to the user.
                return
            }

//            // TODO: Remove this test code later on.
//            DispatchQueue.main.async {
//                let pinRequest: NSFetchRequest<PinMO> = PinMO.fetchRequest()
//                let pins = try! self.dataController.viewContext.fetch(pinRequest)
//                if let firstPin = pins.first {
//                    // Test the images request.
//                    let client = APIClient(session: .shared)
//                    let service = FlickrService(apiClient: client)
//                    service.requestPinRelatedImages(fromPin: firstPin) { flickrResponseData, error in
//                        guard error == nil, let flickrReponseData = flickrResponseData else {
//                            print(error)
//                            return
//                        }
//
//                        // TODO: Continue with the save process.
//                        DispatchQueue.main.async {
//                            let albumStore = AlbumMOStore(photoStore: PhotoMOStore())
//                            self.dataController.viewContext.perform {
//                                try! albumStore.addPhotos(fromFlickrImages: flickrResponseData!.data.photos,
//                                                          toAlbum: firstPin.album!)
//                            }
//                        }
//                    }
//                }
//            }
            self.performSegue(withIdentifier: SegueIdentifiers.ShowMap, sender: nil)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.ShowMap, let mapController = segue.destination as? MapViewController {
            mapController.dataController = dataController
            mapController.pinStore = pinStore
            mapController.albumStore = albumStore
            mapController.flickrService = flickrService
        }
    }
}
