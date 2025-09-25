import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/kayu_bulat_view_model.dart';
import '../../../core/widgets/loading_skeleton.dart';
import 'kayu_bulat_attachment_screen.dart';

class KayuBulatScreen extends StatefulWidget {
  const KayuBulatScreen({super.key});

  @override
  State<KayuBulatScreen> createState() => _KayuBulatScreenState();
}

class _KayuBulatScreenState extends State<KayuBulatScreen> {
  @override
  void initState() {
    super.initState();
    // fetch data pertama kali setelah widget ter-load
    Future.microtask(() =>
        Provider.of<KayuBulatViewModel>(context, listen: false).fetchAll()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Data Kayu Bulat",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF755330),
      ),
      body: Consumer<KayuBulatViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading && vm.list.isEmpty) {
            return const LoadingSkeleton();
          }

          if (vm.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(vm.errorMessage, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => vm.fetchAll(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF755330),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Retry"),
                  )
                ],
              ),
            );
          }

          if (vm.list.isEmpty) {
            return const Center(child: Text("Tidak ada data kayu bulat."));
          }

          return RefreshIndicator(
            onRefresh: () => vm.fetchAll(),
            child: ListView.separated(
              padding: const EdgeInsets.all(10),
              itemCount: vm.list.length,
              itemBuilder: (context, index) {
                final item = vm.list[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.local_florist, // bisa diganti icon kayu/log
                      color: Colors.brown.shade400,
                    ),
                    title: Text(
                      item.noKayuBulat,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B322A),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Suket: ${item.suket}"),
                        Text("Truk: ${item.noTruk} (${item.noPlat})"),
                        Text("Tanggal masuk: ${item.dateCreate}"),
                      ],
                    ),
                    trailing: Icon(
                      item.approve == 1 ? Icons.verified : Icons.pending,
                      color: item.approve == 1 ? Colors.green : Colors.orange,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => KayuBulatAttachmentScreen(noKayuBulat: item.noKayuBulat),
                        ),
                      );
                    },
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 5),
            ),
          );
        },
      ),
    );
  }
}
