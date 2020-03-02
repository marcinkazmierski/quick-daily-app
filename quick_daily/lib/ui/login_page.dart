import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:quick_daily/repositories/api_repository.dart';
import 'package:quick_daily/blocs/authentication_bloc.dart';
import 'package:quick_daily/blocs/login_bloc.dart';

class LoginPage extends StatelessWidget {
  final ApiRepository apiRepository;

  LoginPage({Key key, this.apiRepository})
      : assert(apiRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) {
          return LoginBloc(
            authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
            apiRepository: apiRepository,
          );
        },
        child: LoginForm(),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  TextStyle _style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  @override
  Widget build(BuildContext context) {
    _onLoginButtonPressed() {
      BlocProvider.of<LoginBloc>(context).add(
        LoginButtonPressed(
          username: _usernameController.text,
          password: _passwordController.text,
        ),
      );
    }

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return Scaffold(
            body: Stack(
              children: <Widget>[
                Container(
                  decoration: new BoxDecoration(
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage("assets/images/background.jpg"))),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        CircleAvatar(
                          radius: 58.0,
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          child: Icon(Icons.phone_in_talk, size: 50),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                              hintStyle: TextStyle(color: Colors.white),
                              filled: true,
                              fillColor: Colors.black45,
                              hintText: 'Username'),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                              filled: true,
                              prefixIcon: Icon(Icons.lock, color: Colors.white),
                              hintStyle: TextStyle(color: Colors.white),
                              fillColor: Colors.black45,
                              hintText: 'Password'),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        FlatButton(
                            onPressed: () {},
                            child: Text(
                              'Forgot your Password?',
                              style: TextStyle(color: Colors.white),
                            )),
                        SizedBox(
                          height: 15.0,
                        ),
                        Center(
                          child: state is LoginLoading
                              ? CircularProgressIndicator()
                              : null,
                        ),
                        RaisedButton(
                          onPressed: state is! LoginLoading
                              ? _onLoginButtonPressed
                              : null,
                          child: Padding(
                              padding: EdgeInsets.all(15.0),
                              child: Text('LOGIN')),
                          color: Colors.teal,
                          textColor: Colors.white,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        RaisedButton(
                          onPressed: () {},
                          child: Padding(
                              padding: EdgeInsets.all(15.0),
                              child: Text('REGISTER')),
                          color: Colors.grey,
                          textColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
