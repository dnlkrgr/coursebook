:- module(subject, []).


:- use_module(library(http/http_server)).

:- use_module('../util/courses').
:- use_module('../util/util').

:- http_handler(root(university/MyUni/field/MyField/subject/MySubject),
                subject_handler(Method, MyUni, MyField, MySubject),
                [method(Method), methods([get, post])]).

:- http_handler(root(addcourse/MyUni/MyField/MySubject),
                add_course_handler(Method, MyUni, MyField, MySubject),
                [method(Method), methods([post])]).


add_course_handler(post, MyUni, MyField, MySubject, Request) :-
    http_parameters(Request, 
        [ semester(Semester, [])
        , course_name(CourseName, [])
        , course_type(CourseType, [])
        , credits(Credits, [])
        , prerequisites(Prerequisites, [list(atom)])]),
    assert_course(MyUni, MyField, MySubject, Semester, CourseType, CourseName, Prerequisites, Credits),
    http_redirect(moved, '/', _).

subject_handler(get, MyUni, MyField, MySubject, Request) :-
    check_if_signed_in(Request, _),
    atom_concat(MySubject, '/course/', Path),
    atomic_list_concat(['/addcourse', MyUni, MyField, MySubject], '/', URL),
    reply_html_page(
        title(MySubject), 
        div([
            h4(MyUni),
            h3(MyField),
            h2(MySubject),
            form([method('post')], [input([value('Set this as my subject'), type(submit)])]),
            h1('Courses:'),
            \link_list(uni_field_subject_to_course_name(MyUni, MyField, MySubject), Path),
            h1('Add Course'),
            form([action(URL), method('post')], 
                [p('Choose a Semester'), 
                input([value(summer_semester), name(semester), type(radio)]), 
                label(for(summer_semester), value('Summer Semester')),
                br(_),
                input([value(winter_semester), name(semester), type(radio)]), 
                label(for(winter_semester), value('Winter Semester')),
                br(_),
                p('Course Name'), input([name(course_name)]),
                p('Credits'), input([name(credits), type(number)]),
                p('Choose the Course Type'), 
                input([value(vorlesung), name(course_type), type(radio)]),  % vorlesung, sq, praktikum
                label(for(vorlesung), value('Vorlesung')),
                br(_),
                input([value(praktikum), name(course_type), type(radio)]),  % vorlesung, sq, praktikum
                label(for(praktikum), value('Praktikum')),
                br(_),
                input([value(schluesselqualifikation), name(course_type), type(radio)]),  % vorlesung, sq, praktikum
                label(for(schluesselqualifikation), value('Schlüsselqalifikation')),
                br(_),
                p('Prerequisites'), 
                \prereqs(MyUni, MyField, MySubject),
                input([value('Submit'), type(submit)])])
        ])
    ).
subject_handler(post, _, _, MySubject, Request) :-
    check_if_signed_in(Request, User),
    \+ has_subject(User, MySubject),
    assert_has_subject(User, MySubject),
    http_redirect(moved, '/', _).
subject_handler(post, _, _, _, _) :-
    http_redirect(moved, '/', _).


prereqs(MyUni, MyField, MySubject) -->
    {
      findall(N, course(MyUni, MyField, MySubject, _, _, N, _, _), CourseNames),
      maplist(make_checkbox, CourseNames, NestedCheckBoxes),
      flatten(NestedCheckBoxes, CheckBoxes)
    },
    html(CheckBoxes).

make_checkbox(N, [input([value(N), name(prerequisites), type(checkbox)]), label(for(N), value(N)), br(_)]).