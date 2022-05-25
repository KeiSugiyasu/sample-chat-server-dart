import 'package:sample_chart_app_server_dart_proj/utils/extensions.dart';
import 'package:test/test.dart';

void main() {
  group('String.toDateTime', () {
    test('format: 2022-05-24T17:09:03.888254', () {
      expect('2022-05-24T17:09:03.888254'.toDateTime(),
          equals(DateTime(2022, 5, 24, 17, 9, 3, 888, 254)));
    });
  });

  group('String.toDateTime', () {
    test('format: 2022-05-24 17:09:03', () {
      expect('2022-05-24 17:09:03'.toDateTime(),
          equals(DateTime(2022, 5, 24, 17, 9, 3, 0, 0)));
    });
  });
}
