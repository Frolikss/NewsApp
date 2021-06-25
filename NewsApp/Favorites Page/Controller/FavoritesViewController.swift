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
    
    //MARK: - View Controller Life Cycle
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
        if favoriteNews?.count == 0 {
            let emptyLabel = UILabel(frame: CGRect(x: 0,
                                                   y: 0,
                                                   width: self.view.bounds.size.width,
                                                   height: self.view.bounds.size.height))
            emptyLabel.text = "Swipe right to save story"
            emptyLabel.textAlignment = .center
            self.tableView.backgroundView = emptyLabel
            self.tableView.separatorStyle = .none
            return 0
        } else {
            return favoriteNews?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FavoritesViewCell
        cell.delegate = self
        cell.indexPath = indexPath
        
        if favoriteNews != nil {
            guard let favoriteNews = favoriteNews?[indexPath.row],
                  let imageURL = URL(string: favoriteNews.urlToImage!) else { return UITableViewCell() }
            
            let date = dateFormatter.string(from: favoriteNews.date!)
            
            cell.titleLabel.text = favoriteNews.title
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
    
    func getIndexPathForDeleteAction(_ indexPath: IndexPath) {
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
    
    func getIndexPathForShareAction(_ indexPath: IndexPath, _ button: UIButton) {
        guard let selectedNews = favoriteNews?[indexPath.row].url else { return }
        
        let shareAction = UIActivityViewController(activityItems: [selectedNews], applicationActivities: nil)
        shareAction.popoverPresentationController?.sourceView = button
        present(shareAction, animated: true)
    }
}
