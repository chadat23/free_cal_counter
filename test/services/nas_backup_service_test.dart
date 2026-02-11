import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/services/nas_backup_service.dart';

void main() {
  group('parsePropfindResponse', () {
    test('parses valid PROPFIND XML with backup files', () {
      const xml = '''<?xml version="1.0" encoding="utf-8"?>
<d:multistatus xmlns:d="DAV:">
  <d:response>
    <d:href>/backups/meal_of_record/</d:href>
    <d:propstat>
      <d:prop>
        <d:displayname>meal_of_record</d:displayname>
      </d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
    </d:propstat>
  </d:response>
  <d:response>
    <d:href>/backups/meal_of_record/meal_of_record_2025-01-15T10:30:00.000.zip</d:href>
    <d:propstat>
      <d:prop>
        <d:getcontentlength>102400</d:getcontentlength>
        <d:getlastmodified>Wed, 15 Jan 2025 10:30:00 GMT</d:getlastmodified>
        <d:displayname>meal_of_record_2025-01-15T10:30:00.000.zip</d:displayname>
      </d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
    </d:propstat>
  </d:response>
  <d:response>
    <d:href>/backups/meal_of_record/meal_of_record_2025-01-14T08:00:00.000.zip</d:href>
    <d:propstat>
      <d:prop>
        <d:getcontentlength>98304</d:getcontentlength>
        <d:getlastmodified>Tue, 14 Jan 2025 08:00:00 GMT</d:getlastmodified>
        <d:displayname>meal_of_record_2025-01-14T08:00:00.000.zip</d:displayname>
      </d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
    </d:propstat>
  </d:response>
</d:multistatus>''';

      final service = NasBackupService.instance;
      final backups = service.parsePropfindResponse(xml);

      expect(backups.length, 2);

      // Should be sorted newest first
      expect(backups[0].name, 'meal_of_record_2025-01-15T10:30:00.000.zip');
      expect(backups[0].size, 102400);
      expect(backups[0].modified, isNotNull);
      expect(backups[0].modified!.day, 15);

      expect(backups[1].name, 'meal_of_record_2025-01-14T08:00:00.000.zip');
      expect(backups[1].size, 98304);
    });

    test('filters out non-backup files', () {
      const xml = '''<?xml version="1.0" encoding="utf-8"?>
<d:multistatus xmlns:d="DAV:">
  <d:response>
    <d:href>/backups/meal_of_record/</d:href>
    <d:propstat>
      <d:prop><d:displayname>meal_of_record</d:displayname></d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
    </d:propstat>
  </d:response>
  <d:response>
    <d:href>/backups/meal_of_record/meal_of_record_2025-01-15T10:30:00.000.zip</d:href>
    <d:propstat>
      <d:prop>
        <d:getcontentlength>102400</d:getcontentlength>
        <d:getlastmodified>Wed, 15 Jan 2025 10:30:00 GMT</d:getlastmodified>
      </d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
    </d:propstat>
  </d:response>
  <d:response>
    <d:href>/backups/meal_of_record/random_file.txt</d:href>
    <d:propstat>
      <d:prop>
        <d:getcontentlength>500</d:getcontentlength>
        <d:getlastmodified>Mon, 13 Jan 2025 12:00:00 GMT</d:getlastmodified>
      </d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
    </d:propstat>
  </d:response>
</d:multistatus>''';

      final service = NasBackupService.instance;
      final backups = service.parsePropfindResponse(xml);

      expect(backups.length, 1);
      expect(backups[0].name, 'meal_of_record_2025-01-15T10:30:00.000.zip');
    });

    test('returns empty list for empty multistatus', () {
      const xml = '''<?xml version="1.0" encoding="utf-8"?>
<d:multistatus xmlns:d="DAV:">
</d:multistatus>''';

      final service = NasBackupService.instance;
      final backups = service.parsePropfindResponse(xml);

      expect(backups, isEmpty);
    });

    test('handles missing size and modified fields', () {
      const xml = '''<?xml version="1.0" encoding="utf-8"?>
<d:multistatus xmlns:d="DAV:">
  <d:response>
    <d:href>/backups/meal_of_record/meal_of_record_2025-01-15T10:30:00.000.zip</d:href>
    <d:propstat>
      <d:prop>
        <d:displayname>meal_of_record_2025-01-15T10:30:00.000.zip</d:displayname>
      </d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
    </d:propstat>
  </d:response>
</d:multistatus>''';

      final service = NasBackupService.instance;
      final backups = service.parsePropfindResponse(xml);

      expect(backups.length, 1);
      expect(backups[0].size, isNull);
      expect(backups[0].modified, isNull);
    });
  });
}
