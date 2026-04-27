# docker-pihole (Ansible role)

Ansible role to deploy [Pi-hole](https://pi-hole.net/) using Docker Compose on the target host. The role writes `docker-compose.yml`, pulls the image, manages optional firewalld rules, and can integrate with Unbound on a shared Docker network.

Galaxy `role_name` is **`pihole`** (`meta/main.yml`); this repository is commonly cloned as **`docker-pihole`** and referenced with `ANSIBLE_ROLES_PATH` so the role name matches the directory (see `tests/syntax-check.yml`).

## Requirements

- **Ansible**: 2.14 or newer (`meta/main.yml`).
- **Target host**: Docker Engine and **Docker Compose v2** (`docker compose` CLI). The role **does not** install Docker; install it beforehand (for example with your playbooks or another role).
- **Collections**: install from `requirements.yml` (includes `ansible.posix` and `community.docker`), for example:

  ```bash
  ./scripts/install-ansible-collections.sh
  ```

`meta/main.yml` declares **`dependencies: []`**; there is no hard Galaxy role dependency, only the collections above.

## Role variables

Authoritative defaults are in [`defaults/main.yml`](defaults/main.yml). Commonly overridden values:

| Variable | Purpose |
|----------|---------|
| `dir_loc` | Root for persistent data (`etc/pihole`, `etc/dnsmasq.d` bind mounts). Default `/opt/pihole`. |
| `pihole_compose_dir` | Where `docker-compose.yml` is written; aligned with `dir_loc` in `tasks/main.yml`. |
| `pihole_image` | Container image (required for the template), e.g. `pihole/pihole:latest`. |
| `pihole_container_name` | Docker container name. Default `pihole`. |
| `webport_http` / `webport_https` | Host ports published to the container (when not using host networking). Defaults `80` / `443`. |
| `firewall_deploy` | When **true**, applies firewalld on the host (`tasks/firewall.yml`): HTTP/HTTPS ports from `webport_*`, DNS 53/tcp+udp, and optional DHCP-related rules when env vars enable them. |
| `pihole_firewall_deploy` | If set, mapped to `firewall_deploy` (boolean coerced). |
| `pihole_environment_variables` | Dict passed into the Pi-hole container (see [Pi-hole Docker documentation](https://github.com/pi-hole/docker-pi-hole)). Defaults include `TZ`, `FTLCONF_*`, `DHCP_ACTIVE`, `REV_SERVER`, etc. |
| `pihole_configure_systemd_resolved` | On Debian/Ubuntu, adjust systemd-resolved so host port 53 can be used for published DNS (default `true`). |
| `pihole_use_host_network` | Run Pi-hole with Docker `network_mode: host` (no published ports / bridge). |
| `docker_manage_iptables` / `docker_el_nat_fallback` | Relevant on EL + Docker with `iptables: false`; see EL section below. |

Inventory may set a `timezone` variable and pass `TZ: "{{ timezone }}"` inside `pihole_environment_variables` (see `tests/local-test.yml`).

### Rocky / EL + Docker NAT

On EL9+ guests, Docker sometimes runs with `iptables: false`, so bridge egress needs extra NAT. This role can apply an nftables masquerade fallback after `docker compose up` when `docker_manage_iptables` is false and `docker_el_nat_fallback` is true. Optional lab tuning: `pihole_rocky_network_debug`, `pihole_use_host_network` (see `defaults/main.yml` and task comments).

## Example playbook

Use a role path that matches your checkout name (here `docker-pihole` with the parent directory on `ANSIBLE_ROLES_PATH`):

```yaml
- hosts: dns_servers
  become: true
  gather_facts: true
  roles:
    - role: docker-pihole
      vars:
        pihole_compose_dir: /opt/pihole
        dir_loc: /opt/pihole
        firewall_deploy: "false"
        pihole_image: pihole/pihole:latest
        pihole_container_name: pihole
        pihole_environment_variables:
          TZ: "Europe/London"
          FTLCONF_webserver_api_password: "change-me"
          FTLCONF_dns_listeningMode: "ALL"
          DHCP_ACTIVE: false
          REV_SERVER: false
```

Run with:

```bash
export ANSIBLE_ROLES_PATH="/path/to/parent:/path/to/parent/docker-pihole"
ansible-playbook -i inventory playbook.yml
```

A minimal local example lives in [`tests/local-test.yml`](tests/local-test.yml).

## Continuous integration

[`.github/workflows/ci.yml`](.github/workflows/ci.yml) runs on **`dev`**, **`master`**, and **`feature/**`** (push and pull requests to `dev` / `master`):

1. **Ansible & YAML lint** — `ansible-lint`, `yamllint`, collections from `scripts/install-ansible-collections.sh`.
2. **Ansible syntax** — `ansible-playbook …/tests/syntax-check.yml --syntax-check` with `ANSIBLE_ROLES_PATH` including the repo parent (role name `docker-pihole`).

Full `ansible-playbook --check` is not run in CI (needs a real Docker host); use Molecule or `tests/local-test.yml` locally.

## Molecule (Docker integration test)

The [`molecule/default/`](molecule/default/) scenario runs the role inside a privileged Ubuntu container with Docker-in-Docker (see `prepare.yml` and `molecule.yml`). It verifies the container, DNS (`dig`), and HTTP/HTTPS access to `/admin/`.

Requires **Docker on the machine running Molecule**.

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
./scripts/install-ansible-collections.sh
molecule test
```

Molecule uses [`molecule/ansible.cfg`](molecule/ansible.cfg) (not the repo root `ansible.cfg`) so driver playbooks remain compatible with **Ansible 2.20+** strict conditionals.

## License

MIT (see `meta/main.yml`).

## Author information

See `meta/main.yml` (`author`) and Git history for maintainers.
