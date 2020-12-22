:- module(handlers, []).


:- use_module(library(http/http_dispatch)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_parameters)).

:- ensure_loaded(courses).


:- http_handler('/',                                    home(Method),                   [method(Method), methods([get])]).
:- http_handler(root(completed),                        completed_handler(Method),      [method(Method), methods([get])]).
:- http_handler(root(takeable),                         takeable_handler(Method),       [method(Method), methods([get])]).
:- http_handler(root(university/MyUni),                 university(Method, MyUni),      [method(Method), methods([get])]).
:- http_handler(root(university/MyUni/field/MyField),   field(Method, MyUni, MyField),  [method(Method), methods([get])]).




home(get, _Request) :-
    reply_html_page(
        title('Coursebook'), 
        div([
            % a(href('/completed'), p('Your Completed Courses Here')),
            % a(href('/takeable'), p('Your Available Courses Here')),
            \link_list(university, 'university/')
        ])
    ).

university(get, MyUni, Request) :-
    http_parameters(Request, []),
    % atom_concat('university/', MyUni, Temp1),
    atom_concat(MyUni, '/field/', Temp2),
    reply_html_page(
        title(MyUni), 
        div([
            h1(MyUni),
            h3('Fields of Study:'),
            \link_list(field_of_study(MyUni), Temp2)
        ])
    ).

% TODO: Name muss bei `course` als letztes stehen
field(get, MyUni, MyField, Request) :-
    http_parameters(Request, []),
    atom_concat('university/', MyUni, Temp1),
    atom_concat(MyField, '/', Temp2),

    % atom_concat(Temp2, MyField, Temp3),
    reply_html_page(
        title(MyUni), 
        div([
            h1(MyField),
            \course_list(course_name)
        ])
    ).



link_list(Predicate, Path ) -->
	{
      findall(X, call(Predicate, X), Todos),
      maplist(as_a_li(Path ), Todos, ListTodos)
	},
	html(ul(ListTodos)).

as_a_li(Path, X, li(Temp2)) :-
    atom_concat(Path, X, Temp1),
    Temp2 = a(href(Temp1), p(X)).

completed_handler(get, _Request) :-
    reply_html_page(
        title('Completed Courses'), 
        div([
            p('Your Completed Courses:'),
            \course_list(completed)
        ])
    ).

% RENDERING HTML
course_list(Predicate) -->
	{
      findall(X, call(Predicate, X), Todos),
      maplist(as_li, Todos, ListTodos)
	},
	html(ul(ListTodos)).

as_li(X, li(X)).



takeable_handler(get, _Request) :-
    reply_html_page(
        title('Takeable Courses'), 
        div([
            p('Your Available Courses:'),
            \available_list
        ])
    ).


% RENDERING HTML
available_list -->
	{
      findall(X, is_takeable(X), Todos),
      maplist(as_li, Todos, ListTodos)
	},
	html(ul(ListTodos)).