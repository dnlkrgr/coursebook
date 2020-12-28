:- module(completed,[]).


:- use_module(library(http/http_server)).

:- use_module('../util/courses').
:- use_module('../util/util').


:- http_handler(root(completed),
                completed_handler(Method),
                [method(Method), methods([get])]).


completed_handler(get, Request) :-
    check_if_signed_in(Request, User),
    reply_html_page(
        title('Completed Courses'), 
        div([
            p('Your Completed Courses:'),
            \course_list(completed(User))
        ])
    ).

% RENDERING HTML
course_list(Predicate) -->
	{
      findall(X, call(Predicate, X), Todos),
      maplist(as_li, Todos, ListTodos)
	},
	html(ul(ListTodos)).