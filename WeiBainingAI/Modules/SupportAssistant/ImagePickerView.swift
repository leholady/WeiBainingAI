//
//  ImagePickerView.swift
//  WeiBainingAI
//
//  Created by yy2021_8689 on 2023/11/28.
//

import SwiftUI
import ComposableArchitecture
import SwiftUIX

struct ImagePickerView: View {
    
    let store: StoreOf<ImagePickerFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            MYImagePicker(data: viewStore.$imgData)
                .ignoresSafeArea()
        }
        .background(.white)
    }
}

public struct MYImagePicker: UIViewControllerRepresentable {
    public typealias MYUIViewControllerType = UIImagePickerController
    
    @Environment(\.presentationManager) var presentationManager
    
    let info: Binding<[UIImagePickerController.InfoKey: Any]?>?
    let image: Binding<AppKitOrUIKitImage?>?
    let data: Binding<Data?>?
    
    let encoding: Image.Encoding?
    var allowsEditing = false
    var cameraDevice: UIImagePickerController.CameraDevice?
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    var mediaTypes: [String]?
    var onCancel: (() -> Void)?
    
    public func makeUIViewController(context: Context) -> MYUIViewControllerType {
        UIImagePickerController().then {
            $0.delegate = context.coordinator
        }
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        context.coordinator.base = self
        
        uiViewController.allowsEditing = allowsEditing
        uiViewController.sourceType = sourceType
        
        if let mediaTypes = mediaTypes,
           uiViewController.mediaTypes != mediaTypes {
            uiViewController.mediaTypes = mediaTypes
        }
        
        if uiViewController.sourceType == .camera {
            uiViewController.cameraDevice = cameraDevice ?? .rear
        }
    }
    
    public class MYCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var base: MYImagePicker
        
        init(base: MYImagePicker) {
            self.base = base
        }
        
        public func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let image = (info[UIImagePickerController.InfoKey.editedImage] as? UIImage) ?? (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)
            
            base.info?.wrappedValue = info
            base.image?.wrappedValue = image
            base.data?.wrappedValue = (image?._fixOrientation() ?? image)?.data(using: base.encoding ?? .png)
//            base.presentationManager.dismiss()
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            if let onCancel = base.onCancel {
                onCancel()
            } else {
                base.presentationManager.dismiss()
            }
        }
    }
    
    public func makeCoordinator() -> MYCoordinator {
        .init(base: self)
    }
}

extension NSObjectProtocol {
    func then(_ body: (Self) -> Void) -> Self {
        body(self)
        
        return self
    }
}

extension MYImagePicker {
    public init(
        info: Binding<[UIImagePickerController.InfoKey: Any]?>,
        onCancel: (() -> Void)? = nil
    ) {
        self.info = info
        self.image = nil
        self.data = nil
        self.encoding = nil
        self.onCancel = onCancel
    }
    
    public init(
        image: Binding<AppKitOrUIKitImage?>,
        encoding: Image.Encoding? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        self.info = nil
        self.image = image
        self.data = nil
        self.encoding = encoding
        self.onCancel = onCancel
    }
    
    public init(
        data: Binding<Data?>,
        encoding: Image.Encoding? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        self.info = nil
        self.image = nil
        self.data = data
        self.encoding = encoding
        self.onCancel = onCancel
    }
}

extension UIImage {
    @inlinable
    func data(using encoding: Image.Encoding) -> Data? {
        switch encoding {
        case .png:
            return pngData()
        case .jpeg(let compressionQuality):
            return jpegData(compressionQuality: compressionQuality)
        }
    }
    
    func _fixOrientation() -> UIImage? {
        guard imageOrientation != .up else {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

#Preview {
    ImagePickerView(store: Store(initialState: ImagePickerFeature.State(), reducer: {
        ImagePickerFeature()
    }))
}
