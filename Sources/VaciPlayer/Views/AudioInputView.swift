import SwiftUI

struct AudioInputView: View {
    @ObservedObject var audioInputManager: AudioInputManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Expandable header bar (always visible when panel is visible)
            HeaderBarView(
                isExpanded: Binding(
                    get: { audioInputManager.isPanelExpanded },
                    set: { newValue in audioInputManager.setPanelExpanded(newValue) }
                ), 
                audioInputManager: audioInputManager
            )
            
            // Expandable content area
            if audioInputManager.isPanelExpanded {
                ExpandableContentView(audioInputManager: audioInputManager)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
            }
        }
        .background(.black)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.3)),
            alignment: .top
        )
        .animation(.easeInOut(duration: 0.3), value: audioInputManager.isPanelExpanded)
    }
}

// MARK: - Header Bar (Always Visible)

private struct HeaderBarView: View {
    @Binding var isExpanded: Bool
    @ObservedObject var audioInputManager: AudioInputManager
    
    var body: some View {
        HStack(spacing: 16) {
            // Expand/Collapse Button
            Button(action: { isExpanded.toggle() }) {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                    .foregroundColor(.orange)
                    .font(.system(size: 14, weight: .bold))
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            
            // Power Button - větší a výraznější
            Button(action: {
                audioInputManager.toggle()
            }) {
                ZStack {
                    // Vnější kruh s glow efektem
                    Circle()
                        .fill(audioInputManager.isInputEnabled ? .green.opacity(0.2) : .clear)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(audioInputManager.isInputEnabled ? .green : .gray.opacity(0.5), lineWidth: 2)
                        )
                    
                    // Vnitřní kruh
                    Circle()
                        .fill(audioInputManager.isInputEnabled ? .green : .red.opacity(0.6))
                        .frame(width: 18, height: 18)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.8), lineWidth: 1)
                        )
                    
                    // Power symbol nebo text
                    if audioInputManager.isInputEnabled {
                        Image(systemName: "power")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.black)
                    } else {
                        Text("OFF")
                            .font(.system(size: 6, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: audioInputManager.isInputEnabled)
            }
            .buttonStyle(.plain)
            .help(audioInputManager.isInputEnabled ? "Vypnout guitar amp" : "Zapnout guitar amp")
            
            // Brand Label (Eden WT800 style)
            Text("VACI AMP")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.orange)
            
            Spacer()
            
            // Input Level Meter (in header)
            InputLevelMeterView(level: audioInputManager.inputLevel)
            
            // Selected Device Name
            if let device = audioInputManager.selectedInputDevice {
                Text(device.name)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            } else {
                Text("Žádný vstup")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.red.opacity(0.7))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.black)
    }
}

// MARK: - Expandable Content Area

private struct ExpandableContentView: View {
    @ObservedObject var audioInputManager: AudioInputManager
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 24) {
                // Left side - Device Selection
                DeviceSelectionPanel(audioInputManager: audioInputManager)
                
                Divider()
                    .background(.gray.opacity(0.3))
                
                // Right side - Audio Controls (Eden WT800 style)
                AudioControlsPanel(audioInputManager: audioInputManager)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(.black)
    }
}

// MARK: - Device Selection Panel

private struct DeviceSelectionPanel: View {
    @ObservedObject var audioInputManager: AudioInputManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("VSTUPNÍ ZAŘÍZENÍ", systemImage: "mic")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.orange)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(audioInputManager.availableInputDevices) { device in
                        DeviceRowView(
                            device: device,
                            isSelected: device == audioInputManager.selectedInputDevice,
                            onSelect: {
                                audioInputManager.selectInputDevice(device)
                            }
                        )
                    }
                }
            }
            .frame(maxHeight: 120)
            
            // Channel Selection
            if let selectedDevice = audioInputManager.selectedInputDevice,
               selectedDevice.channelCount > 1 {
                
                Divider()
                    .background(.gray.opacity(0.3))
                
                VStack(alignment: .leading, spacing: 8) {
                    Label("VSTUPNÍ KANÁL", systemImage: "waveform.path")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                    
                    HStack(spacing: 4) {
                        ForEach(audioInputManager.availableChannels, id: \.self) { channel in
                            Button(action: {
                                audioInputManager.selectInputChannel(channel)
                            }) {
                                Text("CH\(channel + 1)")
                                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        channel == audioInputManager.selectedInputChannel 
                                        ? .orange 
                                        : .gray.opacity(0.2)
                                    )
                                    .foregroundColor(
                                        channel == audioInputManager.selectedInputChannel 
                                        ? .black 
                                        : .white
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .frame(minWidth: 220)
    }
}

private struct DeviceRowView: View {
    let device: AVAudioDevice
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                Circle()
                    .fill(isSelected ? .green : .clear)
                    .stroke(isSelected ? .green : .gray.opacity(0.5), lineWidth: 1)
                    .frame(width: 8, height: 8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(device.name)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    HStack {
                        Text(device.portType)
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        if device.channelCount > 1 {
                            Text("\(device.channelCount) CH")
                                .font(.system(size: 9, weight: .medium, design: .monospaced))
                                .foregroundColor(.orange.opacity(0.8))
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? .green.opacity(0.1) : .clear)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isSelected ? .green.opacity(0.3) : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Audio Controls Panel (Eden WT800 style)

private struct AudioControlsPanel: View {
    @ObservedObject var audioInputManager: AudioInputManager
    
    var body: some View {
        HStack(spacing: 32) {
            // Input Gain Section
            VStack(spacing: 8) {
                Text("GAIN")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                
                VStack(spacing: 4) {
                    Text("\(audioInputManager.inputGain, specifier: "%.1f") dB")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                    
                    VerticalSliderView(
                        value: Binding(
                            get: { audioInputManager.inputGain },
                            set: { audioInputManager.setGain($0) }
                        ),
                        range: -20...20,
                        step: 0.5,
                        height: 100,
                        trackColor: .orange.opacity(0.3),
                        thumbColor: .orange
                    )
                }
            }
            
            // Volume Section
            VStack(spacing: 8) {
                Text("VOLUME")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                
                VStack(spacing: 4) {
                    Text("\(Int(audioInputManager.inputVolume * 100))%")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                    
                    VerticalSliderView(
                        value: Binding(
                            get: { audioInputManager.inputVolume },
                            set: { audioInputManager.setVolume($0) }
                        ),
                        range: 0...1,
                        step: 0.01,
                        height: 100,
                        trackColor: .green.opacity(0.3),
                        thumbColor: .green
                    )
                }
            }
            
            // Bass EQ
            VStack(spacing: 8) {
                Text("BASS")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                
                VStack(spacing: 4) {
                    Text("\(audioInputManager.eqManager.band170Hz, specifier: "%.1f") dB")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.blue)
                    
                    VerticalSliderView(
                        value: Binding(
                            get: { audioInputManager.eqManager.band170Hz },
                            set: { audioInputManager.eqManager.setBand170Hz($0); audioInputManager.updateEQFromManager() }
                        ),
                        range: -12...12,
                        step: 1,
                        height: 100,
                        trackColor: .blue.opacity(0.3),
                        thumbColor: .blue
                    )
                }
            }
            
            // Mid EQ
            VStack(spacing: 8) {
                Text("MID")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                
                VStack(spacing: 4) {
                    Text("\(audioInputManager.eqManager.band1kHz, specifier: "%.1f") dB")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.green)
                    
                    VerticalSliderView(
                        value: Binding(
                            get: { audioInputManager.eqManager.band1kHz },
                            set: { audioInputManager.eqManager.setBand1kHz($0); audioInputManager.updateEQFromManager() }
                        ),
                        range: -12...12,
                        step: 1,
                        height: 100,
                        trackColor: .green.opacity(0.3),
                        thumbColor: .green
                    )
                }
            }
            
            // Treble EQ
            VStack(spacing: 8) {
                Text("TREBLE")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                
                VStack(spacing: 4) {
                    Text("\(audioInputManager.eqManager.band6kHz, specifier: "%.1f") dB")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.orange)
                    
                    VerticalSliderView(
                        value: Binding(
                            get: { audioInputManager.eqManager.band6kHz },
                            set: { audioInputManager.eqManager.setBand6kHz($0); audioInputManager.updateEQFromManager() }
                        ),
                        range: -12...12,
                        step: 1,
                        height: 100,
                        trackColor: .orange.opacity(0.3),
                        thumbColor: .orange
                    )
                }
            }
            
            // Presence EQ
            VStack(spacing: 8) {
                Text("PRESENCE")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                
                VStack(spacing: 4) {
                    Text("\(audioInputManager.eqManager.band12kHz, specifier: "%.1f") dB")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.red)
                    
                    VerticalSliderView(
                        value: Binding(
                            get: { audioInputManager.eqManager.band12kHz },
                            set: { audioInputManager.eqManager.setBand12kHz($0); audioInputManager.updateEQFromManager() }
                        ),
                        range: -12...12,
                        step: 1,
                        height: 100,
                        trackColor: .red.opacity(0.3),
                        thumbColor: .red
                    )
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Custom Vertical Slider

private struct VerticalSliderView: View {
    @Binding var value: Float
    let range: ClosedRange<Float>
    let step: Float
    let height: CGFloat
    let trackColor: Color
    let thumbColor: Color
    
    @State private var dragLocation: CGFloat = 0
    @State private var isDragging: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                ZStack(alignment: .bottom) {
                    // Track
                    RoundedRectangle(cornerRadius: 2)
                        .fill(trackColor)
                        .frame(width: 4, height: height)
                    
                    // Fill
                    RoundedRectangle(cornerRadius: 2)
                        .fill(thumbColor.opacity(0.8))
                        .frame(width: 4, height: CGFloat(thumbPosition) * height)
                    
                    // Thumb
                    Circle()
                        .fill(thumbColor)
                        .frame(width: 12, height: 12)
                        .offset(y: -CGFloat(thumbPosition) * height + 6)
                }
                .frame(width: 20, height: height)
                
                Spacer()
            }
        }
        .frame(width: 20, height: height + 20)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { gesture in
                    isDragging = true
                    let newPosition = 1 - (gesture.location.y - 10) / height
                    let clampedPosition = max(0, min(1, newPosition))
                    let newValue = range.lowerBound + Float(clampedPosition) * (range.upperBound - range.lowerBound)
                    let steppedValue = round(newValue / step) * step
                    value = max(range.lowerBound, min(range.upperBound, steppedValue))
                }
                .onEnded { _ in
                    isDragging = false
                }
        )
    }
    
    private var thumbPosition: Float {
        (value - range.lowerBound) / (range.upperBound - range.lowerBound)
    }
}

// MARK: - Input Level Meter

private struct InputLevelMeterView: View {
    let level: Float
    
    var body: some View {
        HStack(spacing: 1) {
            ForEach(0..<8) { index in
                Rectangle()
                    .fill(barColor(for: index))
                    .frame(width: 3, height: 12)
                    .opacity(level * 8 > Float(index) ? 1.0 : 0.3)
            }
        }
        .background(.black)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(.gray.opacity(0.3), lineWidth: 0.5)
        )
    }
    
    private func barColor(for index: Int) -> Color {
        switch index {
        case 0...4: return .green
        case 5...6: return .orange
        default: return .red
        }
    }
}

struct AudioInputView_Previews: PreviewProvider {
    static var previews: some View {
        let audioManager = AudioManager()
        AudioInputView(audioInputManager: AudioInputManager(audioManager: audioManager))
    }
}