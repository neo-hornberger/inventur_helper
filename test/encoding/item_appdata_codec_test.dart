import 'package:flutter_test/flutter_test.dart';
import 'package:inventur_helper/encoding/item_appdata_codec.dart';
import 'package:inventur_helper/models/item.dart';

void main() {
  test('encodes and decodes correctly', () {
    const original = [
      Item('0001-123456', 'Item 1', 'Owner 1', {ItemStatus.available}),
      Item('0705-963842', 'Item 2', null, {ItemStatus.missing}),
    ];
    
    final encoded = itemAppdataCodec.encode(original);
    final decoded = itemAppdataCodec.decode(encoded);

    expect(decoded, hasLength(original.length));
    for (var i = 0; i < original.length; i++) {
      expect(decoded.elementAt(i).barcode, original[i].barcode);
      expect(decoded.elementAt(i).name, original[i].name);
      expect(decoded.elementAt(i).owner, original[i].owner);
      expect(decoded.elementAt(i).status, original[i].status);
    }
  });
}
