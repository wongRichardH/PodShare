//
//  DeleteCellView.swift
//  PodShare
//
//  Created by Richard on 8/10/18.
//  Copyright © 2018 wongRichardH. All rights reserved.
//

import UIKit

protocol DeleteCellViewDelegate: class {
    func deleteAudioDidSelected(cell: DeleteCellView, cellName: String)
}

class DeleteCellView: UIView {

    @IBOutlet weak var dismissViewButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var warningLabel: UILabel!

    weak var delegate: DeleteCellViewDelegate?
    var cellName: String?

    override func awakeFromNib() {
        self.setup()
    }

    func setup() {
        self.backgroundColor = UIColor(displayP3Red: 0.973701, green: 0.925641, blue: 0.908454, alpha: 0.99)
        self.dismissViewButton.addTarget(self, action: #selector(dismissViewButtonPressed), for: .touchUpInside)
        self.deleteButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
    }

    @objc func dismissViewButtonPressed() {
        self.isHidden = true
    }

    @objc func deleteButtonPressed() {
        let cellName = self.cellName ?? ""
        self.isHidden = true
        self.delegate?.deleteAudioDidSelected(cell: self, cellName: cellName)

    }
}
