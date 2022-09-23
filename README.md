# Bitcoin_mining-COP5615

**Brief description:** The aim of the project is to mine bitcoins using the distributed systems. Bitcoin mining using SHA256 hashing is a heavy computational process that consumes plenty of time but by implementing actor-model framework we can split the workload and use multiple cores for faster computation. We have created eight workers each, in server as well as client machine. The total workload is divided equally among all the workers, each worker takes a random string appended to gator username and computes the SHA256 hash until it finds a hash with the required no. of leading zeroes. Let’s say, the total workload = N, so each worker receives N/8 unit of work, which they work upon asynchronously.

**Steps to Run:** 
- To run the server type run: **server:startingProg()** 
- To run the client type run: **client:start_client {server’s IP} {port}**
- k – is a command line argument that takes the no. of leading zeroes 
- Server’s IP – address of host machine
- Port – port at which server is running

**Design:** 

**Server-**

- On running server ‘ServerActor’ is created and ‘start’ message is sent to ‘boss’ actor.
- Boss actor creates multiple worker actors and divides the workload among them.
- Server actors will start the computation as well as also handle the responses coming from the client actors parallelly.
- Once the server finishes its computation and receives the message ‘client done’ from the client actor, it terminates the program.

**Client-**

- On running client ‘Boss’ actor is created, and boss ‘ServerActor’ is selected using the IP address and port entered.
- Client’s boss actor creates multiple worker actors and divides the workload among them.
- Each client actor will then perform the computation and send the generated bitcoin to server.
- Once the client’s computation is done it will send an ‘Client Done’ message to the server.

**Systems used:**

- Apple intel i7 – 8 core machines
- Apple M1 – 8 core machines

**Result:** For k = 4, with 8 cores the ratio comes out to be 2.473. This shows that the computation is being done parallelly, also with increasing the actors we notice that the ratio’s difference from 1 also increases.
