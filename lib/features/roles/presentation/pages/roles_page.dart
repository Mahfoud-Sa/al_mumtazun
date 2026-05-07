import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/roles_cubit.dart';
import '../cubit/roles_state.dart';

class RolesPage extends StatelessWidget {
  const RolesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Roles')),
      body: BlocBuilder<RolesCubit, RolesState>(builder: (context, state) {
        if (state is RolesLoading) return const Center(child: CircularProgressIndicator());
        if (state is RolesLoaded) {
          return ListView.builder(
            itemCount: state.roles.length,
            itemBuilder: (context, i) => ListTile(title: Text(state.roles[i].name)),
          );
        }
        if (state is RolesError) return Center(child: Text(state.message));
        return Center(child: ElevatedButton(onPressed: () => context.read<RolesCubit>().fetch(), child: const Text('Load Roles')));
      }),
    );
  }
}
