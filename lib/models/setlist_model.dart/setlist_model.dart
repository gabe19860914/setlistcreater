/// 1曲ごとの情報を保持するクラス
class Song {
  final String title;  // 曲名

  Song({required this.title});
}

/// セットリスト全体の情報を保持するクラス
class Setlist {
  final String title;      // 公演タイトル
  final DateTime date;     // 公演日
  final String venue;      // 会場
  final List<Song> songs;  // 曲のリスト

  Setlist({
    required this.title,
    required this.date,
    required this.venue,
    required this.songs,
  });
}