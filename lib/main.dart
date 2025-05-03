import 'package:flutter/material.dart';
import 'package:flutter_application_4/models/note_adapter.dart';
import 'package:flutter_application_4/views/noteUi.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart'; 

void main() async {
 
  await Hive.initFlutter();
  Hive.registerAdapter(NoteAdapter());  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const NotesScreen(),
      debugShowCheckedModeBanner: false,  
    );
  }
}
