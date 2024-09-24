// ignore_for_file: must_be_immutable, camel_case_types
import 'package:flutter/material.dart';
import 'package:flutter_note_basket/category_operations.dart';
import 'package:flutter_note_basket/models/category.dart';
import 'package:flutter_note_basket/models/notes.dart';
import 'package:flutter_note_basket/note_detail.dart';
import 'package:flutter_note_basket/utils/database_helper.dart';
import 'package:flutter_note_basket/utils/ui_helper.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Note Basket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Raleway",
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        elevatedButtonTheme: const ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.blue),
            foregroundColor: WidgetStatePropertyAll(Colors.white),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.green, foregroundColor: Colors.white),
      ),
      home: const NoteList(),
    );
  }
}

class NoteList extends StatefulWidget {
  const NoteList({super.key});

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Not Sepeti',
          style: UIHelper.getAppBarTitleTextStyle(),
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                    child: ListTile(
                  leading: const Icon(Icons.category),
                  title: const Text('Kategoriler'),
                  onTap: () {
                    Navigator.of(context).pop();
                    return _goToCategoriesPage();
                  },
                )),
              ];
            },
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              addCategoryDialog(context);
            },
            tooltip: 'Kategori Ekle',
            heroTag: 'addCategory',
            mini: true,
            child: const Icon(Icons.add_circle),
          ),
          FloatingActionButton(
            onPressed: () {
              _goToDetailPage(context);
            },
            tooltip: 'Not Ekle',
            heroTag: 'addNote',
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: showNotes(),
    );
  }

  addCategoryDialog(BuildContext context) {
    var formKey = GlobalKey<FormState>();
    String? newCategoryName;

    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('Kategori Ekle', style: UIHelper.getTitleTextStyle()),
          children: [
            Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  onSaved: (newValue) {
                    newCategoryName = newValue;
                  },
                  decoration: const InputDecoration(
                      labelText: 'Kategori Adı', border: OutlineInputBorder()),
                  validator: (enteredCategoryName) {
                    if (enteredCategoryName!.length < 3) {
                      return 'En az 3 karakter giriniz';
                    }
                    return null;
                  },
                ),
              ),
            ),
            ButtonBar(
              children: [
                ElevatedButton(
                  style: UIHelper.getElevatedButtonRejectButtonStyle(),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Vazgeç',
                    style: UIHelper.getButtonTextStyle(),
                  ),
                ),
                ElevatedButton(
                  style: UIHelper.getElevatedButtonAcceptButtonStyle(),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      databaseHelper
                          .addCategory(Category(newCategoryName))
                          .then((categoryID) {
                        if (categoryID > 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Kategori Eklendi')));
                          Navigator.pop(context);
                        }
                      });
                    }
                  },
                  child: Text(
                    'Kaydet',
                    style: UIHelper.getButtonTextStyle(),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  _goToDetailPage(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NoteDetail(
            title: 'Yeni Not',
          ),
        )).then((value) => setState(() {}));
  }

  void _goToCategoriesPage() {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (context) => const Categories(),
        ))
        .then((value) => setState(() {}));
  }
}

class showNotes extends StatefulWidget {
  const showNotes({super.key});

  @override
  State<showNotes> createState() => _showNotesState();
}

class _showNotesState extends State<showNotes> {
  late List<Notes> allNotes;
  late DatabaseHelper databaseHelper;

  @override
  void initState() {
    super.initState();
    allNotes = [];
    databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: databaseHelper.getNoteList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          allNotes = snapshot.data!;
          return ListView.builder(
            itemCount: allNotes.length,
            itemBuilder: (context, index) {
              return ExpansionTile(
                leading: _showPriorityIcon(allNotes[index].notOncelik),
                title: Text(allNotes[index].notBaslik!),
                subtitle: Text(allNotes[index].kategoriBaslik!),
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Kategori',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                allNotes[index].kategoriBaslik!,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Oluşturulma Tarihi',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                allNotes[index].notTarih == ""
                                    ? "N/A"
                                    : databaseHelper.dateFormat(DateTime.parse(
                                        allNotes[index].notTarih!)),
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "İçerik: \n${allNotes[index].notIcerik!}",
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        ButtonBar(
                          alignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton(
                                onPressed: () =>
                                    _deleteNote(allNotes[index].notID!),
                                child: const Text(
                                  'SİL',
                                  style: TextStyle(color: Colors.redAccent),
                                )),
                            OutlinedButton(
                                onPressed: () {
                                  _goToDetailPage(context, allNotes[index]);
                                },
                                child: const Text(
                                  'GÜNCELLE',
                                  style: TextStyle(color: Colors.green),
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  _goToDetailPage(BuildContext context, Notes note) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NoteDetail(
            title: 'Notu Düzenle',
            editedNote: note,
          ),
        )).then(
      (value) => setState(() {}),
    );
  }

  _showPriorityIcon(int? notOncelik) {
    switch (notOncelik) {
      case 0:
        return CircleAvatar(
          backgroundColor: Colors.redAccent.shade100,
          child: const Text(
            'Az',
            style: TextStyle(color: Colors.white),
          ),
        );

      case 1:
        return CircleAvatar(
          backgroundColor: Colors.redAccent.shade200,
          child: const Text('Orta', style: TextStyle(color: Colors.white)),
        );

      case 2:
        return CircleAvatar(
          backgroundColor: Colors.redAccent.shade700,
          child: const Text('Acil', style: TextStyle(color: Colors.white)),
        );
    }
  }

  _deleteNote(int notID) {
    databaseHelper.deleteNote(notID).then((deleteID) {
      if (deleteID != 0) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Not Silindi")));
        setState(() {});
      }
    });
  }
}
