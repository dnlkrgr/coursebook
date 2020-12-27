:- module(signup,[]).


:- use_module(library(http/http_server)).
:- use_module(library(http/http_authenticate)).

:- use_module('../util/courses').
:- use_module('../util/util').


:- http_handler(root(signup),
                signup_handler(Method),
                [method(Method), methods([get, post])]).

signup_handler(get, _) :-
    reply_html_page(
        title('Sign Up'), 
        div([
            a(href('/signin'), p('Sign In')),
            h1('Sign Up'),
            form([method('post')], 
                [p('Username'), input([name(user_name), type(text)]), 
                p('Password'), input([name(password), type(password)]), 
                input([value('Submit'), type(submit)])])
        ])
    ).
% TODO: check if username exists already
signup_handler(post, Request) :-
    http_parameters(Request, [user_name(Username, []), password(InputPassword, [])]),
    crypt(InputPassword, EncPassword),
    string_codes(Password, EncPassword),
    FilePath = passwd,
    http_read_passwd_file(FilePath, Data),
    \+ member(passwd(Username, Password, []), Data),
    http_write_passwd_file(FilePath, [passwd(Username, Password, []) | Data]),
    http_redirect(moved, root(signin), _).
