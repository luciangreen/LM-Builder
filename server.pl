:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_session)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_files)).
:- use_module(library(http/http_json)).
:- use_module(library(readutil)).
:- use_module(library(filesex)).
:- use_module(library(lists)).
:- use_module(library(apply)).

% HTTP Route Handlers
:- http_handler(root(.), home_page, []).
:- http_handler(root(login), login_page, []).
:- http_handler(root(logout), logout_handler, []).
:- http_handler(root(issues), issues_page, []).
:- http_handler(root('issue'), view_issue, []).
:- http_handler(root(chat), chat_page, []).
:- http_handler(root(chat_query), chat_query_handler, []).
:- http_handler(root(articles), articles_page, []).
:- http_handler(root(advocates), advocates_page, []).
:- http_handler(root(actions), actions_page, []).
:- http_handler(root(profile), profile_page, []).
:- http_handler(root(edit_file), edit_file_page, []).
:- http_handler(root(save_file), save_file_handler, []).
:- http_handler(root(backup), backup_page, []).
:- http_handler(root(run_backup), run_backup_handler, []).
:- http_handler(root('static/'), http_reply_from_files('static', []), [prefix]).

% Start the server
start_server(Port) :-
    ensure_directories,
    initialize_databases,
    http_server(http_dispatch, [port(Port)]).

% Ensure required directories exist
ensure_directories :-
    make_directory_path('issues'),
    make_directory_path('articles'),
    make_directory_path('advocates'),
    make_directory_path('actions'),
    make_directory_path('profiles'),
    make_directory_path('databases'),
    make_directory_path('static'),
    make_directory_path('backups').

% Initialize databases if they don't exist
initialize_databases :-
    ensure_database('databases/keywords.pl', 'keyword'),
    ensure_database('databases/issues.pl', 'issue'),
    ensure_database('databases/advocates.pl', 'advocate'),
    ensure_database('databases/actions.pl', 'action').

ensure_database(Path, Type) :-
    (exists_file(Path) -> true ;
     open(Path, write, Stream),
     format(Stream, '%% ~w database~n', [Type]),
     close(Stream)).

% Home Page
home_page(_Request) :-
    reply_html_page(
        title('Issue Examination CRM'),
        [h1('Issue Examination CRM'),
         p('Welcome to the Issue Examination CRM system.'),
         h2('Navigation'),
         ul([
             li(a(href='/issues', 'View Issues')),
             li(a(href='/chat', 'Chat Interface')),
             li(a(href='/articles', 'Articles')),
             li(a(href='/advocates', 'Advocates')),
             li(a(href='/actions', 'Actions')),
             li(a(href='/profile', 'Profiles')),
             li(a(href='/edit_file', 'Edit Files')),
             li(a(href='/login', 'Login (Admin)'))
         ])
        ]).

% Login Page
login_page(Request) :-
    (memberchk(method(post), Request) ->
        handle_login(Request)
    ;
        show_login_form).

show_login_form :-
    reply_html_page(
        title('Login'),
        [h1('Admin Login'),
         form([action='/login', method='POST'], [
             label('Password: '),
             input([type=password, name=password]),
             br([]),
             input([type=submit, value='Login'])
         ])
        ]).

handle_login(Request) :-
    http_parameters(Request, [password(Password, [])]),
    (Password = 'admin' ->  % Default admin password
        http_session_assert(user_level(admin)),
        reply_html_page(title('Login Success'), [
            h1('Login Successful'),
            p('You are now logged in as admin.'),
            a(href='/', 'Return to Home')
        ])
    ;
        reply_html_page(title('Login Failed'), [
            h1('Login Failed'),
            p('Invalid password.'),
            a(href='/login', 'Try Again')
        ])
    ).

% Logout Handler
logout_handler(_Request) :-
    http_session_retractall(user_level(_)),
    reply_html_page(title('Logged Out'), [
        h1('Logged Out'),
        p('You have been logged out.'),
        a(href='/', 'Return to Home')
    ]).

% Check if user is admin
is_admin :-
    catch(http_session_data(user_level(admin)), _, fail).

% Issues Page
issues_page(_Request) :-
    find_all_issues(Issues),
    reply_html_page(
        title('Issues'),
        [h1('Issues'),
         \issues_list(Issues),
         p([a(href='/', 'Back to Home')])
        ]).

issues_list(Issues) -->
    {maplist(issue_to_html, Issues, HTMLItems)},
    html(ul(HTMLItems)).

issue_to_html(Issue, li(a(href=URL, Issue))) :-
    format(atom(URL), '/issue?name=~w', [Issue]).

find_all_issues(Issues) :-
    exists_directory('issues'),
    directory_files('issues', Files),
    findall(Dir, 
            (member(Dir, Files), 
             \+ member(Dir, ['.', '..']),
             atom_concat('issues/', Dir, FullPath),
             exists_directory(FullPath)),
            Issues).

% View Issue
view_issue(Request) :-
    http_parameters(Request, [name(IssueName, [])]),
    atom_concat('issues/', IssueName, IssueDir),
    atom_concat(IssueName, '_main.md', MainFile),
    atomic_list_concat([IssueDir, '/', MainFile], MainPath),
    (exists_file(MainPath) ->
        read_file_to_string(MainPath, Content, []),
        markdown_to_html(Content, HTML),
        reply_html_page(
            title(IssueName),
            [h1(IssueName),
             \html_raw(HTML),
             p([a(href='/issues', 'Back to Issues')])
            ])
    ;
        reply_html_page(title('Error'), [
            h1('Issue Not Found'),
            p('The requested issue does not exist.'),
            a(href='/issues', 'Back to Issues')
        ])
    ).

html_raw(HTML) -->
    html(\[HTML]).

% Simple Markdown to HTML conversion
markdown_to_html(Markdown, HTML) :-
    split_string(Markdown, "\n", "", Lines),
    maplist(line_to_html, Lines, HTMLLines),
    atomic_list_concat(HTMLLines, '', HTML).

line_to_html(Line, HTML) :-
    string_concat("# ", Rest, Line), !,
    format(atom(HTML), '<h1>~w</h1>', [Rest]).
line_to_html(Line, HTML) :-
    string_concat("## ", Rest, Line), !,
    format(atom(HTML), '<h2>~w</h2>', [Rest]).
line_to_html(Line, HTML) :-
    string_concat("### ", Rest, Line), !,
    format(atom(HTML), '<h3>~w</h3>', [Rest]).
line_to_html(Line, HTML) :-
    string_concat("- ", Rest, Line), !,
    format(atom(HTML), '<li>~w</li>', [Rest]).
line_to_html("", "<br/>") :- !.
line_to_html(Line, HTML) :-
    format(atom(HTML), '<p>~w</p>', [Line]).

% Chat Page
chat_page(_Request) :-
    reply_html_page(
        title('Chat - Issue Verification'),
        [h1('Chat Interface'),
         p('Ask about issues, for example: "what about issue X"'),
         form([action='/chat_query', method='POST'], [
             label('Your question: '),
             br([]),
             textarea([name=query, rows=4, cols=50], ''),
             br([]),
             input([type=submit, value='Ask'])
         ]),
         p([a(href='/', 'Back to Home')])
        ]).

% Chat Query Handler
chat_query_handler(Request) :-
    http_parameters(Request, [query(Query, [])]),
    process_chat_query(Query, Response),
    reply_html_page(
        title('Chat Response'),
        [h1('Chat Response'),
         p(strong('Your question:')),
         p(Query),
         p(strong('Response:')),
         p(Response),
         p([a(href='/chat', 'Ask Another Question')]),
         p([a(href='/', 'Back to Home')])
        ]).

process_chat_query(Query, Response) :-
    downcase_atom(Query, LowerQuery),
    (sub_atom(LowerQuery, _, _, _, 'what about issue') ->
        extract_issue_name(LowerQuery, IssueName),
        get_issue_summary(IssueName, Response)
    ;
        Response = 'I can help you with questions about issues. Try asking "what about issue X"'
    ).

extract_issue_name(Query, IssueName) :-
    split_string(Query, " ", " ", Tokens),
    (append(_, ["issue", Name|_], Tokens) ->
        atom_string(IssueName, Name)
    ;
        IssueName = 'unknown'
    ).

get_issue_summary(IssueName, Summary) :-
    atom_concat('issues/', IssueName, IssueDir),
    atom_concat(IssueName, '_main.md', MainFile),
    atomic_list_concat([IssueDir, '/', MainFile], MainPath),
    (exists_file(MainPath) ->
        read_file_to_string(MainPath, Content, []),
        string_length(Content, Len),
        (Len > 200 ->
            sub_string(Content, 0, 200, _, Summary0),
            atom_concat(Summary0, '...', Summary)
        ;
            Summary = Content
        )
    ;
        Summary = 'Issue not found in the system.'
    ).

% Articles Page
articles_page(_Request) :-
    find_markdown_files('articles', Articles),
    reply_html_page(
        title('Articles'),
        [h1('Articles'),
         \file_list(Articles, 'articles'),
         p([a(href='/', 'Back to Home')])
        ]).

% Advocates Page
advocates_page(_Request) :-
    find_markdown_files('advocates', Advocates),
    reply_html_page(
        title('Advocates'),
        [h1('Advocates'),
         \file_list(Advocates, 'advocates'),
         p([a(href='/', 'Back to Home')])
        ]).

% Actions Page
actions_page(_Request) :-
    find_markdown_files('actions', Actions),
    reply_html_page(
        title('Actions'),
        [h1('Actions'),
         \file_list(Actions, 'actions'),
         p([a(href='/', 'Back to Home')])
        ]).

file_list(Files, _Dir) -->
    {maplist(file_to_html, Files, HTMLItems)},
    html(ul(HTMLItems)).

file_to_html(File, li(File)).

find_markdown_files(Dir, Files) :-
    (exists_directory(Dir) ->
        directory_files(Dir, AllFiles),
        findall(F, (member(F, AllFiles), sub_atom(F, _, _, 0, '.md')), Files)
    ;
        Files = []
    ).

% Profile Page
profile_page(_Request) :-
    find_profiles(Profiles),
    (is_admin -> AdminView = yes ; AdminView = no),
    reply_html_page(
        title('Profiles'),
        [h1('Profiles'),
         \profiles_list(Profiles, AdminView),
         p([a(href='/', 'Back to Home')])
        ]).

profiles_list(Profiles, AdminView) -->
    {maplist(profile_to_html(AdminView), Profiles, HTMLItems)},
    html(ul(HTMLItems)).

profile_to_html(AdminView, Profile, li(Desc)) :-
    format(atom(Desc), '~w (Contact visible to: ~w)', [Profile, AdminView]).

find_profiles(Profiles) :-
    (exists_directory('profiles') ->
        directory_files('profiles', Files),
        findall(F, (member(F, Files), \+ member(F, ['.', '..'])), Profiles)
    ;
        Profiles = []
    ).

% Edit File Page
edit_file_page(Request) :-
    (is_admin ->
        (memberchk(method(get), Request),
         http_parameters(Request, [file(FilePath, [optional(true)])], [form_data(Form)]),
         member(file=FilePath, Form) ->
            show_file_editor(FilePath)
        ;
            show_file_browser
        )
    ;
        reply_html_page(title('Access Denied'), [
            h1('Access Denied'),
            p('You must be logged in as admin to edit files.'),
            a(href='/login', 'Login')
        ])
    ).

show_file_browser :-
    reply_html_page(
        title('File Browser'),
        [h1('File Browser'),
         p('Select a file to edit:'),
         form([action='/edit_file', method='GET'], [
             label('File path: '),
             input([type=text, name=file, size=50]),
             br([]),
             input([type=submit, value='Edit File'])
         ]),
         p([a(href='/', 'Back to Home')])
        ]).

show_file_editor(FilePath) :-
    (exists_file(FilePath) ->
        read_file_to_string(FilePath, Content, [])
    ;
        Content = ''
    ),
    reply_html_page(
        title('Edit File'),
        [h1('Edit File: '), p(FilePath),
         form([action='/save_file', method='POST'], [
             input([type=hidden, name=file, value=FilePath]),
             textarea([name=content, rows=20, cols=80], Content),
             br([]),
             input([type=submit, value='Save File'])
         ]),
         p([a(href='/edit_file', 'Back to File Browser')])
        ]).

% Save File Handler
save_file_handler(Request) :-
    (is_admin ->
        http_parameters(Request, [
            file(FilePath, []),
            content(Content, [])
        ]),
        atom_string(FilePathAtom, FilePath),
        atom_string(ContentAtom, Content),
        open(FilePathAtom, write, Stream),
        write(Stream, ContentAtom),
        close(Stream),
        reply_html_page(title('File Saved'), [
            h1('File Saved'),
            p(['File ', FilePath, ' has been saved successfully.']),
            a(href='/edit_file', 'Edit Another File')
        ])
    ;
        reply_html_page(title('Access Denied'), [
            h1('Access Denied'),
            p('You must be logged in as admin to save files.')
        ])
    ).

% Backup Page
backup_page(_Request) :-
    (is_admin ->
        reply_html_page(
            title('VPS Backup'),
            [h1('VPS Backup'),
             p('Enter admin password to run backup:'),
             form([action='/run_backup', method='POST'], [
                 label('Password: '),
                 input([type=password, name=password]),
                 br([]),
                 input([type=submit, value='Run Backup'])
             ]),
             p([a(href='/', 'Back to Home')])
            ])
    ;
        reply_html_page(title('Access Denied'), [
            h1('Access Denied'),
            p('You must be logged in as admin to access backups.'),
            a(href='/login', 'Login')
        ])
    ).

% Run Backup Handler
run_backup_handler(Request) :-
    (is_admin ->
        http_parameters(Request, [password(Password, [])]),
        (Password = 'admin' ->  % Verify admin password again
            run_backup(Result),
            reply_html_page(title('Backup Complete'), [
                h1('Backup Complete'),
                p(Result),
                a(href='/backup', 'Back to Backup Page')
            ])
        ;
            reply_html_page(title('Backup Failed'), [
                h1('Backup Failed'),
                p('Invalid password.'),
                a(href='/backup', 'Try Again')
            ])
        )
    ;
        reply_html_page(title('Access Denied'), [
            h1('Access Denied'),
            p('You must be logged in as admin.')
        ])
    ).

run_backup(Result) :-
    get_time(Timestamp),
    format(atom(BackupFile), 'backups/backup_~w.tar.gz', [Timestamp]),
    format(atom(Command), 'tar -czf ~w issues articles advocates actions profiles databases', [BackupFile]),
    shell(Command),
    format(atom(Result), 'Backup created: ~w', [BackupFile]).

% Main entry point - To start the server, use:
% swipl -g "consult('server.pl'), start_server(8080)" -t 'halt'
% or run ./start_server.sh
