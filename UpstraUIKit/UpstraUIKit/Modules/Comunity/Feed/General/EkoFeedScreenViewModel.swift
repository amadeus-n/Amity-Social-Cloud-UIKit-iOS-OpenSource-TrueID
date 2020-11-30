//
//  EkoFeedScreenViewModel.swift
//  UpstraUIKit
//
//  Created by Nontapat Siengsanor on 6/10/2563 BE.
//  Copyright © 2563 Upstra. All rights reserved.
//

import EkoChat

enum FeedViewModel {
    case post(EkoPostModel)
}

class EkoFeedScreenViewModel: EkoFeedScreenViewModelType {
    
    weak var delegate: EkoFeedScreenViewModelDelegate?
    
    private let feedRepository = EkoFeedRepository(client: UpstraUIKitManager.shared.client)
    private let fileRepository = EkoFileRepository(client: UpstraUIKitManager.shared.client)
    private let reactionRepository = EkoReactionRepository(client: UpstraUIKitManager.shared.client)
    private var feedCollection: EkoCollection<EkoPost>?
    private var feedToken: EkoNotificationToken?
    
    private var imageCache = EkoImageCache()
    private var viewModels: [FeedViewModel] = []
    let feedType: FeedType
    
    // MARK: - Initializer
    
    init(feedType: FeedType) {
        self.feedType = feedType
        setupCollection()
    }
    
    private func setupCollection() {
        switch feedType {
        case .globalFeed:
            feedCollection = feedRepository.getGlobalFeed()
        case .myFeed:
            feedCollection = feedRepository.getMyFeedSorted(by: .lastCreated, includeDeleted: false)
        case .userFeed(let userId):
            // If current userId is passing through .userFeed, handle this case as .myFeed type.
            if userId == UpstraUIKitManager.shared.client.currentUserId {
                feedCollection = feedRepository.getMyFeedSorted(by: .lastCreated, includeDeleted: false)
            } else {
                feedCollection = feedRepository.getUserFeed(userId, sortBy: .lastCreated, includeDeleted: false)
            }
        case .communityFeed(let communityId):
            feedCollection = feedRepository.getCommunityFeed(withCommunityId: communityId, sortBy: .lastCreated, includeDeleted: false)
        }
        
        feedToken?.invalidate()
        feedToken = feedCollection?.observe { [weak self] (collection, change, error) in
            guard collection.dataStatus == .fresh else { return }
            self?.prepareDataSource()
            Log.add("Feed collection error: \(String(describing: error))")
        }
    }
    
    private func prepareDataSource() {
        guard let collection = feedCollection else { return }
        var viewModels = [FeedViewModel]()
        for i in 0..<collection.count() {
            guard let post = collection.object(at: i) else { continue }
            let model = EkoPostModel(post: post)
            viewModels.append(.post(model))
        }
        self.viewModels = viewModels
        delegate?.screenViewModelDidUpdateData(self)
    }
    
    // MARK: - DataSource
    
    func numberOfItems() -> Int {
        return viewModels.count
    }
    
    func item(at indexPath: IndexPath) -> FeedViewModel {
        return viewModels[indexPath.row]
    }
    
    func loadNext() {
        guard let collection = feedCollection else { return }
        switch collection.loadingStatus {
        case .loaded:
            collection.nextPage()
        default:
            break
        }
    }
    
    func reloadData() {
        setupCollection()
    }
    
    // MARK: - Action
    
    func likePost(postId: String) {
        reactionRepository.addReaction("like", referenceId: postId, referenceType: .post, completion: nil)
    }
    
    func unlikePost(postId: String) {
        reactionRepository.removeReaction("like", referenceId: postId, referenceType: .post, completion: nil)
    }
    
    func deletePost(postId: String) {
        feedRepository.deletePost(withPostId: postId, parentId: nil) { _, _ in
            NotificationCenter.default.post(name: NSNotification.Name.Post.didCreate, object: nil)
        }
    }
    
    func likeComment(commentId: String) {
        reactionRepository.addReaction("like", referenceId: commentId, referenceType: .comment, completion: nil)
    }
    
    func unlikeComment(commentId: String) {
        reactionRepository.removeReaction("like", referenceId: commentId, referenceType: .comment, completion: nil)
    }
    
    func deleteComment(comment: EkoCommentModel) {
        let commentEditor = EkoCommentEditor(client: UpstraUIKitManager.shared.client, comment: comment.comment)
        commentEditor.delete(completion:  nil)
    }
    
    func editComment(comment: EkoCommentModel, text: String) {
        let commentEditor = EkoCommentEditor(client: UpstraUIKitManager.shared.client, comment: comment.comment)
        commentEditor.editText(text, completion: nil)
    }
    
}

// This is a simple NSCache based cache used for caching images. This might not be suitable for caching lots of images that we need to handle
// in UIKit. Please look into combining Disk & In-Memory based cache for optimizing performance.
class EkoImageCache {
    let cache = NSCache<AnyObject, AnyObject>()
    
    func getImage(key: String) -> UIImage? {
        let image = cache.object(forKey: key as AnyObject) as? UIImage
        return image
    }
    
    func setImage(key: String, value: UIImage) {
        cache.setObject(value, forKey: key as AnyObject)
    }
}