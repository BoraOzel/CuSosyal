//
//  UIViewController+Loading.swift
//  CuSosyal
//
//  Created by Bora Özel on 4/6/26.
//

import UIKit

extension UIViewController {

    private static let loadingIndicatorTag = 999
    private static let themeGreen = UIColor(red: 0.22, green: 0.56, blue: 0.24, alpha: 1)

    func showLoadingIndicator() {
        guard view.viewWithTag(Self.loadingIndicatorTag) == nil else { return }

        let overlay = UIView()
        overlay.tag = Self.loadingIndicatorTag
        overlay.backgroundColor = .systemBackground
        overlay.translatesAutoresizingMaskIntoConstraints = false

        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = Self.themeGreen
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()

        overlay.addSubview(indicator)
        view.addSubview(overlay)

        NSLayoutConstraint.activate([
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            indicator.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
        ])
    }

    func hideLoadingIndicator() {
        guard let overlay = view.viewWithTag(Self.loadingIndicatorTag) else { return }
        (overlay.subviews.first as? UIActivityIndicatorView)?.stopAnimating()
        overlay.removeFromSuperview()
    }
}
