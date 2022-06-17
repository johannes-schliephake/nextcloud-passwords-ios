import SwiftUI


struct OTPDisplay<Content: View>: View {
    
    let otp: OTP
    let updateOtp: (OTP) -> Void
    @ViewBuilder let content: (String?, AnyView) -> Content
    
    @State private var totpAge: Double?
    
    // MARK: Views
    
    var body: some View {
        content(otp.current, AnyView(accessoryView()))
    }
    
    @ViewBuilder private func accessoryView() -> some View {
        switch otp.type {
        case .hotp:
            Button {
                increaseHotp(otp)
            }
            label: {
                Image(systemName: "forward")
            }
            .buttonStyle(.borderless)
        case .totp:
            ZStack {
                Circle()
                    .stroke(Color(.tertiarySystemGroupedBackground), lineWidth: 1.5)
                    .frame(width: 18, height: 18)
                if let totpAge {
                    Circle()
                        .trim(from: 0, to: 1 - totpAge / Double(otp.period))
                        .stroke(style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                        .frame(width: 18, height: 18)
                        .rotationEffect(.degrees(-90))
                        .scaleEffect(x: -1)
                        .foregroundColor(.accentColor)
                }
            }
            .onAppear {
                updateTotp(otp, date: Date(), isInitial: true)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) {
                _ in
                updateTotp(otp, date: Date(), isInitial: true)
            }
            .onChange(of: otp.period) {
                _ in
                updateTotp(otp, date: Date(), isInitial: true)
            }
            .onDisappear {
                updateTotp(otp, date: nil)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) {
                _ in
                updateTotp(otp, date: nil)
            }
            .onReceive(OTP.clock) {
                date in
                updateTotp(otp, date: date)
            }
        }
    }
    
    // MARK: Functions
    
    private func increaseHotp(_ hotp: OTP) {
        updateOtp(hotp.next())
    }
    
    private func updateTotp(_ totp: OTP, date: Date?, isInitial: Bool = false) {
        guard let date else {
            totpAge = nil
            return
        }
        guard isInitial || totpAge != nil && Int(date.timeIntervalSince1970).isMultiple(of: totp.period) else {
            return
        }
        let period = Double(totp.period)
        let age = date.timeIntervalSince1970.truncatingRemainder(dividingBy: period)
        totpAge = age
        withAnimation(.linear(duration: period - age)) {
            totpAge = period
        }
    }
    
}
