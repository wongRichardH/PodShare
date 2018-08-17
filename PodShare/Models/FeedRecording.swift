//
//  FeedRecording.swift
//  PodShare
//
//  Created by Richard on 8/16/18.
//  Copyright © 2018 wongRichardH. All rights reserved.
//

import Foundation

class FeedRecording {

    var creatorName: String
    var recordName: String
    var timeCreated: String
    var fileURL: String

    init(creatorName: String, recordName: String, timeCreated: String, fileURL: String) {
        self.creatorName = creatorName
        self.recordName = recordName
        self.timeCreated = timeCreated
        self.fileURL = fileURL
    }
}
