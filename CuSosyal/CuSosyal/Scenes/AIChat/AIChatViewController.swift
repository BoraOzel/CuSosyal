//
//  AIChatViewController.swift
//  CuSosyal
//
//  Created by Bora Özel on 12/5/26.
//

import UIKit

protocol AIChatViewControllerInterface {
    func setupTableView()
    func setupTextViewAppearance()
    func initializeChat()
    func sendMessage()
    func scrollToBottom()
    func setupKeyboardObservers()
    func setupCallbacks()
}

class AIChatViewController: UIViewController {
    
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    private let viewModel: AIChatViewModelInterface
    private var hasInitializedTextViewHeight = false
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Kulüpler hakkında soru sor..."
        label.textColor = .placeholderText
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(viewModel: AIChatViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: "AIChatViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupTextViewAppearance()
        setupKeyboardObservers()
        initializeChat()
        setupCallbacks()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !hasInitializedTextViewHeight, messageTextView.frame.width > 0 else { return }
        hasInitializedTextViewHeight = true
        textViewDidChange(messageTextView)
    }
    
    @IBAction func sendMessageButtonClicked(_ sender: Any) {
        sendMessage()
    }
    
}

extension AIChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = viewModel.messages[indexPath.row]
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        var config = cell.defaultContentConfiguration()
        config.text = message.content
        config.textProperties.numberOfLines = 0
        
        cell.contentConfiguration = config
        cell.backgroundColor = message.isUser ? UIColor.accent.withAlphaComponent(0.1) : .systemBackground
        cell.layer.cornerRadius = 12
        
        return cell
    }
    
}

extension AIChatViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let maxHeight: CGFloat = 120
        let fittingSize = textView.sizeThatFits(CGSize(width: textView.frame.width, height: .infinity))
        
        textView.isScrollEnabled = fittingSize.height >= maxHeight
        textViewHeightConstraint.constant = min(fittingSize.height, maxHeight)
        placeholderLabel.isHidden = !textView.text.isEmpty
        UIView.animate(withDuration: 0.1) { self.view.layoutIfNeeded() }
    }
}

extension AIChatViewController: AIChatViewControllerInterface {
    
    func setupTableView() {
        messageTableView.dataSource = self
        messageTableView.separatorStyle = .none
        messageTextView.delegate = self
        messageTextView.setContentHuggingPriority(UILayoutPriority(rawValue: 249), for: .horizontal)
    }
    
    func setupTextViewAppearance() {
        messageTextView.backgroundColor = .secondarySystemBackground
        messageTextView.layer.cornerRadius = 18
        messageTextView.layer.borderWidth = 0.5
        messageTextView.layer.borderColor = UIColor.separator.cgColor
        messageTextView.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        messageTextView.textContainer.lineFragmentPadding = 0
        
        messageTextView.addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: messageTextView.topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: messageTextView.leadingAnchor, constant: 12)
        ])
    }
    
    func initializeChat() {
        Task { [weak self] in
            guard let self else { return }
            await viewModel.initializeChat()
        }
        hideKeyboardWhenTappedAround()
    }
    
    func sendMessage() {
        guard let text = messageTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return }
        
        messageTextView.text = ""
        textViewDidChange(messageTextView)
        messageTextView.resignFirstResponder()
        
        Task { [weak self] in
            guard let self else { return }
            
            await viewModel.sendMessage(text: text)
            await MainActor.run {
                self.messageTableView.reloadData()
                self.scrollToBottom()
            }
        }
    }
    
    func scrollToBottom() {
        let count = viewModel.messages.count
        guard count > 0 else { return }
        let indexPath = IndexPath(row: count - 1, section: 0)
        messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom
        UIView.animate(withDuration: duration) {
            self.additionalSafeAreaInsets.bottom = keyboardHeight
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        UIView.animate(withDuration: duration) {
            self.additionalSafeAreaInsets.bottom = 0
            self.view.layoutIfNeeded()
            
        }
    }
    
    func setupCallbacks() {
        guard let vm = viewModel as? AIChatViewModel else { return }
        vm.onMessagesUpdated = { [weak self] in
            guard let self else { return }
            self.messageTableView.reloadData()
            self.scrollToBottom()
        }
    }
    
}
