:- module(available,[]).


:- use_module(library(http/http_server)).

:- use_module('../util/courses').
:- use_module('../util/util').


:- http_handler(root(available),
                available_handler(Method),
                [method(Method), methods([get])]).


available_handler(get, Request) :-
    check_if_signed_in(Request, User),
    reply_html_page(
        title('available Courses'), 
        div([
            p('Your Available Courses:'),
            \available_list(User)
        ])
    ).

% RENDERING HTML
available_list(User) -->
	{
      findall(X, is_available(User, X), Todos),
      maplist(as_li, Todos, ListTodos)
	},
	html(ul(ListTodos)).


my_course(Semester, CourseName, Prerequisites, Credits, CourseType) :-
    university(University),
    field_of_study(University, FieldOfStudy),
    course(University,
           FieldOfStudy,
           _,
           Semester,
           CourseName,
           Prerequisites,
           Credits,
           CourseType).

completed_course(CourseName, Credits, CourseType) :-
    my_course(_, CourseName, _, Credits, CourseType),
    completed(_, CourseName).

% ein Course ist belegbar:
% - falls er nicht schon completed worden ist
% - falls alle Voraussetzungen Kurse sind
% - und diese completed wurden
is_available(User, Course) :-
    my_course(_, Course, Prerequisites, _, _),
    \+ completed(User, Course),
    forall(member(X, Prerequisites), completed(User, X)).