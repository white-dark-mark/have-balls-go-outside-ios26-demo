import SwiftUI
import SwiftData
import Supabase
import Auth
import Foundation

struct OTPVerificationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let phoneNumber: String
    let userEmail: String
    let pendingUserData: User
    let onVerificationSuccess: () -> Void
    
    @State private var otpCode = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var isResending = false
    
    @StateObject private var translationManager = TranslationManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text(translationManager.translate("otp_verification"))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(translationManager.translate("otp_sent_message"))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Text(phoneNumber)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                .padding(.top, 40)
                
                // OTP Input Section
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(translationManager.translate("verification_code"))
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        TextField(translationManager.translate("enter_otp_code"), text: $otpCode)
                            .keyboardType(.numberPad)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.title2)
                            .fontWeight(.medium)
                            .textContentType(.oneTimeCode)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                    }
                    
                    // Verify Button
                    Button(action: verifyOTP) {
                        if isLoading {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                                Text(translationManager.translate("verifying"))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                        } else {
                            Text(translationManager.translate("verify_code"))
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .disabled(otpCode.isEmpty || isLoading)
                    .opacity(otpCode.isEmpty || isLoading ? 0.6 : 1.0)
                }
                .padding(.horizontal, 32)
                
                // Resend Code Section
                VStack(spacing: 16) {
                    Text(translationManager.translate("didnt_receive_code"))
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Button(action: resendOTP) {
                        if isResending {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                    .scaleEffect(0.8)
                                Text(translationManager.translate("resending"))
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                        } else {
                            Text(translationManager.translate("resend_code"))
                                .font(.body)
                                .fontWeight(.medium)
                        }
                    }
                    .foregroundColor(.blue)
                    .disabled(isResending)
                }
                
                Spacer()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(translationManager.translate("cancel")) {
                        dismiss()
                    }
                }
            }
        }
        .alert(translationManager.translate("verification"), isPresented: $showingAlert) {
            Button(translationManager.translate("done")) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func verifyOTP() {
        guard !otpCode.isEmpty else { return }
        
        isLoading = true
        
        Task {
            do {
                let client = SupabaseClientManager.shared.client
                
                // Verify OTP with Supabase
                let response = try await client.auth.verifyOTP(
                    phone: phoneNumber,
                    token: otpCode,
                    type: .sms
                )
                
                print("OTP verification successful for: \(response.user.email ?? "unknown")")
                
                // Call edge function to create user record
                await createUserRecord(authSession: response.session)
                
                await MainActor.run {
                    // Insert user data into model context after successful verification
                    modelContext.insert(pendingUserData)
                    
                    showAlert(message: translationManager.translate("verification_successful"))
                    
                    // Navigate back to main app after successful verification
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                        onVerificationSuccess()
                    }
                }
            } catch {
                print("OTP verification failed: \(error.localizedDescription)")
                await MainActor.run {
                    showAlert(message: translationManager.translate("verification_failed"))
                }
            }
            
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    private func resendOTP() {
        isResending = true
        
        Task {
            do {
                let client = SupabaseClientManager.shared.client
                
                // Resend OTP
                try await client.auth.signInWithOTP(phone: phoneNumber)
                
                await MainActor.run {
                    showAlert(message: translationManager.translate("otp_resent"))
                }
            } catch {
                print("Failed to resend OTP: \(error.localizedDescription)")
                await MainActor.run {
                    showAlert(message: translationManager.translate("otp_resend_failed"))
                }
            }
            
            await MainActor.run {
                isResending = false
            }
        }
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showingAlert = true
    }
    
    // MARK: - Edge Function Integration
    private func createUserRecord(authSession: Session?) async {
        guard let session = authSession else {
            print("❌ No auth session available")
            await MainActor.run {
                showAlert(message: translationManager.translate("verification_failed"))
            }
            return
        }
        
        do {
            let client = SupabaseClientManager.shared.client
            let supabaseManager = SupabaseClientManager.shared
            let url = URL(string: "\(supabaseManager.supabaseURL)/functions/v1/register-user")!
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let userData = [
                "phone": pendingUserData.phone,
                "firstName": pendingUserData.firstName,
                "lastName": pendingUserData.lastName,
                "nickname": pendingUserData.nickname,
                "sports": pendingUserData.sports,
                "cityNeighborhood": pendingUserData.cityNeighborhood,
                "email": userEmail.isEmpty ? nil : userEmail
            ] as [String: Any]
            
            let requestBody = ["userData": userData]
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            print("🚀 Calling edge function to create user record...")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📊 Edge function response status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 201 {
                    // Success
                    let responseData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    print("✅ User record created successfully: \(responseData?["message"] ?? "No message")")
                } else {
                    // Error response
                    let errorData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    let errorMessage = errorData?["error"] as? String ?? "Unknown error"
                    print("❌ Edge function error: \(errorMessage)")
                    
                    await MainActor.run {
                        showAlert(message: translationManager.translate("verification_failed"))
                    }
                }
            }
        } catch {
            print("❌ Failed to call edge function: \(error.localizedDescription)")
            await MainActor.run {
                showAlert(message: translationManager.translate("verification_failed"))
            }
        }
    }
}

#Preview {
    let sampleUser = User(
        phone: "+381601234567",
        firstName: "John",
        lastName: "Doe",
        nickname: "JohnD",
        sports: ["Soccer", "Basketball"],
        cityNeighborhood: "Belgrade"
    )
    
    OTPVerificationView(
        phoneNumber: "+381601234567", 
        userEmail: "test@example.com", 
        pendingUserData: sampleUser
    ) {
        // Preview completion callback
    }
    .modelContainer(for: User.self, inMemory: true)
} 
