import SwiftUI


struct EditOTPPage: View {
    
    @StateObject var viewModel: AnyViewModelOf<EditOTPViewModel>
    
    @FocusState private var focusedField: EditOTPViewModel.FocusField?
    
    var body: some View {
        listView()
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle("_otp")
            .interactiveDismissDisabled(viewModel[\.hasChanges])
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    cancelButton()
                }
                ToolbarItem(placement: .confirmationAction) {
                    confirmButton()
                }
            }
            .sync($viewModel[\.focusedField], to: _focusedField)
            .dismiss(on: viewModel[\.shouldDismiss])
    }
    
    private func listView() -> some View {
        List {
            otpSecretField()
            moreSection()
            if !viewModel[\.isCreating] {
                exportButton()
                deleteButton()
            }
        }
        .listStyle(.insetGrouped)
        .onSubmit {
            if viewModel[\.nextFieldFocusable] || viewModel[\.editIsValid] {
                viewModel(.submit)
            }
        }
    }
    
    private func otpSecretField() -> some View {
        Section(header: Text("_secret")) {
            EditLabeledRow(type: .secret, value: $viewModel[\.otpSecret])
                .characterCounter(false)
                .focused($focusedField, equals: .otpSecret)
                .submitLabel(viewModel[\.showMore] ? .next : .done)
        }
    }
    
    private func moreSection() -> some View {
        Section {
            DisclosureGroup("_moreOptions", isExpanded: $viewModel[\.showMore]) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("_type")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Picker("", selection: $viewModel[\.otpType]) {
                        ForEach(OTP.OTPType.allCases.reversed()) {
                            type in
                            switch type {
                            case .totp:
                                Text("_timeBased")
                                    .tag(type)
                            case .hotp:
                                Text("_counterBased")
                                    .tag(type)
                            }
                        }
                    }
                    .pickerStyle(.segmented)
                    .apply { view in
                        if #available(iOS 26, *) {
                            view
                                .controlSize(.large)
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("_algorithm")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Picker("", selection: $viewModel[\.otpAlgorithm]) {
                        ForEach(Crypto.OTP.Algorithm.allCases) {
                            algorithm in
                            switch algorithm {
                            case .sha1:
                                Text("SHA-1")
                                    .tag(algorithm)
                            case .sha256:
                                Text("SHA-256")
                                    .tag(algorithm)
                            case .sha512:
                                Text("SHA-512")
                                    .tag(algorithm)
                            }
                        }
                    }
                    .pickerStyle(.segmented)
                    .apply { view in
                        if #available(iOS 26, *) {
                            view
                                .controlSize(.large)
                        }
                    }
                }
                EditLabeledRow(label: "_digits", value: $viewModel[\.otpDigits], bounds: 6...8)
                    .focused($focusedField, equals: .otpDigits)
                    .submitLabel(.next)
                switch viewModel[\.otpType] {
                case .hotp:
                    EditLabeledRow(label: "_counter", value: $viewModel[\.otpCounter], bounds: 0...Int.max)
                        .focused($focusedField, equals: .otpCounter)
                        .submitLabel(.done)
                case .totp:
                    EditLabeledRow(label: "_periodSeconds", value: $viewModel[\.otpPeriod], bounds: 1...Int.max)
                        .focused($focusedField, equals: .otpPeriod)
                        .submitLabel(.done)
                }
            }
        }
    }
    
    private func exportButton() -> some View {
        Section {
            NavigationLink {
                if let url = viewModel[\.sharingUrl] {
                    ShareOTPPage(viewModel: ShareOTPViewModel(otpUrl: url).eraseToAnyViewModel())
                }
            } label: {
                Label("_exportAsQrCode", systemImage: "square.and.arrow.up")
                    .foregroundColor(.accentColor)
            }
            .isDetailLink(false)
            .enabled(viewModel[\.sharingAvailable])
        }
    }
    
    private func deleteButton() -> some View {
        Button(role: .destructive) {
            viewModel(.deleteOTP)
        } label: {
            HStack {
                Spacer()
                Text("_deleteOtp")
                Spacer()
            }
        }
        .confirmationDialog("_confirmAction", isPresented: $viewModel[\.showDeletionConfirmation]) {
            Button("_deleteOtp", role: .destructive) {
                viewModel(.confirmDelete)
            }
        }
    }
    
    private func cancelButton() -> some View {
        Group {
            if #available(iOS 26, *) {
                Button(role: .cancel) {
                    viewModel(.cancel)
                }
            } else {
                Button("_cancel", role: .cancel) {
                    viewModel(.cancel)
                }
            }
        }
        .confirmationDialog("_confirmAction", isPresented: $viewModel[\.showCancellationConfirmation]) {
            Button("_discardChanges", role: .destructive) {
                viewModel(.discardChanges)
            }
        }
    }
    
    private func confirmButton() -> some View {
        Group {
            if #available(iOS 26, *) {
                Button(role: .confirm) {
                    viewModel(.applyToOTP)
                }
            } else {
                Button(viewModel[\.isCreating] ? "_create" : "_done") {
                    viewModel(.applyToOTP)
                }
            }
        }
        .enabled(viewModel[\.editIsValid])
    }
    
}
