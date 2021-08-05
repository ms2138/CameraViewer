//
//  ONVIFQueryService.swift
//  CameraViewer
//
//  Created by mani on 2019-09-15.
//

import Foundation
import SwiftyXMLParser

class ONVIFQueryService {
    enum QueryError {
        case parsingFailed
        case authenticationFailed
        case dataUnavailable
        case deviceNotFound
    }

    var credential: ONVIFCredential
    let session: URLSession
    private var broadcastConnection: UDPBroadcastConnection!

    init(credential: ONVIFCredential) {
        self.credential = credential
        self.session = URLSession(configuration: URLSessionConfiguration.ephemeral)
    }

    func performDataTask(for request: ONVIFRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var urlRequest = URLRequest.init(url: request.url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = request.body

        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            completion(data, response, error)
        }
        task.resume()
    }
}

extension ONVIFQueryService.QueryError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .parsingFailed:
            return "Parsing failed"
        case .authenticationFailed:
            return "Authentication failed"
        case .dataUnavailable:
            return "Data unavailable"
        case .deviceNotFound:
            return "Device not found"
        }
    }
}

extension ONVIFQueryService {
    func performONVIFDiscovery(completion: @escaping (ONVIFDiscovery?, Error?) -> Void) throws {
        broadcastConnection = try UDPBroadcastConnection(
            port: 3702,
            handler: { (ipAddress, _, data) -> Void in
                var discoveredDevice: ONVIFDiscovery?
                let xml = XML.parse(data)
                let accessor = xml["s:Envelope", "s:Body", "d:ProbeMatches", "d:ProbeMatch"]
                // Get the url for the devices ONVIF service
                if let serviceURL = accessor["d:XAddrs"].url {
                    // Get the first scope where the ONVIF link contains hardware and then
                    // get the last path component that contains the devices model
                    if let hardwareScope = accessor["d:Scopes"].text?.split(separator: " ")
                        .first(where: { $0.contains("hardware") }),
                        let model = URL(string: String(hardwareScope))?.lastPathComponent {
                        discoveredDevice = ONVIFDiscovery(model: model,
                                                          ipAddress: ipAddress,
                                                          deviceService: serviceURL)
                    }
                }
                completion(discoveredDevice, nil)
        },
            errorHandler: { (error) in
                completion(nil, error)
        }
        )
        try broadcastConnection.sendBroadcast(generateBroadcastMessageTemplate())
    }
}

extension ONVIFQueryService {
    func getDeviceInformation(from url: URL, completion: @escaping (ONVIFDevice?, QueryError?) -> Void) {
        let bodyData = generateGetDeviceInformationTemplate().data(using: .utf8)!
        let request = ONVIFRequest(url: url, body: bodyData)
        performDataTask(for: request) { [weak self] (data, _, error) in
            guard let weakSelf = self else { return }

            var camera: ONVIFDevice?
            var queryError: QueryError?

            defer { completion(camera, queryError) }

            guard let data = data else {
                queryError = ONVIFQueryService.QueryError.dataUnavailable
                return
            }

            let xml = XML.parse(data)

            if let error = weakSelf.checkForAuthorizationError(from: xml) {
                queryError = error
                return
            }

            let deviceInfo = xml["s:Envelope", "s:Body", "tds:GetDeviceInformationResponse"]

            if let manufacturer = deviceInfo["tds:Manufacturer"].text,
                let model = deviceInfo["tds:Model"].text,
                let firmware = deviceInfo["tds:FirmwareVersion"].text,
                let serialNumber = deviceInfo["tds:SerialNumber"].text,
                let hardwareID = deviceInfo["tds:HardwareId"].text {
                camera = ONVIFDevice(manufacturer: manufacturer,
                                     model: model,
                                     firmwareVersion: firmware,
                                     serialNumber: serialNumber,
                                     hardwareID: hardwareID)
            } else {
                queryError = ONVIFQueryService.QueryError.parsingFailed
            }
        }
    }

    func getDeviceProfiles(from url: URL, completion: @escaping ([ONVIFProfile], QueryError?) -> Void) {
        let bodyData = generateGetMediaProfileTemplate().data(using: .utf8)!
        let request = ONVIFRequest(url: url, body: bodyData)
        performDataTask(for: request) { [weak self] (data, _, error) in
            guard let weakSelf = self else { return }
            var profileNames = [ONVIFProfile]()
            var queryError: QueryError?

            defer { completion(profileNames, queryError) }

            guard let data = data else {
                queryError = ONVIFQueryService.QueryError.dataUnavailable
                return
            }

            let xml = XML.parse(data)

            if let error = weakSelf.checkForAuthorizationError(from: xml) {
                queryError = error
                return
            }

            let profiles = xml["s:Envelope", "s:Body", "trt:GetProfilesResponse", "trt:Profiles"]

            for profile in profiles {
                let videoEncoder = profile["tt:VideoEncoderConfiguration"]
                let resolution = videoEncoder["tt:Resolution"]
                if let name = profile["tt:Name"].text, let token = profile.attributes["token"],
                    let encoding = videoEncoder["tt:Encoding"].text, let width = resolution["tt:Width"].int,
                    let height = resolution["tt:Height"].int {

                    let resolution = Resolution(width: width, height: height)
                    let deviceProfile = ONVIFProfile(name: name,
                                                     token: token,
                                                     encoding: encoding,
                                                     resolution: resolution)
                    profileNames.append(deviceProfile)
                } else {
                    queryError = ONVIFQueryService.QueryError.parsingFailed
                }
            }
        }
    }

    func getRTSPStreamURI(from url: URL, token: String, completion: @escaping (URL?, QueryError?) -> Void) {
        let bodyData = generateGetRTSPStreamURITemplate(forProfile: token).data(using: .utf8)!
        let request = ONVIFRequest(url: url, body: bodyData)
        performDataTask(for: request) { [weak self] (data, _, error) in
            guard let weakSelf = self else { return }
            var streamURI: URL?
            var queryError: QueryError?

            defer { completion(streamURI, queryError) }

            guard let data = data else {
                queryError = ONVIFQueryService.QueryError.dataUnavailable
                return
            }

            let xml = XML.parse(data)

            if let error = weakSelf.checkForAuthorizationError(from: xml) {
                queryError = error
                return
            }

            let accessor = xml["s:Envelope", "s:Body", "trt:GetStreamUriResponse", "trt:MediaUri"]
            streamURI = accessor["tt:Uri"].url
        }
    }

    func getAllDeviceInformation(from url: URL, completion: @escaping (ONVIFDevice?, QueryError?) -> Void) {
        getDeviceInformation(from: url) { [weak self] (device, error) in
            guard let weakSelf = self else { return }
            var device = device
            var queryError = error

            weakSelf.getDeviceProfiles(from: url, completion: { (profiles, error) in
                let dispatchGroup = DispatchGroup()
                queryError = error

                for var profile in profiles {
                    dispatchGroup.enter()

                    weakSelf.getRTSPStreamURI(from: url, token: profile.token, completion: { (url, error) in
                        queryError = error

                        if let url = url {
                            profile.add(stream: url)
                            device?.add(profile: profile)
                        }
                        dispatchGroup.leave()
                    })

                }
                dispatchGroup.notify(queue: DispatchQueue.global(qos: .background), execute: {
                    completion(device, queryError)
                })
            })
        }
    }
}

extension ONVIFQueryService {
    private func checkForAuthorizationError(from xml: XML.Accessor) -> QueryError? {
        if let failedAuthorization = xml["s:Envelope", "s:Body", "s:Fault", "s:Code", "s:Subcode", "s:Value"].text {
            if failedAuthorization.contains("NotAuthorized") {
                return ONVIFQueryService.QueryError.authenticationFailed
            }
        }
        return nil
    }
}

extension ONVIFQueryService {
    private func generateBroadcastMessageTemplate() -> String {
        return """
            <e:Envelope xmlns:e="http://www.w3.org/2003/05/soap-envelope"
                        xmlns:w="http://schemas.xmlsoap.org/ws/2004/08/addressing"
                        xmlns:d="http://schemas.xmlsoap.org/ws/2005/04/discovery"
                        xmlns:dn="http://www.onvif.org/ver10/network/wsdl">
                <e:Header>
                    <w:MessageID>uuid:84ede3de-7dec-11d0-c360-f01234567890</w:MessageID>
                    <w:To e:mustUnderstand="true">urn:schemas-xmlsoap-org:ws:2005:04:discovery</w:To>
                    <w:Action a:mustUnderstand="true">http://schemas.xmlsoap.org/ws/2005/04/discovery/Probe</w:Action>
                </e:Header>
                <e:Body>
                    <d:Probe>
                        <d:Types>dn:NetworkVideoTransmitter</d:Types>
                    </d:Probe>
                </e:Body>
            </e:Envelope>
        """
    }

    private func generateAuthenicationTemplate() -> String {
        // swiftlint:disable line_length
        return """
            <Security s:mustUnderstand="1" xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">
                <UsernameToken>
                    <Username>\(credential.username)</Username>
                    <Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordDigest">\(credential.passwordDigestBase64)</Password>
                    <Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">\(credential.nonceBase64)</Nonce>
                    <Created xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">\(credential.dateString)</Created>
                </UsernameToken>
            </Security>
        """
        // swiftlint:enable line_length
    }

    private func generateONVIFTemplate(headerContent: String, bodyContent: String) -> String {
        return """
            <s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope"
                        xmlns:media="http://www.onvif.org/ver10/media/wsdl"
                        xmlns:tds="http://www.onvif.org/ver10/device/wsdl"
                        xmlns:tt="http://www.onvif.org/ver10/schema"
                        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                        xmlns:xsd="http://www.w3.org/2001/XMLSchema">
                <s:Header>
                    \(headerContent)
                </s:Header>
                <s:Body>
                    \(bodyContent)
                </s:Body>
            </s:Envelope>
        """
    }

    private func generateGetRTSPStreamURITemplate(forProfile token: String) -> String {
        let headerContent = generateAuthenicationTemplate()
        let bodyContent = """
            <media:GetStreamUri>
                <media:StreamSetup>
                    <tt:Stream>RTP-Unicast</tt:Stream>
                    <tt:Transport>
                        <tt:Protocol>RTSP</tt:Protocol>
                    </tt:Transport>
                </media:StreamSetup>
                <media:ProfileToken>\(token)</media:ProfileToken>
            </media:GetStreamUri>
        """
        return generateONVIFTemplate(headerContent: headerContent, bodyContent: bodyContent)
    }

    private func generateGetDeviceInformationTemplate() -> String {
        let headerContent = generateAuthenicationTemplate()
        let bodyContent = "<tds:GetDeviceInformation/>"
        return generateONVIFTemplate(headerContent: headerContent, bodyContent: bodyContent)
    }

    private func generateGetMediaProfileTemplate() -> String {
        let headerContent = generateAuthenicationTemplate()
        let bodyContent = "<media:GetProfiles/>"
        return generateONVIFTemplate(headerContent: headerContent, bodyContent: bodyContent)
    }
}
