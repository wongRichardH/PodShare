//
//  UIViewController+PodShare.swift
//  PodShare
//
//  Created by Richard on 8/15/18.
//  Copyright © 2018 wongRichardH. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func encode(email: String) -> String{
        return email.components(separatedBy: ".").joined(separator: "•")
    }

    func decode(email: String) -> String{
        return email.components(separatedBy: "•").joined(separator: ".")
    }
}
