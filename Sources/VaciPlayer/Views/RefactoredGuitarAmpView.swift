import SwiftUI

struct RefactoredGuitarAmpView: View {
    @ObservedObject var audioInputManager: AudioInputManager
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            
            if audioInputManager.isInputEnabled {
                contentSections
            }
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(audioInputManager.isInputEnabled ? .green.opacity(0.6) : .gray.opacity(0.3), lineWidth: 1.5)
        )
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("🎸 VACI GUITAR AMP")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)
                
                Text("8-Band Professional EQ")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            deviceSelector
            powerButton
        }
        .padding(12)
        .background(.black.opacity(0.05), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    private var deviceSelector: some View {
        Group {
            if audioInputManager.isInputEnabled {
                Menu {
                    ForEach(audioInputManager.availableInputDevices) { device in
                        Button(device.name) {
                            audioInputManager.selectInputDevice(device)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 10))
                        Text(audioInputManager.selectedInputDevice?.name ?? "Select")
                            .font(.system(size: 10))
                            .lineLimit(1)
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var powerButton: some View {
        Button {
            audioInputManager.toggle()
        } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(audioInputManager.isInputEnabled ? .green : .red)
                    .frame(width: 12, height: 12)
                
                Text(audioInputManager.isInputEnabled ? "ON" : "OFF")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.black, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Content Sections
    private var contentSections: some View {
        VStack(spacing: 12) {
            // Gain and Volume Controls
            GainVolumeControlView(
                gainValue: audioInputManager.inputGain,
                volumeValue: audioInputManager.inputVolume,
                setGain: audioInputManager.setGain,
                setVolume: audioInputManager.setVolume
            )
            
            // EQ Section
            EQSectionView(eqManager: audioInputManager.eqManager)
                .onChange(of: audioInputManager.eqManager.currentValues) { _ in
                    audioInputManager.updateEQFromManager()
                }
            
            // Effects and Status
            EffectsStatusView(
                reverbAmount: audioInputManager.reverbAmount,
                inputLevel: audioInputManager.inputLevel,
                hasSelectedDevice: audioInputManager.selectedInputDevice != nil,
                setReverbAmount: audioInputManager.setReverbAmount
            )
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
}

struct RefactoredGuitarAmpView_Previews: PreviewProvider {
    static var previews: some View {
        let audioManager = AudioManager()
        RefactoredGuitarAmpView(audioInputManager: AudioInputManager(audioManager: audioManager))
            .padding()
    }
}