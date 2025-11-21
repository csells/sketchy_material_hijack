# Sketchy Login Demo

A Flutter application demonstrating how to achieve a hand-drawn, "sketchy"
aesthetic by hijacking Material widgets and using a custom rough drawing engine.

## The Technique: Material Hijacking

The primary goal of this project is to create a unique visual style without
sacrificing the robust behavior and accessibility of standard Flutter widgets.
We achieve this through a technique we call **"Material Hijacking"**.

### How it Works

1.  **Use Standard Widgets**: We start with standard Material widgets like
    `TextField` and `Checkbox` to handle user interaction, focus management,
    accessibility, and state.
2.  **Strip Default Visuals**: We remove the default styling. For example,
    setting `InputDecoration(border: InputBorder.none)` on a `TextField` removes
    the standard Material underline or outline.
3.  **Inject Custom Painting**: We wrap these widgets in `CustomPaint` or use
    their `painter` properties (if available/applicable) to draw our own visuals
    underneath or on top of the interactive elements.
4.  **The "Rough" Engine**: Instead of straight lines and solid fills, we use a
    custom `SimpleRoughGenerator` that draws shapes using randomized, sketchy
    strokes, mimicking a hand-drawn style.

### Pros & Cons

| Feature | Description |
| :--- | :--- |
| **Accessibility** | ✅ **Pro**: Retains all standard accessibility features (screen readers, keyboard navigation, dynamic type) because the underlying semantic widget is still there. |
| **Behavior** | ✅ **Pro**: Preserves complex behaviors like text selection, input masking, focus traversal, and validation logic without needing to reimplement them from scratch. |
| **Compatibility** | ✅ **Pro**: Works seamlessly with the existing Flutter ecosystem, including form validation and state management solutions. |
| **Maintenance** | ⚠️ **Con**: Custom painters are tightly coupled to the layout. If the underlying widget's size or layout logic changes significantly, the painter might need manual adjustments. |
| **Effort** | ⚠️ **Con**: Requires creating a specific `CustomPainter` for every widget type you want to style. There is no "global theme" switch for this level of customization. |
| **Limitations** | ⚠️ **Con**: Some widget internals (like ripple effects, scrollbars, or complex composite widgets) are harder to hijack perfectly without more invasive methods or reimplementing parts of the widget. |

### Practicality & Scalability

Is this technique practical for a real-world app? **Yes, for the majority of UI
elements.**

-   **Standard Widgets**: Buttons, TextFields, Cards, Dialogs, and Checkboxes
    are excellent candidates. They have well-defined bounds and states (focused,
    hovered, disabled) that map easily to custom drawing logic.
-   **Third-Party Packages**: This technique extends well to many 3rd-party
    packages. As long as a widget allows you to customize its container or
    disable its default decoration, you can wrap it in a `CustomPaint` to apply
    your own style.
-   **Complex Widgets**: For highly complex widgets like DatePickers or Sliders,
    "hijacking" might become too labor-intensive. In those cases, a hybrid
    approach (styling the container but leaving the internal components
    standard) or a fully custom widget might be better.

## Technical Highlights

### Deterministic Roughness

A common issue with randomized drawing in UI is "flickering"—where shapes redraw
with new random noise every time the UI updates (e.g., while typing). To solve
this:

-   **Granular Seeding**: Each widget (e.g., `RoughTextField`, `RoughCheckbox`)
    generates a random `seed` upon initialization.
-   **State Caching**: This seed is stored in the widget's `State` object.
-   **Consistent Rendering**: The seed is passed to the `SimpleRoughGenerator`
    for every draw call. This ensures that a specific rectangle or line always
    looks exactly the same for a given widget instance, even across repaints,
    while still looking "random" and unique compared to other elements.

### Custom Font

To complete the aesthetic, the app uses the **Gloria Hallelujah** font via the
`google_fonts` package, replacing the standard Roboto font.

## Project Structure

-   `lib/main.dart`: Contains the entire application code, including:
    -   **Widgets**: `RoughTextField`, `RoughCheckbox`, `RoughCard`,
        `AnimatedRoughButton`.
    -   **Painters**: Custom painters that use the generator to draw the UI.
    -   **Engine**: `SimpleRoughGenerator` class containing the logic for
        drawing rough lines, rectangles, and fills.
