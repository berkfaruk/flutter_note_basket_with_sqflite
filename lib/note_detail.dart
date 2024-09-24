// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_note_basket/models/category.dart';
import 'package:flutter_note_basket/models/notes.dart';
import 'package:flutter_note_basket/utils/database_helper.dart';
import 'package:flutter_note_basket/utils/ui_helper.dart';

class NoteDetail extends StatefulWidget {
  NoteDetail({super.key, required this.title, this.editedNote});

  String title;
  Notes? editedNote;

  @override
  State<NoteDetail> createState() => _NoteDetailState();
}

class _NoteDetailState extends State<NoteDetail> {
  var formKey = GlobalKey<FormState>();
  late List<Category> allCategories;
  late DatabaseHelper databaseHelper;
  int? categoryID;
  int? chosenPriority;
  String noteTitle = "", noteContent = "";
  static final _priority = ["Düşük", "Orta", "Yüksek"];

  @override
  void initState() {
    super.initState();
    allCategories = [];
    databaseHelper = DatabaseHelper();
    databaseHelper.getCategories().then(
      (mapListContainingCategories) {
        for (Map<String, dynamic> readMap in mapListContainingCategories) {
          allCategories.add(Category.fromMap(readMap));
        }

        if (widget.editedNote != null) {
          categoryID = widget.editedNote!.kategoriID;
          chosenPriority = widget.editedNote!.notOncelik;
        } else {
          categoryID = 1;
          chosenPriority = 0;
        }

        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: Text(
        widget.title,
        style: UIHelper.getAppBarTitleTextStyle(),
      )),
      body: allCategories.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Kategori:',
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 12),
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.redAccent, width: 2),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                items: createCategoryItems(),
                                value: categoryID,
                                onChanged: (chosenCategoryID) {
                                  setState(() {
                                    categoryID = chosenCategoryID!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: widget.editedNote != null
                              ? widget.editedNote!.notBaslik
                              : "",
                          validator: (text) {
                            if (text!.length < 3) {
                              return 'En az 3 karakter olmalı';
                            }
                            return null;
                          },
                          onSaved: (newText) {
                            noteTitle = newText!;
                          },
                          decoration: const InputDecoration(
                            hintText: 'Not Başlığını Giriniz',
                            labelText: 'Başlık',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: widget.editedNote != null
                              ? widget.editedNote!.notIcerik
                              : "",
                          onSaved: (text) {
                            noteContent = text!;
                          },
                          decoration: const InputDecoration(
                            hintText: 'Not İçeriğini Giriniz',
                            labelText: 'İçerik',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 4,
                        ),
                      ),
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Öncelik:',
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 36),
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.redAccent, width: 2),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                items: _priority.map(
                                  (priority) {
                                    return DropdownMenuItem<int>(
                                      value: _priority.indexOf(priority),
                                      child: Text(
                                        priority,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    );
                                  },
                                ).toList(),
                                value: chosenPriority,
                                onChanged: (chosenPriorityID) {
                                  setState(() {
                                    chosenPriority = chosenPriorityID!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      ButtonBar(
                        alignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: const ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(Colors.red),
                                foregroundColor:
                                    WidgetStatePropertyAll(Colors.white)),
                            child: const Text('Vazgeç'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                formKey.currentState!.save();

                                var rightNow = DateTime.now();
                                if (widget.editedNote == null) {
                                  databaseHelper
                                      .addNote(Notes(
                                          categoryID,
                                          noteTitle,
                                          noteContent,
                                          rightNow.toString(),
                                          chosenPriority))
                                      .then(
                                    (savedNoteID) {
                                      if (savedNoteID != 0) {
                                        Navigator.pop(context);
                                      }
                                    },
                                  );
                                } else {
                                  databaseHelper
                                      .updateNote(Notes.withID(
                                          widget.editedNote!.notID,
                                          categoryID,
                                          noteTitle,
                                          noteContent,
                                          rightNow.toString(),
                                          chosenPriority))
                                      .then((updatedID) {
                                    if (updatedID != 0) {
                                      Navigator.pop(context);
                                    }
                                  });
                                }
                              }
                            },
                            style: const ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(Colors.green),
                                foregroundColor:
                                    WidgetStatePropertyAll(Colors.white)),
                            child: const Text('Kaydet'),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
    );
  }

  List<DropdownMenuItem<int>> createCategoryItems() {
    return allCategories
        .map(
          (category) => DropdownMenuItem<int>(
              value: category.kategoriID,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  category.kategoriBaslik!,
                  style: const TextStyle(fontSize: 18),
                ),
              )),
        )
        .toList();
  }
}
