//
//  SearchViewController.swift
//  NewsApp
//
//  Created by Dima on 12.06.2021.
//

import UIKit

class SearchViewController: UIViewController {
    
    private let cellIdentifier = "SearchCell"
    var news: NewsModel?
    var dataFetcherService = DataFetcherService()
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Search"
        tabBarController?.tabBar.isHidden = false
  
        textField.becomeFirstResponder()
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = textField.layer.frame.height / 2
        textField.layer.masksToBounds = true
        textField.layer.borderColor = UIColor.red.cgColor
        
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorColor = .gray
        self.tableView.isHidden = true
    }
    
    //MARK: - IBActions
    @IBAction func textFieldInput(_ sender: UITextField) {
        guard let quote = sender.text else { return }
        dataFetcherService.fetchNewsWithSearch(from: quote) { news in
            self.news = news
            DispatchQueue.main.async {
                self.tableView.isHidden = false
                self.tableView.reloadData()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - Prepare for segue func
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        guard let urlString = news?.articles[indexPath.row].url,
              let url = URL(string: urlString) else { return }
        
        let destinationVC = segue.destination as! WebPageViewController
        destinationVC.url = url
    }
    
}

//MARK: - TableView DataSource extension
extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if news?.totalResults == 0 {
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width,
                                                   height: self.view.bounds.size.height))
            emptyLabel.text = "No results"
            emptyLabel.textAlignment = .center
            self.tableView.backgroundView = emptyLabel
            self.tableView.separatorStyle = .none
            return 0
        } else {
            return news?.articles.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Total results: \(news?.totalResults ?? 0)"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SearchTableViewCell
        
        let cellData = news?.articles[indexPath.row]
        cell.titleLabel.text = cellData?.title
        cell.descriptionLabel.text = cellData?.description
        
        return cell
    }
}

