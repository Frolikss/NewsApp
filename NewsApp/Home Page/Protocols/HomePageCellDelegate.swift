//
//  HomePageCellDelegate.swift
//  NewsApp
//
//  Created by Dima on 25.06.2021.
//

import UIKit

protocol HomePageCellDelegate: AnyObject {
    func getIndexPathForShareButton(_ indexPath: IndexPath, _ button: UIButton)
}
