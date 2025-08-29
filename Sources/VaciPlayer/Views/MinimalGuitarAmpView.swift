import SwiftUI

struct MinimalGuitarAmpView: View {
    @ObservedObject var audioInputManager: AudioInputManager
    @State private var selectedDeviceIndex = 0
    
    var body: some View {
        VStack(spacing: 12) {
            // Header s power buttonem
            HStack {
                Text("🎸 GUITAR AMP")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.orange)
                
                Spacer()
                
                // Power Button - výraznější a větší
                Button(action: {
                    audioInputManager.toggle()
                    print("Toggled: \(audioInputManager.isInputEnabled)")
                }) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(audioInputManager.isInputEnabled ? .green : .red)
                            .frame(width: 12, height: 12)
                        
                        Text(audioInputManager.isInputEnabled ? "ON" : "OFF")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(audioInputManager.isInputEnabled ? .green : .red)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }
            
            if audioInputManager.isInputEnabled {
                Divider()
                
                // Zjednodušené ovládání v řádcích
                VStack(spacing: 8) {
                    // Aktuálně vybrané zařízení
                    if let selectedDevice = audioInputManager.selectedInputDevice {
                        HStack {
                            Text("Input:")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text(selectedDevice.name)
                                .font(.system(size: 10))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            Spacer()
                        }
                    }
                    
                    // Ovládání gain a volume v jednom řádku
                    HStack(spacing: 16) {
                        // Gain controls
                        VStack(spacing: 2) {
                            HStack(spacing: 4) {
                                Text("Gain:")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Text("\(Int(audioInputManager.inputGain))dB")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.orange)
                                    .frame(minWidth: 35)
                            }
                            
                            VStack(spacing: 1) {
                                HStack(spacing: 2) {
                                    Button("-3") {
                                        audioInputManager.setGain(audioInputManager.inputGain - 3)
                                    }
                                    .font(.system(size: 9))
                                    .buttonStyle(.bordered)
                                    .controlSize(.mini)
                                    
                                    Button("0") {
                                        audioInputManager.setGain(0)
                                    }
                                    .font(.system(size: 9))
                                    .buttonStyle(.bordered)
                                    .controlSize(.mini)
                                    
                                    Button("+3") {
                                        audioInputManager.setGain(audioInputManager.inputGain + 3)
                                    }
                                    .font(.system(size: 9))
                                    .buttonStyle(.bordered)
                                    .controlSize(.mini)
                                }
                                
                                HStack(spacing: 2) {
                                    Button("-15dB") {
                                        audioInputManager.setGain(-15)
                                    }
                                    .font(.system(size: 8))
                                    .buttonStyle(.bordered)
                                    .controlSize(.mini)
                                    .foregroundColor(.blue)
                                    
                                    Button("+9dB") {
                                        audioInputManager.setGain(9)
                                    }
                                    .font(.system(size: 8))
                                    .buttonStyle(.bordered)
                                    .controlSize(.mini)
                                    .foregroundColor(.orange)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // Volume controls
                        VStack(spacing: 2) {
                            HStack(spacing: 4) {
                                Text("Vol:")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Text("\(Int(audioInputManager.inputVolume * 100))%")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.blue)
                                    .frame(minWidth: 35)
                            }
                            
                            HStack(spacing: 2) {
                                Button("50%") {
                                    audioInputManager.setVolume(0.5)
                                }
                                .font(.system(size: 9))
                                .buttonStyle(.bordered)
                                .controlSize(.mini)
                                
                                Button("80%") {
                                    audioInputManager.setVolume(0.8)
                                }
                                .font(.system(size: 9))
                                .buttonStyle(.bordered)
                                .controlSize(.mini)
                                
                                Button("100%") {
                                    audioInputManager.setVolume(1.0)
                                }
                                .font(.system(size: 9))
                                .buttonStyle(.bordered)
                                .controlSize(.mini)
                            }
                        }
                    }
                    
                    // EQ Section (expandable)
                    if audioInputManager.isPanelExpanded {
                        Divider()
                        
                        VStack(spacing: 8) {
                            Text("EQ & EFFECTS")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.orange)
                            
                            // EQ Controls (using EQ component)
                            EQSectionView(eqManager: audioInputManager.eqManager)
                                .onChange(of: audioInputManager.eqManager.currentValues) { _ in
                                    audioInputManager.updateEQFromManager()
                                }
                            
                            // Reverb Control
                            HStack {
                                Text("Reverb:")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Text("\(Int(audioInputManager.reverbAmount * 100))%")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.cyan)
                                    .frame(minWidth: 30)
                                
                                Spacer()
                                
                                HStack(spacing: 2) {
                                    Button("0%") {
                                        audioInputManager.setReverbAmount(0.0)
                                    }
                                    .font(.system(size: 8))
                                    .buttonStyle(.bordered)
                                    .controlSize(.mini)
                                    
                                    Button("25%") {
                                        audioInputManager.setReverbAmount(0.25)
                                    }
                                    .font(.system(size: 8))
                                    .buttonStyle(.bordered)
                                    .controlSize(.mini)
                                    
                                    Button("50%") {
                                        audioInputManager.setReverbAmount(0.5)
                                    }
                                    .font(.system(size: 8))
                                    .buttonStyle(.bordered)
                                    .controlSize(.mini)
                                }
                            }
                        }
                    }
                    
                    // Expand/Collapse toggle
                    HStack {
                        Spacer()
                        Button(audioInputManager.isPanelExpanded ? "Less" : "EQ") {
                            audioInputManager.togglePanelExpansion()
                        }
                        .font(.system(size: 8))
                        .buttonStyle(.bordered)
                        .controlSize(.mini)
                        .foregroundColor(audioInputManager.isPanelExpanded ? .orange : .secondary)
                    }
                }
            }
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(audioInputManager.isInputEnabled ? .green.opacity(0.5) : .gray.opacity(0.3), lineWidth: 1)
        )
    }
}

struct MinimalGuitarAmpView_Previews: PreviewProvider {
    static var previews: some View {
        let audioManager = AudioManager()
        MinimalGuitarAmpView(audioInputManager: AudioInputManager(audioManager: audioManager))
    }
}