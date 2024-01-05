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


## Partition Leadership


## Garantia de Entrega de mensagens


## Garantia de Entrega parte 2



## Produtor indepotente


## Consumers e Consumer Groups



# Conceitos Básicos na Prática