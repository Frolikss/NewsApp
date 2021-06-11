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
        let urlNewsString = "https://newsapi.org/v2/top-headlines?country=\(K.countriesIndex[selectedCountry])&category=\(categories[selectedCategory])&apiKey=\(K.apiKey)"
        networkDataFetcher.fetchGenericJSONData(urlString: urlNewsString, response: completion)
    }
    
    func fetchNewsWithCategory(selectedCountry: Int, selectedCategory: Int, completion: @escaping (NewsModel?) -> Void) {
        let urlNewsWithCategory = "https://newsapi.org/v2/top-headlines?country=\(K.countriesIndex[selectedCountry])&category=\(categories[selectedCategory])&apiKey=\(K.apiKey)"
        networkDataFetcher.fetchGenericJSONData(urlString: urlNewsWithCategory, response: completion)
    }
    
    func fetchNewsWithCountry(selectedCountry: Int, selectedCategory: Int, completion: @escaping (NewsModel?) -> Void) {
        let urlNewsWithCategory = "https://newsapi.org/v2/top-headlines?country=\(K.countriesIndex[selectedCountry])&category=\(categories[selectedCategory])&apiKey=\(K.apiKey)"
        networkDataFetcher.fetchGenericJSONData(urlString: urlNewsWithCategory, response: completion)
    }
}
