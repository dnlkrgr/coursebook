:- module(subject, []).


:- use_module(library(http/http_server)).
:- use_module(library(http/http_authenticate)).

:- use_module('../util/courses').
:- use_module('../util/util').

:- http_handler(root(university/MyUni/field/MyField/subject/MySubject),
                subject_handler(Method, MyUni, MyField, MySubject),
                [method(Method), methods([get])]).


subject_handler(get, MyUni, MyField, MySubject, Request) :-
    check_if_signed_in(Request, _),
    atom_concat(MySubject, '/course/', Path),
    reply_html_page(
        title(MySubject), 
        div([
            h4(MyUni),
            h3(MyField),
            h2(MySubject),
            h1('Courses:'),
            \link_list(uni_field_subject_to_course_name(MyUni, MyField, MySubject), Path)
        ])
    ).

