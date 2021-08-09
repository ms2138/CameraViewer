//
//  NoContentBackgroundView.swift
//  CameraViewer
//
//  Created by mani on 2021-08-08.
//

import UIKit

protocol NoContentBackgroundView where Self: UIViewController {
    var tableView: UITableView! { get set }
    var backgroundView: DTTableBackgroundView { get }
    func showBackgroundView()
    func hideBackgroundView()
}

extension NoContentBackgroundView {
    func showBackgroundView() {
        tableView.separatorStyle = .none
        self.tableView.backgroundView?.isHidden = false
    }

    func hideBackgroundView() {
        tableView.separatorStyle = .singleLine
        self.tableView.backgroundView?.isHidden = true
    }
}
