#cloud-config
ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6Tvl6E1eMdyvazTIRH3eA2qUqTn5lR7pVdWpQQeVT4sBxzN273XqPvxznmVBMxo0QSWYqLPWVLcygmUo/ZYcEOJBgpdDrX71km3iyEp07TMGJzpSJ6Ioy1HHK3P8G+XCESX6SxJS4XrD/IIM9MBL5yAjrjU8lmqQ5s4/y8LLzsTrPiSU3aFaFWRaRUmFSx07zq78pp+B+vVOvM4CC/uaASQbbIz+zfGlIDsOHXjUmYmZVpnHgQMbXldy+ftEGDwqZcFcJOqgEGEMe9+BILh24NuKq8jj6uHXlGw1hoXHn8FPUZ09yMnE5Z+PGgjWqDZa6BOxdcgo/I68l8Jj9pWRH
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDcQE/cTtzHHZ6c1R0ZwGGmebYQI4mzZcdAydfJR/MlQnjW1974tP7EDQ4lM0jL/PqNoePc2t/5TVuG7e+JR/SnJi4wpflRuCZPVyfnf5Q6z/gXPzzdeL15XYPlZJNRrZF5UCBMVR6u9+nMCOLp5uIrSGisBya40elTvxxWeTbmhheXwlUgRFFqujgDm69LaqgQMfctrbjGqbMtmzWxtczYL2ArQKyuml6BYt9itrAb2MGJFLTyyqooWP2rcrrpoKEYhTj6cXA/b750q+CwXhieQuquy2E4ceDDqk2Z/ysiocnnfAsYiUI6lnDTjnJpGJetcR5zLftnHlYXJVxPwBSt

write_files:
  - path: /opt/rancher/bin/start.sh
    permissions: "0700"
    owner: root
    content: |
      #!/bin/bash
      echo y | ros install -f -c /cloud-config.yml -d /dev/sda

  - path: /cloud-config.yml
    permissions: "0600"
    owner: root
    content: |
      #cloud-config
      ssh_authorized_keys:
        - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6Tvl6E1eMdyvazTIRH3eA2qUqTn5lR7pVdWpQQeVT4sBxzN273XqPvxznmVBMxo0QSWYqLPWVLcygmUo/ZYcEOJBgpdDrX71km3iyEp07TMGJzpSJ6Ioy1HHK3P8G+XCESX6SxJS4XrD/IIM9MBL5yAjrjU8lmqQ5s4/y8LLzsTrPiSU3aFaFWRaRUmFSx07zq78pp+B+vVOvM4CC/uaASQbbIz+zfGlIDsOHXjUmYmZVpnHgQMbXldy+ftEGDwqZcFcJOqgEGEMe9+BILh24NuKq8jj6uHXlGw1hoXHn8FPUZ09yMnE5Z+PGgjWqDZa6BOxdcgo/I68l8Jj9pWRH
        - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDcQE/cTtzHHZ6c1R0ZwGGmebYQI4mzZcdAydfJR/MlQnjW1974tP7EDQ4lM0jL/PqNoePc2t/5TVuG7e+JR/SnJi4wpflRuCZPVyfnf5Q6z/gXPzzdeL15XYPlZJNRrZF5UCBMVR6u9+nMCOLp5uIrSGisBya40elTvxxWeTbmhheXwlUgRFFqujgDm69LaqgQMfctrbjGqbMtmzWxtczYL2ArQKyuml6BYt9itrAb2MGJFLTyyqooWP2rcrrpoKEYhTj6cXA/b750q+CwXhieQuquy2E4ceDDqk2Z/ysiocnnfAsYiUI6lnDTjnJpGJetcR5zLftnHlYXJVxPwBSt
        
      hostname: ${rancher_hostname}.${rancher_domain}

      rancher:
        bootstrap_docker:
          registry_mirror: "https://docker-registry.${rancher_domain}"
        docker:
          registry_mirror: "https://docker-registry.${rancher_domain}"
        system_docker:
          registry_mirror: "https://docker-registry.${rancher_domain}"
        network:
          dns:
            nameservers:
%{ for address in split(",", dns_servers) ~}
              - ${address}
%{ endfor ~}
            search:
              - ${rancher_domain}
          interfaces:
            eth0:
              dhcp: true
              mtu: 1500

        services:
          rancher-server:
            hostname: rancher
            image: rancher/rancher:latest
            ports:
              - 80:80/tcp
              - 443:443/tcp
            volumes:
              - /var/lib/rancher:/var/lib/rancher:rw
            restart: unless-stopped