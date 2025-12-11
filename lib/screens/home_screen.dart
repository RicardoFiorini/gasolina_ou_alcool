import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gasolina_ou_alcool/core/app_colors.dart';
import 'package:gasolina_ou_alcool/widgets/result_dialog.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _gasController = TextEditingController();
  final _ethanolController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Foco para gerenciar o teclado
  final FocusNode _gasFocus = FocusNode();
  final FocusNode _ethanolFocus = FocusNode();

  @override
  void dispose() {
    _gasController.dispose();
    _ethanolController.dispose();
    _gasFocus.dispose();
    _ethanolFocus.dispose();
    super.dispose();
  }

  void _calculate() {
    // Esconde o teclado
    FocusScope.of(context).unfocus();

    // Valida o formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Usamos 'intl' para garantir que o número seja lido corretamente,
    // independentemente de ser '1.99' ou '1,99'
    final format = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final double? gasPrice =
        format.parse(_gasController.text.replaceAll('R\$', '')).toDouble();
    final double? ethanolPrice =
        format.parse(_ethanolController.text.replaceAll('R\$', '')).toDouble();

    if (gasPrice == null || ethanolPrice == null || gasPrice <= 0) {
      // Este caso não deve acontecer devido ao validador, mas é uma boa prática
      return;
    }

    final double ratio = ethanolPrice / gasPrice;

    String title;
    String message;
    String imagePath;

    if (ratio <= 0.7) {
      title = "Compensa Álcool!";
      message =
          "O preço do álcool está ${ratio.toStringAsFixed(2)}% do preço da gasolina. Pode abastecer com álcool.";
      imagePath = "assets/images/ethanol.png";
    } else {
      title = "Compensa Gasolina!";
      message =
          "O preço do álcool está ${ratio.toStringAsFixed(2)}% do preço da gasolina. Melhor abastecer com gasolina.";
      imagePath = "assets/images/gas.png";
    }

    // Mostra o diálogo de resultado
    showDialog(
      context: context,
      barrierDismissible: false, // Impede de fechar clicando fora
      builder: (context) {
        return ResultDialog(
          title: title,
          message: message,
          imagePath: imagePath,
          onDismiss: _clearFields, // Limpa os campos ao fechar
        );
      },
    );
  }

  void _clearFields() {
    // Fecha o dialog primeiro (se estiver aberto)
    Navigator.of(context, rootNavigator: true).pop();

    _gasController.clear();
    _ethanolController.clear();

    // Volta o foco para o primeiro campo
    FocusScope.of(context).requestFocus(_gasFocus);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Combustível Ideal",
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Logo
                Image.asset(
                  "assets/images/logo.png",
                  height: 120,
                ),
                const SizedBox(height: 24),

                // 2. Título da Seção
                Text(
                  "Insira os preços por litro:",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Campo de Gasolina
                _buildPriceTextField(
                  controller: _gasController,
                  label: "Preço da Gasolina",
                  focusNode: _gasFocus,
                  nextFocusNode: _ethanolFocus,
                ),
                const SizedBox(height: 16),

                // 4. Campo de Álcool
                _buildPriceTextField(
                  controller: _ethanolController,
                  label: "Preço do Álcool (Etanol)",
                  focusNode: _ethanolFocus,
                  isLastField: true,
                ),
                const SizedBox(height: 32),

                // 5. Botão de Calcular
                ElevatedButton(
                  onPressed: _calculate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.textDark,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    "CALCULAR",
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget helper para criar os campos de texto padronizados
  Widget _buildPriceTextField({
    required TextEditingController controller,
    required String label,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
    bool isLastField = false,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      // Ação do botão "Enter" no teclado
      textInputAction:
          isLastField ? TextInputAction.done : TextInputAction.next,
      // Muda o foco ou submete o formulário
      onFieldSubmitted: (_) {
        if (nextFocusNode != null) {
          FocusScope.of(context).requestFocus(nextFocusNode);
        } else {
          _calculate();
        }
      },
      // Validação
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Por favor, insira um valor";
        }
        // Tenta parsear o valor
        final format = NumberFormat.simpleCurrency(locale: 'pt_BR');
        try {
          final number = format.parse(value.replaceAll('R\$', ''));
          if (number <= 0) {
            return "O valor deve ser maior que zero";
          }
        } catch (e) {
          return "Valor inválido. Ex: 5,49";
        }
        return null;
      },
      // Estilização
      style: GoogleFonts.lato(fontSize: 18, color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.lato(color: AppColors.textDark.withOpacity(0.7)),
        prefixText: "R\$ ", // Prefixo de moeda
        prefixStyle: GoogleFonts.lato(fontSize: 18, color: AppColors.textDark),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.border, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
    );
  }
}