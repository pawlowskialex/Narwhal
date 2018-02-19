//
//  SubredditPaginator.swift
//  Reddit
//
//  Created by Alex Pawlowski on 2/16/18.
//  Copyright © 2018 Alex Pawlowski. All rights reserved.
//

import Foundation

class SubredditPaginator {
    private enum Page {
        case loading(DisposableType)
        case loaded(PageableRedditListing)
        
        var posts: [RedditPost] {
            switch self {
            case .loaded(let listing):
                return listing.content.children.map { $0.post }
            default:
                return []
            }
        }
    }
    
    private let api: RedditAPIType
    private let request: RedditListingRequest
    private var pages: [Page] = []
    
    private let subject = BehaviorSubject<[RedditPost]>()
    private let queue = DispatchQueue(label: "org.pawlowski.Reddit.paginator.queue")
    
    init(api: RedditAPIType, request: RedditListingRequest) {
        self.api = api
        self.request = request
    }
    
    var posts: Observable<[RedditPost]> { return subject }
    var hasNext: Bool {
        if case let .some(.loaded(listing)) = self.pages.last {
            return listing.next != nil
        }
        return true
    }
    
    func reload(reset: Bool = true) {
        queue.async {
            self.pages = []
            self.append(listing: self.api.listing(request: self.request, limit: 50))
            
            if reset { self.reloadPosts() }
        }
    }
    
    func loadNext() {
        queue.async {
            guard
                let last = self.pages.last,
                case let .loaded(listing) = last,
                let next = listing.next
                else { return }
            
            self.append(listing: next)
            self.reloadPosts()
        }
    }
    
    private func append(listing: Observable<PageableRedditListing>) {
        let index = pages.count
        let subscription = listing
            .retry()
            .observe(on: queue)
            .subscribe(target: self, onNext: {
                $0.pages[index] = .loaded($1)
                $0.reloadPosts()
            })
            .unsubcribedOnDeinit()
        
        pages.append(.loading(subscription))
    }
    
    private func reloadPosts() {
        subject.onNext(pages.flatMap { $0.posts })
    }
}
