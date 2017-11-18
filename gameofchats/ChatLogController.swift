//
//  ChatLogController.swift
//  gameofchats
//
//  Created by Денис Попов on 13.11.2017.
//  Copyright © 2017 Денис Попов. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController : UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    var user : User? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let userMessageRef = Database.database().reference().child("user-messages").child(uid)
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            messagesRef.observe(.value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String : String] else {return}
                
                let message = Message()
                message.setValuesForKeys(dictionary)
                
                if message.chatPartnerId() == self.user?.id {
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
            }, withCancel: nil)
            
            
        }, withCancel: nil)
    }
    
    lazy var inputTextField : UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message"
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
//        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.backgroundColor = .white
        collectionView?.keyboardDismissMode = .interactive

//        setupInputComponents()
//
//        setupKeyboardObservers()
        
    }
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = .white
        
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        
        containerView.addSubview(self.inputTextField)
        
        self.inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor , constant : 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorView)
        
        separatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        return containerView
    }()
    
    override var inputAccessoryView: UIView? {
        get{
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //если не сделать это , то могут быть баги с клавиатурой.
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleKeyboardWillShow(notification : Notification) {
        let keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardDuration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        containerViewBottomAnchor?.constant = -keyboardFrame.height
        //всегда когда меняются constraints view сама анимирует хз как то так
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleKeyboardWillHide(notification : Notification) {
        let keyboardDuration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        containerViewBottomAnchor?.constant = 0
        //всегда когда меняются constraints view сама анимирует хз как то так
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }

    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return messages.count
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.item]
        cell.textView.text = message.text!
        
        setupCell(cell: cell, message: message)
        
        cell.bubbleWidthAnchor?.constant = estimatedFrameForText(text:  message.text!).width + 32
        return cell
    }
    
    private func setupCell(cell : ChatMessageCell , message : Message ) {
        if let profileImageUrl = self.user?.profileImageURL {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        if message.fromId == Auth.auth().currentUser?.uid {
            //исходящие синие
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        } else {
            //входящие серые
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height : CGFloat = 80
        if let text = messages[indexPath.item].text {
            height = estimatedFrameForText(text: text).height + 20
        }
        //при повороте экрана сообщения всегда будут прилипать к нужному краю 
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    private func estimatedFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    var containerViewBottomAnchor : NSLayoutConstraint?
    
    func setupInputComponents() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        
        
        
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewBottomAnchor?.isActive = true
        
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        
        containerView.addSubview(inputTextField)
        
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor , constant : 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorView)
        
        separatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
    }
    
    @objc func handleSend() {
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timestamp : Int = Int(Date().timeIntervalSince1970)
        let values = ["text" : inputTextField.text! , "toId" : toId , "fromId" : fromId , "timestamp" : "\(timestamp)"] as [String : AnyObject]
//        childRef.updateChildValues(values)
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error)
                return
            }
            
            self.inputTextField.text = nil
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId : 1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId)
            recipientUserMessagesRef.updateChildValues([messageId : 1])
        }
    }

    //тригер на enter при отправке сообщений
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}












