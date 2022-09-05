//
//  Copyright © 2014-2020 Reactive Reality. All rights reserved.
//

import UIKit

class FloatingPlaceholderTextField: UIView, UITextFieldDelegate {
// MARK: - UI
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    private let placeholderLabelCenter: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.textColor = .gray
        return label
    }()
    private let placeholderLabelTop: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11)
        label.textColor = .gray
        return label
    }()
    private let textField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = .systemFont(ofSize: 16)
        return field
    }()
    private let hintLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11)
        label.textColor = .black
        return label
    }()
    private let iconView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let shadowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = false
        view.layer.cornerRadius = 8
        return view
    }()
    private let button = UIButton()
    
// MARK: - Properties
    private var isInitialDraw = true
    private var topFrame = CGRect.zero
    private var centerFrame = CGRect.zero
    override var canBecomeFirstResponder: Bool {
        return textField.canBecomeFirstResponder
    }
    override var canResignFirstResponder: Bool {
        return textField.canResignFirstResponder
    }

    var textValue: String?
    private var defaultValue: String?

    private var style: TextFieldStyle? {
        didSet {
            guard let style = style else { return }
            placeholderLabelCenter.text = style.placeholder
            placeholderLabelTop.text = style.placeholder
            textField.autocapitalizationType = style.capitalization
            textField.keyboardType = style.keyboardType
            textField.isSecureTextEntry = style.secureInput
            if style.secureInput {
                setupIcon()
            }
        }
    }

// MARK: - Init and Setup
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard isInitialDraw else { return } // to avoid executing this code multiple times
        let shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 8)
        let layer = CALayer()
        layer.shadowPath = shadowPath.cgPath
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.frame = shadowView.bounds
        shadowView.layer.addSublayer(layer)
        shadowView.isHidden = true

        topFrame = placeholderLabelTop.frame
        centerFrame = placeholderLabelCenter.frame

        if !(textValue ?? "").isEmpty || !(defaultValue ?? "").isEmpty {
            placeholderToTop(animated: false)
        }
        isInitialDraw = false
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(shadowView)
        shadowView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 24).isActive = true
        shadowView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -24).isActive = true
        shadowView.heightAnchor.constraint(equalToConstant: 64).isActive = true
        shadowView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        addSubview(containerView)
        containerView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 24).isActive = true
        containerView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -24).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 64).isActive = true
        containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        containerView.addGestureRecognizer(tap)
        
        containerView.addSubview(placeholderLabelCenter)
        placeholderLabelCenter.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        placeholderLabelCenter.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        placeholderLabelCenter.heightAnchor.constraint(equalToConstant: 20).isActive = true

        containerView.addSubview(placeholderLabelTop)
        placeholderLabelTop.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        placeholderLabelTop.heightAnchor.constraint(equalToConstant: 13).isActive = true
        placeholderLabelTop.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14).isActive = true
        placeholderLabelTop.isHidden = true

        containerView.addSubview(textField)
        textField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        textField.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -44).isActive = true
        textField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 31).isActive = true
        textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -14).isActive = true
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        textField.delegate = self
    }

    private func setupIcon() {
        button.setImage(UIImage(named: "icon-eye"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        button.widthAnchor.constraint(equalToConstant: 24).isActive = true
        containerView.addSubview(button)
        button.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

// MARK: - Configure
    func configure(style: TextFieldStyle, value: String? = nil, isDefaultValue: Bool = false) {
        if let value = value {
            if isDefaultValue {
                let attributedPlaceholder = NSAttributedString(string: value,
                                                               attributes: [.font : UIFont.systemFont(ofSize: 16),
                                                                            .foregroundColor: UIColor.gray])
                textField.attributedPlaceholder = attributedPlaceholder
                defaultValue = value
            } else {
                textField.text = value
                textValue = value
            }
        }
        self.style = style
    }

// MARK: - First Responder
    @objc
    private func handleTap() {
        _ = becomeFirstResponder()
    }

    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }

    private func prepareToBecomeFirstResponder() {
        shadowView.isHidden = false
        containerView.layer.borderColor = UIColor.darkGray.cgColor
        placeholderLabelCenter.textColor = .gray
        button.setImage(button.currentImage?.withTintColor(.black), for: .normal)
        if (textValue ?? "").isEmpty && (defaultValue ?? "").isEmpty {
            placeholderToTop(animated: true)
        }
    }

// MARK: - Text filed delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        prepareToBecomeFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textValue = textField.text
        shadowView.isHidden = true
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        if (textValue ?? "").isEmpty && (defaultValue ?? "").isEmpty {
            placeholderToCenter()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }

    @objc private func textFieldDidChange() {
        textValue = textField.text
    }

    @objc private func buttonTapped() {
        textField.isSecureTextEntry = !textField.isSecureTextEntry
    }

// MARK: - Placeholder
    private func placeholderToTop(animated: Bool) {
        let heightScale = topFrame.height / centerFrame.height
        let widthScale = topFrame.width / centerFrame.width
        UIView.animate(withDuration: animated ? 0.15 : 0.0,
                       delay: 0,
                       options: .curveEaseOut) {
            self.placeholderLabelCenter.transform = CGAffineTransform(scaleX: widthScale, y: heightScale)
            self.placeholderLabelCenter.frame = self.topFrame
        }
    }

    private func placeholderToCenter() {
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut) {
            self.placeholderLabelCenter.transform = .identity
            self.placeholderLabelCenter.frame  = self.centerFrame
        }
    }
}

extension FloatingPlaceholderTextField {
    func setTextValue(_ text: String) {
        if (textValue ?? "").isEmpty && (defaultValue ?? "").isEmpty {
            placeholderToTop(animated: true)
        }
        textField.text = text
        textValue = text
    }

    func clear() {
        if !(textValue ?? "").isEmpty && (defaultValue ?? "").isEmpty {
            placeholderToCenter()
        }
        textField.text = nil
        textValue = nil
    }

    func setErrorState() {
        clear()
        containerView.layer.borderColor = UIColor.systemRed.cgColor
        placeholderLabelCenter.textColor = .systemRed
        button.setImage(button.currentImage?.withTintColor(.red), for: .normal)
    }
}
