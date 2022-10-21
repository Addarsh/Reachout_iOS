//
//  UserAccountVC.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/30/22.
//

import UIKit

class UserAccountVC: UIViewController {
    
    enum ActionType: String {
        case Feedback
        case Logout
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emailTitle: UILabel!
    
    let options: [ActionType] = [.Feedback, .Logout]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        
        // Fetch email.
        guard let email = KeychainHelper.read(service: KeychainHelper.EMAIL, account: KeychainHelper.REACHOUT) else {
            print("Could not read email from keychain")
            // TODO: Ask user to login again.
            return
        }
        
        DispatchQueue.main.async {
            self.emailTitle.text = email
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}

extension UserAccountVC: UITableViewDataSource, UITableViewDelegate {
    // Sets cell row height.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    // Called everytime a cell appears and it will display the data in that cell.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = options[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserAccountTableViewCell") as! UserAccountTableViewCell
        
        cell.setMessage(title: option.rawValue)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let actionType = options[indexPath.row]
        switch actionType {
        case ActionType.Feedback:
            provideFeedback()
        case ActionType.Logout:
            logout()
        }
    }
    
    // Provide app feedback.
    private func provideFeedback() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FeedbackVC") as! FeedbackVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    // Logs a user out.
    private func logout() {
        // Delete token, userId and email and go to login screen.
        KeychainHelper.delete(service: KeychainHelper.TOKEN, account: KeychainHelper.REACHOUT)
        KeychainHelper.delete(service: KeychainHelper.USER_ID, account: KeychainHelper.REACHOUT)
        KeychainHelper.delete(service: KeychainHelper.EMAIL, account: KeychainHelper.REACHOUT)
        KeychainHelper.delete(service: KeychainHelper.USERNAME, account: KeychainHelper.REACHOUT)
        KeychainHelper.delete(service: KeychainHelper.EMAIL_VERIFIED, account: KeychainHelper.REACHOUT)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}
