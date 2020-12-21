:- (multifile prolog:message//1).

% - nur die Kurse zum Studiengang anzeigen

% TODO: Praktika und Seminare zusammen duerfen nicht mehr als 18 Punkte sein

% TODO: vllt auch noch Pruefungsordnung
university(karlsruher_institute_of_technology).
field_of_study(computer_science_master).
semester(winter_semester).

vertiefungsfach(compiler_und_softwaretechnik).
vertiefungsfach(kognitive_systeme_und_robotik).

completed(neuronale_netze).
completed(neuronale_netze_praktikum).
completed(neuronale_netze_seminar).
completed(sicherheit).
completed(kognitive_systeme).
completed(telematik).
completed(mensch_maschine_interaktion).


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
course(karlsruher_institute_of_technology, computer_science_master, sommer_semester, patentrecht, recht, [], 3, ergaenzungsfach).

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
    field_of_study(FieldOfStudy),
    vertiefungsfach(Vertiefungsfach),
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
    findall(Course, vertiefungsfach(Course), Vertiefungsfaecher),
    length(Vertiefungsfaecher, L),
    print_message(error, vertiefungsfaecher-L-Min-Max),
    L>=Min,
    L=<Max.

genug_stammmodule(Min, Max) :-
    findall(Course,
            completed_course(Course, _, stammmodul),
            Stammmodule),
    length(Stammmodule, L),
    print_message(error, stammmodule-L-Min-Max),
    L>=Min,
    L=<Max.

randbedingung(KursTyp, N1, N2) :-
    findall(Punkte,
            completed_course(_, Punkte, KursTyp),
            Punktzahlen),
    sum_list(Punktzahlen, Summe),
    print_message(error, KursTyp-Summe-N1-N2),
    Summe>=N1,
    Summe=<N2.

my_course(Semester, Course, Prerequisites, Credits, CourseType) :-
    university(University),
    field_of_study(FieldOfStudy),
    course(University,
           FieldOfStudy,
           Semester,
           _,
           Course,
           Prerequisites,
           Credits,
           CourseType).

completed_course(Course, Credits, CourseType) :-
    my_course(_, Course, _, Credits, CourseType),
    completed(Course).

% ein Course ist belegbar:
% - falls er nicht schon completed worden ist
% - falls alle Voraussetzungen Kurse sind
% - und diese completed wurden
is_takeable(Course) :-
    my_course(_, Course, Prerequisites, _, _),
    \+ completed(Course),
    forall(member(X, Prerequisites), completed(X)).


prolog:message(KursTyp-L-Min-_) -->
    { L<Min,
      Rest is Min-L
    },
    ['Zu wenige Punkte in ~w; ~d fehlen noch'-[KursTyp, Rest]].
prolog:message(KursTyp-L-_-Max) -->
    { L>Max,
      Rest is L-Max
    },
    ['Zu viele Punkte in ~w; ~d zu viel'-[KursTyp, Rest]].
prolog:message(KursTyp-Summe-N1-_) -->
    { Summe<N1,
      Rest is N1-Summe
    },
    ['Zu wenige Punkte in ~w; ~d Punkte fehlen noch'-[KursTyp, Rest]].
prolog:message(KursTyp-Summe-_-N2) -->
    { Summe>N2,
      Rest is Summe-N2
    },
    ['Zu viele Punkte in ~w; ~d Punkte zu viel'-[KursTyp, Rest]].
prolog:message(_-_-_-_) -->
    [].
prolog:message(_-_) -->
    [].