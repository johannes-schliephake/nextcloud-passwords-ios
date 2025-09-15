import SwiftUI
import Vision
import VisionKit


struct DataScannerView: UIViewControllerRepresentable {
    
    @MainActor static var isSupported: Bool {
        DataScannerViewController.isSupported
    }
    
    private let recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType>
    private let action: (_ result: Result<String, any Error>) -> Void
    
    init(_ barcodeSymbology: VNBarcodeSymbology, action: @escaping (_: Result<String, any Error>) -> Void) {
        self.init([barcodeSymbology], action: action)
    }
    
    init(_ barcodeSymbologies: [VNBarcodeSymbology], action: @escaping (_: Result<String, any Error>) -> Void) {
        self.init([.barcode(symbologies: barcodeSymbologies)], action: action)
    }
    
    init(_ recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType>, action: @escaping (_: Result<String, any Error>) -> Void) {
        self.recognizedDataTypes = recognizedDataTypes
        self.action = action
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(dataScannerView: self)
    }
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(recognizedDataTypes: recognizedDataTypes)
        scanner.delegate = context.coordinator
        do {
            try scanner.startScanning()
        } catch {
            action(.failure(error))
        }
        return scanner
    }
    
    func updateUIViewController(_: DataScannerViewController, context: Context) {}
    
    static func dismantleUIViewController(_ scanner: DataScannerViewController, coordinator: Coordinator) {
        scanner.stopScanning()
    }
    
}


extension DataScannerView {
    
    final class Coordinator: DataScannerViewControllerDelegate {
        
        private let dataScannerView: DataScannerView
        
        init(dataScannerView: DataScannerView) {
            self.dataScannerView = dataScannerView
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            guard case .barcode(let barcode) = addedItems.first,
                  let payload = barcode.payloadStringValue else {
                return
            }
            dataScannerView.action(.success(payload))
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
            dataScannerView.action(.failure(error))
        }
        
    }
    
}
