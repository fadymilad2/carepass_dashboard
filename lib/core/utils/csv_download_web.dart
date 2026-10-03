import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

void downloadCsv(String csv, {String filename = 'carepass-receipts.csv'}) {
  final blob = web.Blob(
    [csv.toJS].toJS,
    web.BlobPropertyBag(type: 'text/csv;charset=utf-8'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename;
  try {
    web.document.body?.appendChild(anchor);
    anchor.click();
  } finally {
    anchor.remove();
    // Give the browser time to begin reading the download before releasing it.
    Timer(const Duration(seconds: 1), () => web.URL.revokeObjectURL(url));
  }
}
