import UIKit
import GoogleSignIn
import GoogleAPIClientForREST

class ItemsPage: UIViewController {

    var titleLabel: UILabel!
    var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        view.backgroundColor = .white

        // Create a UIScrollView
        scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        view.addSubview(scrollView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        // Add title label to the scrollView
        addTitleLabel(to: scrollView)

        // Fetch data from Google Sheets API and update the labels
        fetchDataAndUpdateLabels()

        // Set the content size of the scrollView after adding the title
        scrollView.contentSize = CGSize(width: view.frame.width, height: titleLabel.frame.origin.y + titleLabel.frame.size.height + 20)

        // Bring the title label to the front
        scrollView.bringSubviewToFront(titleLabel)
    }

    func addTitleLabel(to scrollView: UIScrollView) {
        titleLabel = UILabel()
        titleLabel.text = "ReUse Online Store"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        scrollView.addSubview(titleLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20), // Adjust the top margin as needed
            titleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
        ])
    }


    func fetchDataAndUpdateLabels() {
        // Set up Google Sheets API service with API key
        let service = GTLRSheetsService()
        service.apiKey = "AIzaSyDs-xXKWMZlUXwCDPgN-9A945l6wtie_qA"  // Replace with your actual API key

        // Specify the spreadsheet ID and range
        let spreadsheetId = "1Bi6M8urGGxh0aEsQqsAEnVYNyc_MfvzF_RcbtE2xf-U" // Your spreadsheet ID
        let range = "Sheet1!A1:E"  // Adjust the sheet name and range

        // Make the API request
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadsheetId, range: range)
        service.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            // Handle the result and update the labels
            if let values = (result as? GTLRSheets_ValueRange)?.values {
                // Filter non-empty rows
                let nonEmptyRows = values.filter { row in
                    return row.compactMap { $0 as? String }.contains { !$0.isEmpty }
                }

                // Join and display the filtered rows
                let joinedValues = nonEmptyRows.map { row in
                    row.map { "\($0)" }.joined(separator: ", ")
                }.joined(separator: "\n")

                DispatchQueue.main.async {
                    // Update the labels with the fetched data
                    self.updateLabels(with: joinedValues)
                }
            }
        }
    }

    func updateLabels(with text: String) {
        // Create a UIScrollView
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        view.addSubview(scrollView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])


        // Split the text into rows
        let rows = text.components(separatedBy: "\n")

        // Calculate box dimensions and padding
        let padding: CGFloat = 10
        let boxSize = (min(view.frame.width, view.frame.height) - 3 * padding) / 2

        var offset: CGFloat = titleLabel.frame.origin.y + titleLabel.frame.size.height + 20  // Adjust the gap as needed

        for (index, row) in rows.enumerated() {
            // Split each row into columns
            let columns = row.components(separatedBy: ", ")

            // Check if the row has at least four columns (including column E)
            guard columns.count >= 4 else {
                continue
            }

            // Extract the URL from the first column
            guard let imageUrl = URL(string: columns[0]),
                  let imageData = try? Data(contentsOf: imageUrl),
                  let image = UIImage(data: imageData) else {
                continue  // Skip the row if URL or image data is invalid
            }

            // Create a UIView for each row
            let rowView = UIView()
            rowView.backgroundColor = .clear
            scrollView.addSubview(rowView)

            // Create an image view for the background
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            rowView.addSubview(imageView)

            // Add a tap gesture recognizer to each rowView
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            rowView.addGestureRecognizer(tapGesture)

            // Create labels for columns B, C, D, and E
            let labelB = UILabel()
            let labelC = UILabel()
            let labelD = UILabel()
            let labelE = UILabel()

            // Assuming B is at index 1, D is at index 3
            let textB = columns[1]
            let textD = columns[3]

            // Create attributed strings for labels B and D
            let attributedTextB = NSMutableAttributedString(string: (textB), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)])
            let attributedTextD = NSMutableAttributedString(string: (textD), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)])

            labelB.attributedText = attributedTextB
            labelC.text = columns[2] // Assuming C is at index 2
            labelD.attributedText = attributedTextD
            labelE.text = columns[4] // Assuming E is at index 4
            
            labelE.text = columns[4] // Assuming E is at index 4
            labelE.numberOfLines = 0 // Allow multiple lines
            labelE.lineBreakMode = .byWordWrapping // Wrap by word

            // Set tags to identify labels
            labelB.tag = 1
            labelC.tag = 2
            labelD.tag = 3
            labelE.tag = 4

            // Add labels to rowView
            rowView.addSubview(labelB)
            rowView.addSubview(labelC)
            rowView.addSubview(labelD)
            rowView.addSubview(labelE)

            // Set up constraints for labels B, C, D
            labelB.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                labelB.leadingAnchor.constraint(equalTo: rowView.leadingAnchor, constant: 8), // Add a gap of 8 points (adjust as needed)
                labelB.topAnchor.constraint(equalTo: rowView.topAnchor, constant: 8), // Add a gap of 8 points (adjust as needed)
                labelB.widthAnchor.constraint(equalTo: rowView.widthAnchor, multiplier: 0.33)
            ])

            labelC.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                labelC.leadingAnchor.constraint(equalTo: rowView.leadingAnchor, constant: 8), // Add a gap of 8 points (adjust as needed)
                labelC.topAnchor.constraint(equalTo: labelB.bottomAnchor),
                labelC.widthAnchor.constraint(equalTo: rowView.widthAnchor, multiplier: 0.33)
            ])

            labelD.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                labelD.leadingAnchor.constraint(equalTo: labelB.trailingAnchor, constant: 8), // Align with labelB's trailing with a gap of 8 points (adjust as needed)
                labelD.topAnchor.constraint(equalTo: rowView.topAnchor, constant: 8), // Add a gap of 8 points (adjust as needed)
                labelD.widthAnchor.constraint(equalTo: rowView.widthAnchor, multiplier: 0.33)
            ])

            // Set up constraints for the image view
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: rowView.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: rowView.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: rowView.trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: rowView.bottomAnchor)
            ])

            // Set up constraints for the rowView
            rowView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                rowView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: offset + padding),
                rowView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: (index % 2 == 0) ? padding : boxSize + 2 * padding),
                rowView.widthAnchor.constraint(equalToConstant: boxSize),
                rowView.heightAnchor.constraint(equalToConstant: boxSize)
            ])

            if index % 2 == 1 {
                offset += boxSize + padding
            }
        }

        // Set the content size of the scrollView to fit all rowViews
        scrollView.contentSize = CGSize(width: view.frame.width, height: offset + boxSize + 2 * padding)
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let tappedRowView = gesture.view else {
            return
        }

        // Extract the image from the tapped rowView
        if let imageView = tappedRowView.subviews.compactMap({ $0 as? UIImageView }).first,
            let tappedImage = imageView.image {

            // Assuming you have labels tagged as 1, 2, 3 for B, C, D
            let labelB = tappedRowView.viewWithTag(1) as? UILabel
            let labelD = tappedRowView.viewWithTag(3) as? UILabel
            let labelE = tappedRowView.viewWithTag(4) as? UILabel

            // Ensure all labels are non-nil
            guard let unwrappedLabelB = labelB?.text,
                  let unwrappedLabelD = labelD?.text else {
                return
            }

            // Extract the full content of column 4
            let fullTextColumn4: String
            if let attributedText = labelE?.attributedText {
                let range = NSRange(location: 0, length: attributedText.length)
                fullTextColumn4 = (attributedText.string as NSString).substring(with: range)
            } else {
                fullTextColumn4 = labelE?.text ?? ""
            }

            // Create a pop-up view controller to display the larger image
            let popUpViewController = PopUpViewController(image: tappedImage, textB: unwrappedLabelB, textD: unwrappedLabelD, textE: fullTextColumn4)
            present(popUpViewController, animated: true, completion: nil)
        }
    }
}
