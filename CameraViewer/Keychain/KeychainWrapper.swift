//
//  KeychainWrapper.swift
//  CameraViewer
//
//  Created by mani on 2019-09-29.
//
// https://developer.apple.com/library/archive/samplecode/GenericKeychain/Listings/GenericKeychain_KeychainPasswordItem_swift.html

import Foundation

class KeychainWrapper {
    enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unexpectedItemData
        case unhandledError(status: OSStatus)
    }

    private(set) var queryable: KeychainQueryable

    init(queryable: KeychainQueryable) {
        self.queryable = queryable
    }

    func save(password: String, for account: String) throws {
        let encodedPassword = password.data(using: .utf8)!

        do {
            // Check for an existing item in the keychain.
            try _ = readPassword(for: account)

            // Update the existing item with the new password.
            var attributesToUpdate = [String: Any]()
            attributesToUpdate[kSecValueData as String] = encodedPassword

            var query = queryable.query
            query[kSecAttrAccount as String] = account

            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)

            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }

        } catch KeychainError.noPassword {
            var query = queryable.query
            query[kSecAttrAccount as String] = account
            query[kSecValueData as String] = encodedPassword

            // Add a the new item to the keychain.
            let status = SecItemAdd(query as CFDictionary, nil)

            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }

        }
    }

    func readPassword(for account: String) throws -> String {
        var query = queryable.query
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecAttrAccount as String] = account

        // Try to fetch the existing keychain item that matches the query.
        var queryResult: AnyObject?

        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        // Check the return status and throw an error if appropriate.
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }

        // Parse the password string from the query result.
        guard let existingItem = queryResult as? [String: AnyObject],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8)
            else {
                throw KeychainError.unexpectedPasswordData
        }

        return password
    }

    func readAccount() throws -> (username: String, password: String) {
        var query = queryable.query
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue

        // Try to fetch the existing keychain item that matches the query.
        var queryResult: AnyObject?

        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        // Check the return status and throw an error if appropriate.
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }

        // Parse the account string from the query result.
        guard let existingItem = queryResult as? [String: AnyObject],
            let account = existingItem[kSecAttrAccount as String] as? String
            else {
                throw KeychainError.unexpectedItemData
        }

        // Parse the password string from the query result.
        guard let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8)
            else {
                throw KeychainError.unexpectedPasswordData
        }

        return (username: account, password: password)
    }

    func renameAccount(_ newAccountName: String) throws {
        // Try to update an existing item with the new account name.
        var attributesToUpdate = [String: Any]()
        attributesToUpdate[kSecAttrAccount as String] = newAccountName

        var query = queryable.query
        query[kSecAttrAccount as String] = newAccountName

        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        // Throw an error if an unexpected status was returned.

        guard status == noErr || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    func delete() throws {
        // Delete the existing item from the keychain.
        let status = SecItemDelete(queryable.query as CFDictionary)

        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }

    }
}
