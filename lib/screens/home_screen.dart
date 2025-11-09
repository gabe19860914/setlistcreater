import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/setlist/setlist_model.dart';
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

  DateTime _selectedDate = DateTime.now();
  final List<Song> _songs = [];

  // --- 機能追加：ここから ---
  bool _isLandscape = false; // false: 縦向き, true: 横向き
  int _divisionCount = 1; // 分割数 (1, 2, 4)
  // --- 機能追加：ここまで ---

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
    if (_songTitleController.text.isNotEmpty) {
      setState(() {
        _songs.add(Song(
          title: _songTitleController.text,
        ));
        _songTitleController.clear();
      });
      FocusScope.of(context).requestFocus();
    }
  }

  // PDFプレビュー画面に遷移する関数
  void _navigateToExportScreen() {
    if (_formKey.currentState!.validate() && _songs.isNotEmpty) {
      final setlist = Setlist(
        title: _titleController.text,
        date: _selectedDate,
        venue: _venueController.text,
        songs: _songs,
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ExportScreen(
            setlist: setlist,
            // --- 機能追加：選択した設定を渡す ---
            isLandscape: _isLandscape,
            divisionCount: _divisionCount,
          ),
        ),
      );
    } else if (_songs.isEmpty) {
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
    _titleController.dispose();
    _venueController.dispose();
    _songTitleController.dispose();
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
            // ... (公演タイトル、会場、日付のコードは変更なし) ...
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                  labelText: '公演タイトル', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? '公演タイトルを入力してください。' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _venueController,
              decoration: const InputDecoration(
                  labelText: '会場', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? '会場を入力してください。' : null,
            ),
            const SizedBox(height: 16),
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
            // ... (曲追加、曲リストのコードは変更なし) ...
            Text('曲の追加', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextFormField(
              controller: _songTitleController,
              decoration: const InputDecoration(
                  labelText: '曲名', border: OutlineInputBorder()),
              onFieldSubmitted: (_) => _addSong(),
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
            Text('曲リスト (${_songs.length}曲)',
                style: Theme.of(context).textTheme.headlineSmall),
            _songs.isEmpty
                ? const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('まだ曲がありません。')))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _songs.length,
                    itemBuilder: (context, index) {
                      final song = _songs[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(song.title),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () => setState(() => _songs.removeAt(index)),
                        ),
                      );
                    },
                  ),

            // --- 機能追加：PDF設定UI ---
            const Divider(height: 32),
            Text('PDFレイアウト設定', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            // 用紙の向き選択
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(value: false, label: Text('縦向き')),
                ButtonSegment<bool>(value: true, label: Text('横向き')),
              ],
              selected: {_isLandscape},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _isLandscape = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            // 分割数選択
            DropdownButtonFormField<int>(
              value: _divisionCount,
              decoration: const InputDecoration(
                labelText: '分割数',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('1分割（分割なし）')),
                DropdownMenuItem(value: 2, child: Text('2分割')),
                DropdownMenuItem(value: 4, child: Text('4分割')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _divisionCount = value;
                  });
                }
              },
            ),
            // --- 機能追加：ここまで ---

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

