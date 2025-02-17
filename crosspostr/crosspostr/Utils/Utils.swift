import SwiftUI

class Utils {
    static let shared: Utils = Utils()
    
    private init() {}
    
    // MARK: - UI Helpers
    
    /**
     Retrieves the root view controller of the application to present authentication flows with GoogleSignIn.
     
     - Returns: The currently visible `UIViewController`.
     */
    func getRootViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = scene.windows.first?.rootViewController else {
            return nil
        }
        return getVisibleViewController(from: rootViewController)
    }
    
    /**
     Recursively finds the top-most presented view controller.
     
     - Parameter vc: The root `UIViewController` to start searching from.
     - Returns: The currently presented `UIViewController`.
     */
    func getVisibleViewController(from vc: UIViewController) -> UIViewController {
        if let nav = vc as? UINavigationController {
            return getVisibleViewController(from: nav.visibleViewController!)
        }
        if let tab = vc as? UITabBarController {
            return getVisibleViewController(from: tab.selectedViewController!)
        }
        if let presented = vc.presentedViewController {
            return getVisibleViewController(from: presented)
        }
        return vc
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}
