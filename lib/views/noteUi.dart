import 'package:flutter/material.dart';
import 'package:flutter_application_4/controllers/hive.dart';
import 'package:flutter_application_4/controllers/sqlite.dart';
import 'package:flutter_application_4/models/note.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

enum StorageType { hive, sqlite }

class _NotesScreenState extends State<NotesScreen> {
  final SqliteController sqliteController = SqliteController();
  final HiveController hiveController = HiveController();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Note> _notes = [];
  StorageType selectedStorage = StorageType.hive;

  void _initHive() async {
    hiveController.init();
  }

  void _loadNotes() async {
    if (selectedStorage == StorageType.sqlite) {
      final notes = await sqliteController.getNotes();
      setState(() => _notes = notes);
    } else {
      final notes = await hiveController.getNotes();
      setState(() => _notes = notes);
    }
  }

  void _addNote() async {
    final note = Note(
      title: _titleController.text,
      description: _descriptionController.text,
    );
    if (selectedStorage == StorageType.sqlite) {
      await sqliteController.insert(note);
    } else {
      hiveController.add(note);
    }
    _titleController.clear();
    _descriptionController.clear();
    _loadNotes();
  }

  void deleteNote(int? id) async {
    if (selectedStorage == StorageType.sqlite) {
      await sqliteController.delete(id);
    } else {
      hiveController.delete(id);
    }
    _loadNotes();
  }

  @override
  void initState() {
    super.initState();
    _initHive();
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          ' Notes',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input fields and add button
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _addNote,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 22, 101, 227),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        ),
                        child: const Icon(Icons.add,color: Colors.white,),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<StorageType>(
               
                        value: selectedStorage,
                        items: const [
                          DropdownMenuItem(
                            
                            value: StorageType.sqlite,
                            child: Text('SQLite'),
                          ),
                          DropdownMenuItem(
                            value: StorageType.hive,
                            child: Text('Hive'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => selectedStorage = value!);
                          _loadNotes();
                        },
                      ),
                      TextButton.icon(
                        onPressed: () {
                          hiveController.clear();
                          _loadNotes();
                        },
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        label: const Text("Clear Hive", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Notes list
            Expanded(
              child: _notes.isEmpty
                  ? const Center(child: Text("No notes yet"))
                  : ListView.builder(
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        final note = _notes[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              note.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                note.description,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () {
                                if (selectedStorage == StorageType.hive) {
                                  deleteNote(index);
                                } else {
                                  deleteNote(note.id);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
