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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
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
    
    // When a Chat Room is selected by user, enter Chat Room.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let roomName = chatRooms[indexPath.row]
        
        if let vc = storyboard?.instantiateViewController(identifier: "ChatRoomVC") as? ChatRoomVC {
            vc.chatRoomName = roomName
            // Hide UITabBarItems in the new VC.
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
