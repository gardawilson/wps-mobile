import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/login_screen.dart';
import 'views/no_stock_opname_list_screen.dart'; // Import DashboardScreen
import 'views/mapping_lokasi_screen.dart'; // Import DashboardScreen
import 'views/home_screen.dart';  // Pastikan path sesuai dengan file Anda
import 'view_models/stock_opname_view_model.dart'; // Import StockOpnameViewModel
import 'view_models/stock_opname_input_view_model.dart'; // Import StockOpnameInputViewModel
import 'view_models/preview_label_view_model.dart'; // Import LabelViewModel
import 'view_models/pdf_view_model.dart'; // Import PDFViewModel yang diperlukan
import 'view_models/pdf_view_model_st.dart'; // Import PDFViewModel yang diperlukan
import 'view_models/user_profile_view_model.dart'; // Import UserProfileViewModel
import 'view_models/mapping_lokasi_view_model.dart'; // Import UserProfileViewModel
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
        ChangeNotifierProvider(create: (_) => StockOpnameViewModel()),  // Memberikan StockOpnameViewModel ke seluruh aplikasi
        ChangeNotifierProvider(create: (_) => StockOpnameInputViewModel()),  // Menambahkan StockOpnameInputViewModel
        ChangeNotifierProvider(create: (_) => PreviewLabelViewModel()), // Menambahkan LabelViewModel
        ChangeNotifierProvider(create: (_) => PDFViewModelS4S()), // Menambahkan PDFViewModel yang diperlukan
        ChangeNotifierProvider(create: (_) => PDFViewModelST()), // Menambahkan PDFViewModel yang diperlukan
        ChangeNotifierProvider(create: (_) => UserProfileViewModel()), // Menambahkan UserProfileViewModel
        ChangeNotifierProvider(create: (_) => MappingLokasiViewModel()),

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
          '/dashboard': (context) => StockOpnameListScreen(),
          '/mapping': (context) => MappingLokasiScreen(),
        },
      ),
    );
  }
}
