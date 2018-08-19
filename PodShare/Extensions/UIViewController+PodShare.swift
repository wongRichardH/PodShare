//
//  UIViewController+PodShare.swift
//  PodShare
//
//  Created by Richard on 8/15/18.
//  Copyright © 2018 wongRichardH. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func encode(email: String) -> String{
        return email.components(separatedBy: ".").joined(separator: "•")
    }

    func decode(email: String) -> String{
        return email.components(separatedBy: "•").joined(separator: ".")
    }

    func sortByDate(records: [Record]) -> [Record] {
        if records.count != 0 {
            let sorted = records.sorted(by: { $0.nsTimeStamp > $1.nsTimeStamp})
            return sorted
        } else {
            return []
        }
    }

    func sortByDate(feedRecords: [FeedRecording]) -> [FeedRecording] {

        if feedRecords.count != 0 {
            let sorted = feedRecords.sorted(by: { self.convertServerTimeStampToDate(dateString: $0.timeCreated)! > self.convertServerTimeStampToDate(dateString: $1.timeCreated)!})
            return sorted
        } else {
            return []
        }
    }

    func convertServerTimeStampToDate( dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let date = dateFormatter.date(from: dateString)
        return date
    }

    func convertDate(date: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss Z"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd h:mm:ss"

        if let date = dateFormatterGet.date(from: date){
            return (dateFormatterPrint.string(from: date))
        }
        else {
            return ""
        }
    }

    func showAlert(alertTitle: String, alertMessage: String) {
        let alert = AlertPresenter(baseVC: self)
        alert.showAlert(alertTitle: alertTitle, alertMessage: alertMessage)
    }
    
}
