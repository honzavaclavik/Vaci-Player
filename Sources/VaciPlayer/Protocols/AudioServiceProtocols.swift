import Foundation
import Combine
import AVFoundation

// MARK: - Domain Layer Protocols

protocol AudioInputServiceProtocol: ObservableObject {
    var isInputEnabled: Bool { get }
    var inputGain: Float { get }
    var inputVolume: Float { get }
    var inputLevel: Float { get }
    var reverbAmount: Float { get }
    var selectedInputDevice: AVAudioDevice? { get }
    var availableInputDevices: [AVAudioDevice] { get }
    
    func toggle()
    func enable()
    func disable()
    func setGain(_ gain: Float)
    func setVolume(_ volume: Float)
    func setReverbAmount(_ amount: Float)
    func selectInputDevice(_ device: AVAudioDevice?)
}

protocol AudioDeviceManagerProtocol {
    var availableInputDevices: [AVAudioDevice] { get }
    func enumerateInputDevices() -> [AVAudioDevice]
    func selectDevice(_ device: AVAudioDevice?)
}

protocol AudioProcessorProtocol {
    func setupAudioChain(inputNode: AVAudioInputNode, outputNode: AVAudioMixerNode) throws
    func updateGain(_ gain: Float)
    func updateVolume(_ volume: Float)
    func updateReverbAmount(_ amount: Float)
    func updateEQBands(_ bands: [Float])
    func teardownAudioChain()
}

protocol SettingsStoreProtocol {
    func setValue<T>(_ value: T, forKey key: String)
    func getValue<T>(forKey key: String, defaultValue: T) -> T
    func removeValue(forKey key: String)
}

// MARK: - Audio State

struct AudioInputState {
    let isEnabled: Bool
    let inputGain: Float
    let inputVolume: Float
    let inputLevel: Float
    let reverbAmount: Float
    let selectedDevice: AVAudioDevice?
    let availableDevices: [AVAudioDevice]
    
    static let initial = AudioInputState(
        isEnabled: false,
        inputGain: -15.0,
        inputVolume: 0.8,
        inputLevel: 0.0,
        reverbAmount: 0.0,
        selectedDevice: nil,
        availableDevices: []
    )
}

// MARK: - EQ Protocols

protocol EQManagerProtocol: ObservableObject {
    var bandCount: Int { get }
    func getBand(at index: Int) -> Float
    func setBand(at index: Int, gain: Float)
    func getBandConfiguration(at index: Int) -> EQBandConfiguration?
    func applyPreset(_ presetName: String)
    func resetAllBands()
    var availablePresets: [String] { get }
    var currentValues: [Float] { get }
}

struct EQBandConfiguration {
    let frequency: Float
    let displayName: String
    let filterType: AVAudioUnitEQFilterType
    let color: String // Hex color for UI
    
    static let defaultBands: [EQBandConfiguration] = [
        EQBandConfiguration(frequency: 60, displayName: "60Hz", filterType: .highPass, color: "purple"),
        EQBandConfiguration(frequency: 170, displayName: "170Hz", filterType: .parametric, color: "blue"),
        EQBandConfiguration(frequency: 310, displayName: "310Hz", filterType: .parametric, color: "cyan"),
        EQBandConfiguration(frequency: 600, displayName: "600Hz", filterType: .parametric, color: "green"),
        EQBandConfiguration(frequency: 1000, displayName: "1kHz", filterType: .parametric, color: "yellow"),
        EQBandConfiguration(frequency: 3000, displayName: "3kHz", filterType: .parametric, color: "orange"),
        EQBandConfiguration(frequency: 6000, displayName: "6kHz", filterType: .parametric, color: "red"),
        EQBandConfiguration(frequency: 12000, displayName: "12kHz", filterType: .highShelf, color: "pink")
    ]
}