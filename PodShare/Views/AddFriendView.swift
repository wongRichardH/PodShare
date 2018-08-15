//
//  AddFriendView.swift
//  PodShare
//
//  Created by Richard on 8/15/18.
//  Copyright © 2018 wongRichardH. All rights reserved.
//

import UIKit

protocol AddFriendViewDelegate: class {
    func confirmFriendDidSelected(email: String)
}

class AddFriendView: UIView {

    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!

    weak var delegate: AddFriendViewDelegate?

    override func awakeFromNib() {
        self.layer.cornerRadius = 4.0
        self.backgroundColor = UIColor(displayP3Red: 0.973701, green: 0.925641, blue: 0.908454, alpha: 0.99)

        self.dismissButton.addTarget(self, action: #selector(dismissButtonPressed), for: .touchUpInside)
        self.confirmButton.addTarget(self, action: #selector(confirmButtonPressed), for: .touchUpInside)
    }

    @objc func dismissButtonPressed() {
        self.isHidden = true
    }

    @objc func confirmButtonPressed() {
        let email = self.textField.text ?? ""
        self.delegate?.confirmFriendDidSelected(email: email)
    }

}
