import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sqflite_study/data_base.dart';
import 'package:sqflite_study/word.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Shared preferences demo',
      home: MyHomePage(title: 'Список карточек'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Word> words = [];
  final nameFieldCntrl = TextEditingController();
  final valueFieldCntrl = TextEditingController();

  @override
  void dispose() {
    nameFieldCntrl.dispose();
    valueFieldCntrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    words.clear();
    final res = await DBprovider.db.getAllWords();
    setState(() {
      words =  res;
    });
  }

  Future<void> _updateWordValue(Word word) async {
    setState(() {
      DBprovider.db.updateWord(Word(id: word.id, name: word.name, value: valueFieldCntrl.text.toLowerCase()));
      nameFieldCntrl.clear();
      valueFieldCntrl.clear();
      _loadWords();
    });
  }

  Future<void> _addWord() async {
    final newId = await DBprovider.db.getNewId();

    setState(() {
      final word = Word(id: newId, name: nameFieldCntrl.text.toUpperCase(), value: valueFieldCntrl.text.toLowerCase());
      DBprovider.db.addWord(word);
      nameFieldCntrl.clear();
      valueFieldCntrl.clear();
      _loadWords();
    });
  }

  Future<void> _deleteData() async {
    setState(() {
      DBprovider.db.deleteAllWords();
      words.clear();
      nameFieldCntrl.clear();
      valueFieldCntrl.clear();
    });
  }

  Future<void> _deleteWord(id) async {
    await DBprovider.db.deleteWord(id);
    _loadWords();
  }

  Future<void> _showCardAlert({Word? word}) async {
    final title = word == null ? 'Создать карточку' : 'Изменить значение';
    final mainBtnName = word == null ? 'Создать' : 'Изменить' ;
    if(word != null) {
      nameFieldCntrl.text = word.name;
      valueFieldCntrl.text = word.value;
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameFieldCntrl,
                  readOnly: word != null,
                  decoration: const InputDecoration(label: Text('Название')),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: valueFieldCntrl,
                  decoration: const InputDecoration(label: Text('Значение')),
                ),
              ]
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(mainBtnName),
              onPressed: () {
                word == null ? _addWord() : _updateWordValue(word);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
                nameFieldCntrl.clear();
                valueFieldCntrl.clear();
              },
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  ElevatedButton(onPressed: _loadWords, child: const Text('Обновить')),
                  const SizedBox(width: 16,),
                  ElevatedButton(onPressed: _deleteData, child: const Text('Очистить')),
                ],
              ),
            ),
          ]),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (var w in words) 
              Dismissible(
                key: UniqueKey(),
                background: Container(color: Colors.red),
                onDismissed: (direction) {
                  _deleteWord(w.id);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Карточка ${w.name} удалена')));
                },
                child: Card(
                  child:
                  InkWell(
                    onLongPress: () {
                      _showCardAlert(word: w);
                    },
                    child: ListTile(
                      leading: const Icon(Icons.album),
                      title: Text(w.name),
                      subtitle: Text(w.value),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showCardAlert();
        },
      ),
    );
  }
}
