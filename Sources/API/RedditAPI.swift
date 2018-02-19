//
//  RedditAPI.swift
//  Reddit
//
//  Created by Alex Pawlowski on 2/16/18.
//  Copyright © 2018 Alex Pawlowski. All rights reserved.
//

import Foundation

struct RedditListingRequest {
    let path: String
}

struct PageableRedditListing {
    let content: RedditListing
    let next: Observable<PageableRedditListing>?
}

protocol RedditAPIType {
    func listing(request: RedditListingRequest, limit: Int) -> Observable<PageableRedditListing>
}

class RedditAPI: RedditAPIType {
    static var `default`: RedditAPI =
        RedditAPI(baseURL: URL(string: "https://reddit.com")!)
    
    enum Error: Swift.Error {
        case malformedBaseURL
    }
    
    private let session: URLSession
    private let baseURL: URL
    
    init(baseURL: URL, session: URLSession = .shared) {
        self.session = session
        self.baseURL = baseURL
    }
    
    func listing(request: RedditListingRequest, limit: Int = 50) -> Observable<PageableRedditListing> {
        return createListingObservable(request: request,
                                       session: session,
                                       baseURL: baseURL,
                                       limit: limit)
    }
}

private func createListingObservable(request: RedditListingRequest,
                                     session: URLSession,
                                     baseURL: URL,
                                     limit: Int,
                                     after: String? = nil) -> Observable<PageableRedditListing> {
    
    guard var components = URLComponents(string: baseURL.absoluteString)
        else { return Observable.error(RedditAPI.Error.malformedBaseURL) }
    
    let afterQueryItem = after
        .map { [URLQueryItem(name: "after", value: "\($0)")] }
        .get(or: [])
    
    components.path = "/\(request.path)/.json"
    components.queryItems = [URLQueryItem(name: "limit", value: "\(limit)")] + afterQueryItem
    
    guard let url = components.url
        else { return Observable.error(RedditAPI.Error.malformedBaseURL) }
    
    return session
        .data(at: url)
        .map { data in
            let decoder = JSONDecoder()
            let listing = try decoder.decode(RedditResponse.self, from: data).listing
            
            return PageableRedditListing(content: listing,
                                         next:
                listing.after.map { createListingObservable(request: request,
                                                            session: session,
                                                            baseURL: baseURL,
                                                            limit: limit,
                                                            after: $0) }
            )
    }
}
