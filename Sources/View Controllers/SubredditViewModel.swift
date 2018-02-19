//
//  SubredditViewModel.swift
//  Reddit
//
//  Created by Alex Pawlowski on 2/17/18.
//  Copyright © 2018 Alex Pawlowski. All rights reserved.
//

import Foundation
import UIKit

class SubredditViewModel {
    private let paginator: SubredditPaginator
    
    private let subject = BehaviorSubject<State>(value: .loading)
    private let queue = DispatchQueue(label: "org.pawlowski.Reddit.subreddit.viewModel",
                                       qos: .userInteractive)
    
    private var posts: [RedditPost] = []
    private var bounds: CGSize = .zero
    
    enum State {
        case loading
        case loaded(nodes: [SubredditPostTableViewNode], moreAvailable: Bool)
    }
    
    init(api: RedditAPIType, request: RedditListingRequest) {
        paginator = SubredditPaginator(api: api, request: request)
        title = "Reddit · \(request.path)"
        nodes = subject
        paginator.posts
            .observe(on: queue)
            .subscribe(target: self, onNext: { $0.updatePosts($1) })
            .disposed(by: disposeBag)
    }
    
    let title: String
    let nodes: Observable<State>
    
    func didActivate() {
        if posts.isEmpty { reload() }
        else { recalculateNodes() }
    }
    
    func reload(reset: Bool = true) {
        paginator.reload(reset: reset)
    }
    
    func loadNext() {
        paginator.loadNext()
    }
    
    func updateBounds(_ bounds: CGSize) {
        self.bounds = bounds
        self.recalculateNodes()
    }
    
    private func updatePosts(_ posts: [RedditPost]) {
        self.posts = posts
        self.recalculateNodes()
    }
    
    private func recalculateNodes() {
        let isNotEmpty = self.bounds.width > 0.0 || self.bounds.height > 0.0
        let width = self.bounds.width
        let nodes = isNotEmpty ? posts.map { SubredditPostTableViewNode(post: $0, width: width) } : []
        let actions = { self.subject.onNext(.loaded(nodes: nodes,
                                                    moreAvailable: self.paginator.hasNext)) }
        
        executeOnMain(actions)
    }
    
    private let disposeBag = DisposeBag()
}
