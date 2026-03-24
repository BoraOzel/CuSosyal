//
//  ThreeColumnGridFlowLayout.swift
//  CuSosyal
//
//  Created by Bora Özel on 24/3/26.
//

import UIKit

class ThreeColumnGridFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
       
        let columns: CGFloat = 3
        let sidePadding: CGFloat = 16
        let spacingBetweenCells: CGFloat = 10
        let lineSpacing: CGFloat = 15
        
        let totalSpacing = (sidePadding * 2) + (spacingBetweenCells * (columns - 1))
        
        let cellWidth = (collectionView.bounds.width - totalSpacing) / columns
        
        self.itemSize = CGSize(width: cellWidth, height: cellWidth)
        self.minimumInteritemSpacing = spacingBetweenCells
        self.minimumLineSpacing = lineSpacing
        self.sectionInset = UIEdgeInsets(top: sidePadding, left: sidePadding, bottom: sidePadding, right: sidePadding)
    }
}
