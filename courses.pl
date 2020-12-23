:- module(courses, [completed/1, is_available/1, university/1, field_of_study/2, course_name/1, course/8, subject/2, assert_completed/1]).


:- use_module(library(persistency)).

:- persistent completed(course_name:atom).

:- initialization(init).

init:-
  absolute_file_name('coursebook.db', File, [access(write)]),
  db_attach(File, []).

:- (multifile prolog:message//1).



% TODO: Praktika und Seminare zusammen duerfen nicht mehr als 18 Punkte sein

% TODO: vllt auch noch Pruefungsordnung
university(karlsruher_institute_of_technology).

field_of_study(karlsruher_institute_of_technology, computer_science_master).
field_of_study(karlsruher_institute_of_technology, civil_engineering).
field_of_study(karlsruher_institute_of_technology, architecture).
field_of_study(karlsruher_institute_of_technology, art_history).
semester(winter_semester).

subject(computer_science_master, compiler_und_softwaretechnik).
subject(computer_science_master, kognitive_systeme_und_robotik).



% UNI STUFF
course(karlsruher_institute_of_technology, computer_science_master, sommer_semester, compiler_und_softwaretechnik, compiler_und_sprachtechnologie, [], 8, vorlesung).
course(karlsruher_institute_of_technology, computer_science_master, winter_semester, compiler_und_softwaretechnik, compilerpraktikum, [compiler_und_sprachtechnologie], 6, praktikum).
course(karlsruher_institute_of_technology, computer_science_master, sommer_semester, kognitive_systeme_und_robotik, neuronale_netze, [], 6, vorlesung).
course(karlsruher_institute_of_technology, computer_science_master, winter_semester, kognitive_systeme_und_robotik, neuronale_netze_praktikum, [neuronale_netze], 6, praktikum).
course(karlsruher_institute_of_technology, computer_science_master, winter_semester, kognitive_systeme_und_robotik, neuronale_netze_seminar, [neuronale_netze], 3, seminar).
course(karlsruher_institute_of_technology, computer_science_master, sommer_semester, kognitive_systeme_und_robotik, kognitive_systeme, [], 6, stammmodul).
course(karlsruher_institute_of_technology, computer_science_master, sommer_semester, kryptographie, sicherheit, [], 6, stammmodul).
course(karlsruher_institute_of_technology, computer_science_master, winter_semester, telematik, telematik, [], 6, stammmodul).
course(karlsruher_institute_of_technology, computer_science_master, sommer_semester, mensch_maschine_interaktion, mensch_maschine_interaktion, [], 6, stammmodul).
course(karlsruher_institute_of_technology, computer_science_master, _, sprache, chinesisch, [], 2, schluesselqualikation).
course(karlsruher_institute_of_technology, computer_science_master, _, sprache, japanisch, [], 2, schluesselqualikation).
course(karlsruher_institute_of_technology, computer_science_master, winter_semester, recht, urheberrecht, [], 3, ergaenzungsfach).
course(karlsruher_institute_of_technology, computer_science_master, winter_semester, recht, markenrecht, [], 3, ergaenzungsfach).
course(karlsruher_institute_of_technology, computer_science_master, sommer_semester, recht, patentrecht, [], 3, ergaenzungsfach).


course_name(N) :-
    course(_, _, _, _, N, _, _, _).

% RULES
studienstatus :-
    genug_vertiefungsfaecher(2, 2),
    genug_stammmodule(4, 4),
    randbedingung(praktikum, 6, 15),
    randbedingung(seminar, 3, 12),
    randbedingung(ergaenzungsfach, 9, 18),
    randbedingung(schluesselqualikation, 2, 6),
    vertiefungsfaecher(10, 15, 52).

vertiefungsfaecher(VorlesungsMinPunkte, MinPunkteGesamt, MaxPunkteGesamt) :-
    university(University),
    field_of_study(University, FieldOfStudy),
    subject(FieldOfStudy, Vertiefungsfach),
    findall(Punktzahl,
            course(University,
                   FieldOfStudy,
                   _,
                   _,
                   Vertiefungsfach,
                   _,
                   Punktzahl,
                   _),
            Punktzahlen),
    sum_list(Punktzahlen, PunktzahlGesamt),
    PunktzahlGesamt>=MinPunkteGesamt,
    PunktzahlGesamt=<MaxPunkteGesamt,
    findall(Punktzahl,
            course(University,
                   FieldOfStudy,
                   _,
                   _,
                   Vertiefungsfach,
                   _,
                   Punktzahl,
                   vorlesung),
            VorlesungsPunktzahlen),
    sum_list(VorlesungsPunktzahlen, VorlesungsPunktzahlGesamt),
    VorlesungsPunktzahlGesamt>=VorlesungsMinPunkte.


genug_vertiefungsfaecher(Min, Max) :-
    findall(Course, subject(_, Course), Vertiefungsfaecher),
    length(Vertiefungsfaecher, L),
    L>=Min,
    L=<Max.

genug_stammmodule(Min, Max) :-
    findall(Course,
            completed_course(Course, _, stammmodul),
            Stammmodule),
    length(Stammmodule, L),
    L>=Min,
    L=<Max.

randbedingung(KursTyp, N1, N2) :-
    findall(Punkte,
            completed_course(_, Punkte, KursTyp),
            Punktzahlen),
    sum_list(Punktzahlen, Summe),
    Summe>=N1,
    Summe=<N2.

my_course(Semester, CourseName, Prerequisites, Credits, CourseType) :-
    university(University),
    field_of_study(University, FieldOfStudy),
    course(University,
           FieldOfStudy,
           Semester,
           _,
           CourseName,
           Prerequisites,
           Credits,
           CourseType).

completed_course(CourseName, Credits, CourseType) :-
    my_course(_, CourseName, _, Credits, CourseType),
    completed(CourseName).

% ein Course ist belegbar:
% - falls er nicht schon completed worden ist
% - falls alle Voraussetzungen Kurse sind
% - und diese completed wurden
is_available(Course) :-
    my_course(_, Course, Prerequisites, _, _),
    \+ completed(Course),
    forall(member(X, Prerequisites), completed(X)).