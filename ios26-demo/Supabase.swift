import Supabase
import Foundation

class SupabaseClientManager {
    static let shared = SupabaseClientManager()

    let client: SupabaseClient
    let supabaseURL: URL
    let supabaseKey: String

    private init() {
        self.supabaseURL = URL(string: "https://ftftoaaxxdgaszdjbeci.supabase.co")!
        self.supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ0ZnRvYWF4eGRnYXN6ZGpiZWNpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE2NTM3NDEsImV4cCI6MjA2NzIyOTc0MX0.OyTVHGk056foqBVWJ8ar4GX3A8UnXGWtQJw0S2Sajgc"
        self.client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }
}
