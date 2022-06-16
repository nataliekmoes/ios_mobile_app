//
//  AccountViewController.swift
//  CSE335_Project
//

import UIKit
import GoogleSignIn


class AccountViewController: UIViewController {
    
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileEmail: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    var googleSignIn = GIDSignIn.sharedInstance
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        profileName.text = googleSignIn.currentUser?.profile?.name
        profileEmail.text = googleSignIn.currentUser?.profile?.email
        if googleSignIn.currentUser?.profile?.hasImage == true {
            profileImage.load(url: (googleSignIn.currentUser?.profile?.imageURL(withDimension: 240))!)
            
            
        }
    }
    
    
    
    @IBAction func googleSignOut(_ sender: Any) {
        
        self.googleSignIn.signOut()
        
        // return to Login screen
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavigationController = storyboard.instantiateViewController(identifier: "LoginNavigationController")
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavigationController)
        print("Signed user out - displaying LoginNavigationController")
    }
    
    
    
    @IBAction func removeAccount(_ sender: Any) {
        
        self.googleSignIn.disconnect() { error in
            if error == nil {
                // return to sign in view
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginNavigationController = storyboard.instantiateViewController(identifier: "LoginNavigationController")
                
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavigationController)
                print("Removed user account - displaying LoginNavigationController")
            }
            else { print(error.debugDescription) }
        }
    }
}

    extension UIImageView {
        func load(url: URL) {
            DispatchQueue.global().async {
                [weak self] in
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.image = image
                        }
                    }
                }
            }
        }
}
