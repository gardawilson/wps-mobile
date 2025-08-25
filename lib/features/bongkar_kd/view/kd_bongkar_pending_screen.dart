import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wps_mobile/features/bongkar_kd/view/kd_bongkar_detail_screen.dart';
import '../view_model/kd_bongkar_view_model.dart';
import '../../../core/widgets/loading_skeleton.dart';


class KdBongkarPendingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<KDBongkarViewModel>(context, listen: false)
          .fetchKDBongkarList(isPending: true);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KD Pending',
          style: TextStyle(color: Colors.white),
        ),        backgroundColor: const Color(0xFF755330),
      ),
      body: Consumer<KDBongkarViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.kdBongkarList.isEmpty) {
            return const LoadingSkeleton();
          }

          if (viewModel.kdBongkarList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    viewModel.errorMessage,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.fetchKDBongkarList(isPending: true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF755330),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    viewModel.errorMessage,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.fetchKDBongkarList(isPending: true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF755330),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await viewModel.fetchKDBongkarList(isPending: true);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(10),
              itemCount: viewModel.kdBongkarList.length,
              itemBuilder: (context, index) {
                final bongkarKD = viewModel.kdBongkarList[index];

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => KDBongkarDetailScreen(
                            noProcKD: bongkarKD.noProcKD,
                            tgl: bongkarKD.tglMasuk,
                            tglKeluar: bongkarKD.tglKeluar.toString(),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDFBF8),
                        border: Border(
                          left: BorderSide(color: Colors.brown.shade300, width: 4),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bongkarKD.noProcKD,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4B322A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No. KD: ${bongkarKD.noRuangKD}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // 👉 Tanggal Masuk dengan icon
                          Row(
                            children: [
                              const Icon(Icons.login, size: 16, color: Colors.brown),
                              const SizedBox(width: 6),
                              Text(
                                'Masuk: ${bongkarKD.tglMasuk}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // 👉 Tanggal Keluar dengan icon
                          Row(
                            children: [
                              const Icon(Icons.logout, size: 16, color: Colors.green),
                              const SizedBox(width: 6),
                              Text(
                                'Keluar: ${bongkarKD.tglKeluar}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                    ),
                  ),
                );


              },
              separatorBuilder: (context, index) => const SizedBox(height: 10),
            ),
          );
        },
      ),
    );
  }

}
