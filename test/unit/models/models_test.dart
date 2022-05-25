import 'package:sample_chart_app_server_dart_proj/models/models.dart';
import 'package:test/test.dart';

void main() {
  test(
      'ChatItem.withUpdated should return new object that retains the name and the comment, and has the passed updated time value.',
      () {
    final original = ChatItem(
        name: "test",
        comment: "test comment",
        updated: DateTime.now().subtract(Duration(days: 1)));
    final updated = DateTime.now();
    final newOne = original.withUpdated(updated: updated);
    expect(
        original.name == newOne.name &&
            original.comment == newOne.comment &&
            newOne.updated == updated,
        isTrue);
  });
}
