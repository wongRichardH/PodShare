//
//  Date+PodShare.swift
//  PodShare
//
//  Created by Richard on 8/8/18.
//  Copyright © 2018 wongRichardH. All rights reserved.
//

import Foundation

extension Date {

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
        let hour = String(dateTimeComponents.hour! % 12)
        let minute = String(dateTimeComponents.minute!)
        let second = String(dateTimeComponents.second!)

        let dateString = year + "-" + month + "-" + day + " " + hour + ":" + minute + ":" + second

        return dateString
    }
}
