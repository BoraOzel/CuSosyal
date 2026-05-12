//
//  SuggestedCollectionViewCell.swift
//  CuSosyal
//
//  Created by Bora Özel on 5/5/26.
//

import UIKit
import SDWebImage

class SuggestedCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAppearance()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.sd_cancelCurrentImageLoad()
        imageView.image = nil
        nameLabel.text = nil
    }
    
    func configure(data: Communities) {
        nameLabel.text = data.name
        imageView.sd_setImage(with: URL(string: data.logoUrl ?? ""))
    }
    
    func setupAppearance() {
        containerView.applyCornerRadius(20)
        containerView.layer.masksToBounds = true
        
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 6
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.accent.cgColor
    }
    
}
