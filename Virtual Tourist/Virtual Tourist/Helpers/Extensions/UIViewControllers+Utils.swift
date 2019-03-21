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

/// Adds error alerts features.
extension UIViewController {

    // MARK: Imperatives

    /// Creates a default error alert configured with the passed message.
    /// - Parameters:
    ///     - message: the message to be displayed to the user.
    ///     - action: the action to be taken when the user selects the default action.
    /// - Returns: the configured error alert controller.
    func makeErrorAlertController(
        withMessage message: String,
        andDefaultActionHandler action: ((UIAlertAction) -> Void)? = nil
        ) -> UIAlertController {
        return makeErrorAlertController(
            withMessage: message,
            actionTitle: NSLocalizedString("Ok", comment: "The title of the default alert action."),
            andDefaultActionHandler: action
        )
    }

    /// Creates an error alert configured with the passed message and default action options.
    /// - Parameters:
    ///     - message: the message to be displayed to the user.
    ///     - title: the title of the default action button.
    ///     - action: the action to be taken when the user selects the default button.
    /// - Returns: the configured error alert controller.
    func makeErrorAlertController(
        withMessage message: String,
        actionTitle title: String,
        andDefaultActionHandler action: ((UIAlertAction) -> Void)? = nil
        ) -> UIAlertController {
        let alert = makeAlertController(
            withTitle: NSLocalizedString("Error", comment: "The title of the alert to be displayed."),
            andMessage: message
        )
        alert.addAction(UIAlertAction(
            title: title,
            style: .default,
            handler: action
        ))

        return alert
    }

    /// Creates an alert configured with the passed title and message.
    /// - Parameters:
    ///     - title: the title of the alert.
    ///     - message: the message of the alert.
    /// - Returns: the configured alert controller.
    func makeAlertController(withTitle title: String, andMessage message: String) -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: .alert)
    }
}
