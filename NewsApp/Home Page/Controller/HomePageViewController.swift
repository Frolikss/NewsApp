//
//  HomePageViewController.swift
//  NewsApp
//
//  Created by Dima on 04.06.2021.
//

import UIKit

class HomePageViewController: UITableViewController {
    
    let networkService = NetworkingService()
    var news: NewsModel?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        networkService.request { data in
            self.news = data
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        DispatchQueue.global(qos: .utility).async {
            if let imageURL = URL(string: newsCell!.urlToImage ?? K.imageURL) {
                if let dataImage = try? Data(contentsOf: imageURL) {
                    DispatchQueue.main.async {
                        cell.newsImage.image = UIImage(data: dataImage)
                    }
                }
            }
        }
        return cell
    }
}
