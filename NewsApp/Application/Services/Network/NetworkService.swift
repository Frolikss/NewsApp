//
//  NetworkService.swift
//  NewsApp
//
//  Created by Dima on 04.06.2021.
//

import Foundation

class NetworkingService {
    
    let urlString = "https://newsapi.org/v2/top-headlines?country=us&apiKey=\(K.apiKey)"
    
    func request(complition: @escaping (NewsModel?) -> Void){
        guard let url = URL(string: urlString) else { return }
        
        var decode: NewsModel?
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else { return }
            decode = self.decodeJSON(from: data)
            complition(decode)
        }
        task.resume()
    }
    
    func decodeJSON(from data: Data?) -> NewsModel? {
        let decoder = JSONDecoder()
        
        guard let data = data else { return nil }
        do {
            let objects = try decoder.decode(NewsModel.self, from: data)
            return objects
        } catch {
            print(error)
            return nil
        }
    }
}
