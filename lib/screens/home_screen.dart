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
  //final _songTitleController = TextEditingController();
  final TextEditingController _masterSongController = TextEditingController(); // マスターリスト登録用

  DateTime _selectedDate = DateTime.now();
  // マスターリストに曲を登録する関数
  void _addMasterSong() {
    if (_masterSongController.text.isNotEmpty) {
      setState(() {
        _masterSongs.add(_masterSongController.text);
        _masterSongController.clear();
      }); 
    }
  }
  // マスターリストからセットリストに追加する関数
  void _addSongFromMaster(String title) {
    setState(() {
      _songs.add(Song(
        number: _songs.length + 1,
        title: title,
      ));
      // セットリストに追加したことをユーザーに通知
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('「$title」をセットリストに追加しました')),
      );
    });
  }
  // セットリストから曲を削除する関数
  void _removeSong(Song songToRemove) {
    setState(() {
      // 1. 選択された曲をリストから削除
      _songs.removeWhere((song) => song.number == songToRemove.number);

      // 2. 残った曲の連番を振り直す（重要）
      for (int i = 0; i < _songs.length; i++) {
        // 新しいSongオブジェクトを作成し、連番 (number) のみ更新する
        _songs[i] = Song(
          number: i + 1,
          title: _songs[i].title,
          // 必要であれば他のプロパティも引き継ぐ
        );
      }
    });
  }
  final List<Song> _songs = [];
  final List<String> _masterSongs = []; // 登録された曲のマスターリスト 

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
    _songTitleController.dispose(); // 既存
    _masterSongController.dispose(); // ★追加
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Setlist Creator'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 既存：公演情報入力フォーム (変更なし)
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: '公演タイトル'),
                  validator: (value) => value!.isEmpty ? 'タイトルを入力してください' : null,
                ),
                TextFormField(
                  controller: _venueController,
                  decoration: const InputDecoration(labelText: '会場'),
                  validator: (value) => value!.isEmpty ? '会場を入力してください' : null,
                ),
                ListTile(
                  title: Text("公演日: ${DateFormat('yyyy年MM月dd日').format(_selectedDate)}"),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context),
                ),
                const Divider(),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          const Text('曲の登録・選択', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),

          // 1. 曲の新規登録エリア (マスターリストへの追加)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _masterSongController,
                  decoration: const InputDecoration(
                    labelText: '新しい曲名を入力',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _addMasterSong(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addMasterSong,
                child: const Text('登録'),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Text('登録済み曲リスト:', style: TextStyle(fontWeight: FontWeight.w600)),

          // 2. マスターリストとセットリストへの追加ボタン
          SizedBox(
            height: 150, // スクロールできるように高さを指定
            child: ListView.builder(
              itemCount: _masterSongs.length,
              itemBuilder: (context, index) {
                final title = _masterSongs[index];
                return ListTile(
                  title: Text(title),
                  trailing: TextButton(
                    onPressed: () => _addSongFromMaster(title),
                    child: const Text('セットリストに追加 ➡️'),
                  ),
                );
              },
            ),
          ),
          
          const Divider(height: 32),
          
          // ★★★ PDF設定UIの完成形をここに挿入 ★★★
          const Text('PDFレイアウト設定', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          
          // 縦横設定 (isLandscape)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ページの向き:', style: TextStyle(fontWeight: FontWeight.w600)),
              ToggleButtons(
                isSelected: <bool>[!_isLandscape, _isLandscape], // false=縦, true=横
                onPressed: (int index) {
                  setState(() {
                    _isLandscape = index == 1;
                  });
                },
                children: const [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('縦向き')),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('横向き')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 分割数設定 (divisionCount)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('分割数:', style: TextStyle(fontWeight: FontWeight.w600)),
              DropdownButton<int>(
                value: _divisionCount,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('1分割 (分割なし)')),
                  DropdownMenuItem(value: 2, child: Text('2分割')),
                  DropdownMenuItem(value: 4, child: Text('4分割')),
                ],
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _divisionCount = newValue;
                    });
                  }
                },
              ),
            ],
          ),
          const Divider(height: 32), 
          // ★★★ PDF設定UIの終了 ★★★

          const Text('現在のセットリスト', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          
          // 3. 既存のセットリスト表示エリア (ListView.builder)
          Expanded(
            child: ListView.builder(
              itemCount: _songs.length,
              itemBuilder: (context, index) {
                final song = _songs[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(song.number.toString())),
                  title: Text(song.title),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeSong(song),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _navigateToExportScreen,
      label: const Text('PDFを作成してプレビュー'),
      icon: const Icon(Icons.picture_as_pdf),
    ),
  );
}