import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// While Dart's int on the web can go up to 2^53 (MAX_SAFE_INTEGER),
// Random.nextInt() has a limitation of 2^32 on both VM and Web.
const int _kMaxSeed = 0xFFFFFFFF;

void main() {
  runApp(const RoughDemoApp());
}

class RoughDemoApp extends StatelessWidget {
  const RoughDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.gloriaHallelujahTextTheme(),
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFFDFBF7), // Paper off-white
      ),
      home: const RoughScaffold(),
    );
  }
}

// ==========================================
// THE DEMO SCREEN
// ==========================================

class RoughScaffold extends StatefulWidget {
  const RoughScaffold({super.key});

  @override
  State<RoughScaffold> createState() => _RoughScaffoldState();
}

class _RoughScaffoldState extends State<RoughScaffold> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _agreedToTerms = false;
  bool _isLoading = false;

  void _handleLogin() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You must agree to the rough terms first!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Successfully logged into the Sketchy UI!"),
          backgroundColor: Colors.indigo,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Sketchy Login",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // 1. Rough Text Fields
              RoughTextField(hintText: "Username", controller: _userController),
              const SizedBox(height: 20),
              RoughTextField(
                hintText: "Password",
                controller: _passController,
                obscureText: true,
              ),
              const SizedBox(height: 30),

              // 2. Rough Card
              RoughCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Terms of Service",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "By clicking login, you agree to surrender your pixels to the random number generator.",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Rough Checkbox
              Row(
                children: [
                  RoughCheckbox(
                    value: _agreedToTerms,
                    onChanged: (val) => setState(() => _agreedToTerms = val),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Text("I agree to be rough")),
                ],
              ),
              const SizedBox(height: 40),

              // 4. Animated Rough Button
              SizedBox(
                height: 60,
                child: AnimatedRoughButton(
                  color: Colors.indigo,
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                  child: const Center(
                    child: Text(
                      "LOG IN",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET 1: RoughTextField
// ==========================================

class RoughTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final Color baseColor;
  final bool obscureText;

  const RoughTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.baseColor = Colors.black87,
    this.obscureText = false,
  });

  @override
  State<RoughTextField> createState() => _RoughTextFieldState();
}

class _RoughTextFieldState extends State<RoughTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  final int _seed = Random().nextInt(_kMaxSeed);

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RoughInputPainter(
        color: widget.baseColor,
        isFocused: _isFocused,
        seed: _seed,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          style: TextStyle(fontSize: 18, color: widget.baseColor),
          decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: widget.hintText,
            // UPDATE: using withValues instead of withOpacity
            hintStyle: TextStyle(
              color: widget.baseColor.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoughInputPainter extends CustomPainter {
  final Color color;
  final bool isFocused;
  final int seed;
  final SimpleRoughGenerator gen = SimpleRoughGenerator();

  _RoughInputPainter({
    required this.color,
    required this.isFocused,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = isFocused ? 2.0 : 1.0;
    // UPDATE: using withValues
    final Color strokeColor = isFocused ? color : color.withValues(alpha: 0.6);

    // Draw Border
    gen.drawRoughRect(
      canvas,
      Offset.zero & size,
      color: strokeColor,
      strokeWidth: strokeWidth,
      seed: seed,
    );

    // Draw Fill (Dots effect if focused)
    if (isFocused) {
      // UPDATE: using withValues
      gen.drawRoughFill(
        canvas,
        Offset.zero & size,
        color: strokeColor.withValues(alpha: 0.1),
        density: 15.0,
        seed: seed + 1,
      );
    }
  }

  @override
  bool shouldRepaint(_RoughInputPainter old) =>
      old.isFocused != isFocused || old.seed != seed;
}

// ==========================================
// WIDGET 2: RoughCheckbox
// ==========================================

class RoughCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color color;

  const RoughCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.color = Colors.indigo,
  });

  @override
  State<RoughCheckbox> createState() => _RoughCheckboxState();
}

class _RoughCheckboxState extends State<RoughCheckbox> {
  final int _seed = Random().nextInt(_kMaxSeed);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: CustomPaint(
          size: const Size(30, 30),
          painter: _RoughCheckboxPainter(
            isChecked: widget.value,
            color: widget.color,
            seed: _seed,
          ),
        ),
      ),
    );
  }
}

class _RoughCheckboxPainter extends CustomPainter {
  final bool isChecked;
  final Color color;
  final int seed;
  final SimpleRoughGenerator gen = SimpleRoughGenerator();

  _RoughCheckboxPainter({
    required this.isChecked,
    required this.color,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Box
    gen.drawRoughRect(
      canvas,
      Offset.zero & size,
      color: color,
      strokeWidth: 1.5,
      seed: seed,
    );

    // Checkmark
    if (isChecked) {
      final p1 = Offset(size.width * 0.2, size.height * 0.5);
      final p2 = Offset(size.width * 0.4, size.height * 0.8);
      final p3 = Offset(size.width * 0.8, size.height * 0.2);

      gen.drawRoughLine(
        canvas,
        p1,
        p2,
        color: color,
        strokeWidth: 2.5,
        seed: seed + 1,
      );
      gen.drawRoughLine(
        canvas,
        p2,
        p3,
        color: color,
        strokeWidth: 2.5,
        seed: seed + 2,
      );

      // UPDATE: using withValues
      gen.drawRoughFill(
        canvas,
        Offset.zero & size,
        color: color.withValues(alpha: 0.2),
        seed: seed + 3,
      );
    }
  }

  @override
  bool shouldRepaint(_RoughCheckboxPainter old) =>
      old.isChecked != isChecked || old.seed != seed;
}

// ==========================================
// WIDGET 3: RoughCard
// ==========================================

class RoughCard extends StatefulWidget {
  final Widget child;
  final Color color;
  final Color backgroundColor;

  const RoughCard({
    super.key,
    required this.child,
    this.color = Colors.black87,
    this.backgroundColor = Colors.transparent,
  });

  @override
  State<RoughCard> createState() => _RoughCardState();
}

class _RoughCardState extends State<RoughCard> {
  final int _seed = Random().nextInt(_kMaxSeed);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RoughCardPainter(
        color: widget.color,
        backgroundColor: widget.backgroundColor,
        seed: _seed,
      ),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: widget.child,
      ),
    );
  }
}

class _RoughCardPainter extends CustomPainter {
  final Color color;
  final Color backgroundColor;
  final int seed;
  final SimpleRoughGenerator gen = SimpleRoughGenerator();

  _RoughCardPainter({
    required this.color,
    required this.backgroundColor,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundColor != Colors.transparent) {
      gen.drawRoughFill(
        canvas,
        Offset.zero & size,
        color: backgroundColor,
        density: 4.0,
        seed: seed,
      );
    }
    gen.drawRoughRect(
      canvas,
      Offset.zero & size,
      color: color,
      strokeWidth: 1.0,
      seed: seed + 1,
    );
  }

  @override
  bool shouldRepaint(_RoughCardPainter old) => old.seed != seed;
}

// ==========================================
// WIDGET 4: AnimatedRoughButton & Spinner
// ==========================================

class AnimatedRoughButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color color;
  final bool isLoading;

  const AnimatedRoughButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.color = Colors.blue,
    this.isLoading = false,
  });

  @override
  State<AnimatedRoughButton> createState() => _AnimatedRoughButtonState();
}

class _AnimatedRoughButtonState extends State<AnimatedRoughButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final int _seed = Random().nextInt(_kMaxSeed);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _animation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool canInteract = !widget.isLoading;

    return MouseRegion(
      cursor: canInteract
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      onEnter: (_) => canInteract ? _controller.forward() : null,
      onExit: (_) => canInteract ? _controller.reverse() : null,
      child: GestureDetector(
        onTap: canInteract ? widget.onPressed : null,
        onTapDown: (_) => canInteract ? _controller.forward() : null,
        onTapUp: (_) => canInteract ? _controller.reverse() : null,
        onTapCancel: () => _controller.reverse(),
        child: CustomPaint(
          painter: _RoughButtonPainter(
            color: widget.isLoading ? Colors.grey : widget.color,
            progress: _animation.value,
            seed: _seed,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: widget.isLoading
                ? const Center(child: RoughSpinner(size: 20))
                : widget.child,
          ),
        ),
      ),
    );
  }
}

class _RoughButtonPainter extends CustomPainter {
  final Color color;
  final double progress;
  final int seed;
  final SimpleRoughGenerator gen = SimpleRoughGenerator();

  _RoughButtonPainter({
    required this.color,
    required this.progress,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double density = ui.lerpDouble(8.0, 3.0, progress)!;
    final double strokeWidth = ui.lerpDouble(1.5, 2.5, progress)!;

    // UPDATE: using withValues
    final Color fillColor = color.withValues(alpha: 0.1 + (progress * 0.3));

    final rect = Offset.zero & size;

    gen.drawRoughFill(
      canvas,
      rect,
      color: fillColor,
      density: density,
      seed: seed,
    );
    gen.drawRoughRect(
      canvas,
      rect,
      color: color,
      strokeWidth: strokeWidth,
      seed: seed,
    );
  }

  @override
  bool shouldRepaint(_RoughButtonPainter old) => old.progress != progress;
}

class RoughSpinner extends StatefulWidget {
  final double size;
  const RoughSpinner({super.key, this.size = 24});
  @override
  State<RoughSpinner> createState() => _RoughSpinnerState();
}

class _RoughSpinnerState extends State<RoughSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _SpinnerPainter(),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  final SimpleRoughGenerator gen = SimpleRoughGenerator();
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    gen.drawRoughEllipse(canvas, rect, color: Colors.black54, strokeWidth: 2.0);
  }

  @override
  bool shouldRepaint(old) => false;
}

// ==========================================
// THE CUSTOM "ROUGH" ENGINE
// (Replaces external package dependency)
// ==========================================

class SimpleRoughGenerator {
  final Random _random = Random();

  /// Draws a rectangle with sketchy borders
  void drawRoughRect(
    Canvas canvas,
    Rect rect, {
    required Color color,
    double strokeWidth = 1.0,
    int? seed,
  }) {
    final r = seed != null ? Random(seed) : _random;

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Top
    _drawDoubleLine(canvas, paint, rect.topLeft, rect.topRight, r);
    // Right
    _drawDoubleLine(canvas, paint, rect.topRight, rect.bottomRight, r);
    // Bottom
    _drawDoubleLine(canvas, paint, rect.bottomRight, rect.bottomLeft, r);
    // Left
    _drawDoubleLine(canvas, paint, rect.bottomLeft, rect.topLeft, r);
  }

  /// Draws a zigzag/hachure fill
  void drawRoughFill(
    Canvas canvas,
    Rect rect, {
    required Color color,
    double density = 10.0, // Distance between lines
    int? seed,
  }) {
    final r = seed != null ? Random(seed) : _random;
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final Path path = Path();

    // Hachure fill algorithm
    // We draw lines at 45 degrees (slope = 1).
    // Equation of line: y = x + offset
    // We iterate offset to cover the rectangle.
    // The range of offset needs to cover from (left, bottom) to (right, top).
    // At (left, top), offset = top - left.
    // At (right, bottom), offset = bottom - right.
    // We want to cover the whole rect, so we go from roughly (top - right) to (bottom - left)?
    // Let's simplify: iterate x from left-height to right.
    // Draw line from (x, top) to (x+height, bottom).
    // Clip to rect.

    for (double i = -rect.height; i < rect.width; i += density) {
      double startX = rect.left + i;
      double endX = startX + rect.height; // 45 degrees: width = height

      Offset p1 = Offset(startX, rect.top);
      Offset p2 = Offset(endX, rect.bottom);

      // Clip line to rectangle
      // We know y1=top, y2=bottom. We just need to handle x.
      // Line segment is p1->p2.
      // Intersection with left edge (x=rect.left):
      // x = rect.left.
      // t = (rect.left - startX) / (endX - startX) = (rect.left - startX) / rect.height
      // y = top + t * height = top + rect.left - startX.

      // Intersection with right edge (x=rect.right):
      // x = rect.right.
      // t = (rect.right - startX) / rect.height
      // y = top + rect.right - startX.

      // We can use a simple line clipping function or just logic here since it's 45 deg.
      // Actually, let's just clamp the points? No, clamping changes slope.
      // We need to find the segment of the line inside the rect.

      // Case 1: Line is completely to the left or right (handled by loop range mostly, but let's be safe)
      if (p2.dx < rect.left || p1.dx > rect.right) {
        continue;
      }

      Offset? start = p1;
      Offset? end = p2;

      // Clip against Left
      if (start.dx < rect.left) {
        start = Offset(rect.left, rect.top + (rect.left - start.dx));
      }
      if (end.dx < rect.left) {
        continue; // Should not happen given p2.dx check above
      }

      // Clip against Right
      if (end.dx > rect.right) {
        end = Offset(rect.right, rect.top + (rect.right - p1.dx));
      }
      if (start.dx > rect.right) {
        continue;
      }

      // Clip against Bottom (already at bottom) & Top (already at top)
      // But we need to check if our x-clipping moved y outside.
      // Since slope is 1, and we move x towards center, y moves towards center.
      // So y should stay within [top, bottom].
      // Let's just clamp y to be safe against float errors.
      start = Offset(start.dx, start.dy.clamp(rect.top, rect.bottom));
      end = Offset(end.dx, end.dy.clamp(rect.top, rect.bottom));

      _addRoughLineToPath(path, start, end, r);
    }
    canvas.drawPath(path, paint);
  }

  void drawRoughLine(
    Canvas canvas,
    Offset p1,
    Offset p2, {
    required Color color,
    double strokeWidth = 1.0,
    int? seed,
  }) {
    final r = seed != null ? Random(seed) : _random;
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    _drawDoubleLine(canvas, paint, p1, p2, r);
  }

  void drawRoughEllipse(
    Canvas canvas,
    Rect rect, {
    required Color color,
    double strokeWidth = 1.0,
    int? seed,
  }) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw an arc approx 300 degrees
    final Path path = Path();
    path.addArc(rect, 0, 5.5); // ~315 degrees

    canvas.drawPath(path, paint);
  }

  // --- Internal Helpers ---

  void _drawDoubleLine(
    Canvas canvas,
    Paint paint,
    Offset p1,
    Offset p2,
    Random r,
  ) {
    _drawLineWithNoise(canvas, paint, p1, p2, r);
    _drawLineWithNoise(canvas, paint, p1, p2, r);
  }

  void _drawLineWithNoise(
    Canvas canvas,
    Paint paint,
    Offset p1,
    Offset p2,
    Random r,
  ) {
    final Path path = Path();
    path.moveTo(p1.dx + _noise(r), p1.dy + _noise(r));

    // Midpoint deviation
    final mid = Offset.lerp(p1, p2, 0.5)!;
    path.quadraticBezierTo(
      mid.dx + _noise(r) * 2,
      mid.dy + _noise(r) * 2,
      p2.dx + _noise(r),
      p2.dy + _noise(r),
    );

    canvas.drawPath(path, paint);
  }

  void _addRoughLineToPath(Path path, Offset p1, Offset p2, Random r) {
    path.moveTo(p1.dx + _noise(r), p1.dy + _noise(r));
    path.lineTo(p2.dx + _noise(r), p2.dy + _noise(r));
  }

  double _noise(Random r) =>
      (r.nextDouble() - 0.5) * 4.0; // +/- 2 pixels wobble
}
