-module(server).
-export([startingProg/0,get_ip/1, is_not_localhost/1, ip_to_string/1,start_server/1]).
-export([start/0,init/1,stop_Server/0,handle_cast/2, terminate/2]).
-import(string,[concat/2]).
-export([server_listener/3, spawn_processes/7]).
-behaviour(gen_server).
-import(gen_server,[start_link/4]).
-define(Workload, 10).
-define(Worker, 8).
-define(Startvalue, 0).
-define(Endvalue, 0).

startingProg()->
    {ok, [Inp]} = io:fread("Enter Number of Zeroes : ", "~d"),
    Tuple = get_ip(Inp),
    start_server(Tuple).

get_ip(K) ->
    {ok, IpVals} = inet:getif(),
    IPTri = lists:filter((fun is_not_localhost/1), IpVals),
    IPAddresses = lists:map(fun ip_to_string/1, IPTri),
    {IPAddresses, K}.

start_server(Tuple) ->
    ShortName = lists:flatten([io_lib:format("~s", [V]) || V <- element(1, Tuple)]),
    ServerName = [list_to_atom(concat("Server@",ShortName))],
    {ok,ServerPid}=start(),
    CurrentNode = node(),
    erlang:set_cookie(CurrentNode,'bitcoin_cookie12'),
    erlang:register(CurrentNode, self()),
    Times=erlang:system_info(logical_processors)*?Worker,
    spawn_processes(element(2, Tuple),?Startvalue,?Startvalue+?Workload,Times,ServerPid,0,CurrentNode),
    server_listener(?Startvalue,?Startvalue+?Workload,element(2, Tuple)).

server_listener(Start,End,K) ->
    Times=erlang:system_info(logical_processors)*?Worker,
    receive
        {ok,Pid,Startvalue,Endvalue,K,CurrentNode} -> 
            spawn_processes(K,Startvalue,Endvalue,0,Pid,Times,CurrentNode);

        {getnewWorker,Pid,CurrentNode} -> 
            Pid ! {sendnew,K,Start,End,Times,Pid,CurrentNode};

        {found_bitcoin,StringVal,Hash} -> 
          io:format(StringVal),
          io:format("\t"),
          io:format("~64.16.0b~n~n",Hash);

        {getWorkload,ClientName,ClientPid} ->
          ClientName ! {workload,K,Start,End,?Workload,?Workload};

        {getClientWorkload,ClientPid,ClientProcessId} -> 
            ClientPid ! {newClientWorkload,K,Start,End,ClientProcessId};

       {_Reason,_Stack} ->  exit(exception)

    end,
    server_listener(Start+?Workload,End+?Workload,K).


spawn_processes(K,Start,End,Times,Pid,Startvalue,CurrentNode) ->
    Startval=Startvalue,
    if 
      Startval<Times ->
            spawn(worker, get_bit_coins, [K,Start,End,Times,Pid,CurrentNode]),
            spawn_processes(K,Start+?Workload,End+?Workload,Times,Pid,Startvalue+1,CurrentNode);
        true ->
            io:format("")
    end.

stop_Server() ->
    gen_server:cast(server,stop).

init(_Args) ->
    {ok, undefined}.

is_not_localhost({{127,0,0,1}, _Broadcast, _Mask}) -> false;
is_not_localhost({_IP, _Broadcast, _Mask})         -> true.

ip_to_string({{Ip1, Ip2, Ip3, Ip4}, _Broadcast, _Mask}) ->
    io_lib:format("~b.~b.~b.~b", [Ip1, Ip2, Ip3, Ip4]).

start() ->
    gen_server:start_link({local, server}, server, [], []).

handle_cast(stop, LoopData) ->
    {stop, normal, LoopData}.

terminate(_Reason, _LoopData) ->
    ok.