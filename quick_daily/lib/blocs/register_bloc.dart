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

/// EVENTS
abstract class RegisterEvent extends Equatable {
  const RegisterEvent();
}

/// BLOC
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  @override
  RegisterState get initialState => RegisterInitial();

  @override
  Stream<RegisterState> mapEventToState(RegisterEvent event) async* {
    // TODO
  }
}
