import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

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
    final String encodedItems = itemQrCodec.encode(items);

    return AlertDialog(
      title: const Text('Export scanned items'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Scan this QR code to import the list of scanned items on another device.'),
          const SizedBox(height: 32.0),
          BarcodeWidget(
            barcode: _qrCode,
            data: encodedItems,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              SharePlus.instance.share(ShareParams(
                title: 'Exported item list from "Inventur Helper"',
                uri: Uri.parse('app://dev.hornberger.inventur_helper/shared_items#$encodedItems'),
              ));
            },
            child: const Text('Share'),
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
