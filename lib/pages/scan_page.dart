import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';

import '../dialogs/invalid_barcode_dialog.dart';
import '../dialogs/check_item_dialog.dart';
import '../item_util.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<StatefulWidget> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool _processing = false;

  void _onBarcodeScanned(Code barcode) {
    if (_processing) {
      return;
    }

    _processing = true;

    if (barcode.format != Format.qrCode &&
        barcode.format != Format.code128 &&
        barcode.format != Format.dataMatrix) {
      showDialog(
        context: context,
        builder: (context) => InvalidBarcodeDialog(
          barcode: barcode,
          onButtonPressed: () => Navigator.pop(context),
        ),
      ).then((_) => _processing = false);
      return;
    }

    final Set<String> items = barcodeToItems(barcode);

    showDialog(
      context: context,
      builder: (context) => CheckItemDialog(
        items: items,
        onCancel: () => Navigator.pop(context),
        onAdd: () => Navigator.pop(context, true),
      ),
    ).then((addItem) {
      if (addItem == null || !addItem) {
        _processing = false;
        return;
      }

      Navigator.pop(
        context,
        items,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _processing = false;
  }

  @override
  Widget build(BuildContext context) {
    const double scannerCropPercent = .7;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan'),
      ),
      body: Center(
        child: ReaderWidget(
          tryHarder: true,
          tryInverted: true,
          tryRotate: true,
          tryDownscale: true,
          showGallery: false,
          cropPercent: scannerCropPercent,
          scannerOverlay: const ScannerOverlayBorder(
            cutOutSize: scannerCropPercent,
            verticalOffset: 0.2,
            borderColor: Colors.white,
            borderWidth: 5,
            borderRadius: 10,
            borderLength: 25,
          ),
          onScan: _onBarcodeScanned,
        ),
      ),
    );
  }
}
