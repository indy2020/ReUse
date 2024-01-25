import UIKit
import GoogleSignIn
import GoogleSignInSwift
import GoogleAPIClientForREST
import MessageUI
import GTMAppAuth
import GTMSessionFetcher



class PopUpViewController: UIViewController {

    private let imageView = UIImageView()
    private let labelBD = UILabel()
    private let labelE = UILabel()
    private let labelB = UILabel()
    private var getItemButton: UIButton!
    private var textField: UITextField?
    private var messageLabel: UILabel?

    private var userText: String?

    init(image: UIImage, textB: String, textD: String, textE: String) {
        super.init(nibName: nil, bundle: nil)
        imageView.image = image
        labelB.text = textB
        labelBD.text = "\(textB) \(textD)"
        labelE.text = textE
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the pop-up view
        view.backgroundColor = UIColor.white

        // Add the image view to the pop-up view
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)

        // Add the labels for columns B and D
        labelBD.textAlignment = .left  // Ensure left alignment
        labelBD.numberOfLines = 0
        labelBD.textColor = .black
        labelBD.font = UIFont.boldSystemFont(ofSize: 18)  // Set bold and increased font size
        view.addSubview(labelBD)

        // Add the label for column E
        labelE.textAlignment = .left  // Ensure left alignment
        labelE.numberOfLines = 0
        labelE.textColor = .black
        view.addSubview(labelE)

        // Set up constraints for the image view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])

        // Set up constraints for the labels
        labelBD.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            labelBD.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            labelBD.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            labelBD.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])

        labelE.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            labelE.topAnchor.constraint(equalTo: labelBD.bottomAnchor, constant: 20),
            labelE.leadingAnchor.constraint(equalTo: labelBD.leadingAnchor),
            labelE.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            labelE.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -20)
        ])

        // Add "Get Item" button
        getItemButton = UIButton(type: .system)
        getItemButton.setTitle("Get Item", for: .normal)
        getItemButton.backgroundColor = .blue
        getItemButton.setTitleColor(.white, for: .normal)
        getItemButton.addTarget(self, action: #selector(getItemButtonClicked), for: .touchUpInside)
        getItemButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(getItemButton)

        // Set up constraints for the "Get Item" button
        NSLayoutConstraint.activate([
            getItemButton.topAnchor.constraint(equalTo: labelE.bottomAnchor, constant: 20),
            getItemButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            getItemButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            getItemButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        // Add a tap gesture recognizer to dismiss the pop-up view when tapped
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopUp))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func getItemButtonClicked() {
        // Hide the "Get Item" button
        getItemButton.isHidden = true

        // Create a new UITextField
        textField = UITextField()
        textField?.borderStyle = .roundedRect
        textField?.placeholder = "Please Provide a Name for Pickup"
        textField?.translatesAutoresizingMaskIntoConstraints = false
        textField?.delegate = self // Set the delegate to handle text field events
        view.addSubview(textField!)

        // Set up constraints for the UITextField
        NSLayoutConstraint.activate([
            textField!.topAnchor.constraint(equalTo: labelE.bottomAnchor, constant: 20),
            textField!.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField!.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textField!.heightAnchor.constraint(equalToConstant: 40)
        ])

        // Add a target action for the "Return" key
        textField?.addTarget(self, action: #selector(textFieldReturnPressed), for: .editingDidEndOnExit)
    }

    @objc func textFieldReturnPressed() {
        // Hide the text field
        textField?.isHidden = true

        // Display the message label
        messageLabel = UILabel()
        messageLabel?.text = "Please visit the ReUse store to pickup your item."
        messageLabel?.textColor = .systemGray
        messageLabel?.numberOfLines = 0
        messageLabel?.textAlignment = .center
        messageLabel?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageLabel!)

        // Set up constraints for the message label
        NSLayoutConstraint.activate([
            messageLabel!.topAnchor.constraint(equalTo: labelE.bottomAnchor, constant: 20),
            messageLabel!.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageLabel!.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            messageLabel!.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -20)
        ])

        // Handle the text field submission here
        if let userText = textField?.text,
           let textB = labelB.text {
            print("User input: \(userText)")

            // Call the function to update the spreadsheet
            updateSpreadsheet(userText: userText, textB: textB)
        }
    }

    func updateSpreadsheet(userText: String, textB: String) {
        // Replace these values with your own
        let spreadsheetId = "1Bi6M8urGGxh0aEsQqsAEnVYNyc_MfvzF_RcbtE2xf-U"
        let range = "Sheet1"  // Update with your sheet name
        let serviceAccountKeyPath = "reuse-409205-8258401fcf4c.json"  // Update with the actual path

        // Load the service account key JSON data
            guard let serviceAccountData = try? Data(contentsOf: URL(fileURLWithPath: serviceAccountKeyPath)) else {
                print("Error loading service account key data.")
                return
            }

            do {
                // Parse the service account key JSON data
                if let serviceAccount = try JSONSerialization.jsonObject(with: serviceAccountData, options: []) as? [String: Any] {
                    // Use service account credentials to authorize requests
                    let authorization = GTMAppAuthFetcherAuthorization()

                    // Set up the service with the credentials
                    let service = GTLRSheetsService()
                    service.authorizer = authorization

                    // Create the update request
                    let updateRequest = GTLRSheets_ValueRange()
                    updateRequest.values = [["", "", "", "", "", userText]] // Assuming there are 5 columns before column F

                    // Execute the update request on the main thread
                    DispatchQueue.main.async {
                        let query = GTLRSheetsQuery_SpreadsheetsValuesUpdate.query(withObject: updateRequest, spreadsheetId: spreadsheetId, range: range)
                        query.valueInputOption = "RAW"
                        service.executeQuery(query) { (ticket, result, error) in
                            if let error = error {
                                print("Error updating spreadsheet: \(error.localizedDescription)")
                            } else {
                                print("Spreadsheet updated successfully!")
                            }
                        }
                    }
                } else {
                    print("Error parsing service account key JSON")
                }
            } catch {
                print("Error parsing service account key data: \(error.localizedDescription)")
            }
        }
       

    @objc func dismissPopUp() {
        dismiss(animated: true, completion: nil)
    }
}

extension PopUpViewController: UITextFieldDelegate {
    // Implement any UITextFieldDelegate methods as needed
}
