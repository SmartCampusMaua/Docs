# Kafka

# Introdução
## Apresentação
Além de uma ferramenta, kafka é um ecossistema e faremos um tour aprofundado para utilizar.

## O mundo dos eventos
É um projeto open-source da Apache Foundation

"O Apache Kafka é uma plataforma distribuída de streaming de eventos open-source que é utilizada por milhares de empresas para uma alta performance em pipeline de dados, stream de
analytics, integração de dados e aplicações de missão crítica" https://apache.kafka.org


Plataf distribuida de stream de eventos. Stream sao dados que sao produziodos, capturados e entao distribuimos esses dados para as devidas soluçoes


Cada dia mais precisamos processar mais e mais eventos em diversos tipos de plataforma. Desde sistemas que precisam se comunicar, devices para IOT, monitoramento de aplicações, sistemas de alarmes, etc.
Perguntas:
  - Onde salvar esses eventos?
  - Como recuperar de forma rápida e simples de forma que o feedback entre um processo e outro ou mesmo entre um sistema e outro possa acontecer
  de forma fluida e em tempo real?
  - Como escalar?
  - Como ter resiliência e alta disponibilidade?


## Os superpoderes do Kafka

ALTO VOLUME DE DADOS E/OU MUITOS SISTEMAS QUE PRECISAM SE CONECTAR!

- Altissimo throughput.
- Latência extremamente baixa (2ms)
- Escalável
- Armazenamento
- Alta disponibilidade
- Se conecta com quase tudo
- Bibliotecas prontas para as mais diversas tecnologias
- Ferramentas open-source

Empresas:
- Linkedin
- Netflix
- Uber
- Twitter
- Dropbox
- Spotify
- Paypal
- Bancos...




## Dinamica de Funcionamento
Conceitos e dinâmicas básicas de funcionamento
![Alt text](image.png)

kafka eh um cluster formado de nós (brokers)

Producer -> kafka (db) -> Consumer

O kafka nao envia nehuma mensagem para ninguem e nem distribui a mensagem. Ele guarda e o consumer lê. Não eh pub/sub

Recomendaçao minima do kafka em prod sao 3 maquinas

Brokers se comunicam a todo o tempo. O sistema que geremcia tudo isso eh o zookeeper. Service discovery que auxilia o kafka. Mas o zookeeper está de saida pq vai depreciar.


## Tópicos

kafka eh topic

Topico nao eh um sistema de fila.

Quando consumer quiser ler ele le de um topic

Tópico é o canal de comunicação responsável por receber e disponibilizar os dados enviados para o Kafka
![Alt text](image-1.png)

Topic ~= Log

O log é um lugar em que as informações vao sendo colocadas uma após a outra
Cada mensagem vai ser armazenada com um id (offset)
![Alt text](image-2.png)
Pode ser que um consumidor esteja lendo a mensagem 3 e outro consumer leia a mensagem 7. Alem disso, nesse momento está sendo adicionado um novo record no final do log. Nao tem problema nenhum. Inclusive, o kafka permite reprocessar novamente a mensagem. A mensagem fica em disco!



### Anatomia de um registro
Quando uma nova mensagem chega no sistema ela é um registro com Offset 0.
![Alt text](image-3.png)
Headers -> Quando enviamos a mensagem, podemos passar tb alguns Headers e eles funcionam como metadados que podem ser uteis durante o processo. Nao sao obrigatorios mas podem ser interessantes.

Key -> Contexto do tipo/contexto/agrupamento da mensagem que precisamos garantir a ordem da entrega

Value -> Conteudo / payload

Timestamp


## Partições

Cada tópico pode ter uma ou mais partiçoes para conseguir garantir a distribuiçao e resiliencia de seus dados.

![Alt text](image-4.png)

Toda vez que aumentamos a quantidade de partição, as mensagens elas fiam mais separadas. Se o Broker A cair e se todas as mensagens de um topico nesse Broker, ningém consegue ler nada. Se elas estiverem distribuidas entre mais brokers, apenas de nao lermos as mensagens dos tópicos dos brokers que cairam, será possivel ler dos que ainda permaneceram!

Se tivermos 1 milhao de mensagens e pedir para o pc processar essas mensaagens fica dificil. Entao podemos separar os topicos em mais de uma maquina (partições), conseguiremos processar essas mensagens muito mais rapido!

Essa eh a estrategia! Cada maquina, uma partição! 

Quando formos criar um topico, vamos descrever quantas partiçoes queremos em cada um!


## Garantindo ordem de entrega
Existe um efeito colateral quando estamos trabalhando com partiçoes: Como conseguir garantir a ordem das mensagens? KEYS!

![Alt text](image-5.png)
O Consumer 2 pode estar lendo de duas partições. As vezes podemos ter mais partiçoes do que consumer, entao um consumer vai ter que ler mais de uma partiçao

Em um exemplo de uma transação bancária, ao recebermos a Transferencia pela partiçao 1 lida pelo Consumer 1 (lento), é realizada um evento de estorno pela partição 2, lida pelo conumer2 (rápida). Isso significa que há uma chance de o Consumer 2 consumir o evnto do estorno antes do evento da transferencia ser consumida! Em deterrminadas situações, a ordem dos eventos e dos processamentos dos eventos precisa ser seguida! Isto é, primeiro se realiza a transaçao e depois o estorno. Nao há como fazer invertido!


Vamos imaginar uma outra situaçao em que a Transferencia esteja no offset 0 e o estorno no offset 1. Essa é a unica forma de conseguirmos garantir a ordem. Isto é, fazendo com que a tanto a menagem de transferenca quanto a de estorno vao para a mesma partiçao. Se ela vai oara a mesma partiçao, nao tem problema pq o Consumer 1 (lento) VAI LER AS MENSAGENS EM SEQUENCIA. Somente é possivel garantir a ordem das mensagens na mesma partiçao!

![Alt text](image-6.png)

Como fazer isso? Keys!
![Alt text](image-7.png)
Toda vez que mandarmos uma mensagem da trabsferencia (mensgaem 0) colocamos que a key dela é "movimentaçao" e quando formos mandar a mensagem de estorno (mensagem 1), falamos que a key dela tb é "movimentaçao".

O kafka vai colocar todas as mensagens com a mesma key em uma mesma partiçao.

Dessa forma, o kafka se torna muito rapido pois distribui as suas mensagens para que varios consumidores consigam ler ao mesmo tempo!



## Partições Distribuidas

![Alt text](image-8.png)
Cada broker eh uma maquina totalmente diferente e as partiçoes sao o lugar em disco onde ele vai guardar todas as mensagens.

Agora, vamos imaginar o seguinte: Vamos escolhar algo que se chama replicatorFactor igual a dois.

![Alt text](image-9.png)
Da forma anterior hava a distribuiçao, mas nao a resiliencia dos dados. Por conta disso, o replicator factor. Quando criamos um topico, decidimos que será 3 partiçoes com pelo duas copias. Se cair um Broker, sempore haverá uma cópia em outro bROKER.

De acordo com a criticidade e a resiliencia, aumenta-se o replicatiorFactor para a escalabilidade e alta disponibilidade

Normalmente, utilizam 2 (minimo) ou 3 (muito critico) de replication factor.


## Partition Leadership
Uma coisa eh ter uma copia, outra eh garantir alta disponibilidade

![Alt text](image-10.png)

As partiçoes em azul sao as chamadas lideres e significa qu e quando um consumer vai ller um topico e na partiçao 1, necessáriamente ele vai ler a partiçao lider. Nao ha chances nenhuma de o consumer ler de dois brokers; ele sempre vai ler da partiçao lider e nao da partiçao follower!

Caso o broker A cair inteiro, o kafka percebe que ele caiu e entao a nova partiçao lider estará no Broker B
![Alt text](image-11.png)

Entao nao teria tanto problema ter downtime de partiçao pq sempre vai ter uma disponivel quase que imediatamente!

## Producer: Garantia de Entrega de mensagens
Como um producer manda uma mensagem e garantimos que a mensagem foi entregue?


Considerando o exemplo a seguir, a mensagem eh sempre entregue primeiramente ao lider.
Quando  producer envia a mensagem, ele envia o ack.

ack: 0 -> None, ff (fire and forget).
![Alt text](image-12.png)
 É arriscado pois o producer nao recebe a confrmaçao do kafka que esta tudo ok. Por outro lado, o kafka consegue processar mais mensagens, enviando muuito mais mensagens. Depende do contexto. No uber, por exemplo, a cada 10segundos o motorista fica enviando as posiçoes. Caso a informaçao do gps nao apareça algumas vezes, nao ha problemas de engocio e é possivel estar disposto e ciente de que pode-se perder uma mensagem.

ack: 1 -> Leader. Significa que o producer envia a mensagem, e o Lider salva a mensagem e envia uma resposta afirmando que ela foi salva ao Producer.
![Alt text](image-13.png)
E se logo que isso aconteceu o Broker caiu? Ele nao teve tempo de replicar a mensagem para os folloers e o producer acreditou que a mensagem foi gravada.

Isso acaba interfeindo na velocidade e ainda temos a garantia de entrega.

Ack: -1 -> ALL
![Alt text](image-14.png)
Isso significa que o producer vai enviar a mensagem, o lider vai salvar, replicar as mensagens nos followers, os followers vao avisar o lider que a mensagem foi salva e o lider avisa o producer que a mensagem foi salva. Ain nao tem problemas pq a mensagem foi replicada ao longo de todos os Brokers. Garantia total de mensagem salva e replicada.
O problema é que isso torna o sistema inteiro muito mais leeento, mas 100% de garantia.


## Garantia de Entrega parte 2
Mais alguns detalhes:
aT MOST ONCE: mELHOR PERFORMANCE. pODE PERDER ALGUMAS MENSAGENS
![Alt text](image-15.png)

At least once:
Performance Moderada. Pode duplicar mensagem. Pelo menos uma vez garantimos que a mensagem será entregue. 
![Alt text](image-16.png)
Nesse caso temos que tomar cuidado para no consumer, ter um tratamento para ignorar a mensagem com o id ja processado.

Exactly Once:
Pior performance. Exatamente uma vez. Por isso, o kafka fica processando se houve ou nao a duplicaçao da mensagem para o consumidor.
![Alt text](image-17.png)
ERRATA NA FIGURA
--> 1 2 3 4 5

## Produtor indepotente
Conforme a situaçao a seguir que o producer envia a mensagem 1 para o Broker e recebeu o ack. Mas na hora que enviou a mensagem 4 houve um problema de rede. Inevitavel. O que aconteceu foi que o producer enviou a mensagem novamente e recebeu um ack. E se, eventualmente a mensagem que caiu acabou indo em duplicata?

![Alt text](image-18.png)
Nesse caso, a indepotencia é off. Isso significa que nesse caso, a mensagem 4 eh duplicada e o consumer vai ler a mensagem duas vezes. Isso nao seria culpa do kafka, mas do produtor, que enviou a mensagem duas vezes.

Como conseguimos evitar esse tipo de problema? PRODUTOR INDEPOTENTE!

Quando falamos que o producer é indepotente, o kafka entende que isso aconteceu e vai descartar essa mensagem. Isso gera uma lentidao mas ele consegue descartar a mensagem e ainda esteja na ordem correta por causa do timestamp. Descarte automatico.

## Consumers e Consumer Groups
Qual a dinamica que os consumidores trabalham?

![Alt text](image-19.png)
Quando enviamos a mensagem, o consumer vai ter que ler na partiçao 0, 1 e 2 pois temos apenas um consumer. Na pratica o processamento de mensagens nao vai mudar nada. 

Por outro lado, a gente pode ter uma sensaçao de consumer groups.
No grupo X temos o consumer a e o consumer B, podendo ser exatamente o mesmo software rodando em maquinas ou processos diferentes. Eles fazem a mesma coisa. Ja que eles fazem a mesma coisa e sao colocados dentro de um mesmo grupo, a partiçao 0 e 1 vai ser lida pelo consumer A e a partiçao 3 vai ser lida pelo Consumer B.
![Alt text](image-20.png)
Se tivessmos um Consumer y e nao estivesse no Grupo x, esse Consumer iria ler todas as partiçoes!

A coisa mais comum na hora de consumir é falar qual grupo que está consumindo para ter uma melhor performace na leitura.

![Alt text](image-21.png)
Se o Grupo X tiver 3 consumidores, cada Consumer vai ler de uma partiçao. E se adicionarmos mais um Consumer? Ele vai ficar parado! Nao tem como 2 consumidores que estao em um mesmo grupo lerem a mesma partiçao! Eh sempre 1 Consumer por partiçao. Se tiver mais Consumer que uma partiçao, o Consumer vai ficar parado! Nao adinata criar inumeras partiçoes e inumeros consumers! Portanto, o melhor dos mundos eh semrpe ter a mesma quantidade de partiçoes e de consumidores!

Se nao falar qual é o Grupo, entao o nome do Grupo é o proprio consumer!



# Conceitos Básicos na Prática
## Repositorio do Modulo
https://github.com/codeedu/fc2-kafka/blob/main/docker-compose.yaml

docker-compose.yaml
```yaml
version: "3"

services:  
  zookeeper:
    image: confluentinc/cp-zookeeper:7.5.3
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
    extra_hosts:
      - "host.docker.internal:172.17.0.1"

  kafka:
    image: confluentinc/cp-kafka:7.5.3
    depends_on:
      - zookeeper
    ports:
      - "9092:9092"
      - "9094:9094"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_INTER_BROKER_LISTENER_NAME: INTERNAL
      KAFKA_LISTENERS: INTERNAL://:9092,OUTSIDE://:9094
      KAFKA_ADVERTISED_LISTENERS: INTERNAL://kafka:9092,OUTSIDE://host.docker.internal:9094
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: INTERNAL:PLAINTEXT,OUTSIDE:PLAINTEXT
    extra_hosts:
      - "host.docker.internal:172.17.0.1"

  control-center:
    image: confluentinc/cp-enterprise-control-center:7.5.3
    hostname: control-center
    depends_on:
      - kafka
    ports:
      - "9021:9021"
    environment:
      CONTROL_CENTER_BOOTSTRAP_SERVERS: 'kafka:9092'
      CONTROL_CENTER_REPLICATION_FACTOR: 1
      CONTROL_CENTER_CONNECT_CLUSTER: http://kafka-connect:8083
      PORT: 9021
    extra_hosts:
      - "host.docker.internal:172.17.0.1"
```

## Criando Primeiro tópico
Zookeeper, em breve nao será mais necessario.
Kafka: o próprio
control-center: a Confluent criou para visualizarmos algumas configuraçoes via web

Vamos rodar o docker compose
```bash
cd Communication/Async-Brokers/Kafka
docker compose up -d
```

Para verificar se os containeres estao ok: 
```bash
❯ docker compose ps                 

NAME                     IMAGE                                             COMMAND                  SERVICE          CREATED          STATUS          PORTS
kafka-control-center-1   confluentinc/cp-enterprise-control-center:7.5.3   "/etc/confluent/dock…"   control-center   50 seconds ago   Up 46 seconds   0.0.0.0:9021->9021/tcp
kafka-kafka-1            confluentinc/cp-kafka:7.5.3                       "/etc/confluent/dock…"   kafka            50 seconds ago   Up 46 seconds   0.0.0.0:9092->9092/tcp, 0.0.0.0:9094->9094/tcp
kafka-zookeeper-1        confluentinc/cp-zookeeper:7.5.3                   "/etc/confluent/dock…"   zookeeper        50 seconds ago   Up 46 seconds   2181/tcp, 2888/tcp, 3888/tcp
```

Verificar os logs do kafka:
```bash
❯ docker logs kafka-kafka-1
```

Podemos acessar o kafka via plataforma ou CLI.
```bash
docker exec -it kafka-kafka-1 bash
[appuser@c844eaebd5c0 ~]$ 
```

Agora estamos dentro do nosso container do kafka! Uma linha de comando que utilizamos bastante é o kafka-topics, kafka-console-producer e kafka-console-consumer. 

Toda hora que formos criar algo no kafka ou na linha de comando, vamos po bootstrap-server. Basicaamente é o servidor que vamos utilizar para trabalhar com o kafk. REQUIRED! Além disso, há o create para criar um novo topico, partitions, topic (nome)

```bash
[appuser@c844eaebd5c0 ~]$ kafka-topics --create --topic=teste --bootstrap-server=localhost:9092 --partitions=3
Created topic teste.
```

Pronto! O topico foi criado! Agora, vamos dar um comando para listar os topicos!
```bash
[appuser@c844eaebd5c0 ~]$ kafka-topics --list --bootstrap-server=localhost:9092
__consumer_offsets
_confluent-command
_confluent-controlcenter-7-5-3-1-AlertHistoryStore-changelog
_confluent-controlcenter-7-5-3-1-AlertHistoryStore-repartition
_confluent-controlcenter-7-5-3-1-Group-ONE_MINUTE-changelog
_confluent-controlcenter-7-5-3-1-Group-ONE_MINUTE-repartition
_confluent-controlcenter-7-5-3-1-Group-THREE_HOURS-changelog
_confluent-controlcenter-7-5-3-1-Group-THREE_HOURS-repartition
_confluent-controlcenter-7-5-3-1-KSTREAM-OUTEROTHER-0000000106-store-changelog
_confluent-controlcenter-7-5-3-1-KSTREAM-OUTEROTHER-0000000106-store-repartition
_confluent-controlcenter-7-5-3-1-KSTREAM-OUTERTHIS-0000000105-store-changelog
_confluent-controlcenter-7-5-3-1-KSTREAM-OUTERTHIS-0000000105-store-repartition
_confluent-controlcenter-7-5-3-1-MetricsAggregateStore-changelog
_confluent-controlcenter-7-5-3-1-MetricsAggregateStore-repartition
_confluent-controlcenter-7-5-3-1-MonitoringMessageAggregatorWindows-ONE_MINUTE-changelog
_confluent-controlcenter-7-5-3-1-MonitoringMessageAggregatorWindows-ONE_MINUTE-repartition
_confluent-controlcenter-7-5-3-1-MonitoringMessageAggregatorWindows-THREE_HOURS-changelog
_confluent-controlcenter-7-5-3-1-MonitoringMessageAggregatorWindows-THREE_HOURS-repartition
_confluent-controlcenter-7-5-3-1-MonitoringStream-ONE_MINUTE-changelog
_confluent-controlcenter-7-5-3-1-MonitoringStream-ONE_MINUTE-repartition
_confluent-controlcenter-7-5-3-1-MonitoringStream-THREE_HOURS-changelog
_confluent-controlcenter-7-5-3-1-MonitoringStream-THREE_HOURS-repartition
_confluent-controlcenter-7-5-3-1-MonitoringTriggerStore-changelog
_confluent-controlcenter-7-5-3-1-MonitoringTriggerStore-repartition
_confluent-controlcenter-7-5-3-1-MonitoringVerifierStore-changelog
_confluent-controlcenter-7-5-3-1-MonitoringVerifierStore-repartition
_confluent-controlcenter-7-5-3-1-TriggerActionsStore-changelog
_confluent-controlcenter-7-5-3-1-TriggerActionsStore-repartition
_confluent-controlcenter-7-5-3-1-TriggerEventsStore-changelog
_confluent-controlcenter-7-5-3-1-TriggerEventsStore-repartition
_confluent-controlcenter-7-5-3-1-actual-group-consumption-rekey
_confluent-controlcenter-7-5-3-1-aggregate-topic-partition-store-changelog
_confluent-controlcenter-7-5-3-1-aggregate-topic-partition-store-repartition
_confluent-controlcenter-7-5-3-1-aggregatedTopicPartitionTableWindows-ONE_MINUTE-changelog
_confluent-controlcenter-7-5-3-1-aggregatedTopicPartitionTableWindows-ONE_MINUTE-repartition
_confluent-controlcenter-7-5-3-1-aggregatedTopicPartitionTableWindows-THREE_HOURS-changelog
_confluent-controlcenter-7-5-3-1-aggregatedTopicPartitionTableWindows-THREE_HOURS-repartition
_confluent-controlcenter-7-5-3-1-cluster-rekey
_confluent-controlcenter-7-5-3-1-expected-group-consumption-rekey
_confluent-controlcenter-7-5-3-1-group-aggregate-store-ONE_MINUTE-changelog
_confluent-controlcenter-7-5-3-1-group-aggregate-store-ONE_MINUTE-repartition
_confluent-controlcenter-7-5-3-1-group-aggregate-store-THREE_HOURS-changelog
_confluent-controlcenter-7-5-3-1-group-aggregate-store-THREE_HOURS-repartition
_confluent-controlcenter-7-5-3-1-group-stream-extension-rekey
_confluent-controlcenter-7-5-3-1-metrics-trigger-measurement-rekey
_confluent-controlcenter-7-5-3-1-monitoring-aggregate-rekey-store-changelog
_confluent-controlcenter-7-5-3-1-monitoring-aggregate-rekey-store-repartition
_confluent-controlcenter-7-5-3-1-monitoring-message-rekey-store
_confluent-controlcenter-7-5-3-1-monitoring-trigger-event-rekey
_confluent-metrics
_confluent-monitoring
teste
```

Quando subimos o control-center ele sobre um monte de topicos.
O consumer_offset é onde ele guarda em qual offset cada consumer está na leitura dos topicos. Dessa forma ele consegue continuar a leitura a partir do momento que ele parou
o topico teste eh o que acabamos de criar!


## Detalhando nosso topico

Vamos entender como ele ficou em relaçao as suas configuraçoes
```bash
[appuser@c844eaebd5c0 ~]$ kafka-topics --bootstrap-server=localhost:9092 --topic=teste --describe
Topic: teste    TopicId: x6TcecVFRnyJRESdf5ICBQ PartitionCount: 3       ReplicationFactor: 1    Configs: 
        Topic: teste    Partition: 0    Leader: 1       Replicas: 1     Isr: 1
        Topic: teste    Partition: 1    Leader: 1       Replicas: 1     Isr: 1
        Topic: teste    Partition: 2    Leader: 1       Replicas: 1     Isr: 1
```

Quando criamos o topico, tb colcoamos o replication factor. Nesse caso, estamos em apenas uma maquina. Se tivermos em um cluster, ele iria replicar.

Aqui conseguimos entender como o topico funciona e é um dos pontos mais importantes para fazermos a parte pratica a partir de agora!

# Consumindio e Produzindo mensagens

Dentro do container do kafka, temos `docker-console-consumer`. Ele é o responsável por começar a consumir o topico.
Nota: se quisermos ler as mensagens antigas, colocar o --from-begining.
```bash
docker exec -it kafka-kafka-1 bash
[appuser@c844eaebd5c0 ~]$ kafka-console-consumer --bootstrap-server=localhost:9092 --topic=teste
```

Agora vamos enviar mensagens para este topico! Em outro shell:
```bash
docker exec -it kafka-kafka-1 bash
[appuser@c844eaebd5c0 ~]$ kafka-console-producer --bootstrap-server=localhost:9092 --topic=teste
>Mensagem de Teste
```

E entao apareceu no Consumer! Ok.

Se sairmos do consumer e continuar enviando pelo producer, acessando o consumer novamente, ele parte da nova conexao.

sE QUISERMOS LER AS MENSAGENS DO COMEÇO, VAMOS DAR O COMANDO FROM-BEGINING
```bash
kafka-console-consumer --bootstrap-server=localhost:9092 --topic=teste --from-beginning
```

E ele leu todas desde o começo! Entretanto elas estao fora de ordem pois cada mensagem foi para uma partiçao diferente! Nao é possivel garantir a ordem das mensagens, exceto quando temos uma key, que garante que a mensagem vai para uma mesma partiçao.


# Introduçao aos Consumers Groups
Vamos criar um outro consumer no terminal (ao todo com dois consumidores lendo cada topico)

```bash
[appuser@c844eaebd5c0 ~]$ kafka-console-consumer --bootstrap-server=localhost:9092 --topic=teste --from-beginning
```

Vamos adicionar mais um terminal para fazer o producer:
```bash
docker exec -it kafka-kafka-1 bash
[appuser@c844eaebd5c0 ~]$ kafka-console-producer --bootstrap-server=localhost:9092 --topic=teste
>
```

E vamos começar a produzir as mensagens! Os dois consumidores recebem as mensagens ao mesmo tempo pois sao consumidores totalmente independentes.

Mas se quisermos colocar mais workers lendo o kafka, vamos trabalhar com os Consumers Groups que cada consumer le de uma partiçao diferente.

Nos consumers do terminal, vamos criar os consumer gropus
```bash
[appuser@c844eaebd5c0 ~]$ kafka-console-consumer --bootstrap-server=localhost:9092 --topic=teste --group=x
```

Vamos enviar uma mensagem pelo producer. E agora vimos que apenas um dos consumers leu a mensagem, enviada pois está em uma partiçao em que apenas um dos consumers estava lendo!

https://www.confluent.io/blog/apache-kafka-producer-improvements-sticky-partitioner/

De acordo com o link acima, nao funciona mais por round-robin

# Por dentro de um Consumer Group
Como conseguimos ver no consumer group cada um que esta conectado e o que ele esta lendo.

Vamos descrever o group
```bash
[appuser@c844eaebd5c0 ~]$ kafka-consumer-groups --bootstrap-server=localhost:9092 --group=x --describe

GROUP           TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID                                           HOST            CLIENT-ID
x               teste           0          62              62              0               console-consumer-c13eed92-4e4d-49f0-9033-811f70578624 /172.23.0.3     console-consumer
x               teste           1          551             551             0               console-consumer-c13eed92-4e4d-49f0-9033-811f70578624 /172.23.0.3     console-consumer
x               teste           2          14              14              0               console-consumer-eb1cdf80-e57a-436e-94a7-cc084686862f /172.23.0.3     console-consumer
```

CURRENT-OFFSET: OFFESET DO MOMENTO
LOG-END OFFSET: Offset da Ultima mensagem
LAG:Diferença da mensagem que estamos lendo para a ultima mensagem.
CONSUMER-ID: Consumers conectasdo nesse momento

Agora vimos que dos dois consumer-id, um deles está lendo de duas partiçoes e o outro apenas de uma

# Navegando pelo Confluent Control Center

Vamos acessar o control center.
Confluent é a principal empresa que mantem o kafka desde o LinkeIn
http://localhost:9021

E logo na tela inicial vericamos que há 51 topicos rodando no nosso luster, 

E agora percebemos que temos uma listagem e alguns recursos.

O primeiro ponto é um overview dew Brokers, Consumers e Producers

Em, Toics, a opçao Hide mostra apenas o tópico que criamos, escolher visualizar e até escolher a partiçao desejada. 

![Alt text](image-22.png)

O campo key é o que nos garante que as mensagens caiam na mesma partiçao.

SCHEMAS -> O Kafka tem um servi;co da confluent (schema registry), entao configura-se o padrao para uma mensagem (avro) e essa mensagem tem que seguir esse schema.

Um ponto que veremos em breve é a parte do Connect, para integrar sistemas
ksqldb -> consumir informaçoes de um topico kafka como se estivesse trabalhando com o SQL
Consumers -> Consumers Groups ->L Topics.

O grande problema é nao entender os conceitos!


Desenvolvendo produtor e consumidor


# Repositório do módulo
https://github.com/codeedu/fc2-gokafka

## Preparando ambiente para implementação
Mais importante do que publicar/ler é entender conceitos e pontos que no final das contas vai fazer grandes diferenças. O diferencial de um dev sao detalhes como nomeácao de grupos, formatos de acks das mensagens etc

Para esse módulo, vamos criar um diretório de desenvolvimento chamado kafka-go
e um Dockerfile para ele
```Dockerfile
FROM golang:1.21

WORKDIR /go/src
ENV PATH="/go/bin:${PATH}"

RUN apt-get update && \
    apt-get install build-essential librdkafka-dev -y

CMD ["tail", "-f", "/dev/null"]
```

Nesse momento, o  ponto mais importante é instalar a biblioteca `librdkafka` no Dockerfile para nós falarmos com kafka.

Essa biblioteca foi implementada em C. O Java foi feito em Java. O librdkafka feito em C/C++ utilizam essa lib para utilizar o kafka!  Entao instamos a librdkafka no sistema operacional e interage com o kafka em diversas linguagens! 

No caso do Go, a biblioteca confluent-kafka-go conversa com o librdkafka em background!

Outro ponto importante é o docker-compose. O extra-hosts faz com que se consiga se comunicar com qualquer container do docker e não precisar ficar criando diversas networks.

Importante ter em /etc/hosts, o endereço 127.0.0.1 docker.host.internal

Vamos criar o docker-compose.yaml:
```yaml
version: "3"

services:
  app:
    build: .
    container_name: gokafka
    volumes:
      - .:/go/src/
    extra_hosts:
      - "host.docker.internal:172.17.0.1"

  zookeeper:
    image: confluentinc/cp-zookeeper:7.5.3
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
    extra_hosts:
      - "host.docker.internal:172.17.0.1"

  kafka:
    image: confluentinc/cp-kafka:7.5.3
    depends_on:
      - zookeeper
    ports:
      - "9092:9092"
      - "9094:9094"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_INTER_BROKER_LISTENER_NAME: INTERNAL
      KAFKA_LISTENERS: INTERNAL://:9092,OUTSIDE://:9094
      KAFKA_ADVERTISED_LISTENERS: INTERNAL://kafka:9092,OUTSIDE://host.docker.internal:9094
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: INTERNAL:PLAINTEXT,OUTSIDE:PLAINTEXT
    extra_hosts:
      - "host.docker.internal:172.17.0.1"

  control-center:
    image: confluentinc/cp-enterprise-control-center:7.5.3
    hostname: control-center
    depends_on:
      - kafka
    ports:
      - "9021:9021"
    environment:
      CONTROL_CENTER_BOOTSTRAP_SERVERS: 'kafka:9092'
      CONTROL_CENTER_REPLICATION_FACTOR: 1
      CONTROL_CENTER_CONNECT_CLUSTER: http://app-connect:8083
      PORT: 9021
    extra_hosts:
      - "host.docker.internal:172.17.0.1"
```

E subir os containers:
```bash
❯ DOCKER_DEFAULT_PLATFORM=linux/amd64 docker compose build 
❯ docker compose up -d
```

Se o docker já cria redes por padrao, pq usar o host?

Imagina outra aplicaçao que vai usar o compose e tb o kafka? É para isso. Colocar o mesmo localhost para todos.

Vamos verificar o funcionamento
```bash
❯ docker compose ps
NAME                        IMAGE                                             COMMAND                  SERVICE          CREATED          STATUS          PORTS
gokafka                     kafka-go-app                                      "tail -f /dev/null"      app              54 seconds ago   Up 52 seconds   
kafka-go-control-center-1   confluentinc/cp-enterprise-control-center:7.5.3   "/etc/confluent/dock…"   control-center   53 seconds ago   Up 10 seconds   0.0.0.0:9021->9021/tcp
kafka-go-kafka-1            confluentinc/cp-kafka:7.5.3                       "/etc/confluent/dock…"   kafka            53 seconds ago   Up 10 seconds   0.0.0.0:9092->9092/tcp, 0.0.0.0:9094->9094/tcp
kafka-go-zookeeper-1        confluentinc/cp-zookeeper:7.5.3                   "/etc/confluent/dock…"   zookeeper        54 seconds ago   Up 52 seconds   2181/tcp, 2888/tcp, 3888/tcp
```

E verificar os logs se esta tudo ok!
```bash
docker logs kafka-go-kafka-1
```

E está! 

## Setando ambiente Go
A goland é uma ide da jetbrains para golang. Mas vamos usar o vscode.

Vamos acessar o conteiner do `app`
```bash
❯ docker exec -it gokafka bash
root@51c4d044c58b:/go/src# ls
Dockerfile  docker-compose.yaml
```

Quando damos ls vimos que esta tudo ok em relaçao aos arquivos no volume. 

Para conseguirmos trabalhar com a gestao de pacotes do go e gerenciar dependencias vamos usar o go mod e ele vai guardar no arquivo todas as dependecias externas da nossa aplicaçao.

```bash
root@51c4d044c58b:/go/src# go mod init github.com/rogeriocassares/fc2-gokafka
go: creating new go.mod: module github.com/rogeriocassares/fc2-gokafka
```

O arquivo go.mod registra todas as dependencias.

Para garantir que esta tudo ok, vamos criar um arquivo main no seguinte diretorio:
cmd/producer/main.go
```go
package main

import "fmt"

func main() {
	fmt.Println("Hello Go!")
}

```
Isso significa que estamos noi pacote main e estamos na funçao main. Essa é a funçaop do ponto de entrada!

Vamos executar o programa dentro do container!
```bash
root@51c4d044c58b:/go/src# go run cmd/producer/main.go 
Hello Go!
```

Nesse momento configuramos a aplicaçao do Go!

## Criando e configurando producer
Vamos entrar no container do kafka:
```bash
❯ docker exec -it kafka-go-kafka-1 bash
[appuser@c61527c8cad6 ~]$
```

Essa aba servirá para consumirmos as mensagens do kafka. Para isso, vamos criar um tópico:
```bash
[appuser@c61527c8cad6 ~]$ kafka-topics --create --bootstrap-server=localhost:9092 --topic=teste --partitions=3
Created topic teste.
```

Agora vamos consumir desse tópico:
```bash
[appuser@c61527c8cad6 ~]$ kafka-console-consumer --bootstrap-server=localhost:9092 --topic=teste
```

Vamos criar uma funçao no main.go para retornar um producer da biblioteca do kafka da confluent.
```go
package main

import (
	"fmt"
	"log"

	"github.com/confluentinc/confluent-kafka-go/kafka"
)

func main() {
	fmt.Println("Hello Go!")
}

func NewKafkaProducer() *kafka.Producer {
	configMap := &kafka.ConfigMap{
		"bootstrap.servers"="kafka-go-kafka-1:9092",
	}
	p, err := kafka.NewProducer(configMap)
	if err != nil {
		log.Println(err.Error())
	}
	return p
}

```

Uma vez que temos o producer vamos começar a produxir as mensagens!


## Publicando primeira mensagem

Vamos criar um producer na funçao main e publicar uma nova mensagem criando uma funçap Publish() e preparar a mensagem para enviá-la
```go
package main

import (
	"log"

	"github.com/confluentinc/confluent-kafka-go/kafka"
)

func main() {
	producer := NewKafkaProducer()
	Publish("Mensagem", "teste", producer, nil)
}

func NewKafkaProducer() *kafka.Producer {
	configMap := &kafka.ConfigMap{
		"bootstrap.servers": "kafka-go-kafka-1:9092",
	}
	p, err := kafka.NewProducer(configMap)
	if err != nil {
		log.Println(err.Error())
	}
	return p
}

func Publish(msg string, topic string, producer *kafka.Producer, key []byte) error {
	message := &kafka.Message{
		Value:          []byte(msg),
		TopicPartition: kafka.TopicPartition{Topic: &topic, Partition: kafka.PartitionAny},
		Key:            key,
	}
	err := producer.Produce(message, nil)
	if err != nil {
		return err
	}
	return nil
}
```

Vamos baixar as dependencias e executar o codigo:
```bash
root@51c4d044c58b:/go/src# go mod tidy
root@51c4d044c58b:/go/src# go run cmd/producer/main.go 
# command-line-arguments
/usr/local/go/pkg/tool/linux_arm64/link: running gcc failed: exit status 1
/usr/bin/ld: /go/pkg/mod/github.com/confluentinc/confluent-kafka-go@v1.9.2/kafka/librdkafka_vendor/librdkafka_glibc_linux.a(rdkafka_error.o): Relocations in generic ELF (EM: 62)
/usr/bin/ld: /go/pkg/mod/github.com/confluentinc/confluent-kafka-go@v1.9.2/kafka/librdkafka_vendor/librdkafka_glibc_linux.a(rdkafka_error.o): Relocations in generic ELF (EM: 62)
/usr/bin/ld: /go/pkg/mod/github.com/confluentinc/confluent-kafka-go@v1.9.2/kafka/librdkafka_vendor/librdkafka_glibc_linux.a: error adding symbols: file in wrong format
collect2: error: ld returned 1 exit status
```

Se esse problema acontecer, é pq nao existe librdkafka para arm64 pre compilado, por isso a instruçao do `❯ DOCKER_DEFAULT_PLATFORM=linux/amd64 docker compose build `

Quando ele vai publicar a aplicaçao go já acabou e o programa moprreu e nao deu tempo dse ele fazer essa publicaçao. 

O producer.Flush() espera receber um retorno que a mensagem foi entregue ou nao. Ou agurada o retorno o espera milissegundos da  mesnagem e morre. Vamos esperar 1 segundo!
```go
package main

import (
	"log"

	"github.com/confluentinc/confluent-kafka-go/kafka"
)

func main() {
	producer := NewKafkaProducer()
	Publish("Mensagem", "teste", producer, nil)
	producer.Flush(1000)
}

func NewKafkaProducer() *kafka.Producer {
	configMap := &kafka.ConfigMap{
		"bootstrap.servers": "kafka-go-kafka-1:9092",
	}
	p, err := kafka.NewProducer(configMap)
	if err != nil {
		log.Println(err.Error())
	}
	return p
}

func Publish(msg string, topic string, producer *kafka.Producer, key []byte) error {
	message := &kafka.Message{
		Value:          []byte(msg),
		TopicPartition: kafka.TopicPartition{Topic: &topic, Partition: kafka.PartitionAny},
		Key:            key,
	}
	err := producer.Produce(message, nil)
	if err != nil {
		return err
	}
	return nil
}
```
E vamos ver se conseguimos publicar a mensagem!

```bash
go run cmd/producer/main.go
```


Como sabemos se deu tudo certo e temos um retorno em qual partiçao, offset e se deu tudo certo?


## Delivery report

Nao adianta apenas publicarmos a mensagem mas precisamos receber o retorno do que aconteceu ao publicar. DeliverycHANEL É UM CANAL DE COMUNICAÇAO ENTRE A PUBLICAÇAO DA MENSAGEM E UMA ROTINA QUE EXECITAMOS.

Quando tem um retorno, ele envia essa mensagem para um canal de comunicaçao que vai estar sendo lido. Quando chegar mensagem nesse canal, essa mensagem ser;á o retorno do envio, como se fosse uma callback. Uma funçao quye fica aguragudando e envia o resultado de forma assinmcrona.

Para termos ideia do que acontece vamos fazer sincrona, entretanto a velocidade vai ser altamente comporometida! Se for assincrona, mandamos a mensagem e outra funçao vai ler esse retorno. Muito mais rapido.

Vamos usar o channels!

Vamos observar a resposta de qual partição a mensagem foi enviada:
```go
package main

import (
	"fmt"
	"log"

	"github.com/confluentinc/confluent-kafka-go/kafka"
)

func main() {
	deliveryChan := make(chan kafka.Event)
	producer := NewKafkaProducer()
	Publish("Mensagem", "teste", producer, nil, deliveryChan)

	e := <-deliveryChan
	msg := e.(*kafka.Message)
	if msg.TopicPartition.Error != nil {
		fmt.Println("Error to send")
	} else {
		fmt.Println("Sent message: ", msg.TopicPartition)
	}

	producer.Flush(1000)
}

func NewKafkaProducer() *kafka.Producer {
	configMap := &kafka.ConfigMap{
		"bootstrap.servers": "kafka-go-kafka-1:9092",
	}
	p, err := kafka.NewProducer(configMap)
	if err != nil {
		log.Println(err.Error())
	}
	return p
}

func Publish(msg string, topic string, producer *kafka.Producer, key []byte, deliveryChan chan kafka.Event) error {
	message := &kafka.Message{
		Value:          []byte(msg),
		TopicPartition: kafka.TopicPartition{Topic: &topic, Partition: kafka.PartitionAny},
		Key:            key,
	}
	err := producer.Produce(message, deliveryChan)
	if err != nil {
		return err
	}
	return nil
}
```

```bash
root@84e400c5013d:/go/src# go run cmd/producer/main.go
Sent message:  teste[1]@1
```

Olha só. Ele respondeu a Mensagem no topico teste na partiçao 1, no offset 1 (2a mensagem enviada no partiçao 1).

Vamos enviar novamente:
```bash
root@84e400c5013d:/go/src# go run cmd/producer/main.go
Sent message:  teste[1]@2
```

Olha só. Terceira mensagem (offset 2) enviada na partiçao 1 do tópico teste!

Dessa forma ainda nao esta legal pq esta de forma sincrona (receber o retorno para mandar a proxima)


## Recebendo report de forma assíncrona

Vamos tornar o código assincrono enviando mensagens e em outra thread receber os dados.

Vamos criar uma funçao de delivery report!
```go
package main

import (
	"fmt"
	"log"

	"github.com/confluentinc/confluent-kafka-go/kafka"
)

func main() {
	deliveryChan := make(chan kafka.Event)
	producer := NewKafkaProducer()
	Publish("Mensagem", "teste", producer, nil, deliveryChan)
	DeliveryReport(deliveryChan)
	// e := <-deliveryChan
	// msg := e.(*kafka.Message)
	// if msg.TopicPartition.Error != nil {
	// 	fmt.Println("Error to send")
	// } else {
	// 	fmt.Println("Sent message: ", msg.TopicPartition)
	// }

	// producer.Flush(1000)
}

func NewKafkaProducer() *kafka.Producer {
	configMap := &kafka.ConfigMap{
		"bootstrap.servers": "kafka-go-kafka-1:9092",
	}
	p, err := kafka.NewProducer(configMap)
	if err != nil {
		log.Println(err.Error())
	}
	return p
}

func Publish(msg string, topic string, producer *kafka.Producer, key []byte, deliveryChan chan kafka.Event) error {
	message := &kafka.Message{
		Value:          []byte(msg),
		TopicPartition: kafka.TopicPartition{Topic: &topic, Partition: kafka.PartitionAny},
		Key:            key,
	}
	err := producer.Produce(message, deliveryChan)
	if err != nil {
		return err
	}
	return nil
}

func DeliveryReport(deliveryChan chan kafka.Event) {
	for e := range deliveryChan {
		switch ev := e.(type) {
		case *kafka.Message:
			if ev.TopicPartition.Error != nil {
				fmt.Println("Error to send")
			} else {
				fmt.Println("Sent message: ", ev.TopicPartition)
			}
		}
	}
}

```

```bash
root@84e400c5013d:/go/src# go run cmd/producer/main.go
Sent message:  teste[1]@3
```

Apesar de ter enviado, o terminal está travado nesse momento!

Isso pq o programa esta parado na Funcao do DeliveryReport pq esta em loop infinito! Enquanto nenhum eveto chega ele fica aguardando e trava o termnal. Precisamos rodar isso de uma forma assincrona ainda!

O go tem goroutine, pegando a funçao e fazendo uma thread com ela! `go DeliveryReport(deliveryChan)`

```go
package main

import (
	"fmt"
	"log"

	"github.com/confluentinc/confluent-kafka-go/kafka"
)

func main() {
	deliveryChan := make(chan kafka.Event)
	producer := NewKafkaProducer()
	Publish("Mensagem", "teste", producer, nil, deliveryChan)
	go DeliveryReport(deliveryChan) // async
	// e := <-deliveryChan
	// msg := e.(*kafka.Message)
	// if msg.TopicPartition.Error != nil {
	// 	fmt.Println("Error to send")
	// } else {
	// 	fmt.Println("Sent message: ", msg.TopicPartition)
	// }

	// producer.Flush(1000)
}

func NewKafkaProducer() *kafka.Producer {
	configMap := &kafka.ConfigMap{
		"bootstrap.servers": "kafka-go-kafka-1:9092",
	}
	p, err := kafka.NewProducer(configMap)
	if err != nil {
		log.Println(err.Error())
	}
	return p
}

func Publish(msg string, topic string, producer *kafka.Producer, key []byte, deliveryChan chan kafka.Event) error {
	message := &kafka.Message{
		Value:          []byte(msg),
		TopicPartition: kafka.TopicPartition{Topic: &topic, Partition: kafka.PartitionAny},
		Key:            key,
	}
	err := producer.Produce(message, deliveryChan)
	if err != nil {
		return err
	}
	return nil
}

func DeliveryReport(deliveryChan chan kafka.Event) {
	for e := range deliveryChan {
		switch ev := e.(type) {
		case *kafka.Message:
			if ev.TopicPartition.Error != nil {
				fmt.Println("Error to send")
			} else {
				fmt.Println("Sent message: ", ev.TopicPartition)
			}
		}
	}
}
```

```bash
root@84e400c5013d:/go/src# go run cmd/producer/main.go
```

Ao rodar, temos um outro problema. Apesar de rodar, nao travou o termnal mas nao recebemos o Report! Isso aconteceu pq nao deu nem tempo do DeliveryReport receber o retorno mas o programa ja acabou! Nesse caso, o Flush ajuda a receber a mensagem com um timeout de 1 segundo:
```go
package main

import (
	"fmt"
	"log"

	"github.com/confluentinc/confluent-kafka-go/kafka"
)

func main() {
	deliveryChan := make(chan kafka.Event)
	producer := NewKafkaProducer()
	Publish("Mensagem", "teste", producer, nil, deliveryChan)
	go DeliveryReport(deliveryChan)
	producer.Flush(1000)
	// e := <-deliveryChan
	// msg := e.(*kafka.Message)
	// if msg.TopicPartition.Error != nil {
	// 	fmt.Println("Error to send")
	// } else {
	// 	fmt.Println("Sent message: ", msg.TopicPartition)
	// }

	// producer.Flush(1000)
}

func NewKafkaProducer() *kafka.Producer {
	configMap := &kafka.ConfigMap{
		"bootstrap.servers": "kafka-go-kafka-1:9092",
	}
	p, err := kafka.NewProducer(configMap)
	if err != nil {
		log.Println(err.Error())
	}
	return p
}

func Publish(msg string, topic string, producer *kafka.Producer, key []byte, deliveryChan chan kafka.Event) error {
	message := &kafka.Message{
		Value:          []byte(msg),
		TopicPartition: kafka.TopicPartition{Topic: &topic, Partition: kafka.PartitionAny},
		Key:            key,
	}
	err := producer.Produce(message, deliveryChan)
	if err != nil {
		return err
	}
	return nil
}

func DeliveryReport(deliveryChan chan kafka.Event) {
	for e := range deliveryChan {
		switch ev := e.(type) {
		case *kafka.Message:
			if ev.TopicPartition.Error != nil {
				fmt.Println("Error to send")
			} else {
				fmt.Println("Sent message: ", ev.TopicPartition)
			}
		}
	}
}

```

```bash
root@84e400c5013d:/go/src# go run cmd/producer/main.go
Sent message:  teste[2]@1
```

O que fazemos com o Delivery Report? Podemos anotar no banco de dados que a mensagem foi enviada. 

Anotar no db que a mensagem foi processada
Ex: confirma que uma transferencia bancaria ocorreu
Caso nao ocorreu, pode ser necessário fazer um retry

Vamos imaginar que tem que fazer o envio de um email muito importante, como dados de acesso. Ao inves de bloquear o sistema enviado o email, mandamos essa mensagem para o kafka e vai ter um outro consumidor enviando o email. E se quisermos ter a certeza que essa mensagem chegou no kafka, iremos enviar a mensagem e aguardar o resultado. Dessa forma vamos ter a absoluta certeza pq o kafka nos avisou!


## Parâmetros importantes

E os acks? ClientId? E a indepotencia?
Sao esses detalhes que mudam completamente o nivel de confiabilidade, granulalidade, certezas de entregas.

Para isso, há uma série de configuraçoes que podemos passar para criar o producer.

https://github.com/confluentinc/librdkafka/blob/master/CONFIGURATION.md

Podemos enviar mensagens e a cada 100 mesnagens para enquanto nao estiver recebedo a confirmaçao das menasgens, por exemplo.

uma opçao superimportante é o tempo maximo de ntrega de uma mensagem (delivery.timeout.ms). Na hora em que enviamos uma mensagem, temos que aguardar para recevver o retorno que essa mensagem foi entregue e podemos configiurar o tempo. Tempois disso, rececemos a mensagem que a mensagem nao foi entregue. Se o tempo for zero, agiarda-se infinitamente.

Vamos imaginar que se a mensagem demorar muito para enviar nao faz nem mais sentido. Ou se a mensagem for tao importaaaante, se em um segundo nao receber a confirmaçao da mensagem, vamos fazer um if para renviar a mensagem!

Outro parametro é o ack. 
0 (envia a mensagem e nao precisa receber o retorno de entrega)
1 (aguarda que o lider retorne falando que ele já persistiu a mensagem)
all (espera o lider e os insunc brokers com copias dessa partiçao tb tenham persistido e sicronizado a mebsagem)

Um parametro muda completamente o modo de trabalho e a logica de toda a computaçao

enable.indepotence: por padrao o parametro é false e isso significa que  o produtor nao eh idepotente entao muitas vezes a mensagem pode chrgar mais de uma vez ou pular a mensagem (at least, once). Mas se quiser apenas uma vez EXATAMENTE, a indepotencia vai para true e o ack ser all.

Essas configs mudam drasticamente a forma do envio das mensagens!

Leia a doc e veja os parametros high e medium para ver o que da para fazer em relaçao a opçoes.

group.id é HIGH!

```go
package main

import (
	"fmt"
	"log"

	"github.com/confluentinc/confluent-kafka-go/kafka"
)

func main() {
	deliveryChan := make(chan kafka.Event)
	producer := NewKafkaProducer()
	Publish("Mensagem", "teste", producer, nil, deliveryChan)
	go DeliveryReport(deliveryChan)
	producer.Flush(1000)
}

func NewKafkaProducer() *kafka.Producer {
	configMap := &kafka.ConfigMap{
		"bootstrap.servers":   "kafka-go-kafka-1:9092",
		"delivery.timeout.ms": "0",
		"acks":                "all",
		"enable.idempotence":  "true",
	}
	p, err := kafka.NewProducer(configMap)
	if err != nil {
		log.Println(err.Error())
	}
	return p
}

func Publish(msg string, topic string, producer *kafka.Producer, key []byte, deliveryChan chan kafka.Event) error {
	message := &kafka.Message{
		Value:          []byte(msg),
		TopicPartition: kafka.TopicPartition{Topic: &topic, Partition: kafka.PartitionAny},
		Key:            key,
	}
	err := producer.Produce(message, deliveryChan)
	if err != nil {
		return err
	}
	return nil
}

func DeliveryReport(deliveryChan chan kafka.Event) {
	for e := range deliveryChan {
		switch ev := e.(type) {
		case *kafka.Message:
			if ev.TopicPartition.Error != nil {
				fmt.Println("Error to send")
			} else {
				fmt.Println("Sent message: ", ev.TopicPartition)
			}
		}
	}
}
```

## Trabalhando com keys

Quando vamos madar uma mensagem e ela tiver sem key, cada hora ela vai cair em uma partiçao.
Se as mensagens caem em partiçoes diferentes, naoé possivel garantir a ordem das leituras pq cada consumidor está 

```bash
root@84e400c5013d:/go/src# go run cmd/producer/main.go
Sent message:  teste[0]@1
root@84e400c5013d:/go/src# go run cmd/producer/main.go
Sent message:  teste[1]@4
root@84e400c5013d:/go/src# go run cmd/producer/main.go
Sent message:  teste[2]@2
```

E entao nao conseguimos garantir a ordem das leituras!
Vamos fazer uma transaçao e processar o estorno antes da trasnferencia!
A key garante que toda vez que passarmos uma mensagem ela vai cair na mesma partiçao para ser processada pelo consumer. 
Vamos colocar a key `[]byte("transfer")`
```go
package main

import (
	"fmt"
	"log"

	"github.com/confluentinc/confluent-kafka-go/kafka"
)

func main() {
	deliveryChan := make(chan kafka.Event)
	producer := NewKafkaProducer()
	Publish("Mensagem", "teste", producer, []byte("transfer"), deliveryChan)
	go DeliveryReport(deliveryChan)
	producer.Flush(1000)
}

func NewKafkaProducer() *kafka.Producer {
	configMap := &kafka.ConfigMap{
		"bootstrap.servers":   "kafka-go-kafka-1:9092",
		"delivery.timeout.ms": "0",
		"acks":                "all",
		"enable.idempotence":  "true",
	}
	p, err := kafka.NewProducer(configMap)
	if err != nil {
		log.Println(err.Error())
	}
	return p
}

func Publish(msg string, topic string, producer *kafka.Producer, key []byte, deliveryChan chan kafka.Event) error {
	message := &kafka.Message{
		Value:          []byte(msg),
		TopicPartition: kafka.TopicPartition{Topic: &topic, Partition: kafka.PartitionAny},
		Key:            key,
	}
	err := producer.Produce(message, deliveryChan)
	if err != nil {
		return err
	}
	return nil
}

func DeliveryReport(deliveryChan chan kafka.Event) {
	for e := range deliveryChan {
		switch ev := e.(type) {
		case *kafka.Message:
			if ev.TopicPartition.Error != nil {
				fmt.Println("Error to send")
			} else {
				fmt.Println("Sent message: ", ev.TopicPartition)
			}
		}
	}
}
```

```bash
root@84e400c5013d:/go/src# go run cmd/producer/main.go
Sent message:  teste[0]@3
```

Como vamos manter a mesma key, ela sempre será colocada para a partiçao que enviou a primeira vez, isto é, partiçao 0:
 vamos ver:

 ```bash
root@84e400c5013d:/go/src# go run cmd/producer/main.go
Sent message:  teste[0]@4
root@84e400c5013d:/go/src# go run cmd/producer/main.go
Sent message:  teste[0]@5
root@84e400c5013d:/go/src# go run cmd/producer/main.go
Sent message:  teste[0]@6
root@84e400c5013d:/go/src# go run cmd/producer/main.go
Sent message:  teste[0]@7
 ```

Todas as mensagens agora estao sendo encaminhadas para a partição 0!


## Consumindo mensagens

O Consumer var ser um loop infinitoi que vai ler as mensagens!
cmd/consumer/main.go
```go
package main

import (
	"fmt"

	"github.com/confluentinc/confluent-kafka-go/kafka"
)

func main() {
	configMap := &kafka.ConfigMap{
		"bootstrap.servers": "kafka-go-kafka-1:9092",
		"client.id":         "goapp-consumer",
		"group.id":          "goapp-group",
		"auto.offset.reset": "earliest",
	}
	c, err := kafka.NewConsumer(configMap)
	if err != nil {
		fmt.Println("error message: ", err.Error())
	}
	topics := []string{"teste"}
	c.SubscribeTopics(topics, nil)
	for {
		msg, err := c.ReadMessage(-1)
		if err == nil {
			fmt.Println(string(msg.Value), msg.TopicPartition)
		}
	}
}
```

No consumer group, cada consumer vai ler de uma partiçao diferente. Mesmo que exista um unico consumer, ele é o proprio grup! O ideal é semrpe ter a mesma quantidade de consumers dentro de um grupo que o numero de partiçoes.

Vamos executar e ver se vai funcionar:
```bash
root@84e400c5013d:/go/src# go run cmd/consumer/main.go 
Mensagem teste[2]@0
Mensagem teste[2]@1
Mensagem teste[2]@2
Mensagem teste[0]@0
Mensagem teste[0]@1
Mensagem teste[0]@2
Mensagem teste[0]@3
Mensagem teste[0]@4
Mensagem teste[0]@5
Mensagem teste[0]@6
Mensagem teste[0]@7
Mensagem teste[1]@0
Mensagem teste[1]@1
Mensagem teste[1]@2
Mensagem teste[1]@3
Mensagem teste[1]@4
Mensagem teste[1]@5
```

Com o parametro earlist, ele le todas as mensagens que enviamos at;é agora.

E ao enviarmos uma nova mensagem:
```bash
cmd/producer/main.go
Sent message:  teste[0]@8
```

Verificamos no consumer que ela chegou corretamente
```bash
Mensagem teste[0]@8
```

Nesse ponto estamos lendo a mesgame o tempo todo bo kafka.

## Consumer groups na pratica
Temos 3 partiçoes e um conumsr. Isso significa que o consumer le as tres partiçoes.

Vamos no node do kafka e executar o seguinte comando:
```bash
❯ docker exec -it kafka-go-kafka-1 bash
[appuser@ec5274cdc055 ~]$ kafka-consumer-groups --bootstrap-server=localhost:9092  --des
cribe --group=goapp-group

GROUP           TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID                                         HOST            CLIENT-ID
goapp-group     teste           0          9               9               0               goapp-consumer-8cdd33ba-afea-4776-a475-730338559999 /172.21.0.2     goapp-consumer
goapp-group     teste           1          6               6               0               goapp-consumer-8cdd33ba-afea-4776-a475-730338559999 /172.21.0.2     goapp-consumer
goapp-group     teste           2          3               3               0               goapp-consumer-8cdd33ba-afea-4776-a475-730338559999 /172.21.0.2     goapp-consumer
```

Se olharmos agora, o client-id goapp-consumer possui um Id e ele é o mesmo para as tres partiçoes pq temos apenas um worker. Cada worker le das tres patiçoes.

Podemos modificar o nome do client.id e ler as mensagens do kafka. Mesmo com earliset as mensagens antigas nao vem pq ja esta sendo lida pelo consumer 1.

Quando rodamos duas vezes com client-id diferentes, um vai ler as partiçaoes 0 e 1 e o outro apenas a partiçao 2.

se colocarmos mais um consumer com client-di 3, cada um lerá uma partiçao! SAO TRES CONSUMIDORES LENDO UM MESMO TOPICO SENDO QUE ESSE TOPICO É LIDO 3 VEZES MAIS RAPIDO!

Se colocarmos mais um consumer, nao adianta termos mais consumidores do que partiçoes! Ficara ocioso até que um deles caia e ele encontre espaço para subir.


```bash


GROUP           TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG    CONSUMER-ID                                  HOST            CLIENT-ID
goapp-group     teste           0          11              11              0               rdkafka-1a2abb2f-8d2d-4ff6-aad0-5d977bd18bf5 /172.21.0.2     rdkafka
goapp-group     teste           1          6               6               0               rdkafka-1a2abb2f-8d2d-4ff6-aad0-5d977bd18bf5 /172.21.0.2     rdkafka
goapp-group     teste           2          3               3               0               rdkafka-1d54f525-c1e3-44c3-a71d-4498a85bea23 /172.21.0.2     rdkafka
```
# Kafka Connect
## Repositório
https://github.com/rogeriocassares/fc2-kafka-connect
## Introdução ao Kafka Connect
O Apache kafka é uma plataforma muito bem sucedida. Ele possui diversos componentes em volta dessa plataforma e isso ajuda demais diversos tipos de soluçoes enquanto outros frameworks os sistema de filas as vezes nao funciona

O Kafka Connect é fantatico e nos ajuda a integrar qualquer tipo de sistema!

## Entendendo a dinâmica do Kafka Connect 
"Kafka Connect é um componente gratuito e open-source do Apache Kafka que trabalha como um hub dados centralizado para integrações simples entre banco de dados, key-value stores, search indexes e file systems."
https://docs.confluent.io/platform/current/connect/index.html

Isso significa que as integraçoes de sistemas nao sao tao complexas e ele funciona como hub de informaçao.

Dinamica: Vamos imaginar que temos um CRM com salesforce e estamos migrando ou precisando dessas informações deste crm para colcoar em algum outro sistema como db para ciencia de dados ou outro sistema/plataforma etc, banco mysql
Podemos conectar o kafka connect no salesforce, gravar em um topico do kafka e jogar a informaçao no sql sem programar nada! Ou mesmo pegar do mysql e jogar no mongodb. Evitar desenvolver algo do zero será bem vindo em qualquer lugar.

A partir do apachekafka, temos do kafka connect que fica falando o tempo todo com o kafka. A partir daí temos diversos tipos de conectores. O grande ponto dos conectores, é que de um lado há os conectores chamados DataSources, que pegam dados de algum lugar, de um banco de dados, por exemplo (Input). Do outro lado, temos outro tipo de conector chamado de Sinks (output). AWS Lambda, ElasticSearch, jdbc etc. Nao interessa como pegamos os dados, mas atraves dos conectores enviarmos para onde quisermos. O kafka connect tem 2 tarefas (input+output)

![Alt text](image-23.png)

## Workers
Standalone Workers: O kafka connect é feito atravvés de workers. O standalone é apenas um worker que é o responsavel por rodar as tarefas qu queremos rodar.

A tarefa é o processo que roda no worker e usa o conector para fazer a transiçao de dados de um ponto para o outro. A tarefa é quem realmente executa o trabalho. Podemos ter mais de um conector rodando o kafka connect em um mesmo worker, trabalhando em paralelo.
![Alt text](image-24.png)

Distributed Workers: Nesse caso, ele vai trabvalhar em um cluster com 3 Workers e essas maquinas se ajudem a processar as informaçoes. As vezes temos uma tarefa que tem que ler de 3 partiçoes. Quando temos mais de um Worker e esse worker estao dentro de um mesmo grupo (GroupId) ele vao dividir essas tarefas para conseguirmos processar essas informaçoes mais rapidamente. Imagina um topico com muita informaçao, gravar em um db etc. Se tivermos 3 tarefas, cada tarefa le uma partiçao e está localizada em workers distribuido. Eles se organizam para ler das partiçoes pq estao  trabalhando em um cluster e funciona bem parecido com um consumer group.
![Alt text](image-25.png)

## Converters e Dead Letter Queue
Converters: As tasks utilizam os "converters" para mudar o formato dos dados tanto para
leitura ou escrita no Kakfa.
• Avro
• Protobuf
• JsonSchema
• Json
• String
• ByteArray

![Alt text](image-26.png)

DLQ: Como temos diverrsos passos desde o dado ser gravado no kfka para serr lido em utro lugar, muitas vezes esse dado nao esta no formato como gostariamos. Entao na hora que o conector le e bate no converter e dá um erro no formato, na gravaçao ou no processamento. E o que fazemos? DLQ!

DLQ normalmente é um local onde jogamos as informaçoes que deram erro para analizarmos depois. 


Quando há um registro inválido, independente da razão, o erro pode ser tratado nas configurações do conector através da propriedade "errors. tolerance". Esse tipo de configuração pode ser realizado apenas para conectores do tipo "Sink"
Sink significa que os dados já estao no kafka e queremos pegar esses dados e jogar para um lugar.

Tipos:
• none: Faz a tarefa falhar imediatamente.
O grande pronblema eh que quando a tarefa falha, ela para a Task. E termos que olhar o log, entender e colcoar para funcionar novamente. Evita qualquer tipo de problema.

all: Erros sao ignorados e processo continua normalmente
passa tudo, mas nao sasabmos que ele aconteceu. 

Dependendo dos dados e da integridade, podemos ignorar. Mas quando é muito serio precisamos saber o que acontece. Por isso, temos o parametro:

`errors.deadletterqueue.topic.name=<TOPIC_NAME>`. Para isso, o DLQ deve estar configurado para `all`

Entao, simplesmente, toda vez que der um erro, vamos mandar a mensagem para um topico e verificar o erro naquela mensagem. Como sabemos o problema? O kafka connect vai registrar os erros no cabeçalho. Esse é o melhor dos mundos pois nao paramos as tarefas mas temos a mensagem com problema e qual foi o problema. Se nao falarmos nada de DLQ, o padrao é node e vai parar tudo! Cuidado!

## Fazendo tour no Confluent Hub
No Confluent hub, é um local/repositorio onde podemos buscar tipos de plugns que podemos trabalhar com o kafka connect

https://www.confluent.io/hub/

Sinks para onde
Sources, de onde
Transforms
Converters

Existe muiiitaa coisa. Algo muito comum de se buscar sao bamcos de dados em geral. E vamos perceber que tem o debezium. É um dos caras mais utilizados do mercado quando trabahamos com o kafka connect pois possui uma alta variedade de conexão com banco de dados!

https://debezium.io/
https://www.confluent.io/hub/debezium/debezium-connector-mysql

Captura mudanças de banco de dados e está conectado ao kafka! 

E também trabalharemos com o Connector do MongoDB!
https://www.confluent.io/hub/mongodb/kafka-connect-mongodb


## Inicializando serviços
Vamos dar um for no kafka-connect do mysql para dar um fork nos logs binarios. 

Vamos copiar o docker-compose do repositorio
Para converter os formatos, vamos trabalhar com o padrao JSOn. Nao será Schema Registry nem fixo.
O mais importante aqui é que quando por algum motivo nao formos utilizar o docker, existem alguns caminhos que podemos configurar, mas podmos instalar de uma forma um pouco mais simples ao nves de baixar e descompactar.
Vamos utilizar um comando no-prompt para instalar o debezium e o kafka-connect-mongodb

Esse curso não é para ser formado em kafka, mas uma boa noçao do que conseguimos fazer e realizar integraçoes concretas. Hoje em dia é muito mais comum utilizarmos serviços gerenciados do kafka!

```yaml
version: "3"

services:  
  mysql:
    image: wesleywillians/mysql-kafka-connect:latest
    command: --innodb-use-native-aio=0
    tty: true
    restart: always
    ports:
      - "33600:3306"
    environment:
      - MYSQL_DATABASE=fullcycle
      - MYSQL_ROOT_PASSWORD=root
      - MYSQL_USER=root
    extra_hosts:
      - "host.docker.internal:172.17.0.1"

  zookeeper:
    image: confluentinc/cp-zookeeper:7.5.3
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181

  kafka:
    image: confluentinc/cp-kafka:7.5.3
    depends_on:
      - zookeeper
    ports:
      - "9092:9092"
      - "9094:9094"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_INTER_BROKER_LISTENER_NAME: INTERNAL
      KAFKA_LISTENERS: INTERNAL://:9092,OUTSIDE://:9094
      KAFKA_ADVERTISED_LISTENERS: INTERNAL://kafka:9092,OUTSIDE://host.docker.internal:9094
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: INTERNAL:PLAINTEXT,OUTSIDE:PLAINTEXT
    extra_hosts:
      - "host.docker.internal:172.17.0.1"

  control-center:
    image: confluentinc/cp-enterprise-control-center:7.5.3
    hostname: control-center
    depends_on:
      - kafka
    ports:
      - "9021:9021"
    environment:
      CONTROL_CENTER_BOOTSTRAP_SERVERS: 'kafka:9092'
      CONTROL_CENTER_REPLICATION_FACTOR: 1
      CONTROL_CENTER_CONNECT_CLUSTER: http://kafka-connect:8083
      PORT: 9021
    extra_hosts:
      - "host.docker.internal:172.17.0.1"

  kafka-connect:
    image: confluentinc/cp-kafka-connect-base:7.5.3
    container_name: kafka-connect
    depends_on:
      - zookeeper
      - kafka
    ports:
      - 8083:8083
    environment:
      CONNECT_BOOTSTRAP_SERVERS: "kafka:9092"
      CONNECT_REST_PORT: 8083
      CONNECT_GROUP_ID: kafka-connect
      CONNECT_CONFIG_STORAGE_TOPIC: _connect-configs
      CONNECT_OFFSET_STORAGE_TOPIC: _connect-offsets
      CONNECT_STATUS_STORAGE_TOPIC: _connect-status
      CONNECT_KEY_CONVERTER: org.apache.kafka.connect.storage.StringConverter
      CONNECT_VALUE_CONVERTER: org.apache.kafka.connect.json.JsonConverter
      CONNECT_INTERNAL_KEY_CONVERTER: "org.apache.kafka.connect.json.JsonConverter"
      CONNECT_INTERNAL_VALUE_CONVERTER: "org.apache.kafka.connect.json.JsonConverter"
      CONNECT_REST_ADVERTISED_HOST_NAME: "kafka-connect"
      CONNECT_LOG4J_ROOT_LOGLEVEL: "INFO"
      CONNECT_LOG4J_LOGGERS: "org.apache.kafka.connect.runtime.rest=WARN,org.reflections=ERROR"
      CONNECT_LOG4J_APPENDER_STDOUT_LAYOUT_CONVERSIONPATTERN: "[%d] %p %X{connector.context}%m (%c:%L)%n"
      CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR: "1"
      CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR: "1"
      CONNECT_STATUS_STORAGE_REPLICATION_FACTOR: "1"
      # # Optional settings to include to support Confluent Control Center
      #   CONNECT_PRODUCER_INTERCEPTOR_CLASSES: "io.confluent.monitoring.clients.interceptor.MonitoringProducerInterceptor"
      #   CONNECT_CONSUMER_INTERCEPTOR_CLASSES: "io.confluent.monitoring.clients.interceptor.MonitoringConsumerInterceptor"
      #  ---------------
      CONNECT_PLUGIN_PATH: /usr/share/java,/usr/share/confluent-hub-components,/data/connect-jars
    # If you want to use the Confluent Hub installer to d/l component, but make them available
    # when running this offline, spin up the stack once and then run :
    #   docker cp kafka-connect:/usr/share/confluent-hub-components ./data/connect-jars
    volumes:
      - $PWD/data:/data
    # In the command section, $ are replaced with $$ to avoid the error 'Invalid interpolation format for "command" option'
    command:
      - bash
      - -c
      - |
        echo "Installing Connector"
        confluent-hub install --no-prompt debezium/debezium-connector-mysql:1.2.2
        confluent-hub install --no-prompt mongodb/kafka-connect-mongodb:1.5.0
        #
        echo "Launching Kafka Connect worker"
        /etc/confluent/docker/run &
        #
        sleep infinity
    extra_hosts:
      - "host.docker.internal:172.17.0.1"

  mongodb:
    image: mongo:4.4.4
    restart: always
    volumes:
      - ./.docker/dbdata:/data/db
      - ./.docker/mongo:/docker-entrypoint-initdb.d
    environment:
      - MONGO_INITDB_ROOT_USERNAME=root
      - MONGO_INITDB_ROOT_PASSWORD=root
      - MONGO_INITDB_DATABASE=fullcycle
    extra_hosts:
      - "host.docker.internal:172.17.0.1"

  mongo-express:
    image: mongo-express
    restart: always
    ports:
      - 8085:8081
    environment:
      - ME_CONFIG_MONGODB_SERVER=mongodb
      - ME_CONFIG_MONGODB_AUTH_USERNAME=root
      - ME_CONFIG_MONGODB_AUTH_PASSWORD=root
      - ME_CONFIG_MONGODB_ADMINUSERNAME=root
      - ME_CONFIG_MONGODB_ADMINPASSWORD=root
    depends_on:
      - mongodb
```

E vamos executar!
```bash
❯ docker compose up -d
```





## Verificando Kafka Connect no Control Center
Após tudo ter sido baixado, vamos entrar no painel de controle do confluent control center
http://localhost:9021

No confluent control cventer, temos 1 connect cluster!
Vamso clicar e comçar a analizar. O proprio kafka-connect utiliza topicos para trabalhar.

Em Connect, vamos verificar os conectores e adicionar clicantdo nos conectores que aparecem por padrao e ja instalados. Vamos trabalhar com o mysql e com o mongo

Se clicarmos em cada um, ele vai fazer um assistente para fazermos um processo de configuraçao que ele faz um post. O kafka connect possui uma API rest e nela podemos ver status de conectores, posts, etc. Se olharmos, ele mostra qual o connector class. 

Nós vamos fazer o nosso proprio arquivo de configraçao e fazer o upload. 


## Configurando MySQL

Vamos entarar no db:
```bash
❯ docker exec -it kafka-connect-mysql-1 bash
root@3b510c140f63:/# mysql -u root -p fullcycle
Password: root
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 2
Server version: 5.7.32-log MySQL Community Server (GPL)

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
```

Vamos Criar uma tabela:
```bash
create table categories (id int auto_increment primary key, name varchar(255));
Query OK, 0 rows affected (0.08 sec)
```

E vamos ver as tables:
```bash
mysql> show tables;
+---------------------+
| Tables_in_fullcycle |
+---------------------+
| categories          |
+---------------------+
1 row in set (0.01 sec)
```

E descreve-la:
```bash
mysql> desc categories;
+-------+--------------+------+-----+---------+----------------+
| Field | Type         | Null | Key | Default | Extra          |
+-------+--------------+------+-----+---------+----------------+
| id    | int(11)      | NO   | PRI | NULL    | auto_increment |
| name  | varchar(255) | YES  |     | NULL    |                |
+-------+--------------+------+-----+---------+----------------+
2 rows in set (0.08 sec)
```

Vamos inserir um dado:
```bash
mysql> insert into categories (name) values('Electronics');
Query OK, 1 row affected (0.04 sec)
```

E entao um select:
```bash
mysql> select * from categories;
+----+-------------+
| id | name        |
+----+-------------+
|  1 | Electronics |
+----+-------------+
1 row in set (0.01 sec)
```

Ate aqui, temos um banco de dados, com uma tabela chamada Electronics.

Agora vamos criar um conector para acessar o banco de dados e jogar no kafka!


## Configurando conector do MySQL
vamos criar uma pasta connectors e crirar um aqeuivo mysql.propreties
```properties
name=mysql-connector
connector.class=io.debezium.connector.mysql.MySqlConnector
tasks.max=1
database.user=root
database.password=root
database.hostname=mysql
database.port=3306
database.server.name=mysql-server
database.history.kafka.bootstrap.servers=kafka:9092
database.history.kafka.topic=mysql_history
```
 um dos pontos mais importsntes: connector.class. 
 Ele sempre vai tentar grava o historico das inofmrçoes que já temos em um topico do kafka, assim como as demais que chegarem com  o nome mysql_history

 Agora, vamos subir esse conector no nosso kafka-connect

 http://localhost:9021 -> Connect --> upload 

Após os campos serem preenchidos, vamos dar um launch!

Para testar se esta funcionando, em Topics, vemos o mysql-server, que é o topico que ele criou baseado no servidor, o mysql.history e o mysql-server.fullcycle.categories. Isso significa existe um tócico da tabela! Se entrarmos nesse topico, podemos observar as mensagens e se colocarmos offset 0, temos a mensagem que criamos manualmente no db!

Ao inserirmos qualquer valor no banco de dados, ele vai colocando no topico em latencia super baixa!

Para ter acesso todas as informaçoes acesse a documentaçao completa.

O apache connect não é uma ferramenta que permite alta complexidade, mas sim conectar uma coisa à outra!

## Persistindo dados no MongoDb
Da mesma forma, mongodb.properties
```properties
name=mongo-sink-from-mysql
connector.class=com.mongodb.kafka.connect.MongoSinkConnector
task.max=1
topics=mysql-server.fullcycle.categories
connection.uri=mongodb://root:root@mongodb/
database=fullcycle
transforms=extractValue
transforms.extractValue.type=org.apache.kafka.connect.transforms.ExtractField$Value
transforms.extractValue.field=after
```

Vamos conectar ao topico do historico do mysql-server ao banco de dados do mongo!


Vamos adicionar um novo conectoer no mongodb.

Nao importa de onde o dado esteja vindo. No caso do debezium, o dado já vem no formato de json. Nesse caso, precisamos colocar um converter e reforçar que os dados sao json

Para acessar o mongodb:
http://localhost:8085

E vemos que o banco de dados fullcycle já existe no Mongodb!
E ainda mais, temos uma coleçao (tabela) com os registros que inserimos no mysql!

A grande questão, é registrar apenas informação e nao metadados. 
O kafka connect tem o single message transformation.

Quando temos um conector, sao aplicadas SMTs para fazer modificaçaoes em tempo real antes de gravar os dados. 
Por isso, usamos o transforms ExtractValue e escolher quais dados vamos utilizar.


# Serviços gerenciados
## Confluent Cloud
Ambiente gratuito para começar instanciado nas Cloud Providers.
Em qualquer lugar que formos trabalhar com kafka gerenciado É ALGO BEM CARO!

Vamos criar um cluster básico sem nenhum custo
A propria confluent tem uma cli 

Alem disso, em Tools, ele fornece todaa a ConfigMap para acessar o kafka

Podemos ver os consumers e os topicos, o ksqldb consegue relacionamento entre as tabelas e verificar todos os detalhes que está acontecendo com o kafka.


## Kafka gerenciado na AWS
AMK. Amazon Managed Streaming for Kafka

Confluent >>> AWS.


## Encerramento