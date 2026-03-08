import 'package:flutter/material.dart';
import '../auth_controller.dart';

class LoginScreen extends StatefulWidget {
  final AuthController authController;

  const LoginScreen({
    super.key,
    required this.authController,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _showPassword = false;
  bool _loading = false;
  String? _errorMessage;

  static const _lime = Color(0xFFB4FF3C);
  static const _bg = Color(0xFF0D0D0D);

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
      _loading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required.';
        _loading = false;
      });
      return;
    }

    try {
      final result = await widget.authController.login(
        username: username,
        password: password,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        Navigator.pushReplacementNamed(context, '/pose');
      } else {
        setState(() {
          _errorMessage = result['error']?.toString() ?? 'Invalid credentials.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Login failed: $e';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Background grid
          CustomPaint(
            painter: _GridPainter(),
            size: MediaQuery.of(context).size,
          ),
          // Green glow top-left
          Positioned(
            top: -60,
            left: -60,
            child: _Orb(color: _lime.withValues(alpha: 0.09), size: 420),
          ),
          // Orange glow bottom-right
          Positioned(
            bottom: -80,
            right: -60,
            child: _Orb(
              color: const Color(0xFFFF641E).withValues(alpha: 0.08),
              size: 380,
            ),
          ),
          // Main content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 48,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.025),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 96,
                        offset: const Offset(0, 48),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFB4FF3C),
                                    Color(0xFF7ECF00),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: _lime.withValues(alpha: 0.35),
                                    blurRadius: 40,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.fitness_center,
                                color: Color(0xFF0D0D0D),
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Colors.white, Color(0x66FFFFFF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: const Text(
                                'Pose Coach',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'MOTION ANALYSIS PLATFORM',
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Welcome text
                      const Text(
                        'Ready to train?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xE6FFFFFF),
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Sign in and pick up where you left off',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Username field
                      _FieldLabel('USERNAME'),
                      const SizedBox(height: 8),
                      _InputField(
                        controller: _usernameController,
                        focusNode: _usernameFocus,
                        hint: 'your_username',
                        icon: Icons.person_outline_rounded,
                        keyboardType: TextInputType.text,
                        accentColor: _lime,
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      _FieldLabel('PASSWORD'),
                      const SizedBox(height: 8),
                      _InputField(
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        obscure: !_showPassword,
                        accentColor: _lime,
                        suffix: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.white.withValues(alpha: 0.35),
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                        ),
                      ),

                      // Error message
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.redAccent.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFFF6B6B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),

                      // Sign in button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: _loading
                                ? null
                                : const LinearGradient(
                                    colors: [
                                      Color(0xFFB4FF3C),
                                      Color(0xFF89D400),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            color: _loading ? _lime.withValues(alpha: 0.2) : null,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: _loading
                                ? []
                                : [
                                    BoxShadow(
                                      color: _lime.withValues(alpha: 0.3),
                                      blurRadius: 28,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                          ),
                          child: TextButton(
                            onPressed: _loading ? null : _handleLogin,
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _loading
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white.withValues(alpha: 0.6),
                                    ),
                                  )
                                : const Text(
                                    "LET'S GO →",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0D0D0D),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'or',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Create account
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.28),
                              ),
                              children: const [
                                TextSpan(text: 'New here? '),
                                TextSpan(
                                  text: 'Create account',
                                  style: TextStyle(
                                    color: Color(0xFFB4FF3C),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// — Helpers —

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: Colors.white.withValues(alpha: 0.35),
    ),
  );
}

class _InputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboardType;
  final Color accentColor;
  final Widget? suffix;

  const _InputField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.icon,
    required this.accentColor,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.suffix,
  });

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(
      () => setState(() => _focused = widget.focusNode.hasFocus),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _focused
            ? widget.accentColor.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focused
              ? widget.accentColor.withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: 0.07),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        obscureText: widget.obscure,
        keyboardType: widget.keyboardType,
        style: const TextStyle(fontSize: 14, color: Color(0xE0FFFFFF)),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.18)),
          prefixIcon: Icon(
            widget.icon,
            color: _focused
                ? widget.accentColor.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.3),
            size: 20,
          ),
          suffixIcon: widget.suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  final Color color;
  final double size;
  const _Orb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [color, Colors.transparent]),
    ),
  );
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB4FF3C).withValues(alpha: 0.03)
      ..strokeWidth = 1;
    const step = 48.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}