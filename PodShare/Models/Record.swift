//
//  Record.swift
//  PodShare
//
//  Created by Richard on 8/8/18.
//  Copyright © 2018 wongRichardH. All rights reserved.
//

import Foundation

class Record {

    var file: NSURL
    var timestamp: String

    init(file: NSURL, timestamp: String) {
        self.file = file
        self.timestamp = timestamp
    }
}
