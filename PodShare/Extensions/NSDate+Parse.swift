//
//  NSDate+Parse.swift
//  PodShare
//
//  Created by Richard on 8/8/18.
//  Copyright © 2018 wongRichardH. All rights reserved.
//

import Foundation

extension NSDate {

    func getTimestamp() -> String {

        let currentDateTime = Date()
        let userCalendar = Calendar.current

        let requestedComponents: Set<Calendar.Component> = [
            .year,
            .month,
            .day,
            .hour,
            .minute,
            .second
        ]

        let dateTimeComponents = userCalendar.dateComponents(requestedComponents, from: currentDateTime)

        let year = String(dateTimeComponents.year!)
        let month = String(dateTimeComponents.month!)
        let day = String(dateTimeComponents.day!)

        let dateString = year + "-" + month + "-" + day

        return dateString
    }
}
