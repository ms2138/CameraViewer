//
//  DateTime.swift
//  CameraViewer
//
//  Created by mani on 2021-08-18.
//

import Foundation

func timeDifference(first: Date, second: Date) -> TimeInterval {
    return second.timeIntervalSince(first)
}

func doesEventTimeExist(start: String, end: String) -> Bool? {
    let startDate = formatDate(date: start, format: "yyyy-MM-dd HH:mm:ss")
    let endDate = formatDate(date: end, format: "yyyy-MM-dd HH:mm:ss")

    if let startDate = startDate, let endDate = endDate {
        return timeDifference(first: startDate, second: endDate) > 2.0
    }
    return nil
}

func formatDate(date: String, format: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format

    return dateFormatter.date(from: date)
}

func getFormattedDate(from string: String) -> String? {
    let date = formatDate(date: string, format: "yyyy-MM-dd HH:mm:ss")
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM d, h:mm:ss a"

    guard let theDate = date else { return nil }

    return dateFormatter.string(from: theDate)
}
