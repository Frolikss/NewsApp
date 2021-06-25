//
//  Networking.swift
//  NewsApp
//
//  Created by Dima on 25.06.2021.
//

import Foundation

protocol Networking {
    func request(urlString: String, complition: @escaping (Data?, Error?) -> Void)
}
