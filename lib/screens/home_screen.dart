import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/setlist_model.dart';
import 'export_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // フォームの入力を管理するためのキー
  final _formKey = GlobalKey<FormState>();

  // 各テキストフィールドの入力を管理するコントローラー
  final _titleController = TextEditingController();
  final _venueController = TextEditingController();
  final _songTitleController = TextEditingController();
  final _songArtistController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  final List<Song> _songs = [];

  // 日付選択ピッカーを表示する関数
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // 曲をリストに追加する関数
  void _addSong() {
    if (_songTitleController.text.isNotEmpty &&
        _songArtistController.text.isNotEmpty) {
      setState(() {
        _songs.add(Song(
          title: _songTitleController.text,
          artist: _songArtistController.text,
        ));
        _songTitleController.clear();
        _songArtistController.clear();
      });
      // フォーカスを曲名入力フィールドに戻す
      FocusScope.of(context).previousFocus();
    }
  }

  // PDFプレビュー画面に遷移する関数
  void _navigateToExportScreen() {
    // バリデーションを実行
    if (_formKey.currentState!.validate() && _songs.isNotEmpty) {
      final setlist = Setlist(
        title: _titleController.text,
        date: _selectedDate,
        venue: _venueController.text,
        songs: _songs,
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ExportScreen(setlist: setlist),
        ),
      );
    } else if (_songs.isEmpty) {
      // 曲が追加されていない場合にスナックバーで通知
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('曲を1曲以上追加してください。'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // 公演タイトル入力
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '公演タイトル',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '公演タイトルを入力してください。';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // 会場入力
            TextFormField(
              controller: _venueController,
              decoration: const InputDecoration(
                labelText: '会場',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '会場を入力してください。';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // 日付選択
            Row(
              children: [
                Expanded(
                  child: Text(
                    '公演日: ${DateFormat('yyyy年MM月dd日').format(_selectedDate)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('日付を選択'),
                ),
              ],
            ),
            const Divider(height: 32),
            // 曲追加セクション
            Text('曲の追加', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextFormField(
              controller: _songTitleController,
              decoration: const InputDecoration(
                labelText: '曲名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _songArtistController,
              decoration: const InputDecoration(
                labelText: 'アーティスト名',
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (_) => _addSong(), // Enterキーで曲を追加
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _addSong,
                icon: const Icon(Icons.add),
                label: const Text('曲を追加'),
              ),
            ),
            const Divider(height: 32),
            // 曲リスト表示
            Text('曲リスト (${_songs.length}曲)',
                style: Theme.of(context).textTheme.headlineSmall),
            _songs.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: Text('まだ曲がありません。')),
                  )
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
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _songs.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 32),
            // PDF作成ボタン
            ElevatedButton(
              onPressed: _navigateToExportScreen,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: Theme.of(context).textTheme.titleLarge,
              ),
              child: const Text('PDFを作成してプレビュー'),
            ),
          ],
        ),
      ),
    );
  }
}