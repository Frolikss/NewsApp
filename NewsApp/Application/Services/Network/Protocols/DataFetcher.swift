//
//  DataFetcher.swift
//  NewsApp
//
//  Created by Dima on 25.06.2021.
//

import Foundation

protocol DataFetcher {
    func fetchGenericJSONData<T: Decodable>(urlString: String, response: @escaping (T?) -> Void)
}
