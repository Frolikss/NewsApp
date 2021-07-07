//
//  DataFetcherService.swift
//  NewsApp
//
//  Created by Dima on 06.06.2021.
//

import Foundation

class DataFetcherService {
    
    var networkDataFetcher: DataFetcher
    private let categories = Categories.allCases
    
    init(networkDataFetcher: DataFetcher = NetworkDataFetcher()) {
        self.networkDataFetcher = networkDataFetcher
    }
    
    func fetchNews(selectedCountry: Int, selectedCategory: Int, completion: @escaping (NewsModel?) -> Void) {
        let urlNewsString = "https://newsapi.org/v2/top-headlines?pageSize=10&country=\(K.countriesIndex[selectedCountry])&category=\(categories[selectedCategory])&apiKey=\(apiKey)"
        networkDataFetcher.fetchGenericJSONData(urlString: urlNewsString, response: completion)
    }
    
    func fetchNewsWithCategory(selectedCountry: Int, selectedCategory: Int, completion: @escaping (NewsModel?) -> Void) {
        let urlNewsWithCategory = "https://newsapi.org/v2/top-headlines?pageSize=10&country=\(K.countriesIndex[selectedCountry])&category=\(categories[selectedCategory])&apiKey=\(apiKey)"
        networkDataFetcher.fetchGenericJSONData(urlString: urlNewsWithCategory, response: completion)
    }
    
    func fetchNewsWithCountry(selectedCountry: Int, selectedCategory: Int, completion: @escaping (NewsModel?) -> Void) {
        let urlNewsWithCountry = "https://newsapi.org/v2/top-headlines?pageSize=10&country=\(K.countriesIndex[selectedCountry])&category=\(categories[selectedCategory])&apiKey=\(apiKey)"
        networkDataFetcher.fetchGenericJSONData(urlString: urlNewsWithCountry, response: completion)
    }
    
    func fetchNewsWithSearch(from quote: String, completion: @escaping (NewsModel?) -> Void) {
        let urlNewsWithSearch = "https://newsapi.org/v2/top-headlines?q=\(quote)&apiKey=\(apiKey)"
        networkDataFetcher.fetchGenericJSONData(urlString: urlNewsWithSearch, response: completion)
    }
}
