//
//  CheckInView.swift
//  ServiceApp
//
//  Created by Kelvin J on 6/3/22.
//

import SwiftUI
import UIKit

struct CheckInView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var allowSubmit = false
    @State var code = -1
    @State var correctCode = false
    @State var showMessage: Image?
    var data: EventInformationModel
    var body: some View {
        
        HStack(spacing: 10) {
            Text("Check In").font(.title)
            self.showMessage?
                .resizable()
                .frame(width: 28, height: 28)
        }
        CheckInController(allowSubmit: $allowSubmit, code: $code, correctCode: $correctCode, data: data)
            .frame(width: 286, height: 50)
        HStack {
            Text("You will get the 5-digit code from the organizer upon arrival")
            Spacer(minLength: 30)
            Button(action: {
                print(code)
                FirestoreCRUD().validateOneTimeCode(data: data, inputtedValue: self.code) { dbCode in
                    switch dbCode {
                    case true:
                        self.correctCode = true
                        withAnimation {
                            self.showMessage = Image(systemName: "checkmark.circle.fill").symbolRenderingMode(.multicolor)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    case false:
                        self.correctCode = false
                        withAnimation {
                            self.showMessage = Image(systemName: "xmark.octagon.fill").symbolRenderingMode(.multicolor)
                        }
                    case .none:
                        break
                    case .some(_):
                        break
                    }
                }
            }) {
                Text("Submit")
                    .foregroundColor(allowSubmit ? .blue : .darkGray)
                    .bold()
            }.disabled(!allowSubmit)
        }.padding(30)
    }
}

struct CheckInController: UIViewRepresentable {
    @Binding var allowSubmit: Bool
    @Binding var code: Int
    @Binding var correctCode: Bool
    var data: EventInformationModel
    var codeTxt = OneTimeCodeTextField()
    func makeUIView(context: Context) -> UITextField {
        codeTxt.configure(withSlotCount: 5, andSpacing: 9)
        codeTxt.codeBackgroundColor = .secondarySystemBackground
        codeTxt.codeTextColor = .label
        codeTxt.codeFont = .systemFont(ofSize: 30, weight: .black)
        codeTxt.codeMinimumScaleFactor = 0.2
        codeTxt.codeCornerRadius = 12
        codeTxt.codeCornerCurve = .continuous
        
        codeTxt.codeBorderWidth = 1
        codeTxt.codeBorderColor = .label
        
        // Get entered Passcode
        codeTxt.didReceiveCode = { code in
            print(code)
            allowSubmit = false
            guard code.count == 5 else { return }
            
            allowSubmit = true
            self.code = Int(code)!
            
        }
        codeTxt.clear()
        return codeTxt
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) { }
}

public class OneTimeCodeTextField: UITextField {
    // MARK: UI Components
    private(set) var digitLabels = [UILabel]()
    
    // MARK: Delegates
    private lazy var oneTimeCodeDelegate = OneTimeCodeTextFieldDelegate(oneTimeCodeTextField: self)
    
    // MARK: Properties
    private var isConfigured = false
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.addTarget(self, action: #selector(becomeFirstResponder))
        return recognizer
    }()
    
    // MARK: Completions
    public var didReceiveCode: ((String) -> Void)?
    
    // MARK: Customisations
    /// Needs to be called after `configure()`.
    /// Default value: `.secondarySystemBackground`
    public var codeBackgroundColor: UIColor = .secondarySystemBackground {
        didSet {
            digitLabels.forEach({ $0.backgroundColor = codeBackgroundColor })
        }
    }
    
    /// Needs to be called after `configure()`.
    /// Default value: `.label`
    public var codeTextColor: UIColor = .label {
        didSet {
            digitLabels.forEach({ $0.textColor = codeTextColor })
        }
    }
    
    /// Needs to be called after `configure()`.
    /// Default value: `.systemFont(ofSize: 24)`
    public var codeFont: UIFont = .systemFont(ofSize: 24) {
        didSet {
            digitLabels.forEach({ $0.font = codeFont })
        }
    }
    
    /// Needs to be called after `configure()`.
    /// Default value: 0.8
    public var codeMinimumScaleFactor: CGFloat = 0.8 {
        didSet {
            digitLabels.forEach({ $0.minimumScaleFactor = codeMinimumScaleFactor })
        }
    }
    
    /// Needs to be called after `configure()`.
    /// Default value: 8
    public var codeCornerRadius: CGFloat = 8 {
        didSet {
            digitLabels.forEach({ $0.layer.cornerRadius = codeCornerRadius })
        }
    }
    
    /// Needs to be called after `configure()`.
    /// Default value: `.continuous`
    public var codeCornerCurve: CALayerCornerCurve = .continuous {
        didSet {
            digitLabels.forEach({ $0.layer.cornerCurve = codeCornerCurve })
        }
    }
    
    /// Needs to be called after `configure()`.
    /// Default value: 0
    public var codeBorderWidth: CGFloat = 0 {
        didSet {
            digitLabels.forEach({ $0.layer.borderWidth = codeBorderWidth })
        }
    }
    
    /// Needs to be called after `configure()`.
    /// Default value: `.none`
    public var codeBorderColor: UIColor? = .none {
        didSet {
            digitLabels.forEach({ $0.layer.borderColor = codeBorderColor?.cgColor })
        }
    }
        
    // MARK: Configuration
    public func configure(withSlotCount slotCount: Int = 6, andSpacing spacing: CGFloat = 8) {
        guard isConfigured == false else { return }
        isConfigured = true
        configureTextField()
        
        let slotsStackView = generateSlotsStackView(with: slotCount, spacing: spacing)
        addSubview(slotsStackView)
        addGestureRecognizer(tapGestureRecognizer)
        
        NSLayoutConstraint.activate([
            slotsStackView.topAnchor.constraint(equalTo: topAnchor),
            slotsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            slotsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            slotsStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func configureTextField() {
        tintColor = .clear
        textColor = .clear
        layer.borderWidth = 0
        borderStyle = .none
        keyboardType = .numberPad
        textContentType = .oneTimeCode
        
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        delegate = oneTimeCodeDelegate
        
        becomeFirstResponder()
    }
    
    private func generateSlotsStackView(with count: Int, spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = spacing
        
        for _ in 0..<count {
            let slotLabel = generateSlotLabel()
            stackView.addArrangedSubview(slotLabel)
            digitLabels.append(slotLabel)
        }
        
        return stackView
    }
    
    private func generateSlotLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.textAlignment = .center
        label.font = codeFont
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.textColor = codeTextColor
        label.backgroundColor = codeBackgroundColor
        
        label.layer.masksToBounds = true
        label.layer.cornerRadius = codeCornerRadius
        label.layer.cornerCurve = codeCornerCurve
        
        label.layer.borderWidth = codeBorderWidth
        label.layer.borderColor = codeBorderColor?.cgColor
        
        return label
    }
    
    @objc
    private func textDidChange() {
        guard let code = text, code.count <= digitLabels.count else { return }
        
        for i in 0 ..< digitLabels.count {
            let currentLabel = digitLabels[i]
            
            if i < code.count {
                let index = code.index(code.startIndex, offsetBy: i)
                currentLabel.text = String(code[index])
            } else {
                currentLabel.text?.removeAll()
            }
        }
        
        if code.count == digitLabels.count { didReceiveCode?(code) }
    }
    
    public func clear() {
        guard isConfigured == true else { return }
        digitLabels.forEach({ $0.text = "" })
        text = ""
    }
}


class OneTimeCodeTextFieldDelegate: NSObject, UITextFieldDelegate {
    let oneTimeCodeTextField: OneTimeCodeTextField
    
    init(oneTimeCodeTextField: OneTimeCodeTextField) {
        self.oneTimeCodeTextField = oneTimeCodeTextField
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)),
              let characterCount = textField.text?.count else { return false }
        return characterCount < oneTimeCodeTextField.digitLabels.count || string == ""
    }
}

extension OneTimeCodeTextField {
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        false
    }
    
    public override func caretRect(for position: UITextPosition) -> CGRect {
        .zero
    }
    
    public override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        []
    }
}
