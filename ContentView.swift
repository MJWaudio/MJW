import SwiftUI

struct ContentView: View {
    @State private var selectedType: BoxType = .ported
    @State private var width = "90"
    @State private var height = "40"
    @State private var depth = "45"
    @State private var portArea = "300"
    @State private var portLength = "50"

    private var result: BoxResult {
        BoxCalculator.calculate(
            type: selectedType,
            widthCm: Double(width) ?? 0,
            heightCm: Double(height) ?? 0,
            depthCm: Double(depth) ?? 0,
            portAreaCm2: Double(portArea) ?? 0,
            portLengthCm: Double(portLength) ?? 0
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("MJW").font(.system(size: 36, weight: .black, design: .rounded))
                        Text("AUDIO BOX").font(.headline).tracking(4).foregroundStyle(.orange)
                        Text("Subwoofer enclosure design").font(.subheadline).foregroundStyle(.secondary)
                    }
                    .padding(.top, 12)

                    Picker("Enclosure type", selection: $selectedType) {
                        ForEach(BoxType.allCases) { type in
                            Text(type.title).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))

                    GroupBox("Internal dimensions (cm)") {
                        VStack(spacing: 12) {
                            valueField("Width", value: $width)
                            valueField("Height", value: $height)
                            valueField("Depth", value: $depth)
                        }.padding(.top, 6)
                    }

                    if selectedType == .ported {
                        GroupBox("Slot port (cm / cm²)") {
                            VStack(spacing: 12) {
                                valueField("Port area (cm²)", value: $portArea)
                                valueField("Port length (cm)", value: $portLength)
                            }.padding(.top, 6)
                        }
                    } else {
                        Text("Bandpass mode is a UI placeholder. Enter driver T/S parameters and chamber details in a future version before using this mode for design.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
                    }

                    GroupBox("Preliminary result") {
                        VStack(alignment: .leading, spacing: 10) {
                            resultRow("Gross internal volume", value: String(format: "%.1f L", result.grossLiters))
                            resultRow("Approx. net volume", value: String(format: "%.1f L", result.netLiters))
                            resultRow("Estimated tuning", value: result.tuningHz.map { String(format: "%.1f Hz", $0) } ?? "—")
                            Text("Estimate only. Driver displacement, bracing, port end correction and losses are not fully modeled.")
                                .font(.caption2).foregroundStyle(.secondary)
                        }.padding(.top, 6)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Auto SPL Optimizer", systemImage: "waveform.path")
                            .font(.headline)
                        Text("Planned next: driver parameters, chamber modeling, response curves and dimension-constrained optimization.")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .tint(.orange)
    }

    private func valueField(_ title: String, value: Binding<String>) -> some View {
        HStack {
            Text(title)
            Spacer()
            TextField(title, text: value)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 110)
                .textFieldStyle(.roundedBorder)
        }
    }

    private func resultRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(.secondary)
            Spacer()
            Text(value).fontWeight(.semibold).monospacedDigit()
        }
    }
}

enum BoxType: String, CaseIterable, Identifiable {
    case ported, fourthOrder, sixthOrder
    var id: String { rawValue }
    var title: String {
        switch self {
        case .ported: "Ported"
        case .fourthOrder: "4th order bandpass"
        case .sixthOrder: "6th order bandpass"
        }
    }
}

struct BoxResult {
    let grossLiters: Double
    let netLiters: Double
    let tuningHz: Double?
}

enum BoxCalculator {
    static func calculate(type: BoxType, widthCm: Double, heightCm: Double, depthCm: Double,
                          portAreaCm2: Double, portLengthCm: Double) -> BoxResult {
        let gross = max(0, widthCm * heightCm * depthCm / 1000)
        guard type == .ported else {
            return BoxResult(grossLiters: gross, netLiters: gross, tuningHz: nil)
        }
        let portLiters = max(0, portAreaCm2 * portLengthCm / 1000)
        let net = max(0, gross - portLiters)
        // Approximate Helmholtz relation in SI units; empirical end correction is not yet configurable.
        let areaM2 = portAreaCm2 / 10_000
        let lengthM = portLengthCm / 100
        let volumeM3 = net / 1000
        guard areaM2 > 0, lengthM > 0, volumeM3 > 0 else {
            return BoxResult(grossLiters: gross, netLiters: net, tuningHz: nil)
        }
        let effectiveLength = lengthM + 0.732 * sqrt(areaM2 / Double.pi)
        let hz = (343 / (2 * Double.pi)) * sqrt(areaM2 / (volumeM3 * effectiveLength))
        return BoxResult(grossLiters: gross, netLiters: net, tuningHz: hz.isFinite ? hz : nil)
    }
}
