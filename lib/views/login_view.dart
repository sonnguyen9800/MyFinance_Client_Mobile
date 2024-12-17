import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _serverAddressController = TextEditingController();
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
    final serverAddressField = TextField(
      decoration: const InputDecoration(
        labelText: 'Server address',
        border: OutlineInputBorder(),
      ),
      controller: _serverAddressController,
      onChanged: (value) {
        serverAddress = value;
      },
    );
    _serverAddressController.text = "http://10.0.2.2:8080/api";
    return Column(
      children: [
        const SizedBox(height: 48),
        serverAddressField,
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            serverAddress = serverAddressField.controller!.text;

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
    return Column(
        verticalDirection: VerticalDirection.down,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 10),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
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
          TextButton(
            onPressed: () => Get.toNamed('/signup'),
            child: const Text('Don\'t have an account? Sign up'),
          ),
          TextButton(
            onPressed: () {
              _authController.serverAddress.value = '';
              setState(() {});
            },
            child: const Text('Select different server?'),
          ),
        ]);
  }
}
