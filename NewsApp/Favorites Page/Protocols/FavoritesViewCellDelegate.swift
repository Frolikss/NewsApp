//
//  FavoritesViewCellDelegate.swift
//  NewsApp
//
//  Created by Dima on 25.06.2021.
//

import UIKit

protocol FavoritesViewCellDelegate: AnyObject {
    func getIndexPathForDeleteAction(_ indexPath: IndexPath)
    func getIndexPathForShareAction(_ indexPath: IndexPath, _ button: UIButton)
}
