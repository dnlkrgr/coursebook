:- module(subject, []).


:- use_module(library(http/http_server)).
:- use_module(library(http/http_authenticate)).

:- use_module('../util/courses').
:- use_module('../util/util').

:- http_handler(root(university/MyUni/field/MyField/subject/MySubject),
                subject_handler(Method, MyUni, MyField, MySubject),
                [method(Method), methods([get, post])]).


subject_handler(get, MyUni, MyField, MySubject, Request) :-
    check_if_signed_in(Request, _),
    atom_concat(MySubject, '/course/', Path),
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
            form([action('/addcourse'), method('post')], 
                [p('Choose a Semester'), 
                input([id(summer_semester), name(semester), type(radio)]), 
                label(for(summer_semester), value('Summer Semester')),
                br(_),
                input([id(winter_semester), name(semester), type(radio)]), 
                label(for(winter_semester), value('Winter Semester')),
                br(_),
                p('Course Name'), input([name(course_name)]),
                p('Credits'), input([name(course_credits), type(number)]),
                p('Choose the Course Type'), 
                input([id(vorlesung), name(course_type), type(radio)]),  % vorlesung, sq, praktikum
                label(for(vorlesung), value('Vorlesung')),
                br(_),
                input([id(praktikum), name(course_type), type(radio)]),  % vorlesung, sq, praktikum
                label(for(praktikum), value('Praktikum')),
                br(_),
                input([id(schluesselqualifikation), name(course_type), type(radio)]),  % vorlesung, sq, praktikum
                label(for(schluesselqualifikation), value('Schlüsselqalifikation')),
                br(_),
                p('Prerequisites'), 
                \prereqs(MyUni, MyField, MySubject),
                input([value('Submit'), type(submit)])])

%course(_, _, sommer_semester, compiler_und_softwaretechnik, compiler_und_sprachtechnologie, [], 8, vorlesung).
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
      findall(N, course(MyUni, MyField, _, MySubject, N, _, _, _), CourseNames),
      maplist(make_checkbox, CourseNames, NestedCheckBoxes),
      flatten(NestedCheckBoxes, CheckBoxes)
    },
    html(CheckBoxes).

make_checkbox(N, [input([id(N), name(course_prereq), type(checkbox)]), label(for(N), value(N)), br(_)]).