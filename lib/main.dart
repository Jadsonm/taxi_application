import 'package:flutter/material.dart';
import 'package:taxi_application/convert_coordinates.dart';
import 'package:taxi_application/home_screen.dart';
import 'package:taxi_application/order_traking_page.dart';
import 'package:taxi_application/search_google_places.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taxi Application',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const OrderTrakingPage(), // Rota inicial
        '/search': (context) => const SearchGooglePlaces(), // Rota para a tela de pesquisa
        // Adicione outras rotas conforme necessário
      },
    );
  }
}
