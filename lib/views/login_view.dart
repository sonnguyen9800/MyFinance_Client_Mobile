import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatefulWidget {
  LoginView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'MyFinance',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_authController.serverAddress.value.isNotEmpty)
                  _renderLoginForm()
                else
                  _renderServerAddressForm(),
              ]),
        ),
      ),
    );
  }

  _renderServerAddressForm() {
    String serverAddress = "";
    return Column(
      children: [
        const SizedBox(height: 48),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Server address',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            serverAddress = value;
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            final canConnect = await _authController.connect(serverAddress);
            if (canConnect) {
              setState(() {}); // refresh the UI  to show the login form
            }
          },
          child: const Text('Connect'),
        ),
      ],
    );
  }

  _renderLoginForm() {
    return Column(children: [
      const SizedBox(height: 48),
      TextField(
        controller: _emailController,
        decoration: const InputDecoration(
          labelText: 'Email',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _passwordController,
        decoration: const InputDecoration(
          labelText: 'Password',
          border: OutlineInputBorder(),
        ),
        obscureText: true,
      ),
      const SizedBox(height: 24),
      Obx(() => ElevatedButton(
            onPressed: _authController.isLoading.value
                ? null
                : () => _authController.login(
                      _emailController.text,
                      _passwordController.text,
                    ),
            child: _authController.isLoading.value
                ? const CircularProgressIndicator()
                : const Text('Login'),
          )),
      const SizedBox(height: 16),
      TextButton(
        onPressed: () => Get.toNamed('/signup'),
        child: const Text('Don\'t have an account? Sign up'),
      ),
    ]);
  }
}
