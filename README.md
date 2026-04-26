Role Name
=========

A simple role to deploy the Pi-hole Docker container to a host.

Requirements
------------

- Docker must be installed on the host.

Role Variables
--------------

Common variables:

    # Persistent data + docker-compose.yml location
    dir_loc: "/opt/pihole"
    pihole_compose_dir: "/opt/pihole"

    # Container settings
    pihole_image: "pihole/pihole:latest"
    pihole_container_name: "pihole"
    timezone: "Europe/London"

    # Published ports (only when NOT using host networking)
    webport_http: "80"
    webport_https: "443"

    # Host firewall (firewalld on RedHat family)
    firewall_deploy: false
    firewall_itmes:
      - dns
      - http
      - https

Pi-hole container env vars:

    # Full list: https://github.com/pi-hole/docker-pi-hole
    pihole_environment_variables:
      TZ: "{{ timezone }}"
      FTLCONF_MAXDBDAYS: "180"
      FTLCONF_webserver_api_password: "change-me"
      FTLCONF_dns_listeningMode: "all"
      DHCP_ACTIVE: false

### Rocky / EL + Vagrant bridge notes

On EL9+ guests (e.g. Rocky Linux) it is common to run Docker with `iptables: false` (or have missing xtables
matches). In that configuration Docker will not add MASQUERADE rules, and containers may not have internet
egress until NAT is configured.

This role supports that with an opt-in nftables masquerade fallback that discovers Docker network subnets
and applies NAT rules after `docker compose up` creates the project networks.

Relevant variables:

    # Must match the same variable used by the docker role.
    # When false on EL, the role will apply nftables NAT fallback after compose.
    docker_manage_iptables: "{{ not (vagrant_env | default(false) | bool) }}"
    docker_el_nat_fallback: true

For lab debugging you can bypass the bridge entirely:

    # Runs the Pi-hole container in the host network namespace (no bridge NAT).
    pihole_use_host_network: false

Optional Rocky debug mode:

    # Stops firewalld, installs dig on the host, and relaxes container confinement (lab only).
    pihole_rocky_network_debug: false

Dependencies
------------

geerlingguy.docker

Example Playbook
----------------

Simple example playbook is as follows

    - hosts: dns-servers
      vars:
        pihole_compose_dir: "/opt/pihole"
        dir_loc: "/opt/pihole"
        firewall_deploy: false
        pihole_image: "pihole/pihole:latest"
        timezone: "Europe/London"
        pihole_container_name: "pihole"
        pihole_environment_variables:
          TZ: "{{ timezone }}"
          FTLCONF_MAXDBDAYS: "180"
          FTLCONF_webserver_api_password: "change-me"
          FTLCONF_dns_listeningMode: "all"
          DHCP_ACTIVE: false

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
