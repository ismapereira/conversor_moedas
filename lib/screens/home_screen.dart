import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Importamos nosso serviço de API

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Instância do nosso serviço
  final ApiService _apiService = ApiService();

  // Controla o campo de texto do valor
  final TextEditingController _amountController = TextEditingController();

  // Variáveis de estado
  Future<Map<String, String>>? _currenciesFuture;
  String _fromCurrency = 'USD'; // Moeda padrão "De"
  String _toCurrency = 'BRL'; // Moeda padrão "Para"
  String _resultMessage = ''; // Mensagem com o resultado
  bool _isConverting = false; // Feedback de carregamento no botão

  @override
  void initState() {
    super.initState();
    // Ao iniciar a tela, carregamos a lista de moedas
    _loadCurrencies();
  }

  // Método para carregar as moedas da API
  void _loadCurrencies() {
    _currenciesFuture = _apiService.getCurrencies();
    setState(() {}); // Atualiza a tela para o FutureBuilder
  }

  // Método para realizar a conversão
  Future<void> _convert() async {
    if (_amountController.text.isEmpty) return;

    setState(() {
      _isConverting = true;
      _resultMessage = '';
    });

    try {
      // Pegamos o valor, garantindo que o formato decimal seja com '.'
      double amount = double.parse(_amountController.text.replaceAll(',', '.'));

      // Chamamos a API
      double convertedAmount = await _apiService.convert(
        _fromCurrency,
        _toCurrency,
        amount,
      );

      // Formatamos a saída para 2 casas decimais
      String fromAmountFormatted = amount.toStringAsFixed(2);
      String toAmountFormatted = convertedAmount.toStringAsFixed(2);

      // Atualizamos a mensagem de resultado
      setState(() {
        _resultMessage =
            '$fromAmountFormatted $_fromCurrency = $toAmountFormatted $_toCurrency';
      });
    } catch (e) {
      // Em caso de erro
      setState(() {
        _resultMessage = 'Erro: ${e.toString()}';
      });
    } finally {
      // Independente de sucesso ou falha, paramos o loading
      setState(() {
        _isConverting = false;
      });
    }
  }

  // Método para inverter as moedas selecionadas
  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      // Após inverter, realizamos a conversão automaticamente
      if (_amountController.text.isNotEmpty) {
        _convert();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversor Minimalista'),
        backgroundColor: Colors.white, // Fundo branco
        elevation: 0, // Sem sombra, para um look "flat"
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black87, // Título em cor escura
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // O FutureBuilder "constrói" a tela baseado no estado da nossa API
        child: FutureBuilder<Map<String, String>>(
          future: _currenciesFuture,
          builder: (context, snapshot) {
            // 1. Estado de Carregamento
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            // 2. Estado de Erro
            if (snapshot.hasError) {
              return Center(
                child: Text('Erro ao carregar moedas. Tente novamente.'),
              );
            }

            // 3. Estado de Sucesso (Dados Prontos)
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Nenhuma moeda encontrada.'));
            }

            // Se chegamos aqui, os dados (moedas) estão prontos
            final currencies = snapshot.data!;
            List<String> currencyKeys = currencies.keys.toList()..sort();

            // Garantir que os valores padrão estejam na lista
            if (!currencyKeys.contains(_fromCurrency)) {
              _fromCurrency = currencyKeys.first;
            }
            if (!currencyKeys.contains(_toCurrency)) {
              _toCurrency = currencyKeys.first;
            }

            // Interface principal
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20),

                  // 1. Campo de Valor
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Valor a converter',
                      prefixIcon: Icon(Icons.attach_money_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // 2. Dropdowns de Seleção
                  Row(
                    children: [
                      // "De"
                      Expanded(
                        child: _buildCurrencyDropdown(
                          'De',
                          _fromCurrency,
                          (val) {
                            setState(() {
                              _fromCurrency = val!;
                            });
                          },
                          currencyKeys,
                          currencies,
                        ),
                      ),

                      // Botão de Inverter
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: IconButton(
                          icon: Icon(
                            Icons.swap_horiz,
                            color: Theme.of(context).primaryColor,
                            size: 30,
                          ),
                          onPressed: _swapCurrencies,
                        ),
                      ),

                      // "Para"
                      Expanded(
                        child: _buildCurrencyDropdown(
                          'Para',
                          _toCurrency,
                          (val) {
                            setState(() {
                              _toCurrency = val!;
                            });
                          },
                          currencyKeys,
                          currencies,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),

                  // 3. Botão de Converter
                  ElevatedButton(
                    onPressed: _isConverting ? null : _convert,
                    child: _isConverting
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                        : Text('Converter'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),

                  // 4. Área de Resultado
                  if (_resultMessage.isNotEmpty)
                    Center(
                      child: Text(
                        _resultMessage,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget auxiliar para criar os Dropdowns
  Widget _buildCurrencyDropdown(
    String label,
    String selectedValue,
    ValueChanged<String?> onChanged,
    List<String> keys,
    Map<String, String> nameMap,
  ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
      value: selectedValue,
      isExpanded: true,
      items: keys.map((String key) {
        return DropdownMenuItem<String>(
          value: key,
          // Mostra a sigla e o nome da moeda (ex: BRL - Brazilian Real)
          child: Text(
            '$key - ${nameMap[key]}',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
