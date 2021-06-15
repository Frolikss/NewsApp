//
//  HomePageViewController.swift
//  NewsApp
//
//  Created by Dima on 04.06.2021.
//

public var selectedCategory = 0
public var selectedCountry = K.countriesIndex.firstIndex(of: "us")!

import UIKit
import SwiftAlerts

class HomePageViewController: UITableViewController {
    
    private let cellIdentifier = "HomePageCell"
    private let spinner = UIActivityIndicatorView(style: .medium)
    var dataFetcherService = DataFetcherService()
    var news: NewsModel?
    var cache = NSCache<AnyObject, AnyObject>()
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = false
        
        segmentedControl.apportionsSegmentWidthsByContent = true
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
            UIView.transition(with: self.tableView,
                              duration: 0.75,
                              options: .transitionCrossDissolve,
                              animations: { self.tableView.reloadData() })
            
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
        
        alert.addAction(cancelAction)
        alert.addAction(doneAction)
        alert.addPickerView(values: K.countries) { _, _, index, _ in
            selectedCountry = index.row
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
    //MARK: - Prepare for segue func
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        guard let urlString = news?.articles[indexPath.row].url,
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
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news?.articles.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! HomePageCell
        
        let newsCell = news?.articles[indexPath.row]
        cell.authorLabel.text = newsCell?.author ?? "No author"
        cell.titleLabel.text = newsCell?.title
        
        if let image = cache.object(forKey: newsCell?.url as AnyObject) {
            UIView.transition(with: cell,
                              duration: 0.75,
                              options: .transitionCrossDissolve,
                              animations: { cell.newsImage.image = image as? UIImage })
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
            
            DispatchQueue.global(qos: .background).async(execute: imageWorkItem)
            
            imageWorkItem.notify(queue: .main) {
                UIView.transition(with: cell,
                                  duration: 0.75,
                                  options: .transitionCrossDissolve,
                                  animations: { cell.newsImage.image = UIImage(data: data) })
                if let image = cell.newsImage.image {
                    self.cache.setObject(image, forKey: newsCell?.url as AnyObject)
                }
            }
        }
        return cell
    }
}
