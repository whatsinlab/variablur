<div align="center">
  <img width="128" height="128" src="/Resources/Icon.png" alt="Variablur Icon">
  <h1><b>Variablur</b></h1>
  <p>
    Vary blur with ease.
  </p>
</div>

Variablur is a Swift package for applying SwiftUI blur effects whose strength
changes across a view.

<div align="center">
  <img width="256" src="/Resources/Example.gif" alt="Preview">
</div>

Use it to add edge fades, paired horizontal or vertical blurs, perimeter blur,
and custom directional blur overlays without building mask images by hand.

## Overview

Variablur adds a SwiftUI `View.blur(_:variation:ignoreSafeArea:)` modifier. You
choose the strongest blur radius, then describe where the blur appears with a
`Variation` and shape its transition with a `Curve`.

```swift
import SwiftUI
import Variablur

struct ContentView: View {
    var body: some View {
        ScrollView {
            content
        }
        .blur(18, variation: .bottom(.easeOut, height: 96))
    }
}
```

`Variation` supports common placements:

```swift
Image("Backdrop")
    .blur(16, variation: .vertical(.easeInOut, height: 120))
```

It also supports custom start and end points:

```swift
content
    .blur(
        20,
        variation: .bottom(.easeOut, height: 140)
            .from(.bottomTrailing)
            .to(.topLeading)
    )
```

## Requirements

- Swift 6.3 or later
- iOS 14.0 or later
- macOS 11.0 or later

## Installation

Add Variablur to a Swift package with Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/whatsinlab/variablur.git", branch: "main"),
]
```

Then add `Variablur` to the target that uses it:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        "Variablur",
    ]
)
```

You can also add the package in Xcode with **File > Add Package
Dependencies...** and the repository URL.

## Usage

### Edge Blur

Use a directional variation to fade one side of a view.

```swift
List(items) { item in
    Row(item)
}
.blur(24, variation: .top(.sineOut, height: 80))
```

### Axis Blur

Use paired axis variations to blur both sides of a view.

```swift
TimelineView(.animation) { _ in
    CanvasView()
        .blur(12, variation: .horizontal(.easeInOut, height: 64))
}
```

### Perimeter Blur

Use `.all` when the blur should follow the view perimeter.

```swift
RoundedRectangle(cornerRadius: 28)
    .fill(.thinMaterial)
    .blur(10, variation: .all(.easeInOut))
```

### Custom Curves

Use one of the built-in easing curves or provide cubic Bezier control points.

```swift
let curve = Variablur.Curve(0.2, 0.0, 0.0, 1.0)

content
    .blur(22, variation: .bottom(curve, height: 120))
```

On newer platforms, Variablur can also sample SwiftUI `UnitCurve` values:

```swift
if #available(iOS 17.0, macOS 14.0, *) {
    content
        .blur(22, variation: .bottom(.init(.snappy), height: 120))
}
```

## License

Variablur is available under the MIT license. See `LICENSE` for details.
