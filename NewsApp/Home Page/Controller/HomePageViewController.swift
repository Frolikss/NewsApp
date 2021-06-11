//
//  HomePageViewController.swift
//  NewsApp
//
//  Created by Dima on 04.06.2021.
//

import UIKit
import SwiftAlerts

class HomePageViewController: UITableViewController {
    
    let spinner = UIActivityIndicatorView(style: .medium)
    var dataFetcherService = DataFetcherService()
    var news: NewsModel?
    var cache = NSCache<AnyObject, AnyObject>()
    var selectedCategory = 0
    var selectedCountry = 51
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        segmentedControl.apportionsSegmentWidthsByContent = true
        tableView.backgroundView = spinner
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        
        dataFetcherService.fetchNews(selectedCountry: selectedCountry, selectedCategory: selectedCategory) { data in
            self.news = data
            self.reloadTableData()
        }
    }
    
    @IBAction func segmentedControlPressed(_ sender: UISegmentedControl) {
        
        selectedCategory = sender.selectedSegmentIndex
        dataFetcherService.fetchNewsWithCategory(selectedCountry: selectedCountry, selectedCategory: selectedCategory) { data in
            self.news = data
            self.reloadTableData()
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
            self.selectedCountry = index.row
            self.dataFetcherService.fetchNewsWithCountry(selectedCountry: self.selectedCountry,
                                                         selectedCategory: self.selectedCategory) { data in
                self.news = data
            }
        }
        present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        guard let urlString = news?.articles[indexPath.row].url,
              let url = URL(string: urlString) else { return }
        
        let destinationVC = segue.destination as! WebPageViewController
        destinationVC.url = url
    }
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomePageCell", for: indexPath) as! HomePageCell
        
        let newsCell = news?.articles[indexPath.row]
        cell.authorLabel.text = newsCell?.author ?? "No author"
        cell.titleLabel.text = newsCell?.title
        
        if let image = cache.object(forKey: newsCell?.url as AnyObject) {
            cell.newsImage.image = image as? UIImage
        } else {
            var data = Data()
            let imageWorkItem = DispatchWorkItem {
                guard let imageURL = URL(string: newsCell!.urlToImage ?? K.imageURL) else { return }
                
                do {
                    data = try Data(contentsOf: imageURL)
                } catch {
                    print(error)
                }
            }
            
            DispatchQueue.global(qos: .background).async(execute: imageWorkItem)
            
            imageWorkItem.notify(queue: .main) {
                cell.newsImage.image = UIImage(data: data)
                if let image = cell.newsImage.image {
                    self.cache.setObject(image, forKey: newsCell?.url as AnyObject)
                }
            }
        }
        return cell
    }
}
