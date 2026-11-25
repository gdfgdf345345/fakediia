import SwiftUI
import CoreImage.CIFilterBuiltins

/// Крес QR-код з білого поля — як у справжній Дії під час показу документа.
struct QRCodeView: View {
    let payload: String
    var side: CGFloat = 220

    private var image: UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(payload.utf8)
        filter.correctionLevel = "M"
        guard let output = filter.outputImage else { return nil }
        let scaled = output.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        let context = CIContext()
        guard let cg = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cg)
    }

    var body: some View {
        VStack(spacing: 16) {
            if let img = image {
                Image(uiImage: img)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: side, height: side)
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
    }
}
