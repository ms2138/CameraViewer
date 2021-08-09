//
//  UITextField+EXT.swift
//  CameraViewer
//
//  Created by mani on 2021-08-08.
//

import UIKit

extension UITextField: Validatable {
    func validate(_ functions: [(String) -> Bool]) -> Bool {
        return functions.map { $0(self.text ?? "") }.allSatisfy { $0 == true }
    }
}
