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
    var context: NSManagedObjectContext?
    
    //MARK: - Fetch Results Controller
    private lazy var fetchResultsController: NSFetchedResultsController<PersistentNews> = {
        let fetchRequest: NSFetchRequest<PersistentNews> = PersistentNews.fetchRequest()
        fetchRequest.fetchLimit = 20
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        guard let context = context else {
            return NSFetchedResultsController()
        }
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    private lazy var dateFormatter: DateFormatter = {
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
        guard let urlString = fetchResultsController.object(at: indexPath).url,
              let url = URL(string: urlString) else { return }
        
        let destinationVC = segue.destination as! WebPageViewController
        destinationVC.url = url
    }
    
    //MARK: - Fetch News from CoreData func
    private func fetchNews() {
        do {
            try fetchResultsController.performFetch()
            self.tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard fetchResultsController.fetchedObjects?.count != 0,
              let sectionInfo = fetchResultsController.sections?[section] else {
            
            let emptyLabel = UILabel(frame: CGRect(x: 0,
                                                   y: 0,
                                                   width: self.view.bounds.size.width,
                                                   height: self.view.bounds.size.height))
            emptyLabel.text = "Swipe right to save story on Home page"
            emptyLabel.textAlignment = .center
            self.tableView.backgroundView = emptyLabel
            self.tableView.separatorStyle = .none
            return 0
        }
        self.tableView.backgroundView = .none
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FavoritesViewCell
        cell.delegate = self
        cell.indexPath = indexPath
        
        let favoriteNews = fetchResultsController.object(at: indexPath)
        
        if let urlString = favoriteNews.urlToImage, let imageURL = URL(string: urlString) {
            
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
        let deleteNews = fetchResultsController.object(at: indexPath)
        
        fetchResultsController.managedObjectContext.delete(deleteNews)
        
        do {
            try fetchResultsController.managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getIndexPathForShareAction(_ indexPath: IndexPath, _ button: UIButton) {
        guard let selectedNews = fetchResultsController.object(at: indexPath).url else { return }
        
        let shareAction = UIActivityViewController(activityItems: [selectedNews], applicationActivities: nil)
        shareAction.popoverPresentationController?.sourceView = button
        present(shareAction, animated: true)
    }
}

// MARK: - Fetched Results Controller Delegate -
extension FavoritesViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .none)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .none)
        default: return
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData()
        self.tableView.endUpdates()
    }
}
