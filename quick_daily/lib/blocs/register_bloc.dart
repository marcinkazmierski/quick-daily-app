import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

///STATES
abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object> get props => [];
}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterFailure extends RegisterState {
  final String error;

  const RegisterFailure({this.error});

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'RegisterFailure { error: $error }';
}

/// EVENTS
abstract class RegisterEvent extends Equatable {
  const RegisterEvent();
}

class RegisterButtonPressed extends RegisterEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'RegisterButtonPressed {}';
}

class RegisterSubmit extends RegisterEvent {
  final String nick;
  final String email;
  final String password;

  const RegisterSubmit({
    this.nick,
    this.email,
    this.password,
  });

  @override
  List<Object> get props => [nick, email, password];

  @override
  String toString() =>
      'RegisterSubmit { nick: $nick, email: $email, password: $password }';
}

class OnRegisterError extends RegisterEvent {
  final String error;

  const OnRegisterError({this.error});

  @override
  List<Object> get props => [this.error];

  @override
  String toString() => 'OnCallError {}';
}

/// BLOC
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  @override
  RegisterState get initialState => RegisterInitial();

  @override
  Stream<RegisterState> mapEventToState(RegisterEvent event) async* {
    // TODO
    if (event is RegisterSubmit) {
      try {
        //todo: do registration
      } catch (error) {
        yield RegisterFailure(error: error.toString());
      }
    }

    if (event is OnRegisterError) {
      yield RegisterFailure(error: event.error);
    }
  }
}
