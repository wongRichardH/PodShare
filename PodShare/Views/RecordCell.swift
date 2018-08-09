//
//  RecordCell.swift
//  PodShare
//
//  Created by Richard on 8/8/18.
//  Copyright © 2018 wongRichardH. All rights reserved.
//

import UIKit

class RecordCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateRecordLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func configure(record: Record) {
        self.dateRecordLabel.text = record.timestamp
    }
    
}
