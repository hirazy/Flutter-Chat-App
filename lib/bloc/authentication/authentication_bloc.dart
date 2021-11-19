
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_app/utils/authentication_repository.dart';
import 'package:chat_app/utils/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'authentication_event.dart';
import 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState>{
  AuthenticationBloc(AuthenticationState initialState) : super(initialState);


  // AuthenticationBloc({
  //   required AuthenticationRepository authenticationRepository,
  //   required UserRepository userRepository
  // })
  //     : _authenticationRepository = authenticationRepository,
  //     _userRepository = userRepository,
  // super(const AuthenticationState.unknown()){
  //   on<AuthenticationStatusChanged>(_onAuthenticationStatusChanged);
  //   on<AuthenticationLogoutRequested>(_onAuthenticationLogoutRequested);
  //   _authenticationStatusSubscription = _authenticationRepository.status.listen(
  //         (status) => add(AuthenticationStatusChanged(status)),
  //   );
  // };
  //
  // final AuthenticationRepository _authenticationRepository;
  // final UserRepository _userRepository;
  // late StreamSubscription<AuthenticationStatus> _authenticationStatusSubscription;

  @override
  Stream<AuthenticationState> mapEventToState(AuthenticationEvent event) async*{

  }
}