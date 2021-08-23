//
//  DahuaQueryService.swift
//  CameraViewer
//
//  Created by mani on 2019-10-05.
//

import Foundation

class DahuaQueryService: NSObject {
    enum DahuaError: Error {
        case unauthorized
        case badRequest
    }
    typealias Host = String

    let name: Host
    let username: String
    let password: String
    private let dahuaAPI: DahuaAPI

    init(host: Host, username: String, password: String) {
        self.name = host
        self.username = username
        self.password = password
        self.dahuaAPI = DahuaAPI(host: name, username: username, password: password)

        super.init()
    }
}

extension DahuaQueryService {
    func getType(completion: @escaping (String?, Error?) -> Void) {
        dahuaAPI.getDeviceType { (content, response, error) in
            var deviceType: String?
            var theError = error
            defer { completion(deviceType, theError) }
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 400:
                    theError = DahuaError.badRequest
                case 401:
                    theError = DahuaError.unauthorized
                default:
                    guard let content = content else { return }
                    deviceType = self.getDeviceType(from: content)
                }
            }
        }
    }

    func getSerialNumber(completion: @escaping (String?, Error?) -> Void) {
        dahuaAPI.getSerialNumber { (content, response, error) in
            var serialNumber: String?
            var theError = error
            defer { completion(serialNumber, theError) }
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 400:
                    theError = DahuaError.badRequest
                case 401:
                    theError = DahuaError.unauthorized
                default:
                    guard let content = content else { return }
                    serialNumber = self.getDeviceSerialNumber(from: content)
                }
            }
        }
    }

    func getChannel(completion: @escaping ([Channel]?, Error?) -> Void) {
        dahuaAPI.getChannelTitle { (content, response, error) in
            var channelTitles: [Channel]?
            var theError = error
            defer { completion(channelTitles, theError) }
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 400:
                    theError = DahuaError.badRequest
                case 401:
                    theError = DahuaError.unauthorized
                default:
                    guard let content = content else { return }
                    channelTitles = self.getDeviceChannel(from: content)
                }
            }
        }
    }

    func getClass(completion: @escaping (String?, Error?) -> Void) {
        dahuaAPI.getDeviceClass { (content, response, error) in
            var deviceClass: String?
            var theError = error
            defer { completion(deviceClass, theError) }
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 400:
                    theError = DahuaError.badRequest
                case 401:
                    theError = DahuaError.unauthorized
                default:
                    guard let content = content else { return }
                    deviceClass = self.getDeviceClass(from: content)
                }
            }
        }
    }

    func getAutoFocusStatus(for channel: String, completion: @escaping (String?, Error?) -> Void) {
        dahuaAPI.getAutoFocusStatus(channel: channel) { (content, response, error) in
            var autoFocusStatus: String?
            var theError = error
            defer { completion(autoFocusStatus, theError) }
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 400:
                    theError = DahuaError.badRequest
                case 401:
                    theError = DahuaError.unauthorized
                default:
                    guard let content = content else { return }
                    autoFocusStatus = self.getAutoFocusStatus(from: content)
                }
            }
        }
    }

    func getEvents(channel: String, startTime: String, endTime: String,
                   directory: String?, fileTypes: [String]?, events: [String]?,
                   flags: [String]?, streams: [String]?, completion: @escaping ([Event]?, Error?) -> Void) {
        dahuaAPI.findFiles(channel: channel, startTime: startTime, endTime: endTime,
                           directory: directory, fileTypes: fileTypes, events: events,
                           flags: flags, streams: streams) { (content, response, error) in
                            var events: [Event]?
                            var theError = error
                            defer { completion(events, theError) }
                            if let response = response as? HTTPURLResponse {
                                switch response.statusCode {
                                case 400:
                                    theError = DahuaError.badRequest
                                case 401:
                                    theError = DahuaError.unauthorized
                                default:
                                    guard let content = content else { return }
                                    events = self.getEvents(from: content, channel: channel)
                                }
                            }
        }
    }
}

extension DahuaQueryService {
    private func getDeviceType(from content: String) -> String? {
        let deviceData = parseDeviceInfomation(string: content)
        return deviceData["type"]
    }

    private func getDeviceSerialNumber(from content: String) -> String? {
        let deviceData = parseDeviceInfomation(string: content)
        return deviceData["sn"]
    }

    private func getDeviceChannel(from content: String) -> [Channel] {
        let channelData = parseChannelTitle(string: content)
        var channels = [Channel]()
        channelData.keys.forEach {
            if let name = channelData[$0]?["Name"] {
                if let channelNumber = Int($0.digits) {
                    let correctChannelNumber = String(channelNumber + 1)
                    let channel = Channel(name: name, number: correctChannelNumber)
                    channels.append(channel)
                }
            }
        }
        return channels.sorted { $0.number < $1.number }
    }

    private func getDeviceClass(from content: String) -> String? {
        let deviceData = parseDeviceInfomation(string: content)
        return deviceData["class"]
    }

    private func getAutoFocusStatus(from content: String) -> String? {
        let deviceData = parseAutoFocusInformation(string: content)
        return deviceData["Status"]
    }

    private func getEvents(from content: String, channel: String) -> [Event] {
        let eventData = parseEvents(string: content)
        var events = [Event]()

        eventData.keys.forEach {
            if let event = eventData[$0] {
                if let startTime = event["StartTime"], let endTime = event["EndTime"],
                    let type = event["Flags[0]"], let fileType = event["Type"],
                    let filePath = event["FilePath"], type.contains("Event") {
                    let formattedStartTime = startTime.replacingOccurrences(of: "[-:\\s]",
                                                                            with: "_",
                                                                            options: .regularExpression,
                                                                            range: nil)
                    let formattedEndTime = endTime.replacingOccurrences(of: "[-:\\s]",
                                                                        with: "_",
                                                                        options: .regularExpression,
                                                                        range: nil)
                    if let url = dahuaAPI.getPlaybackStreamURL(channel: channel,
                                                               startTime: formattedStartTime,
                                                               endTime: formattedEndTime) {
                        let event = Event(startTime: startTime, endTime: endTime,
                                          type: type, fileType: fileType, filePath: filePath,
                                          channel: channel, playbackURL: url)
                        events.append(event)
                    }
                }
            }
        }
        return events
    }
}

extension DahuaQueryService {
    private func parseChannelTitle(string: String) -> [String: [String: String]] {
        let content = string.components(separatedBy: .newlines).filter { !$0.isEmpty }
        var items = [String: [String: String]]()

        content.forEach { item in
            let itemAttributes = item.components(separatedBy: ".").filter { !$0.contains("table") }
            let itemsKey = itemAttributes[0]
            let subAttributes = itemAttributes[1].components(separatedBy: "=")
            var subItems = items[itemsKey, default: [:]]
            subItems[subAttributes[0]] = subAttributes[1]
            items[itemsKey] = subItems
        }

        return items
    }

    private func parseDeviceInfomation(string: String) -> [String: String] {
        let content = string.components(separatedBy: .newlines).filter { !$0.isEmpty }
        var items = [String: String]()

        content.forEach { item in
            let itemAttributes = item.components(separatedBy: "=")

            let itemKey = itemAttributes[0]
            let itemValue = itemAttributes[1]
            items[itemKey] = itemValue
        }

        return items
    }

    private func parseAutoFocusInformation(string: String) -> [String: String] {
        let content = string.components(separatedBy: .newlines).filter { !$0.isEmpty }
        var items = [String: String]()

        content.forEach { item in
            let itemAttributes = item.components(separatedBy: "status.").filter { !$0.isEmpty }
            let subAttributes = itemAttributes[0].components(separatedBy: "=")
            let itemsKey = subAttributes[0]
            items[itemsKey] = subAttributes[1]
        }

        return items
    }

    private func parseDeviceDiscovery(string: String) -> [String: [String: String]] {
        let content = string.components(separatedBy: .newlines).filter { !$0.isEmpty }
        var items = [String: [String: String]]()

        content.forEach { item in
            let itemAttributes = item.components(separatedBy: "=")
            let itemsKey = itemAttributes[0].components(separatedBy: ".")[0]
            let subAttributes = itemAttributes[0].components(separatedBy: ".").filter {
                !$0.contains("deviceInfo")
                }.joined(separator: ".")
            let item = itemAttributes[1]

            var subItems = items[itemsKey, default: [:]]
            subItems[subAttributes] = item
            items[itemsKey] = subItems
        }

        return items
    }

    private func parseEvents(string: String) -> [String: [String: String]] {
        let content = string.components(separatedBy: .newlines).filter { $0.contains("items") }
        var items = [String: [String: String]]()

        content.forEach { item in
            let itemAttributes = item.components(separatedBy: ".")
            let itemsKey = itemAttributes[0]
            let subAttributes = itemAttributes[1].components(separatedBy: "=")

            var subItems = items[itemsKey, default: [:]]
            subItems[subAttributes[0]] = subAttributes[1]
            items[itemsKey] = subItems
        }

        return items
    }
}
