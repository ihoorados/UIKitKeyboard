//
//  TabBarViewController.swift
//  UIKitKeyboard
//
//  Created by Hoorad on 12/31/24.
//


import UIKit

class ReaboardTabBarVC: UITabBarController, UITabBarControllerDelegate{

    let homeVC: AuthenticationViewController
    let aboutVC: AuthenticationViewController
    
    init(){
        
        self.homeVC = AuthenticationViewController()
        self.aboutVC = AuthenticationViewController()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: app life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        UITabBar.appearance().barTintColor = .systemBackground
        tabBar.tintColor = .systemYellow
        setupVCs()
        delegate = self
    }
    
    func setupVCs() {
          viewControllers = [
            
            createNavController(for: homeVC,
                                title: NSLocalizedString("Login", comment: ""),
                                image: UIImage(systemName: "tornado")!),
            createNavController(for: aboutVC,
                                  title: NSLocalizedString("Form", comment: ""),
                                  image: UIImage(systemName: "square.stack")!),
          ]
    }
    
    fileprivate func createNavController(for rootViewController: UIViewController,
                                                      title: String,
                                                      image: UIImage) -> UIViewController {
        
        rootViewController.navigationItem.title = title
        rootViewController.navigationItem.largeTitleDisplayMode = .always
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        navController.navigationBar.prefersLargeTitles = true
        let attrs = [NSAttributedString.Key.foregroundColor: .label,
                     NSAttributedString.Key.backgroundColor : UIColor.clear]
        navController.navigationBar.largeTitleTextAttributes = attrs
        return navController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // UITabBarControllerDelegate method
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        //print("Selected \(viewController.title)")
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    }
}
