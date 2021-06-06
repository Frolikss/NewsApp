//
//  HomePageViewController.swift
//  NewsApp
//
//  Created by Dima on 04.06.2021.
//

import UIKit

class HomePageViewController: UITableViewController {
    
    let spinner = UIActivityIndicatorView(style: .medium)
    var dataFetcherService = DataFetcherService()
    var news: NewsModel?
    var cache = NSCache<AnyObject, AnyObject>()
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        segmentedControl.apportionsSegmentWidthsByContent = true
        
        tableView.backgroundView = spinner
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        
        dataFetcherService.fetchNews { data in
            self.news = data
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.spinner.stopAnimating()
            }
        }
    }
    
    @IBAction func segmentedControlPressed(_ sender: UISegmentedControl) {
        
        let index = sender.selectedSegmentIndex
        dataFetcherService.fetchNewsWithCategory(from: index) { data in
            
            self.news = data
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.spinner.stopAnimating()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        guard let urlString = news?.articles[indexPath.row].url,
              let url = URL(string: urlString) else { return }
        
        let destinationVC = segue.destination as! WebPageViewController
        destinationVC.url = url
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return news != nil ? 1 : 0
    }
    
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
            
            DispatchQueue.global(qos: .userInitiated).async(execute: imageWorkItem)
            
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
