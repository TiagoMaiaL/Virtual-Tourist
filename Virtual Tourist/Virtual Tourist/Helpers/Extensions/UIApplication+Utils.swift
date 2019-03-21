//
//  UIApplication+Utils.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 20/03/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit

extension UIApplication {

    /// Display or hides the app's networking activity indicator.
    func enableNetworkingActivityIndicator(_ isEnabled: Bool) {
        DispatchQueue.main.async {
            self.isNetworkActivityIndicatorVisible = isEnabled
        }
    }
}
