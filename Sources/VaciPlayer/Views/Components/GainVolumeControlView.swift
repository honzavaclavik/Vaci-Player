import SwiftUI

struct GainVolumeControlView: View {
    let gainValue: Float
    let volumeValue: Float
    let setGain: (Float) -> Void
    let setVolume: (Float) -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            gainControlSection
            
            Divider()
                .frame(height: 60)
            
            volumeControlSection
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
    
    // MARK: - Gain Control Section
    private var gainControlSection: some View {
        VStack(spacing: 8) {
            Text("GAIN")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.orange)
            
            gainDisplay
            gainButtons
        }
    }
    
    private var gainDisplay: some View {
        Text("\(gainValue, specifier: "%.1f")dB")
            .font(.system(size: 13, weight: .bold, design: .monospaced))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(.orange.opacity(0.2), in: RoundedRectangle(cornerRadius: 4))
    }
    
    private var gainButtons: some View {
        HStack(spacing: 4) {
            GainButton(label: "-15", value: -15.0, currentValue: gainValue, action: setGain)
            GainButton(label: "-5", value: -5.0, currentValue: gainValue, action: setGain)
            GainButton(label: "0", value: 0.0, currentValue: gainValue, action: setGain)
            GainButton(label: "+5", value: 5.0, currentValue: gainValue, action: setGain)
            GainButton(label: "+10", value: 10.0, currentValue: gainValue, action: setGain)
        }
    }
    
    // MARK: - Volume Control Section
    private var volumeControlSection: some View {
        VStack(spacing: 8) {
            Text("VOLUME")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.blue)
            
            volumeDisplay
            volumeButtons
        }
    }
    
    private var volumeDisplay: some View {
        Text("\(Int(volumeValue * 100))%")
            .font(.system(size: 13, weight: .bold, design: .monospaced))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(.blue.opacity(0.2), in: RoundedRectangle(cornerRadius: 4))
    }
    
    private var volumeButtons: some View {
        HStack(spacing: 4) {
            VolumeButton(label: "25", value: 0.25, currentValue: volumeValue, action: setVolume)
            VolumeButton(label: "50", value: 0.5, currentValue: volumeValue, action: setVolume)
            VolumeButton(label: "75", value: 0.75, currentValue: volumeValue, action: setVolume)
            VolumeButton(label: "100", value: 1.0, currentValue: volumeValue, action: setVolume)
        }
    }
}

// MARK: - Gain Button Component
struct GainButton: View {
    let label: String
    let value: Float
    let currentValue: Float
    let action: (Float) -> Void
    
    var body: some View {
        Button(label) {
            action(value)
        }
        .font(.system(size: 9, weight: .medium))
        .buttonStyle(.borderedProminent)
        .controlSize(.mini)
        .tint(abs(currentValue - value) < 0.1 ? .orange : .secondary)
    }
}

// MARK: - Volume Button Component
struct VolumeButton: View {
    let label: String
    let value: Float
    let currentValue: Float
    let action: (Float) -> Void
    
    var body: some View {
        Button(label) {
            action(value)
        }
        .font(.system(size: 9, weight: .medium))
        .buttonStyle(.borderedProminent)
        .controlSize(.mini)
        .tint(abs(currentValue - value) < 0.01 ? .blue : .secondary)
    }
}

// MARK: - Preview
struct GainVolumeControlView_Previews: PreviewProvider {
    static var previews: some View {
        GainVolumeControlView(
            gainValue: -5.0,
            volumeValue: 0.8,
            setGain: { _ in },
            setVolume: { _ in }
        )
        .padding()
    }
}