import SwiftUI
import FactoryKit


struct PasswordDetailPage: View {
    
    @ObservedObject var entriesController: EntriesController
    @ObservedObject var password: Password
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var autoFillController: AutoFillController
    @EnvironmentObject private var sessionController: SessionController
    @EnvironmentObject private var settingsController: SettingsController
    
    // AppStorage freezes app on iOS 16 + 17
//    @AppStorage("showMetadata", store: Configuration.userDefaults) private var showMetadata = Configuration.defaults["showMetadata"] as! Bool
    @State private var showMetadata = Configuration.userDefaults.bool(forKey: "showMetadata")
    @State private var favicon: UIImage?
    @State private var showEditPasswordView = false
    @State private var showErrorAlert = false
    @State private var navigationSelection: NavigationSelection?
    @State private var hasNavigationSelection = false
    @State private var showSelectTagsView = false
    @State private var showPasswordStatusTooltip = false
    @State private var sectionWidth = 300.0
    @ScaledMetric private var currentOtpFontSize = 17
    @ScaledMetric private var upcomingOtpFontSize = 12
    @ScaledMetric private var otpLabelsDistance = 6
    
    private let iOS26 = if #available(iOS 26, *) { true } else { false }
    
    // MARK: Views
    
    var body: some View {
        mainStack()
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle(password.label)
            .toolbar {
                if #available(iOS 26, *) {
                    ToolbarItem(placement: .largeTitle) {
                        Text("")
                    }
                    stateToolbar()
                    if let complete = autoFillController.complete,
                       autoFillController.mode != .extension || password.otp != nil {
                        ToolbarItem(placement: .bottomBar) {
                            selectButton(complete: complete)
                        }
                    }
                    ToolbarSpacer(.flexible, placement: .bottomBar)
                    ToolbarItem(placement: .bottomBar) {
                        favoriteButton()
                    }
                    ToolbarItem(placement: .bottomBar) {
                        if password.editable {
                            editButton()
                        }
                    }
                } else {
                    ToolbarItem(placement: .primaryAction) {
                        stateView()
                    }
                    ToolbarItem(placement: .primaryAction) {
                        if password.editable {
                            editButton()
                        }
                    }
                }
            }
            .onReceive(dependency(\.systemNotifications).publisher(for: Notification.Name("deletePassword"), object: password)) { _ in
                dismiss()
            }
            .onChange(of: sessionController.session == nil) { withoutSession in
                if withoutSession {
                    dismiss()
                }
            }
            .apply { view in
                if #available(iOS 26, *),
                   UIDevice.current.userInterfaceIdiom == .phone {
                    /// Fixes bug in SwiftUI where popovers are presented outside of screen on phones when source is placed trailing in navigation bar
                    view
                        .overlay(alignment: .topTrailing) {
                            EmptyView()
                                .frame(width: 2, height: 2)
                                .tooltip(isPresented: $showPasswordStatusTooltip) {
                                    tooltipContent()
                                }
                                .offset(x: -37, y: -34 + 5)
                        }
                }
            }
            .onChange(of: showMetadata) { Configuration.userDefaults.set($0, forKey: "showMetadata") }
    }
    
    private func mainStack() -> some View {
        listView()
            .apply { view in
                if #unavailable(iOS 26) {
                    GeometryReader { geometryProxy in
                        VStack(spacing: 0) {
                            view
                            if let complete = autoFillController.complete,
                               autoFillController.mode != .extension || password.otp != nil {
                                Divider()
                                selectBar(geometryProxy: geometryProxy, complete: complete)
                            }
                        }
                        .edgesIgnoringSafeArea(autoFillController.complete != nil ? .bottom : [])
                    }
                }
            }
            .sheet(isPresented: $showEditPasswordView, content: {
                EditPasswordNavigation(entriesController: entriesController, password: password)
            })
            .apply { view in
                if #available(iOS 17, *) {
                    view
                        // Explicit capture of entriesController required to fix freeze on iOS 17, also used for every other navigationDestination
                        .navigationDestination(item: $navigationSelection) { [entriesController] navigationSelection in
                            switch navigationSelection {
                            case let .duplicate(password):
                                Self(entriesController: entriesController, password: password)
                            case let .entries(tag):
                                EntriesPage(entriesController: entriesController, tag: tag, showFilterSortMenu: false)
                            }
                        }
                } else {
                    view
                        .navigationDestination(
                            isPresented: $hasNavigationSelection,
                            destination: { [entriesController] in
                                if let navigationSelection {
                                    switch navigationSelection {
                                    case let .duplicate(password):
                                        Self(entriesController: entriesController, password: password)
                                    case let .entries(tag):
                                        EntriesPage(entriesController: entriesController, tag: tag, showFilterSortMenu: false)
                                    }
                                }
                            }
                        )
                        .onChange(of: navigationSelection) { hasNavigationSelection = $0 != nil }
                        .onChange(of: hasNavigationSelection) { navigationSelection = $0 ? navigationSelection : nil }
                }
            }
    }
    
    private func listView() -> some View {
        List {
            Section {
                if #available(iOS 26, *) {
                    HStack(spacing: 20) {
                        faviconImage()
                        Text(password.label)
                            .multilineTextAlignment(.leading)
                            .font(.largeTitle)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    HStack {
                        Spacer()
                        passwordStatusIcon()
                        Spacer()
                        faviconImage()
                        Spacer()
                        favoriteButton()
                        Spacer()
                    }
                    .padding(.top)
                }
            }
            .onGeometryChange(
                for: Double.self,
                of: { $0.size.width },
                action: { sectionWidth = $0 }
            )
            .listRowBackground(Color.clear)
            .apply { view in
                if #available(iOS 26, *) {
                    view
                        .listSectionSpacing(0)
                }
            }
            if let tags = entriesController.tags {
                let validTags = EntriesController.tags(for: password.tags, in: tags).valid
                tagsSection(validTags: validTags)
                    .listRowBackground(Color.clear)
            }
            serviceSection()
            accountSection()
            if !password.customUserFields.isEmpty {
                customFieldsSection()
            }
            if !password.notes.isEmpty {
                notesSection()
            }
            metadataSection()
                .listRowBackground(Color.clear)
        }
        .listStyle(.insetGrouped)
        .apply { view in
            if UIDevice.current.userInterfaceIdiom == .pad,
               #available(iOS 17, *) {
                view
                    .listWidthLimit(600)
            }
        }
    }
    
    private func passwordStatusIcon() -> some View {
        Button {
            showPasswordStatusTooltip = true
        }
        label: {
            let font: Font = if #available(iOS 26, *) { .title2 } else { .title }
            switch password.statusCode {
            case .good:
                Image(systemName: "checkmark.shield.fill")
                    .font(font)
                    .foregroundColor(.green)
            case .outdated, .duplicate:
                Image(systemName: "exclamationmark.shield.fill")
                    .font(font)
                    .foregroundColor(.yellow)
            case .breached:
                Image(systemName: "xmark.shield.fill")
                    .font(font)
                    .foregroundColor(.red)
            case .unknown:
                Image(systemName: "shield.fill")
                    .font(font)
                    .foregroundColor(.gray)
                    .mask {
                        Image(systemName: "questionmark")
                            .font(font.bold())
                            .scaleEffect(0.5)
                            .foregroundColor(.black)
                            .background(.white)
                            .compositingGroup()
                            .luminanceToAlpha()
                    }
            }
        }
        .buttonStyle(.borderless)
        .apply { view in
            if !iOS26 || UIDevice.current.userInterfaceIdiom == .pad {
                view
                    .tooltip(isPresented: $showPasswordStatusTooltip) {
                        tooltipContent()
                    }
            }
        }
    }
    
    private func tooltipContent() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            switch password.statusCode {
            case .good:
                Text("_passwordStatusGoodMessage")
            case .outdated:
                Text("_passwordStatusOutdatedMessage")
            case .duplicate:
                Text("_passwordStatusDuplicateMessage")
            case .breached:
                Text("_passwordStatusBreachedMessage")
            case .unknown:
                Text("_passwordStatusUnknownMessage")
            }
            if password.editable,
               password.statusCode == .outdated || password.statusCode == .duplicate || password.statusCode == .breached {
                if #unavailable(iOS 26) {
                    Divider()
                        .padding(.trailing, -100)
                }
                Button {
                    showPasswordStatusTooltip = false
                    showEditPasswordView = true
                } label: {
                    Label("_editPassword", systemImage: "square.and.pencil")
                        .apply { view in
                            if #available(iOS 26, *) {
                                view
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, minHeight: 34)
                            } else {
                                view
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                }
                .apply { view in
                    if #available(iOS 26, *) {
                        view
                            .buttonStyle(.glassProminent)
                    }
                }
                .disabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
            }
            if password.statusCode == .duplicate,
               let duplicates = entriesController.passwords?.filter({ $0.password == password.password && $0.id != password.id }) {
                if #unavailable(iOS 26) {
                    Divider()
                        .padding(.trailing, -100)
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text(Strings.duplicates)
                        .apply { view in
                            if #available(iOS 26, *) {
                                view
                                    .font(.headline)
                            } else {
                                view
                                    .font(.subheadline)
                            }
                        }
                        .bold()
                        .foregroundColor(.gray)
                        .padding(.top, 12)
                        .padding(.bottom, EdgeInsets.entryRow.bottom)
                    if #unavailable(iOS 26) {
                        Divider()
                            .padding(.trailing, -100)
                    }
                    if duplicates.isEmpty {
                        Text(Strings.duplicatesTrashMessage)
                            .foregroundColor(.gray)
                            .padding(.top, 15)
                    }
                    else {
                        ForEach(duplicates.sortedByLabel()) {
                            duplicate in
                            Button {
                                showPasswordStatusTooltip = false
                                navigationSelection = .duplicate(password: duplicate)
                            } label: {
                                PasswordRow(label: duplicate.label, username: duplicate.username, url: duplicate.url)
                                    .padding(.top, EdgeInsets.entryRow.top)
                                    .padding(.bottom, EdgeInsets.entryRow.bottom)
                                    .foregroundColor(.primary)
                            }
                            Divider()
                                .apply { view in
                                    if #unavailable(iOS 26) {
                                        view
                                            .padding(.trailing, -100)
                                    }
                                }
                                .padding(.leading, 40 + 12)
                        }
                    }
                }
            }
        }
        .environmentObject(autoFillController)
        .environmentObject(sessionController)
        .environmentObject(settingsController)
    }
    
    private func faviconImage() -> some View {
        Image(uiImage: favicon ?? UIImage())
            .resizable()
            .frame(width: 64, height: 64)
            .background(favicon == nil ? Color(white: 0.5, opacity: 0.2) : nil)
            .apply { view in
                if #available(iOS 26, *) {
                    view
                        .cornerRadius(9.6)
                } else {
                    view
                        .cornerRadius(6)
                }
            }
            .task(id: password.url) {
                requestFavicon()
            }
    }
    
    private func favoriteButton() -> some View {
        Button {
            toggleFavorite()
        } label: {
            Image(systemName: password.favorite ? "star.fill" : "star")
                .apply { view in
                    if #unavailable(iOS 26) {
                        view
                            .font(.title)
                    }
                }
        }
        .buttonStyle(.borderless)
        .disabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
    }
    
    private func tagsSection(validTags: [Tag]) -> some View {
        Section {
            if iOS26 || !validTags.isEmpty {
                let aligment: HorizontalAlignment = iOS26 ? .leading : .center
                FlowView(alignment: aligment) {
                    ForEach(validTags.sorted()) { tag in
                        TagBadge(tag: tag, baseColor: Color(.secondarySystemGroupedBackground))
                            .apply { view in
                                if UIDevice.current.userInterfaceIdiom != .pad { /// Disable tag buttons for iPad because of NavigationLink bugs
                                    Button {
                                        navigationSelection = .entries(tag: tag)
                                    } label: {
                                        view
                                    }
                                    .buttonStyle(.borderless)
                                }
                            }
                    }
                    if #available(iOS 26, *) {
                        selectTagsButton(hasTags: !validTags.isEmpty)
                    }
                }
            }
        } footer: {
            if #unavailable(iOS 26) {
                HStack {
                    Spacer()
                    selectTagsButton(hasTags: !validTags.isEmpty)
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showSelectTagsView) {
            SelectTagsNavigation(temporaryEntry: .password(label: password.label, username: password.username, url: password.url, tags: password.tags), selectTags: {
                validTags, invalidTags in
                password.tags = validTags.map { $0.id } + invalidTags
                entriesController.update(password: password)
            })
        }
    }
    
    private func selectTagsButton(hasTags: Bool) -> some View {
        Button {
            showSelectTagsView = true
        } label: {
            if #available(iOS 26, *) {
                if hasTags {
                    Label("_editTags", systemImage: "checklist")
                        .labelStyle(.iconOnly)
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.gray)
                        .padding(6)
                        .background(
                            Capsule()
                                .fill(Color(.secondarySystemGroupedBackground))
                        )
                } else {
                    HStack(spacing: 6) {
                        Circle()
                            .strokeBorder(Color(.placeholderText), lineWidth: 1.5)
                            .frame(width: 14, height: 14)
                        Text("_addTags")
                            .font(.subheadline)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(Color(.placeholderText))
                    }
                    .padding(.init(top: 6, leading: 6, bottom: 6, trailing: 10))
                    .background {
                        Capsule()
                            .strokeBorder(Color(.placeholderText), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                    }
                }
            } else {
                Text(hasTags ? "_editTags" : "_addTags")
                    .font(.footnote)
                    .textCase(.uppercase)
            }
        }
        .buttonStyle(.borderless)
        .disabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
    }
    
    private func serviceSection() -> some View {
        Section {
            if #unavailable(iOS 26) {
                LabeledRow(type: .text, label: "_name", value: password.label, copiable: true)
            }
            if !password.url.isEmpty || !iOS26 {
                LabeledRow(type: .url, label: "_url", value: password.url, copiable: true)
            }
        } header: {
            if #unavailable(iOS 26) {
                Text("_service")
            }
        }
    }
    
    private func accountSection() -> some View {
        Section {
            if !password.username.isEmpty || !iOS26 {
                LabeledRow(type: .nonLinguisticText, label: "_username", value: password.username, copiable: true)
            }
            LabeledRow(type: .secret, label: "_password", value: password.password, copiable: true)
            if let otp = password.otp {
                HStack {
                    OTPDisplay(otp: otp) { otp in
                        password.updated = Date()
                        password.otp = otp
                        entriesController.update(password: password)
                    } content: { current, upcoming, accessoryView in
                        Button {
                            if let current {
                                dependency(\.pasteboardService).set(string: current, sensitive: false)
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: otpLabelsDistance) {
                                Text("_otp")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text((current ?? "").segmented)
                                    .font(.system(size: currentOtpFontSize))
                                    .foregroundColor(.primary)
                                    .monospaced()
                                    .apply { view in
                                        if #available(iOS 17, *) {
                                            view
                                                .typesettingLanguage(.init(languageCode: .unavailable))
                                        }
                                    }
                                    .id(current)
                                    .transition(
                                        .asymmetric(
                                            insertion: .scale(scale: upcomingOtpFontSize / currentOtpFontSize, anchor: .leading)
                                                .combined(with: .offset(y: currentOtpFontSize + otpLabelsDistance))
                                                .combined(with: .opacity),
                                            removal: .offset(y: -(currentOtpFontSize + otpLabelsDistance))
                                                .combined(with: .opacity)
                                        )
                                    )
                                if let upcoming {
                                    Text(upcoming.segmented)
                                        .font(.system(size: upcomingOtpFontSize))
                                        .foregroundColor(.gray)
                                        .monospaced()
                                        .apply { view in
                                            if #available(iOS 17, *) {
                                                view
                                                    .typesettingLanguage(.init(languageCode: .unavailable))
                                            }
                                        }
                                        .id(upcoming)
                                        .transition(
                                            .asymmetric(
                                                insertion: .offset(y: currentOtpFontSize + otpLabelsDistance)
                                                    .combined(with: .opacity),
                                                removal: .scale(scale: currentOtpFontSize / upcomingOtpFontSize, anchor: .leading)
                                                    .combined(with: .offset(y: -(currentOtpFontSize + otpLabelsDistance)))
                                                    .combined(with: .opacity)
                                            )
                                        )
                                }
                            }
                        }
                        .disabled(current == nil)
                        Spacer()
                        switch otp.type {
                        case .hotp:
                            accessoryView
                        case .totp:
                            accessoryView
                                .padding(.horizontal, 4)
                        }
                    }
                    .disabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
                }
            }
        } header: {
            if !password.username.isEmpty || password.otp != nil || !iOS26 {
                Text("_account")
            }
        }
    }
    
    private func customFieldsSection() -> some View {
        Section(header: Text("_customFields")) {
            ForEach(password.customUserFields) {
                customField in
                LabeledRow(type: LabeledRow.RowType(rawValue: customField.type.rawValue) ?? .nonLinguisticText, label: customField.label, value: customField.value, copiable: true)
            }
        }
    }
    
    private func notesSection() -> some View {
        Section(header: Text("_notes")) {
            TextView(password.notes)
                .frame(height: 100)
        }
    }
    
    private func metadataSection() -> some View {
        Section {
            DisclosureGroup(isExpanded: $showMetadata) {
                VStack(spacing: 8) {
                    labeledFootnote("_created") {
                        Text(password.created.formattedString)
                    }
                    labeledFootnote("_updated") {
                        Text(password.updated.formattedString)
                    }
                    labeledFootnote("_encryption") {
                        switch (password.cseType, password.sseType) {
                        case ("none", "none"),
                            ("none", "unknown"):
                            Text("-")
                        case (_, "none"),
                            (_, "unknown"):
                            Text("_clientSide")
                        case ("none", _):
                            Text("_serverSide")
                        case (_, _):
                            Text("\("_clientSide".localized) & \("_serverSide".localized)")
                        }
                    }
                    if let folders = entriesController.folders {
                        labeledFootnote("_folder") {
                            FlowView(spacing: 5, alignment: .trailing) {
                                ForEach(password.ancestors(in: folders)) {
                                    ancestor in
                                    HStack(spacing: 5) {
                                        Text(ancestor.label)
                                        if password.folder != ancestor.id {
                                            Image(systemName: "chevron.forward")
                                                .foregroundColor(Color(.systemGray))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Divider()
                    if !password.id.isEmpty {
                        labeledFootnote("_id") {
                            Text(password.id.uppercased())
                                .apply { view in
                                    if #available(iOS 17, *) {
                                        view
                                            .typesettingLanguage(.init(languageCode: .unavailable))
                                    }
                                }
                        }
                    }
                    labeledFootnote("_hash") {
                        Text(Crypto.SHA1.hash(.init(password.password.utf8), humanReadable: true))
                            .apply { view in
                                if #available(iOS 17, *) {
                                    view
                                        .typesettingLanguage(.init(languageCode: .unavailable))
                                }
                            }
                    }
                }
                .frame(width: sectionWidth)
                .frame(maxWidth: .infinity)
                .listRowInsets(EdgeInsets(top: 8, leading: -4, bottom: 8, trailing: 16))
            } label: {
                Text("_metadata")
                    .foregroundColor(.gray)
                    .apply { view in
                        if #available(iOS 26, *) {
                            view
                                .font(.headline)
                        } else {
                            view
                                .textCase(.uppercase)
                                .font(.footnote)
                        }
                    }
            }
        }
    }
    
    private func labeledFootnote<Content: View>(_ labelKey: LocalizedStringKey, @ContentBuilder content: () -> Content) -> some View {
        HStack(alignment: .top) {
            Text(labelKey)
                .font(.footnote)
                .foregroundColor(.gray)
            Spacer()
            content()
                .font(.footnote)
                .multilineTextAlignment(.trailing)
                .imageScale(.medium)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private func selectBar(geometryProxy: GeometryProxy, complete: @escaping (String, String) -> Void) -> some View {
        VStack {
            VStack {
                selectButton(complete: complete)
            }
            .padding()
        }
        .padding(.bottom, geometryProxy.safeAreaInsets.bottom)
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    func selectButton(complete: @escaping (String, String) -> Void) -> some View {
        Button {
            switch autoFillController.mode {
            case .app:
                complete(password.id, "")
            case .provider:
                complete(password.username, password.password)
            case .extension:
                guard let currentOtp = password.otp?.current else {
                    return
                }
                complete(password.username, currentOtp)
            }
        } label: {
            Text(autoFillController.mode == .extension && !autoFillController.hasField ? "_copyOtp" : "_select")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 34)
        }
        .apply { view in
            if #available(iOS 26, *) {
                view
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.glassProminent)
            } else {
                view
                    .buttonStyle(.action)
            }
        }
        .disabled(password.state == .decryptionFailed)
    }
    
    @available(iOS 26, *) @ContentBuilder private func stateToolbar() -> some ToolbarContent {
        if let state = password.state {
            if state.isError {
                ToolbarItem(placement: .primaryAction) {
                    errorButton(state: state)
                }
                .sharedBackgroundVisibility(.hidden)
            }
            else if state.isProcessing {
                ToolbarItem(placement: .primaryAction) {
                    ProgressView()
                }
                .sharedBackgroundVisibility(.hidden)
            }
        }
        ToolbarItem(placement: .primaryAction) {
            passwordStatusIcon()
        }
        .sharedBackgroundVisibility(.hidden)
    }
    
    @ContentBuilder private func stateView() -> some View {
        if let state = password.state {
            if state.isError {
                errorButton(state: state)
            }
            else if state.isProcessing {
                ProgressView()
            }
        }
    }
    
    private func editButton() -> some View {
        Button(action: {
            showEditPasswordView = true
        }, label: {
            Label("_edit", systemImage: "square.and.pencil")
                .apply { view in
                    if #unavailable(iOS 26) {
                        view
                            .labelStyle(.titleOnly)
                    }
                }
        })
        .disabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
        .accessibility(identifier: "editPasswordButton")
    }
    
    private func errorButton(state: Entry.State) -> some View {
        Button {
            showErrorAlert = true
        }
        label: {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(state == .deletionFailed ? .gray : .red)
        }
        .buttonStyle(.borderless)
        .alert(isPresented: $showErrorAlert) {
            switch state {
            case .creationFailed:
                return Alert(title: Text("_error"), message: Text("_createPasswordErrorMessage"))
            case .updateFailed:
                return Alert(title: Text("_error"), message: Text("_editPasswordErrorMessage"))
            case .deletionFailed:
                return Alert(title: Text("_error"), message: Text("_deletePasswordErrorMessage"))
            case .decryptionFailed:
                return Alert(title: Text("_error"), message: Text("_decryptPasswordErrorMessage"))
            default:
                return Alert(title: Text("_error"))
            }
        }
    }
    
    // MARK: Functions
    
    private func requestFavicon() {
        guard let domain = URL(string: password.url)?.host ?? URL(string: "https://\(password.url)")?.host,
              let session = sessionController.session else {
            return
        }
        FaviconServiceRequest(session: session, domain: domain).send { favicon = $0 }
    }
    
    private func toggleFavorite() {
        password.updated = Date()
        password.favorite.toggle()
        entriesController.update(password: password)
    }
    
}


extension PasswordDetailPage {
    
    private enum NavigationSelection: Hashable {
        
        case entries(tag: Tag)
        case duplicate(password: Password)
        
    }
    
}


extension PasswordDetailPage {
    
    private struct PasswordRow: View {
        
        let label: String
        let username: String
        let url: String
        
        @EnvironmentObject private var sessionController: SessionController
        
        @State private var favicon: UIImage?
        
        var body: some View {
            HStack {
                Image(uiImage: favicon ?? UIImage())
                    .resizable()
                    .frame(width: 40, height: 40)
                    .background(favicon == nil ? Color(white: 0.5, opacity: 0.2) : nil)
                    .apply { view in
                        if #available(iOS 26, *) {
                            view
                                .cornerRadius(6)
                        } else {
                            view
                                .cornerRadius(3.75)
                        }
                    }
                    .onAppear {
                        requestFavicon()
                    }
                Spacer(minLength: 12)
                VStack(alignment: .leading) {
                    Text(!label.isEmpty ? label : "-")
                        .lineLimit(1)
                    if !username.isEmpty {
                        Text(username)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                            .apply { view in
                                if #available(iOS 17, *) {
                                    view
                                        .typesettingLanguage(.init(languageCode: .unavailable))
                                }
                            }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        
        // MARK: Functions
        
        private func requestFavicon() {
            guard let domain = URL(string: url)?.host ?? URL(string: "https://\(url)")?.host,
                  let session = sessionController.session else {
                return
            }
            FaviconServiceRequest(session: session, domain: domain).send { favicon = $0 }
        }
        
    }
    
}
