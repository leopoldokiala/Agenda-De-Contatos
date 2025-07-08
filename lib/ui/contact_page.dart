import 'dart:io';

import 'package:agenda_de_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact? contact;
  ContactPage({this.contact});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _nameFocus = FocusNode();

  bool _userEdited = false;
  Contact? _editedContact;

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact!.toMap());

      _nameController.text = _editedContact!.name ?? '';
      _emailController.text = _editedContact!.email ?? '';
      _phoneController.text = _editedContact!.phone ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_userEdited,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          bool shouldPop = await _requestPop();
          if (shouldPop) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(
            _editedContact?.name ?? 'Novo Contato',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed: () {
            if (_editedContact!.name != null &&
                _editedContact!.name!.isNotEmpty) {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context, _editedContact);
              }
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
            ;
          },
          child: Icon(Icons.save, color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image:
                          _editedContact!.img != null
                              ? FileImage(File(_editedContact!.img!))
                              : AssetImage('images/User.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                onTap: () async {
                  final picker = ImagePicker();
                  final file = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (file != null) {
                    setState(() {
                      _editedContact?.img = file.path;
                    });
                  }
                },
              ),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(labelText: 'Nome'),
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedContact!.name = text;
                  });
                },
              ),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'Email'),
                  onChanged: (text) {
                    _userEdited = true;
                    _editedContact!.email = text;
                  },
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'O email não pode estar vazio';
                    } else if (!text.contains('@') || !text.contains('.')) {
                      return 'Digite um email válido';
                    }
                    return null;
                  },
                ),
              ),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Phone'),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact!.phone = text;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPop() async {
    if (_userEdited) {
      bool? shouldPop = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('Descartar Alterações?'),
            content: Text('Se sair, as alterações serão perdidas.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text('Sim'),
              ),
            ],
          );
        },
      );

      return shouldPop ?? false;
    }

    return true;
  }
}
