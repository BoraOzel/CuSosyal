//
//  TagsCollectionViewCell.swift
//  CuSosyal
//
//  Created by Bora Özel on 24/3/26.
//

import UIKit

class TagsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tagImageView: UIImageView!
    @IBOutlet weak var tagNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    func configure(tag: Tags) {
        tagNameLabel.text = tag.rawValue
        tagImageView.image = tag.icon
    }
    
    func setupCell() {
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1.5
        self.layer.borderColor = UIColor.systemGray5.cgColor
    }
    
}
