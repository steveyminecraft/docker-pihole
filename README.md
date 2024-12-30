Role Name
=========

A simple role to allow for deployment pihole docker container to a host

Requirements
------------

This anisble role requires docker and docker compose to be installed on the host before deployment I recommend geerlingguy.docker to be used 

Role Variables
--------------

    dir_loc: '/opt/pihole' # installation location of the files for the container and the compose file
    firewall_deploy: true # set to false if you do not want or use firewalld
    firewall_itmes:
      - dns
      - http
      - https
    pihole_image: "pihole/pihole:2024.07.0" # current version of Pihole, set to latest if you want the newist version at all times
    timezone: "Europe/London" # Select your local timezone
    firewall_deploy: true # will ensure firewalld is install and configured
    pihole_container_name: pihole

    For full detials about the containers vars please see https://github.com/pi-hole/docker-pi-hole
    pihole_environment_variables:
      TZ: "{{ timezone }}"
      FTLCONF_MAXDBDAYS: "180"
      WEBPASSWORD: 'Intranet' # example value, change it and better use ansible-vault
      PIHOLE_DNS_: "1.1.1.1;2606:4700:4700::1111"
      REV_SERVER: "true"
      REV_SERVER_CIDR: "192.168.56.0/24"
      REV_SERVER_TARGET: "192.168.56.1"
      REV_SERVER_DOMAIN: "test"
      DHCP_ACTIVE: false
      PIHOLE_DOMAIN: 'test'
      WEBTHEME: "default-darker"

Dependencies
------------

geerlingguy.docker

Example Playbook
----------------

Simeple example playbook is as follows

    - hosts: dns-servers
      vars:
        dir_loc: '/opt/pihole'
        firewall_deploy: true
        firewall_itmes:
          - dns
          - http
          - https
        pihole_image: "pihole/pihole:2024.07.0"
        timezone: "Europe/London"
        firewall_deploy: true # will ensure firewalld is install and configured
        pihole_container_name: pihole
        pihole_environment_variables:
          TZ: "{{ timezone }}"
          FTLCONF_MAXDBDAYS: "180"
          WEBPASSWORD: 'Intranet' # example value, change it and better use ansible-vault
          PIHOLE_DNS_: "1.1.1.1;2606:4700:4700::1111"
          REV_SERVER: "true"
          REV_SERVER_CIDR: "192.168.56.0/24"
          REV_SERVER_TARGET: "192.168.56.1"
          REV_SERVER_DOMAIN: "test"
          DHCP_ACTIVE: false
          PIHOLE_DOMAIN: 'test'
          WEBTHEME: "default-darker"

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
