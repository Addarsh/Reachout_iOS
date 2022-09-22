//
//  ChatsVC.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/21/22.
//

import UIKit

class ChatsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    // Chat Room names on the page.
    var chatRooms: [String] = ["abc, def", "hello, everyone", "xyz, share", "asdaisjdasldalsjdlajdlajdljadljaldjaldjslajdlsajdlsajdlasj"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.white
    }
}

extension ChatsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chatRoomName = chatRooms[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoomTableViewCell") as! ChatRoomTableViewCell
        
        cell.setName(name: chatRoomName)
        
        return cell
    }
    
}
