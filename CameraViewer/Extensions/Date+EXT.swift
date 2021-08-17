//
//  Date+EXT.swift
//  CameraViewer
//
//  Created by mani on 2021-08-16.
//

import Foundation

extension Date {
    func dateString(dateStyle: DateFormatter.Style = .medium,
                    timeStyle: DateFormatter.Style = .medium,
                    format: String = "yyyy-M-d hh:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
