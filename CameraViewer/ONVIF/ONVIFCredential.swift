//
//  ONVIFCredential.swift
//  CameraViewer
//
//  Created by mani on 2019-09-15.
//

import Foundation

struct ONVIFCredential {
    let username: String
    let password: String
    let date: Date
    let dateFormatter: DateFormatter
    let nonce: UInt
    var nonceBinaryData: Data {
        var randomNonce = nonce
        return Data(bytes: &randomNonce, count: MemoryLayout.size(ofValue: randomNonce))
    }
    var nonceBase64: String {
        return nonceBinaryData.base64EncodedString(options: [])
    }
    var dateString: String {
        return dateFormatter.string(from: date)
    }
    var dateBinaryData: Data {
        return dateString.data(using: .utf8)!
    }
    var passwordBinaryData: Data {
        return password.data(using: .utf8)!
    }
    var passwordDigest: Data {
        return sha1(nonceBinaryData + dateBinaryData + passwordBinaryData)
    }

    var passwordDigestBase64: String {
        return passwordDigest.base64EncodedString(options: [])
    }

    init(username: String, password: String) {
        self.username = username
        self.password = password
        self.date = Date()
        self.nonce = UInt.random(in: 0..<1000)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        self.dateFormatter = dateFormatter
    }

    func sha1(_ data: Data) -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }
}
