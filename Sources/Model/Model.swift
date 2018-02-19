//
//  Model.swift
//  Reddit
//
//  Created by Alex Pawlowski on 2/16/18.
//  Copyright © 2018 Alex Pawlowski. All rights reserved.
//

import Foundation

struct RedditResponse: Codable {
    let listing: RedditListing
    
    enum CodingKeys : String, CodingKey {
        case listing = "data"
    }
}

struct RedditListing: Codable {
    let after: String?
    let children: [RedditChild]
}

struct RedditChild: Codable {
    let kind: String
    let post: RedditPost
    
    enum CodingKeys : String, CodingKey {
        case kind
        case post = "data"
    }
}

struct RedditPost: Codable {
    let title: String
    let author: String
    let subreddit: String
    let url: URL
    let created: Date
    let thumbnail: URL?
    let numberOfComments: Int
    let preview: RedditPreview?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.title = try container.decode(String.self, forKey: .title)
        self.author = try container.decode(String.self, forKey: .author)
        self.subreddit = try container.decode(String.self, forKey: .subreddit)
        
        let absoluteString = try container.decode(String.self, forKey: .url)
        let encodedString = absoluteString
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            .get(or: absoluteString)
        
        self.url = try URL(string: encodedString).get(or: container.decode(URL.self, forKey: .url))
        self.created = Date(timeIntervalSince1970: try container.decode(Double.self, forKey: .created))
        self.thumbnail = (try? container.decode(URL.self, forKey: .thumbnail))
            .flatMap { $0.absoluteString.hasPrefix("http") ? $0 : nil }
        self.numberOfComments = try container.decode(Int.self, forKey: .numberOfComments)
        self.preview = try? container.decode(RedditPreview.self, forKey: .preview)
    }
    
    
    enum CodingKeys : String, CodingKey {
        case title
        case author
        case subreddit = "subreddit_name_prefixed"
        case url
        case created = "created_utc"
        case thumbnail = "thumbnail"
        case numberOfComments = "num_comments"
        case preview
    }
}

struct RedditPreview: Codable {
    let images: [RedditImage]
}

struct RedditImage: Codable {
    let source: RedditImageSource
}

struct RedditImageSource: Codable {
    let url: URL
}
