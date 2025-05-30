import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

import '../encoding/item_qr_codec.dart';

final Barcode _qrCode = Barcode.qrCode(errorCorrectLevel: BarcodeQRCorrectionLevel.high);

class ExportItemlistDialog extends StatelessWidget {
  final Iterable<String> items;
  final void Function() onCancel;

  const ExportItemlistDialog({
    super.key,
    required this.items,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export scanned items'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Scan this QR code to import the list of scanned items on another device.'),
          const SizedBox(height: 32.0),
          BarcodeWidget(
            barcode: _qrCode,
            data: itemQrCodec.encode(items),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Close'),
        ),
      ],
    );
  }
}
