# LCMultiImageEditor
Image editor for multiple images

### Editor
```swift
let vc = LCMultiImageEditor(layoutType: self.layoutType, images: self.images)
vc.delegate = self
vc.modalPresentationStyle = .fullScreen
self.present(vc, animated: true, completion: nil)
```

### Delegation methods
- Implement MultiEditorDelegate protocol to handle selected photos.  
```swift
func multiEditor(_ controller: LCMultiImageEditor, didFinishWithCroppedImage exportedImage: UIImage)
func multiEditorDidCancel(_ controller: LCMultiImageEditor)
```
