import SwiftUI
import PhotosUI
import VisionKit

struct AddExpenseView: View {
    @EnvironmentObject var expenseManager: ExpenseManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var selectedCategory: ExpenseCategory = .food
    @State private var selectedDate = Date()
    @State private var receiptImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingDocumentCamera = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    
    // For receipt scanning
    @State private var scannedText: String = ""
    @State private var isProcessingReceipt = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Información del Gasto") {
                    TextField("Monto", text: $amount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Descripción", text: $description)
                        .textFieldStyle(.roundedBorder)
                    
                    Picker("Categoría", selection: $selectedCategory) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    
                    DatePicker("Fecha", selection: $selectedDate, displayedComponents: .date)
                }
                
                Section("Recibo (Opcional)") {
                    if let receiptImage = receiptImage {
                        Image(uiImage: receiptImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                        
                        Button("Remover Imagen") {
                            self.receiptImage = nil
                            scannedText = ""
                        }
                        .foregroundColor(.red)
                    }
                    
                    HStack {
                        Button(action: {
                            sourceType = .camera
                            showingCamera = true
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Tomar Foto")
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            sourceType = .photoLibrary
                            showingImagePicker = true
                        }) {
                            HStack {
                                Image(systemName: "photo.fill")
                                Text("Galería")
                            }
                        }
                    }
                    
                    Button(action: {
                        showingDocumentCamera = true
                    }) {
                        HStack {
                            Image(systemName: "doc.text.viewfinder")
                            Text("Escanear Recibo")
                        }
                    }
                    
                    if !scannedText.isEmpty {
                        Text("Texto detectado:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(scannedText)
                            .font(.caption)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                if isProcessingReceipt {
                    Section {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Procesando recibo...")
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("Agregar Gasto")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveExpense()
                    }
                    .disabled(amount.isEmpty || description.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $receiptImage, sourceType: sourceType)
            }
            .sheet(isPresented: $showingCamera) {
                ImagePicker(image: $receiptImage, sourceType: .camera)
            }
            .sheet(isPresented: $showingDocumentCamera) {
                DocumentCameraView(scannedText: $scannedText, scannedImage: $receiptImage) {
                    processReceiptText()
                }
            }
        }
    }
    
    private func saveExpense() {
        guard let amountValue = Double(amount) else { return }
        
        var newExpense = Expense(
            amount: amountValue,
            description: description,
            category: selectedCategory,
            date: selectedDate
        )
        
        if let receiptImage = receiptImage {
            newExpense.receiptImage = receiptImage.jpegData(compressionQuality: 0.7)
        }
        
        expenseManager.addExpense(newExpense)
        dismiss()
    }
    
    private func processReceiptText() {
        // Simple receipt processing logic
        isProcessingReceipt = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Extract amount from scanned text (simplified)
            let lines = scannedText.components(separatedBy: .newlines)
            
            for line in lines {
                // Look for patterns like $XX.XX or total
                if line.lowercased().contains("total") || line.contains("$") {
                    let numbers = line.components(separatedBy: .decimalDigits.inverted).joined()
                    if let extractedAmount = extractAmountFromString(numbers) {
                        amount = String(format: "%.2f", extractedAmount)
                        break
                    }
                }
            }
            
            // If no description is provided, try to extract business name
            if description.isEmpty {
                if let businessName = extractBusinessNameFromText(scannedText) {
                    description = businessName
                }
            }
            
            isProcessingReceipt = false
        }
    }
    
    private func extractAmountFromString(_ text: String) -> Double? {
        let pattern = #"[\d]+\.[\d]{2}"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: text.utf16.count)
        
        if let match = regex?.firstMatch(in: text, range: range),
           let matchRange = Range(match.range, in: text) {
            return Double(String(text[matchRange]))
        }
        
        return nil
    }
    
    private func extractBusinessNameFromText(_ text: String) -> String? {
        let lines = text.components(separatedBy: .newlines)
        return lines.first { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

struct DocumentCameraView: UIViewControllerRepresentable {
    @Binding var scannedText: String
    @Binding var scannedImage: UIImage?
    let onScanComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = context.coordinator
        return scannerViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: DocumentCameraView
        
        init(_ parent: DocumentCameraView) {
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            for pageIndex in 0..<scan.pageCount {
                let image = scan.imageOfPage(at: pageIndex)
                parent.scannedImage = image
                
                // Extract text using Vision framework (simplified)
                extractText(from: image) { text in
                    DispatchQueue.main.async {
                        self.parent.scannedText = text
                        self.parent.onScanComplete()
                    }
                }
                break // Only process first page for simplicity
            }
            
            parent.dismiss()
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.dismiss()
        }
        
        private func extractText(from image: UIImage, completion: @escaping (String) -> Void) {
            // This would typically use Vision framework for OCR
            // For now, we'll return a placeholder
            completion("Texto extraído del recibo - implementar OCR con Vision framework")
        }
    }
}

#Preview {
    AddExpenseView()
        .environmentObject(ExpenseManager())
}
