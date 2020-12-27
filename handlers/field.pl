:- module(field, []).


:- use_module(library(http/http_server)).
:- use_module(library(http/http_authenticate)).

:- use_module('../util/courses').
:- use_module('../util/util').

:- http_handler(root(university/MyUni/field/MyField),
                field_handler(Method, MyUni, MyField),
                [method(Method), methods([get, post])]).


field_handler(get, MyUni, MyField, Request) :-
    check_if_signed_in(Request, _),
    atom_concat(MyField, '/subject/', Path),
    reply_html_page(
        title(MyField), 
        div([
            h3(MyUni),
            h2(MyField),
            form([method('post')], [input([value('Set this as my field'), type(submit)])]),
            h1('Subjects:'),
            \link_list(subject(MyField), Path)
        ])
    ).

field_handler(post, _, MyField, Request) :-
    check_if_signed_in(Request, User),
    \+ has_field(User, MyField),
    assert_has_field(User, MyField),
    http_redirect(moved, '/', _).
field_handler(post, _, _, _) :-
    http_redirect(moved, '/', _).
