build_kb:-
			write('Please enter a word and its category on separate lines:'),nl,
			read(TheWord), (TheWord=done ,write("Done building the words database...");read(Thecategory),
			assert(word(TheWord, Thecategory)), build_kb).

is_category(C) :- word(_,C).

categories(L) :- setof(C, is_category(C),L).


available_length(L) :- word(X,_) , atom_length(X,L). 

available_length2(L, C) :- word(X,C), atom_length(X,L).



pick_word(W,L,C) :- word(W,C), atom_length(W,L).

correct_letters(L1,L2, L3) :- intersection(L1, L2, L4), remove_duplicates(L4, L3).

remove_duplicates([], []).

remove_duplicates([Head | Tail], Result) :-
    member(Head, Tail), !,
    remove_duplicates(Tail, Result).

remove_duplicates([Head | Tail], [Head | Result]) :-
    remove_duplicates(Tail, Result).

correct_positions([],[],[]).
correct_positions(L1,L2,CP) :- L1=[H|T1], L2=[H|T2], CP=[H|CPT], correct_positions(T1,T2,CPT).
correct_positions(L1,L2,CP) :- L1=[H|T1], L2=[H2|T2], H\=H2 ,correct_positions(T1,T2,CP).


play:- categories(L), write('The available categories are: '),
		write(L), nl, write('Choose a category:') , nl ,
		read(C), checkcategory(C,L,C1), 
		write('Choose a length:'), nl,
		read(Length), checklength(Length,Length2), 
		check_length_within_category(Length2,C1, LengthFinal),
		pick_word(Word,LengthFinal,C1), Guesses is LengthFinal+1, 
		write('Game started, You have '), write(Guesses),  write(' guesses.'),nl,
		gamehelper(Word, Guesses, LengthFinal).

checkcategory(C,L,C) :- member(C,L),!.
checkcategory(C,L,C1) :- \+member(C,L), write('This category does not exist.'), nl,
						write('Choose a category: '), nl,
						read(X), checkcategory(X,L,C1).
checklength(Length,Length):- available_length(Length), !.
checklength(Length,Length2):- \+available_length(Length), write('There are no words of this length.'),
						nl, write('Choose a length: '), nl,
						read(Length1), checklength(Length1,Length2).
						
check_length_within_category(Length2,C1, Length2):- available_length2(Length2,C1).
check_length_within_category(Length2,C1, LengthFinal):- \+available_length2(Length2,C1), write('There are no words of this length in THIS CATEGORY.'),
						nl, write('Choose a length: '), nl,
						read(Length1), checklength(Length1,L2), check_length_within_category(L2,C1, LengthFinal).



gamehelper(_,0,_) :- write('You Lost!'),!.
						
gamehelper(Word, Guesses, Length) :- write('Enter a word composed of '), write(Length),
									write(' letters:') , nl,
									read(EnteredWord), ( 
									
									
									(atom_length(EnteredWord, L1), L1\=Length,
									write('Word is not composed of '), write(Length) ,write(' letters. Try again.'),nl,
									write('Remaining Guesses are: '), write(Guesses),nl,nl,
									gamehelper(Word, Guesses, Length))
									;
									
									(
									\+word(EnteredWord,_), write("This word is not available in the Database, try again"), nl,
									write('Remaining Guesses are: '), write(Guesses),nl,nl,
									gamehelper(Word, Guesses, Length)
									)
									;
									(atom_length(EnteredWord,Length), 
									NewGuesses is Guesses-1, atom_chars(EnteredWord, List),
									atom_chars(Word,L2),
									correct_letters(List,L2,CorrectLetters),
									correct_positions(List,L2,CorrectPositions),
									(
									(length(CorrectPositions,Length),
									write('You Won!'));(NewGuesses == 0, write('You Lost'));(
									write('Correct letters are: '), write(CorrectLetters),
									nl, write('Correct letters in correct positions are: '),
									write(CorrectPositions), nl,
									write('Remaining Guesses are: '), write(NewGuesses),nl,nl,
									gamehelper(Word,NewGuesses,Length)
									)
									
									))).
									
									
									
									
									
checkwordlength(EW,L) :- atom_length(EW,L),!.
checkwordlength(EW,L) :- atom_length(EW,L1), L1\=L,
						write('Word is not composed of ') ,write(L), write(' letters. Try again.'),nl,
						read(EnteredWord), checkwordlength(EnteredWord, L).


						
main :-
		write('Welcome to Pro-Wordle'),nl,nl,
		write('----------------------'),nl,
		build_kb,
		play.
