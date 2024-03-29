# LCMultiImageEditor
Image editor for multiple images

## Installation
LCMultiImageEditor is compatible with Swift Package Manager.
```
https://github.com/tmaas510/LCImageEditor
```

### Editor
```swift
let vc = LCMultiImageEditor(layoutType: self.layoutType, images: self.images)
vc.delegate = self
vc.modalPresentationStyle = .fullScreen
self.present(vc, animated: true, completion: nil)
```

### Delegation methods
Implement MultiEditorDelegate protocol to handle selected image.  
```swift
func multiEditor(_ controller: LCMultiImageEditor, didFinishWithCroppedImage exportedImage: UIImage)
func multiEditorDidCancel(_ controller: LCMultiImageEditor)
```
