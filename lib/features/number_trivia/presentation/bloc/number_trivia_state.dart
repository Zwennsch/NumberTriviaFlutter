part of 'number_trivia_bloc.dart';

abstract class NumberTriviaState extends Equatable {
  const NumberTriviaState();

  @override
  List<Object> get props => [];
}

class Empty extends NumberTriviaState {}

class Loading extends NumberTriviaState {}

class Loaded extends NumberTriviaState {
  final NumberTrivia trivia;

  Loaded({@required this.trivia});

  // I am actually not so sure about that... Because in the tutorial the old version of Equatable is used and the trivia gets passed to super
  get props => [trivia];
}

class Error extends NumberTriviaState {
  final String errorMsg;

  Error({@required this.errorMsg});

  // I am actually not so sure about that... Because in the tutorial the old version of Equatable is used and the trivia gets passed to super
  get props => [errorMsg];
}
