//
//  InitialVC.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/21/22.
//

import UIKit

class InitialVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Check if user is logged in. If so, transfer to Posts VC directly.
        guard let username = KeychainHelper.read(service: KeychainHelper.USERNAME, account: KeychainHelper.REACHOUT) else {
            // Token not found. Do nothing.
            return
        }
        
        // If username is empty, set username first else go to Tabs view.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vcId = username != "" ? "TabsVC" : "CreateUsernameVC"
        let vc = storyboard.instantiateViewController(withIdentifier: vcId)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    @IBAction func login() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }

}
