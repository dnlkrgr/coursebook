:- module(courses, [course/8, assert_course/8, assert_university/1, has_subject/2, assert_has_subject/2, has_field/2, assert_has_field/2, completed/2, assert_completed/2, goes_to/2, assert_goes_to/2, university/1, field_of_study/2, subject/2, course_name/1]).


:- use_module(library(persistency)).

:- initialization(init).

init:-
  absolute_file_name('../data/coursebook.db', File, [access(write)]),
  db_attach(File, []).


:- persistent completed(user_name:atom, course_name:atom).
:- persistent goes_to(user_name:atom, university:atom).
:- persistent has_field(user_name:atom, field:atom).
:- persistent has_subject(user_name:atom, subject:atom).
:- persistent university(university_name:atom).
:- persistent course(university_name:atom
                    , field_name:atom
                    , subject_name:atom
                    , semester:atom
                    , course_type:atom
                    , course_name:atom
                    , prerequisites:list(atom)
                    , credits:atom).


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
course(karlsruher_institute_of_technology, computer_science_master, compiler_und_softwaretechnik, sommer_semester, vorlesung, compiler_und_sprachtechnologie, [], 8).
course(karlsruher_institute_of_technology, computer_science_master, compiler_und_softwaretechnik, winter_semester, praktikum,  compilerpraktikum, [compiler_und_sprachtechnologie], 6).
course(karlsruher_institute_of_technology, computer_science_master, kognitive_systeme_und_robotik, sommer_semester, vorlesung,  neuronale_netze, [], 6).
course(karlsruher_institute_of_technology, computer_science_master, kognitive_systeme_und_robotik, winter_semester, praktikum,  neuronale_netze_praktikum, [neuronale_netze], 6).
course(karlsruher_institute_of_technology, computer_science_master, kognitive_systeme_und_robotik, winter_semester, seminar,  neuronale_netze_seminar, [neuronale_netze], 3).
course(karlsruher_institute_of_technology, computer_science_master, kognitive_systeme_und_robotik, sommer_semester, stammmodul,  kognitive_systeme, [], 6).
course(karlsruher_institute_of_technology, computer_science_master, kryptographie, sommer_semester, stammmodul,  sicherheit, [], 6).
course(karlsruher_institute_of_technology, computer_science_master, telematik, winter_semester, stammmodul,  telematik, [], 6).
course(karlsruher_institute_of_technology, computer_science_master, mensch_maschine_interaktion, sommer_semester,  mensch_maschine_interaktion, stammmodul, [], 6).
course(karlsruher_institute_of_technology, computer_science_master, sprache,  _,                    schluesselqualikation, chinesisch, [], 2).
course(karlsruher_institute_of_technology, computer_science_master, sprache,  _,                    schluesselqualikation, japanisch, [], 2).
course(karlsruher_institute_of_technology, computer_science_master, recht,    winter_semester,      ergaenzungsfach, urheberrecht, [], 3).
course(karlsruher_institute_of_technology, computer_science_master, recht,    winter_semester,      ergaenzungsfach, markenrecht, [], 3).
course(karlsruher_institute_of_technology, computer_science_master, recht,    sommer_semester,      ergaenzungsfach, patentrecht, [], 3).

course_name(N) :-
    course(_, _, _, _, N, _, _, _).

% % RULES
% studienstatus :-
%     genug_vertiefungsfaecher(2, 2),
%     genug_stammmodule(4, 4),
%     randbedingung(praktikum, 6, 15),
%     randbedingung(seminar, 3, 12),
%     randbedingung(ergaenzungsfach, 9, 18),
%     randbedingung(schluesselqualikation, 2, 6),
%     vertiefungsfaecher(10, 15, 52).

% vertiefungsfaecher(VorlesungsMinPunkte, MinPunkteGesamt, MaxPunkteGesamt) :-
%     university(University),
%     field_of_study(University, FieldOfStudy),
%     subject(FieldOfStudy, Vertiefungsfach),
%     findall(Punktzahl,
%             course(University,
%                    FieldOfStudy,
%                    _,
%                    _,
%                    Vertiefungsfach,
%                    _,
%                    Punktzahl,
%                    _),
%             Punktzahlen),
%     sum_list(Punktzahlen, PunktzahlGesamt),
%     PunktzahlGesamt>=MinPunkteGesamt,
%     PunktzahlGesamt=<MaxPunkteGesamt,
%     findall(Punktzahl,
%             course(University,
%                    FieldOfStudy,
%                    _,
%                    _,
%                    Vertiefungsfach,
%                    _,
%                    Punktzahl,
%                    vorlesung),
%             VorlesungsPunktzahlen),
%     sum_list(VorlesungsPunktzahlen, VorlesungsPunktzahlGesamt),
%     VorlesungsPunktzahlGesamt>=VorlesungsMinPunkte.


% genug_vertiefungsfaecher(Min, Max) :-
%     findall(Course, subject(_, Course), Vertiefungsfaecher),
%     length(Vertiefungsfaecher, L),
%     L>=Min,
%     L=<Max.

% genug_stammmodule(Min, Max) :-
%     findall(Course,
%             completed_course(Course, _, stammmodul),
%             Stammmodule),
%     length(Stammmodule, L),
%     L>=Min,
%     L=<Max.

% randbedingung(KursTyp, N1, N2) :-
%     findall(Punkte,
%             completed_course(_, Punkte, KursTyp),
%             Punktzahlen),
%     sum_list(Punktzahlen, Summe),
%     Summe>=N1,
%     Summe=<N2.
