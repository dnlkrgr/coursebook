:- module(handlers,[]).


:- use_module(library(http/http_dispatch)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_parameters)).

:- ensure_loaded(courses).



:- http_handler(/, home_handler(Method), [method(Method), methods([get])]).
:- http_handler(root(completed),
                completed_handler(Method),
                [method(Method), methods([get])]).
:- http_handler(root(takeable),
                takeable_handler(Method),
                [method(Method), methods([get])]).
:- http_handler(root(university/MyUni),
                university_handler(Method, MyUni),
                [method(Method), methods([get])]).
:- http_handler(root(university/MyUni/field/MyField),
                field_handler(Method, MyUni, MyField),
                [method(Method), methods([get])]).
:- http_handler(root(university/MyUni/field/MyField/subject/MySubject),   
                subject_handler(Method, MyUni, MyField, MySubject),   
                [method(Method), methods([get])]).
:- http_handler(root(university/MyUni/field/MyField/subject/MySubject/course/MyCourse),   
                course_handler(Method, MyUni, MyField, MySubject, MyCourse),   
                [method(Method), methods([get])]).



home_handler(get, _Request) :-
    reply_html_page(
        title('Coursebook'), 
        div([
            h1('Listed Universities:'),
            \link_list(university, 'university/')
        ])
    ).

university_handler(get, MyUni, Request) :-
    http_parameters(Request, []),
    atom_concat(MyUni, '/field/', Temp2),
    reply_html_page(
        title(MyUni), 
        div([
            h2(MyUni),
            h1('Fields of Study:'),
            \link_list(field_of_study(MyUni), Temp2)
        ])
    ).

field_handler(get, MyUni, MyField, _) :-
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

subject_handler(get, MyUni, MyField, MySubject, _) :-
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

uni_field_subject_to_course_name(MyUni, MyField, MySubject, CourseName) :-
    course(MyUni, MyField, _, MySubject, CourseName, _, _, _).

course_handler(get, MyUni, MyField, MySubject, MyCourse, _) :-
    atom_concat('Course - ', MyCourse, Title),
    course(MyUni, MyField, Semester, MySubject, MyCourse, Requirements, Credits, CourseType),
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
            p(CourseType)
        ])
    ).


link_list(Predicate, Path) -->
	{
      findall(X, call(Predicate, X), Todos),
      maplist(as_a_li(Path), Todos, ListTodos)
	},
	html(ul(ListTodos)).

as_a_li(Path, X, li(Temp2)) :-
    atom_concat(Path, X, Temp1),
    Temp2 = a(href(Temp1), p(X)).

completed_handler(get, _Request) :-
    reply_html_page(
        title('Completed Courses'), 
        div([
            p('Your Completed Courses:'),
            \course_list(completed)
        ])
    ).

% RENDERING HTML
course_list(Predicate) -->
	{
      findall(X, call(Predicate, X), Todos),
      maplist(as_li, Todos, ListTodos)
	},
	html(ul(ListTodos)).

as_li(X, li(X)).



takeable_handler(get, _Request) :-
    reply_html_page(
        title('Takeable Courses'), 
        div([
            p('Your Available Courses:'),
            \available_list
        ])
    ).


% RENDERING HTML
available_list -->
	{
      findall(X, is_takeable(X), Todos),
      maplist(as_li, Todos, ListTodos)
	},
	html(ul(ListTodos)).