import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:searchfield/searchfield.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../../core/view_models/lokasi_view_model.dart';
import '../view_model/kd_bongkar_detail_view_model.dart';
import '../view_model/barcode_qr_scan_kd_bongkar_view_model.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../../core/widgets/dialog_error.dart';
import 'barcode_qr_scan_kd_bongkar_screen.dart';

class KDBongkarDetailScreen extends StatefulWidget {
  final String noProcKD;
  final String tgl;

  const KDBongkarDetailScreen({Key? key, required this.noProcKD, required this.tgl}) : super(key: key);

  @override
  State<KDBongkarDetailScreen> createState() => _KDBongkarDetailScreenState();
}

class _KDBongkarDetailScreenState extends State<KDBongkarDetailScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _locationController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  String? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lokasiVM = Provider.of<LokasiViewModel>(context, listen: false);
      final kdDetailVM = Provider.of<KDBongkarDetailViewModel>(context, listen: false);

      lokasiVM.fetchLokasi();
      kdDetailVM.fetchBefore(widget.noProcKD);
      kdDetailVM.fetchAfter(widget.noProcKD);
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kdDetailVM = Provider.of<KDBongkarDetailViewModel>(context);
    final lokasiVM = Provider.of<LokasiViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _buildSimpleAppBar(kdDetailVM),
      body: Column(
        children: [
          _buildSimpleFilter(lokasiVM),
          _buildSimpleStats(kdDetailVM),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSimpleList(kdDetailVM.beforeList, kdDetailVM.isLoading, "Semua label telah selesai di scan", isPending: true),
                _buildSimpleList(kdDetailVM.afterList, kdDetailVM.isLoading, "Belum ada label yang di scan", isPending: false),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildSpeedDial(),
    );
  }

  PreferredSizeWidget _buildSimpleAppBar(KDBongkarDetailViewModel kdDetailVM) {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF755330),
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.noProcKD,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          // Text(
          //   '${widget.tgl} • ${widget.noProcKD}',
          //   style: const TextStyle(
          //     fontSize: 13,
          //     color: Colors.white70,
          //     fontWeight: FontWeight.w400,
          //   ),
          // ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Container(
          color: const Color(0xFF755330),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            indicatorWeight: 2,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Before (${kdDetailVM.totalBefore})"),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("After (${kdDetailVM.totalAfter})"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleStats(KDBongkarDetailViewModel kdDetailVM) {
    final total = kdDetailVM.totalBefore + kdDetailVM.totalAfter;
    final progress = total > 0 ? (kdDetailVM.totalAfter / total) : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Progress Circle
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF755330)),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF755330),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          // Stats Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$total Total Label',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${kdDetailVM.totalBefore} Pending',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${kdDetailVM.totalAfter} Done',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleFilter(LokasiViewModel lokasiVM) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.location_on,
              color: Color(0xFF755330),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSimpleDropdown(lokasiVM),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleDropdown(LokasiViewModel lokasiVM) {
    final suggestions = [
      SearchFieldListItem<String>('Semua'),
      ...lokasiVM.lokasiList.map((lok) => SearchFieldListItem<String>(lok.idLokasi)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SearchField<String>(
        controller: _locationController,
        hint: 'Lokasi',
        searchInputDecoration: SearchInputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        suggestions: suggestions,
        onSuggestionTap: (selected) {
          setState(() {
            _selectedLocation = selected.searchKey;
            _locationController.text = selected.searchKey;
          });
        },
      ),
    );
  }

  Widget _buildSimpleList(List<dynamic> list, bool isLoading, String emptyMessage, {required bool isPending}) {
    if (isLoading) return const LoadingSkeleton();

    if (list.isEmpty) {
      return _buildEmptyState(emptyMessage, isPending);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return _buildSimpleItem(item, isPending, index);
      },
    );
  }

  Widget _buildSimpleItem(dynamic item, bool isPending, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status Indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isPending ? Colors.orange : Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.noST,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.idLokasi != '-' ? item.idLokasi : (isPending ? "Menunggu lokasi" : "Tidak ada lokasi"),
                        style: TextStyle(
                          fontSize: 13,
                          color: isPending && item.idLokasi == '-'
                              ? Colors.orange.shade600
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isPending ? Colors.orange.shade50 : Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isPending ? "PENDING" : "DONE",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isPending ? Colors.orange.shade700 : Colors.green.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, bool isPending) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isPending ? Colors.green.shade50 : Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPending ? Icons.check_circle : Icons.pending_actions,
              size: 40,
              color: isPending ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedDial() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      backgroundColor: const Color(0xFF755330),
      foregroundColor: Colors.white,
      visible: true,
      spaceBetweenChildren: 16,
      overlayOpacity: 0.4,
      elevation: 8,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.qr_code_scanner),
          label: 'Scan QR Code',
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF755330),
          onTap: () => _showScanBarQRCode(context),
        ),
      ],
    );
  }

  void _showScanBarQRCode(BuildContext context) {
    if (_selectedLocation == null || _selectedLocation!.toLowerCase().contains('semua')) {
      DialogError.show(
        context: context,
        title: 'Pilih Lokasi Terlebih Dahulu',
        message: 'Silakan pilih lokasi yang spesifik sebelum melakukan scan QR Code.',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => BarcodeQrScanKdBongkarViewModel(),
          child: BarcodeQrScanKdBongkarScreen(
            noProcKD: widget.noProcKD,
            selectedLocation: _selectedLocation!,
          ),
        ),
      ),
    );
  }
}