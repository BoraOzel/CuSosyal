//
//  EventCollectionViewCell.swift
//  CuSosyal
//
//  Created by Bora Özel on 19/4/26.
//

import UIKit
import SDWebImage

class EventCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAppearance()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
        dateLabel.text = nil
        locationLabel.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.layer.cornerRadius = 12
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        imageView.clipsToBounds = true
    }
    
    private func setupAppearance() {
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true
        
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.accent.cgColor
        
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 6
    }
    
    
    func configure(with event: Events, logoUrl: String) {
        titleLabel.text = event.title
        locationLabel.text = "📍\(event.location)"
        dateLabel.text = "🗓️\(Self.dateFormatter.string(from: event.date))"
        imageView.sd_setImage(with: URL(string: logoUrl))
    }
    
}
