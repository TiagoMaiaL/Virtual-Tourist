//
//  SplashViewController.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 11/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit

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
                debugPrint("An error occurred - \(error!)")
                // TODO: Display an error to the user.
                return
            }

            self.performSegue(withIdentifier: SegueIdentifiers.ShowMap, sender: nil)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.ShowMap,
            let navigationController = segue.destination as? UINavigationController,
            let mapController = navigationController.visibleViewController as? MapViewController {

            navigationController.modalPresentationStyle = .custom
            navigationController.transitioningDelegate = self

            mapController.dataController = dataController
            mapController.pinStore = pinStore
            mapController.albumStore = albumStore
            mapController.flickrService = flickrService
        }
    }
}

extension SplashViewController: UIViewControllerTransitioningDelegate {

    // MARK: UIViewControllerTransitioningDelegate Methods

    public func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
        ) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}

extension SplashViewController: UIViewControllerAnimatedTransitioning {

    // MARK: UIViewControllerAnimatedTransitioning Methods

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let currentView = view!
        let container = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!

        let currentViewSnapshot = currentView.snapshotView(afterScreenUpdates: false)!
        container.addSubview(toView)
        container.addSubview(currentViewSnapshot)

        UIView.animate(withDuration: 0.5, animations: {
            currentViewSnapshot.alpha = 0
        }) { completed in
            transitionContext.completeTransition(completed)
        }
    }
}
