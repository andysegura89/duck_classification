import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register.dart';
import 'login_check.dart';
import 'package:email_validator/email_validator.dart';

//login page

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // used to read text in input fields
  final _emailController = TextEditingController();
  final _pwController = TextEditingController();
  //error messages displayed when text isn't correct
  String _emailErrorMessage = '';
  String _pwErrorMessage = '';

  //makes sure input is a valid email
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
  //makes sure password is over 6 characters
  void validatePassword(String val) {
    if(val.isEmpty){
      setState(() {
        _pwErrorMessage = "Password can not be empty";
      });
    }else if(val.length < 6){
      setState(() {
        _pwErrorMessage = "Password must be more than 6 characters";
      });
    }else{
      setState(() {
        _pwErrorMessage = "";
      });
    }
  }

  //Attempts to sign in user to firebase, reroutes to Login Check
  // to see if login attempt was successful

  Future signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _pwController.text.trim());
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => LoginCheck()));

  }

  // disposes and closes app, automatically called
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
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                Icons.dataset_linked,
                size: 105,
              ),
              SizedBox(height: 20),
              Text(
                "birdbrAIn-CR2G",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              SizedBox(height: 15),
              Text(
                "Welcome!",
                style: TextStyle(fontSize: 18),
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
                      keyboardType: TextInputType.emailAddress,
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
                  height: 5),
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
                height: 5,),
              Text(
                  _pwErrorMessage,
                style: TextStyle(
                    color: Colors.red),
              ),
              SizedBox(
                  height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: GestureDetector(
                  onTap: signIn,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(15)),
                    child: Center(
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  'New User?  ',
                  style: TextStyle(
                    color: Colors.black38,
                    fontSize: 20,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Register()));
                  },
                  child: Text('Register',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 20,
                      )),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
