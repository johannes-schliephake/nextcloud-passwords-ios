import SwiftUI


struct TextView: UIViewRepresentable {
    
    private let title: String
    @Binding private var text: String
    private var isEditable = true
    
    init(_ title: String, text: Binding<String>) {
        self.title = title
        _text = text
    }
    
    init(_ text: String) {
        self.init("", text: .constant(text))
        isEditable = false
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(textView: self)
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        view.addSubview(context.coordinator.uiLabel)
        view.addSubview(context.coordinator.uiTextView)
        
        context.coordinator.uiLabel.translatesAutoresizingMaskIntoConstraints = false
        context.coordinator.uiTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: context.coordinator.uiLabel.topAnchor),
            view.rightAnchor.constraint(equalTo: context.coordinator.uiLabel.rightAnchor),
            view.leftAnchor.constraint(equalTo: context.coordinator.uiLabel.leftAnchor),
            view.topAnchor.constraint(equalTo: context.coordinator.uiTextView.topAnchor),
            view.rightAnchor.constraint(equalTo: context.coordinator.uiTextView.rightAnchor),
            view.bottomAnchor.constraint(equalTo: context.coordinator.uiTextView.bottomAnchor),
            view.leftAnchor.constraint(equalTo: context.coordinator.uiTextView.leftAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_: UIView, context: Context) {
        context.coordinator.uiLabel.isHidden = !text.isEmpty
        context.coordinator.uiTextView.text = text
    }
    
}


extension TextView {
    
    final class Coordinator: NSObject, UITextViewDelegate {
        
        private let textView: TextView
        
        let uiLabel: UILabel
        let uiTextView: BetterCopyUITextView
        
        init(textView: TextView) {
            self.textView = textView
            uiLabel = UILabel()
            uiTextView = BetterCopyUITextView()
            super.init()
            
            let textColor = UIColor(Color.primary)
            
            uiLabel.text = textView.title
            uiLabel.font = UIFont.preferredFont(forTextStyle: .body)
            uiLabel.textColor = textColor.withAlphaComponent(0.23)
            
            uiTextView.font = UIFont.preferredFont(forTextStyle: .body)
            uiTextView.textColor = textColor
            uiTextView.backgroundColor = nil
            uiTextView.textContainerInset = .zero
            uiTextView.textContainer.lineFragmentPadding = 0
            uiTextView.delegate = self
            uiTextView.isEditable = textView.isEditable
            
            if !uiTextView.isEditable {
                uiTextView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
            }
        }
        
        func textViewDidChange(_ uiTextView: UITextView) {
            uiLabel.isHidden = !uiTextView.text.isEmpty
            textView.text = uiTextView.text
        }
        
        @objc func didTap(sender: UITapGestureRecognizer) {
            if uiTextView.selectedRange.length == 0 {
                uiTextView.selectAll(sender)
            }
        }
        
    }
    
}


extension TextView {
    
    final class BetterCopyUITextView: UITextView {
        
        override var canBecomeFirstResponder: Bool {
            true
        }
        
        override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
            if isEditable {
                return super.canPerformAction(action, withSender: sender)
            }
            return action == #selector(UIResponderStandardEditActions.copy)
        }
        
    }
    
}
