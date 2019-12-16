# Design Review

UDP/IP is a standard communication protocol, so implementations are typically evaluated on performance, area 
requirements, flexibility of use, and power consumption. The goal of a communication protocol is to be as standardized
and flexible as possible. As such, there is little room for innovation within the actual validation of transmitted or 
received packets. Instead, designers seek to produce implementations of UDP/IP that provide the highest throughput and
lowest latency. In a general sense, a UDP/IP module should enable the functionality of the rest of a design while 
consuming minimal resources and time. This also means the design should require the smallest area and power 
consumption possible. 

Although the designed UDP/IP transmitter and receiver work reliably given some input restrictions discussed above, 
there is room for improvement in the speed and efficiency of the final product. First, each of the three major 
sub-modules, CRC, ring buffer, and udp control, is designed to only process one packet at a time. For example, the UDP
control module handles gradual serial reception of a packet, UDP and IP checksum calculation, and gradual 
transmission of confirmed packet. The throughput of the UDP control module is reduced by the fact that only one packet
can be processing within the module at a time. Pipelining this design would allow for a packet to be in the process 
of being received while another packet is having UDP and IP checksum confirmed and a fourth packet is being 
transmitted, drastically increasing throughput. Implementing similar improvements to the CRC module would have a 
similar effect. 

In addition, flexibility of input packet size as well as module latency is worsened by the way packets are aggregated.
Within the CRC module, each packet is received from serial into a two-dimensional byte array to be transmitted to the 
CRC validation sub-module in parallel. Packet size is confirmed by waiting for the last byte control line to be driven
high. Also, the design does not rely on the packet length fields at all. As a result of both these facts, packet size 
is restricted by the size of the two-dimensional byte array. Additionally, latency is increased by the fact that the 
entire packet has to be received before processing can begin. I could solve this problem by avoiding aggregation of 
data into a two-dimensional byte array entirely. Instead, I could handle processing gradually as the packet is 
received while relying on the packet length fields to determine how many bytes to wait for. On the output of each 
module, I could add a FIFO (first in first out) with an enable to allow for packets to pass if data reliability is 
confirmed. This way, data aggregation would happen independent of actual processing, allowing for lower latency and 
better packet length flexibility.

## [Index](index.md)
