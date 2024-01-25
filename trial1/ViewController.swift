import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the background color to white
        view.backgroundColor = UIColor.white

        // Add a label to display the text "reUSE"
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

        // Add a delay of 1 second and then navigate to OpeningScreen
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.navigateToOpeningScreen()
        }
    }

    func navigateToOpeningScreen() {
        // Create an instance of OpeningScreen
        let openingScreen = OpeningScreen()

        // Set the background color to white and make it opaque
        openingScreen.view.backgroundColor = UIColor.white.withAlphaComponent(1.0)

        // Push OpeningScreen onto the navigation stack
        navigationController?.pushViewController(openingScreen, animated: true)
    }
}
