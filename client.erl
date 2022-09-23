-module(client).
-import(string,[concat/2]).
-export([generate_server/1, start_client/1, connect_to_server/1, client_worker/1, spawn_processes_client/7,start/0]).

generate_server(Ipaddress) ->
    MName = string:concat("node1@",Ipaddress),
    string:to_atom(MName).
    
start_client(Ip_address) ->
    ClientName=generate_server(Ip_address),
    {ok,Clientpid}=start(),
    ClientNode = node(),
    erlang:set_cookie(ClientNode,'bitcoin_cookie12'),
    Tuple={ClientNode,Ip_address}.

connect_to_server(Tuple) ->
    global:sync(),
    global:whereis_name(server),{getWorkload,self,element(1,Tuple)},
    client_worker(element(1,Tuple)).

client_worker(Name) ->
    process_flag(trap_exit, true),
        receive
            {workload,K,Start_value,End_value,Workload,NoOfWorkers} -> 
                spawn_processes_client(K,Start_value,End_value,0,Workload,NoOfWorkers,self);

            {getnew,Clientprocesspid} -> 
                global:whereis_name(server) ! {getClientWorkload,self,clientprocesspid};

            {newClientWorkload,K,Start_value,End_value,ClientProcessId}-> 
                ClientProcessId ! {sendnew,K,Start_value,End_value,self};
            
            {badarg,_value} -> exit(exception)

            end,
            client_worker(Name).

spawn_processes_client(K,Start_value,End_value,StartValue,Workload,Workers,ClientId) ->
        Times=erlang:system_info(logical_processors)*1,
        Start=StartValue,
        if 
        Start<Times ->
            spawn(node(), server, bitcoin,[K,Start_value,End_value,ClientId]);
        true ->
            io:format("")
    end.
        

start() ->
    gen_server:start_link({local, server}, server, [], []).
