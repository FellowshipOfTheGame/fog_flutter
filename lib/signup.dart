import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final Firestore _db = Firestore.instance;

class SignUpWidget extends StatefulWidget {
  @override
  _SignUpWidget createState() => new _SignUpWidget();
}

class _SignUpWidget extends State<SignUpWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  Future<bool> _sigin = Future.value(false);
  CollectionReference get members => _db.collection('members');

  Future<Null> _addMember(FirebaseUser user) async {
    final DocumentReference document = members.document(user.uid);
    document.setData(<String, dynamic>{
      'name': user.displayName,
      'authority': 0,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
      ),
      body: FutureBuilder(
        future: _sigin,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();
          if (snapshot.data == false)
            return Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, bottom: 16.0, right: 16.0, top: 32.0),
              child: Column(
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: Column(children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value.isEmpty) return 'Name is empty';
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'E-mail',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value.isEmpty) return 'E-mail is empty';
                            if (value.contains(' ') ||
                                !value.contains(RegExp(r'^[^@]+@[^.]+\..+$')))
                              return 'Invalid e-mail';
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TextFormField(
                          controller: _passController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value.isEmpty) return 'Password is empty';
                            if (value.length < 8)
                              return 'Password needs to be at least 8 caracters long';
                            if (!value.contains(RegExp(r'[a-zA-Z]')) ||
                                !value.contains(RegExp(r'[0-9]')))
                              return 'Password needs to contain numbers and letters';
                          },
                          obscureText: true,
                        ),
                      ),
                    ]),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          _sigin = Future.value(true);
                        });

                        try {
                          await _auth.createUserWithEmailAndPassword(
                              email: _emailController.text,
                              password: _passController.text);
                          UserUpdateInfo _user = UserUpdateInfo();
                          _user.displayName = _nameController.text;
                          await _auth.updateProfile(_user);

                          FirebaseUser user = await _auth.currentUser();
                          _addMember(user);
                          Navigator.of(context).pop(user);
                        } catch (e) {}
                      }
                    },
                    child: Text('Signup'),
                  ),
                ],
              ),
            );
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}