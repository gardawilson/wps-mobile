import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:wps_stockopname/view_models/lokasi_view_model.dart';
import '../view_models/mapping_lokasi_view_model.dart';
import '../widgets/loading_skeleton.dart';
import '../views/barcode_qr_scan_mapping_screen.dart';
import 'package:searchfield/searchfield.dart';

class MappingLokasiScreen extends StatefulWidget {
  const MappingLokasiScreen({Key? key}) : super(key: key);

  @override
  _MappingLokasiScreenState createState() => _MappingLokasiScreenState();
}

class _MappingLokasiScreenState extends State<MappingLokasiScreen> {
  final TextEditingController _locationController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _selectedFilter;
  String? _selectedLocation;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mappingVM = Provider.of<MappingLokasiViewModel>(context, listen: false);
      final lokasiVM = Provider.of<LokasiViewModel>(context, listen: false);

      lokasiVM.fetchLokasi();
      mappingVM.fetchData();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
        if (!isLoadingMore) {
          setState(() {
            isLoadingMore = true;
          });

          final mappingVM = Provider.of<MappingLokasiViewModel>(context, listen: false);
          mappingVM.loadMoreData().then((_) {
            if (mounted) {
              setState(() {
                isLoadingMore = false;
              });
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mapping Lokasi',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF755330),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1, // Bisa disesuaikan jika mau ukuran berbeda
                  child: _buildFilterDropdown(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildLocationDropdown(),
                ),
              ],
            ),
          ),
          // Tambahkan summary section untuk menampilkan total M3
          _buildSummarySection(),
          Expanded(
            child: Consumer<MappingLokasiViewModel>(
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tidak Ada Data',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
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
                    return _buildLabelCard(noLabel);
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
        backgroundColor: const Color(0xFF755330),
        foregroundColor: Colors.white,
        visible: true,
        curve: Curves.linear,
        spaceBetweenChildren: 16,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.qr_code),
            label: 'Scan QR',
            onTap: () {
              _showScanBarQRCode(context);
            },
          ),
        ],
      ),
    );
  }

  // Widget baru untuk menampilkan summary total M3
  Widget _buildSummarySection() {
    return Consumer<MappingLokasiViewModel>(
      builder: (context, viewModel, child) {
        // Asumsikan viewModel memiliki property summary atau cara mengakses LabelSummary
        // Anda perlu menyesuaikan ini dengan struktur MappingLokasiViewModel Anda
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF755330).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: const Color(0xFF755330).withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSummaryItem(
                'Total Label',
                _formatNumber(viewModel.totalData),
                Icons.label,
                Colors.black,
              ),
              _buildSummaryItem(
                'Total M³',
                _formatM3(viewModel.summary?.totalM3),
                Icons.view_in_ar,
                Colors.orange,
              ),
              _buildSummaryItem(
                'Total Pcs',
                _formatNumber(viewModel.summary?.totalJumlah ?? 0),
                Icons.format_list_numbered,
                Colors.green,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLabelCard(dynamic noLabel) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header: Label & Date ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    noLabel.combinedLabel ?? 'Unknown Label',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  noLabel.dateCreate ?? '-',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 8),
            const Divider(height: 1, color: Colors.grey),
            const SizedBox(height: 8),

            // --- Detail Info Secara Vertikal ---
            _buildInfoRow(
              icon: Icons.category,
              label: noLabel.labelType ?? 'Tidak Ada Tipe',
              textStyle: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            _buildInfoRow(
              icon: Icons.location_on,
              label: 'Lokasi: ${noLabel.labelLocation ?? "-"}',
              textStyle: const TextStyle(fontSize: 14, color: Colors.blueAccent),
            ),
            if (noLabel.labelM3 != null && noLabel.labelM3.isNotEmpty) ...[
              const SizedBox(height: 6),
              _buildInfoRow(
                icon: Icons.view_in_ar,
                label: 'M³: ${_formatM3(noLabel.labelM3)}',
                textStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (noLabel.hasDetails) ...[
              const SizedBox(height: 6),
              _buildInfoRow(
                icon: Icons.list_alt,
                label: '${noLabel.totalBatang} batang (${noLabel.totalDetails} detail)',
                textStyle: const TextStyle(fontSize: 12, color: Colors.green),
              ),
            ],
          ],
        ),

        // --- Expanded Detail Content ---
        children: _buildExpansionChildren(noLabel),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required TextStyle textStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: textStyle.color),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: textStyle)),
      ],
    );
  }


  List<Widget> _buildExpansionChildren(dynamic noLabel) {
    if (noLabel.hasDetails) {
      return [
        const Divider(),
        _buildTableView(noLabel.details),
      ];
    } else {
      return [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Tidak ada detail tersedia',
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ),
      ];
    }
  }

  Widget _buildTableView(List<dynamic> details) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          fontSize: 12,
        ),
        dataTextStyle: const TextStyle(
          fontSize: 11,
          color: Colors.black87,
        ),
        columnSpacing: 40,
        horizontalMargin: 40,
        columns: const [
          DataColumn(
            label: Text('No.'),
            numeric: true,
          ),
          DataColumn(
            label: Text('Tbl'),
            numeric: true,
          ),
          DataColumn(
            label: Text('Lbr'),
            numeric: true,
          ),
          DataColumn(
            label: Text('Pjg'),
            numeric: true,
          ),
          DataColumn(
            label: Text('Pcs'),
            numeric: true,
          ),
        ],
        rows: details.map<DataRow>((detail) {
          return DataRow(
            cells: [
              DataCell(
                Text(
                  detail.noUrut?.toString() ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              DataCell(
                Text(formatAngka(detail.tebal)),
              ),
              DataCell(
                Text(formatAngka(detail.lebar)),
              ),
              DataCell(
                Text(formatAngka(detail.panjang)),
              ),
              DataCell(
                Text(
                  detail.jmlhBatang?.toString() ?? '0',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String formatAngka(double? value) {
    if (value == null) return '-';

    // Jika angka adalah bilangan bulat (misal: 7.0), tampilkan tanpa desimal
    if (value == value.truncateToDouble()) {
      return value.toStringAsFixed(0);
    }

    // Jika bukan bilangan bulat, tampilkan 2 angka di belakang koma
    return value.toStringAsFixed(2);
  }

  // Helper method untuk format M3 - mempertahankan format asli dari JSON
  String _formatM3(String? m3Value) {
    if (m3Value == null || m3Value.isEmpty) return '0.0000';

    final double? value = double.tryParse(m3Value);
    if (value == null) return '0.0000';

    // Tambahkan thousand separator tanpa mengubah jumlah digit desimal
    // Pisahkan bagian integer dan desimal
    String valueStr = m3Value;
    if (valueStr.contains('.')) {
      List<String> parts = valueStr.split('.');
      String integerPart = parts[0];
      String decimalPart = parts[1];

      // Tambahkan thousand separator ke bagian integer
      String formattedInteger = integerPart.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match match) => '${match[1]},',
      );

      return '$formattedInteger.$decimalPart';
    } else {
      // Jika tidak ada desimal, tambahkan .0000
      return valueStr.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match match) => '${match[1]},',
      ) + '.0000';
    }
  }

  // Helper method untuk format angka dengan thousand separator
  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]},',
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButton<String>(
        value: _selectedFilter,
        hint: const Text('Filter Label'),
        isExpanded: true,
        onChanged: (value) {
          setState(() {
            _selectedFilter = value;
          });

          final viewModel = Provider.of<MappingLokasiViewModel>(context, listen: false);
          viewModel.fetchData(filterBy: _selectedFilter, idLokasi: _selectedLocation);
        },
        items: const [
          DropdownMenuItem<String>(value: null, child: Text('Semua')),
          DropdownMenuItem<String>(value: 'st', child: Text('ST')),
          DropdownMenuItem<String>(value: 's4s', child: Text('S4S')),
          DropdownMenuItem<String>(value: 'fj', child: Text('FJ')),
          DropdownMenuItem<String>(value: 'moulding', child: Text('MLD')),
          DropdownMenuItem<String>(value: 'laminating', child: Text('LMT')),
          DropdownMenuItem<String>(value: 'ccakhir', child: Text('CCA')),
          DropdownMenuItem<String>(value: 'sanding', child: Text('SND')),
          DropdownMenuItem<String>(value: 'bj', child: Text('BJ')),
        ],
        underline: const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildLocationDropdown() {
    return Consumer<LokasiViewModel>(
      builder: (context, lokasiVM, child) {
        final mappingVM = Provider.of<MappingLokasiViewModel>(context, listen: false);

        final suggestions = [
          SearchFieldListItem<String>('Semua'),
          ...lokasiVM.lokasiList.map(
                (lokasi) => SearchFieldListItem<String>(lokasi.idLokasi),
          ),
        ];

        return Container(
          width: 140,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SearchField<String>(
            controller: _locationController,
            hint: 'Lokasi',
            searchInputDecoration: SearchInputDecoration(border: InputBorder.none),
            suggestions: suggestions,
            onSuggestionTap: (selected) {
              setState(() {
                _selectedLocation = selected.searchKey;
                _locationController.text = selected.searchKey;
              });

              mappingVM.fetchData(
                filterBy: _selectedFilter,
                idLokasi: _selectedLocation == 'Semua' ? null : _selectedLocation,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCountText() {
    return Consumer<MappingLokasiViewModel>(
      builder: (context, viewModel, child) {
        return Text(
          '${viewModel.totalData} Label',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        );
      },
    );
  }

  void _showScanBarQRCode(BuildContext context) {
    if (_selectedLocation == null || _selectedLocation == 'Semua') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih lokasi terlebih dahulu.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeQrScanMappingScreen(
          selectedFilter: _selectedFilter ?? 'all',
          idLokasi: _selectedLocation!,
        ),
      ),
    );
  }
}