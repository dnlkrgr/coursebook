:- module(course,[]).

:- use_module(library(http/http_server)).
:- use_module(library(http/http_authenticate)).

:- use_module('../util/courses').
:- use_module('../util/util').

:- http_handler(root(university/MyUni/field/MyField/subject/MySubject/course/MyCourse),
                course_handler(Method,
                               MyUni,
                               MyField,
                               MySubject,
                               MyCourse),
                [method(Method), methods([get, post])]).

course_handler(get, MyUni, MyField, MySubject, CourseName, Request) :-
    check_if_signed_in(Request),
    atom_concat('Course - ', CourseName, Title),
    course(MyUni, MyField, Semester, MySubject, CourseName, Requirements, Credits, CourseType),
    reply_html_page(
        title(Title), 
        div([
            h1('Course Info:'),
            b(p('Semester:')),
            p(Semester),
            b(p('Requirements:')),
            p(Requirements),
            b(p('Credits:')),
            p(Credits),
            b(p('Course Type:')),
            p(CourseType),
            form([method('post')], [input([value('Completed'), type(submit)])])
        ])
    ).

course_handler(post, _, _, _, CourseName, _) :-
    \+ completed(CourseName),
    assert_completed(CourseName),
    http_redirect(moved, '/', _).
course_handler(post, _, _, _, _, _) :-
    http_redirect(moved, '/', _).
