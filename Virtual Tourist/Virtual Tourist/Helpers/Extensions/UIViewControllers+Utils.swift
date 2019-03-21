//
//  UIViewControllers+Utils.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 20/03/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Adds support to the Notification API.
extension UIViewController {

    // MARK: Imperatives

    /// Removes this controller from all notifications registered.
    func stopObservingNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    /// Starts observing a specific notification.
    func startObservingNotification(withName name: Notification.Name, usingSelector selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: nil)
    }
}
