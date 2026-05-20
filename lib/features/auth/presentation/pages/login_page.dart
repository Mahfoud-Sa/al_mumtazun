import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthAuthenticated) Navigator.of(context).pop();
                if (state is AuthError)
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
              },
              builder: (context, state) {
                if (state is AuthLoading)
                  return const CircularProgressIndicator();
                return ElevatedButton(
                  onPressed: () => context.read<AuthCubit>().login(
                    emailCtrl.text.trim(),
                    passCtrl.text,
                  ),
                  child: const Text('Login'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
