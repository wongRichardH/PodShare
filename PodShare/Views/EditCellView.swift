//
//  EditCellView.swift
//  PodShare
//
//  Created by Richard on 8/9/18.
//  Copyright © 2018 wongRichardH. All rights reserved.
//

import UIKit

protocol EditCellViewDelegate: class {
    func renameButtonDidSelect(text: String, indexPath: IndexPath)
}

class EditCellView: UIView {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var renameButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    weak var delegate: EditCellViewDelegate?

    var cellIndexPath: IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()

        self.renameButton.addTarget(self, action: #selector(renameButtonPressed), for: .touchUpInside)
        self.cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
    }

    func setup() {
        self.textField.textAlignment = .center
        self.textField.autocapitalizationType = .sentences
        self.textField.autocorrectionType = .default
        self.textField.spellCheckingType = .no

        self.layer.cornerRadius = 4.0

    }

    @objc func cancelButtonPressed() {
        self.isHidden = true
    }

    @objc func renameButtonPressed() {
        let textInField = self.textField.text ?? ""
        self.isHidden = true
        self.delegate?.renameButtonDidSelect(text: textInField, indexPath: self.cellIndexPath!)
    }
}
