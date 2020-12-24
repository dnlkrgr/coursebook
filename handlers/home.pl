:- module(home_handler,[]).

:- use_module(library(http/http_server)).
:- use_module(library(http/http_authenticate)).

:- use_module('../util/courses').
:- use_module('../util/util').


:- http_handler(/, home_handler(Method), [method(Method), methods([get])]).

home_handler(get, Request) :-
    check_if_signed_in(Request),
    reply_html_page(
        title('Coursebook'), 
        div([
            h1('Listed Universities:'),
            \link_list(university, 'university/'),
            h2('Completed Courses:'),
            a(href('/completed'), p('Completed')),
            h2('Available Courses:'),
            a(href('/available'), p('Available'))
        ])
    ).
