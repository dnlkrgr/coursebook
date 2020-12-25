:- module(signin,[]).


:- use_module(library(http/http_server)).
:- use_module(library(http/http_authenticate)).

:- use_module('../util/courses').
:- use_module('../util/util').


:- http_handler(root(signin),
                signin_handler(Method),
                [method(Method), methods([get])]).


signin_handler(get, Request) :-
    http_authenticate(basic(passwd), Request, _),
    http_redirect(moved, '/', _).
signin_handler(get, _) :-
    throw(http_reply(authorise(basic, _))),
    http_redirect(moved, '/', _).
