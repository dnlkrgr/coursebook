:- module(handlers,[]).


:- ensure_loaded(courses).

:- use_module(library(http/http_server)).
:- use_module(library(http/http_authenticate)).


:- http_handler(/, home_handler(Method), [method(Method), methods([get])]).
:- http_handler(root(signin),
                signin_handler(Method),
                [method(Method), methods([get])]).
:- http_handler(root(signup),
                signup_handler(Method),
                [method(Method), methods([get, post])]).
:- http_handler(root(completed),
                completed_handler(Method),
                [method(Method), methods([get])]).
:- http_handler(root(available),
                available_handler(Method),
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
                course_handler(Method,
                               MyUni,
                               MyField,
                               MySubject,
                               MyCourse),
                [method(Method), methods([get, post])]).


home_handler(get, Request) :-
    check_if_signed_in(Request),
    reply_html_page(
        title('Coursebook'), 
        div([
            h1('Listed Universities:'),
            \link_list(university, 'university/'),
            h2('Completed Courses:'),
            a(href('/completed'), p('Completed')),
            h2('Available Courses:'),
            a(href('/available'), p('Available'))
        ])
    ).

check_if_signed_in(Request) :-
    http_authenticate(basic(passwd), Request, _) 
    ; http_redirect(moved, root(signup), _).
    
signin_handler(get, Request) :-
    (http_authenticate(basic(passwd), Request, _) 
    ; throw(http_reply(authorise(basic, _)))),
    http_redirect(moved, '/', _).

signup_handler(get, _) :-
    reply_html_page(
        title('Sign Up'), 
        div([
            a(href('/signin'), p('Sign In')),
            h1('Sign Up'),
            form([method('post')], 
                [input([name(user_name), type(text)]), 
                input([name(password), type(password)]), 
                input([value('Submit'), type(submit)])])
        ])
    ).
signup_handler(post, Request) :-
    http_parameters(Request, [user_name(Username, []), password(InputPassword, [])]),
    crypt(InputPassword, EncPassword),
    string_codes(Password, EncPassword),
    FilePath = passwd,
    http_read_passwd_file(FilePath, Data),
    http_write_passwd_file(FilePath, [passwd(Username, Password, []) | Data]),
    http_redirect(moved, root(signin), _).

university_handler(get, MyUni, Request) :-
    check_if_signed_in(Request),
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

subject_handler(get, MyUni, MyField, MySubject, Request) :-
    check_if_signed_in(Request),
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

link_list(Predicate, Path) -->
	{
      findall(X, call(Predicate, X), Todos),
      maplist(as_a_li(Path), Todos, ListTodos)
	},
	html(ul(ListTodos)).

as_a_li(Path, X, li(Temp2)) :-
    atom_concat(Path, X, Temp1),
    Temp2 = a(href(Temp1), p(X)).

completed_handler(get, Request) :-
    check_if_signed_in(Request),
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



available_handler(get, Request) :-
    check_if_signed_in(Request),
    reply_html_page(
        title('available Courses'), 
        div([
            p('Your Available Courses:'),
            \available_list
        ])
    ).


% RENDERING HTML
available_list -->
	{
      findall(X, is_available(X), Todos),
      maplist(as_li, Todos, ListTodos)
	},
	html(ul(ListTodos)).