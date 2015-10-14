% vim: sw=4 ts=4 et
-module(nitrogen_dev).
-export([
    command/1,
    help/0,
    compile/0,
    page/1,
    action/1,
    element/1
]).

help() ->
    Message = [
        "   ---------------------------------------------------------",
        "                 Nitrogen Developer Utility",
        "   ---------------------------------------------------------",
        "   ",
        "   nitrogen_dev:compile()",
        "     - Recompile changed files on a running Nitrogen system.",
        "   ",
        "   nitrogen_dev:page(Name)",
        "     - Create a new page with the specified name.",
        "   ",
        "   nitrogen_dev:action(Name)",
        "     - Create a new action with the specified name.",
        "   ",
        "   nitrogen_dev:element(Name)",
        "     - Create a new element with the specified name.",
        "   ",
        "   nitrogen_dev:help()",
        "     - This screen."
    ],
    [io:format("~s~n", [X]) || X <- Message],
    ok.

compile() ->
    command(["compile"]).

page(Name) ->
    command(["page", wf:to_list(Name)]).

action(Name) ->
    command(["action", wf:to_list(Name)]).

element(Name) ->
    command(["element", wf:to_list(Name)]).
    

command([]) ->
    Message = [
        "   ---------------------------------------------------------",
        "                 Nitrogen Developer Utility",
        "   ---------------------------------------------------------",
        "   ",
        "   ./bin/dev compile",
        "     - Recompile changed files on a running Nitrogen system.",
        "   ",
        "   ./bin/dev page <name>",
        "     - Create a new page with the specified name.",
        "   ",
        "   ./bin/dev action <name>",
        "     - Create a new action with the specified name.",
        "   ",
        "   ./bin/dev element <name>",
        "     - Create a new element with the specified name.",
        "   ",
        "   ./bin/dev help",
        "     - This screen."
    ],
    [io:format("~s~n", [X]) || X <- Message];

command(["compile"]) ->
    sync:go();

command(["page", Name]) ->
    Filename = filename:join([".", "src", Name ++ ".erl"]),
    Template = filename:join([os:getenv("HOME"), ".nitrogen", "prototypes",  "page.erl"]),
    case filelib:is_file(Filename) of
        true -> 
            io:format("File already exists: " ++ Filename ++ "!\n");
        false ->
            Contents = template(Template, Name),
            file:write_file(Filename, Contents),
            io:format("Created page: " ++ Filename ++ "\n"),
            io:format("Remember to recompile!~n")
    end;    

command([Type, Name]) when Type == "action";
                           Type == "element" ->
    {Filename, Template} = get_paths(Name, Type),
    case filelib:is_file(Filename) of
        true -> 
            io:format("File already exists: " ++ Filename ++ "!\n");
        false ->
            Contents = template(Template, Name),
            file:write_file(Filename, Contents),
            io:format("Created " ++ Type ++ ": " ++ Filename ++ "\n"),
            io:format("Remember to recompile!~n")
    end;    

command(["help"|_]) ->
    command([]);

command(Other) ->
    io:format("ERROR: Unknown command: ~p~n~n", [Other]),
    command([]).

template(Template, Name) ->
    {ok, B} = file:read_file(Template),
    replace_name(binary_to_list(B), Name).

replace_name(S, Name) ->
    case S of
        "[[[NAME]]]" ++ Rest -> 
            [Name|replace_name(Rest, Name)];
        [H|T] ->
            [H|replace_name(T, Name)];
        [] ->
            []
    end.

get_paths(Name, Type) ->
    Filename = filename:join([".", "src", Type ++ "s", Type ++ "_" ++ Name ++ ".erl"]),
    Template = filename:join([os:getenv("HOME"), ".nitrogen", "prototypes", Type ++ ".erl"]),
    io:format("Template: ~p, File: ~p~n", [Template, Filename]),
    {Filename, Template}.
