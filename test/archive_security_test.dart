import 'dart:io';
import 'dart:convert';
import 'package:archive/archive_io.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('extracts a normal ZIP entry inside the destination', () {
    final root = Directory.systemTemp.createTempSync('archive-security-');
    try {
      final payload = utf8.encode('local fixture');
      final archive = Archive()..addFile(ArchiveFile('inside.txt', payload.length, payload));
      final zip = ZipEncoder().encode(archive)!;
      extractArchiveToDisk(ZipDecoder().decodeBytes(zip), root.path);
      expect(File('${root.path}/inside.txt').readAsStringSync(), 'local fixture');
    } finally { root.deleteSync(recursive: true); }
  });
  test('does not extract a traversal entry outside the destination', () {
    final root = Directory.systemTemp.createTempSync('archive-security-');
    final destination = Directory('${root.path}/output')..createSync();
    try {
      final payload = utf8.encode('must stay contained');
      final archive = Archive()..addFile(ArchiveFile('../escaped.txt', payload.length, payload));
      final zip = ZipEncoder().encode(archive)!;
      try { extractArchiveToDisk(ZipDecoder().decodeBytes(zip), destination.path); } catch (_) { /* Rejecting an unsafe entry is valid. */ }
      expect(File('${root.path}/escaped.txt').existsSync(), isFalse);
    } finally { root.deleteSync(recursive: true); }
  });
}
