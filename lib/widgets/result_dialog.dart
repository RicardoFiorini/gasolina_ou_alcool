import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gasolina_ou_alcool/core/app_colors.dart';

class ResultDialog extends StatelessWidget {
  final String title;
  final String message;
  final String imagePath;
  final String buttonText;
  final VoidCallback onDismiss;

  // ESTA É A CORREÇÃO:
  // Removi o "const" daqui, pois "onDismiss" é uma função
  // e não pode ser parte de um construtor constante.
  ResultDialog({
    super.key,
    required this.title,
    required this.message,
    required this.imagePath,
    required this.onDismiss,
    this.buttonText = "Calcular Novamente",
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
          fontSize: 22,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              imagePath,
              height: 100,
              width: 100,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 18,
                color: AppColors.textDark.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: onDismiss,
          child: Text(
            buttonText,
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}