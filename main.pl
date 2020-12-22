:- module(production,[]).
/** <module> production mode starter file

    Consult this file to start the system in production
    don't load both it and debug

*/

% Make it easier to read 'codes' style strings
:- portray_text(true).


% First we import the abstract path stuff
:- use_module(library(http/http_path)).
% load the multi-threaded http server
:- use_module(library(http/thread_httpd)).
% and the standard handler dispatcher
:- use_module(library(http/http_dispatch)).

:- ensure_loaded(html_handlers).
:- ensure_loaded(handlers).


server(Port) :-
    format('Starting server on ~w', [Port]),
    http_server(http_dispatch, [port(Port)]).


%
% And start that puppy
main :- server(8081).

:- main.
