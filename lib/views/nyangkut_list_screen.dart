import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../view_models/nyangkut_list_view_model.dart';
import 'nyangkut_detail_screen.dart';

class NyangkutListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NyangkutListViewModel>(context, listen: false)
          .fetchNyangkutList();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nyangkut List',
          style: TextStyle(color: Colors.white),
        ),        backgroundColor: const Color(0xFF755330),
      ),
      body: Consumer<NyangkutListViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.nyangkutList.isEmpty) {
            return _buildLoadingSkeleton();
          }

          if (viewModel.nyangkutList.isEmpty) {
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
                      viewModel.fetchNyangkutList();
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
                      viewModel.fetchNyangkutList();
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
              await viewModel.fetchNyangkutList();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(10),
              itemCount: viewModel.nyangkutList.length,
              itemBuilder: (context, index) {
                final nyangkut = viewModel.nyangkutList[index];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NyangkutDetailScreen(
                            noNyangkut: nyangkut.NoNyangkut,
                            tgl: nyangkut.tgl,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nyangkut.NoNyangkut,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF755330),
                              ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            nyangkut.tgl,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF755330),
                            ),
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

  // Widget untuk menampilkan loading skeleton dengan shimmer effect
  Widget _buildLoadingSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.separated(
        padding: const EdgeInsets.all(10),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 10),
      ),
    );
  }
}
