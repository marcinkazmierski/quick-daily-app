import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_daily/blocs/register_bloc.dart';
import 'package:quick_daily/common/fade_animation.dart';
import 'package:quick_daily/repositories/api_repository.dart';

class RegisterPage extends StatelessWidget {
  final ApiRepository apiRepository;

  RegisterPage({Key key, this.apiRepository})
      : assert(apiRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) {
          return RegisterBloc();
        },
        child: RegisterForm(),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _nickController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _onRegisterSubmit() {
      BlocProvider.of<RegisterBloc>(context).add(
        RegisterSubmit(
          email: _emailController.text,
          nick: _nickController.text,
          password: _passwordController.text,
        ),
      );
    }

    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is RegisterFailure) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<RegisterBloc, RegisterState>(
        builder: (context, state) {
          return Scaffold(
            body: Stack(
              children: <Widget>[
                Container(
                  decoration: new BoxDecoration(
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage("assets/images/bg2.jpg"))),
                ),
                Container(
                  color: Color.fromRGBO(0, 0, 0, 0.2),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        FadeAnimation(
                            2,
                            CircleAvatar(
                              radius: 58.0,
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              child: Icon(Icons.phone_in_talk, size: 50),
                            )),
                        SizedBox(
                          height: 30.0,
                        ),
                        FadeAnimation(
                            2,
                            TextFormField(
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              controller: _emailController,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                  hintStyle: TextStyle(color: Colors.white54),
                                  filled: true,
                                  fillColor: Colors.black45,
                                  hintText: 'E-mail'),
                            )),
                        SizedBox(
                          height: 10.0,
                        ),
                        FadeAnimation(
                            2,
                            TextFormField(
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              controller: _nickController,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                  hintStyle: TextStyle(color: Colors.white54),
                                  filled: true,
                                  fillColor: Colors.black45,
                                  hintText: 'Nick'),
                            )),
                        SizedBox(
                          height: 10.0,
                        ),
                        FadeAnimation(
                            2,
                            TextFormField(
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                  filled: true,
                                  prefixIcon:
                                      Icon(Icons.lock, color: Colors.white),
                                  hintStyle: TextStyle(color: Colors.white54),
                                  fillColor: Colors.black45,
                                  hintText: 'Password'),
                            )),
                        SizedBox(
                          height: 15.0,
                        ),
                        FadeAnimation(
                            2,
                            FlatButton(
                                onPressed: () {
                                  Scaffold.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Feature is not implemented yet'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                },
                                child: Text(
                                  'Forgot your Password?',
                                  style: TextStyle(color: Colors.white),
                                ))),
                        SizedBox(
                          height: 15.0,
                        ),
                        Center(
                          child: state is RegisterLoading
                              ? CircularProgressIndicator()
                              : null,
                        ),
                        FadeAnimation(
                            2,
                            RaisedButton(
                              onPressed: state is! RegisterLoading
                                  ? _onRegisterSubmit()
                                  : null,
                              child: Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: Text('REGISTER')),
                              color: Colors.teal,
                              textColor: Colors.white,
                            )),
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
