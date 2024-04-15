//
//  ChatroomInputBoxView.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/1/25.
//

import UIKit

class ChatroomInputBoxView: UIView {
    
    // MARK: - Closures
    
    var sendButtonDidTapClosure: ((String) -> Void)?
    
    // MARK: - UI properties
    
    lazy var textView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    lazy var sendButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.sendButtonTintColor, for: .normal)
        button.setTitleColor(.gray, for: .disabled)
        button.addTarget(self, action: #selector(sendButtonDidTap), for: .touchUpInside)
        button.setTitle("Send", for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func sendButtonDidTap(_ sender: UIButton) {
        sendButtonDidTapClosure?(textView.text)
        textView.text = ""
    }
}

extension ChatroomInputBoxView: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.becomeFirstResponder()
    }
}

private extension ChatroomInputBoxView {
    
    func setupUI() {
        backgroundColor = .inputBoxBackgroundColor
        
        let insets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        addSubview(textView)
        addSubview(sendButton)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom),
            textView.heightAnchor.constraint(equalToConstant: 32),
            
            sendButton.topAnchor.constraint(equalTo: textView.topAnchor),
            sendButton.leadingAnchor.constraint(equalTo: textView.trailingAnchor, constant: insets.right),
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right),
            sendButton.bottomAnchor.constraint(equalTo: textView.bottomAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
}
