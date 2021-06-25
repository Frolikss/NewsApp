//
//  HomePageViewController.swift
//  NewsApp
//
//  Created by Dima on 04.06.2021.
//

fileprivate var selectedCategory = 0
fileprivate var selectedCountry = K.countriesIndex.firstIndex(of: "us")!

import UIKit
import CoreData
import SwiftAlerts

class HomePageViewController: UITableViewController {
    
    private let cellIdentifier = "HomePageCell"
    private let spinner = UIActivityIndicatorView(style: .medium)
    private var dataFetcherService = DataFetcherService()
    private var news: NewsModel?
    private var cache = NSCache<AnyObject, AnyObject>()
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    //MARK: - View Controller Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        tabBarController?.tabBar.isHidden = false
        segmentedControl.apportionsSegmentWidthsByContent = true
        
        tableView.tableFooterView = UIView()
        tableView.backgroundView = spinner
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        
        dataFetcherService.fetchNews(selectedCountry: selectedCountry,
                                     selectedCategory: selectedCategory) { news in
            self.news = news
            self.reloadTableData()
        }
    }
    
    //MARK: - IBActions
    @IBAction func segmentedControlPressed(_ sender: UISegmentedControl) {
        
        selectedCategory = sender.selectedSegmentIndex
        dataFetcherService.fetchNewsWithCategory(selectedCountry: selectedCountry,
                                                 selectedCategory: selectedCategory) { news in
            self.news = news
            self.animateTransition(self.tableView) {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func selectedCountryPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Select Country",
                                      message: "Select news for specific country",
                                      preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        let doneAction = UIAlertAction(title: "Done",
                                       style: .default) { _ in
            self.spinner.startAnimating()
            self.reloadTableData()
        }
        
        alert.popoverPresentationController?.barButtonItem = sender
        alert.addAction(cancelAction)
        alert.addAction(doneAction)
        alert.addPickerView(values: K.countries) { _, _, indexPath, _ in
            
            selectedCountry = indexPath.row
            self.dataFetcherService.fetchNewsWithCountry(selectedCountry: selectedCountry,
                                                         selectedCategory: selectedCategory) { news in
                self.news = news
            }
        }
        present(alert, animated: true)
    }
    
    @IBAction func refreshPage(_ sender: UIRefreshControl) {
        dataFetcherService.fetchNews(selectedCountry: selectedCountry,
                                     selectedCategory: selectedCategory) { news in
            
            if self.news?.articles.first?.title != news?.articles.first?.title {
                self.news = news
                self.tableView.reloadData()
            }
            sender.endRefreshing()
        }
    }
    
    //MARK: - Animate Transition func
    private func animateTransition(_ view: UIView, _ completion: @escaping () -> Void) {
        UIView.transition(with: view,
                          duration: 0.75,
                          options: .transitionCrossDissolve,
                          animations: completion)
    }
    
    //MARK: - Prepare for segue func
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow,
              let urlString = news?.articles[indexPath.row].url,
              let url = URL(string: urlString) else { return }
        
        let destinationVC = segue.destination as! WebPageViewController
        destinationVC.url = url
    }
    
    //MARK: - Reload Table Data func
    private func reloadTableData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.spinner.stopAnimating()
        }
    }
    
    //MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let save = saveAction(indexPath)
        return UISwipeActionsConfiguration(actions: [save])
    }
    
    //MARK: - Contextual Action
    private func saveAction(_ indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: "Save") { _, _, completion in
            guard let selectedNews = self.news?.articles[indexPath.row] else { return }
            
            let persitentItem = PersistentNews(context: self.context)
            persitentItem.title = selectedNews.title
            persitentItem.url = selectedNews.url
            persitentItem.urlToImage = selectedNews.urlToImage
            persitentItem.date = Date()
            
            do {
                try self.context.save()
            } catch {
                self.context.rollback()
                print(error.localizedDescription)
            }
            completion(true)
        }
        
        action.image = UIImage(systemName: "square.and.arrow.down")
        action.backgroundColor = .red
        return action
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news?.articles.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! HomePageCell
        
        let newsCell = news?.articles[indexPath.row]
        
        cell.delegate = self
        cell.indexPath = indexPath
        cell.authorLabel.text = newsCell?.author ?? ""
        cell.titleLabel.text = newsCell?.title
        
        if let image = cache.object(forKey: newsCell?.url as AnyObject) {
            
            self.animateTransition(cell) {
                cell.newsImage.image = image as? UIImage
            }
        } else {
            
            var data = Data()
            let imageWorkItem = DispatchWorkItem {
                guard let imageURL = URL(string: newsCell!.urlToImage ?? K.imageURL) else { return }
                
                do {
                    data = try Data(contentsOf: imageURL)
                } catch {
                    data = try! Data(contentsOf: URL(string: K.imageURL)!)
                }
            }
            
            DispatchQueue.global(qos: .utility).async(execute: imageWorkItem)
            
            imageWorkItem.notify(queue: .main) {
                
                self.animateTransition(cell) {
                    cell.newsImage.image = UIImage(data: data)
                }
                
                if let image = cell.newsImage.image {
                    self.cache.setObject(image, forKey: newsCell?.url as AnyObject)
                }
            }
        }
        return cell
    }
}

//MARK: - HomePageCellDelegate
extension HomePageViewController: HomePageCellDelegate {
    
    func getIndexPathForShareButton(_ indexPath: IndexPath, _ button: UIButton) {
        guard let selectedNews = news?.articles[indexPath.row].url else { return }
        
        let shareAction = UIActivityViewController(activityItems: [selectedNews], applicationActivities: nil)
        shareAction.popoverPresentationController?.sourceView = button
        present(shareAction, animated: true)
    }
}
