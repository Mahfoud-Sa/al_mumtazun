// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../cubit/inventory_cubit.dart';
// import '../cubit/inventory_state.dart';

// class InventoryPage extends StatelessWidget {
//   const InventoryPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Inventory')),
//       body: BlocBuilder<InventoryCubit, InventoryState>(builder: (context, state) {
//         if (state is InventoryLoading) return const Center(child: CircularProgressIndicator());
//         if (state is InventoryLoaded) {
//           return ListView.builder(
//             itemCount: state.items.length,
//             itemBuilder: (context, i) => ListTile(title: Text(state.items[i].name), subtitle: Text('Qty: ${state.items[i].quantity}')),
//           );
//         }
//         if (state is InventoryError) return Center(child: Text(state.message));
//         return Center(child: ElevatedButton(onPressed: () => context.read<InventoryCubit>().fetch(), child: const Text('Load Items')));
//       }),
//     );
//   }
// }
