//
//  AlertPresenter.swift
//  PodShare
//
//  Created by Richard on 8/13/18.
//  Copyright © 2018 wongRichardH. All rights reserved.
//

import Foundation
import UIKit

class AlertPresenter {

    let baseVC: UIViewController

    init(baseVC: UIViewController) {
        self.baseVC = baseVC
    }

    func showAlert(alertTitle: String, alertMessage: String) {
        let alertController = UIAlertController(title: alertTitle,
                                                message: alertMessage,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.baseVC.present(alertController, animated: true, completion: nil)
    }

}
