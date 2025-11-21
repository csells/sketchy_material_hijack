# Sketchy Login Demo

A Flutter application demonstrating how to achieve a hand-drawn, "sketchy" aesthetic by hijacking Material widgets and using a custom rough drawing engine.

## Core Concept: Material Hijacking

The primary goal of this project is to create a unique visual style without sacrificing the robust behavior and accessibility of standard Flutter widgets. We achieve this through a technique we call **"Material Hijacking"**.

### How it Works

1.  **Use Standard Widgets**: We start with standard Material widgets like `TextField` and `Checkbox` to handle user interaction, focus management, accessibility, and state.
2.  **Strip Default Visuals**: We remove the default styling. For example, setting `InputDecoration(border: InputBorder.none)` on a `TextField` removes the standard Material underline or outline.
3.  **Inject Custom Painting**: We wrap these widgets in `CustomPaint` or use their `painter` properties (if available/applicable) to draw our own visuals underneath or on top of the interactive elements.
4.  **The "Rough" Engine**: Instead of straight lines and solid fills, we use a custom `SimpleRoughGenerator` that draws shapes using randomized, sketchy strokes, mimicking a hand-drawn style.

## Technical Highlights

### Deterministic Roughness

A common issue with randomized drawing in UI is "flickering"—where shapes redraw with new random noise every time the UI updates (e.g., while typing). To solve this:

-   **Granular Seeding**: Each widget (e.g., `RoughTextField`, `RoughCheckbox`) generates a random `seed` upon initialization.
-   **State Caching**: This seed is stored in the widget's `State` object.
-   **Consistent Rendering**: The seed is passed to the `SimpleRoughGenerator` for every draw call. This ensures that a specific rectangle or line always looks exactly the same for a given widget instance, even across repaints, while still looking "random" and unique compared to other elements.

### Custom Font

To complete the aesthetic, the app uses the **Gloria Hallelujah** font via the `google_fonts` package, replacing the standard Roboto font.

## Project Structure

-   `lib/main.dart`: Contains the entire application code, including:
    -   **Widgets**: `RoughTextField`, `RoughCheckbox`, `RoughCard`, `AnimatedRoughButton`.
    -   **Painters**: Custom painters that use the generator to draw the UI.
    -   **Engine**: `SimpleRoughGenerator` class containing the logic for drawing rough lines, rectangles, and fills.
