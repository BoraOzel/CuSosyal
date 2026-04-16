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

protocol TagsViewControllerInterface {
    func setupCollectionView()
}

class TagsViewController: UIViewController,
                          AlertPresentable {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    
    typealias CustomLayout = UICollectionViewFlowLayout
    
    var selectedTags: [Tags] = []
    
    weak var delegate: TagSelectionDelegate?
    
    private let allTags = Tags.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    @IBAction func registerButtonClicked(_ sender: Any) {
        guard selectedTags.count >= 3 else {
            showAlert(title: "Hata",
                      message: "En az 3 adet ilgi alanı seçiniz.",
                      buttonText: "Tamam")
            
            return
        }
        
        delegate?.didSelectTags(tags: selectedTags)
    }
    
}

extension TagsViewController: TagsViewControllerInterface {
    
    func setupCollectionView() {
        tagsCollectionView.delegate = self
        tagsCollectionView.dataSource = self
        
        tagsCollectionView.register(UINib(nibName: "TagsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TagsCollectionViewCell")
        
        tagsCollectionView.allowsMultipleSelection = true
        tagsCollectionView.collectionViewLayout = ThreeColumnGridFlowLayout()
    }
    
}

extension TagsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTag = allTags[indexPath.row]
        
        if !selectedTags.contains(selectedTag) {
            selectedTags.append(selectedTag)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let deselectedTag = allTags[indexPath.row]
        
        if let index = selectedTags.firstIndex(of: deselectedTag) {
            selectedTags.remove(at: index)
        }
    }
    
}

extension TagsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allTags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagsCollectionViewCell", for: indexPath) as! TagsCollectionViewCell
        let currentTag = allTags[indexPath.row]
        
        cell.configure(tag: currentTag)
        
        if selectedTags.contains(currentTag) {
            cell.isSelected = true
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        } else {
            cell.isSelected = false
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        
        return cell
    }
    
}
