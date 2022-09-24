//
//  PostsVC.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/21/22.
//

import UIKit

class PostsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    // Posts on the page.
    var posts: [Post] = [Post(title: "First Post", message: "hi there, want to chat?"), Post(title: "Second Post", message: "Want to connect."), Post(title: "Third Post", message: "contact me")]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
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
        
        cell.setMessage(title: post.title, message: post.message, postedBy: "addarsh", postTime: "2 mins ago")
        
        return cell
    }
}
