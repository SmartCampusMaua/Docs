# Iniciando com o Ansible

Qualquer tipo de tarefa repetitiva para fazer deploy vamos fazer utilizando o ansible do zero.

## Ansible vs Terraform
Quando falamos de ansible, falamos de uma ferramenta de automatizaçao de tarefas de forma muito inteligente. Ele garante que nao vai repetir novamente uma tarefa que ele ja realizou.

Tarefas como:
Temos 5 Ips com senhas e temos que instalar webservers. A chance de errarmos em um dessas tarefas eh muito grande. Imagina 100 servidores, updates em maquinas uma por uma!

Basicamente ela entra via ssh nas maquinas executa as instruçoes nas mias diversas maquinas. Esse aqruivo de inventario e tarefas ficam dentro de um arquivo de inventário.

Mas ele nao apenas isso. Ele tem uma estutura para rodar os maisa diversos tipos de tarefas. Podemos comunicar com k8s, Docker e diversos tipos de comnado Linux.

Provisionamento com o Terraform e executa as configuraçoes com o aNSIBLE

iMAGINE QUE SUBIMOS MAQUINAS EC2 COM O Terraform e todas as configuraçoes individuais com o ansible.

Podemos ateh criar um cluster k8s com ansible! Mas nao eh muito bom para isso.

Terraform -> Provisionamento da infra
Ansible -> Rodar tarefas automatizadas de config na infra

Muito importante. Muitas tarefas de pipeline CI/CD, estao sendo utilizando o ansible e depois ele passa ou nao. 

## Rodando primeiro ping
O processo de instalaçao eh muito simples mas tem uma pegadinha. 

Toda vez que formos rodar o ansible para executar tarefas em outras maquinas, o node de control nao pode ser rodado em Windows! Ha uma opçao com o wsl2.

https://www.ansible.com/

iNSTALE O ANSIBLE COM O PKG MANAGER

E verifique se a instalaçao esta ok
```bash
ansible --version
ansible [core 2.16.1]
  config file = None
  configured module search path = ['/Users/rogeriocassares/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /opt/homebrew/Cellar/ansible/9.1.0/libexec/lib/python3.12/site-packages/ansible
  ansible collection location = /Users/rogeriocassares/.ansible/collections:/usr/share/ansible/collections
  executable location = /opt/homebrew/bin/ansible
  python version = 3.12.0 (main, Oct  5 2023, 15:44:07) [Clang 14.0.3 (clang-1403.0.22.14.1)] (/opt/homebrew/Cellar/ansible/9.1.0/libexec/bin/python)
  jinja version = 3.1.2
  libyaml = True
```

Geralmente, quando trabalhamos com Ansible criamos um arquivo de inventario denominado hosts na raiz do projeto. Esse arquivo eh um inventario, que basicamente ele tem o inventario tem a listagem e ip de todas as maquinas que queremos executar os comandos.

Se quisermos rodar um ping:
```bash
```
-i -> arquivo de inventario
-m -> qual modulo rodar?

Toda vez que o ansible tenta falar com uma maquina ele se conecta via ssh. Na propria maquina nao eh viavel rodar na propria maquina, mas vamos forçar usando os comando abaixo em hosts
```hosts
localhost ansible_connection=local
```

E rodou apesar do warning!
```bash
❯ ansible -i hosts all -m ping
[WARNING]: Platform darwin on host localhost is using the discovered Python interpreter at
/opt/homebrew/bin/python3.12, but future installation of another Python interpreter could change the meaning of
that path. See https://docs.ansible.com/ansible-core/2.16/reference_appendices/interpreter_discovery.html for more
information.
localhost | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/opt/homebrew/bin/python3.12"
    },
    "changed": false,
    "ping": "pong"
}
```

Muitas vezes quando vamos rodar o Ansible, podemos colocar direto o endereço do interpretador python pq dessa via comando ansible forma ele esta descobrindo automaticamente o interpretador do python.

Vamos criar uma maquina e executar os comando sdo ansible na máquina remota.

## Configurando Ubuntu com Ansible e Docker
Vamos montar uma maquina para ser o controlador do Ansible.
Cada maquina nossa vai ser um container e o ansible vai entrar em cada um desses containers para teste

Vamos criar o Dockerfile da aplicaçao para reescrever algumas coisas do /etc/ssh/ssh_config
```Dockerfile
FROM ubuntu:22.04

RUN apt-get update && apt-get install vim ssh ansible -y
RUN echo 'root:fullcycle' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config
RUN sed -i 's/#PubkeyAuthentication/PubkeyAuthentication/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication/PasswordAuthentication/' /etc/ssh/sshd_config
```

Vamos criar um arquivo de docker-compose .yaml

```yaml
version: '3'

services:
  control:
    build: .
    container_name: control
    command: ["tail", "-f", "/dev/null"]
    hostname: control
    volumes:
      - .:/root/ansible
```

E vamos rodar
```bash
docker compose up -d
```


E vamos entrar no container criado!
```bash
docker exec -it control bash
```

Uma vez no terminal, o que vamos querer eh que tudo o que rodarmos no terminal utilizando o ansible deve funcionar. vamos testar:
```bash
cd /root/ansible/
ansible -i hosts all -m ping
localhost | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

E funcionou! Essa eh a máquina que vamos rodar como control. Agora vamos criar um node e fazer o control acessar via ssh.

## Configurando Nodes e configurando chaves
Temos que ter certeza que o ansible seja capaz de executar comando nelas e ela sera atraves de chaves.

Vamos colocar no docker-compose
```yaml
version: '3'

services:
  control:
    build: .
    container_name: control
    command: ["tail", "-f", "/dev/null"]
    hostname: control
    volumes:
      - .:/root/ansible

  node1:
    build: .
    container_name: node1
    command: ["tail", "-f", "/dev/null"]
    hostname: node1

```

Subir o compose
```bash
docker compose up -d
```

E vamos entrar no node1:
```bash
docker exec -it node1 bash
```

Agora, precisamos ver o seguinte: A maquina tem que poder logar via ssh no node1. mas por enquanto a conexao est refused. 

Vamos iniciar o serviço de ssh no node1 e tentar acessar via ssh na control
node1:
```bash
service ssh start
 * Starting OpenBSD Secure Shell server sshd [ OK ] 
```

control:
```bash
ssh root@node1
```

Aqui nao podemos digitar a senha, mas tem que ser automatico! E para que isso seja automatico precisamos de uma chave. E essa chave vai ser enviada tb para a outra maquina (private e public). A chave publica vai ser copiada para a outra maquina e toda a vez que formos fazer login no node1 vamos conseguir

No control
```bash
ssh-keygen 
```
```bash
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /root/.ssh/id_rsa
Your public key has been saved in /root/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:pwYmZaG8OCkXAN5w7sdNQ7AOURiVM9ZWOTPINdpnC8M root@control
The key's randomart image is:
+---[RSA 3072]----+
|+. +=+*.++.      |
|..=o.*o*+=.      |
| ..++.*+ E+o     |
|  .+++o . = .    |
|. =.o+o.S ..     |
| o ..o . o       |
|        o        |
|       .         |
|                 |
+----[SHA256]-----+
```

Duas chaves foram geradas:
Your identification has been saved in /root/.ssh/id_rsa
Your public key has been saved in /root/.ssh/id_rsa.pub

Como fazer para usar a chave para acessar o node1? Precisamos colocar a chave publica no known_hosts do ssh do node1
```bash
root@control:~/ansible# ssh-copy-id root@node1
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/root/.ssh/id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
root@node1's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'root@node1'"
and check to make sure that only the key(s) you wanted were added.
```

E pronto!

A chave publica foi copiada! Uma vez que ela esta la nao precisamos mais de senhas!

```bash
ssh root@node1
Welcome to Ubuntu 22.04.3 LTS (GNU/Linux 6.4.16-linuxkit aarch64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

This system has been minimized by removing packages and content that are
not required on a system that users do not log into.

To restore this content, you can run the 'unminimize' command.
root@node1:~# 
```

Funcionou! Se formos verificar as authorizes keys do node1:
```bash
cat /root/.ssh/authorized_keys 
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCOdAF/UhnoUsCOhS/bZ3/vdyus/nS1XYeIjmAgp4bLwQh6jAEnq5fDcdL+eRR75faRbXs0M51BcR0AW6kgUioC6lbVKIFASoM6FsazEpGxmeGHDOdRmrqYf+5V/vx1leVtRe9xM618hXmDrdde0P881E4NU6JYhUAik0LNjsdWWuRqT3CBmYFcGNcF8wXpbdUDRR9aClDjbgacM0MC47LTutC1ZqoZ4pSqGZnx6W1NNPvR9OJ0qgsNhr+0K1UpclP22lISykjc0TEThaM2dRznEjdiTCrKn+qLtjCSsm8NoXcYVRYunyMiYXr7o67aY59vzALkr4UJQKXuqC6UpyUO+a47zxzHAtzxUPToh3tItehxDmUYGnrYntwblE6vbez8WKAyeHIn3FWDqaGNcvpWWIm70DC8PBIRgYifYHf9LXN09d2nv4RFdblSukjLsPlG6STtNq+y9FDsKDf6Ty2FniAU3M0y8l5tDbBrMQaDTQOoWMGA+W46/UQ+IQN1Ov0= root@control
```

É esse arquivo qu e permite fazermos o lohin. Vamos voltar para o control, e mudar no Vscode, no arquivo hosts, de localhost para node1
```hosts
node1
```
E vamos ver o que vai acontecer quando dermos o ping no  control via ansible

control:
```bash
root@control:~/ansible# ansible -i hosts all -m ping
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

Veja que le conseguiu entrar no node1 e executar o ping. E isso soh aconteceu pq ele tinha permissao para acessar a outra maquina

Vamos rodar um script no node1 a partir do control
```bash
root@control:~/ansible# ansible -i hosts all -m shell -a 'uptime'
node1 | CHANGED | rc=0 >>
 14:55:17 up 19 min,  0 users,  load average: 1.26, 1.08, 1.14
```

Vamos subir uma outra maquina modificando o docker-compose
```yaml
version: '3'

services:
  control:
    build: .
    container_name: control
    command: ["tail", "-f", "/dev/null"]
    hostname: control
    volumes:
      - .:/root/ansible

  node1:
    build: .
    container_name: node1
    command: ["tail", "-f", "/dev/null"]
    hostname: node1

  node2:
    build: .
    container_name: node2
    command: ["tail", "-f", "/dev/null"]
    hostname: node2
```

E vamos rodar o novo compose
```bash
docker compose up -d
```

E entrar no node2
```bash
docker exec -it node2 bash
```

Ativar o ssh
```bash
service ssh start
 * Starting OpenBSD Secure Shell server sshd  [ OK ] 
```

Entrar no control e copiar o id para o node2
```bash
❯ docker compose exec -it control bash
root@control:/# ssh-copy-id root@node2
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/root/.ssh/id_rsa.pub"
The authenticity of host 'node2 (172.22.0.4)' can't be established.
ED25519 key fingerprint is SHA256:hvBv4Cc/MQ+bYabaeGkwY2kUXT/a522MlQjGS9CBJwo.
This host key is known by the following other names/addresses:
    ~/.ssh/known_hosts:1: [hashed name]
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
root@node2's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'root@node2'"
and check to make sure that only the key(s) you wanted were added.
```

Agora a chave foi adicionada na maquina node2 tb!
Vamos agora colocar node2 no arquivo de hosts
```hosts
node1
node2
```

E pedir para o control rodar o comando de ping tanto no node1 quanto no node2
```bash
root@control:/# cd root/ansible/
root@control:~/ansible# ansible -i hosts all -m ping
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
node2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

E funcionou!

Nota: tanto na maquina node1 e node2 nao precisamos ter o ansible instalado! Apenas o python.

## Executando primeiros comandos
O Ansible pode ser dividos em dois tipos de comandos:

ad-hoc: executa apenas uma vez, como o ping
playbook: uma serie de comandos em série

Um exemplo de comando selecionando um dos hosts seria:
```bash
ansible -i hosts node1 -m ping
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

Com isso ele faz apenas no node1

Agora, vamos imagnar qu equeremos instalar o git nessas maquinas e depois fazer o checkout de um repositorio git no githb em 50 maquinas. O ansible tem o plugin do gerenciador de pacotes apt-get!

```bash
root@control:~/ansible# ansible -i hosts all -m apt -a "update_cache=yes name=git state=present"
```

E agora o resultado: Amarelo -> alterou, verde -> ja estava ok

```bash
[WARNING]: Updating cache and auto-installing missing dependency: python3-apt
node1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "cache_update_time": 1704467433,
    "cache_updated": false,
    "changed": true,
    "stderr": "debconf: delaying package configuration, since apt-utils is not installed\n",
    "stderr_lines": [
        "debconf: delaying package configuration, since apt-utils is not installed"
    ],
    "stdout": "Reading package lists...\nBuilding dependency tree...\nReading state information...\nThe following additional packages will be installed:\n  git-man less libbrotli1 libcurl3-gnutls liberror-perl libgdbm-compat4\n  libgdbm6 libldap-2.5-0 libldap-common libnghttp2-14 libperl5.34 librtmp1\n  libsasl2-2 libsasl2-modules libsasl2-modules-db libssh-4 patch perl\n  perl-modules-5.34\nSuggested packages:\n  gettext-base git-daemon-run | git-daemon-sysvinit git-doc git-email git-gui\n  gitk gitweb git-cvs git-mediawiki git-svn gdbm-l10n\n  libsasl2-modules-gssapi-mit | libsasl2-modules-gssapi-heimdal\n  libsasl2-modules-ldap libsasl2-modules-otp libsasl2-modules-sql ed\n  diffutils-doc perl-doc libterm-readline-gnu-perl\n  | libterm-readline-perl-perl make libtap-harness-archive-perl\nThe following NEW packages will be installed:\n  git git-man less libbrotli1 libcurl3-gnutls liberror-perl libgdbm-compat4\n  libgdbm6 libldap-2.5-0 libldap-common libnghttp2-14 libperl5.34 librtmp1\n  libsasl2-2 libsasl2-modules libsasl2-modules-db libssh-4 patch perl\n  perl-modules-5.34\n0 upgraded, 20 newly installed, 0 to remove and 0 not upgraded.\nNeed to get 13.7 MB of archives.\nAfter this operation, 72.2 MB of additional disk space will be used.\nGet:1 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 perl-modules-5.34 all 5.34.0-3ubuntu1.3 [2976 kB]\nGet:2 http://ports.ubuntu.com/ubuntu-ports jammy/main arm64 libgdbm6 arm64 1.23-1 [34.1 kB]\nGet:3 http://ports.ubuntu.com/ubuntu-ports jammy/main arm64 libgdbm-compat4 arm64 1.23-1 [6294 B]\nGet:4 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libperl5.34 arm64 5.34.0-3ubuntu1.3 [4723 kB]\nGet:5 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 perl arm64 5.34.0-3ubuntu1.3 [232 kB]\nGet:6 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 less arm64 590-1ubuntu0.22.04.1 [142 kB]\nGet:7 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libnghttp2-14 arm64 1.43.0-1ubuntu0.1 [76.1 kB]\nGet:8 http://ports.ubuntu.com/ubuntu-ports jammy/main arm64 libbrotli1 arm64 1.0.9-2build6 [314 kB]\nGet:9 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libsasl2-modules-db arm64 2.1.27+dfsg2-3ubuntu1.2 [21.1 kB]\nGet:10 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libsasl2-2 arm64 2.1.27+dfsg2-3ubuntu1.2 [55.6 kB]\nGet:11 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libldap-2.5-0 arm64 2.5.16+dfsg-0ubuntu0.22.04.1 [181 kB]\nGet:12 http://ports.ubuntu.com/ubuntu-ports jammy/main arm64 librtmp1 arm64 2.4+20151223.gitfa8646d.1-2build4 [59.2 kB]\nGet:13 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libssh-4 arm64 0.9.6-2ubuntu0.22.04.2 [185 kB]\nGet:14 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libcurl3-gnutls arm64 7.81.0-1ubuntu1.15 [279 kB]\nGet:15 http://ports.ubuntu.com/ubuntu-ports jammy/main arm64 liberror-perl all 0.17029-1 [26.5 kB]\nGet:16 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 git-man all 1:2.34.1-1ubuntu1.10 [954 kB]\nGet:17 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 git arm64 1:2.34.1-1ubuntu1.10 [3223 kB]\nGet:18 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libldap-common all 2.5.16+dfsg-0ubuntu0.22.04.1 [15.8 kB]\nGet:19 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libsasl2-modules arm64 2.1.27+dfsg2-3ubuntu1.2 [68.4 kB]\nGet:20 http://ports.ubuntu.com/ubuntu-ports jammy/main arm64 patch arm64 2.7.6-7build2 [105 kB]\nFetched 13.7 MB in 23s (593 kB/s)\nSelecting previously unselected package perl-modules-5.34.\r\n(Reading database ... \r(Reading database ... 5%\r(Reading database ... 10%\r(Reading database ... 15%\r(Reading database ... 20%\r(Reading database ... 25%\r(Reading database ... 30%\r(Reading database ... 35%\r(Reading database ... 40%\r(Reading database ... 45%\r(Reading database ... 50%\r(Reading database ... 55%\r(Reading database ... 60%\r(Reading database ... 65%\r(Reading database ... 70%\r(Reading database ... 75%\r(Reading database ... 80%\r(Reading database ... 85%\r(Reading database ... 90%\r(Reading database ... 95%\r(Reading database ... 100%\r(Reading database ... 54337 files and directories currently installed.)\r\nPreparing to unpack .../00-perl-modules-5.34_5.34.0-3ubuntu1.3_all.deb ...\r\nUnpacking perl-modules-5.34 (5.34.0-3ubuntu1.3) ...\r\nSelecting previously unselected package libgdbm6:arm64.\r\nPreparing to unpack .../01-libgdbm6_1.23-1_arm64.deb ...\r\nUnpacking libgdbm6:arm64 (1.23-1) ...\r\nSelecting previously unselected package libgdbm-compat4:arm64.\r\nPreparing to unpack .../02-libgdbm-compat4_1.23-1_arm64.deb ...\r\nUnpacking libgdbm-compat4:arm64 (1.23-1) ...\r\nSelecting previously unselected package libperl5.34:arm64.\r\nPreparing to unpack .../03-libperl5.34_5.34.0-3ubuntu1.3_arm64.deb ...\r\nUnpacking libperl5.34:arm64 (5.34.0-3ubuntu1.3) ...\r\nSelecting previously unselected package perl.\r\nPreparing to unpack .../04-perl_5.34.0-3ubuntu1.3_arm64.deb ...\r\nUnpacking perl (5.34.0-3ubuntu1.3) ...\r\nSelecting previously unselected package less.\r\nPreparing to unpack .../05-less_590-1ubuntu0.22.04.1_arm64.deb ...\r\nUnpacking less (590-1ubuntu0.22.04.1) ...\r\nSelecting previously unselected package libnghttp2-14:arm64.\r\nPreparing to unpack .../06-libnghttp2-14_1.43.0-1ubuntu0.1_arm64.deb ...\r\nUnpacking libnghttp2-14:arm64 (1.43.0-1ubuntu0.1) ...\r\nSelecting previously unselected package libbrotli1:arm64.\r\nPreparing to unpack .../07-libbrotli1_1.0.9-2build6_arm64.deb ...\r\nUnpacking libbrotli1:arm64 (1.0.9-2build6) ...\r\nSelecting previously unselected package libsasl2-modules-db:arm64.\r\nPreparing to unpack .../08-libsasl2-modules-db_2.1.27+dfsg2-3ubuntu1.2_arm64.deb ...\r\nUnpacking libsasl2-modules-db:arm64 (2.1.27+dfsg2-3ubuntu1.2) ...\r\nSelecting previously unselected package libsasl2-2:arm64.\r\nPreparing to unpack .../09-libsasl2-2_2.1.27+dfsg2-3ubuntu1.2_arm64.deb ...\r\nUnpacking libsasl2-2:arm64 (2.1.27+dfsg2-3ubuntu1.2) ...\r\nSelecting previously unselected package libldap-2.5-0:arm64.\r\nPreparing to unpack .../10-libldap-2.5-0_2.5.16+dfsg-0ubuntu0.22.04.1_arm64.deb ...\r\nUnpacking libldap-2.5-0:arm64 (2.5.16+dfsg-0ubuntu0.22.04.1) ...\r\nSelecting previously unselected package librtmp1:arm64.\r\nPreparing to unpack .../11-librtmp1_2.4+20151223.gitfa8646d.1-2build4_arm64.deb ...\r\nUnpacking librtmp1:arm64 (2.4+20151223.gitfa8646d.1-2build4) ...\r\nSelecting previously unselected package libssh-4:arm64.\r\nPreparing to unpack .../12-libssh-4_0.9.6-2ubuntu0.22.04.2_arm64.deb ...\r\nUnpacking libssh-4:arm64 (0.9.6-2ubuntu0.22.04.2) ...\r\nSelecting previously unselected package libcurl3-gnutls:arm64.\r\nPreparing to unpack .../13-libcurl3-gnutls_7.81.0-1ubuntu1.15_arm64.deb ...\r\nUnpacking libcurl3-gnutls:arm64 (7.81.0-1ubuntu1.15) ...\r\nSelecting previously unselected package liberror-perl.\r\nPreparing to unpack .../14-liberror-perl_0.17029-1_all.deb ...\r\nUnpacking liberror-perl (0.17029-1) ...\r\nSelecting previously unselected package git-man.\r\nPreparing to unpack .../15-git-man_1%3a2.34.1-1ubuntu1.10_all.deb ...\r\nUnpacking git-man (1:2.34.1-1ubuntu1.10) ...\r\nSelecting previously unselected package git.\r\nPreparing to unpack .../16-git_1%3a2.34.1-1ubuntu1.10_arm64.deb ...\r\nUnpacking git (1:2.34.1-1ubuntu1.10) ...\r\nSelecting previously unselected package libldap-common.\r\nPreparing to unpack .../17-libldap-common_2.5.16+dfsg-0ubuntu0.22.04.1_all.deb ...\r\nUnpacking libldap-common (2.5.16+dfsg-0ubuntu0.22.04.1) ...\r\nSelecting previously unselected package libsasl2-modules:arm64.\r\nPreparing to unpack .../18-libsasl2-modules_2.1.27+dfsg2-3ubuntu1.2_arm64.deb ...\r\nUnpacking libsasl2-modules:arm64 (2.1.27+dfsg2-3ubuntu1.2) ...\r\nSelecting previously unselected package patch.\r\nPreparing to unpack .../19-patch_2.7.6-7build2_arm64.deb ...\r\nUnpacking patch (2.7.6-7build2) ...\r\nSetting up libbrotli1:arm64 (1.0.9-2build6) ...\r\nSetting up libsasl2-modules:arm64 (2.1.27+dfsg2-3ubuntu1.2) ...\r\nSetting up libnghttp2-14:arm64 (1.43.0-1ubuntu0.1) ...\r\nSetting up less (590-1ubuntu0.22.04.1) ...\r\nSetting up perl-modules-5.34 (5.34.0-3ubuntu1.3) ...\r\nSetting up libldap-common (2.5.16+dfsg-0ubuntu0.22.04.1) ...\r\nSetting up libsasl2-modules-db:arm64 (2.1.27+dfsg2-3ubuntu1.2) ...\r\nSetting up librtmp1:arm64 (2.4+20151223.gitfa8646d.1-2build4) ...\r\nSetting up patch (2.7.6-7build2) ...\r\nSetting up libsasl2-2:arm64 (2.1.27+dfsg2-3ubuntu1.2) ...\r\nSetting up libssh-4:arm64 (0.9.6-2ubuntu0.22.04.2) ...\r\nSetting up git-man (1:2.34.1-1ubuntu1.10) ...\r\nSetting up libgdbm6:arm64 (1.23-1) ...\r\nSetting up libldap-2.5-0:arm64 (2.5.16+dfsg-0ubuntu0.22.04.1) ...\r\nSetting up libgdbm-compat4:arm64 (1.23-1) ...\r\nSetting up libperl5.34:arm64 (5.34.0-3ubuntu1.3) ...\r\nSetting up libcurl3-gnutls:arm64 (7.81.0-1ubuntu1.15) ...\r\nSetting up perl (5.34.0-3ubuntu1.3) ...\r\nSetting up liberror-perl (0.17029-1) ...\r\nSetting up git (1:2.34.1-1ubuntu1.10) ...\r\nProcessing triggers for libc-bin (2.35-0ubuntu3.5) ...\r\n",
    "stdout_lines": [
        "Reading package lists...",
        "Building dependency tree...",
        "Reading state information...",
        "The following additional packages will be installed:",
        "  git-man less libbrotli1 libcurl3-gnutls liberror-perl libgdbm-compat4",
        "  libgdbm6 libldap-2.5-0 libldap-common libnghttp2-14 libperl5.34 librtmp1",
        "  libsasl2-2 libsasl2-modules libsasl2-modules-db libssh-4 patch perl",
        "  perl-modules-5.34",
        "Suggested packages:",
        "  gettext-base git-daemon-run | git-daemon-sysvinit git-doc git-email git-gui",
        "  gitk gitweb git-cvs git-mediawiki git-svn gdbm-l10n",
        "  libsasl2-modules-gssapi-mit | libsasl2-modules-gssapi-heimdal",
        "  libsasl2-modules-ldap libsasl2-modules-otp libsasl2-modules-sql ed",
        "  diffutils-doc perl-doc libterm-readline-gnu-perl",
        "  | libterm-readline-perl-perl make libtap-harness-archive-perl",
        "The following NEW packages will be installed:",
        "  git git-man less libbrotli1 libcurl3-gnutls liberror-perl libgdbm-compat4",
        "  libgdbm6 libldap-2.5-0 libldap-common libnghttp2-14 libperl5.34 librtmp1",
        "  libsasl2-2 libsasl2-modules libsasl2-modules-db libssh-4 patch perl",
        "  perl-modules-5.34",
        "0 upgraded, 20 newly installed, 0 to remove and 0 not upgraded.",
        "Need to get 13.7 MB of archives.",
        "After this operation, 72.2 MB of additional disk space will be used.",
        "Get:1 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 perl-modules-5.34 all 5.34.0-3ubuntu1.3 [2976 kB]",
        "Get:2 http://ports.ubuntu.com/ubuntu-ports jammy/main arm64 libgdbm6 arm64 1.23-1 [34.1 kB]",
        "Get:3 http://ports.ubuntu.com/ubuntu-ports jammy/main arm64 libgdbm-compat4 arm64 1.23-1 [6294 B]",
        "Get:4 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libperl5.34 arm64 5.34.0-3ubuntu1.3 [4723 kB]",
        "Get:5 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 perl arm64 5.34.0-3ubuntu1.3 [232 kB]",
        "Get:6 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 less arm64 590-1ubuntu0.22.04.1 [142 kB]",
        "Get:7 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libnghttp2-14 arm64 1.43.0-1ubuntu0.1 [76.1 kB]",
        "Get:8 http://ports.ubuntu.com/ubuntu-ports jammy/main arm64 libbrotli1 arm64 1.0.9-2build6 [314 kB]",
        "Get:9 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libsasl2-modules-db arm64 2.1.27+dfsg2-3ubuntu1.2 [21.1 kB]",
        "Get:10 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libsasl2-2 arm64 2.1.27+dfsg2-3ubuntu1.2 [55.6 kB]",
        "Get:11 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libldap-2.5-0 arm64 2.5.16+dfsg-0ubuntu0.22.04.1 [181 kB]",
        "Get:12 http://ports.ubuntu.com/ubuntu-ports jammy/main arm64 librtmp1 arm64 2.4+20151223.gitfa8646d.1-2build4 [59.2 kB]",
        "Get:13 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libssh-4 arm64 0.9.6-2ubuntu0.22.04.2 [185 kB]",
        "Get:14 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libcurl3-gnutls arm64 7.81.0-1ubuntu1.15 [279 kB]",
        "Get:15 http://ports.ubuntu.com/ubuntu-ports jammy/main arm64 liberror-perl all 0.17029-1 [26.5 kB]",
        "Get:16 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 git-man all 1:2.34.1-1ubuntu1.10 [954 kB]",
        "Get:17 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 git arm64 1:2.34.1-1ubuntu1.10 [3223 kB]",
        "Get:18 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libldap-common all 2.5.16+dfsg-0ubuntu0.22.04.1 [15.8 kB]",
        "Get:19 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libsasl2-modules arm64 2.1.27+dfsg2-3ubuntu1.2 [68.4 kB]",
        "Get:20 http://ports.ubuntu.com/ubuntu-ports jammy/main arm64 patch arm64 2.7.6-7build2 [105 kB]",
        "Fetched 13.7 MB in 23s (593 kB/s)",
        "Selecting previously unselected package perl-modules-5.34.",
        "(Reading database ... ",
        "(Reading database ... 5%",
        "(Reading database ... 10%",
        "(Reading database ... 15%",
        "(Reading database ... 20%",
        "(Reading database ... 25%",
        "(Reading database ... 30%",
        "(Reading database ... 35%",
        "(Reading database ... 40%",
        "(Reading database ... 45%",
        "(Reading database ... 50%",
        "(Reading database ... 55%",
        "(Reading database ... 60%",
        "(Reading database ... 65%",
        "(Reading database ... 70%",
        "(Reading database ... 75%",
        "(Reading database ... 80%",
        "(Reading database ... 85%",
        "(Reading database ... 90%",
        "(Reading database ... 95%",
        "(Reading database ... 100%",
        "(Reading database ... 54337 files and directories currently installed.)",
        "Preparing to unpack .../00-perl-modules-5.34_5.34.0-3ubuntu1.3_all.deb ...",
        "Unpacking perl-modules-5.34 (5.34.0-3ubuntu1.3) ...",
        "Selecting previously unselected package libgdbm6:arm64.",
        "Preparing to unpack .../01-libgdbm6_1.23-1_arm64.deb ...",
        "Unpacking libgdbm6:arm64 (1.23-1) ...",
        "Selecting previously unselected package libgdbm-compat4:arm64.",
        "Preparing to unpack .../02-libgdbm-compat4_1.23-1_arm64.deb ...",
        "Unpacking libgdbm-compat4:arm64 (1.23-1) ...",
        "Selecting previously unselected package libperl5.34:arm64.",
        "Preparing to unpack .../03-libperl5.34_5.34.0-3ubuntu1.3_arm64.deb ...",
        "Unpacking libperl5.34:arm64 (5.34.0-3ubuntu1.3) ...",
        "Selecting previously unselected package perl.",
        "Preparing to unpack .../04-perl_5.34.0-3ubuntu1.3_arm64.deb ...",
        "Unpacking perl (5.34.0-3ubuntu1.3) ...",
        "Selecting previously unselected package less.",
        "Preparing to unpack .../05-less_590-1ubuntu0.22.04.1_arm64.deb ...",
        "Unpacking less (590-1ubuntu0.22.04.1) ...",
        "Selecting previously unselected package libnghttp2-14:arm64.",
        "Preparing to unpack .../06-libnghttp2-14_1.43.0-1ubuntu0.1_arm64.deb ...",
        "Unpacking libnghttp2-14:arm64 (1.43.0-1ubuntu0.1) ...",
        "Selecting previously unselected package libbrotli1:arm64.",
        "Preparing to unpack .../07-libbrotli1_1.0.9-2build6_arm64.deb ...",
        "Unpacking libbrotli1:arm64 (1.0.9-2build6) ...",
        "Selecting previously unselected package libsasl2-modules-db:arm64.",
        "Preparing to unpack .../08-libsasl2-modules-db_2.1.27+dfsg2-3ubuntu1.2_arm64.deb ...",
        "Unpacking libsasl2-modules-db:arm64 (2.1.27+dfsg2-3ubuntu1.2) ...",
        "Selecting previously unselected package libsasl2-2:arm64.",
        "Preparing to unpack .../09-libsasl2-2_2.1.27+dfsg2-3ubuntu1.2_arm64.deb ...",
        "Unpacking libsasl2-2:arm64 (2.1.27+dfsg2-3ubuntu1.2) ...",
        "Selecting previously unselected package libldap-2.5-0:arm64.",
        "Preparing to unpack .../10-libldap-2.5-0_2.5.16+dfsg-0ubuntu0.22.04.1_arm64.deb ...",
        "Unpacking libldap-2.5-0:arm64 (2.5.16+dfsg-0ubuntu0.22.04.1) ...",
        "Selecting previously unselected package librtmp1:arm64.",
        "Preparing to unpack .../11-librtmp1_2.4+20151223.gitfa8646d.1-2build4_arm64.deb ...",
        "Unpacking librtmp1:arm64 (2.4+20151223.gitfa8646d.1-2build4) ...",
        "Selecting previously unselected package libssh-4:arm64.",
        "Preparing to unpack .../12-libssh-4_0.9.6-2ubuntu0.22.04.2_arm64.deb ...",
        "Unpacking libssh-4:arm64 (0.9.6-2ubuntu0.22.04.2) ...",
        "Selecting previously unselected package libcurl3-gnutls:arm64.",
        "Preparing to unpack .../13-libcurl3-gnutls_7.81.0-1ubuntu1.15_arm64.deb ...",
        "Unpacking libcurl3-gnutls:arm64 (7.81.0-1ubuntu1.15) ...",
        "Selecting previously unselected package liberror-perl.",
        "Preparing to unpack .../14-liberror-perl_0.17029-1_all.deb ...",
        "Unpacking liberror-perl (0.17029-1) ...",
        "Selecting previously unselected package git-man.",
        "Preparing to unpack .../15-git-man_1%3a2.34.1-1ubuntu1.10_all.deb ...",
        "Unpacking git-man (1:2.34.1-1ubuntu1.10) ...",
        "Selecting previously unselected package git.",
        "Preparing to unpack .../16-git_1%3a2.34.1-1ubuntu1.10_arm64.deb ...",
        "Unpacking git (1:2.34.1-1ubuntu1.10) ...",
        "Selecting previously unselected package libldap-common.",
        "Preparing to unpack .../17-libldap-common_2.5.16+dfsg-0ubuntu0.22.04.1_all.deb ...",
        "Unpacking libldap-common (2.5.16+dfsg-0ubuntu0.22.04.1) ...",
        "Selecting previously unselected package libsasl2-modules:arm64.",
        "Preparing to unpack .../18-libsasl2-modules_2.1.27+dfsg2-3ubuntu1.2_arm64.deb ...",
        "Unpacking libsasl2-modules:arm64 (2.1.27+dfsg2-3ubuntu1.2) ...",
        "Selecting previously unselected package patch.",
        "Preparing to unpack .../19-patch_2.7.6-7build2_arm64.deb ...",
        "Unpacking patch (2.7.6-7build2) ...",
        "Setting up libbrotli1:arm64 (1.0.9-2build6) ...",
        "Setting up libsasl2-modules:arm64 (2.1.27+dfsg2-3ubuntu1.2) ...",
        "Setting up libnghttp2-14:arm64 (1.43.0-1ubuntu0.1) ...",
        "Setting up less (590-1ubuntu0.22.04.1) ...",
        "Setting up perl-modules-5.34 (5.34.0-3ubuntu1.3) ...",
        "Setting up libldap-common (2.5.16+dfsg-0ubuntu0.22.04.1) ...",
        "Setting up libsasl2-modules-db:arm64 (2.1.27+dfsg2-3ubuntu1.2) ...",
        "Setting up librtmp1:arm64 (2.4+20151223.gitfa8646d.1-2build4) ...",
        "Setting up patch (2.7.6-7build2) ...",
        "Setting up libsasl2-2:arm64 (2.1.27+dfsg2-3ubuntu1.2) ...",
        "Setting up libssh-4:arm64 (0.9.6-2ubuntu0.22.04.2) ...",
        "Setting up git-man (1:2.34.1-1ubuntu1.10) ...",
        "Setting up libgdbm6:arm64 (1.23-1) ...",
        "Setting up libldap-2.5-0:arm64 (2.5.16+dfsg-0ubuntu0.22.04.1) ...",
        "Setting up libgdbm-compat4:arm64 (1.23-1) ...",
        "Setting up libperl5.34:arm64 (5.34.0-3ubuntu1.3) ...",
        "Setting up libcurl3-gnutls:arm64 (7.81.0-1ubuntu1.15) ...",
        "Setting up perl (5.34.0-3ubuntu1.3) ...",
        "Setting up liberror-perl (0.17029-1) ...",
        "Setting up git (1:2.34.1-1ubuntu1.10) ...",
        "Processing triggers for libc-bin (2.35-0ubuntu3.5) ..."
    ]
}
node2 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "cache_update_time": 1704467433,
    "cache_updated": false,
    "changed": true,
    "stderr": "debconf: delaying package configuration, since apt-utils is not installed\n",
    "stderr_lines": [
        "debconf: delaying package configuration, since apt-utils is not installed"
    ],
    "stdout": "Reading package lists...\nBuilding dependency tree...\nReading state information...\nThe following additional packages will be installed:\n  git-man less libbrotli1 libcurl3-gnutls liberror-perl libgdbm-compat4\n  libgdbm6 libldap-2.5-0 libldap-common libnghttp2-14 libperl5.34 librtmp1\n  libsasl2-2 libsasl2-modules libsasl2-modules-db libssh-4 patch perl\n  perl-modules-5.34\nSuggested packages:\n  gettext-base git-daemon-run | git-daemon-sysvinit git-doc git-email git-gui\n  gitk gitweb git-cvs git-mediawiki git-svn gdbm-l10n\n  libsasl2-modules-gssapi-mit | libsasl2-modules-gssapi-heimdal\n  libsasl2-modules-ldap libsasl2-modules-otp libsasl2-modules-sql ed\n  diffutils-doc perl-doc libterm-readline-gnu-perl\n  | libterm-readline-perl-perl make libtap-harness-archive-perl\nThe following NEW packages will be installed:\n  git git-man less libbrotli1 libcurl3-gnutls liberror-perl libgdbm-compat4\n  libgdbm6 libldap-2.5-0 libldap-common libnghttp2-14 libperl5.34 librtmp1\n  libsasl2-2 libsasl2-modules libsasl2-modules-db libssh-4 patch perl\n  perl-modules-5.34\n0 upgraded, 20 newly installed, 0 to remove and 0 not upgraded.\nNeed to get 13.7 MB of archives.\nAfter this operation, 72.2 MB of additional disk space will be used.\nGet:1 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 perl-modules-5.34 all 5.34.0-3ubuntu1.3 [2976 kB]\nGet:2 http://ports.ubuntu.com/ubuntu-ports jammy/main arm64 libgdbm6 arm64 1.23-1 [34.1 kB]\nGet:3 http://ports.ubuntu.com/ubuntu-ports jammy/main arm64 libgdbm-compat4 arm64 1.23-1 [6294 B]\nGet:4 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libperl5.34 arm64 5.34.0-3ubuntu1.3 [4723 kB]\nGet:5 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 perl arm64 5.34.0-3ubuntu1.3 [232 kB]\nGet:6 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 less arm64 590-1ubuntu0.22.04.1 [142 kB]\nGet:7 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libnghttp2-14 arm64 1.43.0-1ubuntu0.1 [76.1 kB]\nGet:8 http://ports.ubuntu.com/ubuntu-ports jammy/main arm64 libbrotli1 arm64 1.0.9-2build6 [314 kB]\nGet:9 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libsasl2-modules-db arm64 2.1.27+dfsg2-3ubuntu1.2 [21.1 kB]\nGet:10 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libsasl2-2 arm64 2.1.27+dfsg2-3ubuntu1.2 [55.6 kB]\nGet:11 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libldap-2.5-0 arm64 2.5.16+dfsg-0ubuntu0.22.04.1 [181 kB]\nGet:12 http://ports.ubuntu.com/ubuntu-ports jammy/main arm64 librtmp1 arm64 2.4+20151223.gitfa8646d.1-2build4 [59.2 kB]\nGet:13 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libssh-4 arm64 0.9.6-2ubuntu0.22.04.2 [185 kB]\nGet:14 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libcurl3-gnutls arm64 7.81.0-1ubuntu1.15 [279 kB]\nGet:15 http://ports.ubuntu.com/ubuntu-ports jammy/main arm64 liberror-perl all 0.17029-1 [26.5 kB]\nGet:16 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 git-man all 1:2.34.1-1ubuntu1.10 [954 kB]\nGet:17 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 git arm64 1:2.34.1-1ubuntu1.10 [3223 kB]\nGet:18 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libldap-common all 2.5.16+dfsg-0ubuntu0.22.04.1 [15.8 kB]\nGet:19 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libsasl2-modules arm64 2.1.27+dfsg2-3ubuntu1.2 [68.4 kB]\nGet:20 http://ports.ubuntu.com/ubuntu-ports jammy/main arm64 patch arm64 2.7.6-7build2 [105 kB]\nFetched 13.7 MB in 23s (597 kB/s)\nSelecting previously unselected package perl-modules-5.34.\r\n(Reading database ... \r(Reading database ... 5%\r(Reading database ... 10%\r(Reading database ... 15%\r(Reading database ... 20%\r(Reading database ... 25%\r(Reading database ... 30%\r(Reading database ... 35%\r(Reading database ... 40%\r(Reading database ... 45%\r(Reading database ... 50%\r(Reading database ... 55%\r(Reading database ... 60%\r(Reading database ... 65%\r(Reading database ... 70%\r(Reading database ... 75%\r(Reading database ... 80%\r(Reading database ... 85%\r(Reading database ... 90%\r(Reading database ... 95%\r(Reading database ... 100%\r(Reading database ... 54337 files and directories currently installed.)\r\nPreparing to unpack .../00-perl-modules-5.34_5.34.0-3ubuntu1.3_all.deb ...\r\nUnpacking perl-modules-5.34 (5.34.0-3ubuntu1.3) ...\r\nSelecting previously unselected package libgdbm6:arm64.\r\nPreparing to unpack .../01-libgdbm6_1.23-1_arm64.deb ...\r\nUnpacking libgdbm6:arm64 (1.23-1) ...\r\nSelecting previously unselected package libgdbm-compat4:arm64.\r\nPreparing to unpack .../02-libgdbm-compat4_1.23-1_arm64.deb ...\r\nUnpacking libgdbm-compat4:arm64 (1.23-1) ...\r\nSelecting previously unselected package libperl5.34:arm64.\r\nPreparing to unpack .../03-libperl5.34_5.34.0-3ubuntu1.3_arm64.deb ...\r\nUnpacking libperl5.34:arm64 (5.34.0-3ubuntu1.3) ...\r\nSelecting previously unselected package perl.\r\nPreparing to unpack .../04-perl_5.34.0-3ubuntu1.3_arm64.deb ...\r\nUnpacking perl (5.34.0-3ubuntu1.3) ...\r\nSelecting previously unselected package less.\r\nPreparing to unpack .../05-less_590-1ubuntu0.22.04.1_arm64.deb ...\r\nUnpacking less (590-1ubuntu0.22.04.1) ...\r\nSelecting previously unselected package libnghttp2-14:arm64.\r\nPreparing to unpack .../06-libnghttp2-14_1.43.0-1ubuntu0.1_arm64.deb ...\r\nUnpacking libnghttp2-14:arm64 (1.43.0-1ubuntu0.1) ...\r\nSelecting previously unselected package libbrotli1:arm64.\r\nPreparing to unpack .../07-libbrotli1_1.0.9-2build6_arm64.deb ...\r\nUnpacking libbrotli1:arm64 (1.0.9-2build6) ...\r\nSelecting previously unselected package libsasl2-modules-db:arm64.\r\nPreparing to unpack .../08-libsasl2-modules-db_2.1.27+dfsg2-3ubuntu1.2_arm64.deb ...\r\nUnpacking libsasl2-modules-db:arm64 (2.1.27+dfsg2-3ubuntu1.2) ...\r\nSelecting previously unselected package libsasl2-2:arm64.\r\nPreparing to unpack .../09-libsasl2-2_2.1.27+dfsg2-3ubuntu1.2_arm64.deb ...\r\nUnpacking libsasl2-2:arm64 (2.1.27+dfsg2-3ubuntu1.2) ...\r\nSelecting previously unselected package libldap-2.5-0:arm64.\r\nPreparing to unpack .../10-libldap-2.5-0_2.5.16+dfsg-0ubuntu0.22.04.1_arm64.deb ...\r\nUnpacking libldap-2.5-0:arm64 (2.5.16+dfsg-0ubuntu0.22.04.1) ...\r\nSelecting previously unselected package librtmp1:arm64.\r\nPreparing to unpack .../11-librtmp1_2.4+20151223.gitfa8646d.1-2build4_arm64.deb ...\r\nUnpacking librtmp1:arm64 (2.4+20151223.gitfa8646d.1-2build4) ...\r\nSelecting previously unselected package libssh-4:arm64.\r\nPreparing to unpack .../12-libssh-4_0.9.6-2ubuntu0.22.04.2_arm64.deb ...\r\nUnpacking libssh-4:arm64 (0.9.6-2ubuntu0.22.04.2) ...\r\nSelecting previously unselected package libcurl3-gnutls:arm64.\r\nPreparing to unpack .../13-libcurl3-gnutls_7.81.0-1ubuntu1.15_arm64.deb ...\r\nUnpacking libcurl3-gnutls:arm64 (7.81.0-1ubuntu1.15) ...\r\nSelecting previously unselected package liberror-perl.\r\nPreparing to unpack .../14-liberror-perl_0.17029-1_all.deb ...\r\nUnpacking liberror-perl (0.17029-1) ...\r\nSelecting previously unselected package git-man.\r\nPreparing to unpack .../15-git-man_1%3a2.34.1-1ubuntu1.10_all.deb ...\r\nUnpacking git-man (1:2.34.1-1ubuntu1.10) ...\r\nSelecting previously unselected package git.\r\nPreparing to unpack .../16-git_1%3a2.34.1-1ubuntu1.10_arm64.deb ...\r\nUnpacking git (1:2.34.1-1ubuntu1.10) ...\r\nSelecting previously unselected package libldap-common.\r\nPreparing to unpack .../17-libldap-common_2.5.16+dfsg-0ubuntu0.22.04.1_all.deb ...\r\nUnpacking libldap-common (2.5.16+dfsg-0ubuntu0.22.04.1) ...\r\nSelecting previously unselected package libsasl2-modules:arm64.\r\nPreparing to unpack .../18-libsasl2-modules_2.1.27+dfsg2-3ubuntu1.2_arm64.deb ...\r\nUnpacking libsasl2-modules:arm64 (2.1.27+dfsg2-3ubuntu1.2) ...\r\nSelecting previously unselected package patch.\r\nPreparing to unpack .../19-patch_2.7.6-7build2_arm64.deb ...\r\nUnpacking patch (2.7.6-7build2) ...\r\nSetting up libbrotli1:arm64 (1.0.9-2build6) ...\r\nSetting up libsasl2-modules:arm64 (2.1.27+dfsg2-3ubuntu1.2) ...\r\nSetting up libnghttp2-14:arm64 (1.43.0-1ubuntu0.1) ...\r\nSetting up less (590-1ubuntu0.22.04.1) ...\r\nSetting up perl-modules-5.34 (5.34.0-3ubuntu1.3) ...\r\nSetting up libldap-common (2.5.16+dfsg-0ubuntu0.22.04.1) ...\r\nSetting up libsasl2-modules-db:arm64 (2.1.27+dfsg2-3ubuntu1.2) ...\r\nSetting up librtmp1:arm64 (2.4+20151223.gitfa8646d.1-2build4) ...\r\nSetting up patch (2.7.6-7build2) ...\r\nSetting up libsasl2-2:arm64 (2.1.27+dfsg2-3ubuntu1.2) ...\r\nSetting up libssh-4:arm64 (0.9.6-2ubuntu0.22.04.2) ...\r\nSetting up git-man (1:2.34.1-1ubuntu1.10) ...\r\nSetting up libgdbm6:arm64 (1.23-1) ...\r\nSetting up libldap-2.5-0:arm64 (2.5.16+dfsg-0ubuntu0.22.04.1) ...\r\nSetting up libgdbm-compat4:arm64 (1.23-1) ...\r\nSetting up libperl5.34:arm64 (5.34.0-3ubuntu1.3) ...\r\nSetting up libcurl3-gnutls:arm64 (7.81.0-1ubuntu1.15) ...\r\nSetting up perl (5.34.0-3ubuntu1.3) ...\r\nSetting up liberror-perl (0.17029-1) ...\r\nSetting up git (1:2.34.1-1ubuntu1.10) ...\r\nProcessing triggers for libc-bin (2.35-0ubuntu3.5) ...\r\n",
    "stdout_lines": [
        "Reading package lists...",
        "Building dependency tree...",
        "Reading state information...",
        "The following additional packages will be installed:",
        "  git-man less libbrotli1 libcurl3-gnutls liberror-perl libgdbm-compat4",
        "  libgdbm6 libldap-2.5-0 libldap-common libnghttp2-14 libperl5.34 librtmp1",
        "  libsasl2-2 libsasl2-modules libsasl2-modules-db libssh-4 patch perl",
        "  perl-modules-5.34",
        "Suggested packages:",
        "  gettext-base git-daemon-run | git-daemon-sysvinit git-doc git-email git-gui",
        "  gitk gitweb git-cvs git-mediawiki git-svn gdbm-l10n",
        "  libsasl2-modules-gssapi-mit | libsasl2-modules-gssapi-heimdal",
        "  libsasl2-modules-ldap libsasl2-modules-otp libsasl2-modules-sql ed",
        "  diffutils-doc perl-doc libterm-readline-gnu-perl",
        "  | libterm-readline-perl-perl make libtap-harness-archive-perl",
        "The following NEW packages will be installed:",
        "  git git-man less libbrotli1 libcurl3-gnutls liberror-perl libgdbm-compat4",
        "  libgdbm6 libldap-2.5-0 libldap-common libnghttp2-14 libperl5.34 librtmp1",
        "  libsasl2-2 libsasl2-modules libsasl2-modules-db libssh-4 patch perl",
        "  perl-modules-5.34",
        "0 upgraded, 20 newly installed, 0 to remove and 0 not upgraded.",
        "Need to get 13.7 MB of archives.",
        "After this operation, 72.2 MB of additional disk space will be used.",
        "Get:1 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 perl-modules-5.34 all 5.34.0-3ubuntu1.3 [2976 kB]",
        "Get:2 http://ports.ubuntu.com/ubuntu-ports jammy/main arm64 libgdbm6 arm64 1.23-1 [34.1 kB]",
        "Get:3 http://ports.ubuntu.com/ubuntu-ports jammy/main arm64 libgdbm-compat4 arm64 1.23-1 [6294 B]",
        "Get:4 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libperl5.34 arm64 5.34.0-3ubuntu1.3 [4723 kB]",
        "Get:5 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 perl arm64 5.34.0-3ubuntu1.3 [232 kB]",
        "Get:6 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 less arm64 590-1ubuntu0.22.04.1 [142 kB]",
        "Get:7 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libnghttp2-14 arm64 1.43.0-1ubuntu0.1 [76.1 kB]",
        "Get:8 http://ports.ubuntu.com/ubuntu-ports jammy/main arm64 libbrotli1 arm64 1.0.9-2build6 [314 kB]",
        "Get:9 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libsasl2-modules-db arm64 2.1.27+dfsg2-3ubuntu1.2 [21.1 kB]",
        "Get:10 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libsasl2-2 arm64 2.1.27+dfsg2-3ubuntu1.2 [55.6 kB]",
        "Get:11 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libldap-2.5-0 arm64 2.5.16+dfsg-0ubuntu0.22.04.1 [181 kB]",
        "Get:12 http://ports.ubuntu.com/ubuntu-ports jammy/main arm64 librtmp1 arm64 2.4+20151223.gitfa8646d.1-2build4 [59.2 kB]",
        "Get:13 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libssh-4 arm64 0.9.6-2ubuntu0.22.04.2 [185 kB]",
        "Get:14 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libcurl3-gnutls arm64 7.81.0-1ubuntu1.15 [279 kB]",
        "Get:15 http://ports.ubuntu.com/ubuntu-ports jammy/main arm64 liberror-perl all 0.17029-1 [26.5 kB]",
        "Get:16 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 git-man all 1:2.34.1-1ubuntu1.10 [954 kB]",
        "Get:17 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 git arm64 1:2.34.1-1ubuntu1.10 [3223 kB]",
        "Get:18 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libldap-common all 2.5.16+dfsg-0ubuntu0.22.04.1 [15.8 kB]",
        "Get:19 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libsasl2-modules arm64 2.1.27+dfsg2-3ubuntu1.2 [68.4 kB]",
        "Get:20 http://ports.ubuntu.com/ubuntu-ports jammy/main arm64 patch arm64 2.7.6-7build2 [105 kB]",
        "Fetched 13.7 MB in 23s (597 kB/s)",
        "Selecting previously unselected package perl-modules-5.34.",
        "(Reading database ... ",
        "(Reading database ... 5%",
        "(Reading database ... 10%",
        "(Reading database ... 15%",
        "(Reading database ... 20%",
        "(Reading database ... 25%",
        "(Reading database ... 30%",
        "(Reading database ... 35%",
        "(Reading database ... 40%",
        "(Reading database ... 45%",
        "(Reading database ... 50%",
        "(Reading database ... 55%",
        "(Reading database ... 60%",
        "(Reading database ... 65%",
        "(Reading database ... 70%",
        "(Reading database ... 75%",
        "(Reading database ... 80%",
        "(Reading database ... 85%",
        "(Reading database ... 90%",
        "(Reading database ... 95%",
        "(Reading database ... 100%",
        "(Reading database ... 54337 files and directories currently installed.)",
        "Preparing to unpack .../00-perl-modules-5.34_5.34.0-3ubuntu1.3_all.deb ...",
        "Unpacking perl-modules-5.34 (5.34.0-3ubuntu1.3) ...",
        "Selecting previously unselected package libgdbm6:arm64.",
        "Preparing to unpack .../01-libgdbm6_1.23-1_arm64.deb ...",
        "Unpacking libgdbm6:arm64 (1.23-1) ...",
        "Selecting previously unselected package libgdbm-compat4:arm64.",
        "Preparing to unpack .../02-libgdbm-compat4_1.23-1_arm64.deb ...",
        "Unpacking libgdbm-compat4:arm64 (1.23-1) ...",
        "Selecting previously unselected package libperl5.34:arm64.",
        "Preparing to unpack .../03-libperl5.34_5.34.0-3ubuntu1.3_arm64.deb ...",
        "Unpacking libperl5.34:arm64 (5.34.0-3ubuntu1.3) ...",
        "Selecting previously unselected package perl.",
        "Preparing to unpack .../04-perl_5.34.0-3ubuntu1.3_arm64.deb ...",
        "Unpacking perl (5.34.0-3ubuntu1.3) ...",
        "Selecting previously unselected package less.",
        "Preparing to unpack .../05-less_590-1ubuntu0.22.04.1_arm64.deb ...",
        "Unpacking less (590-1ubuntu0.22.04.1) ...",
        "Selecting previously unselected package libnghttp2-14:arm64.",
        "Preparing to unpack .../06-libnghttp2-14_1.43.0-1ubuntu0.1_arm64.deb ...",
        "Unpacking libnghttp2-14:arm64 (1.43.0-1ubuntu0.1) ...",
        "Selecting previously unselected package libbrotli1:arm64.",
        "Preparing to unpack .../07-libbrotli1_1.0.9-2build6_arm64.deb ...",
        "Unpacking libbrotli1:arm64 (1.0.9-2build6) ...",
        "Selecting previously unselected package libsasl2-modules-db:arm64.",
        "Preparing to unpack .../08-libsasl2-modules-db_2.1.27+dfsg2-3ubuntu1.2_arm64.deb ...",
        "Unpacking libsasl2-modules-db:arm64 (2.1.27+dfsg2-3ubuntu1.2) ...",
        "Selecting previously unselected package libsasl2-2:arm64.",
        "Preparing to unpack .../09-libsasl2-2_2.1.27+dfsg2-3ubuntu1.2_arm64.deb ...",
        "Unpacking libsasl2-2:arm64 (2.1.27+dfsg2-3ubuntu1.2) ...",
        "Selecting previously unselected package libldap-2.5-0:arm64.",
        "Preparing to unpack .../10-libldap-2.5-0_2.5.16+dfsg-0ubuntu0.22.04.1_arm64.deb ...",
        "Unpacking libldap-2.5-0:arm64 (2.5.16+dfsg-0ubuntu0.22.04.1) ...",
        "Selecting previously unselected package librtmp1:arm64.",
        "Preparing to unpack .../11-librtmp1_2.4+20151223.gitfa8646d.1-2build4_arm64.deb ...",
        "Unpacking librtmp1:arm64 (2.4+20151223.gitfa8646d.1-2build4) ...",
        "Selecting previously unselected package libssh-4:arm64.",
        "Preparing to unpack .../12-libssh-4_0.9.6-2ubuntu0.22.04.2_arm64.deb ...",
        "Unpacking libssh-4:arm64 (0.9.6-2ubuntu0.22.04.2) ...",
        "Selecting previously unselected package libcurl3-gnutls:arm64.",
        "Preparing to unpack .../13-libcurl3-gnutls_7.81.0-1ubuntu1.15_arm64.deb ...",
        "Unpacking libcurl3-gnutls:arm64 (7.81.0-1ubuntu1.15) ...",
        "Selecting previously unselected package liberror-perl.",
        "Preparing to unpack .../14-liberror-perl_0.17029-1_all.deb ...",
        "Unpacking liberror-perl (0.17029-1) ...",
        "Selecting previously unselected package git-man.",
        "Preparing to unpack .../15-git-man_1%3a2.34.1-1ubuntu1.10_all.deb ...",
        "Unpacking git-man (1:2.34.1-1ubuntu1.10) ...",
        "Selecting previously unselected package git.",
        "Preparing to unpack .../16-git_1%3a2.34.1-1ubuntu1.10_arm64.deb ...",
        "Unpacking git (1:2.34.1-1ubuntu1.10) ...",
        "Selecting previously unselected package libldap-common.",
        "Preparing to unpack .../17-libldap-common_2.5.16+dfsg-0ubuntu0.22.04.1_all.deb ...",
        "Unpacking libldap-common (2.5.16+dfsg-0ubuntu0.22.04.1) ...",
        "Selecting previously unselected package libsasl2-modules:arm64.",
        "Preparing to unpack .../18-libsasl2-modules_2.1.27+dfsg2-3ubuntu1.2_arm64.deb ...",
        "Unpacking libsasl2-modules:arm64 (2.1.27+dfsg2-3ubuntu1.2) ...",
        "Selecting previously unselected package patch.",
        "Preparing to unpack .../19-patch_2.7.6-7build2_arm64.deb ...",
        "Unpacking patch (2.7.6-7build2) ...",
        "Setting up libbrotli1:arm64 (1.0.9-2build6) ...",
        "Setting up libsasl2-modules:arm64 (2.1.27+dfsg2-3ubuntu1.2) ...",
        "Setting up libnghttp2-14:arm64 (1.43.0-1ubuntu0.1) ...",
        "Setting up less (590-1ubuntu0.22.04.1) ...",
        "Setting up perl-modules-5.34 (5.34.0-3ubuntu1.3) ...",
        "Setting up libldap-common (2.5.16+dfsg-0ubuntu0.22.04.1) ...",
        "Setting up libsasl2-modules-db:arm64 (2.1.27+dfsg2-3ubuntu1.2) ...",
        "Setting up librtmp1:arm64 (2.4+20151223.gitfa8646d.1-2build4) ...",
        "Setting up patch (2.7.6-7build2) ...",
        "Setting up libsasl2-2:arm64 (2.1.27+dfsg2-3ubuntu1.2) ...",
        "Setting up libssh-4:arm64 (0.9.6-2ubuntu0.22.04.2) ...",
        "Setting up git-man (1:2.34.1-1ubuntu1.10) ...",
        "Setting up libgdbm6:arm64 (1.23-1) ...",
        "Setting up libldap-2.5-0:arm64 (2.5.16+dfsg-0ubuntu0.22.04.1) ...",
        "Setting up libgdbm-compat4:arm64 (1.23-1) ...",
        "Setting up libperl5.34:arm64 (5.34.0-3ubuntu1.3) ...",
        "Setting up libcurl3-gnutls:arm64 (7.81.0-1ubuntu1.15) ...",
        "Setting up perl (5.34.0-3ubuntu1.3) ...",
        "Setting up liberror-perl (0.17029-1) ...",
        "Setting up git (1:2.34.1-1ubuntu1.10) ...",
        "Processing triggers for libc-bin (2.35-0ubuntu3.5) ..."
    ]
}
```

Vamos verificar se o git ja esta instalado!
```bash
❯ docker exec -it node1 bash

root@node1:/# git
usage: git [--version] [--help] [-C <path>] [-c <name>=<value>]
           [--exec-path[=<path>]] [--html-path] [--man-path] [--info-path]
           [-p | --paginate | -P | --no-pager] [--no-replace-objects] [--bare]
           [--git-dir=<path>] [--work-tree=<path>] [--namespace=<name>]
           [--super-prefix=<path>] [--config-env=<name>=<envvar>]
           <command> [<args>]

These are common Git commands used in various situations:

start a working area (see also: git help tutorial)
   clone     Clone a repository into a new directory
   init      Create an empty Git repository or reinitialize an existing one

work on the current change (see also: git help everyday)
   add       Add file contents to the index
   mv        Move or rename a file, a directory, or a symlink
   restore   Restore working tree files
   rm        Remove files from the working tree and from the index

examine the history and state (see also: git help revisions)
   bisect    Use binary search to find the commit that introduced a bug
   diff      Show changes between commits, commit and working tree, etc
   grep      Print lines matching a pattern
   log       Show commit logs
   show      Show various types of objects
   status    Show the working tree status

grow, mark and tweak your common history
   branch    List, create, or delete branches
   commit    Record changes to the repository
   merge     Join two or more development histories together
   rebase    Reapply commits on top of another base tip
   reset     Reset current HEAD to the specified state
   switch    Switch branches
   tag       Create, list, delete or verify a tag object signed with GPG

collaborate (see also: git help workflows)
   fetch     Download objects and refs from another repository
   pull      Fetch from and integrate with another repository or a local branch
   push      Update remote refs along with associated objects

'git help -a' and 'git help -g' list available subcommands and some
concept guides. See 'git help <command>' or 'git help <concept>'
to read about a specific subcommand or concept.
See 'git help git' for an overview of the system.
```

Agora, vamos fazer o chckout de um repo
```bash
root@control:~/ansible# ansible -i hosts all -m git -a "repo=https://github.com/codeedu/fc2-terraform dest=/root/terraform-repo"
node2 | CHANGED => {
    "after": "e4e1c02086f192b259cce4e42b16baadebacb118",
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "before": null,
    "changed": true
}
node1 | CHANGED => {
    "after": "e4e1c02086f192b259cce4e42b16baadebacb118",
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "before": null,
    "changed": true
}
```

Pronto! Ele deu como alterado. amos ver no node1
```bash
root@node1:/# ls /root/terraform-repo/
main.tf  modules  terraform.tfvars  variables.tf
```

Foi! Instalamos o git e baixamos o repositprio!

O mais legal eh que conseguimos entender os detalhes de cada uma das maquinas!
```bash
ansible -i hosts all -m setup
...
                "major": 3,
                "micro": 12,
                "minor": 10,
                "releaselevel": "final",
                "serial": 0
            },
            "version_info": [
                3,
                10,
                12,
                "final",
                0
            ]
        },
        "ansible_python_version": "3.10.12",
        "ansible_real_group_id": 0,
        "ansible_real_user_id": 0,
        "ansible_selinux": {
            "status": "disabled"
        },
        "ansible_selinux_python_present": true,
        "ansible_service_mgr": "tail",
        "ansible_ssh_host_key_ecdsa_public": "AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLg+jRl0ZPFCPM8XbKzn5CkmbVctqG/uII5pWNM79RkpSyq9iq6LD76Vlvr2sCTel9DdOpHfOA76F4+wHpsCvpE=",
        "ansible_ssh_host_key_ecdsa_public_keytype": "ecdsa-sha2-nistp256",
        "ansible_ssh_host_key_ed25519_public": "AAAAC3NzaC1lZDI1NTE5AAAAIDSKxfzhdhdKuVHw5K71jovN6iEg07OmVIFY+QNXVhDn",
        "ansible_ssh_host_key_ed25519_public_keytype": "ssh-ed25519",
        "ansible_ssh_host_key_rsa_public": "AAAAB3NzaC1yc2EAAAADAQABAAABgQDlT8cSgEpTKk/5TSo1DVF83FCapP5E3Yub0rEK8fkaCwdA6KgIFq0Cfj0lmYq1BP8oZVRq9Yzv6Csv/x+K8IcXHPcGYcBnOP/D3eGlWh0mjW4OQTmNEW5Gww63scppVZkYzz+9GC/k6xTLpH0iZ+NIMRb1khtGvLbkjMSPegw1S2X/eY6xeSln1tWwOCaFgsWXyCKyK/iddA3OvUTC7fa5FUvHETgxkzobauc0SDL7PE23LmJEf4htlbtiNzNFXdiI/UgEfLtKP4jezLEq2hOA0oNQ217Ncmf6oaBItYwPeUbAt8u4/c3s++SEfZzjVd7YtehqjZHeqRSdLqDMd4tcoMuL2NsUQyWmmyMaW3Za3Rj6kFag3pi1I8W7462PgFbSQovsc0w/xZcVbFpK/XknbRZPMP81LlZ8mzEmp/4vU2mjWckeQvxp92uKjfE4ejDyaUG74/4OlVJsdBE1vgL06wlR47xFdYn7MRmGinQP0B6hNBgp8V34IgFkAqyoi3M=",
        "ansible_ssh_host_key_rsa_public_keytype": "ssh-rsa",
        "ansible_swapfree_mb": 0,
        "ansible_swaptotal_mb": 1535,
        "ansible_system": "Linux",
        "ansible_system_vendor": "NA",
        "ansible_uptime_seconds": 2549,
        "ansible_user_dir": "/root",
        "ansible_user_gecos": "root",
        "ansible_user_gid": 0,
        "ansible_user_id": "root",
        "ansible_user_shell": "/bin/bash",
        "ansible_user_uid": 0,
        "ansible_userspace_bits": "64",
        "ansible_virtualization_role": "guest",
        "ansible_virtualization_type": "docker",
        "discovered_interpreter_python": "/usr/bin/python3",
        "gather_subset": [
            "all"
        ],
        "module_setup": true
    },
    "changed": false
}
node1 | SUCCESS => {
    "ansible_facts": {
        "ansible_apparmor": {
            "status": "disabled"
        },
        "ansible_architecture": "aarch64",
        "ansible_bios_date": "NA",
        "ansible_bios_vendor": "NA",
        "ansible_bios_version": "NA",
        "ansible_board_asset_tag": "NA",
        "ansible_board_name": "NA",
        "ansible_board_serial": "NA",
        "ansible_board_vendor": "NA",
        "ansible_board_version": "NA",
        "ansible_chassis_asset_tag": "NA",
        "ansible_chassis_serial": "NA",
        "ansible_chassis_vendor": "NA",
        "ansible_chassis_version": "NA",
        "ansible_cmdline": {
            "com.docker.VMID": "c64dcdc7-4a55-4472-b75a-cde572434577",
            "console": "hvc0",
            "eth0.IPNet": "192.168.65.3/24",
            "eth0.mtu": "65535",
            "eth0.router": "192.168.65.1",
            "eth1.dhcp": true,
            "init": "/init",
            "irqaffinity": "0",
            "linuxkit.unified_cgroup_hierarchy": "1",
            "loglevel": "1",
            "mitigations": "off",
            "no_stf_barrier": true,
            "noibpb": true,
            "noibrs": true,
            "nospec_store_bypass_disable": true,
            "panic": "0",
            "root": "/dev/vdb",
            "virtio_net.disable_csum": "1",
            "vpnkit.connect": "connect://2/1999",
            "vpnkit.disable": "osxfs-data",
            "vsyscall": "emulate"
        },
        "ansible_date_time": {
            "date": "2024-01-05",
            "day": "05",
            "epoch": "1704467875",
            "hour": "15",
            "iso8601": "2024-01-05T15:17:55Z",
            "iso8601_basic": "20240105T151755613614",
            "iso8601_basic_short": "20240105T151755",
            "iso8601_micro": "2024-01-05T15:17:55.613614Z",
            "minute": "17",
            "month": "01",
            "second": "55",
            "time": "15:17:55",
            "tz": "UTC",
            "tz_offset": "+0000",
            "weekday": "Friday",
            "weekday_number": "5",
            "weeknumber": "01",
            "year": "2024"
        },
        "ansible_device_links": {
            "ids": {},
            "labels": {},
            "masters": {},
            "uuids": {}
        },
        "ansible_devices": {
            "loop0": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "1",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "none",
                "sectors": "0",
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "loop1": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "1",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "none",
                "sectors": "0",
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "loop2": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "1",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "none",
                "sectors": "0",
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "loop3": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "1",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "none",
                "sectors": "0",
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "loop4": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "1",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "none",
                "sectors": "0",
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "loop5": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "1",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "none",
                "sectors": "0",
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "loop6": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "1",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "none",
                "sectors": "0",
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "loop7": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "1",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "none",
                "sectors": "0",
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "nbd0": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "0",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "mq-deadline",
                "sectors": "0",
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "nbd1": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "0",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "mq-deadline",
                "sectors": "0",
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "nbd10": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "0",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "mq-deadline",
                "sectors": "0",
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "nbd11": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "0",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "mq-deadline",
                "sectors": "0",
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "nbd12": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "0",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "mq-deadline",
                "sectors": "0",
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "nbd13": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "0",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "mq-deadline",
                "sectors": "0",
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "nbd14": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "0",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "mq-deadline",
                "sectors": "0",
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "nbd15": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "0",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "mq-deadline",
                "sectors": "0",
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "nbd2": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "0",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "mq-deadline",
                "sectors": "0",
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "nbd3": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "0",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "mq-deadline",
                "sectors": "0",
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "nbd4": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "0",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "mq-deadline",
                "sectors": "0",
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "nbd5": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "0",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "mq-deadline",
                "sectors": "0",
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "nbd6": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "0",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "mq-deadline",
                "sectors": "0",
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "nbd7": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "0",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "mq-deadline",
                "sectors": "0",
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "nbd8": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "0",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "mq-deadline",
                "sectors": "0",
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "nbd9": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "0",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "mq-deadline",
                "sectors": "0",
                "sectorsize": "512",
                "size": "0.00 Bytes",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            },
            "vda": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {
                    "vda1": {
                        "holders": [],
                        "links": {
                            "ids": [],
                            "labels": [],
                            "masters": [],
                            "uuids": []
                        },
                        "sectors": "156248064",
                        "sectorsize": 512,
                        "size": "74.50 GB",
                        "start": "2048",
                        "uuid": null
                    }
                },
                "removable": "0",
                "rotational": "1",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "mq-deadline",
                "sectors": "156250112",
                "sectorsize": "512",
                "size": "74.51 GB",
                "support_discard": "512",
                "vendor": "0x1af4",
                "virtual": 1
            },
            "vdb": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": null,
                "partitions": {},
                "removable": "0",
                "rotational": "1",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "mq-deadline",
                "sectors": "2236536",
                "sectorsize": "512",
                "size": "1.07 GB",
                "support_discard": "0",
                "vendor": "0x1af4",
                "virtual": 1
            }
        },
        "ansible_distribution": "Ubuntu",
        "ansible_distribution_file_parsed": true,
        "ansible_distribution_file_path": "/etc/os-release",
        "ansible_distribution_file_variety": "Debian",
        "ansible_distribution_major_version": "22",
        "ansible_distribution_release": "jammy",
        "ansible_distribution_version": "22.04",
        "ansible_dns": {
            "nameservers": [
                "127.0.0.11"
            ],
            "options": {
                "ndots": "0"
            }
        },
        "ansible_domain": "",
        "ansible_effective_group_id": 0,
        "ansible_effective_user_id": 0,
        "ansible_env": {
            "HOME": "/root",
            "LC_CTYPE": "C.UTF-8",
            "LOGNAME": "root",
            "MOTD_SHOWN": "pam",
            "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin",
            "PWD": "/root",
            "SHELL": "/bin/bash",
            "SHLVL": "0",
            "SSH_CLIENT": "172.22.0.3 50834 22",
            "SSH_CONNECTION": "172.22.0.3 50834 172.22.0.2 22",
            "SSH_TTY": "/dev/pts/1",
            "TERM": "xterm",
            "USER": "root",
            "_": "/bin/sh"
        },
        "ansible_fibre_channel_wwn": [],
        "ansible_fips": false,
        "ansible_form_factor": "NA",
        "ansible_fqdn": "node1",
        "ansible_hostname": "node1",
        "ansible_hostnqn": "",
        "ansible_is_chroot": false,
        "ansible_iscsi_iqn": "",
        "ansible_kernel": "6.4.16-linuxkit",
        "ansible_kernel_version": "#1 SMP PREEMPT Thu Nov 16 10:49:20 UTC 2023",
        "ansible_local": {},
        "ansible_lsb": {
            "codename": "jammy",
            "description": "Ubuntu 22.04.3 LTS",
            "id": "Ubuntu",
            "major_release": "22",
            "release": "22.04"
        },
        "ansible_machine": "aarch64",
        "ansible_machine_id": "ea963c6b8dd7483390661b61497bfb68",
        "ansible_memfree_mb": 101,
        "ansible_memory_mb": {
            "nocache": {
                "free": 1011,
                "used": 6933
            },
            "real": {
                "free": 101,
                "total": 7944,
                "used": 7843
            },
            "swap": {
                "cached": 213,
                "free": 0,
                "total": 1535,
                "used": 1535
            }
        },
        "ansible_memtotal_mb": 7944,
        "ansible_mounts": [
            {
                "block_available": 3062316,
                "block_size": 4096,
                "block_total": 19145185,
                "block_used": 16082869,
                "device": "/dev/vda1",
                "fstype": "ext4",
                "inode_available": 3878681,
                "inode_total": 4890624,
                "inode_used": 1011943,
                "mount": "/etc/resolv.conf",
                "options": "rw,relatime,discard,bind",
                "size_available": 12543246336,
                "size_total": 78418677760,
                "uuid": "N/A"
            },
            {
                "block_available": 3062316,
                "block_size": 4096,
                "block_total": 19145185,
                "block_used": 16082869,
                "device": "/dev/vda1",
                "fstype": "ext4",
                "inode_available": 3878681,
                "inode_total": 4890624,
                "inode_used": 1011943,
                "mount": "/etc/hostname",
                "options": "rw,relatime,discard,bind",
                "size_available": 12543246336,
                "size_total": 78418677760,
                "uuid": "N/A"
            },
            {
                "block_available": 3062316,
                "block_size": 4096,
                "block_total": 19145185,
                "block_used": 16082869,
                "device": "/dev/vda1",
                "fstype": "ext4",
                "inode_available": 3878681,
                "inode_total": 4890624,
                "inode_used": 1011943,
                "mount": "/etc/hosts",
                "options": "rw,relatime,discard,bind",
                "size_available": 12543246336,
                "size_total": 78418677760,
                "uuid": "N/A"
            }
        ],
        "ansible_nodename": "node1",
        "ansible_os_family": "Debian",
        "ansible_pkg_mgr": "apt",
        "ansible_proc_cmdline": {
            "com.docker.VMID": "c64dcdc7-4a55-4472-b75a-cde572434577",
            "console": "hvc0",
            "eth0.IPNet": "192.168.65.3/24",
            "eth0.mtu": "65535",
            "eth0.router": "192.168.65.1",
            "eth1.dhcp": true,
            "init": "/init",
            "irqaffinity": "0",
            "linuxkit.unified_cgroup_hierarchy": "1",
            "loglevel": "1",
            "mitigations": "off",
            "no_stf_barrier": true,
            "noibpb": true,
            "noibrs": true,
            "nospec_store_bypass_disable": true,
            "panic": "0",
            "root": "/dev/vdb",
            "virtio_net.disable_csum": "1",
            "vpnkit.connect": "connect://2/1999",
            "vpnkit.disable": "osxfs-data",
            "vsyscall": "emulate"
        },
        "ansible_processor": [
            "0",
            "1",
            "2",
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9"
        ],
        "ansible_processor_cores": 1,
        "ansible_processor_count": 10,
        "ansible_processor_nproc": 10,
        "ansible_processor_threads_per_core": 1,
        "ansible_processor_vcpus": 10,
        "ansible_product_name": "NA",
        "ansible_product_serial": "NA",
        "ansible_product_uuid": "NA",
        "ansible_product_version": "NA",
        "ansible_python": {
            "executable": "/usr/bin/python3",
            "has_sslcontext": true,
            "type": "cpython",
            "version": {
                "major": 3,
                "micro": 12,
                "minor": 10,
                "releaselevel": "final",
                "serial": 0
            },
            "version_info": [
                3,
                10,
                12,
                "final",
                0
            ]
        },
        "ansible_python_version": "3.10.12",
        "ansible_real_group_id": 0,
        "ansible_real_user_id": 0,
        "ansible_selinux": {
            "status": "disabled"
        },
        "ansible_selinux_python_present": true,
        "ansible_service_mgr": "tail",
        "ansible_ssh_host_key_ecdsa_public": "AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLg+jRl0ZPFCPM8XbKzn5CkmbVctqG/uII5pWNM79RkpSyq9iq6LD76Vlvr2sCTel9DdOpHfOA76F4+wHpsCvpE=",
        "ansible_ssh_host_key_ecdsa_public_keytype": "ecdsa-sha2-nistp256",
        "ansible_ssh_host_key_ed25519_public": "AAAAC3NzaC1lZDI1NTE5AAAAIDSKxfzhdhdKuVHw5K71jovN6iEg07OmVIFY+QNXVhDn",
        "ansible_ssh_host_key_ed25519_public_keytype": "ssh-ed25519",
        "ansible_ssh_host_key_rsa_public": "AAAAB3NzaC1yc2EAAAADAQABAAABgQDlT8cSgEpTKk/5TSo1DVF83FCapP5E3Yub0rEK8fkaCwdA6KgIFq0Cfj0lmYq1BP8oZVRq9Yzv6Csv/x+K8IcXHPcGYcBnOP/D3eGlWh0mjW4OQTmNEW5Gww63scppVZkYzz+9GC/k6xTLpH0iZ+NIMRb1khtGvLbkjMSPegw1S2X/eY6xeSln1tWwOCaFgsWXyCKyK/iddA3OvUTC7fa5FUvHETgxkzobauc0SDL7PE23LmJEf4htlbtiNzNFXdiI/UgEfLtKP4jezLEq2hOA0oNQ217Ncmf6oaBItYwPeUbAt8u4/c3s++SEfZzjVd7YtehqjZHeqRSdLqDMd4tcoMuL2NsUQyWmmyMaW3Za3Rj6kFag3pi1I8W7462PgFbSQovsc0w/xZcVbFpK/XknbRZPMP81LlZ8mzEmp/4vU2mjWckeQvxp92uKjfE4ejDyaUG74/4OlVJsdBE1vgL06wlR47xFdYn7MRmGinQP0B6hNBgp8V34IgFkAqyoi3M=",
        "ansible_ssh_host_key_rsa_public_keytype": "ssh-rsa",
        "ansible_swapfree_mb": 0,
        "ansible_swaptotal_mb": 1535,
        "ansible_system": "Linux",
        "ansible_system_vendor": "NA",
        "ansible_uptime_seconds": 2549,
        "ansible_user_dir": "/root",
        "ansible_user_gecos": "root",
        "ansible_user_gid": 0,
        "ansible_user_id": "root",
        "ansible_user_shell": "/bin/bash",
        "ansible_user_uid": 0,
        "ansible_userspace_bits": "64",
        "ansible_virtualization_role": "guest",
        "ansible_virtualization_type": "docker",
        "discovered_interpreter_python": "/usr/bin/python3",
        "gather_subset": [
            "all"
        ],
        "module_setup": true
    },
    "changed": false
}
```

Essas sao todas as informaçoes que o ansible tem sobre a maquina que esta rodando em cima! 

Consegummos ateh rodar comandos sh puro:
```bash
root@control:~/ansible# ansible -i hosts node1 -m shell -a "ls -la"
node1 | CHANGED | rc=0 >>
total 36
drwx------ 1 root root 4096 Jan  5 15:15 .
drwxr-xr-x 1 root root 4096 Jan  5 14:38 ..
drwx------ 3 root root 4096 Jan  5 14:53 .ansible
-rw------- 1 root root   50 Jan  5 14:57 .bash_history
-rw-r--r-- 1 root root 3106 Oct 15  2021 .bashrc
drwx------ 2 root root 4096 Jan  5 14:48 .cache
-rw-r--r-- 1 root root  161 Jul  9  2019 .profile
drwx------ 2 root root 4096 Jan  5 14:48 .ssh
drwxr-xr-x 4 root root 4096 Jan  5 15:15 terraform-repo
```

Imagina tudo isso podendo rodar git, deploy no k8s instalar docker, remover pacotes etc!

Quando temos modulos que executam comandos de formas super simples e automatizada, a nossa vida muda completamete!

Entao, subimos toda a nossa infra utilizando o terraform e as configuraçoes usando os comnados do ansible!!!

O mais legal de tudo isso eh que no final das contas o ansible apenas entra via ssh e aplica os comandos.

E entao o playbook executa passo a passo.

Vamos instalar um nginx nas duas máquinas!
```bash
root@control:~/ansible# ansible -i hosts all -m apt -a "update_cache=yes name=nginx state=present"
```
E entao se formos no node1 e dermos o comando nginx para começar a rodar e depois verificar o processo:
```bash
root@node1:/# nginx
root@node1:/# ps -aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.0   2236   256 ?        Ss   14:38   0:00 tail -f /dev/null
root          32  0.0  0.0  15168  1900 ?        Ss   14:41   0:00 sshd: /usr/sbin/sshd [listener] 0 of 
sshd          35  0.0  0.0      0     0 ?        Z    14:41   0:00 [sshd] <defunct>
sshd          37  0.0  0.0      0     0 ?        Z    14:47   0:00 [sshd] <defunct>
sshd          39  0.0  0.0      0     0 ?        Z    14:47   0:00 [sshd] <defunct>
root         925  0.0  0.0   4136  2048 pts/0    Ss   15:12   0:00 bash
root        1780  0.0  0.0  54984  2120 ?        Ss   15:25   0:00 nginx: master process nginx
www-data    1781  0.0  0.0  55676  6344 ?        S    15:25   0:00 nginx: worker process
www-data    1782  0.0  0.0  55676  6344 ?        S    15:25   0:00 nginx: worker process
www-data    1783  0.0  0.0  55676  6344 ?        S    15:25   0:00 nginx: worker process
www-data    1784  0.0  0.0  55676  6344 ?        S    15:25   0:00 nginx: worker process
www-data    1785  0.0  0.0  55676  6344 ?        S    15:25   0:00 nginx: worker process
www-data    1786  0.0  0.0  55676  6344 ?        S    15:25   0:00 nginx: worker process
www-data    1787  0.0  0.0  55676  6344 ?        S    15:25   0:00 nginx: worker process
www-data    1788  0.0  0.0  55676  6344 ?        S    15:25   0:00 nginx: worker process
www-data    1789  0.0  0.0  55676  6344 ?        S    15:25   0:00 nginx: worker process
www-data    1790  0.0  0.0  55676  6344 ?        S    15:25   0:00 nginx: worker process
root        1791  0.0  0.0   7384  2688 pts/0    R+   15:25   0:00 ps -aux
root@node1:/# 
```

Observamos o nginx rodando. 

Para desisntalar:
```bash
root@control:~/ansible# ansib
le -i hosts all -m apt -a "update_cache=yes name=nginx state=absent"
```

Se formos ver os processos, ela ainda esta rodando pq fica na memoria. Basta darmos um kill no processo
```bash
root@node1:/# ps -aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.0   2236   256 ?        Ss   14:38   0:00 tail -f /
root          32  0.0  0.0  15168  1772 ?        Ss   14:41   0:00 sshd: /us
sshd          35  0.0  0.0      0     0 ?        Z    14:41   0:00 [sshd] <d
sshd          37  0.0  0.0      0     0 ?        Z    14:47   0:00 [sshd] <d
sshd          39  0.0  0.0      0     0 ?        Z    14:47   0:00 [sshd] <d
root         925  0.0  0.0   4136  2176 pts/0    Ss   15:12   0:00 bash
root        1780  0.0  0.0  54984  1992 ?        Ss   15:25   0:00 nginx: ma
www-data    1781  0.0  0.0  55676  4296 ?        S    15:25   0:00 nginx: wo
www-data    1782  0.0  0.0  55676  4168 ?        S    15:25   0:00 nginx: wo
www-data    1783  0.0  0.0  55676  4168 ?        S    15:25   0:00 nginx: wo
www-data    1784  0.0  0.0  55676  4296 ?        S    15:25   0:00 nginx: wo
www-data    1785  0.0  0.0  55676  4168 ?        S    15:25   0:00 nginx: wo
www-data    1786  0.0  0.0  55676  4168 ?        S    15:25   0:00 nginx: wo
www-data    1787  0.0  0.0  55676  4168 ?        S    15:25   0:00 nginx: wo
www-data    1788  0.0  0.0  55676  4168 ?        S    15:25   0:00 nginx: wo
www-data    1789  0.0  0.0  55676  4168 ?        S    15:25   0:00 nginx: wo
www-data    1790  0.0  0.0  55676  4168 ?        S    15:25   0:00 nginx: wo
root        2045  0.0  0.0   7384  2688 pts/0    R+   15:28   0:00 ps -aux


root@node1:/# kill 1780


root@node1:/# ps -aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.0   2236   256 ?        Ss   14:38   0:00 tail -f /
root          32  0.0  0.0  15168  1772 ?        Ss   14:41   0:00 sshd: /us
sshd          35  0.0  0.0      0     0 ?        Z    14:41   0:00 [sshd] <d
sshd          37  0.0  0.0      0     0 ?        Z    14:47   0:00 [sshd] <d
sshd          39  0.0  0.0      0     0 ?        Z    14:47   0:00 [sshd] <d
root         925  0.0  0.0   4136  2176 pts/0    Ss   15:12   0:00 bash
root        1780  0.0  0.0      0     0 ?        Zs   15:25   0:00 [nginx] <
root        2049  0.0  0.0   7384  2688 pts/0    R+   15:29   0:00 ps -aux
```

Uma das coisas mais importantes, o ansible sempre vai executar orientado a uma maquina, apesar de ser possivel realizar algumas tarefas sobre ele mesmo.

Sobre o nginx, se instalarmos dentro da propria maquina, eh possivel deseinstalar via ansible!


# Trabalhando com Playbooks








