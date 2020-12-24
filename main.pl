:- module(production,[]).

:- use_module(library(http/http_server)).

:- use_module('handlers/home').
:- use_module('handlers/signin').
:- use_module('handlers/signup').
:- use_module('handlers/university').
:- use_module('handlers/field').
:- use_module('handlers/subject').
:- use_module('handlers/course').
:- use_module('handlers/completed').
:- use_module('handlers/available').

:- portray_text(true).

server(Port) :-
    format('Starting server on ~w', [Port]),
    http_server(http_dispatch, [port(Port)]).

main :- server(8081).

:- main.