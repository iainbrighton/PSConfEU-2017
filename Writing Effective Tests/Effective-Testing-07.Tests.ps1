<#
    Usage: ping [-t] [-a] [-n count] [-l size] [-f] [-i TTL] [-v TOS]
                [-r count] [-s count] [[-j host-list] | [-k host-list]]
                [-w timeout] [-R] [-S srcaddr] [-c compartment] [-p]
                [-4] [-6] target_name

    Options:
        -t             Ping the specified host until stopped.
                    To see statistics and continue - type Control-Break;
                    To stop - type Control-C.
        -a             Resolve addresses to hostnames.
        -n count       Number of echo requests to send.
        -l size        Send buffer size.
        -f             Set Don't Fragment flag in packet (IPv4-only).
        -i TTL         Time To Live.
        -v TOS         Type Of Service (IPv4-only. This setting has been deprecated
                    and has no effect on the type of service field in the IP
                    Header).
        -r count       Record route for count hops (IPv4-only).
        -s count       Timestamp for count hops (IPv4-only).
        -j host-list   Loose source route along host-list (IPv4-only).
        -k host-list   Strict source route along host-list (IPv4-only).
        -w timeout     Timeout in milliseconds to wait for each reply.
        -R             Use routing header to test reverse route also (IPv6-only).
                    Per RFC 5095 the use of this routing header has been
                    deprecated. Some systems may drop echo requests if
                    this header is used.
        -S srcaddr     Source address to use.
        -c compartment Routing compartment identifier.
        -p             Ping a Hyper-V Network Virtualization provider address.
        -4             Force using IPv4.
        -6             Force using IPv6.
#>

Describe 'Stubbing executables' {

    Context 'Standard implementation' {

        It 'Calls native command' {
            $result = ping 127.0.0.1 -n 1

            $result -match 'Reply from 127.0.0.1' | Should Be $true
        }

        It 'Calls native command' {
            $result = PING.EXE 127.0.0.1 -n 1

            $result -match 'Reply from 127.0.0.1' | Should Be $true
        }
    } #end Context

    Context 'is possible to hide executables' {

        It 'Calls our implmentation' {
            Mock PING.EXE { return 'Reply from outer space...' }

            $result = ping.exe 127.0.0.1 -n 1

            $result -match 'outer space' | Should Be $true
        }

        It 'Calls our implmentation' {
            Mock PING { return 'Reply from outer space...' }

            $result = ping.exe 127.0.0.1 -n 1

            $result -match 'outer space' | Should Be $true
        }
    } #end Context

    Context 'must call using full command' {
        
        It 'Does not call our implmentation' {
            Mock PING { return 'Reply from outer space...' }

            $result = PING 127.0.0.1 -n 1

            $result -match 'outer space' | Should Be $true
        }
    }
} #end Describe
