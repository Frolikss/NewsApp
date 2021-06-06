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
        let urlNewsString = "https://newsapi.org/v2/top-headlines?country=us&apiKey=\(K.apiKey)"
        networkDataFetcher.fetchGenericJSONData(urlString: urlNewsString, response: completion)
    }
}
