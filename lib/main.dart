import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Importa nossa tela

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conversor de Moedas',
      // Define o tema "minimalista"
      theme: ThemeData(
        // Usaremos um tom de cinza-azulado (moderno)
        primarySwatch: Colors.blueGrey,
        // Fundo do app será branco
        scaffoldBackgroundColor: Colors.white,

        // Tema para os campos de input
        inputDecorationTheme: InputDecorationTheme(
          // Bordas arredondadas por padrão
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          // Borda quando o campo está focado
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: Colors.blueGrey.shade700, // Cor primária mais escura
              width: 2.0,
            ),
          ),
        ),
      ),
      // Nossa tela principal
      home: HomeScreen(),
      // Remove o banner "DEBUG"
      debugShowCheckedModeBanner: false,
    );
  }
}
