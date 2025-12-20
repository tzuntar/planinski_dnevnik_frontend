// sucks that this still isn't in the built-in libraries in the big 25

import UIKit

extension UIImageView {
    func loadFrom(URLAddress address: String) {
        guard let url = URL(string: address) else { return }

        DispatchQueue.global(qos: .background).async { [weak self] in
            if let imageData = try? Data(contentsOf: url) {
                if let loadedImage = UIImage(data: imageData) {
                    DispatchQueue.main.async { [weak self] in
                        self?.image = loadedImage
                    }
                }
            }
        }
    }
    
    func loadFrom(URLAddress address: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: address) else {
            completion(nil)
            return
        }
        DispatchQueue.global(qos: .background).async {
            if let imageData = try? Data(contentsOf: url) {
                if let loadedImage = UIImage(data: imageData) {
                    DispatchQueue.main.async { [weak self] in
                        self?.image = loadedImage
                        completion(loadedImage)
                    }
                }
            }
        }
    }
}

extension UITableViewCell {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)   // causes the view (or one of its embedded text fields) to
                                // resign the first responder status
    }
    
    func moveViewWithKeyboard(_ notification: Notification, viewBottomConstraint: NSLayoutConstraint, keyboardWillShow: Bool) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardAniDuration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let keyboardAniCurve = UIView.AnimationCurve(rawValue: notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! Int)!

        if keyboardWillShow {
            // necessary because older iPhones don't have a defined safe area
            let safeAreaExists = (view?.window?.safeAreaInsets.bottom != 0)
            let bottomConstant: CGFloat = 20
            viewBottomConstraint.constant = keyboardSize.height + (safeAreaExists ? 0 : bottomConstant)
        } else {
            viewBottomConstraint.constant = 20
        }

        let animator = UIViewPropertyAnimator(duration: keyboardAniDuration, curve: keyboardAniCurve) { [weak self] in
            self?.view.layoutIfNeeded() // update constraints
        }

        animator.startAnimation()
    }
}
