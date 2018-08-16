//
//  UploadAudioView.swift
//  PodShare
//
//  Created by Richard on 8/15/18.
//  Copyright © 2018 wongRichardH. All rights reserved.
//

import UIKit

protocol UploadAudioViewDelegate: class {
    func uploadAudioDidSelected(cell: RecordCell)
}

class UploadAudioView: UIView {

    @IBOutlet weak var warningMessageLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!

    weak var delegate: UploadAudioViewDelegate?

    var cell: RecordCell?

    override func awakeFromNib() {
        self.setup()
    }

    func setup() {
        self.layer.cornerRadius = 4.0
        self.warningMessageLabel.numberOfLines = 0
        self.backgroundColor = UIColor(displayP3Red: 0.973701, green: 0.925641, blue: 0.908454, alpha: 0.99)
        self.dismissButton.addTarget(self, action: #selector(dismissViewButtonPressed), for: .touchUpInside)
        self.confirmButton.addTarget(self, action: #selector(confirmButtonPressed), for: .touchUpInside)
    }

    @objc func dismissViewButtonPressed() {
        self.isHidden = true
    }

    @objc func confirmButtonPressed() {
        if let cell = self.cell {
            self.cell = cell
            self.isHidden = true
            self.delegate?.uploadAudioDidSelected(cell: cell)
        }
    }

}
