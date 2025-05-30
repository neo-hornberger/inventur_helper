import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';

import './encoding/item_qr_codec.dart';
import './models/item.dart';
import './preferences.dart';

Item lookupItem(String barcode) {
  final inv = Preferences().inventory;

  if (inv == null) {
    return Item(barcode, null, null);
  }

  return inv.items.firstWhere((item) => item.barcode == barcode, orElse: () => Item(barcode, null, null));
}

Set<String> barcodeToItems(Code barcode) {
  if (barcode.format == Format.code128) {
    return {_code128ToItem(barcode)};
  } else if (barcode.format == Format.qrCode) {
    return _qrCodeToItems(barcode);
  } else {
    throw Exception('Invalid barcode format: ${barcode.format?.name}');
  }
}

String _code128ToItem(Code barcode) {
  assert(barcode.format == Format.code128, 'Invalid barcode format: ${barcode.format?.name}');
  return barcode.text!;
}

Set<String> _qrCodeToItems(Code barcode) {
  assert(barcode.format == Format.qrCode, 'Invalid barcode format: ${barcode.format?.name}');
  return itemQrCodec.decode(barcode.text!).toSet();
}

ListTile itemWidget(
  Item item, {
  void Function()? onTap,
  void Function()? onLongPress,
}) {
  final subtitle = [
    if (item.owner != null) Text(item.owner!, style: const TextStyle(fontWeight: FontWeight.bold)),
    if (item.name != null) Text(item.name!),
  ];

  return ListTile(
    title: Text(item.barcode),
    subtitle: subtitle.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: subtitle,
          )
        : null,
    onTap: onTap,
    onLongPress: onLongPress,
  );
}
