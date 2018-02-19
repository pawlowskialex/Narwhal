//
//  SubredditViewController.swift
//  Reddit
//
//  Created by Alex Pawlowski on 2/16/18.
//  Copyright © 2018 Alex Pawlowski. All rights reserved.
//

import UIKit

// MARK: - SubredditViewController - Main

class SubredditViewController: UITableViewController {
    fileprivate var api: RedditAPIType!
    fileprivate var imageManager: ImageManagerType!
    fileprivate var request: RedditListingRequest!
    fileprivate var viewModel: SubredditViewModel!
    
    // MARK: - Views
    
    private let contentRefreshControl = UIRefreshControl()
    
    // MARK: - Implementation
    
    private var nodes: [SubredditPostTableViewNode] = []
    private var moreContentAvailable: Bool = true
    private var selectionDelegate: SubredditViewControllerSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = viewModel.title
        
        self.setupTableView()
        self.setupViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel.didActivate()
    }
    
    private func setupTableView() {
        selectionDelegate = SubredditViewControllerSelectionDelegate(controller: self,
                                                                     api: api,
                                                                     imageManager: imageManager)
        
        tableView.separatorStyle = .none
        tableView.isOpaque = true
        
        tableView.register(SubredditPostTableViewCell.self)
        tableView.register(SubredditImagedPostTableViewCell.self)
        tableView.register(SubredditLoaderFooterView.self)
        tableView.register(SubredditEmptyFooterView.self)
        
        contentRefreshControl.addTarget(self, action: #selector(beginRefreshing(sender:)),
                                        for: .valueChanged)
    }
    
    private func setupViewModel() {
        viewModel.state
            .subscribe(target: self, onNext: { $0.reload(with: $1) })
            .disposed(by: disposeBag)
        
        viewModel.updateSize(view.bounds.size)
    }
    
    private func reload(with state: SubredditViewModel.State) {
        switch state {
        case .loading:
            self.tableView.refreshControl = nil
            self.moreContentAvailable = true
            
        case .loaded(let nodes, let moreAvailable):
            self.tableView.refreshControl = contentRefreshControl
            self.nodes = nodes
            self.moreContentAvailable = moreAvailable
            self.contentRefreshControl.endRefreshing()
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Trait Transition
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in self.viewModel.updateSize(size) })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let node = nodes[indexPath.item]
        let cell: SubredditPostTableViewCell
        
        if node.layout.thumbnail.isEmpty {
            cell = tableView.dequeueReusableCell(with: SubredditPostTableViewCell.self,
                                                 for: indexPath)
        }
        else {
            let imagedCell = tableView.dequeueReusableCell(with: SubredditImagedPostTableViewCell.self,
                                                 for: indexPath)

            if let thumbnailURL = node.post.thumbnail {
                if let thumbnailImage = imageManager.image(for: thumbnailURL) {
                    imagedCell.thumbnailImage = thumbnailImage
                }
                else {
                    imagedCell.thumbnailObservable =
                        imageManager.downloadImage(at: thumbnailURL,
                                                   preprocessor: { $0.resized(to: node.layout.thumbnail.size) })
                }
            }

            cell = imagedCell
        }
    
        cell.node = node
        cell.delegate = selectionDelegate
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return nodes[indexPath.item].layout.height
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return moreContentAvailable ?
            tableView.dequeueReusableHeaderFooterView(with: SubredditLoaderFooterView.self) :
            tableView.dequeueReusableHeaderFooterView(with: SubredditEmptyFooterView.self)
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return nodes.isEmpty ? tableView.safeAreaLayoutGuide.layoutFrame.height : 100.0
    }
    
    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView,
                            willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        
        (cell as? SubredditImagedPostTableViewCell)?.subscribeThumbnail()
        
        if indexPath.item == nodes.index(before: nodes.endIndex) {
            viewModel.loadNext()
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            didEndDisplaying cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        
        (cell as? SubredditImagedPostTableViewCell)?.unsubscribeThumbnail()
    }
    
    // MARK: - Programmatic Instantiation
    
    init(api: RedditAPIType,
         imageManager: ImageManagerType,
         request: RedditListingRequest) {
        super.init(style: .grouped)
        self.api = api
        self.request = request
        self.imageManager = imageManager
        self.createViewModel()
        self.enableStateRestoration()
    }
    
    // MARK: - Storyboard Instantiation
    
    @IBInspectable var path: String = "best"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        api = inject(type: RedditAPIType.self,
                     responder: self,
                     fallback: RedditAPI.default)
        imageManager = inject(type: ImageManagerType.self,
                              responder: self,
                              fallback: ImageManager())
        request = RedditListingRequest(path: path)
        createViewModel()
        enableStateRestoration()
    }
    
    // MARK: - View Model Creation
    
    private func createViewModel() {
        viewModel = SubredditViewModel(api: api, request: request)
    }
    
    // MARK: - State Restoration Opt-in
    
    private func enableStateRestoration() {
        restorationIdentifier = encodeRestorationPath(request.path)
        restorationClass = SubredditViewController.self
    }
    
    private let disposeBag = DisposeBag()
}

// MARK: - SubredditViewController - UIRefreshControl

extension SubredditViewController {
    @objc fileprivate func beginRefreshing(sender: UIRefreshControl) {
        self.viewModel.reload()
    }
}

// MARK: - UIViewControllerRestoration

extension SubredditViewController: UIViewControllerRestoration {
    static func viewController(withRestorationIdentifierPath identifierComponents: [Any],
                               coder: NSCoder) -> UIViewController? {

        return identifierComponents.last
            .flatMap { $0 as? String }
            .flatMap(decodeRestorationPath)
            .map { SubredditViewController(api: inject(type: RedditAPIType.self,
                                                       responder: UIApplication.shared,
                                                       fallback: RedditAPI.default),
                                           imageManager: inject(type: ImageManagerType.self,
                                                                responder: UIApplication.shared,
                                                                fallback: ImageManager()),
                                           request: RedditListingRequest(path: $0))
        }
    }
}

// MARK - UIViewControllerRestoration - Encoding

private func encodeRestorationPath(_ path: String) -> String? {
    return path.data(using: .utf8).map { $0.base64EncodedString() }
}

private func decodeRestorationPath(_ path: String) -> String? {
    return Data(base64Encoded: path).flatMap { String(data: $0, encoding: .utf8) }
}
