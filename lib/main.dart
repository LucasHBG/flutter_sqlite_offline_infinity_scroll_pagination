import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_test_pagination/database_helper.dart';
import 'package:sqflite_test_pagination/user.dart';
import 'package:sqflite_test_pagination/user_card.dart';
import 'package:sqflite_test_pagination/user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
  }
  // Change the default factory. On iOS/Android, if not using `sqlite_flutter_lib` you can forget
  // this step, it will use the sqlite version available on the system.
  databaseFactory = databaseFactoryFfi;
  DBHelper.instance.database;

  final List<User> users = List.generate(50, (index) {
    return User(
      id: index + 1,
      active: Random().nextBool(),
      sex: index % 2 == 0 ? 'male' : 'female',
      name: 'User${index + 1}',
    );
  });

  final database = await DBHelper().database;
  for (User user in users) {
    database.insert(
      UserRepository().tableName,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  final PagingController<int, User> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems =
          await UserRepository().getUsersPaginated(pageKey == 0 ? 0 : pageKey * 10);
      final isLastPage = newItems.length < 10;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: PagedListView(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<User>(
            itemBuilder: (context, item, index) => UserCard(
              user: item,
            ),
          ),
        ),
      ),
    );
  }
}
