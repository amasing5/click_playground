//Global attributes --- begin
define($in {{ in_intf }}, $in_addr {{ in_ip }}, $in_mac {{ in_mac }})
define($out {{ out_intf }}, $out_addr {{ out_ip }}, $out_mac {{ out_mac }})
//Global attributes --- end


// Shared IP input path and routing table
ip :: Strip(14)
    -> CheckIPHeader(INTERFACES $in_addr/255.255.255.0 $out_addr/255.255.255.0)
      -> rt :: StaticIPLookup(
                               $in_addr/255.255.255.0 0,
                               $out_addr/255.255.255.0 1);


// ARP responses are copied to each ARPQuerier and the host.
arpt :: Tee(2);

// Input and output paths for in
c0 :: Classifier(12/0806 20/0001, 12/0806 20/0002, 12/0800, -);
FromDevice($in , SNIFFER false, METHOD LINUX, PROMISC true) -> c0;
out0 :: Queue(200) -> todevice0 :: ToDevice($in);
c0[0] -> ar0 :: Print("Discard incoming ARP-Queries for in-if") -> Discard;
arpq0 :: ARPQuerier($in_addr, $in_mac) -> out0;
c0[1] -> arpt;
arpt[0] -> [1]arpq0;
c0[2] -> Paint(1) -> ip;
c0[3] -> Print("Discard Non-IP for in-if") -> Discard;

// Input and output paths for out
c1 :: Classifier(12/0806 20/0001, 12/0806 20/0002, 12/0800, -);
FromDevice($out , SNIFFER false, METHOD LINUX, PROMISC true) -> c1;
out1 :: Queue(200) -> todevice1 :: ToDevice($out);
c1[0] -> ar1 :: Print("Discard incoming ARP-Queries for out-if") -> Discard;
arpq1 :: ARPQuerier($out_addr, $out_mac) -> out1;
c1[1] -> arpt;
arpt[1] -> [1]arpq1;
c1[2] -> Paint(2) -> ip;
c1[3] -> Print("Discard Non-IP for out-if") -> Discard;


// Forwarding path for in interface
rt[0] -> DropBroadcasts
    -> Print("Forwarding from in interface")
    -> cp0 :: PaintTee(1)
    -> gio0 :: IPGWOptions($in_addr)
    -> FixIPSrc($in_addr)
    -> dt0 :: DecIPTTL
    -> fr0 :: IPFragmenter(1500)
    -> [0]arpq0;
dt0[1] -> ICMPError($in_addr, timeexceeded) -> rt;
fr0[1] -> ICMPError($in_addr, unreachable, needfrag) -> rt;
gio0[1] -> ICMPError($in_addr, parameterproblem) -> rt;
cp0[1] -> ICMPError($in_addr, redirect, host) -> rt;

// Forwarding path for out interface
rt[1] -> DropBroadcasts
    -> Print("Forwarding from out interface")
    -> cp1 :: PaintTee(2)
    -> gio1 :: IPGWOptions($out_addr)
    -> FixIPSrc($out_addr)
    -> dt1 :: DecIPTTL
    -> fr1 :: IPFragmenter(1500)
    -> [0]arpq1;
dt1[1] -> ICMPError($out_addr, timeexceeded) -> rt;
fr1[1] -> ICMPError($out_addr, unreachable, needfrag) -> rt;
gio1[1] -> ICMPError($out_addr, parameterproblem) -> rt;
cp1[1] -> ICMPError($out_addr, redirect, host) -> rt;
