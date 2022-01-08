{ config, pkgs, ...}: rec {

    networking = {
        networkmanager.enable = true;

        extraHosts = ''
        10.30.10.10 gitlab.wn-cz.local
        10.30.0.63 jira.wn-cz.local
        10.30.0.69 confluence.wn-cz.local
        '';

        firewall = {
            enable = true;
            allowedTCPPorts = [ 17500 ];
            # 5678 - Cisco Discovery Protocol
            # 20561 - MAC Telnet
            allowedUDPPorts = [ 17500 5678 ];
        };
    };
}