//
//  FavoritesViewController.swift
//  NewsApp
//
//  Created by Dima on 18.06.2021.
//

import UIKit
import CoreData

class FavoritesViewController: UITableViewController {
    
    private let cellIdentifier = "FavoritesCell"
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var favoriteNews: [PersistentNews]?
    private lazy var dateFormatter = { () -> DateFormatter in
        let dt = DateFormatter()
        dt.dateFormat = "MM/dd/yyyy"
        return dt
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchNews()
        self.tableView.tableFooterView = UIView()
    }
    
    //MARK: - Segue func
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        guard let urlString = favoriteNews?[indexPath.row].url,
              let url = URL(string: urlString) else { return }
        
        let destinationVC = segue.destination as! WebPageViewController
        destinationVC.url = url
    }
    
    //MARK: - Fetch News from CoreData func
    private func fetchNews() {
        
        do {
            favoriteNews = try context.fetch(PersistentNews.fetchRequest())
            self.tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteNews?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FavoritesViewCell
        cell.delegate = self
        cell.indexPath = indexPath
        
        if favoriteNews != nil {
            guard let favoriteNews = favoriteNews?[indexPath.row],
                  let imageURL = URL(string: favoriteNews.urlToImage!) else { return UITableViewCell() }
            
            cell.titleLabel.text = favoriteNews.title
            let date = dateFormatter.string(from: favoriteNews.date!)
            cell.savedOnLabel.text = "Saved: \(date)"
            
            var data = Data()
            DispatchQueue.global(qos: .utility).async {
                
                do {
                    data = try Data(contentsOf: imageURL)
                } catch {
                    data = try! Data(contentsOf: URL(string: K.imageURL)!)
                }
                
                DispatchQueue.main.async {
                    cell.favoritesImageView.image = UIImage(data: data)
                }
            }
        }
        return cell
    }
}

//MARK: - FavoritesViewCellDelegate
extension FavoritesViewController: FavoritesViewCellDelegate {
    func getIndexPath(_ indexPath: IndexPath) {
        guard let deleteNews = favoriteNews?[indexPath.row] else { return }
        
        favoriteNews?.remove(at: indexPath.row)
        context.delete(deleteNews)
        
        do {
            try context.save()
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
}
