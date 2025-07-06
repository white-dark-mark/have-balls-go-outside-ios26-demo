//
//  TranslationManager.swift
//  ios26-demo
//
//  Created by Marko Stankovic on 7/6/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Translation Manager
@MainActor
class TranslationManager: ObservableObject {
    static let shared = TranslationManager()
    
    @Published var currentLanguage: String = "en"
    @Published var translations: [String: [String: String]] = [:]
    @Published var isLoading = false
    
    private let translationAPI = "https://your-api.com/translations" // Replace with your API
    private let fallbackLanguage = "en"
    
    private init() {
        // Load saved language or detect system language
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") {
            currentLanguage = savedLanguage
        } else {
            currentLanguage = detectSystemLanguage()
        }
        
        loadTranslations()
    }
    
    // MARK: - Public Methods
    
    func translate(_ key: String, language: String? = nil) -> String {
        let lang = language ?? currentLanguage
        
        // Try current language first
        if let translation = translations[lang]?[key] {
            return translation
        }
        
        // Fallback to English
        if let fallback = translations[fallbackLanguage]?[key] {
            return fallback
        }
        
        // Return key if no translation found
        return key
    }
    
    func changeLanguage(to language: String) {
        currentLanguage = language
        UserDefaults.standard.set(language, forKey: "selectedLanguage")
        loadTranslations()
    }
    
    func getSupportedLanguages() -> [Language] {
        return [
            Language(code: "en", name: "English", flag: "🇺🇸"),
            Language(code: "sr", name: "Srpski", flag: "🇷🇸"),
            Language(code: "es", name: "Español", flag: "🇪🇸")
        ]
    }
    
    // MARK: - Private Methods
    
    private func loadTranslations() {
        isLoading = true
        
        // Try to load from API first
        loadFromAPI { [weak self] success in
            if !success {
                // Fallback to local JSON
                self?.loadFromLocalJSON()
            }
            self?.isLoading = false
        }
    }
    
    private func loadFromAPI(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: translationAPI) else {
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let data = data,
                   let translations = try? JSONDecoder().decode([String: [String: String]].self, from: data) {
                    self?.translations = translations
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }.resume()
    }
    
    private func loadFromLocalJSON() {
        // Load from local JSON file as fallback
        if let path = Bundle.main.path(forResource: "translations", ofType: "json"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let translations = try? JSONDecoder().decode([String: [String: String]].self, from: data) {
            self.translations = translations
        } else {
            // Hardcoded fallback
            loadHardcodedTranslations()
        }
    }
    
    private func loadHardcodedTranslations() {
        translations = [
            "en": [
                "sports_venues": "Sports Venues",
                "registration": "Registration",
                "community": "Community",
                "map": "Map",
                "soccer": "Soccer",
                "basketball": "Basketball",
                "phone_number": "Phone Number",
                "first_name": "First Name",
                "last_name": "Last Name",
                "nickname": "Nickname",
                "sports_you_play": "Sports You Play",
                "select_sports_hint": "Select at least one sport",
                "city_neighborhood": "City/Neighborhood",
                "register_button": "Register",
                "cancel": "Cancel",
                "done": "Done",
                "please_fill_required_fields": "Please fill in all required fields",
                "select_at_least_one_sport": "Please select at least one sport",
                "registration_successful": "Registration successful!",
                "welcome_message": "Welcome to the sports community!",
                "tennis": "Tennis",
                "baseball": "Baseball",
                "american_football": "American Football",
                "volleyball": "Volleyball",
                "swimming": "Swimming",
                "running": "Running",
                "cycling": "Cycling",
                "boxing": "Boxing",
                "martial_arts": "Martial Arts",
                "golf": "Golf",
                "ice_hockey": "Ice Hockey",
                "skiing": "Skiing",
                "snowboarding": "Snowboarding",
                "surfing": "Surfing",
                "skateboarding": "Skateboarding",
                "wrestling": "Wrestling",
                "weightlifting": "Weightlifting",
                "gym": "Gym",
                "gymnastics": "Gymnastics",
                "address": "Address",
                "description": "Description",
                "get_directions": "Get Directions",
                "join_game": "Join Game",
                "registered_users": "Registered Users",
                "no_users_registered": "No users registered yet",
                "sample_items": "Sample Items",
                "no_items": "No items",
                "add_item": "Add Item",
                "contact_info": "Contact Information",
                "sports_interests": "Sports Interests",
                "location_info": "Location",
                "select_language": "Select Language",
                "language": "Language"
            ],
            "sr": [
                "sports_venues": "Sportski objekti",
                "registration": "Registracija",
                "community": "Zajednica",
                "map": "Mapa",
                "soccer": "Fudbal",
                "basketball": "Košarka",
                "phone_number": "Broj telefona",
                "first_name": "Ime",
                "last_name": "Prezime",
                "nickname": "Nadimak",
                "sports_you_play": "Sportovi koje igraš",
                "select_sports_hint": "Izaberi najmanje jedan sport",
                "city_neighborhood": "Grad/Četvrt",
                "register_button": "Registruj se",
                "cancel": "Otkaži",
                "done": "Završeno",
                "please_fill_required_fields": "Molimo vas da popunite sva obavezna polja",
                "select_at_least_one_sport": "Molimo vas da izaberete najmanje jedan sport",
                "registration_successful": "Registracija uspešna!",
                "welcome_message": "Dobrodošli u sportsku zajednicu!",
                "tennis": "Tenis",
                "baseball": "Bejzbol",
                "american_football": "Američki fudbal",
                "volleyball": "Odbojka",
                "swimming": "Plivanje",
                "running": "Trčanje",
                "cycling": "Biciklizam",
                "boxing": "Boks",
                "martial_arts": "Borilačke veštine",
                "golf": "Golf",
                "ice_hockey": "Hokej na ledu",
                "skiing": "Skijanje",
                "snowboarding": "Snoubording",
                "surfing": "Surfovanje",
                "skateboarding": "Skejtbording",
                "wrestling": "Rvanje",
                "weightlifting": "Dizanje tegova",
                "gym": "Teretana",
                "gymnastics": "Gimnastika",
                "address": "Adresa",
                "description": "Opis",
                "get_directions": "Putanja",
                "join_game": "Pridruži se igri",
                "registered_users": "Registrovani korisnici",
                "no_users_registered": "Nema registrovanih korisnika",
                "sample_items": "Primeri stavki",
                "no_items": "Nema stavki",
                "add_item": "Dodaj stavku",
                "contact_info": "Kontakt informacije",
                "sports_interests": "Sportska interesovanja",
                "location_info": "Lokacija",
                "select_language": "Izaberite jezik",
                "language": "Jezik"
            ],
            "es": [
                "sports_venues": "Instalaciones Deportivas",
                "registration": "Registro",
                "community": "Comunidad",
                "map": "Mapa",
                "soccer": "Fútbol",
                "basketball": "Baloncesto",
                "phone_number": "Número de Teléfono",
                "first_name": "Nombre",
                "last_name": "Apellido",
                "nickname": "Apodo",
                "sports_you_play": "Deportes que Practicas",
                "select_sports_hint": "Selecciona al menos un deporte",
                "city_neighborhood": "Ciudad/Barrio",
                "register_button": "Registrarse",
                "cancel": "Cancelar",
                "done": "Hecho",
                "please_fill_required_fields": "Por favor, completa todos los campos requeridos",
                "select_at_least_one_sport": "Por favor, selecciona al menos un deporte",
                "registration_successful": "¡Registro exitoso!",
                "welcome_message": "¡Bienvenido a la comunidad deportiva!",
                "tennis": "Tenis",
                "baseball": "Béisbol",
                "american_football": "Fútbol Americano",
                "volleyball": "Voleibol",
                "swimming": "Natación",
                "running": "Correr",
                "cycling": "Ciclismo",
                "boxing": "Boxeo",
                "martial_arts": "Artes Marciales",
                "golf": "Golf",
                "ice_hockey": "Hockey sobre Hielo",
                "skiing": "Esquí",
                "snowboarding": "Snowboard",
                "surfing": "Surf",
                "skateboarding": "Skateboard",
                "wrestling": "Lucha",
                "weightlifting": "Levantamiento de Pesas",
                "gym": "Gimnasio",
                "gymnastics": "Gimnasia",
                "address": "Dirección",
                "description": "Descripción",
                "get_directions": "Obtener Direcciones",
                "join_game": "Unirse al Juego",
                "registered_users": "Usuarios Registrados",
                "no_users_registered": "No hay usuarios registrados aún",
                "sample_items": "Elementos de Muestra",
                "no_items": "No hay elementos",
                "add_item": "Agregar Elemento",
                "contact_info": "Información de Contacto",
                "sports_interests": "Intereses Deportivos",
                "location_info": "Ubicación",
                "select_language": "Seleccionar Idioma",
                "language": "Idioma"
            ]
        ]
    }
    
    private func detectSystemLanguage() -> String {
        let preferredLanguage = Locale.preferredLanguages.first ?? "en"
        let languageCode = String(preferredLanguage.prefix(2))
        
        // Check if we support this language
        let supportedLanguages = ["en", "sr", "es"]
        return supportedLanguages.contains(languageCode) ? languageCode : "en"
    }
}

// MARK: - Language Model
struct Language: Identifiable {
    let id = UUID()
    let code: String
    let name: String
    let flag: String
}

// MARK: - String Extension for New Translation System
extension String {
    var t: String {
        return TranslationManager.shared.translate(self)
    }
    
    func t(_ language: String) -> String {
        return TranslationManager.shared.translate(self, language: language)
    }
}

// MARK: - Reactive Translation View
struct ReactiveText: View {
    let key: String
    @StateObject private var translationManager = TranslationManager.shared
    
    init(_ key: String) {
        self.key = key
    }
    
    var body: some View {
        Text(translationManager.translate(key))
            .onReceive(translationManager.$currentLanguage) { _ in
                // This ensures the view updates when language changes
            }
    }
}

// MARK: - SwiftUI Translation View
struct T: View {
    let key: String
    let language: String?
    
    @StateObject private var translationManager = TranslationManager.shared
    
    init(_ key: String, language: String? = nil) {
        self.key = key
        self.language = language
    }
    
    var body: some View {
        Text(translationManager.translate(key, language: language))
            .onReceive(translationManager.$currentLanguage) { _ in
                // Refresh when language changes
            }
    }
}

// MARK: - Language Picker View
struct LanguagePickerView: View {
    @StateObject private var translationManager = TranslationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(translationManager.getSupportedLanguages()) { language in
                    Button(action: {
                        translationManager.changeLanguage(to: language.code)
                        dismiss()
                    }) {
                        HStack {
                            Text(language.flag)
                                .font(.title2)
                            
                            VStack(alignment: .leading) {
                                Text(language.name)
                                    .font(.headline)
                                Text(language.code.uppercased())
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if translationManager.currentLanguage == language.code {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle(translationManager.translate("select_language"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(translationManager.translate("done")) {
                        dismiss()
                    }
                }
            }
        }
    }
} 