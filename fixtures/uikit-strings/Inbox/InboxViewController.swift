import UIKit

/// Shows how many messages are waiting and lets the user archive them.
final class InboxViewController: UIViewController {
    private let countLabel = UILabel()
    private let archiveButton = UIButton(type: .system)
    private let messageCount = 3
    private let sender = "Ada"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = NSLocalizedString("inbox.title", comment: "Navigation title")

        let format = NSLocalizedString("inbox.count", comment: "Number of messages from a sender")
        countLabel.text = String.localizedStringWithFormat(format, messageCount, sender)
        archiveButton.setTitle("Archive all", for: .normal)
        archiveButton.addTarget(self, action: #selector(archive), for: .primaryActionTriggered)

        let stack = UIStackView(arrangedSubviews: [countLabel, archiveButton])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    @objc private func archive() {
        let alert = UIAlertController(
            title: NSLocalizedString("archive.confirm.title", comment: ""),
            message: NSLocalizedString("archive.confirm.message", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("archive.confirm.ok", comment: ""), style: .destructive))
        present(alert, animated: true)
    }

    // scripts/simulator-shots.sh opens the alert at launch, so it can take a screenshot of it.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if ProcessInfo.processInfo.arguments.contains("-ShowArchiveAlert"), presentedViewController == nil {
            archive()
        }
    }
}
