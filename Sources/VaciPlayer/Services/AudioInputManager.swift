import Foundation
import AVFoundation
#if os(macOS)
import CoreAudio
#endif

class AudioInputManager: NSObject, ObservableObject {
    @Published var isInputEnabled: Bool = false
    @Published var isPanelVisible: Bool = false // Panel visibility persistence
    @Published var isPanelExpanded: Bool = false // Panel expansion state persistence
    @Published var availableInputDevices: [AVAudioDevice] = []
    @Published var selectedInputDevice: AVAudioDevice?
    @Published var selectedInputChannel: Int = 0 // Input channel selection
    @Published var inputGain: Float = -15.0 // in dB (-30 to +15), inspired by Bass Pro settings
    @Published var inputVolume: Float = 0.8 // 0.0 to 1.0, default 80% like GuitarAmp
    @Published var inputLevel: Float = 0.0 // Visual level meter
    @Published var availableChannels: [Int] = [] // Available input channels for selected device
    
    // EQ Manager (separate component)
    @Published var eqManager = GuitarEQManager()
    
    // Modulation Effects
    @Published var reverbAmount: Float = 0.0 // Reverb wetness (0.0 to 1.0)
    @Published var reverbRoomSize: Float = 0.5 // Room size (0.0 to 1.0)
    
    // Audio effects for guitar amp processing
    private var gainEffect = AVAudioUnitDistortion()
    private var eqEffect = AVAudioUnitEQ(numberOfBands: 8) // 8-band parametric EQ
    private var reverbEffect = AVAudioUnitReverb()
    private var outputMixer = AVAudioMixerNode() // Output with pan control
    private var stereoConverter: AVAudioSourceNode? // Custom stereo converter
    
    // Reference to main audio manager
    private weak var audioManager: AudioManager?
    
    // Level monitoring
    private var levelTimer: Timer?
    private var averagePowerLevels: [Float] = []
    
    init(audioManager: AudioManager) {
        super.init()
        print("Initializing AudioInputManager...")
        
        self.audioManager = audioManager
        isInputEnabled = false
        
        // Inicializujeme v bezpečném pořadí
        enumerateInputDevices()
        setupEffects()
        loadSettings()
        
        print("AudioInputManager initialized successfully with stereo conversion 🎸🔊")
    }
    
    
    deinit {
        print("Deinitializing AudioInputManager...")
        stopInputMonitoring()
        disable()
        isInputEnabled = false
    }
    
    // MARK: - Audio Device Management
    
    private func enumerateInputDevices() {
        print("Enumerating input devices...")
        #if os(macOS)
        // On macOS, use AudioUnit and CoreAudio for device enumeration
        do {
            var propertyAddress = AudioObjectPropertyAddress(
                mSelector: kAudioHardwarePropertyDevices,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMain
            )
            
            var propertySize: UInt32 = 0
            var result = AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &propertySize)
            
            guard result == noErr else {
                print("Error getting audio devices property size: \(result)")
                return
            }
            
            let deviceCount = Int(propertySize) / MemoryLayout<AudioDeviceID>.size
            guard deviceCount > 0 else {
                print("No audio devices found")
                return
            }
            
            var devices = [AudioDeviceID](repeating: 0, count: deviceCount)
            
            result = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &propertySize, &devices)
            
            guard result == noErr else {
                print("Error getting audio devices: \(result)")
                return
            }
            
            var inputDevices: [AVAudioDevice] = []
            
            for deviceID in devices {
                // Check if device has input streams
                propertyAddress.mSelector = kAudioDevicePropertyStreams
                propertyAddress.mScope = kAudioDevicePropertyScopeInput
                
                result = AudioObjectGetPropertyDataSize(deviceID, &propertyAddress, 0, nil, &propertySize)
                
                if result == noErr && propertySize > 0 {
                    // Get device name safely
                    if let deviceName = getDeviceName(for: deviceID) {
                        // Get number of input channels for this device
                        let channelCount = getInputChannelCount(for: deviceID)
                        let device = AVAudioDevice(deviceID: deviceID, name: deviceName, channelCount: channelCount)
                        inputDevices.append(device)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.availableInputDevices = inputDevices
                print("✅ Found \(inputDevices.count) input devices:")
                for device in inputDevices {
                    print("  - \(device.name) (channels: \(device.channelCount))")
                }
            }
        }
        #else
        // iOS/tvOS implementation using AVAudioSession
        let audioSession = AVAudioSession.sharedInstance()
        do {
            let availableInputs = try audioSession.availableInputs ?? []
            DispatchQueue.main.async {
                self.availableInputDevices = availableInputs.compactMap { input in
                    // For iOS, assume stereo input for most devices
                    let channelCount = input.channels?.count ?? 2
                    return AVAudioDevice(portDescription: input, channelCount: channelCount)
                }
            }
        } catch {
            print("Error enumerating input devices: \(error)")
        }
        #endif
    }
    
    #if os(macOS)
    private func getDeviceName(for deviceID: AudioDeviceID) -> String? {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceNameCFString,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var deviceName: CFString = "" as CFString
        var nameSize = UInt32(MemoryLayout<CFString>.size)
        
        let result = AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &nameSize, &deviceName)
        
        guard result == noErr else {
            print("Error getting device name for deviceID \(deviceID): \(result)")
            return nil
        }
        
        return deviceName as String
    }
    
    private func getInputChannelCount(for deviceID: AudioDeviceID) -> Int {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreamConfiguration,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var propertySize: UInt32 = 0
        let result = AudioObjectGetPropertyDataSize(deviceID, &propertyAddress, 0, nil, &propertySize)
        
        guard result == noErr else { return 1 }
        
        let bufferList = UnsafeMutablePointer<AudioBufferList>.allocate(capacity: 1)
        defer { bufferList.deallocate() }
        
        let getResult = AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &propertySize, bufferList)
        guard getResult == noErr else { return 1 }
        
        let buffers = UnsafeMutableAudioBufferListPointer(bufferList)
        var totalChannels = 0
        
        for buffer in buffers {
            totalChannels += Int(buffer.mNumberChannels)
        }
        
        return max(1, totalChannels)
    }
    #endif
    
    func selectInputDevice(_ device: AVAudioDevice?) {
        print("Selecting input device: \(device?.name ?? "None")")
        
        selectedInputDevice = device
        
        // Update available channels for the selected device
        if let device = device {
            availableChannels = Array(0..<device.channelCount)
            // Reset to first channel if current selection is out of range
            if selectedInputChannel >= device.channelCount {
                selectedInputChannel = 0
            }
            print("  - Channels available: \(device.channelCount)")
            print("  - Selected channel: \(selectedInputChannel)")
        } else {
            availableChannels = []
            selectedInputChannel = 0
            print("  - No device selected")
        }
        
        setupInputDevice()
        saveSettings()
    }
    
    func selectInputChannel(_ channel: Int) {
        guard let device = selectedInputDevice,
              channel < device.channelCount else { return }
        
        selectedInputChannel = channel
        setupInputDevice()
        saveSettings()
    }
    
    private func setupInputDevice() {
        guard let device = selectedInputDevice else { return }
        
        #if os(macOS)
        // On macOS, set the default input device using CoreAudio
        if let deviceID = device.deviceID {
            var propertyAddress = AudioObjectPropertyAddress(
                mSelector: kAudioHardwarePropertyDefaultInputDevice,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMain
            )
            
            var deviceIDValue = deviceID
            let result = AudioObjectSetPropertyData(
                AudioObjectID(kAudioObjectSystemObject),
                &propertyAddress,
                0,
                nil,
                UInt32(MemoryLayout<AudioDeviceID>.size),
                &deviceIDValue
            )
            
            if result != noErr {
                print("Error setting default input device: \(result)")
            }
        }
        #else
        // iOS/tvOS implementation
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setPreferredInput(device.portDescription)
        } catch {
            print("Error setting up input device: \(error)")
        }
        #endif
        
        // Restart input engine with new device
        if isInputEnabled {
            disable()
            enable()
        }
    }
    
    // MARK: - Effects Setup
    
    private func setupEffects() {
        print("Setting up guitar amp effects...")
        
        // Configure gain effect as clean amplifier
        gainEffect.wetDryMix = 0 // Clean signal only
        gainEffect.preGain = inputGain
        
        // Setup 4-band EQ (Bass Pro inspired)
        setupEQ()
        
        // Setup reverb/ambience
        setupReverb()
        
        // Setup custom stereo converter
        setupStereoConverter()
        
        // Set volume and pan to center for stereo spread
        outputMixer.outputVolume = inputVolume
        outputMixer.pan = 0.0 // Center position
        
        print("✅ Effects setup completed with stereo conversion 🎸🔊")
    }
    
    private func setupEQ() {
        // Configure 8-band parametric EQ using eqManager values
        let bands = eqEffect.bands
        let eqValues = eqManager.currentValues
        let frequencies: [Float] = [60, 170, 310, 600, 1000, 3000, 6000, 12000]
        let filterTypes: [AVAudioUnitEQFilterType] = [
            .highPass, .parametric, .parametric, .parametric, 
            .parametric, .parametric, .parametric, .highShelf
        ]
        
        if bands.count >= 8 {
            for i in 0..<8 {
                bands[i].filterType = filterTypes[i]
                bands[i].frequency = frequencies[i]
                bands[i].gain = eqValues[i]
                bands[i].bandwidth = i == 1 ? 1.2 : 1.0
                bands[i].bypass = false
            }
        }
    }
    
    private func setupReverb() {
        // Standard reverb setup - user controls wet/dry mix normally
        let wetMix = reverbAmount * 100 // 0% to 100%
        reverbEffect.wetDryMix = wetMix
        reverbEffect.loadFactoryPreset(.mediumRoom)
        print("🌊 Reverb wet mix: \(wetMix)%")
    }
    
    private func setupStereoConverter() {
        // We'll use reverb for stereo conversion but set a proper mix
        // The key insight: reverb effect automatically converts mono to stereo
        // even with minimal wet mix, maintaining the dry signal in stereo
        print("🔄 Using reverb effect for stereo conversion")
    }
    

    
    
    
    // MARK: - Input Control
    
    func toggle() {
        if isInputEnabled {
            disable()
        } else {
            enable()
        }
    }
    
    func enable() {
        guard let audioEngine = audioManager?.getAudioEngine(),
              let mainMixerNode = audioManager?.getMainMixerNode() else {
            print("❌ AudioEngine not available")
            return
        }
        
        guard !isInputEnabled else {
            print("⚠️ Guitar amp already enabled")
            return
        }
        
        do {
            // Stop engine temporarily for configuration
            let wasRunning = audioEngine.isRunning
            if wasRunning {
                audioEngine.stop()
            }
            
            // Attach nodes if not already attached
            if !audioEngine.attachedNodes.contains(gainEffect) {
                audioEngine.attach(gainEffect)
            }
            if !audioEngine.attachedNodes.contains(eqEffect) {
                audioEngine.attach(eqEffect)
            }
            if !audioEngine.attachedNodes.contains(reverbEffect) {
                audioEngine.attach(reverbEffect)
            }
            if !audioEngine.attachedNodes.contains(outputMixer) {
                audioEngine.attach(outputMixer)
            }
            
            let inputNode = audioEngine.inputNode
            let inputFormat = inputNode.outputFormat(forBus: 0)
            let stereoFormat = AVAudioFormat(standardFormatWithSampleRate: inputFormat.sampleRate, channels: 2)!
            
            // Audio chain: Input → Gain → EQ → Reverb (automatic stereo conversion) → Output → MainMixer  
            // AVAudioUnitReverb automatically converts mono input to stereo output
            audioEngine.connect(inputNode, to: gainEffect, format: inputFormat)
            audioEngine.connect(gainEffect, to: eqEffect, format: inputFormat)
            audioEngine.connect(eqEffect, to: reverbEffect, format: inputFormat)
            audioEngine.connect(reverbEffect, to: outputMixer, format: stereoFormat)
            audioEngine.connect(outputMixer, to: mainMixerNode, format: stereoFormat)
            
            // Configure output mixer for stereo distribution
            outputMixer.outputVolume = inputVolume
            outputMixer.pan = 0.0 // Center pan for both channels (stereo from stereoConverter)
            
            print("🔗 Audio chain: Input → Gain → EQ → Reverb (stereo conversion) → OutputMixer → MainMixer 🎸🔊")
            
            // Restart engine if it was running
            if wasRunning {
                try audioEngine.start()
            }
            
            isInputEnabled = true
            startInputMonitoring()
            saveSettings()
            print("✅ Guitar amp enabled with stereo conversion - You should hear your input in both channels now! 🎸🔊")
            print("🎚️ Gain: \(inputGain)dB, Volume: \(Int(inputVolume * 100))%")
            
        } catch {
            print("❌ Failed to enable guitar amp: \(error)")
            isInputEnabled = false
        }
    }
    
    func disable() {
        guard let audioEngine = audioManager?.getAudioEngine() else { return }
        guard isInputEnabled else {
            print("⚠️ Guitar amp already disabled")
            return
        }
        
        // Stop engine temporarily for disconnection
        let wasRunning = audioEngine.isRunning
        if wasRunning {
            audioEngine.stop()
        }
        
        // Disconnect and detach nodes
        audioEngine.disconnectNodeInput(outputMixer)
        audioEngine.disconnectNodeInput(reverbEffect)
        audioEngine.disconnectNodeInput(eqEffect)
        audioEngine.disconnectNodeInput(gainEffect)
        audioEngine.detach(outputMixer)
        audioEngine.detach(reverbEffect)
        audioEngine.detach(eqEffect)
        audioEngine.detach(gainEffect)
        
        // Restart engine if it was running
        if wasRunning {
            do {
                try audioEngine.start()
            } catch {
                print("❌ Failed to restart audio engine: \(error)")
            }
        }
        
        isInputEnabled = false
        stopInputMonitoring()
        saveSettings()
        print("🔇 Guitar amp disabled")
    }
    
    // MARK: - Audio Processing Controls
    
    func setGain(_ gainDB: Float) {
        let clampedGain = max(-30, min(15, gainDB)) // Reasonable range like Bass Pro: -30 to +15dB
        inputGain = clampedGain
        gainEffect.preGain = clampedGain
        saveSettings()
        print("🎚️ Input gain: \(clampedGain)dB")
    }
    
    func setVolume(_ volume: Float) {
        let clampedVolume = max(0.0, min(1.0, volume))
        inputVolume = clampedVolume
        outputMixer.outputVolume = clampedVolume
        saveSettings()
        print("🔊 Input volume: \(Int(clampedVolume * 100))%")
    }
    
    // MARK: - EQ Controls (delegated to EQManager)
    
    func updateEQFromManager() {
        setupEQ()
        print("🎚️ EQ updated from manager")
    }
    
    // MARK: - Modulation Controls
    
    func setReverbAmount(_ amount: Float) {
        let clampedAmount = max(0.0, min(1.0, amount))
        reverbAmount = clampedAmount
        reverbEffect.wetDryMix = clampedAmount * 100
        saveSettings()
        print("🌊 Reverb: \(Int(clampedAmount * 100))%")
    }
    
    func status() {
        print("\n📊 Guitar Amp Status:")
        print("  Running: \(isInputEnabled ? "✅ YES" : "❌ NO")")
        print("  Gain: \(inputGain)dB, Volume: \(Int(inputVolume * 100))%")
        eqManager.printStatus()
        print("  Reverb: \(Int(reverbAmount * 100))%")
        print("  Stereo: ✅ Automatic stereo conversion via reverb effect (mono→stereo) 🎸🔊")
        if let audioEngine = audioManager?.getAudioEngine() {
            print("  Engine: \(audioEngine.isRunning ? "🟢 Running" : "🔴 Stopped")")
        }
    }
    
    // MARK: - Level Monitoring
    
    private func startInputMonitoring() {
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updateInputLevel()
        }
    }
    
    private func stopInputMonitoring() {
        levelTimer?.invalidate()
        levelTimer = nil
        inputLevel = 0.0
    }
    
    private func updateInputLevel() {
        guard isInputEnabled,
              let audioEngine = audioManager?.getAudioEngine(),
              audioEngine.isRunning else {
            inputLevel = 0.0
            return
        }
        
        // Simplified level monitoring
        let currentLevel = audioEngine.inputNode.volume
        averagePowerLevels.append(currentLevel)
        
        if averagePowerLevels.count > 10 {
            averagePowerLevels.removeFirst()
        }
        
        let averageLevel = averagePowerLevels.reduce(0, +) / Float(averagePowerLevels.count)
        
        DispatchQueue.main.async {
            self.inputLevel = averageLevel
        }
    }
    
    // MARK: - Panel Control
    
    func togglePanelVisibility() {
        isPanelVisible.toggle()
        savePanelSettings()
    }
    
    func togglePanelExpansion() {
        isPanelExpanded.toggle()
        savePanelSettings()
    }
    
    func setPanelVisible(_ visible: Bool) {
        isPanelVisible = visible
        savePanelSettings()
    }
    
    func setPanelExpanded(_ expanded: Bool) {
        isPanelExpanded = expanded
        savePanelSettings()
    }
    
    // MARK: - Settings Persistence
    
    private func saveSettings() {
        UserDefaults.standard.set(inputGain, forKey: "guitarAmp_gain")
        UserDefaults.standard.set(inputVolume, forKey: "guitarAmp_volume")
        UserDefaults.standard.set(reverbAmount, forKey: "guitarAmp_reverbAmount")
        // Nikdy neuložíme isInputEnabled - vždy startujeme s vypnutým amp
        UserDefaults.standard.set(selectedInputChannel, forKey: "guitarAmp_selectedChannel")
        
        if let deviceIdentifier = selectedInputDevice?.identifier {
            UserDefaults.standard.set(deviceIdentifier, forKey: "guitarAmp_selectedDevice")
        }
    }
    
    private func savePanelSettings() {
        UserDefaults.standard.set(isPanelVisible, forKey: "guitarAmp_panelVisible")
        UserDefaults.standard.set(isPanelExpanded, forKey: "guitarAmp_panelExpanded")
    }
    
    private func loadSettings() {
        inputGain = UserDefaults.standard.object(forKey: "guitarAmp_gain") as? Float ?? -15.0
        inputVolume = UserDefaults.standard.object(forKey: "guitarAmp_volume") as? Float ?? 0.8
        // EQ settings are now managed by eqManager
        reverbAmount = UserDefaults.standard.object(forKey: "guitarAmp_reverbAmount") as? Float ?? 0.0
        // Vždy začneme s vypnutým guitar amp
        isInputEnabled = false
        isPanelVisible = UserDefaults.standard.bool(forKey: "guitarAmp_panelVisible")
        isPanelExpanded = UserDefaults.standard.bool(forKey: "guitarAmp_panelExpanded")
        selectedInputChannel = UserDefaults.standard.integer(forKey: "guitarAmp_selectedChannel")
        
        if let deviceIdentifier = UserDefaults.standard.string(forKey: "guitarAmp_selectedDevice") {
            selectedInputDevice = availableInputDevices.first { $0.identifier == deviceIdentifier }
            // Update available channels for loaded device
            if let device = selectedInputDevice {
                availableChannels = Array(0..<device.channelCount)
                // Ensure selected channel is valid
                if selectedInputChannel >= device.channelCount {
                    selectedInputChannel = 0
                }
            }
        }
        
        // Apply loaded settings to effects
        setupEffects()
    }
}

// MARK: - AVAudioDevice Helper

struct AVAudioDevice: Identifiable, Hashable {
    let id = UUID()
    
    #if os(macOS)
    let deviceID: AudioDeviceID?
    let deviceName: String
    let channelCount: Int
    
    init(deviceID: AudioDeviceID, name: String, channelCount: Int = 1) {
        self.deviceID = deviceID
        self.deviceName = name
        self.channelCount = channelCount
    }
    
    var name: String {
        return deviceName
    }
    
    var portType: String {
        return "Audio Input"
    }
    
    var identifier: String {
        return "\(deviceID ?? 0)"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(deviceID)
    }
    
    static func == (lhs: AVAudioDevice, rhs: AVAudioDevice) -> Bool {
        lhs.deviceID == rhs.deviceID
    }
    #else
    let portDescription: AVAudioSessionPortDescription?
    let channelCount: Int
    
    init(portDescription: AVAudioSessionPortDescription, channelCount: Int = 1) {
        self.portDescription = portDescription
        self.channelCount = channelCount
    }
    
    var name: String {
        portDescription?.portName ?? "Neznámé zařízení"
    }
    
    var portType: String {
        portDescription?.portType.rawValue ?? ""
    }
    
    var identifier: String {
        return portDescription?.uid ?? ""
    }
    
    var deviceID: AudioDeviceID? {
        return nil
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(portDescription?.uid)
    }
    
    static func == (lhs: AVAudioDevice, rhs: AVAudioDevice) -> Bool {
        lhs.portDescription?.uid == rhs.portDescription?.uid
    }
    #endif
}