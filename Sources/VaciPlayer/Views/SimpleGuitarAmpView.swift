import SwiftUI

struct SimpleGuitarAmpView: View {
    @ObservedObject var audioInputManager: AudioInputManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with power button
            HStack {
                Text("VACI AMP")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                
                Spacer()
                
                // Power Button
                Button(action: {
                    audioInputManager.toggle()
                }) {
                    HStack {
                        Circle()
                            .fill(audioInputManager.isInputEnabled ? .green : .red)
                            .frame(width: 20, height: 20)
                        
                        Text(audioInputManager.isInputEnabled ? "ON" : "OFF")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
            
            if audioInputManager.isInputEnabled {
                // Device Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Input Device:")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.orange)
                    
                    Picker("Input Device", selection: Binding(
                        get: { audioInputManager.selectedInputDevice?.id ?? UUID() },
                        set: { newId in
                            if let device = audioInputManager.availableInputDevices.first(where: { $0.id == newId }) {
                                audioInputManager.selectInputDevice(device)
                            }
                        }
                    )) {
                        Text("None").tag(UUID())
                        ForEach(audioInputManager.availableInputDevices) { device in
                            Text(device.name).tag(device.id)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Simple Controls
                HStack(spacing: 20) {
                    // Gain
                    VStack {
                        Text("GAIN")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.orange)
                        
                        Text("\(audioInputManager.inputGain, specifier: "%.1f") dB")
                            .font(.system(size: 11))
                            .foregroundColor(.white)
                        
                        Button("Reset") {
                            audioInputManager.inputGain = 0.0
                        }
                        .font(.system(size: 10))
                        .buttonStyle(.plain)
                        .foregroundColor(.gray)
                    }
                    
                    // Volume
                    VStack {
                        Text("VOLUME")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.orange)
                        
                        Text("\(Int(audioInputManager.inputVolume * 100))%")
                            .font(.system(size: 11))
                            .foregroundColor(.white)
                        
                        Button("50%") {
                            audioInputManager.inputVolume = 0.5
                        }
                        .font(.system(size: 10))
                        .buttonStyle(.plain)
                        .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding(16)
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct SimpleGuitarAmpView_Previews: PreviewProvider {
    static var previews: some View {
        let audioManager = AudioManager()
        SimpleGuitarAmpView(audioInputManager: AudioInputManager(audioManager: audioManager))
    }
}