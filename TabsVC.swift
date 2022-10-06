//
//  TabsVC.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/21/22.
//

import UIKit

class TabsVC: UITabBarController{
    
    @IBOutlet weak var myTabBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        myTabBar.layer.borderColor = UIColor.gray.cgColor
        myTabBar.layer.borderWidth = 0.5
    }

}
