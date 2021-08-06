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
