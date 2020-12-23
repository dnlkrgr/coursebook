:- module(production,[]).

:- use_module(library(http/http_server)).
:- ensure_loaded(handlers).

:- portray_text(true).

server(Port) :-
    format('Starting server on ~w', [Port]),
    http_server(http_dispatch, [port(Port)]).

main :- server(8081).

:- main.