import SwiftUI



struct TextView: UIViewRepresentable {
    
    private let title: String
    @Binding private var text: String
    private var isEditable = true
    private var isSelectable = true
    
    private let uiLabel = UILabel()
    private var uiTextView = UITextView()
    
    init(_ title: String, text: Binding<String>) {
        _text = text
        self.title = title
    }
    
    init(_ text: String, isSelectable: Bool = true) {
        self.init("", text: .constant(text))
        isEditable = false
        self.isSelectable = isSelectable
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(textView: self)
    }
    
    func makeUIView(context: Context) -> UIView {
        let textColor = UIColor(Color.primary)
        let view = UIView()
        
        uiLabel.text = title
        uiLabel.font = UIFont.preferredFont(forTextStyle: .body)
        uiLabel.textColor = textColor.withAlphaComponent(0.23)
        view.addSubview(uiLabel)
        
        uiTextView.font = UIFont.preferredFont(forTextStyle: .body)
        uiTextView.textColor = textColor
        uiTextView.backgroundColor = nil
        uiTextView.textContainerInset = .zero
        uiTextView.textContainer.lineFragmentPadding = 0
        uiTextView.delegate = context.coordinator
        uiTextView.isEditable = isEditable
        uiTextView.isSelectable = isSelectable
        view.addSubview(uiTextView)
        
        uiLabel.translatesAutoresizingMaskIntoConstraints = false
        uiTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: uiLabel.topAnchor),
            view.rightAnchor.constraint(equalTo: uiLabel.rightAnchor),
            view.leftAnchor.constraint(equalTo: uiLabel.leftAnchor),
            view.topAnchor.constraint(equalTo: uiTextView.topAnchor),
            view.rightAnchor.constraint(equalTo: uiTextView.rightAnchor),
            view.bottomAnchor.constraint(equalTo: uiTextView.bottomAnchor),
            view.leftAnchor.constraint(equalTo: uiTextView.leftAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ view: UIView, context: Context) {
        uiLabel.isHidden = !text.isEmpty
        uiTextView.text = text
    }
    
}


extension TextView {
    
    final class Coordinator: NSObject, UITextViewDelegate {
        
        private let textView: TextView
        
        init(textView: TextView) {
            self.textView = textView
        }
        
        func textViewDidChange(_ uiTextView: UITextView) {
            self.textView.uiLabel.isHidden = !uiTextView.text.isEmpty
            self.textView.text = uiTextView.text
        }
        
    }
    
}
