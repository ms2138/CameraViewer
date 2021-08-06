//
//  Event.swift
//  CameraViewer
//
//  Created by mani on 2021-08-05.
//

import Foundation

struct Event: Comparable {
    var startTime: String
    var endTime: String
    var type: String
    var fileType: String
    var filePath: String
    var channel: String
    var playbackURL: URL

    static func < (lhs: Event, rhs: Event) -> Bool {
        return lhs.startTime < rhs.endTime
    }

    static func > (lhs: Event, rhs: Event) -> Bool {
        return lhs.startTime > rhs.endTime
    }

    static func <= (lhs: Event, rhs: Event) -> Bool {
        return lhs.startTime <= rhs.endTime
    }

    static func >= (lhs: Event, rhs: Event) -> Bool {
        return lhs.startTime >= rhs.endTime
    }
}
