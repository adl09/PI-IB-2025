Es esquema de 3 VM en zmq_samples usando VirtQueues es muy ineficiente.

# Tenemos esto:
# iperf3 -c 192.168.1.3
[   46.489145] random: iperf3: uninitialized urandom read (37 bytes read)
Connecting to host 192.168.1.3, port 5201
Accepted connection from 192.168.1.1, port 38780
[   46.736942] random: iperf3: uninitialized urandom read (131072 bytes read)
[  5] local 192.168.1.3 port 5201 connected to 192.168.1.1 port 38790
[   46.521484] random: iperf3: uninitialized urandom read (131072 bytes read)
[  5] local 192.168.1.1 port 38790 connected to 192.168.1.3 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.01  [ ID] Interval           Transfer     Bitrate
[  5]   0.00-1.00   sec  4.02 MBytes  33.7 sec  4.10 MBytes  34.1 Mbits/sec   30   53.7 KBytes       
 Mbits/sec                  
[  5]   1.01-2.01   sec  3.92 MBytes  32.9 Mbits/sec   15   65.0 KBytes       
[  5]   1.00-2.00   sec  4.01 MBytes  33.6 Mbits/sec                  
[  5]   2.01-3.02   sec  4.19 MBytes  34.8 Mbits/sec    5   82.0 KBytes       
[  5]   2.00-3.00   sec  5.13 MBytes  43.1 Mbits/sec                  
[  5]   3.02-4.01   sec  4.25 MBytes  36.1 Mbits/sec   12   43.8 KBytes       
[   50.843678] random: crng init done
[  5]   3.00-4.00   sec  4.93 MBytes  41.3 Mbits/sec                  
[  5]   4.01-5.05   sec  3.89 MBytes  31.2 Mbits/sec    1   79.2 KBytes       
[  5]   4.00-5.01   sec  5.14 MBytes  42.9 Mbits/sec                  
[  5]   5.05-6.03   sec  4.08 MBytes  35.2 Mbits/sec   17   56.6 KBytes       
[  5]   5.01-6.01   sec  4.56 MBytes  38.2 Mbits/sec                  
[  5]   6.03-7.02   sec  4.13 MBytes  34.9 Mbits/sec   16   66.5 KBytes       
[  5]   6.01-7.01   sec  4.10 MBytes  34.4 Mbits/sec                  
[  5]   7.02-8.03   sec  3.89 MBytes  32.2 Mbits/sec   22   55.1 KBytes       
[  5]   8.03-9.00   sec  4.01 MBytes  34.8 Mbits/sec   14   46.7 KBytes       
[  5]   7.01-8.01   sec  4.53 MBytes  38.0 Mbits/sec                  
[  5]   8.01-8.88   sec  3.97 MBytes  38.3 Mbits/sec                  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-8.88   sec  40.4 MBytes  38.2 Mbits/sec                  receiver
[  5]   9.00-10.01  sec  4.12 MBytes  34.3 Mbits/sec   15   55.1 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.01  sec  40.6 MBytes  34.0 Mbits/sec  147             sender
[-----------------------------------------------------------
Server listening on 5201 (test #2)
------------  5]   0.00-8.88   sec  40.4 MBytes  38.2 Mbits/sec                  receiver

iperf Done.
# -----------------------------------------------
# iperf3 -c 192.168.1.3 -u
Connecting to host 192.168.1.3, port 5201
Accepted connection from 192.168.1.1, port 38802
[   60.090252] random: iperf3: uninitialized urandom read (1448 by[  5] local 192.168.1.1 port 48834 connected to 192.168.1.3 port 5201
tes read)
[  5] local 192.168.1.3 port 5201 connected to 192.168.1.1 port 48834
[ ID] Interval           Transfer     Bitrate         Jitter    Lost/Total Datag[ ID] Interval           Transfer     Bitrate         Total Datagrams
rams
[  5]   0.00-1.00   sec   129 KBytes  1.05 Mbits/sec  0.629 ms  0/91 (0%)  
[  5]   0.00-1.01   sec   129 KBytes  1.04 Mbits/sec  91  
[  5]   1.00-2.00   sec   127 KBytes  1.04 Mbits/sec  0.473 ms  0/90 (0%)  
[  5]   1.01-2.01   sec   127 KBytes  1.05 Mbits/sec  90  
[  5]   2.00-3.00   sec   129 KBytes  1.06 Mbits/sec  0.706 ms  0/91 (0%)  
[  5]   2.01-3.01   sec   129 KBytes  1.05 Mbits/sec  91  
[  5]   3.01-4.00   sec   129 KBytes  1.06 Mbits/sec  91  
[  5]   3.00-4.00   sec   129 KBytes  1.05 Mbits/sec  0.530 ms  0/91 (0%)  
[  5]   4.00-5.01   sec   127 KBytes  1.03 Mbits/sec  90  
[  5]   4.00-5.00   sec   127 KBytes  1.04 Mbits/sec  1.049 ms  0/90 (0%)  
[  5]   5.01-6.01   sec   129 KBytes  1.05 Mbits/sec  91  
[  5]   5.00-6.01   sec   130 KBytes  1.06 Mbits/sec  1.034 ms  0/92 (0%)  
^C[  5]   6.01-6.49   sec  62.2 KBytes  1.05 Mbits/sec  44  
- - - - -[  5]   5.00-6.01   sec   130 KBytes  1.06 Mbits/sec  1.034 ms  0/92 (0%)  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Jitter    Lost/Total Datagrams
[  5]   0.00-6.49   sec   831 KBytes  1.05 Mbits/sec  0.000 ms  2525440770048/0 (-1.3e-41%)  ��D
[  5]   0.00-6.49   sec  0.00  Interval           Transfer     Bitrate         Jitter    Lost/Total Datagrams
[  5]   0.00-6.01   sec   831 KBytes  1.13 Mbits/sec  0.809 ms  0/588 (0%)  receiver
iperf3: the client has terminated



Propongo estudiar el uso de dataports y memoria compartida:
- VM0 y VM1 comparten un buffer donde uno agrega paquetes a la cola y otro los quita.
- Esto también entre VM0 y VM2, VM1 y VM2.
