//
//  DahuaAPI.swift
//  CameraViewer
//
//  Created by mani on 2019-09-02.
//

import Foundation

class DahuaAPI: NSObject {
    typealias Host = String

    private lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    let username: String
    let password: String
    let host: Host

    init(host: Host, username: String, password: String) {
        self.host = host
        self.username = username
        self.password = password

        super.init()
    }
}

extension DahuaAPI {
    func getChannelTitle(completion: @escaping (String?, URLResponse?, Error?) -> Void) {
        let actionQuery = URLQueryItem(name: "action", value: "getConfig")
        let channelTitleQuery = URLQueryItem(name: "name", value: "ChannelTitle")
        let channelTitleEndPoint = EndPoint(host: host,
                                            scheme: .http,
                                            path: .configManager,
                                            queryItems: [actionQuery, channelTitleQuery])
        performDataTask(for: channelTitleEndPoint.url, completion: completion)
    }

    func getNetworkConfig(completion: @escaping (String?, URLResponse?, Error?) -> Void) {
        let actionQuery = URLQueryItem(name: "action", value: "getConfig")
        let networkNameQuery = URLQueryItem(name: "name", value: "Network")
        let getNetworkConfigEndPoint = EndPoint(host: host,
                                                scheme: .http,
                                                path: .configManager,
                                                queryItems: [actionQuery, networkNameQuery])
        performDataTask(for: getNetworkConfigEndPoint.url, completion: completion)
    }

    func getDeviceType(completion: @escaping (String?, URLResponse?, Error?) -> Void) {
        let actionQuery = URLQueryItem(name: "action", value: "getDeviceType")
        let getDeviceTypeEndPoint = EndPoint(host: host,
                                             scheme: .http,
                                             path: .magicBox,
                                             queryItems: [actionQuery])
        performDataTask(for: getDeviceTypeEndPoint.url, completion: completion)
    }

    func getHardwareVersion(completion: @escaping (String?, URLResponse?, Error?) -> Void) {
        let actionQuery = URLQueryItem(name: "action", value: "getHardwareVersion")
        let getHardwareVersionEndPoint = EndPoint(host: host,
                                                  scheme: .http,
                                                  path: .magicBox,
                                                  queryItems: [actionQuery])
        performDataTask(for: getHardwareVersionEndPoint.url, completion: completion)
    }

    func getSerialNumber(completion: @escaping (String?, URLResponse?, Error?) -> Void) {
        let actionQuery = URLQueryItem(name: "action", value: "getSerialNo")
        let getSerialNumberEndPoint = EndPoint(host: host,
                                               scheme: .http,
                                               path: .magicBox,
                                               queryItems: [actionQuery])
        performDataTask(for: getSerialNumberEndPoint.url, completion: completion)
    }

    func getDeviceClass(completion: @escaping (String?, URLResponse?, Error?) -> Void) {
        let actionQuery = URLQueryItem(name: "action", value: "getDeviceClass")
        let getDeviceClassEndPoint = EndPoint(host: host,
                                              scheme: .http,
                                              path: .magicBox,
                                              queryItems: [actionQuery])
        performDataTask(for: getDeviceClassEndPoint.url, completion: completion)
    }

    func getSystemInformation(completion: @escaping (String?, URLResponse?, Error?) -> Void) {
        let actionQuery = URLQueryItem(name: "action", value: "getSystemInfo")
        let getSystemInformationEndPoint = EndPoint(host: host,
                                                    scheme: .http,
                                                    path: .magicBox,
                                                    queryItems: [actionQuery])
        performDataTask(for: getSystemInformationEndPoint.url, completion: completion)
    }

    func getVendorInformation(completion: @escaping (String?, URLResponse?, Error?) -> Void) {
        let actionQuery = URLQueryItem(name: "action", value: "getVendor")
        let getVendorInformationEndPoint = EndPoint(host: host,
                                                    scheme: .http,
                                                    path: .magicBox,
                                                    queryItems: [actionQuery])
        performDataTask(for: getVendorInformationEndPoint.url, completion: completion)
    }

    func getCurrentTime(completion: @escaping (String?, URLResponse?, Error?) -> Void) {
        let actionQuery = URLQueryItem(name: "action", value: "getCurrentTime")
        let getCurrentTimeEndPoint = EndPoint(host: host,
                                              scheme: .http,
                                              path: .global,
                                              queryItems: [actionQuery])
        performDataTask(for: getCurrentTimeEndPoint.url, completion: completion)
    }

    func getAutoFocusStatus(channel: String, completion: @escaping (String?, URLResponse?, Error?) -> Void) {
        let actionQuery = URLQueryItem(name: "action", value: "getFocusStatus")
        let channelNumberQuery = URLQueryItem(name: "channel", value: channel)
        let getVideoConfigEndPoint = EndPoint(host: host,
                                              scheme: .http,
                                              path: .videoInput,
                                              queryItems: [actionQuery, channelNumberQuery])
        performDataTask(for: getVideoConfigEndPoint.url, completion: completion)
    }

    func performAutoFocus(channel: String, completion: @escaping (String?, URLResponse?, Error?) -> Void) {
        let actionQuery = URLQueryItem(name: "action", value: "autoFocus")
        let channelNumberQuery = URLQueryItem(name: "channel", value: channel)
        let getVideoConfigEndPoint = EndPoint(host: host,
                                              scheme: .http,
                                              path: .videoInput,
                                              queryItems: [actionQuery, channelNumberQuery])
        performDataTask(for: getVideoConfigEndPoint.url, completion: completion)
    }
}

extension DahuaAPI {
    // Call getDeviceClass method first if class in unknown
    // DeviceClass: IPC, NVR, etc....
    func performDeviceDiscovery(deviceClass: String, completion: @escaping (String?, URLResponse?, Error?) -> Void) {
        let actionQuery = URLQueryItem(name: "action", value: "attach")
        let deviceClassQuery = URLQueryItem(name: "DeviceClass", value: deviceClass)
        let deviceDiscoveryEndPoint = EndPoint(host: host,
                                               scheme: .http,
                                               path: .discovery,
                                               queryItems: [actionQuery, deviceClassQuery])
        performDataTask(for: deviceDiscoveryEndPoint.url, completion: completion)
    }
}

extension DahuaAPI {
    // Channel:  Video channel index.  Starts at 1
    // StreamType: Main stream is 0, extra stream 1 is 1, extra stream 2 is 2
    func getRTSPStreamURL(channel: String, streamType: String) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "rtsp"
        urlComponents.host = host
        urlComponents.user = username
        urlComponents.password = password
        urlComponents.port = 554
        urlComponents.path = "/cam/realmonitor"

        let queryItems = [
            URLQueryItem(name: "channel", value: channel),
            URLQueryItem(name: "subtype", value: streamType)
        ]

        urlComponents.queryItems = queryItems

        return urlComponents.url
    }

    // Channel:  Video channel index.  Starts at 1
    func getPlaybackStreamURL(channel: String, startTime: String, endTime: String) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "rtsp"
        urlComponents.host = host
        urlComponents.user = username
        urlComponents.password = password
        urlComponents.port = 554
        urlComponents.path = "/cam/playback"

        let queryItems = [
            URLQueryItem(name: "channel", value: channel),
            URLQueryItem(name: "starttime", value: startTime),
            URLQueryItem(name: "endtime", value: endTime)
        ]

        urlComponents.queryItems = queryItems

        return urlComponents.url
    }
}

extension DahuaAPI {
    // Call this method to start the find files process
    // ObjectId returned.  Will be needed to call findFiles, findNextFile, closeFileFinder, and destroyFileFinder
    func createFileFinder(completion: @escaping (String?, URLResponse?, Error?) -> Void) {
        let actionQuery = URLQueryItem(name: "action", value: "factory.create")
        let createFileFinderEndPoint = EndPoint(host: host,
                                                scheme: .http,
                                                path: .mediaFileFind,
                                                queryItems: [actionQuery])
        performDataTask(for: createFileFinderEndPoint.url, completion: completion)
    }

    func closeFileFinder(objectId: String, completion: @escaping (String?, URLResponse?, Error?) -> Void) {
        let actionQuery = URLQueryItem(name: "action", value: "close")
        let objectIdQuery = URLQueryItem(name: "object", value: objectId)
        let closeFileFinderEndPoint = EndPoint(host: host,
                                               scheme: .http,
                                               path: .mediaFileFind,
                                               queryItems: [actionQuery, objectIdQuery])
        performDataTask(for: closeFileFinderEndPoint.url, completion: completion)
    }

    func destroyFileFinder(objectId: String, completion: @escaping (String?, URLResponse?, Error?) -> Void) {
        let actionQuery = URLQueryItem(name: "action", value: "destroy")
        let objectIdQuery = URLQueryItem(name: "object", value: objectId)
        let destroyFileFinderEndPoint = EndPoint(host: host,
                                                 scheme: .http,
                                                 path: .mediaFileFind,
                                                 queryItems: [actionQuery, objectIdQuery])
        performDataTask(for: destroyFileFinderEndPoint.url, completion: completion)
    }

    // Perform a file find using the passed in parameters.  Returns OK if files are found.  Error if not results
    // To get the list of files found, call findNextFile method
    //
    // Find files parameters
    //
    // ObjectId: id comes from calling createFileFinder method
    // StartTime: format - 2019-1-10 12:00:00
    // EndTime: format - 2019-1-11 12:00:00
    // Directory: /mnt/dvr/sda1
    // FileType: dav, jpg, mp4
    // Event: AlarmLocal, VideoMotion, VideoLoss, VideoBlind, Traffic
    // Flag: Timing, Manual, Marker, Event, Mosaic, Cutout
    // Stream: Main, Extra1, Extra2, Extra3
    // Returns OK, if the query matches any media files
    func performFileFind(objectId: String, channel: String, startTime: String, endTime: String,
                         directory: String?, fileTypes: [String]?, events: [String]?, flags: [String]?,
                         streams: [String]?, completion: @escaping (String?, URLResponse?, Error?) -> Void) {
        var queryItems: [URLQueryItem]

        let actionQuery = URLQueryItem(name: "action", value: "findFile")
        let objectIdQuery = URLQueryItem(name: "object", value: objectId)
        let channelQuery = URLQueryItem(name: "condition.Channel", value: channel)
        let directoryQuery = URLQueryItem(name: "condition.Dirs[0]", value: directory)
        let startTimeQuery = URLQueryItem(name: "condition.StartTime", value: startTime)
        let endTimeQuery = URLQueryItem(name: "condition.EndTime", value: endTime)

        queryItems = [actionQuery, objectIdQuery, channelQuery,
                      directoryQuery, startTimeQuery, endTimeQuery]

        let fileTypeQueries = createQueryItems(from: fileTypes, key: "Types")
        queryItems.append(contentsOf: fileTypeQueries)

        let eventsQueries = createQueryItems(from: events, key: "Events")
        queryItems.append(contentsOf: eventsQueries)

        let flagQueries = createQueryItems(from: flags, key: "Flag")
        queryItems.append(contentsOf: flagQueries)

        let findFilesEndPoint = EndPoint(host: host,
                                         scheme: .http,
                                         path: .mediaFileFind,
                                         queryItems: queryItems)
        performDataTask(for: findFilesEndPoint.url, completion: completion)
    }

    // Find files parameters
    //
    // StartTime: format - 2019-1-10 12:00:00
    // EndTime: format - 2019-1-11 12:00:00
    // Directory: /mnt/dvr/sda1
    // FileType: dav, jpg, mp4
    // Event: AlarmLocal, VideoMotion, VideoLoss, VideoBlind, Traffic
    // Flag: Timing, Manual, Marker, Event, Mosaic, Cutout
    // Stream: Main, Extra1, Extra2, Extra3
    // FileCount: Number of results returned.  Max is 100
    //
    // Returns OK, if the query matches any media files
    func findFiles(channel: String, startTime: String, endTime: String, directory: String?,
                   fileTypes: [String]?, events: [String]?, flags: [String]?, streams: [String]?,
                   fileCount: String = "100", completion: @escaping (String?, URLResponse?, Error?) -> Void) {
        createFileFinder { [weak self] (data, response, error) in
            guard let weakSelf = self else { return }
            guard let data = data else {
                completion(nil, nil, nil)
                return
            }

            if var objectId = data.components(separatedBy: "=").last {
                objectId.removeAllWhitespacesAndNewlines()

                weakSelf.performFileFind(objectId: objectId, channel: channel, startTime: startTime, endTime: endTime,
                                         directory: directory, fileTypes: fileTypes, events: events,
                                         flags: flags, streams: streams, completion: { (_, response, error) in

                                            weakSelf.findNextFile(objectId: objectId,
                                                                  fileCount: fileCount,
                                                                  completion: { (data, response, error) in
                                                weakSelf.closeFileFinder(objectId: objectId, completion: { _, _, _  in
                                                    weakSelf.destroyFileFinder(objectId: objectId) { _, _, _ in
                                                    }
                                                })
                                                completion(data, response, error)
                                            })
                })

            }
        }
    }

    // This method will return a list of found media files
    // Call this method after findFiles returns OK
    func findNextFile(objectId: String, fileCount: String = "100",
                      completion: @escaping (String?, URLResponse?, Error?) -> Void) {
        let actionQuery = URLQueryItem(name: "action", value: "findNextFile")
        let objectIdQuery = URLQueryItem(name: "object", value: objectId)
        let countQuery = URLQueryItem(name: "count", value: fileCount)
        let findNextFileEndPoint = EndPoint(host: host,
                                            scheme: .http,
                                            path: .mediaFileFind,
                                            queryItems: [actionQuery, objectIdQuery, countQuery])
        performDataTask(for: findNextFileEndPoint.url, completion: completion)
    }
}

extension DahuaAPI {
    private func createQueryItems(from items: [String]?, key: String) -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        if let items = items {
            for (index, value) in items.enumerated() {
                let query = "condition.\(key)[\(index)]"
                let queryItem = URLQueryItem(name: query, value: value)
                queryItems.append(queryItem)
            }
        }
        return queryItems
    }

    private func performDataTask(for url: URL, completion: @escaping (String?, URLResponse?, Error?) -> Void) {
        let task = session.dataTask(with: url) { (data, response, error) in
            var dataString: String?

            defer { completion(dataString, response, error) }

            guard let data = data else {
                return
            }

            dataString = String(data: data, encoding: .utf8)
        }
        task.resume()
    }
}

extension DahuaAPI: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard let response = response as? HTTPURLResponse,
            (200...299).contains(response.statusCode) else {
                completionHandler(.cancel)
                return
        }
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPDigest {
            let credential = URLCredential(user: username,
                                           password: password,
                                           persistence: .forSession)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

struct EndPoint {
    enum Path: String {
        case configManager = "/cgi-bin/configManager.cgi"
        case magicBox = "/cgi-bin/magicBox.cgi"
        case mediaFileFind = "/cgi-bin/mediaFileFind.cgi"
        case global = "/cgi-bin/global.cgi"
        case discovery = "/cgi-bin/deviceDiscovery.cgi"
        case videoInput = "/cgi-bin/devVideoInput.cgi"
    }

    enum Scheme: String {
        case http
        case https
    }

    enum Action: String {
        case getConfig = "getConfig"
        case getDeviceType = "getDeviceType"
        case getHardwareVersion = "getHardwareVersion"
        case getSerialNo = "getSerialNo"
        case getSystemInfo = "getSystemInfo"
        case getVendor = "getVendor"
        case getCurrentTime = "getCurrentTime"
        case factoryCreate = "factory.create"
        case findFile = "findFile"
        case findNextFile = "findNextFile"
        case close = "close"
        case destroy = "destroy"
    }

    var host: String
    var scheme: Scheme
    var path: Path
    var queryItems: [URLQueryItem]

    var url: URL {
        var components = URLComponents()
        components.scheme = scheme.rawValue
        components.host = host
        components.path = path.rawValue
        components.queryItems = queryItems
        return components.url!
    }
}
