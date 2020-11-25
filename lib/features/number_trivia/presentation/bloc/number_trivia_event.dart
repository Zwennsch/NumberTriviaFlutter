part of 'number_trivia_bloc.dart';

abstract class NumberTriviaEvent extends Equatable {
  const NumberTriviaEvent([List props = const <dynamic>[]]);

  @override
  List<Object> get props => props;
}

class GetTriviaForConcreteNumber extends NumberTriviaEvent {
  // we are using a String here, since the value recieved from a textfield is always a string
  final String numberString;

  GetTriviaForConcreteNumber(this.numberString) : super([numberString]);
}

class GetTriviaForRandomNumber extends NumberTriviaEvent {}
