//
//  EventsViewController.swift
//  CameraViewer
//
//  Created by mani on 2021-08-16.
//

import UIKit

class EventsViewController: UITableViewController {
    var events: [Event]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension EventsViewController {
    func loadEvents(for url: URL) {
        if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            if let host = urlComponents.host, let username = urlComponents.user,
               let password = urlComponents.password {
                if let queryItem = urlComponents.queryItems?.filter({ $0.name.contains("channel") }).first,
                   let channel = queryItem.value {
                    let dahuaQuery = DahuaQueryService(host: host,
                                                       username: username,
                                                       password: password)
                    let startOfDay = Date().startOfDay
                    let nextDay = startOfDay.nextDay

                    dahuaQuery.getEvents(channel: channel, startTime: startOfDay.dateString(),
                                         endTime: nextDay?.dateString() ?? startOfDay.dateString(),
                                         directory: "/mnt/dvr/sda0", fileTypes: ["dav", "mp4"],
                                         events: ["VideoMotion"], flags: ["Event", "Timing"],
                                         streams: ["Main"]) { [weak self] (events, _) in
                        guard let weakSelf = self else { return }
                        weakSelf.events = events
                    }
                }
            }
        }
    }
}
