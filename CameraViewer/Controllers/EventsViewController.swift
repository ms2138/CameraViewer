//
//  EventsViewController.swift
//  CameraViewer
//
//  Created by mani on 2021-08-16.
//

import UIKit

class EventsViewController: UITableViewController, NoContentBackgroundView {
    private let reuseIdentifier = "EventCell"
    
    private var events: [Event]?
    var handler: ((Event) -> Void)?
    let backgroundView = DTTableBackgroundView(frame: .zero)
    var textColor: UIColor = .white {
        willSet {
            backgroundView.messageLabel.textColor = newValue
        }
    }
    var separatorColor: UIColor = .white {
        willSet {
            tableView.separatorColor = newValue
        }
    }
    var backgroundColor: UIColor = .black {
        willSet {
            tableView.backgroundColor = newValue
        }
    }
    var selectedColor: UIColor = .gray

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 44.0

        setupBackgroundView()

        tableView.register(EventCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
}

private extension EventsViewController {
    func setupBackgroundView() {
        backgroundView.frame = view.frame
        tableView.backgroundView = backgroundView
        backgroundView.messageLabel.textColor = textColor
        backgroundView.messageLabel.text = "No Events Found"
        hideBackgroundView()
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
                        if let events = events {
                            weakSelf.events = events.filter({
                                doesEventTimeExist(start: $0.startTime, end: $0.endTime) ?? false
                            }).sorted { $0 < $1 }
                            DispatchQueue.main.async {
                                weakSelf.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
}

extension EventsViewController {
    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let events = events {
            let event = events[indexPath.row]
            handler?(event)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension EventsViewController {
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let eventCount = events?.count ?? 0

        if eventCount > 0 && tableView.backgroundView?.isHidden == false {
            hideBackgroundView()
        }
        if eventCount == 0 {
            showBackgroundView()
        }

        return eventCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,
                                                 for: indexPath) as! EventCell
        cell.timeLabel.textColor = textColor
        cell.backgroundColor = backgroundColor
        cell.selectedColor = selectedColor

        if let events = events {
            let event = events[indexPath.row]
            let startTime = event.startTime
            let endTime = event.endTime

            if let startTime = getFormattedDate(from: startTime),
               let endTime = getFormattedDate(from: endTime) {
                cell.timeLabel.text = "\(startTime) - \(endTime)"
            }
        }

        return cell
    }
}
