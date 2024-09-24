import 'package:flutter/material.dart';
import 'package:flutter_note_basket/models/category.dart';
import 'package:flutter_note_basket/utils/database_helper.dart';
import 'package:flutter_note_basket/utils/ui_helper.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  List<Category>? allCategories;
  late DatabaseHelper databaseHelper;

  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    if (allCategories == null) {
      allCategories = <Category>[];
      updateCategoryList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Kategoriler', style: UIHelper.getAppBarTitleTextStyle(),),
      ),
      body: ListView.builder(
        itemCount: allCategories!.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(allCategories![index].kategoriBaslik!),
            trailing: InkWell(
              child: const Icon(Icons.delete),
              onTap: () => _deleteCategory(allCategories![index].kategoriID),
            ),
            leading: const Icon(Icons.category),
            onTap: () => _updateCategory(allCategories![index], context),
          );
        },
      ),
    );
  }

  void updateCategoryList() {
    databaseHelper.getCategoryList().then(
      (containsCategoriesList) {
        setState(() {
          allCategories = containsCategoriesList;
        });
      },
    );
  }

  _deleteCategory(int? kategoriID) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Kategori Sil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Kategoriyi sildiğinizde bununla ilgili tüm notlarda silinecektir. Emin misiniz ?'),
              ButtonBar(
                children: [
                  OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Vazgeç')),
                  OutlinedButton(
                    onPressed: () {
                      databaseHelper.deleteCategory(kategoriID!).then(
                        (deletedCategory) {
                          if (deletedCategory != 0) {
                            setState(() {
                              updateCategoryList();
                              Navigator.of(context).pop();
                            });
                          }
                        },
                      );
                    },
                    child: const Text(
                      'Kategoriyi Sil',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  _updateCategory(Category toBeUpdatedCategory, BuildContext context) {
    updateCategoryDialog(context, toBeUpdatedCategory);
  }

  updateCategoryDialog(BuildContext context, Category toBeUpdatedCategory) {
    var formKey = GlobalKey<FormState>();
    String? toBeUpdatedCategoryName;

    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            'Kategori Güncelle',
            style: UIHelper.getAppBarTitleTextStyle(),
          ),
          children: [
            Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: toBeUpdatedCategory.kategoriBaslik,
                  onSaved: (newValue) {
                    toBeUpdatedCategoryName = newValue;
                  },
                  decoration: const InputDecoration(
                      labelText: 'Kategori Adı', border: OutlineInputBorder()),
                  validator: (enteredCategoryName) {
                    if (enteredCategoryName!.length < 2) {
                      return 'En az 2 karakter giriniz';
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
                  child: const Text(
                    'Vazgeç',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(style: UIHelper.getElevatedButtonAcceptButtonStyle(),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();

                      databaseHelper
                          .updateCategory(Category.withID(
                              toBeUpdatedCategory.kategoriID,
                              toBeUpdatedCategoryName))
                          .then(
                        (categoryID) {
                          if (categoryID != 0) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('Kategori Güncellendi')));
                            updateCategoryList();
                            Navigator.pop(context);
                          }
                        },
                      );
                    }
                  },
                  child: const Text(
                    'Kaydet',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
