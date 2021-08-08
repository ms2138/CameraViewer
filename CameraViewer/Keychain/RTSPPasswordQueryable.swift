//
//  RTSPPasswordQueryable.swift
//  CameraViewer
//
//  Created by mani on 2019-09-29.
//

import Foundation

struct RTSPPasswordQueryable {
    let server: String
    let port: Int
    let path: String
}

extension RTSPPasswordQueryable: KeychainQueryable {
    var query: [String: Any] {
        var query: [String: Any] = [:]
        query[kSecClass as String] = kSecClassInternetPassword
        query[kSecAttrServer as String] = server
        query[kSecAttrPort as String] = port
        query[kSecAttrPath as String] = path
        query[kSecAttrProtocol as String] = kSecAttrProtocolRTSP
        query[kSecAttrAuthenticationType as String] = kSecAttrAuthenticationTypeDefault
        return query
    }
}
