import 'package:flutter/material.dart';
import '../models/setlist_model.dart';
import 'export_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 各入力フォームのコントローラー
  final _titleController = TextEditingController();
  final _venueController = TextEditingController();
  final _songTitleController = TextEditingController();
  final _songArtistController = TextEditingController();

  // 追加された曲のリスト
  final List<Song> _songs = [];

  // 曲をリストに追加するメソッド
  void _addSong() {
    final title = _songTitleController.text;
    final artist = _songArtistController.text;

    if (title.isNotEmpty && artist.isNotEmpty) {
      setState(() {
        _songs.add(Song(title: title, artist: artist));
      });
      _songTitleController.clear();
      _songArtistController.clear();
      FocusScope.of(context).unfocus(); // キーボードを閉じる
    }
  }

  // 曲をリストから削除するメソッド
  void _removeSong(int index) {
    setState(() {
      _songs.removeAt(index);
    });
  }

  // PDF出力画面へ遷移するメソッド
  void _navigateToExportScreen() {
    if (_titleController.text.isEmpty ||
        _venueController.text.isEmpty ||
        _songs.isEmpty) {
      // 入力チェック
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('公演タイトル、会場名、曲を1曲以上入力してください')),
      );
      return;
    }

    final setlist = Setlist(
      title: _titleController.text,
      venue: _venueController.text,
      date: DateTime.now(), // 現在の日付を使用
      songs: _songs,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExportScreen(setlist: setlist),
      ),
    );
  }

  @override
  void dispose() {
    // コントローラーを破棄
    _titleController.dispose();
    _venueController.dispose();
    _songTitleController.dispose();
    _songArtistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setlist Creator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 公演情報 ---
            const Text('公演情報',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                  labelText: '公演タイトル', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _venueController,
              decoration: const InputDecoration(
                  labelText: '会場', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),

            // --- 曲の追加 ---
            const Text('曲の追加',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _songTitleController,
              decoration: const InputDecoration(
                  labelText: '曲名', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _songArtistController,
              decoration: const InputDecoration(
                  labelText: 'アーティスト', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('曲を追加'),
              onPressed: _addSong,
            ),
            const SizedBox(height: 24),

            // --- 曲リスト ---
            const Text('セットリスト',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _songs.isEmpty
                ? const Center(child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('まだ曲がありません'),
                ))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _songs.length,
                    itemBuilder: (context, index) {
                      final song = _songs[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(song.title),
                        subtitle: Text(song.artist),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeSong(index),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 32),

            // --- PDF出力ボタン ---
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: _navigateToExportScreen,
              child:
                  const Text('PDFを作成してプレビュー', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
