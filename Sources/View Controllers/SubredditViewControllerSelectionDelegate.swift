//
//  SubredditViewControlleSelectionDelegate.swift
//  Reddit
//
//  Created by Alex Pawlowski on 2/18/18.
//  Copyright © 2018 Alex Pawlowski. All rights reserved.
//

import Foundation
import SafariServices

class SubredditViewControllerSelectionDelegate: SubredditPostCellSelectionDelegate {
    private weak var controller: SubredditViewController?
    private let api: RedditAPIType
    private let imageManager: ImageManagerType
    
    init(controller: SubredditViewController, api: RedditAPIType, imageManager: ImageManagerType) {
        self.controller = controller
        self.api = api
        self.imageManager = imageManager
    }
    
    func cell(_ cell: SubredditPostTableViewCell,
              didSelectContentItem item: SubredditPostCellContentItem) {
        
        guard let navigationController = controller?.navigationController
            else { return }
        
        // Global tint is messed up
        let tintColor = UIColor.black
        
        switch item {
        case .post(let post):
            let webController = SFSafariViewController(url: post.url)
            webController.preferredControlTintColor = tintColor
            navigationController.present(webController, animated: true, completion: nil)
            
        case .subreddit(let path):
            let subredditController = SubredditViewController(api: api,
                                                              imageManager: imageManager,
                                                              request: RedditListingRequest(path: path))
            navigationController.pushViewController(subredditController, animated: true)
            
        case .preview(let url):
            let webController = SFSafariViewController(url: url)
            webController.preferredControlTintColor = tintColor
            navigationController.present(webController, animated: true, completion: nil)
        }
    }
}
