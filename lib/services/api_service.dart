import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // A URL base da API
  final String _baseUrl = "https://api.frankfurter.app";

  // Busca todas as moedas disponíveis (ex: 'USD', 'BRL')
  Future<Map<String, String>> getCurrencies() async {
    final response = await http.get(Uri.parse('$_baseUrl/currencies'));

    if (response.statusCode == 200) {
      // Converte o JSON de resposta em um Map<String, String>
      return Map<String, String>.from(json.decode(response.body));
    } else {
      // Se falhar, lança uma exceção
      throw Exception('Falha ao carregar moedas');
    }
  }

  // Converte um valor de uma moeda para outra
  Future<double> convert(String from, String to, double amount) async {
    // Se as moedas forem iguais, não há o que converter
    if (from == to) return amount;

    final response = await http.get(
      Uri.parse('$_baseUrl/latest?amount=$amount&from=$from&to=$to'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Retorna o valor convertido que está em 'rates'
      return data['rates'][to];
    } else {
      throw Exception('Falha ao converter moeda');
    }
  }
}
