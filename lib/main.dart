import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wps_mobile/features/bongkar_kd/view/kd_bongkar_screen.dart';
import 'package:wps_mobile/features/bongkar_kd/view_model/kd_bongkar_detail_view_model.dart';
import 'features/login/view/login_screen.dart';
import 'features/stock_opname/view/stock_opname_list_screen.dart'; // Import DashboardScreen
import 'features/mapping/view/mapping_lokasi_screen.dart'; // Import DashboardScreen
import 'features/nyangkut/view/nyangkut_menu_screen.dart'; // Import DashboardScreen
import 'features/home/view/home_screen.dart';  // Pastikan path sesuai dengan file Anda
import 'features/stock_opname/view_model/stock_opname_list_view_model.dart'; // Import StockOpnameViewModel
import 'features/stock_opname/view_model/stock_opname_detail_view_model.dart'; // Import StockOpnameInputViewModel
import 'core/view_models/preview_label_view_model.dart'; // Import LabelViewModel
import 'core/view_models/pdf_view_model.dart'; // Import PDFViewModel yang diperlukan
import 'core/view_models/pdf_view_model_st.dart'; // Import PDFViewModel yang diperlukan
import 'features/home/view_model/user_profile_view_model.dart'; // Import UserProfileViewModel
import 'features/mapping/view_model/mapping_lokasi_view_model.dart'; // Import UserProfileViewModel
import 'features/nyangkut/view_model/nyangkut_list_view_model.dart'; // Import UserProfileViewModel
import 'features/nyangkut/view_model/nyangkut_detail_view_model.dart'; // Import UserProfileViewModel
import 'features/bongkar_kd/view_model/kd_bongkar_view_model.dart'; // Import UserProfileViewModel
import 'core/view_models/lokasi_view_model.dart'; // Import UserProfileViewModel
import 'package:flutter_dotenv/flutter_dotenv.dart';


Future<void> main() async {
  await dotenv.load(fileName: ".env");  // ✅ Aman & async-safe
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(  // Menggunakan MultiProvider untuk mengelola lebih dari satu provider
      providers: [
        ChangeNotifierProvider(create: (_) => StockOpnameViewModel()),
        ChangeNotifierProvider(create: (_) => StockOpnameInputViewModel()),
        ChangeNotifierProvider(create: (_) => PreviewLabelViewModel()),
        ChangeNotifierProvider(create: (_) => PDFViewModelS4S()),
        ChangeNotifierProvider(create: (_) => PDFViewModelST()),
        ChangeNotifierProvider(create: (_) => UserProfileViewModel()),
        ChangeNotifierProvider(create: (_) => MappingLokasiViewModel()),
        ChangeNotifierProvider(create: (_) => NyangkutListViewModel()),
        ChangeNotifierProvider(create: (_) => NyangkutDetailViewModel()),
        ChangeNotifierProvider(create: (_) => LokasiViewModel()),
        ChangeNotifierProvider(create: (_) => KDBongkarViewModel()),
        ChangeNotifierProvider(create: (_) => KDBongkarDetailViewModel()),
      ],
      child: MaterialApp(
        title: 'WPS Mobile',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/home': (context) => HomeScreen(),
          '/stockopname': (context) => StockOpnameListScreen(),
          '/mapping': (context) => MappingLokasiScreen(),
          '/nyangkut': (context) => NyangkutMenuScreen(),
          '/bongkarkd': (context) => KDBongkarScreen(),
        },
      ),
    );
  }
}
