import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../utils/theme.dart';
import '../../widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _showPass = false;

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_email.text, _pass.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, auth.isAdmin ? '/admin' : '/commuter');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error ?? 'Failed'), backgroundColor: AppColors.red));
    }
  }

  void _fill(bool admin) { _email.text = admin ? 'admin@transit.gov' : 'priya@gmail.com'; _pass.text = admin ? 'admin123' : 'pass123'; }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg,
    body: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF091624), AppColors.bg])),
      child: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Form(key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 20),
        Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.cyan.withOpacity(0.12), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.cyan.withOpacity(0.3))),
            child: const Text('🚌', style: TextStyle(fontSize: 22))),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SMART CITY', style: TextStyle(fontSize: 10, color: AppColors.cyan, letterSpacing: 2.5, fontWeight: FontWeight.w700)),
            const Text('Transport', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textW, fontFamily: 'SpaceGrotesk')),
          ]),
        ]),
        const SizedBox(height: 48),
        const Text('Welcome Back 👋', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textW, fontFamily: 'SpaceGrotesk')),
        const SizedBox(height: 4),
        const Text('Sign in to your account', style: TextStyle(color: AppColors.textM, fontSize: 14)),
        const SizedBox(height: 28),
        AppField(ctrl: _email, label: 'Email', icon: Icons.alternate_email, keyType: TextInputType.emailAddress,
          validator: (v) => v?.contains('@') != true ? 'Enter valid email' : null),
        const SizedBox(height: 12),
        AppField(ctrl: _pass, label: 'Password', icon: Icons.lock_outline, obscure: !_showPass,
          suffix: GestureDetector(onTap: () => setState(() => _showPass = !_showPass),
            child: Text(_showPass ? 'Hide' : 'Show', style: const TextStyle(color: AppColors.cyan, fontSize: 12))),
          validator: (v) => v?.isEmpty == true ? 'Enter password' : null),
        const SizedBox(height: 28),
        Consumer<AuthProvider>(builder: (_, auth, _) => SizedBox(width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: auth.loading ? null : _login,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyan, foregroundColor: AppColors.bg, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: auth.loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.bg)) : const Text('SIGN IN', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 1)),
          ))),
        const SizedBox(height: 24),
        Row(children: const [Expanded(child: Divider(color: AppColors.border)), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('DEMO ACCOUNTS', style: TextStyle(color: AppColors.textM, fontSize: 9, letterSpacing: 1.5))), Expanded(child: Divider(color: AppColors.border))]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: () => _fill(false), icon: const Text('🧑‍💼', style: TextStyle(fontSize: 13)), label: const Text('Commuter', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.textL, side: const BorderSide(color: AppColors.border), padding: const EdgeInsets.symmetric(vertical: 10)))),
          const SizedBox(width: 10),
          Expanded(child: OutlinedButton.icon(onPressed: () => _fill(true), icon: const Text('🛡️', style: TextStyle(fontSize: 13)), label: const Text('Admin', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.adminPurple, side: BorderSide(color: AppColors.adminPurple.withOpacity(0.5)), padding: const EdgeInsets.symmetric(vertical: 10)))),
        ]),
        const SizedBox(height: 28),
        Center(child: GestureDetector(onTap: () => Navigator.pushNamed(context, '/register'),
          child: const Text.rich(TextSpan(text: "Don't have an account? ", style: TextStyle(color: AppColors.textM, fontSize: 13),
            children: [TextSpan(text: 'Register', style: TextStyle(color: AppColors.cyan, fontWeight: FontWeight.w700))])))),
      ])))),
    ),
  );
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(), _email = TextEditingController(),
    _phone = TextEditingController(), _pass = TextEditingController(), _confirm = TextEditingController();
  String _role = 'commuter';
  bool _showPass = false;

  Future<void> _register() async {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(name: _name.text, email: _email.text, password: _pass.text, phone: _phone.text, role: _role);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, auth.isAdmin ? '/admin' : '/commuter');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error ?? 'Failed'), backgroundColor: AppColors.red));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg,
    appBar: AppBar(title: const Text('Create Account'), leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 16), onPressed: () => Navigator.pop(context))),
    body: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Form(key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Join Transit 🚌', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textW, fontFamily: 'SpaceGrotesk')),
      const SizedBox(height: 4),
      const Text('Create account to access all features', style: TextStyle(color: AppColors.textM)),
      const SizedBox(height: 24),
      GCard(padding: const EdgeInsets.all(4), child: Row(children: [
        _roleBtn('🧑‍💼 Commuter', 'commuter'), _roleBtn('🛡️ Admin', 'admin'),
      ])),
      const SizedBox(height: 14),
      AppField(ctrl: _name, label: 'Full Name', icon: Icons.person_outline, validator: (v) => v?.isEmpty == true ? 'Required' : null),
      const SizedBox(height: 10),
      AppField(ctrl: _email, label: 'Email', icon: Icons.alternate_email, keyType: TextInputType.emailAddress, validator: (v) => v?.contains('@') != true ? 'Invalid email' : null),
      const SizedBox(height: 10),
      AppField(ctrl: _phone, label: 'Phone', icon: Icons.phone_outlined, keyType: TextInputType.phone, validator: (v) => (v?.length ?? 0) < 10 ? 'Enter 10-digit number' : null),
      const SizedBox(height: 10),
      AppField(ctrl: _pass, label: 'Password', icon: Icons.lock_outline, obscure: !_showPass,
        suffix: GestureDetector(onTap: () => setState(() => _showPass = !_showPass), child: Text(_showPass ? 'Hide' : 'Show', style: const TextStyle(color: AppColors.cyan, fontSize: 12))),
        validator: (v) => (v?.length ?? 0) < 6 ? 'Min 6 characters' : null),
      const SizedBox(height: 10),
      AppField(ctrl: _confirm, label: 'Confirm Password', icon: Icons.lock_outline, obscure: true, validator: (v) => v != _pass.text ? 'Passwords do not match' : null),
      const SizedBox(height: 28),
      Consumer<AuthProvider>(builder: (_, auth, _) => SizedBox(width: double.infinity, height: 52,
        child: ElevatedButton(
          onPressed: auth.loading ? null : _register,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyan, foregroundColor: AppColors.bg, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          child: auth.loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.bg)) : const Text('CREATE ACCOUNT', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 1)),
        ))),
      const SizedBox(height: 16),
      Center(child: GestureDetector(onTap: () => Navigator.pop(context),
        child: const Text.rich(TextSpan(text: 'Already registered? ', style: TextStyle(color: AppColors.textM, fontSize: 13),
          children: [TextSpan(text: 'Sign In', style: TextStyle(color: AppColors.cyan, fontWeight: FontWeight.w700))])))),
    ]))),
  );

  Widget _roleBtn(String label, String role) {
    final sel = _role == role;
    return Expanded(child: GestureDetector(onTap: () => setState(() => _role = role),
      child: AnimatedContainer(duration: const Duration(milliseconds: 200), margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: sel ? AppColors.cyan : Colors.transparent, borderRadius: BorderRadius.circular(10)),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: sel ? AppColors.bg : AppColors.textM, fontSize: 12, fontWeight: FontWeight.w700)))));
  }
}
