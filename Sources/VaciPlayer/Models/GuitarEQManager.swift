import Foundation
import Combine
import AVFoundation

class GuitarEQManager: ObservableObject, EQManagerProtocol {
    
    // MARK: - Properties
    @Published private var bands: [Float]
    private let configurations: [EQBandConfiguration]
    private let settingsStore: SettingsStoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var bandCount: Int { configurations.count }
    
    // Legacy properties for backward compatibility
    var band60Hz: Float { getBand(at: 0) }
    var band170Hz: Float { getBand(at: 1) }
    var band310Hz: Float { getBand(at: 2) }
    var band600Hz: Float { getBand(at: 3) }
    var band1kHz: Float { getBand(at: 4) }
    var band3kHz: Float { getBand(at: 5) }
    var band6kHz: Float { getBand(at: 6) }
    var band12kHz: Float { getBand(at: 7) }
    
    // MARK: - Presets
    private let presets: [String: [Float]] = [
        "Flat": [0, 0, 0, 0, 0, 0, 0, 0],
        "Rock": [2, 1, -1, 3, 2, 4, 3, 2],
        "Jazz": [-2, 1, 2, 1, -1, 2, 1, -1],
        "Blues": [1, 2, 0, 2, 1, -1, 2, 1],
        "Metal": [3, -1, -2, 0, 2, 4, 5, 3],
        "Clean": [-1, 1, 2, 0, -1, 1, 2, 0],
        "Vintage": [2, 3, 1, -1, 0, 2, 1, -2],
        "Modern": [-2, 0, 1, 2, 3, 2, 4, 5]
    ]
    
    var availablePresets: [String] {
        Array(presets.keys.sorted())
    }
    
    // MARK: - Initialization
    
    init(settingsStore: SettingsStoreProtocol = UserDefaultsSettingsStore(), 
         configurations: [EQBandConfiguration] = EQBandConfiguration.defaultBands) {
        self.settingsStore = settingsStore
        self.configurations = configurations
        self.bands = Array(repeating: 0.0, count: configurations.count)
        
        loadSettings()
        setupAutoSave()
    }
    
    private func setupAutoSave() {
        $bands
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveSettings()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Band Configuration
    struct EQBand {
        let frequency: String
        let value: Float
        let setter: (Float) -> Void
    }
    
    func getAllBands() -> [EQBand] {
        return [
            EQBand(frequency: "60Hz", value: band60Hz, setter: setBand60Hz),
            EQBand(frequency: "170Hz", value: band170Hz, setter: setBand170Hz),
            EQBand(frequency: "310Hz", value: band310Hz, setter: setBand310Hz),
            EQBand(frequency: "600Hz", value: band600Hz, setter: setBand600Hz),
            EQBand(frequency: "1kHz", value: band1kHz, setter: setBand1kHz),
            EQBand(frequency: "3kHz", value: band3kHz, setter: setBand3kHz),
            EQBand(frequency: "6kHz", value: band6kHz, setter: setBand6kHz),
            EQBand(frequency: "12kHz", value: band12kHz, setter: setBand12kHz)
        ]
    }
    
    // MARK: - Protocol Implementation
    
    func getBand(at index: Int) -> Float {
        guard index >= 0 && index < bands.count else { return 0.0 }
        return bands[index]
    }
    
    func setBand(at index: Int, gain: Float) {
        guard index >= 0 && index < bands.count else { return }
        bands[index] = clampGain(gain)
        print("🎚️ \(configurations[index].displayName): \(bands[index])dB")
    }
    
    func getBandConfiguration(at index: Int) -> EQBandConfiguration? {
        guard index >= 0 && index < configurations.count else { return nil }
        return configurations[index]
    }
    
    // MARK: - Legacy Band Setters (for backward compatibility)
    func setBand60Hz(_ gain: Float) { setBand(at: 0, gain: gain) }
    func setBand170Hz(_ gain: Float) { setBand(at: 1, gain: gain) }
    func setBand310Hz(_ gain: Float) { setBand(at: 2, gain: gain) }
    func setBand600Hz(_ gain: Float) { setBand(at: 3, gain: gain) }
    func setBand1kHz(_ gain: Float) { setBand(at: 4, gain: gain) }
    func setBand3kHz(_ gain: Float) { setBand(at: 5, gain: gain) }
    func setBand6kHz(_ gain: Float) { setBand(at: 6, gain: gain) }
    func setBand12kHz(_ gain: Float) { setBand(at: 7, gain: gain) }
    
    // MARK: - Preset Management
    func applyPreset(_ presetName: String) {
        guard let values = presets[presetName], values.count == bands.count else { return }
        
        for (index, value) in values.enumerated() {
            setBand(at: index, gain: value)
        }
        
        print("🎚️ Applied EQ preset: \(presetName)")
    }
    
    func resetAllBands() {
        applyPreset("Flat")
    }
    
    // MARK: - Utility
    private func clampGain(_ gain: Float) -> Float {
        return max(-15, min(15, gain))
    }
    
    // MARK: - Persistence
    private func saveSettings() {
        for (index, band) in bands.enumerated() {
            let key = "guitarAmp_band\(index)"
            settingsStore.setValue(band, forKey: key)
        }
    }
    
    private func loadSettings() {
        for index in 0..<bands.count {
            let key = "guitarAmp_band\(index)"
            bands[index] = settingsStore.getValue(forKey: key, defaultValue: 0.0)
        }
    }
    
    // MARK: - Current Values Array
    var currentValues: [Float] {
        bands
    }
    
    // MARK: - Status Logging
    func printStatus() {
        print("🎚️ EQ Status:")
        for (index, band) in bands.enumerated() {
            let config = configurations[index]
            print("  \(config.displayName): \(band)dB")
        }
    }
}