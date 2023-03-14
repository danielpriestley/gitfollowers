import UIKit

class UserInfoVC: UIViewController {
    
    var username: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: View configuration
        view.backgroundColor = .systemBackground
        
        // Establish a bar button item, and then assign it to the navigation item.
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        navigationItem.rightBarButtonItem = doneButton
        print(username!)
    }
    
    @objc func dismissVC() {
        dismiss(animated: true)
    }
}

