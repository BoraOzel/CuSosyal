//
//  TagsViewController.swift
//  CuSosyal
//
//  Created by Bora Özel on 16/3/26.
//

import UIKit

protocol TagSelectionDelegate: AnyObject {
    func didSelectTags(tags: [Tags])
}

class TagsViewController: UIViewController,
                          AlertPresentable {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    
    var selectedTags: [Tags] = []
    
    weak var delegate: TagSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    
    }

    @IBAction func registerButtonClicked(_ sender: Any) {
        guard !selectedTags.isEmpty else {
            showAlert(title: "Hata",
                      message: "En az 3 adet ilgi alanı seçiniz.",
                      buttonText: "Tamam")
            
            return
        }
        
        delegate?.didSelectTags(tags: selectedTags)
    }
    
}
