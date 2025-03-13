import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/login_screen.dart';
import 'views/dashboard_screen.dart'; // Import DashboardScreen
import 'view_models/stock_opname_view_model.dart'; // Import StockOpnameViewModel
import 'view_models/stock_opname_input_view_model.dart'; // Import StockOpnameInputViewModel
import 'view_models/preview_label_view_model.dart'; // Import LabelViewModel


void main() {
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

      ],
      child: MaterialApp(
        title: 'Stock Opname App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/home': (context) => DashboardScreen(),
        },
      ),
    );
  }
}
