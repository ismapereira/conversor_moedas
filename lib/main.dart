import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Importa nossa tela

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conversor de Moedas',

      // Define o tema "minimalista" moderno
      theme: ThemeData(
        // Cor primária
        primarySwatch: Colors.teal,

        // Fundo do app
        scaffoldBackgroundColor: Colors.white,

        // Tema da AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // Fundo branco
          elevation: 0, // Sem sombra
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black87, // Título em cor escura
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),

        // Tema para os campos de input (TextField e Dropdowns)
        inputDecorationTheme: InputDecorationTheme(
          // Fundo preenchido
          filled: true,
          fillColor: Colors.grey.shade100,

          // Sem borda visível
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none, // Remove a borda
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            // Adiciona uma borda sutil da cor primária quando focado
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2.0),
          ),
        ),

        // Tema do Botão Principal
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal, // Cor de fundo
            foregroundColor: Colors.white, // Cor do texto
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),

      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
