import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _serverAddressController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _hydrateServerAddress();
  }

  Future<void> _hydrateServerAddress() async {
    final storedServerAddress = await _authController.getStoredServerAddress();
    if (!mounted) return;

    _serverAddressController.text = storedServerAddress?.isNotEmpty == true
        ? storedServerAddress!
        : (kIsWeb ? '${Uri.base.origin}/api' : 'http://localhost:8080/api');
    setState(() {});
  }

  @override
  void dispose() {
    _serverAddressController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SvgPicture.asset(
                        'assets/logo.svg',
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'MyFinance',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Obx(
                        () => _authController.serverAddress.value.isNotEmpty
                            ? _buildLoginForm()
                            : _buildServerAddressForm(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildServerAddressForm() {
    if (_serverAddressController.text.isEmpty) {
      _serverAddressController.text =
          kIsWeb ? '${Uri.base.origin}/api' : 'http://localhost:8080/api';
    }

    final serverAddressField = TextField(
      decoration: const InputDecoration(
        labelText: 'Server address',
        border: OutlineInputBorder(),
      ),
      controller: _serverAddressController,
    );

    return Column(
      children: [
        const SizedBox(height: 24),
        serverAddressField,
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            final serverAddress = serverAddressField.controller!.text.trim();
            final canConnect = await _authController.connect(serverAddress);
            if (canConnect) {
              setState(() {});
            }
          },
          child: const Text('Connect'),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () async {
            final serverAddress = serverAddressField.controller!.text.trim();
            await _authController.ping(serverAddress);
          },
          child: const Text('Ping'),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          obscureText: !_isPasswordVisible,
        ),
        const SizedBox(height: 16),
        Obx(() => ElevatedButton(
              onPressed: _authController.isLoading.value
                  ? null
                  : () => _authController.login(
                        _emailController.text,
                        _passwordController.text,
                      ),
              child: _authController.isLoading.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Login'),
            )),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Get.toNamed('/signup'),
          child: const Text("Don't have an account? Sign up"),
        ),
        TextButton(
          onPressed: () {
            _serverAddressController.text = _authController.serverAddress.value;
            _authController.serverAddress.value = '';
            setState(() {});
          },
          child: const Text('Select different server?'),
        ),
      ],
    );
  }
}
