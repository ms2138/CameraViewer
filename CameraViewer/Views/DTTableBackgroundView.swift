//
//  DTTableBackgroundView.swift
//  CameraViewer
//
//  Created by mani on 2021-08-08.
//

import UIKit

class DTTableBackgroundView: UIView {
    let messageLabel: UILabel
    let activityIndicator: UIActivityIndicatorView
    private let stackView: UIStackView

    override init(frame: CGRect) {
        self.messageLabel = UILabel(frame: .zero)
        self.messageLabel.textColor = UIColor.darkGray
        self.messageLabel.font = UIFont.systemFont(ofSize: 20.0)
        self.messageLabel.numberOfLines = 0
        self.messageLabel.textAlignment = .center

        self.activityIndicator = UIActivityIndicatorView(style: .large)
        self.activityIndicator.color = .darkGray

        self.messageLabel.text = "Label"

        self.stackView = UIStackView(arrangedSubviews: [self.messageLabel,
                                                        self.activityIndicator])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 8.0

        super.init(frame: frame)

        addSubview(stackView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
}

extension DTTableBackgroundView {
    func startLoadingOperation(message: String = "Loading...") {
        messageLabel.text = message
        activityIndicator.startAnimating()
    }

    func stopLoadingOperation(message: String = "") {
        messageLabel.text = message
        activityIndicator.stopAnimating()
    }
}
