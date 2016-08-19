//
//  AccountRootVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/18/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class AccountRootVC: UIViewController {
    
    var profileView: ProfileViewVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileView = storyboard?.instantiateViewControllerWithIdentifier("profileViewVC") as? ProfileViewVC
        
        profileView?.derpibooru = Derpibooru()
        profileView?.profileName = NSUserDefaults.standardUserDefaults().stringForKey("username")
        
        if profileView != nil {
            addChildViewController(profileView!)
            view.addSubview(profileView!.view)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}



