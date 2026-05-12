//
//  UIView+Appearance.swift
//  CuSosyal
//
//  Created by Bora Özel on 12/5/26.
//

import UIKit

extension UIView {
    
    func applyGradient(colors: [UIColor],
                       startPoint: CGPoint = CGPoint(x: 0, y: 0),
                       endPoint: CGPoint = CGPoint(x: 1, y: 1),
                       cornerRadius: CGFloat = 0) {

        layer.sublayers?.removeAll { $0 is CAGradientLayer }
        
        let gradient = CAGradientLayer()
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.frame = bounds
        gradient.cornerRadius = cornerRadius
        layer.insertSublayer(gradient, at: 0)
    }
    
    func applyShadow(color: UIColor = .black,
                     opacity: Float = 0.15,
                     offset: CGSize = CGSize(width: 0, height: 4),
                     radius: CGFloat = 8) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
    }
    
    func applyCornerRadius(_ radius: CGFloat) {
        layer.cornerRadius = radius
    }
    
    func updateGradientFrame() {
        layer.sublayers?
            .compactMap { $0 as? CAGradientLayer }
            .forEach { $0.frame = bounds }
    }
}

