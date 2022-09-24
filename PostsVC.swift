//
//  PostsVC.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/21/22.
//

import UIKit

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
    
    private let postsServiceQueue = DispatchQueue(label: "Posts service queue", qos: .default, attributes: [], autoreleaseFrequency: .inherit, target: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        
        // Start spinner.
        showSpinner()
        
        // Load posts.
        PostsService.listPosts(resultQueue: postsServiceQueue) { result in
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
    
    private func showSpinner() {
        activityIndicator.startAnimating()
        loadingView.isHidden = false
    }

    private func hideSpinner() {
        activityIndicator.stopAnimating()
        loadingView.isHidden = true
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
