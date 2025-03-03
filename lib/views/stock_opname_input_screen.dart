import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../view_models/stock_opname_input_view_model.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/scan_location_dialog.dart';
import '../widgets/add_manual_dialog.dart';

class StockOpnameInputScreen extends StatefulWidget {
  final String noSO;
  final String tgl;

  const StockOpnameInputScreen({Key? key, required this.noSO, required this.tgl}) : super(key: key);

  @override
  _StockOpnameInputScreenState createState() => _StockOpnameInputScreenState();
}

class _StockOpnameInputScreenState extends State<StockOpnameInputScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedFilter;
  String? _selectedLocation;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<StockOpnameInputViewModel>(context, listen: false);
      viewModel.fetchInitialData(widget.noSO);

      _scrollController.addListener(() {
        if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
          if (!isLoadingMore) {
            isLoadingMore = true;
            viewModel.loadMoreData(widget.noSO).then((_) {
              isLoadingMore = false;
            });
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.noSO,
          style: const TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF8D6E63),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => _showFilterOptions(context),
          ),
        ],
      ),
      body: Consumer<StockOpnameInputViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isInitialLoading && viewModel.noLabelList.isEmpty) {
            return const LoadingSkeleton();
          }

          if (viewModel.errorMessage.isNotEmpty) {
            return Center(
              child: Text(
                viewModel.errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          if (!viewModel.noLabelFound) {
            return const Center(
              child: Text(
                'Data Tidak Ditemukan',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: viewModel.noLabelList.length + (viewModel.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == viewModel.noLabelList.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final noLabel = viewModel.noLabelList[index];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      noLabel.combinedLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      noLabel.labelType ?? 'Tidak Ada Tipe',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      'Lokasi Label: ${noLabel.labelLocation ?? "Tidak Ada"}',
                      style: const TextStyle(fontSize: 14, color: Colors.blueAccent),
                    ),
                    const Divider(),
                  ],
                ),
              );
            },
            cacheExtent: 1000,
          );
        },
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: const Color(0xFF8D6E63),
        foregroundColor: Colors.white,
        visible: true,
        curve: Curves.linear,
        spaceBetweenChildren: 16,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.qr_code),
            label: 'Scan QR',
            onTap: () {
              _showScanLocationSelectionDialog(context);
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.add),
            label: 'Input Manual',
            onTap: () {
              _showAddManualDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFilterOption(context, 'Semua', null),
                  _buildFilterOption(context, 'Sawn Timber', 'st'),
                  _buildFilterOption(context, 'S4S', 's4s'),
                  _buildFilterOption(context, 'Finger Joint', 'fj'),
                  _buildFilterOption(context, 'Moulding', 'moulding'),
                  _buildFilterOption(context, 'Laminating', 'laminating'),
                  _buildFilterOption(context, 'CC Akhir', 'ccakhir'),
                  _buildFilterOption(context, 'Sanding', 'sanding'),
                  _buildFilterOption(context, 'Barang Jadi', 'bj'),
                  _buildFilterOption(context, 'Kayu Bulat', 'kayubulat'),

                  // Dropdown Filter Lokasi
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Filter Berdasarkan Lokasi',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedLocation, // Default value is null
                      items: [
                        // Add 'Semua' option that represents null
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('Semua'), // This is the 'null' option
                        ),
                        // Add the actual location items
                        ...Provider.of<StockOpnameInputViewModel>(context, listen: false)
                            .blokList
                            .map((lokasi) => DropdownMenuItem<String>(
                          value: lokasi.idLokasi,
                          child: Text('${lokasi.idLokasi} - ${lokasi.blok}'),
                        ))
                            .toList(),
                      ],
                      onChanged: (selectedIdLokasi) {
                        setState(() {
                          _selectedLocation = selectedIdLokasi;
                        });

                        final viewModel =
                        Provider.of<StockOpnameInputViewModel>(context, listen: false);
                        // Pass null if 'Semua' is selected
                        viewModel.fetchData(widget.noSO, filterBy: _selectedFilter, idLokasi: _selectedLocation);

                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildFilterOption(BuildContext context, String label, String? value) {
    final isSelected = _selectedFilter == value;

    return ListTile(
      title: Text(label, style: TextStyle(color: isSelected ? Colors.blue : Colors.black)),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });

        final viewModel = Provider.of<StockOpnameInputViewModel>(context, listen: false);
        viewModel.fetchData(widget.noSO, filterBy: value, idLokasi: _selectedLocation);

        Navigator.pop(context);
      },
    );
  }

  void _showScanLocationSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ScanLocationDialog(noSO: widget.noSO);
      },
    );
  }

  void _showAddManualDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddManualDialog(noSO: widget.noSO);
      },
    );
  }
}
