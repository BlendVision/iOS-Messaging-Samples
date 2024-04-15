//
//  BasicInterfaces.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/2/20.
//

import Foundation
import UIKit

// View

protocol ViewInterface: AnyObject { }

// Interactor

protocol InteractorInterface: AnyObject { }

// Presenter

protocol PresenterInterface: AnyObject { }

// Router

protocol RouterInterface: AnyObject {
    var viewController: UIViewController? { get set }
}

extension RouterInterface {
    var navigationController: UINavigationController? {
        return viewController?.navigationController
    }
    
    func present(_ router: RouterInterface, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let vc = router.viewController else { return }
        viewController?.present(vc, animated: animated, completion: completion)
    }
    
    func push(_ router: RouterInterface, animated: Bool = true) {
        guard let vc = router.viewController else { return }
        navigationController?.pushViewController(vc, animated: animated)
    }
}
