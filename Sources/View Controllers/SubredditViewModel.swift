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
    
    private enum BackingState {
        case loading(size: CGSize)
        case loaded(size: CGSize, posts: [RedditPost], moreAvailable: Bool)
        
        func with(size: CGSize) -> BackingState {
            switch self {
            case .loading:
                return .loading(size: size)
            case .loaded(_, let posts, let moreAvailable):
                return .loaded(size: size,
                               posts: posts,
                               moreAvailable: moreAvailable)
            }
        }
        
        func with(posts: [RedditPost], moreAvailable: Bool) -> BackingState {
            switch self {
            case .loading(let size), .loaded(let size, _, _):
                return .loaded(size: size,
                               posts: posts,
                               moreAvailable: moreAvailable)
            }
        }
        
        func materialize() -> State {
            switch self {
            case .loading: return .loading
            case .loaded(let size, let posts, let moreAvailable):
                let isNotEmpty = size.width > 0.0 && size.height > 0.0
                let nodes = isNotEmpty ? posts.map { SubredditPostTableViewNode(post: $0, width: size.width) } : []
                
                return .loaded(nodes: nodes,
                               moreAvailable: moreAvailable)
            }
        }
    }
    
    private var backingState: BackingState = .loading(size: .zero)
    
    enum State {
        case loading
        case loaded(nodes: [SubredditPostTableViewNode], moreAvailable: Bool)
    }
    
    init(api: RedditAPIType, request: RedditListingRequest) {
        paginator = SubredditPaginator(api: api, request: request)
        title = "Reddit · \(request.path)"
        state = subject
        paginator.posts
            .observe(on: queue)
            .subscribe(target: self, onNext: { $0.updatePosts($1) })
            .disposed(by: disposeBag)
    }
    
    let title: String
    let state: Observable<State>
    
    func didActivate() {
        if case .loading = backingState { reload() }
        else { self.materializeBackingState() }
    }
    
    func reload() {
        paginator.reload()
    }
    
    func loadNext() {
        paginator.loadNext()
    }
    
    func updateSize(_ size: CGSize) {
        self.backingState = backingState.with(size: size)
        self.materializeBackingState()
    }
    
    private func updatePosts(_ posts: [RedditPost]) {
        self.backingState = backingState.with(posts: posts, moreAvailable: paginator.hasNext)
        queue.async(execute: self.materializeBackingState)
    }
    
    private func materializeBackingState() {
        let materializedState = backingState.materialize()
        executeOnMain { self.subject.onNext(materializedState) }
    }
    
    private let disposeBag = DisposeBag()
}
