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
            onPressed: () {
              // Button is kept, but now it does nothing
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter options outside the button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFilterDropdown(),
                _buildLocationDropdown(),
              ],
            ),
          ),
          Expanded(
            child: Consumer<StockOpnameInputViewModel>(
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
          ),
        ],
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

  Widget _buildFilterDropdown() {
    return DropdownButton<String>(
      value: _selectedFilter,
      hint: const Text('Filter Label'),
      onChanged: (value) {
        setState(() {
          _selectedFilter = value;
        });

        final viewModel = Provider.of<StockOpnameInputViewModel>(context, listen: false);
        viewModel.fetchData(widget.noSO, filterBy: _selectedFilter, idLokasi: _selectedLocation);
      },
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text('Semua'),
        ),
        DropdownMenuItem<String>(
          value: 'st',
          child: Text('Sawn Timber'),
        ),
        DropdownMenuItem<String>(
          value: 's4s',
          child: Text('S4S'),
        ),
        DropdownMenuItem<String>(
          value: 'fj',
          child: Text('Finger Joint'),
        ),
        DropdownMenuItem<String>(
          value: 'moulding',
          child: Text('Moulding'),
        ),
        DropdownMenuItem<String>(
          value: 'laminating',
          child: Text('Laminating'),
        ),
        DropdownMenuItem<String>(
          value: 'ccakhir',
          child: Text('CC Akhir'),
        ),
        DropdownMenuItem<String>(
          value: 'sanding',
          child: Text('Sanding'),
        ),
        DropdownMenuItem<String>(
          value: 'bj',
          child: Text('Barang Jadi'),
        ),
        DropdownMenuItem<String>(
          value: 'kayubulat',
          child: Text('Kayu Bulat'),
        ),
      ],
    );
  }

  Widget _buildLocationDropdown() {
    return DropdownButton<String>(
      value: _selectedLocation,
      hint: const Text('Filter Lokasi'),
      onChanged: (selectedIdLokasi) {
        setState(() {
          _selectedLocation = selectedIdLokasi;
        });

        final viewModel = Provider.of<StockOpnameInputViewModel>(context, listen: false);
        viewModel.fetchData(widget.noSO, filterBy: _selectedFilter, idLokasi: _selectedLocation);
      },
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text('Semua'),
        ),
        ...Provider.of<StockOpnameInputViewModel>(context, listen: false)
            .blokList
            .map((lokasi) => DropdownMenuItem<String>(
          value: lokasi.idLokasi,
          child: Text('${lokasi.idLokasi} - ${lokasi.blok}'),
        ))
            .toList(),
      ],
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
