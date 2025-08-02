import SwiftUI


struct OTPDisplay<Content: View>: View {
    
    let otp: OTP
    let updateOtp: (OTP) -> Void
    @ViewBuilder let content: (String?, String?, AnyView) -> Content
    
    @State private var current: String?
    @State private var upcoming: String?
    @State private var totpAge: Double?
    
    // MARK: Views
    
    var body: some View {
        content(current, upcoming, AnyView(accessoryView()))
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
            .task(id: otp) {
                current = otp.current
            }
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
            .task(id: otp) {
                updateTotp(otp, date: Date(), isInitial: true)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) {
                _ in
                updateTotp(otp, date: Date(), isInitial: true)
            }
            .onDisappear {
                updateTotp(otp, date: nil)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) {
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
        withAnimation(isInitial ? nil : .default) {
            current = otp.current
            upcoming = otp.upcoming
        }
        let period = Double(totp.period)
        let age = date.timeIntervalSince1970.truncatingRemainder(dividingBy: period)
        totpAge = age
        withAnimation(.linear(duration: period - age)) {
            totpAge = period
        }
    }
    
}
