import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Importamos nosso serviço de API

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Instância do nosso serviço
  final ApiService _apiService = ApiService();

  // Controla o campo de texto do valor
  final TextEditingController _amountController = TextEditingController();

  // Variáveis de estado
  Future<Map<String, String>>? _currenciesFuture;
  String _fromCurrency = 'USD';
  String _toCurrency = 'BRL';
  bool _isConverting = false;

  // NOVAS VARIÁVEIS DE ESTADO PARA O DESIGN DO RESULTADO
  String _errorMessage = ''; // Apenas para erros
  String _fromAmountStr = ''; // "100.00 USD"
  String _toAmountStr = ''; // "512.34 BRL"
  bool _showResultCard = false; // Controla a animação

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  void _loadCurrencies() {
    _currenciesFuture = _apiService.getCurrencies();
    setState(() {});
  }

  // MÉTODO _convert ATUALIZADO
  Future<void> _convert() async {
    if (_amountController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, insira um valor';
        _showResultCard = false;
      });
      return;
    }

    setState(() {
      _isConverting = true;
      _errorMessage = '';
      _showResultCard = false; // Esconde o card antigo antes de converter
    });

    try {
      double amount = double.parse(_amountController.text.replaceAll(',', '.'));

      double convertedAmount = await _apiService.convert(
        _fromCurrency,
        _toCurrency,
        amount,
      );

      // Atualiza as novas variáveis de estado
      setState(() {
        _fromAmountStr = '${amount.toStringAsFixed(2)} $_fromCurrency';
        _toAmountStr = '${convertedAmount.toStringAsFixed(2)} $_toCurrency';
        _showResultCard = true; // Mostra o card com animação
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro: Verifique sua conexão.';
        _showResultCard = false;
      });
    } finally {
      setState(() {
        _isConverting = false;
      });
    }
  }

  // MÉTODO _swapCurrencies ATUALIZADO
  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;

      // Limpa o resultado anterior ao inverter
      _showResultCard = false;
      _errorMessage = '';

      if (_amountController.text.isNotEmpty) {
        _convert();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conversor de Moedas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, String>>(
          future: _currenciesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('Erro ao carregar moedas. Tente novamente.'),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Nenhuma moeda encontrada.'));
            }

            final currencies = snapshot.data!;
            List<String> currencyKeys = currencies.keys.toList()..sort();

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
                  const SizedBox(height: 20),

                  // 1. Campo de Valor
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      // Usar hintText é mais minimalista que labelText
                      hintText: 'Digite o valor',
                      prefixIcon: Icon(
                        Icons.monetization_on_outlined,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Dropdowns de Seleção
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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

                      // Botão de Inverter ATUALIZADO
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 8.0,
                        ),
                        // Damos um fundo circular ao botão
                        child: Material(
                          color: Colors.grey.shade200,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: IconButton(
                            icon: Icon(
                              Icons.swap_horiz,
                              color: Theme.of(context).primaryColor,
                              size: 28,
                            ),
                            onPressed: _swapCurrencies,
                          ),
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
                  const SizedBox(height: 32),

                  // 3. Botão de Converter
                  ElevatedButton(
                    onPressed: _isConverting ? null : _convert,
                    child: _isConverting
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                        : const Text('Converter'),
                  ),
                  const SizedBox(height: 32),

                  // 4. NOVA ÁREA DE RESULTADO
                  // Animação de Fade-in
                  AnimatedOpacity(
                    opacity: _showResultCard ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: _buildResultCard(),
                  ),

                  // Exibição de Erro
                  if (_errorMessage.isNotEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
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

  // NOVO WIDGET: Card de Resultado
  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "De" (Valor original)
          Text(
            _fromAmountStr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),

          // Ícone de igualdade
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Icon(
              Icons.arrow_downward_rounded,
              color: Colors.black54,
              size: 20,
            ),
          ),

          // "Para" (Valor convertido) - O HERÓI
          Text(
            _toAmountStr,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar dos Dropdowns (O MESMO DE ANTES)
  Widget _buildCurrencyDropdown(
    String label,
    String selectedValue,
    ValueChanged<String?> onChanged,
    List<String> keys,
    Map<String, String> nameMap,
  ) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 8.0,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          isDense: true,
          items: keys.map((String key) {
            return DropdownMenuItem<String>(
              value: key,
              child: Text(
                '$key - ${nameMap[key]}',
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
