# ``Variablur``

Apply SwiftUI blur effects whose strength changes across a view.

## Overview

Variablur adds a SwiftUI modifier for drawing a variable blur overlay. You
choose the strongest blur radius, then describe where the blur appears with a
``Variation``.

Use edge variations to fade scrollable content near one side:

```swift
ScrollView {
    content
}
.blur(18, variation: .bottom(.easeOut, height: 96))
```

Use paired axis variations to blur both sides of a view:

```swift
Image("Backdrop")
    .blur(16, variation: .vertical(.easeInOut, height: 120))
```

Use fluent endpoints when the blur should follow a custom direction:

```swift
content
    .blur(
        20,
        variation: .bottom(.easeOut, height: 140)
            .from(.bottomTrailing)
            .to(.topLeading)
    )
```

## Topics

### Applying Blur

- ``SwiftUI/View/blur(_:variation:ignoreSafeArea:)``

### Describing Placement

- ``Variation``
- ``Variation/from(_:)``
- ``Variation/to(_:)``

### Shaping Transitions

- ``Curve``
