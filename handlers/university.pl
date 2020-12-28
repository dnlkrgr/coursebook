:- module(university, []).


:- use_module(library(http/http_server)).

:- use_module('../util/courses').
:- use_module('../util/util').

:- http_handler(root(university/MyUni),
                university_handler(Method, MyUni),
                [method(Method), methods([get, post])]).


university_handler(get, MyUni, Request) :-
    check_if_signed_in(Request, _),
    http_parameters(Request, []),
    atom_concat(MyUni, '/field/', Temp2),
    reply_html_page(
        title(MyUni), 
        div([
            h2(MyUni),
            form([method('post')], [input([value('Set this as my university'), type(submit)])]),
            h1('Fields of Study:'),
            \link_list(field_of_study(MyUni), Temp2)
        ])
    ). 

university_handler(post, MyUni, Request) :-
    check_if_signed_in(Request, User),
    \+ goes_to(User, MyUni),
    assert_goes_to(User, MyUni),
    http_redirect(moved, '/', _).
university_handler(post, _, _) :-
    http_redirect(moved, '/', _).
