:- module(util, [check_if_signed_in/2, link_list/4, as_a_li/3, as_li/2, uni_field_subject_to_course_name/4]).

:- use_module(library(http/http_server)).
:- use_module(library(http/http_authenticate)).

:- use_module(courses).

check_if_signed_in(_, _).
% check_if_signed_in(Request, User)   :- http_authenticate(basic(passwd), Request, [User | _]).
% check_if_signed_in(_, _)            :- http_redirect(moved, root(signup), _).


link_list(Predicate, Path) -->
	{
      findall(X, call(Predicate, X), Todos),
      maplist(as_a_li(Path), Todos, ListTodos)
	},
	html(ul(ListTodos)).


as_a_li(Path, X, li(Temp2)) :-
    atom_concat(Path, X, Temp1),
    Temp2 = a(href(Temp1), p(X)).

as_li(X, li(X)).


uni_field_subject_to_course_name(MyUni, MyField, MySubject, CourseName) :-
    course(MyUni, MyField, MySubject, _, _, CourseName, _, _).