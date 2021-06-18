//
//  FavoritesViewCell.swift
//  NewsApp
//
//  Created by Dima on 18.06.2021.
//

import UIKit

protocol FavoritesViewCellDelegate: AnyObject {
    func getIndexPath(_ indexPath: IndexPath)
}

class FavoritesViewCell: UITableViewCell {
    
    weak var delegate: FavoritesViewCellDelegate?
    var indexPath: IndexPath?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var savedOnLabel: UILabel!
    @IBOutlet weak var favoritesImageView: UIImageView!
    
    @IBAction func binButtonPressed(_ sender: Any) {
        guard let indexPath = indexPath else { return }
        delegate?.getIndexPath(indexPath)
    }
}
