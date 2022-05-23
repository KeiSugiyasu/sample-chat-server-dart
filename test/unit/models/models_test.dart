import 'package:sample_chart_app_server_dart_proj/models/models.dart';
import 'package:test/test.dart';

class Hoge {
  int? a;
  Hoge(this.a);
}

void main() {
  test(
      'ChatItem.withUpdated should return new object that has same name and comment.',
      () {
    final original = ChatItem(
        name: "test",
        comment: "test comment",
        updated: DateTime.now().subtract(Duration(days: 1)));
    final newOne = original.withUpdated(updated: DateTime.now());
    expect(
        original.name == newOne.name &&
            original.comment == newOne.comment &&
            original.updated != newOne.updated,
        isTrue);
  });
}
