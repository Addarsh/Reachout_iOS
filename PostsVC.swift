//
//  PostsVC.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/21/22.
//

import UIKit

protocol PostsDelegate {
    func reloadPosts()
}

class PostsVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var loadingView: UIView! {
        didSet {
            loadingView.layer.cornerRadius = 6
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var pullControl = UIRefreshControl()
    
    private var userId: String = ""
    
    // To ensure we don't send multiple requests while posts are still loading.
    private var postsLoadingBottom = false
    
    // To stop loading posts when user scrolls to the bottom and already has oldest post in memory.
    private var noMorePostsToLoad = false
    
    // Posts on the page.
    var posts: [PostsService.Post] = []
    
    private let headerHeight: CGFloat = 150
    
    private var authToken: String = ""
    
    private let postsServiceQueue = DispatchQueue(label: "Posts service queue", qos: .default, attributes: [], autoreleaseFrequency: .inherit, target: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        
        pullControl.attributedTitle = NSAttributedString(string: "Fetching Posts")
        pullControl.tintColor = UIColor.systemBlue
        pullControl.addTarget(self, action: #selector(pulledRefreshControl(_:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(pullControl)

        
        // Fetch user_id.
        guard let userId = KeychainHelper.read(service: KeychainHelper.USER_ID, account: KeychainHelper.REACHOUT) else {
            print("Could not read user_id from keychain")
            // TODO: Ask user to login again.
            return
        }
        self.userId = userId
        
        guard let token = KeychainHelper.read(service: KeychainHelper.TOKEN, account: KeychainHelper.REACHOUT) else {
            print("Could not read token from keychain")
            // TODO: Ask user to login again.
            return
        }
        self.authToken = token
    }
    
    @objc func pulledRefreshControl(_ sender:AnyObject) {
        fetchLatestPosts()

        pullControl.endRefreshing()
    }
    
    @objc private func appMovedToForeground() {
        // Start spinner.
        showSpinner()
        
        fetchLatestPosts()
    }
    
    // Start timer when view appears.
    override func viewWillAppear(_ animated: Bool) {
        // Start spinner.
        showSpinner()
        
        fetchLatestPosts()
    }
    
    // Handler for the fetch posts periodic timer.
    @objc func fetchPostsHandler() {
        fetchLatestPosts()
    }
    
    // Fetch latest posts from server.
    private func fetchLatestPosts() {
        // Reset variables.
        self.noMorePostsToLoad = false
        self.postsLoadingBottom = false
        
        // Load posts.
        PostsService.listPosts(token: self.authToken, createdTime: nil, resultQueue: postsServiceQueue) { result in
            DispatchQueue.main.async {
                self.hideSpinner()
            }
            
            switch result {
            case .success(let gotPosts):
                self.posts = gotPosts
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("list Posts failed with error: \(error.localizedDescription)")
            }
        }
    }
    
    // Show loading spinner.
    private func showSpinner() {
        activityIndicator.startAnimating()
        loadingView.isHidden = false
    }

    // Hide loading spinner.
    private func hideSpinner() {
        activityIndicator.stopAnimating()
        loadingView.isHidden = true
    }
    
    
    @IBAction func goToAccount(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserAccountVC")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    @IBAction func createPost(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CreatePostVC") as! CreatePostVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
}

extension PostsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    // Called everytime a cell appears and it will display the data in that cell.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !noMorePostsToLoad && indexPath.row + 1 == posts.count && !postsLoadingBottom {
            postsLoadingBottom = true
            // End of table. fetch the next set of posts.
            oldestCreationDate()
        }
        
        let post = posts[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as! PostTableViewCell
        
        let postTime = Utils.durationFromNow(date: Utils.getDate(isoDate: post.created_time))
        
        cell.setMessage(title: post.title, message: post.description, postedBy: post.username, postTime: postTime, hideDeleteButton: userId != post.creator_user, hideChatButton: userId == post.creator_user, rowIndex: indexPath.row, postTableActionDelegate: self)
        
        return cell
    }
    
    private func oldestCreationDate() {
        // Posts in decreasing order of creation time.
        if let lastPost = posts.last {
            fetchNextPosts(createdTime: lastPost.created_time)
        }
    }
    
    // Fetch next set of posts from server.
    private func fetchNextPosts(createdTime: String) {
        self.showSpinner()
        
        // Fetch token.
        guard let token = KeychainHelper.read(service: KeychainHelper.TOKEN, account: KeychainHelper.REACHOUT) else {
            print("Could not read token from keychain")
            // TODO: Ask user to login again.
            return
        }
        
        // Load posts.
        PostsService.listPosts(token: token, createdTime: createdTime, resultQueue: postsServiceQueue) { result in
            DispatchQueue.main.async {
                self.hideSpinner()
            }
            
            switch result {
            case .success(let gotPosts):
                self.posts = self.posts + gotPosts
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    if gotPosts.count == 0 {
                        self.noMorePostsToLoad = true
                    }
                    self.postsLoadingBottom = false
                }
            case .failure(let error):
                print("list next Posts failed with error: \(error.localizedDescription)")
            }
        }
    }
}

extension PostsVC: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension PostsVC: PostTableActionDelegate {
    
    func didStartChat(rowIndex: Int) {
        // Check if chat room already exists.
        self.showSpinner()
        
        // Load posts.
        let post = posts[rowIndex]
        ChatService.chatRoomAlreadyExists(otherUserId: post.creator_user, token: self.authToken, resultQueue: postsServiceQueue) { result in
            DispatchQueue.main.async {
                self.hideSpinner()
            }
            
            switch result {
            case .success(let chatRoomExists):
                if !chatRoomExists.exists {
                    DispatchQueue.main.async {
                        // Start a new chat.
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "StartChatVC") as! StartChatVC
                        vc.postOfCreator = post
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true)
                    }
                } else {
                    self.goToExistingChatRoom(roomId: chatRoomExists.room_id)
                }
            case .failure(let error):
                print("list next Posts failed with error: \(error.localizedDescription)")
            }
        }
    }
    
    // Fetch and go to existing chat room.
    private func goToExistingChatRoom(roomId: String) {
        ChatService.getChatRoom(roomId: roomId, token: self.authToken, resultQueue: postsServiceQueue) { result in
            DispatchQueue.main.async {
                self.hideSpinner()
            }
            
            switch result {
            case .success(let gotChatRoom):
                
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "ChatRoomVC") as! ChatRoomVC
                    vc.setRoom(chatRoom: gotChatRoom)
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            case .failure(let error):
                print("Reload Chat Room failed with error: \(error.localizedDescription)")
            }
        }
    }
    
    func didDeletePost(rowIndex: Int) {
        // Delete Post.
        guard let token = KeychainHelper.read(service: KeychainHelper.TOKEN, account: KeychainHelper.REACHOUT) else {
            print("Could not read token from keychain")
            // TODO: Ask user to login again.
            return
        }
        
        let postId = self.posts[rowIndex].id
        
        showSpinner()
        
        // Delete post.
        PostsService.deletePost(id: postId, token: token, resultQueue: postsServiceQueue) { result in
            DispatchQueue.main.async {
                self.hideSpinner()
            }
            switch result {
            case .success(_):
                self.fetchLatestPosts()
            case .failure(let error):
                print("list Posts failed with error: \(error.localizedDescription)")
            }
        }
    }
}
