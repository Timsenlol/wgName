import 'package:meta/meta.dart';

class Kuehlschrank {
  final String id;
  final String imagePath;
  final String imageUrl;
  final String wgid;
  final String datum;

  Kuehlschrank(
      {@required this.id,
      @required this.imagePath,
      @required this.imageUrl,
      @required this.wgid,
      @required this.datum});
}
