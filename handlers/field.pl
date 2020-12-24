:- module(field, []).


:- use_module(library(http/http_server)).
:- use_module(library(http/http_authenticate)).

:- use_module('../util/courses').
:- use_module('../util/util').

:- http_handler(root(university/MyUni/field/MyField),
                field_handler(Method, MyUni, MyField),
                [method(Method), methods([get])]).


field_handler(get, MyUni, MyField, Request) :-
    check_if_signed_in(Request),
    atom_concat(MyField, '/subject/', Path),
    reply_html_page(
        title(MyField), 
        div([
            h3(MyUni),
            h2(MyField),
            h1('Subjects:'),
            \link_list(subject(MyField), Path)
        ])
    ).