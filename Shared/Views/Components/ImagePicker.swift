import SwiftUI
import PhotosUI


struct ImagePicker: UIViewControllerRepresentable {
    
    let action: (_ image: UIImage) -> Void
    
    @Environment(\.presentationMode) private var presentationMode
    
    func makeCoordinator() -> Coordinator {
        Coordinator(imagePicker: self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
}


extension ImagePicker {
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        
        private let imagePicker: ImagePicker
        
        init(imagePicker: ImagePicker) {
            self.imagePicker = imagePicker
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard !results.isEmpty else {
                imagePicker.presentationMode.wrappedValue.dismiss()
                return
            }
            results
                .forEach {
                    result in
                    guard result.itemProvider.canLoadObject(ofClass: UIImage.self) else {
                        return
                    }
                    result.itemProvider.loadObject(ofClass: UIImage.self) {
                        [weak self] object, error in
                        guard error == nil,
                              let image = object as? UIImage else {
                            return
                        }
                        DispatchQueue.main.async {
                            self?.imagePicker.action(image)
                            self?.imagePicker.presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
        }
        
    }
    
}
