//
//  LeftPostCell.swift
//  PodShare
//
//  Created by Richard on 8/14/18.
//  Copyright © 2018 wongRichardH. All rights reserved.
//

import UIKit

class LeftPostCell: UITableViewCell {

    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var recordingTitleLabel: UILabel!
    @IBOutlet weak var recordingDateLabel: UILabel!
    var fileURL: String?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = UIColor(red:0.88, green:0.88, blue:0.88, alpha:0.99)
    }

    func configure(with feed: FeedRecording) {
        self.creatorNameLabel.text = feed.creatorName
        self.recordingTitleLabel.text = feed.recordName
        self.recordingDateLabel.text = feed.timeCreated.description
        self.fileURL = feed.fileURL
    }

    
}
