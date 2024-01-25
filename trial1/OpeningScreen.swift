import UIKit
import GoogleSignIn

class OpeningScreen: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide the back button in the navigation bar
        navigationItem.hidesBackButton = true

        // Create a label to display the text
        let label = UILabel()
        label.text = "reUSE"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24)

        // Add the label to the view
        view.addSubview(label)

        // Set up constraints for the label if needed
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        // Set the background color to white and make it opaque
        view.backgroundColor = UIColor.white.withAlphaComponent(1.0)

        // Add Sign in with Google button
                let googleSignInButton = GIDSignInButton()
                googleSignInButton.style = .wide
                googleSignInButton.addTarget(self, action: #selector(handleSignInButton), for: .touchUpInside)
                view.addSubview(googleSignInButton)

                // Set up constraints for the button if needed
                googleSignInButton.translatesAutoresizingMaskIntoConstraints = false
                googleSignInButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20).isActive = true
                googleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
            }

            @objc func handleSignInButton() {
                GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
                    guard signInResult != nil else {
                        // Inspect error
                        print("Error signing in: \(error?.localizedDescription ?? "")")
                        return
                    }

                    // If sign-in succeeded, create and push the new view controller
                    let newViewController = ItemsPage() // Replace with the actual class name of your new view controller
                    self.navigationController?.pushViewController(newViewController, animated: true)
                }
            }
        }
