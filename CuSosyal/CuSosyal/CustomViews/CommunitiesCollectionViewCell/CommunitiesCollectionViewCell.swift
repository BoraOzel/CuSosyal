//
//  CommunitiesCollectionViewCell.swift
//  CuSosyal
//
//  Created by Bora Özel on 18/4/26.
//

import UIKit
import SDWebImage

class CommunitiesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var communityImageView: UIImageView!
    @IBOutlet weak var communityNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupBorder()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        communityImageView.sd_cancelCurrentImageLoad()
        communityImageView.image = nil
        communityNameLabel.text = nil
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width,
                                height: UIView.layoutFittingCompressedSize.height)
        let size = contentView.systemLayoutSizeFitting(targetSize,
                                                       withHorizontalFittingPriority: .required,
                                                       verticalFittingPriority: .fittingSizeLevel)
        layoutAttributes.frame.size = size
        return layoutAttributes
    }
    
    func configure(data: Communities) {
        communityNameLabel.text = data.name
        communityImageView.sd_setImage(with: URL(string: data.logoUrl ?? ""))
    }
    
    func setupBorder() {
        layer.borderWidth = 1
        layer.cornerRadius = 20
        layer.borderColor = UIColor.accent.cgColor
    }
}
