//
//  Record.swift
//  PodShare
//
//  Created by Richard on 8/8/18.
//  Copyright © 2018 wongRichardH. All rights reserved.
//

import Foundation

class Record {

    var name: String
    var timestamp: String
    var fileURL: NSURL

    init(name: String, timestamp: String, fileURL: NSURL) {
        self.name = name
        self.timestamp = timestamp
        self.fileURL = fileURL
    }

    
}
