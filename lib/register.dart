import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:birdbrain/terms.dart';
import 'package:email_validator/email_validator.dart';

/// allows user to request an account. user must agree to terms
/// and conditions to request.
class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _emailController = TextEditingController();
  final _pwController = TextEditingController();
  CollectionReference newUserRequests = FirebaseFirestore.instance.collection('newUserRequests');
  bool agreedToTerms = false;
  String _emailErrorMessage = '';
  String _pwErrorMessage = '';

  //sends username and password to firestore so we can authorize
  //and approve.
  Future requestSignUp() async {
    newUserRequests.add({
      'email': _emailController,
      'password': _pwController
    });
    Navigator.pop(context);
  }

  //makes sure inout is valid email
  void validateEmail(String val) {
    if(val.isEmpty){
      setState(() {
        _emailErrorMessage = "Email can not be empty";
      });
    }else if(!EmailValidator.validate(val, true)){
      setState(() {
        _emailErrorMessage = "Invalid Email Address";
      });
    }else{
      setState(() {
        _emailErrorMessage = "";
      });
    }
  }

  //makes sure input is longer than 6 characters
  void validatePassword(String val) {
    if(val.isEmpty){
      setState(() {
        _pwErrorMessage = "Password can not be empty";
      });
    }else if(val.length < 6){
      setState(() {
        _pwErrorMessage = "Password must be more than 6 characterss";
      });
    }else{
      setState(() {
        _pwErrorMessage = "";
      });
    }
  }

  //disposes and closes app
  @override
  void dispose() {
    _emailController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child:
                Column(mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
              Icon(
                Icons.app_registration,
                size: 90,
              ),
              SizedBox(height: 20),
              Text(
                "Request an account",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "You will receive an email when your account has been approved.",
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 18.0),
                    child: TextField(
                      onChanged: (val) {
                        validateEmail(val);
                      },
                      controller: _emailController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'email',
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              Text(_emailErrorMessage,
                  style: TextStyle(
                      color: Colors.red
                  )),
              SizedBox(
                  height: 15
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 18.0),
                    child: TextField(
                      onChanged: (val) {
                        validatePassword(val);
                      },
                      controller: _pwController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'password',
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                  height: 5),
              Text(_pwErrorMessage,
                  style: TextStyle(
                      color: Colors.red
                  )),
              SizedBox(
                  height: 15),
              GestureDetector(
                onTap: () async {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => TermsPage()));
                },
                child: Text('Read Terms and Conditions',
                style: TextStyle(
                  fontSize: 16,
                  decoration: TextDecoration.underline
                )),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      "Accept Terms and Conditions",
                  style: TextStyle(
                    fontSize: 16
                  )),
                  Checkbox(value: this.agreedToTerms,
                      onChanged: (bool? value) {
                                    setState(() {
                                    this.agreedToTerms = value!;
                                    });},
                  )
                ],
              ),
              SizedBox(
                  height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: GestureDetector(
                  onTap: agreedToTerms? requestSignUp : null,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(15)),
                    child: Center(
                      child: Text(
                        "Submit Request",
                        style: TextStyle(
                          color: agreedToTerms ? Colors.white : Colors.grey,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                  height: 10),
            ]),
          ),
        ),
      ),
    );
  }
}
