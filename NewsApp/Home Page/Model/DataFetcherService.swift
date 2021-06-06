//
//  DataFetcherService.swift
//  NewsApp
//
//  Created by Dima on 06.06.2021.
//

import Foundation

class DataFetcherService {
    
    var networkDataFetcher: DataFetcher
    
    init(networkDataFetcher: DataFetcher = NetworkDataFetcher()) {
        self.networkDataFetcher = networkDataFetcher
    }
    
    func fetchNews(completion: @escaping (NewsModel?) -> Void) {
        let urlNewsString = "https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=\(K.apiKey)"
        networkDataFetcher.fetchGenericJSONData(urlString: urlNewsString, response: completion)
    }
    
    func fetchNewsWithCategory(from index: Int, completion: @escaping (NewsModel?) -> Void) {
        let categories = Categories.allCases
        let urlNewsWithCategory = "https://newsapi.org/v2/top-headlines?country=us&category=\(categories[index])&apiKey=\(K.apiKey)"
        networkDataFetcher.fetchGenericJSONData(urlString: urlNewsWithCategory, response: completion)
    }
}
