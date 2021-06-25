//
//  NetworkService.swift
//  NewsApp
//
//  Created by Dima on 04.06.2021.
//

import Foundation

protocol Networking {
    func request(urlString: String, complition: @escaping (Data?, Error?) -> Void)
}

class NetworkService: Networking {
    
    func request(urlString: String, complition: @escaping (Data?, Error?) -> Void) {
        guard let url = URL(string: urlString) else { return }
    
        let request = URLRequest(url: url)
        let task = createDataTask(from: request, completion: complition)
        task.resume()
    }
    
    private func createDataTask(from request: URLRequest, completion: @escaping (Data?, Error?) -> Void) -> URLSessionDataTask {
        return URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                completion(nil, NetworkError.failInternetError)
                return }
            DispatchQueue.main.async {
                completion(data, error)
            }
        }
    }
}
