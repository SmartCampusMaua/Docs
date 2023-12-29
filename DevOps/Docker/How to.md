docker ps
docker ps -a
docker stop ID/Name
docker rm ID/Name
docker rm ID/Name -f
docker run ubuntu bash
docker run nginx
docker run -p 80:80 nginx
docker run -d -p 80:80 nginx 
docker run --name nginx -d -p 8080:80 nginx
docker exec nginx ls

docker exec -it nginx bash
apt-get update # for update the apt cache
apt-get install vim



![Name](/Docker/_lib/img/_)


A imagem no docker é imutável e nao conseguimos escrever no container em execução!
-v Cria a pasta na máquina host mesmo que ela nao exista (old)

```docker run -d --name nginx -p 8080:80 -v ~/PATH/TO/THE/FILE:/usr/share/nginx/html nginx```


--mount NÃO cria a pasta caso ela não exista
`docker run -d --name nginx -p 8080:80 --mount type=bind,source="$(pwd)"/html,target=/usr/share/nginx/html nginx`


 Volumes
`docker volume [create/inspect/ls/prune/rm]`





# É possível mapear um volume para varios containers ao mesmo tempo
`docker volume ls`
`docker volume create meuvolume`
`docker volume ls`
`docker volume inspect meuvolume`
`docker run -d --name nginx -p 8080:80 --mount type=volume,source=meuvolume,target=/app nginx` 
`docker exec -it nginx bash # target /app created!`
`cd app`
`touch oi`
`exit`
`docker run -d --name nginx -p 8081:80 --mount type=volume,source=meuvolume,target=/app nginx`
`docker exec -it nginx2 bash`
`cd app`
`ls #oi`
`touch oi2`
`exit`
`docker exec -it nginx bash`
`cd app`
`ls #oi oi2`
`docker run -d --name nginx3 -p 8082:80 -v meuvolume:/app nginx`
`docker exec -it nginx3 bash`
`cd app`
`ls #oi oi2`

`#Remove all volumes`
`docker volume prune`

`docker ps -a -q # Apenas os IDs do Container`
`docker rm $(docker ps -a -q) -f # Remove de maneira forçada todos os containeres ativos e nao ativos`





# Imagens!
docker hub é o container registry do docker.
As tags são as versoes das imagens.
Dockerpull simplesmente baixa as imagens para o pc do container registry.
Docker hub é o conatine registry do docker, mas podem existir outros registries.
Caso o nome da imagem nao tenha um prefixo, isso significa que elas vêm do docker registry do docker hub.
Caso a camada de overlay filesystem já existir no PC, o docker pull não precisa baixar novamente.

`docker images`
`docker pull php`
`docker pull php:rc-alpine`
`docker rmi php:latest #rmi` -> remove image
`docker rmi php:rc-alpine`

Dockerfile
Criar imagens personalizadas
`docker build -t rogeriocassares/nginx:latest .`
`docker images`
`docker run -it rogeriocassares/nginx-com-vim bash`
`vim oi # ok!`

WORKDIR -> Cria a pasta e direciona o usuário para ela!


# Entrypoint vs CMD
`CMD [ "Hello!"]`

`docker build -t rogeriocassares/hello .`
`docker run --rm rogeriocassares/hello:latest`

O CMD pode ser substituido por um comando no terminal.
Tudo o que for colocado depois do nome da imagem no run, vai substituir os CMDs no Dockerfile.
`docker run --rm rogeriocassares/hello echo "oi"`



Resumidamente:

`ENTRYPOINT` é definido na criação do doker file, pode ser uma função `sleep` por exemplo.

`CMD` é mais como um argumento, pode ser um argumento da função definida pelo `ENTRYPOINT`, por exemplo `10` segundos.

`docker run example 10` -> somente `CMD` de 10 segundos

`docker run --entrypoint sleep2.0 example 10` -> muda da função do `ENTRYPOINT` para `sleep2.0`, com um `CMD` de 10 segundos



# Entrypoint 
`ENTRYPOINT [ "echo", "Hi!" ]`

ENTRYPOINT é um comando fixo, enquando CMD é variável.

Tudo o que for colocado em um CMD depois do ENTRYPOINT ou através do terminal após a imagem no docker run vai ser passado como parâmetro ao comando do entrypoint!



O que está escrito no CMD dentro do Dockerfile vai como default, podendo ser substituido pelos comandos do docker run.



No arquivo de Dockerfile do Nginx, por exemplo, pode ser observado:

`COPY docker-entrypoint.sh /`

`...`

`ENTRYPOINT ["/docker-entrypoint.sh"]`

`EXPOSE 80`

`CMD ["nginx", "-g", "daemon off;"]`



Isso significa que o arquivo de entrypoint foi copiado para dentro do container, o comando fixo docker-entrypoint.sh foi executado e então os comandos CMDs, variáveis, foram executados como parametros do descrito em ENTRYPOINT:

`/docker-entrypoint.sh nginx -g  daemon off;`



Logo, quando passsamos:

`docker run -d --rm -p 8080:80 nginx bash`

o comando `bash` é executado no lugar do `default`, descrito no CMD do Dockerfile.



Verificando o docker-entrypoint.sh, verificou-se que ele termina com exec "$@". Por isso, todo arquivo .sh que termina com exec "$@",  significa que ele vai aceitar os parâmetros do que foi passado depois deste arquivo docker-entrypoint.sh. Este exec executa o que vem depois do entrypoint:

`./docker-entrypoint.sh echo "hello"`

`hello`

CMD sempre vai depois do ENTRYPOINT, mas se nao tiver nada no ENTRYPOINT vai ser o comando que será executado.



# Docker Push

`docker build -t rogeriocassares/nginx-fullcycle .`

`docker run --rm -d -p 8080:80 rogeriocassares/nginx-fullcycle` 

`docker login`

`Username:`

`Password:`

`docker push rogeriocassares/nginx-fullcycle`





# Network

Rede interna que roda dentro do docker. Principalmente para um container se comunicar um com o outro.

Tipos de network:  

**bridge**: Um container se comunica facilmente com o outro

**host**: Mescla a network do docker com a network do host do docker. Por exemplo, ao subir um container na porta 80, utilizando essa network, um container sobe a porta 80 na própria máquina local. isto é, o container e a própria máquina acabam entrando na mesma rede.

Portanto, a máquina pode acessar uma porta direta no container sem precisar fazer a exposição de portas no Dockerfile. Os containeres participam da mesma rede do computador.

**overlay**: Vários Dockers em computadores diferentes e precisamos que esses containeres se comuniquem parecendo que estão na mesma rede. Docker swarm cria um cluster de vários dockers sendo executados para que possam ser escalados. Então para que um container consiga conversar com o outro em máquinas diferentes, eles precisam estar em uma overlay network.

**maclan**: Pode ser configurada um macaddress para uma máquina/container e pode parecer que ela está plugada na rede.

**none**: Container roda totalmente de forma isolada.

**As mais importantes são a bridge e depois a host.**





## Bridge

`docker network ls`

`docker network prune #permanecem apenas as networks padrões`

`docker run -d -it --name ubuntu1 bash`

`docker run -d -it --name ubuntu2 bash`

`docker network inspect bridge` -> Nele é possível obter os endereços IP dos containers criados.

`docker attach ubuntu1` -> Com isso entramos direto no nosso container, uma vez que executamos ele com `-it` mas demos o comando `-d` para não ficar atrelado ao terminal naquele momento.

`bash-5.1# ip addr show`

`bash-5.1# ping 172.17.0.4 # ping no ubuntu2`

Aqui vemos que eles estão na mesma rede!

`bash-5.1# ping ubuntu2`
`ping: bad address 'ubuntu2'`

Entretanto, quando rodamos por padrao na network bridge, não está sendo feita a resolução por nomes do container.

Logout dos containers faz eles pararem!

Então remova-os:

`docker rm ubuntu1`

`docker rm ubuntu2`



Agora, vamos criar uma nova rede!

`docker network create --driver bridge minharede` 

`docker network ls`

`docker run -dit --name ubuntu1 --network minharede bash`

`docker run -dit --name ubuntu2 --network minharede bash`

Agora vamos entrar em um deles!

`docker exec -it ubuntu1 bash`

`bash-5.1# ping ubuntu2`
`PING ubuntu2 (172.28.0.3): 56 data bytes`
`64 bytes from 172.28.0.3: seq=0 ttl=64 time=0.135 ms`



Portanto, quando criamos a rede, mesmo forçando ela a ser do tipo bridge agora temos a resoulução do nome pelo nome do container na mesma rede minha rede.

 Agora vamos criar um `ubuntu3` que nao vai estar na mesma rede:

`docker run -dit --name ubuntu3 bash`

`docker exec -it ubuntu3 bash`

`bash-5.1# ping ubuntu2`
`ping: bad address 'ubuntu2'`

Isso acontece porque não estão na mesma rede!

Mas podemos conetcar um container em uma network!

`docker network connect minharede ubuntu3`

`docker exec -it ubuntu3 bash`

`bash-5.1# ping ubuntu2`

`PING ubuntu2 (172.28.0.3): 56 data bytes`
`64 bytes from 172.28.0.3: seq=0 ttl=64 time=0.148 ms`



Legal! Agora conectamos o container `ubuntu3` à rede `minharede` e ele consegue acessar a resolução de nomes!





## host

No MAC OS o tipo host não funciona pois o Docker foi feito para rodar no Linux! O MAC OS emula uma maquina virtual para falar com o Docker e não a própria máquina. Então quando fizer no formato host, o docker vai juntar a rede do container com a rede da máquina virtual que emula o Linux e não com as portas do MAC em si.



`docker run --rm -d --name nginx --network host nginx`

Quando acessássemos o localhost na porta 80, já deveria funcionar o acesso ao container do nginx sem o port forward!

`curl http://localhost`

```html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
    </head>
</html>
```



# Container acessando a máquina

As vezes vamos utilizar o container Docker mas orecisamos acessar alguma porta/recurso do Docker host. 

Para isso, vamos criar um exemplo, a partir da pasta html onde está o arquivo index.html. Vamos subir um server php na porta 8000 na máquina local e não nao container.

`cd html`

`php -S 0.0.0.0:8000`

E se precisássemos que o container Docker acessasse a porta 8000 da máquina local para obter o resultado do server php?

`docker run --rm -it --name ubuntu ubuntu bash`

`root@88389659e402:/# apt-get update`

`root@88389659e402:/# apt-get install curl -y`

Nao podemos utilizar o localhost pq ele seria o proprioo container. Então:

`curl http://host.docker.internal:8000`

Pronto! Agora, o container acessou o endereço da sua máquina rodando por qualquer motivo, por exemplo, autenticação. 

Entao, o host, docker internal acessa a máquina a partir dos containers e o expose faz a máqina acessar os containers!





# Colocando em prática!

Como empacotar qualquer framework e lingugem de programação em docker!

No caso, o `go` geraria apenas um binário. Entao o `Laravel` é um bom exemplo para começar de um jeito um pouco mais interessante!



Escolha de uma imagem base do php oficial.

`docker run -it --name php php:7.4-cli bash`

`apt-get update`



Quando estamos trabalhando  com o php, baixamos o framework que se chama laravel a ser instalado via composer. O composer é um gerenciador de pacotes do php. Na imagem do php não se tem pacote composer instalado. 

https://getcomposer.org/download/

Vamos fazer o download manualmente apos o apt-get update

```
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php

ls
cd /var/www
root@00abfbc1bff7:/var/www# ls
composer-setup.php  composer.phar  html

# O arquivo compose.phar é o arquivo que vamos utilizar para gerenciar os pacotes php
#Agora vamos remover o composer-setup.php
php -r "unlink('composer-setup.php');"

# Agora somos aptos a rodar o compose.phar
php composer.phar

php composer.phar create-project laravel/laravel laravel

ERROR

apt install libzip-dev -y

ERROR

# Uma peculariade dessa imagem do php é que o pessoal do phpo criou uma extensão que chama docker-php-ext-install para instalar as dependencias que podem precisar do php nessa imagem do docke. Entao:

docker-php-ext-install zip

php composer.phar create-project laravel/laravel laravel

root@00abfbc1bff7:/var/www# cd laravel

root@00abfbc1bff7:/var/www/laravel# ls
README.md  artisan    composer.json  config    package.json  public     routes      storage  vendor
app        bootstrap  composer.lock  database  phpunit.xml   resources  server.php  tests    webpack.mix.js




```

É importante escrevermos o Dockerfile em contextos, pois cada layer dessas será um layer da nossa imagem.

Arrumar o Dockerfile e gerar a imagem para ver se está conseguindo gerar

`cd laravel`

`docker build -t rogeriocassares/laravel:latest .`



O laravel tem um arquivo arthisan, criar, controles, modulos, subir servidor, etc.

No container

`php artisan serve`

`Starting Laravel development server: http://127.0.0.1:8000`



É esse comando que queremos que fique segurando o processo do php no container!

no Dockerfile, editar o comando `ENTRYPOINT`

Build da imagem: 

`docker build -t rogeriocassares/laravel:latest .`

Vamos subir a imagem

`docker run  --rm --name laravel -p 8000:8000 rogeriocassares/laravel`

O servidor de desenvolvimento está liberado para rodar no 127.0.0.1 do container e não está exposto para quem está de fora então devemos deixar o acesso dentro do laravel liberado para qualquer host.



`root@00abfbc1bff7:/var/www/laravel# php artisan serve --help`

Se escrevermos no --host 0.0.0.0 todos vao poder entrar.



Mas a grande questão é a seguinte:

entrypoint vs command

Aqui a entrada por padrão será a 

`ENTRYPOINT ["php","laravel/artisan","serve"]`



E o `CMD` vai passar os parametros/comandos para o `ENTRYPOINT`!



Nesse caso, passamos esse parametro através do `-host` no `CMD` do Dockerfile e se quisermos alterá-lo, podemos sobreescrever através dos comandos por parametro no cli do docker run

Podemos remover o container apenas com o inicio do ID!

Nesse caso: 

`docker rm -f 353`



Gerar o build após a escrita do `CMD`

`docker build -t rogeriocassares/laravel:latest .`



`docker run  -d --rm --name laravel -p 8000:8000 rogeriocassares/laravel`

Verificando com o docker ps vemos que está rodando!



Mas para ver o que está acontecendo dentro do programa, podemos ver os logs!

`docker logs laravel`

Agoa é possivel acessar o `laravel` da nossa máquina atraves do `localhost:8000`



Apesar de o `CMD` do Dockerfile ser anexado ao `ENTRYPOINT`, ele pode ser substituido.

Exemplo, trabalhar com a porta 8001 dos dois lados:

`docker run -d --rm --name laravel -p 8001:8001 rogeriocassares/laravel --host=0.0.0.0 --port=8001`



`docker logs laravel`
`Starting Laravel development server: http://0.0.0.0:8001`
`[Tue Jul  5 18:11:45 2022] PHP 7.4.30 Development Server (http://0.0.0.0:8001) started`



Agora é possivel acessar o `laravel` da nossa máquina atraves do `localhost:8000`





Então, agora nós temos um comando comum e podemos fornecer uma customização por linha de comando!



Agora, bastar colocxar essa imagem no docker registry!

`docker push rogeriocassares/laravel`



OBS: O docker hub apaga as imagens automaticamente se a imagem nao for baixada em um prazo de 30 dias.



As vezes queremos desenvolver uma certa tecnologia sem ter necessariamente ela instalada em nossa máquina  porque a imagem é imutável.

A ideia agora é desenvolver em nossa máquina, utilizando o Docker como infraestrutura, mas usando o docker e vendo o resultado.





# Agora vamos utilizar o Nodejs

Eventualmente não precisamos nem ter o Dockerfile! É como se nao houvesse nada de node instalado em nossa máquina.

A ideia agora é alterar uma pasta no computador e ela ser alterada no container. Então qualquer mudança que fizermos será verificado em tempo real dentro do container compartilhando o volume.

`cd node`

`docker run --rm -it -v $(pwd)/:/usr/src/app -p 3000:3000 node:15 bash`

`cd /usr/src/app`

`touch oi`

`rm oi`

Neste momento os volumes do container e da nossa máquina já estao sendo compartilhados!

`# Start a node proj`

`npm init` 

`npm install express --save`

`touch index.js`

`node index.js`

Acessando o `localhost` da máquina na porta 3000 já temos o acesso à página de resposta do server em node sem nem precisar ter o node instalado em nosTIMIZANDO AS NOSSA IMAGENSsa máquina!

Se alterar na máquina, altera ali no container!

Não criamos nem o Dockerfile e estamos rodando dentro de um container direto!

Como geramos essa imagem? 

Vamos criar um Dockerfile com tudo o que fizemos até agora.



Se quisermos gerar o pacote final da aplicação fechada, precisamos copiar os arquivos finais do desevolvimento para dentro do `WORKDIR` pois não existe mais compartilhamento de arquivos quando vamos distribuir a nossa imagem. Precisamos colocar tudo dentro dela!

`COPY . .`

E entao vamos trabalhar com o `CMD` pois conseguiremos alterar do jeito que desejarmos via `docker run`

**BUILD NO DOCKERFILE!**

`docker build -t rogeriocassares/hello-express .`

`docker run -p 3000:3000 rogeriocassares/hello-express:latest`

`docker push rogeriocassares/hello-express`



Sempre que vamos gerar um build, devemos copiar tudo o que está dentro da pasta para a aplicação.

É muito comum trabalharmos com dois Dockerfiles!



**IMPORTANTE!**

`touch Dockerfile.prod`

Então o Dockerfile.prod terá o copy para empacotar tudo o que está dentro da nossa aplicação para a imagem.

E no Dockerfile normal, nós tiramos o `COPY`. Portanto, no Dockerfile podemos instalar o que quisermos com `apt-get` e etc e então copiamos tudo apenas quando formos gerar a imagem como o Dockerfile.prod.

Como fazemos o build com esse novo Docker?

`docker build -t rogeriocassares/hello-express node/ -f node/Dockerfile.prod`



**PORTANTO, TEMOS ASSIM UMA FORMA SIMPLES DE TRABALHAR COM UMA VERSAO LOCAL E UMA IMAGEM DE DESEVOLVIMENTO!**



# Otimizando nossas imagens!

Normalmente, para desenvolvimento, executamos uma imagem bem completa com vários pacotes muitas vezes pré-instalados. Mas para produção, quanto menor a imagem e mais enxuta, melhor!

Mas rápido, mais fácil e menos vulnerabilidade por segurança.

Em produção, geralmente usamos imagens utilizando o Alpine Linux, muito enxuto!

Objetivo: Gerar imagem ord latavel.

Nginx como servidor de proxy reverso para o php!

Client -> nginx -> php -. nginx -> client

Rodar o php no modo fastcgi

O nginx se conecta facilmente com o php, envia as requisições via tcp e retorna o resultado. Mas, vamos utilizar o alpine Linux para reduzir o tamanho da imagem!



**AGORA É A HORA DE TRABALHAR COM O MULTISTACK BUILDING!**

A ideia é que façamos o processo de build da nossa imagem em duas ou mais estapas: Estado inicial onde geramos a imagem e um próximo estado em que otimizamos a imagem!

Dockerfile.prod para o laravel:

`FROM php:7.4-cli AS builder`

`...`

`FROM php:7.4-fpm-alpine`

`WORKDIR /var/www`

`RUN rm -rf /var/www/html`

`COPY --from=builder /var/www/laravel .`



Isso significa que do builder vamos buscar na pasta `/var/www/laravel` e vamos copiar para a pasta `/var/www/` deste último estágio aqui!

Portanto, o estágio de builder gerou todo conteudo que a gente queira, e agora o estágio de build 2 vai copiar desse estágio do caminho `/var/www/laravel` para o caminho indicado pelo `WORKDIR`.



O `laravel` tem uma pasta de public onde ele guarda as imagens e os arquivos principais.



Uma convenção muito grande é trabalhar com o nome desta pasta como `html` e poderiamos até gerar um link simbólico para facilitar a nossa vida.



Mas o que faremos agora é apenas dar a permissão correta: `www-data`. Isso fará com que no nosso aplpine linux possa dar a permissão para ler e escrever a nossa pasta, pq senao os arquivos de cache e de log do laravelk nao vao poder ser guardados.

`RUN chown -R www-data:www-data /var/www`



Permissao para o usuario e grupo `www-data` serem os donos desses arquivos para poderem ler e escrever nessa pasta.



`CMD [ "php-fpm" ]` é o comando que vai executar o `php`. Então o `php` vai ficar escutando no `fpm` e o nginx vai fazer essa chamada.



**BUILD IT!**

`docker build -t rogeriocassares/laravel:prod laravel -f laravel/Dockerfile.prod`



Toda vez que mudarmos o nome padrao de Dockerfile, devemos indicar a flag `-f` e indicar o novo nome! Nesse caso indicamos o caminho com a pasta  `laravel/Dockerfile.prod`



`docker images | grep laravel`

`rogeriocassares/laravel                     prod                 5418ee5573b6   42 seconds ago      66.7MB`
`rogeriocassares/laravel                     latest               d1b16de6754d   About an hour ago   553MB`



Olha a diferença de tamanho entre os arquivos!

Portanto, conseguimos aqui trabalha com uma imagem mais enxuta e mais segura!





# Proxy reverso

Com `nginx`

`nginx.conf` configuramos os domínios que vamos trabalhar. Nesse caso, apenas um host que é o laravel.

Criar arquivo `nginx.conf`.

O arquivo `index.php` tem que pelo menos existir no `nginx` mesmo que seja em branco para que não retorne um `not found`. Então, quando bater no `index.php` em branco ele vai apontar para o `laravel`.

Gerar o build:

`cd nginx`

`docker build -t rogeriocassares/nginx:prod . -f Dockerfile.prod`



Criando network:

`docker network list`

`docker network create laranet`

`docker run -d --network laranet --name laravel rogeriocassares/laravel:prod`

`docker run -d --network laranet --name nginx -p 8080:80 rogeriocassares/nginx:prod`



`localhost:8080 -> File not found`

`docker logs nginx`



Link simbolico é como uma pasta de atalho:

Como o laravel possui uma pasta `public` e queremos mandar o cara para a pasta `html`, basta criarmos um link simbólico para que quando a pasta `html` for acessada, o cliente vai estar vendo o conteúdo da `public`.

`docker rm -f laravel`

`docker rm -f nginx`

Rebuild!

`docker build -t rogeriocassares/nginx:prod . -f Dockerfile.pr`od



Rebuild no Laravel:

`cd ../laravel`

`docker build -t rogeriocassares/laravel:prod . -f Dockerfile.prod`



Run to containers!

`docker run -d --network laranet --name laravel rogeriocassares/laravel:prod`

`docker run -d --network laranet --name nginx -p 8080:80 rogeriocassares/nginx:prod`



Localhost:8080

OK!



O `nginx` tb faz a exposição de assets, arquivos estáticos, css...



Caso tivéssemos imagens, teríamos que copiar essas images para dentro do `nginx` pois o `pho` não serve imagens, apenas o `php`!



# Docker Compose

Facilita a vida para trabalhar com docker. Automatiza o processo. Ferramenta que baseado no `yaml`, sobe de forma automática os containeres funcionando.

`docker-compose.yaml` especifica quais serviços queremos subir.

Cada serviço vai representar em um container que iremos trabalhar.



Remover todos os containeres:

`docker rm $(docker ps -a -q) -f`

Subir todos os containeres com `docker-compose`:

`docker-compose up`

Remover todos os containeres com `docker-compose`:

`docker-compose down`



**Buildando imagens com o compose**

No dia a dia, nao iremos fixar a imagem que iremos trabalhar. Nesse caso, incluiremos a tag `build`, `context` e o nome do arquivo Dockerfile.

`docker-compose up -d`

`docker-compose ps`

`docker-compose down`

Agora, se quisermos, podemos rebuildar as imagens com:

`docker-compose up -d --build`



# Usando Banco de dados

Duplicando os `docker-composes` para `laravel` (`bkp`) para trabalha com o `docker-compose` normal.

No caso do MySql, quando vamos dar o boot, existe um `CMD` que precisamos rodar se não, não vai funcionar. Esse é um como um `CMD` que vai depois do `ENTRYPOINT` padrão.

`tty`, permite que entremos no sistema e acessar de forma interativa.

`docker-compose up -d`

`docker logs db`





Adicionando o node no `docker-compose.yaml`:

`docker-compose up -d --build`

`docker ps`

`docker exec -it app bash`



Nesse ponto, estamos trabalhando com o `Node`, dentro de um container, mas sem precisar ter o `Node` instalado na máquina;

`docker exec -it db bash`

`mysql -u root -p`

`mysql> show databases;`

`mysql> use nodedb;`

`mysql> create table people(id int not null auto_increment, name varchar(255), primary key(id));`

`mysql> desc people;`



Vamos fazer o programa `Node` criar um registro lá dentro.

No docker bash do node:

`npm install mysql --save`

`Edir index.js`

`node index.js`

No mysql bash

`mysql> select * from people;`



Funcionou!



Então agora, pela primeira vez, nós temos um abiente de desenvolvimento com banco de dados cujos dados não sao perdidos porque o volume está compartilhado onde nos programamos no vscode, programamos dentro do container e um se comunica com o outro para gravar os dados no db.



### Dependência entre os containeres

Muitas vezes só podemos iniciar o node quando o node estiver de pé, por exemplo e pode dar um erro e matar o container!

Para que um container possa esperar o outro ficar pronto é um comando que chama `dependes_on` no `docker-compose`.



`depends_on:`

​      `\- db`



Mas isso não significa que o container app vai ficar esperando o mysql ficar pronto porque não é a sua responsabilidade...

Como podemos então esperar?

Entao podemos colocar um script a ser executado como comando para esperar que o outro serviço fique pronto!

`waitforit` e `dockerize`.

Portanto, na imagem onde formos instalar o node (Dockerfile), vamos instalar o `dockerize` antes da exposição das portas.

```
RUN rm -rf /var/lib/apt/lists/* && \
    apt-get update -o Acquire::CompressionTypes::Order::=gz

RUN apt-get update && apt-get install -y wget

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz
```



Então quando instalarmos o `dockerize` na nossa imagem, ele consegue fazer essa chamada. 

Asssim, vamos poder verificar se o container está pronto.

Saia do container bash do node e rebuild:

`docker-compose up -d --build`



ENTRA NO APP BASH

`docker exec -it app bash`

`root@f13350070ee0:/usr/src/app# dockerize -wait tcp://db://3306`
`2022/07/06 20:47:51 Waiting for: tcp://db://3306`
`2022/07/06 20:47:51 Problem with dial: dial tcp 192.168.16.2:0: connect: connection refused. Sleeping 1s`



Então, esse comando verifica que o mysql na porta 3306 está pronto!

`docker-compose stop db`

`docker-compose ps`

No app bash:

`root@f13350070ee0:/usr/src/app# dockerize -wait tcp://db://3306 -timeout 50s`

Então apenas depois disso o programa vai rodar o `ENTRYPOINT` que vai rodar o programa final, que vai manter o programa no ar.

`docker-entrypoint.sh`



editar o `docker-compose.yam` para mudar o `ENTRYPOINT` do app.



Build all again!

`docker-compose up -d --build`

db subiu primeiro e app subiu depois!

`docker-compose ps`






















































