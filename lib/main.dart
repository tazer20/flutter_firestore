// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final Stream<QuerySnapshot> users =
      FirebaseFirestore.instance.collection('users').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Cloud firestore'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Read Data from Cloud Firestore',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Container(
                height: 250,
                padding: EdgeInsets.symmetric(vertical: 20),
                child: StreamBuilder<QuerySnapshot>(
                  stream: users,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Loading');
                    }
                    final data = snapshot.requireData;
                    return ListView.builder(
                      itemCount: data.size,
                      itemBuilder: (context, index) {
                        return Text(
                            'My name is ${data.docs[index]['name']} and I am ${data.docs[index]['age']} years old');
                      },
                    );
                  },
                )),
            Text(
              'Write Data to Cloud Firestore',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            MyCustomForm()
          ],
        ),
      ),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() => MyCustomFormState();
}

class MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();

  var name = '';
  var age = 0;
  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: InputDecoration(
                icon: Icon(Icons.person),
                hintText: 'Your Name??',
                labelText: 'Name'),
            onChanged: (value) {
              name = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some Text';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: InputDecoration(
                icon: Icon(Icons.date_range),
                hintText: 'Your Age??',
                labelText: 'Age'),
            onChanged: (value) {
              age = int.parse(value);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some Text';
              }
              return null;
            },
          ),
          SizedBox(
            height: 10,
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sending Data to Firestore'),
                    ),
                  );

                  users
                      .add({'name': name, 'age': age})
                      .then((value) => print('user added'))
                      .catchError(
                          (error) => print('failer to add user: $error'));
                }
              },
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
