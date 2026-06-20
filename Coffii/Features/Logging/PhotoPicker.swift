import SwiftUI
import PhotosUI
import UIKit

/// PhotosUI-based library picker. Works in the simulator (camera capture can be
/// added later via `UIImagePickerController` — not needed for the demoable core).
struct PhotoPickerButton<Label: View>: View {
    @Binding var data: Data?
    var maxDimension: CGFloat = 1600
    @ViewBuilder var label: () -> Label

    @State private var item: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $item, matching: .images, photoLibrary: .shared()) {
            label()
        }
        .onChange(of: item) { _, new in loadImage(new) }
    }

    private func loadImage(_ item: PhotosPickerItem?) {
        guard let item else { return }
        item.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                if case .success(let raw?) = result {
                    data = ImageIO.downscale(data: raw, maxDimension: maxDimension)
                }
            }
        }
    }
}

enum ImageIO {
    /// Downscale and JPEG-compress so shot photos stay small in the store.
    static func downscale(data: Data, maxDimension: CGFloat = 1600, quality: CGFloat = 0.82) -> Data? {
        guard let src = CGImageSourceCreateWithData(data as CFData, nil),
              let cg = CGImageSourceCreateImageAtIndex(src, 0, nil) else { return data }
        let w = CGFloat(cg.width), h = CGFloat(cg.height)
        let scale = min(1, maxDimension / max(w, h))
        let size = CGSize(width: w * scale, height: h * scale)
        let ui = UIImage(cgImage: cg)
        let renderer = UIGraphicsImageRenderer(size: size)
        let resized = renderer.image { _ in ui.draw(in: CGRect(origin: .zero, size: size)) }
        return resized.jpegData(compressionQuality: quality)
    }
}
