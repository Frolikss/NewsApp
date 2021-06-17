//
//  HomePageCell.swift
//  NewsApp
//
//  Created by Dima on 04.06.2021.
//

import UIKit

protocol HomePageCellDelegate: AnyObject {
    func getIndexPath(indexPath: IndexPath)
}

class HomePageCell: UITableViewCell {
    
    weak var delegate: HomePageCellDelegate?
    var indexPath: IndexPath?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowRadius = 3.0
        titleLabel.layer.shadowOpacity = 1.0
        titleLabel.layer.shadowOffset = CGSize(width: 4, height: 4)
        titleLabel.layer.masksToBounds = false
    }
    @IBAction func bookmarkButtonPressed(_ sender: UIButton) {
        guard let indexPath = indexPath else { return }
        delegate?.getIndexPath(indexPath: indexPath)
    }
}
