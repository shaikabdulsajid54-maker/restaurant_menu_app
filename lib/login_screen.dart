import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Login screen for The Grand Kitchen menu app.
/// Everything happens on this one page:
///   - Mobile number -> inline OTP entry (no separate screen)
///   - "Continue with Email" -> inline email field
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneFormKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  // 4-digit OTP boxes
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());

  bool _isSendingOtp = false;
  bool _otpSent = false;
  bool _isVerifying = false;

  bool _showEmailField = false;
  bool _isEmailSubmitting = false;

  // Brand accent color — warm food-app orange/red
  static const Color primaryColor = Color(0xFFFF5A3C);
  static const Color darkText = Color(0xFF1F1B24);
  static const Color mutedText = Color(0xFF8C8A94);

  // Full-screen background food photo (swap for your own asset if you have one)
  static const String backgroundImageUrl =
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1200&q=80';

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // ---- Mobile + OTP flow ----

  void _sendOtp() {
    if (!_phoneFormKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSendingOtp = true);

    // TODO: replace with a real "send OTP" API call
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _isSendingOtp = false;
        _otpSent = true;
      });
      // Jump focus to the first OTP box
      FocusScope.of(context).requestFocus(_otpFocusNodes.first);
    });
  }

  void _resendOtp() {
    for (final c in _otpControllers) {
      c.clear();
    }
    _sendOtp();
  }

  void _changeNumber() {
    setState(() {
      _otpSent = false;
      for (final c in _otpControllers) {
        c.clear();
      }
    });
  }

  void _onOtpDigitChanged(String value, int index) {
    if (value.isNotEmpty && index < _otpFocusNodes.length - 1) {
      FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
    }
    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
    }
  }

  void _verifyOtp() {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the full 4-digit OTP')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _isVerifying = true);

    // TODO: replace with a real "verify OTP" API call, then navigate
    // to the home / menu screen on success.
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _isVerifying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP verified — welcome!')),
      );
    });
  }

  // ---- Email flow ----

  void _toggleEmailField() {
    setState(() => _showEmailField = !_showEmailField);
  }

  void _submitEmail() {
    if (!_emailFormKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isEmailSubmitting = true);

    // TODO: replace with a real email login/sign-up API call
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isEmailSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged in successfully')),
      );
    });
  }

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  void _forgotPassword() {
    // TODO: navigate to your forgot-password / reset flow
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Forgot password tapped')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ---- Background food photo ----
          Image.network(
            backgroundImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: darkText),
          ),

          // ---- Dark gradient overlay so content stays readable ----
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black54, Colors.black45, Colors.black87],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // ---- Centered content ----
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      48,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ---- Logo + restaurant name ----
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        // Fork + spoon icon
                        child: const Icon(
                          Icons.restaurant_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'The Grand Kitchen',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'MULTI-CUISINE RESTAURANT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                          letterSpacing: 1.4,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ---- Card holding the whole form ----
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _otpSent ? 'Verify your number' : 'Welcome back',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: darkText,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _otpSent
                                  ? 'Enter the 4-digit code sent to\n+91 ${_phoneController.text}'
                                  : 'Log in to browse our full menu and\nsave your favourite dishes',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: mutedText,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 22),

                            // ---- Mobile number / OTP section ----
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: _otpSent ? _buildOtpSection() : _buildPhoneSection(),
                            ),

                            const SizedBox(height: 20),

                            // ---- Divider ----
                            Row(
                              children: const [
                                Expanded(child: Divider(color: Color(0xFFE2E0E6))),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('or', style: TextStyle(color: mutedText, fontSize: 13)),
                                ),
                                Expanded(child: Divider(color: Color(0xFFE2E0E6))),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // ---- Email section (toggles open inline) ----
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: _showEmailField ? _buildEmailFields() : _buildEmailToggle(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ---- Terms & privacy ----
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.5),
                          children: [
                            TextSpan(text: 'By continuing, you agree to our\n'),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                            TextSpan(text: '  &  '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                          ],
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

  // ---- Mobile number input + "Send OTP" button ----
  Widget _buildPhoneSection() {
    return Form(
      key: _phoneFormKey,
      child: Column(
        key: const ValueKey('phone-section'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E0E6)),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('🇮🇳', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 6),
                      Text('+91',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: darkText)),
                    ],
                  ),
                ),
                Container(height: 26, width: 1, color: const Color(0xFFE2E0E6)),
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      counterText: '',
                      hintText: 'Enter mobile number',
                      hintStyle: TextStyle(color: mutedText, fontWeight: FontWeight.w400),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter your mobile number';
                      if (value.length != 10) return 'Enter a valid 10-digit number';
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isSendingOtp ? null : _sendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSendingOtp
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                    )
                  : const Text('Send OTP',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  // ---- OTP boxes + Verify button ----
  Widget _buildOtpSection() {
    return Column(
      key: const ValueKey('otp-section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (i) {
            return SizedBox(
              width: 56,
              height: 56,
              child: TextField(
                controller: _otpControllers[i],
                focusNode: _otpFocusNodes[i],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFFF5F4F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: primaryColor, width: 1.5),
                  ),
                ),
                onChanged: (value) => _onOtpDigitChanged(value, i),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _isVerifying ? null : _verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isVerifying
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                  )
                : const Text('Verify & Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _changeNumber,
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: const Text('Change number',
                  style: TextStyle(fontSize: 12.5, color: mutedText, fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: _isSendingOtp ? null : _resendOtp,
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: const Text('Resend OTP',
                  style: TextStyle(fontSize: 12.5, color: primaryColor, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ],
    );
  }

  // ---- "Continue with Email" collapsed button ----
  Widget _buildEmailToggle() {
    return SizedBox(
      key: const ValueKey('email-toggle'),
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _toggleEmailField,
        icon: const Icon(Icons.mail_outline_rounded, color: darkText, size: 20),
        label: const Text('Continue with Email',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: darkText)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE2E0E6)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ---- Expanded email field + submit ----
  Widget _buildEmailFields() {
    return Form(
      key: _emailFormKey,
      child: Column(
        key: const ValueKey('email-fields'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E0E6)),
            ),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                hintText: 'Enter your email address',
                hintStyle: TextStyle(color: mutedText, fontWeight: FontWeight.w400),
                prefixIcon: Icon(Icons.mail_outline_rounded, color: mutedText, size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter your email address';
                final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
                if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
                return null;
              },
            ),
          ),
          const SizedBox(height: 12),

          // ---- Password field ----
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E0E6)),
            ),
            child: TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Enter your password',
                hintStyle: const TextStyle(color: mutedText, fontWeight: FontWeight.w400),
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: mutedText, size: 20),
                suffixIcon: IconButton(
                  onPressed: _togglePasswordVisibility,
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: mutedText,
                    size: 20,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter your password';
                if (value.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _forgotPassword,
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
              child: const Text('Forgot password?',
                  style: TextStyle(fontSize: 12.5, color: primaryColor, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isEmailSubmitting ? null : _submitEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isEmailSubmitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                    )
                  : const Text('Login',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: _toggleEmailField,
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: const Text('Use mobile number instead',
                  style: TextStyle(fontSize: 12.5, color: mutedText, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}