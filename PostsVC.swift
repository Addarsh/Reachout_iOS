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
    
    // Posts on the page.
    var posts: [Post] = []
    
    private let headerHeight: CGFloat = 150
    
    private let postsServiceQueue = DispatchQueue(label: "Posts service queue", qos: .default, attributes: [], autoreleaseFrequency: .inherit, target: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        
        // Start spinner.
        showSpinner()
        
        fetchLatestPosts()
    }
    
    // Fetch latest posts from server.
    private func fetchLatestPosts() {
        // Fetch token.
        guard let token = KeychainHelper.read(service: KeychainHelper.TOKEN, account: KeychainHelper.REACHOUT) else {
            print("Could not read token from keychain")
            // TODO: Ask user to login again.
            return
        }
        
        // Load posts.
        PostsService.listPosts(token: token, resultQueue: postsServiceQueue) { result in
            switch result {
            case .success(let gotPosts):
                self.posts = gotPosts
                DispatchQueue.main.async {
                    self.hideSpinner()
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
        vc.postsDelegate = self
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
        let post = posts[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as! PostTableViewCell
        
        let postTime = Utils.durationFromNow(date: Utils.getDate(isoDate: post.created_time))
        cell.setMessage(title: post.title, message: post.description, postedBy: post.username, postTime: postTime)
        
        return cell
    }
}

extension PostsVC: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension PostsVC: PostsDelegate {
    func reloadPosts() {
        fetchLatestPosts()
    }
}
