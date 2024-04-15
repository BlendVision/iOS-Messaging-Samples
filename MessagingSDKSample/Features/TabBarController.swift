import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
        self.delegate = self
    }
    
    func setupViewControllers() {
        let firstVM = UserSettingViewModel(userIndex: 0)
        let firstVC = UINavigationController(rootViewController: UserSettingViewController(viewModel: firstVM))
        firstVC.tabBarItem.image = UIImage(systemName: "1.circle.fill")
        
        let secondVM = UserSettingViewModel(userIndex: 1)
        let secondVC = UINavigationController(rootViewController: UserSettingViewController(viewModel: secondVM))
        secondVC.tabBarItem.image = UIImage(systemName: "2.circle.fill")
        
        let thirdVM = UserSettingViewModel(userIndex: 3)
        let thirdVC = UINavigationController(rootViewController: UserSettingViewController(viewModel: thirdVM))
        thirdVC.tabBarItem.image = UIImage(systemName: "3.circle.fill")
        
        viewControllers = [firstVC, secondVC, thirdVC]
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        viewController != tabBarController.selectedViewController
    }
}
