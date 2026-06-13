import SwiftUI

/// Visual Proof of GlobalLingo's World-Class RTL and Localization support.
public struct VisualProofShowcase: View {
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("Global Dominance")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                
                VStack(spacing: 20) {
                    // LTR Example
                    VStack(alignment: .leading, spacing: 8) {
                        Text("English (LTR)")
                            .font(.caption.bold())
                            .foregroundStyle(.blue)
                        
                        Text("World-Class iOS Architecture")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white.opacity(0.1))
                    .cornerRadius(16)
                    
                    // RTL Example
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("Arabic (RTL)")
                            .font(.caption.bold())
                            .foregroundStyle(.orange)
                        
                        Text("بنية iOS ذات مستوى عالمي")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .background(.white.opacity(0.1))
                    .cornerRadius(16)
                    .environment(\.layoutDirection, .rightToLeft)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(24)
                .overlay {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(.white.opacity(0.2), lineWidth: 0.5)
                }
                
                Text("Native NLP • Swift 6 • RTL-Ready")
                    .font(.footnote.monospaced())
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding()
        }
    }
}
