import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';

class InvalidBarcodeDialog extends StatelessWidget {
  final Code barcode;
  final void Function() onButtonPressed;

  const InvalidBarcodeDialog({
    super.key,
    required this.barcode,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Invalid barcode'),
      content: Wrap(children: [
        Text('The scanned barcode is not a valid ${Format.qrCode.name}, ${Format.code128.name} barcode or ${Format.dataMatrix.name}.'),
        const SizedBox(height: 15),
        Text(
          'The scanned barcode is of type "${barcode.format?.name}".',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        )
      ]),
      actions: [
        TextButton(
          onPressed: onButtonPressed,
          child: const Text('OK'),
        ),
      ],
    );
  }
}
