import SwiftUI

struct BasicGuitarAmpView: View {
    @ObservedObject var audioInputManager: AudioInputManager
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text("🎸 GUITAR AMP")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                
                Spacer()
                
                // Power Button
                Button(action: {
                    audioInputManager.toggle()
                    print("Guitar amp toggled: \(audioInputManager.isInputEnabled)")
                }) {
                    HStack {
                        Circle()
                            .fill(audioInputManager.isInputEnabled ? .green : .red)
                            .frame(width: 16, height: 16)
                        
                        Text(audioInputManager.isInputEnabled ? "ON" : "OFF")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 8)
            
            if audioInputManager.isInputEnabled {
                VStack(spacing: 16) {
                    // Device Selection
                    HStack {
                        Text("Input:")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Menu(audioInputManager.selectedInputDevice?.name ?? "Select Device") {
                            ForEach(audioInputManager.availableInputDevices) { device in
                                Button(device.name) {
                                    audioInputManager.selectInputDevice(device)
                                    print("Selected device: \(device.name)")
                                }
                            }
                        }
                        .font(.system(size: 11))
                        
                        Spacer()
                    }
                    
                    // Gain Control
                    HStack {
                        Text("GAIN:")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.orange)
                        
                        Text("\(audioInputManager.inputGain, specifier: "%.1f") dB")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(minWidth: 50)
                        
                        Spacer()
                        
                        Button("-5") {
                            audioInputManager.setGain(audioInputManager.inputGain - 5)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.mini)
                        
                        Button("0") {
                            audioInputManager.setGain(0)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.mini)
                        
                        Button("+5") {
                            audioInputManager.setGain(audioInputManager.inputGain + 5)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.mini)
                        
                        Button("+10") {
                            audioInputManager.setGain(audioInputManager.inputGain + 10)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.mini)
                    }
                    
                    // Volume Control
                    HStack {
                        Text("VOL:")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.orange)
                        
                        Text("\(Int(audioInputManager.inputVolume * 100))%")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(minWidth: 50)
                        
                        Spacer()
                        
                        Button("25%") {
                            audioInputManager.setVolume(0.25)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.mini)
                        
                        Button("50%") {
                            audioInputManager.setVolume(0.5)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.mini)
                        
                        Button("75%") {
                            audioInputManager.setVolume(0.75)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.mini)
                        
                        Button("100%") {
                            audioInputManager.setVolume(1.0)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.mini)
                    }
                    
                    // Status
                    HStack {
                        if audioInputManager.selectedInputDevice != nil {
                            Text("✅ Ready")
                                .font(.system(size: 10))
                                .foregroundColor(.green)
                        } else {
                            Text("⚠️ Select Input Device")
                                .font(.system(size: 10))
                                .foregroundColor(.orange)
                        }
                        
                        Spacer()
                        
                        Text("Engine: \(audioInputManager.isInputEnabled ? "Running" : "Stopped")")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding(12)
        .background(.black.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.orange.opacity(0.3), lineWidth: 1)
        )
    }
}

struct BasicGuitarAmpView_Previews: PreviewProvider {
    static var previews: some View {
        let audioManager = AudioManager()
        BasicGuitarAmpView(audioInputManager: AudioInputManager(audioManager: audioManager))
    }
}