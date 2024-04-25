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
      home: MyHomePage(title: 'List Storage'),
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
  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords () async {
    final res = await DBprovider.db.getAllWords();
    setState(() {
      words =  res;
    });
  }

  Future<void> _addWord() async {
    final newId = await DBprovider.db.getNewId();

    setState(() {
      final word = Word(id: newId, name: myController.text.toUpperCase(), value: myController.text.toLowerCase());
      DBprovider.db.addWord(word);
      myController.clear();
      _loadWords();
    });
  }

  Future<void> _deleteData() async {
    setState(() {
      DBprovider.db.deleteAllWords();
      words.clear();
      myController.clear();
    });
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
            TextField(
              controller: myController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter the string',
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  ElevatedButton(
                      onPressed: _addWord, child: const Text('add')),
                  const SizedBox(
                    width: 16,
                  ),
                  ElevatedButton(
                      onPressed: _deleteData, child: const Text('clear all')),
                ],
              ),
            ),
          ]),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (var w in words) Text('${w.id}; ${w.name}; ${w.value}'),
            ],
          ),
        ),
      ]),
    );
  }
}
