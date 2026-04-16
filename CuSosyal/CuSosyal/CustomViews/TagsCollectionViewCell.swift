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
    
    private let unselectedAlpha: CGFloat = 0.5
    private let selectedAlpha: CGFloat = 0.95
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    override var isSelected: Bool {
        didSet {
            updateSelectionUI()
        }
    }
    
    func configure(tag: Tags) {
        tagNameLabel.text = tag.rawValue
        tagImageView.image = tag.icon
    }
    
    func setupCell() {
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1.5
        self.layer.borderColor = UIColor.systemGray5.cgColor
        self.backgroundColor = .clear
        self.containerView.backgroundColor = UIColor.systemBackground.withAlphaComponent(unselectedAlpha)
    }
    
    func updateSelectionUI() {
        let targetAlpha = isSelected ? selectedAlpha : unselectedAlpha
        let targetBorderColor = isSelected ? UIColor(named: "accentColor")?.cgColor : UIColor.systemGray5.cgColor
        
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor = UIColor.systemBackground.withAlphaComponent(targetAlpha)
            self.layer.borderColor = targetBorderColor
        }
    }
    
}
