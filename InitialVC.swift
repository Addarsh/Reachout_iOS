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
        // Check if user token exists.
        if KeychainHelper.read(service: KeychainHelper.TOKEN, account: KeychainHelper.REACHOUT) == nil {
            // User has not signed up/login yet. Do nothing.
            return
        }
        
        var gotoVC = ""
        if KeychainHelper.read(service: KeychainHelper.EMAIL_VERIFIED, account: KeychainHelper.REACHOUT) == nil {
            // User has not verified email yet.
            gotoVC = "VerifyEmailVC"
        } else if KeychainHelper.read(service: KeychainHelper.USERNAME, account: KeychainHelper.REACHOUT) == nil {
            // User has not created Username yet.
            gotoVC = "CreateUsernameVC"
        } else {
            // User is logged in. Go to TabsVC.
            gotoVC = "TabsVC"
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: gotoVC)
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
