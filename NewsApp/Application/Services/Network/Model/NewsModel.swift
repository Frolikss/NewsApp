//
//  NewsModel.swift
//  NewsApp
//
//  Created by Dima on 04.06.2021.
//

import Foundation

struct NewsModel: Decodable {
    let totalResults: Int
    let articles: [Article]
}

struct Article: Decodable {
    let author: String?
    let title: String
    let url: String
    let urlToImage: String?
    let description: String?
}
