import SwiftUI


struct EditOTPPage: View {
    
    @StateObject var viewModel: AnyViewModel<EditOTPViewModel.State, EditOTPViewModel.Action>
    
    @FocusState private var focusedField: EditOTPViewModel.FocusField?
    
    var body: some View {
        listView()
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
            .dismiss(on: viewModel[\.shouldDismiss].eraseToAnyPublisher())
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
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button {
                    viewModel(.focusPreviousField)
                } label: {
                    Image(systemName: "chevron.up")
                }
                .enabled(viewModel[\.previousFieldFocusable])
                Button {
                    viewModel(.focusNextField)
                } label: {
                    Image(systemName: "chevron.down")
                }
                .enabled(viewModel[\.nextFieldFocusable])
                Spacer()
                Button {
                    viewModel(.dismissKeyboard)
                } label: {
                    Text("_dismiss")
                        .bold()
                }
            }
        }
        .onSubmit {
            viewModel(.submit)
        }
    }
    
    private func otpSecretField() -> some View {
        Section(header: Text("_secret")) {
            EditLabeledRow(type: .secret, value: $viewModel[\.otpSecret])
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
        .actionSheet(isPresented: $viewModel[\.showDeleteAlert]) {
            ActionSheet(title: Text("_confirmAction"), buttons: [.cancel(), .destructive(Text("_deleteOtp")) {
                viewModel(.confirmDelete)
            }])
        }
    }
    
    private func cancelButton() -> some View {
        Button("_cancel", role: .cancel) {
            viewModel(.cancel)
        }
        .actionSheet(isPresented: $viewModel[\.showCancelAlert]) {
            ActionSheet(title: Text("_confirmAction"), buttons: [.cancel(), .destructive(Text("_discardChanges")) {
                viewModel(.discardChanges)
            }])
        }
    }
    
    private func confirmButton() -> some View {
        Button("_done") {
            viewModel(.applyToOTP)
        }
        .enabled(viewModel[\.editIsValid])
    }
    
}
