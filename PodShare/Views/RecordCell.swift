//
//  RecordCell.swift
//  PodShare
//
//  Created by Richard on 8/8/18.
//  Copyright © 2018 wongRichardH. All rights reserved.
//

import UIKit

protocol RecordCellDelegate: class {
    func editButtonDidSelect(cell: RecordCell)
    func deleteButtonDidSelect(cell: RecordCell)
}

class RecordCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateRecordLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!

    weak var delegate: RecordCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.editButton.addTarget(self, action: #selector(editButtonPressed), for: .touchUpInside)
        self.trashButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(record: Record) {
        self.titleLabel.text = record.name
        self.dateRecordLabel.text = record.timestamp
    }

    @objc func editButtonPressed() {
        self.delegate?.editButtonDidSelect(cell: self)
    }

    @objc func deleteButtonPressed() {
        self.delegate?.deleteButtonDidSelect(cell: self)
    }
    
}
