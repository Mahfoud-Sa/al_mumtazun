import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_cubit.dart';

class RoleGuard extends StatelessWidget {
  final List<String> allowedRoles;
  final Widget child;

  const RoleGuard({super.key, required this.allowedRoles, required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    if (!auth.isLoggedIn || !auth.hasAnyRole(allowedRoles)) {
      return const UnauthorizedPage();
    }
    return child;
  }
}

class UnauthorizedPage extends StatelessWidget {
  const UnauthorizedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text('ليس لديك صلاحية للوصول إلى هذه الصفحة')),
    );
  }
}
