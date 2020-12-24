:- module(available,[]).


:- use_module(library(http/http_server)).
:- use_module(library(http/http_authenticate)).

:- use_module('../util/courses').
:- use_module('../util/util').


:- http_handler(root(available),
                available_handler(Method),
                [method(Method), methods([get])]).


available_handler(get, Request) :-
    check_if_signed_in(Request),
    reply_html_page(
        title('available Courses'), 
        div([
            p('Your Available Courses:'),
            \available_list
        ])
    ).

% RENDERING HTML
available_list -->
	{
      findall(X, is_available(X), Todos),
      maplist(as_li, Todos, ListTodos)
	},
	html(ul(ListTodos)).