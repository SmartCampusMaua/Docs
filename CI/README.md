# Iniciando com CI

É o proesso de integrar modificaçoes do codebase de forma continua e automatizada, evitando assun erros humanos de verificação, garantindo mais agilidade e segurança no  processo de desenvolvimento de um sw;



Processos automatixados para validar mdificações. 

Alemde fazer a PR basica, temos que rodar os testes, verificar se nao tem nenhum bug de seguran~ca, o codelinter e executar diversas verificações. 

Se tivermos que fazer isso para cada PR ia ser algo insano pq a chance de o revisor erraré muito grande. 

Entao o CI vai fazer essas verificações de forma interiramente automatizada.

A todo o momento ele vai quere integrar o codigo novo com o codigo base e impedir que atrapalhe a nossa integração.

Osprincipais processos que normalmente sao importantes com CI:

Testar, verificar, testar integrações. Pegar o codigo que subiu, fazer os testes, e aprovar ou nao,

No caso de CI, eh muito comum nos realizarmos os testes da aplicação, lint, espaçamrnto, etc. Verificação de qualidade de coidigo.Muitos codigos de blocos repetdos que nao gostariamos de acumular para nao gerar uma grandequantidade de debitos tecncos na nossa alicação. Alem disso,  fazer algumas verificações de segurança. Imagina alguem ter colocado ali um token direto sem ter colocado em uma variavel de ambiente ou tem alguma coisa muito erradaque poderiamos fazer essa verificação e poderia passar aos olhos humanos. Entao podemos realizar processos dessa forma para nos ajudar.



Além disso, muitas vezes, queremos pegar esse processo de CI, gerar obuild e gerar os artefatos que vamos utilizar para colcoar issoemproduçao.

Entao vamos imaginar que vamosfazer o CI, testes,linter, segurançae etc e entao baseado nesse resultado vamos gerar um zip, subirem um servidor e quando aluem quiser colcar no ar, a gente pega esse zip e faz o processo de deploy.

As vezes na eh zip, mas o CI vai gerar uma imagem Docker eentaosubmims essaimagemno nosso COntainer Register. Entao quando subimos o nosso processo de CI temos a possibilidade de gerar artefatos para quenos ajude futuramente em um processo de deploy.

Outra coisa beminteressante e muito utilizada: a parte de bump version. Se estuvermos trabalhando com SemVer, e tb ocoventional commits, podemospegar um prgrama especifico para analisar tudo o que foi gerado nos commits dees pull request e baseado nisso ele vai gerar automaticamente uma tag, um release na hora em que subirmos. Fazendo o controle de vesao da aplicalçao de forma automatica simplesmente analisando os processos dos nossos commits e aplicando CCI

CI tem muita liberdade.

A criatividade e a necessidade 

Relizar testes de integração, end0to0end, coleçoes que testou em uma ai no Postman e etc.

#### Status Check

É a garantia de que uma PR nao poderá ser mergeada ao repositorio sem antes ter passadi oelo processo de CI ou mesmo no processo de Code Review.

Podemos falar ao status check se o processo de CI passou. Se ele nao passou, bloquemoas o processo de mergear a pR;

Assim, mesmo que nao estejamos trabalhando com code review, impedimos que outras pessoas posssam fazeer um merge da sua aplicação.

A mais popular é o Jenkins. Gratuito e muito bom! Quando tivermos mutos PRs e commits, vamos ter que clusterizar esse processo para que ele de conta de rodar os jobs em paralelo.

Aqui vamos ver a Github Actions. O diferencial é que ele se integra no github inteiro baseado em eventos. Ele nao eh apenas CI, mas trabalha num workflow de acordo com o que precisamos. 

Se quisermos rodar uma automação quando alguem criar uma nova issue, porexemplo, ou modificar issiu, ou fechar, o push, ou PR. Sao açoes que podemos capturar e ações que podemos executar e podemos pegar ações feitas de outros desenvolvedores e empretamos para podermos utilizar.



Independente da ferramenta que estamos utilizando, os conceitossao os mesmos mas apenas os arquivos ou padroes sao um pouco diferentes.



O GA é um automatizador de workflow de desenvolvimento de sw.

Ele utiliza os principais eventos gerados pelo Github pata==ra que ossamos executar tarefas dos mais variados tipos, incluidno processos de Ci.

DINAMICA:

WORKFLOW -> 

Sao conjuntos de processis definidos por nós. Ex fazer build + rodar os testes da aplicação

É possivel ter mas do que um workflow por repositorio

Definidos em arquivos yaml em .github/workflows.

Possui um ou mais jobs.

É iniciado em eventos do github o atraves de agendamentos.



EVENTO (on push) -> FILTROS (branches master) ->AMBIENTE (ubuntu)-> AÇOES (steps= uses: actions/run-compose; run: npm run prod)

No steps, temos uas opçoes. O uses é quando pegamos uma action do github (um codigo desenvolvido poralguem que podemoscolocarali dentro e elevai executar o codigo no padrao do gh actions. Iclusive temos um marketplace do gha que podemos olhar todas as actions que ja existem. Uma aplicação go, por exemplo, já possui um setup-go que organiza o ambiente ubuntu que para rodaro teste certinho para o que queremos fazer e issso que deica o gha muito poderoso, q afinal podemos compartilhar as action para facilitarmos as coisas.).Joa o comando run executa um comando na maquina ubuntu.



ACTON -> A acion é a ação que de fato será executada em um dos steps de um Job em um workflow . Ela pode ser criada do zero ou ser reutilizada de actions pre-existentes.

A acrion pode ser desenvolvida em:

Javascript

Docker Image

Em um repositorio publico, podemos usar essas actionsavontade.Porem pararepositoriosprivados existem planos 





#### cRIANDO sOFTWARE eXEMPLO

Programa - Test - Repo - Actions

O primeiro passo é criar um progranma de fazer uma conta de somar em go, por exemplo. E depois fazer um test e testar.

```bash
❯ go mod init rogeriocassares/github-actions
go: creating new go.mod: module rogeriocassares/github-actions
```



main.go

```go
package main

import "fmt"

func main() {
	fmt.Println(Soma(10, 10))
}

func Soma(a int, b int) int {
	return a + b
}

```



math_test.go

```bash
package main

import "testing"

func TestSoma(t *testing.T) {

	total := Soma(15, 15)

	if total != 30 {
		t.Errorf("Resultado da soma é invalido: Resultado %d, Esperado: %d", total, 30)
	}
}

```



#### Criando primeiro Workflow

Criar um repositorio no Guthub fullcycle-ci-go e inici a um repositorio git

```bash
git init
```

Vamos adionar ao stage utilizando o conventional commits plugin do vscode.

As vezes quando estamos trabalhando com mommits assinados pode demorar um pouquinho. 

Podemos resolver com o gpg-agent

```bash
gpgconf --launc gpg-agent
```



Agora vamos dar um push e configurar pela primeira vez:

```bash
rogerio in 3.CI on  master [!] 
❯ git branch -M main
git remote add origin https://github.com/rogeriocassares/fullcycle-ci-go.git
rogerio in 3.CI on  main [!] 
❯ git push -u origin main
Enumerating objects: 6, done.
Counting objects: 100% (6/6), done.
Delta compression using up to 4 threads
Compressing objects: 100% (5/5), done.
Writing objects: 100% (6/6), 4.18 KiB | 2.09 MiB/s, done.
Total 6 (delta 0), reused 0 (delta 0), pack-reused 0
To https://github.com/rogeriocassares/fullcycle-ci-go.git
 * [new branch]      main -> main
Branch 'main' set up to track remote branch 'main' from 'origin'.

```



Agora vamos criar o 1o workflow utilizando o GHA!



Criar arquivo .github/workflows/ci.yaml

```ỳaml
name: ci-golang-workflow
on: [push]
jobs: 
  check-application:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2 
      # Pega os dados que acabamos de subir e vai fazer download na maquina ubuntu.
      - uses: actions/setup-go@v2
      # Faz o setup do go
      # actions/setup é um repositório do github!
        with: 
          go-version: 1.15
      - run: go test
      - run: go run math.go
```



Agora vamos no controle de versao do github, adiconar o ci.yaml , conventional commits plugin ... etc. No proprio source control, podemos dar um push.

Se formos no github -> Action e podemos ver o que ele executou, rodou os testes o programa e depois completou o job!

Nesse ponto, as nossas actions funcionaram e está tudo ok!



#### Fazendo Github actions nao passar

Imaginemos u edesejamos fazer modificação na aplicação. Mudar de Soma para soma e fazer com que o teste nao passe pq o test está utilizando Soma.

Entao vamos dar um commit nesse arquivo.

Source Control - CObventional COmmit nova feature ... 



Vamos em Actions para verificar e olha só. Run go test nao passou!

O PROCESSO DE CI nao passsou pq nao achou a função soma!

Inclusive quando vamos ao codebase, vemos que o último commit nao passou!

Agora vamos fazer este teste passar atribuindo soma minuscula ao nome da função.

Source control - convential commit - push

Agora vimos que passou o go test e conseguiu rodar a nossa função!

SE O CODEIGO NAO PASSAR NO TESTES O GITHUB ACTION NAO PERMITE QUE SEJA DADO O PR PARA O REPOITORIO



#### Ativando status check

Vamos voltar nos padroes de criar um branch develop e PRs

No terminal:

```bash
rogerio in 3.CI on  main [!] 
❯ git checkout -b develop
Switched to a new branch 'develop'

```



E vamos subir um branch igualzinho ao main no github

```bash

rogerio in 3.CI on  develop [!] 
❯ git push origin develop
Total 0 (delta 0), reused 0 (delta 0), pack-reused 0
remote: 
remote: Create a pull request for 'develop' on GitHub by visiting:
remote:      https://github.com/rogeriocassares/fullcycle-ci-go/pull/new/develop
remote: 
To https://github.com/rogeriocassares/fullcycle-ci-go.git
 * [new branch]      develop -> develop
 
```



No github:

Settings, branches

Branch princiap para o develop

E entao vamos criar uma proteção para o branch develop

Add rules e exigir que tenhamos um require status check antes de dar um merge.

Vamos escolher o Job chamado check-application, que foi o nome do Job que criamos no arquivo yaml. Esse teste entao tem que paassar para pdermos dar um merge no nosso github!

E vamios obrigar que os branches estejam na ultima versao para que façam o status check. 

NInguem tb poode commitar diretamente, incluindo administradores ... 

Fazer essa mesma rule para o main

Agora, a regra é que tudo o que estiver em produção é o que etsá no branch main, nesse processo, só vai ser mergeado no develop. O develop é quem faz o merge para o main.

O processo de CI do develo e do main sao diferentes.

No develop, o CI vai apenas verificar se está tudo passando. 

No main, além de passar, ele vai fazer o deploy. E ninsso vai entrar o CD - COntinuos Deployment/Delivery.

Nesse caso, queremos que aconteça somente no branch develop pq as regras do branc em produção sao diferentes,



Entao vamos alterar lgumas coisas no ci.yaml. AO invés on push, on pull-request.

Outra parte para entender, é qual branch queremos filtrar.

Github docs tem diversos templates para os jobs

```yaml
name: ci-golang-workflow
on: 
  pull_request:
    branches:
      - develop
      # Todas as vezes que subirmos para o branch develop, queremos que algo aconteça
jobs: 
  check-application:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2 
      - uses: actions/setup-go@v2
        with: 
          go-version: 1.15
      - run: go test
      - run: go run math.go
```



Adicionar , comnvential commits ... push

Entao, todas as v ezes que colocarmos no nosso repositorio e dermos um PR, o status check vai acontecer! E ai vai opassar e podermos dar o merge.



Deu erro ao fazer o push diretamente para a branch develop pq devemos fazer uma PR!!!

Vamos fazer um PR criando uma nova branch!

```bash
rogerio in 3.CI on  develop [!] 
❯ git checkout -b feature/ci
Switched to a new branch 'feature/ci'
rogerio in 3.CI on  feature/ci [!] 
❯ git push origin feature/ci
Enumerating objects: 13, done.
Counting objects: 100% (13/13), done.
Delta compression using up to 4 threads
Compressing objects: 100% (6/6), done.
Writing objects: 100% (8/8), 4.38 KiB | 4.38 MiB/s, done.
Total 8 (delta 3), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas:   0% (0/3remote: Resolving deltas:  33% (1/3remote: Resolving deltas:  66% (2/3remote: Resolving deltas: 100% (3/3remote: Resolving deltas: 100% (3/3), completed with 2 local objects.
remote: 
remote: Create a pull request for 'feature/ci' on GitHub by visiting:
remote:      https://github.com/rogeriocassares/fullcycle-ci-go/pull/new/feature/ci
remote: 
To https://github.com/rogeriocassares/fullcycle-ci-go.git
 * [new branch]      feature/ci -> feature/ci
```



Vamos no github e create PR com essa nova branch!

Agora quando criamos a PR ele vai começar a rodar os testes e nao consegumos nem mesmo fazer o merge sem que passe no test do workflow.

Funcionou!



Agora deletamos a branch do repositorio remoto, e no nosso terminal:

```bash
git checkout develop
git pull origin develop
git branch -d feature/ci
```



Pronto!



#### Trabalhando com Strategy Matrix

Vale muito apena o processo de realizar os testes em diversos ambientes ou mesmo com diversa versoes do mesmo ambiente/ mesma linguagem. Entao podemos criar uma estratégia e uma matriz de como queremos testar.

```yaml
name: ci-golang-workflow
on: 
  pull_request:
    branches:
      - develop
jobs: 
  check-application:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        go: ['1.14','1.15']
    steps:
      - uses: actions/checkout@v2 
      - uses: actions/setup-go@v2
        with: 
          go-version: ${{matrix.go}}
      - run: go test
      - run: go run math.go
```





E entao vamos criar uma nova branch, 

```bash
rogerio in 3.CI on  develop [!] 
❯ git checkout -b feature/github-matrix
Switched to a new branch 'feature/github-matrix'
rogerio in 3.CI on  feature/github-matrix [!] 
❯ git add .
```

E agora, vamos dar uma PR e ir para as asctions.

Entao os checks estao acontecendo em 2 jobs! Um na versao 1.14 e outro na 1.15

Como ele esta em uma matriz, ele vai testar os mesmos steps em ambientes diferentes!

Aparentemente, neste momento, o processo de PR está travado.

**check-application** *Expected* — *Waiting for status to be reported*

Na realidade, o teste nao foi completado pq nao foi mudado completamente o processo de ci.

Entao pdeomos forçar como amdin ou ajustar o branch para sofrer as modificaçẽos necessárias.



Ostatus checkin applicationnao existe mais. Pq mudamos o status check no ci.yaml

Por conta disso, vamos desabilitar no branch para resolver isso.



Sttings, brances, e selecionaras outros status e vamos fazer o merge!



### CI com Docker

Como subir nossa imagem para teste e CI com Docker!

Vamos criaro nosso Dockerfile!

E essa imagem vai ser utilizada como base para ser utilizada lá no GHA!

```Docker
FROM golang:latest

WORKDIR /app

COPY . .
RUN go build -o math

CMD ["./math"]
```



Docker build!

```bash
docker build -t test .
❯ docker run --rm test
20
```

Entao aqui temoso Dockerfile do nosso programa!

Agora vamos commitar esse arquivo e entao depois vamos fazer com que consigamos daro builddessa imagem para subir para o Docker Hub!

deletar o branch no github após o merge

No terminal:

```bash
git checkout develop
git pull origin develop
git branch -d feature/github-matrix
```



#### Gerando build da imagem via CI

```bash
git checkout -b feature/ci-docker
git add Dockerfile
```

Conv COmmit ...

Agora que já temos essaimagem colocada, vamos focar na parte do Ci.

Agora, queremos que se o test estiver tudo ok, gerar um build da nossa imagem!

```yaml
name: ci-golang-workflow
on: 
  pull_request:
    branches:
      - develop
      # Todas as vezes que subirmos para o branch develop, queremos que algo aconteça
jobs: 
  check-application:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2 
      - uses: actions/setup-go@v2
        with: 
          go-version: 1.15
      - run: go test
      - run: go run math.go
```



Existe uma action do github que se chama build and push Docker images!

https://github.com/marketplace/actions/build-and-push-docker-images

A action que fala sobre o qemu vai nos ajudar aconfigurar o amiente Docker na nossa máquina!

E a acrion buildx vai nos ajudar a geraro docker build para a nossa imagem!



https://github.com/docker/setup-buildx-action

Note que o QEMU vai nos ajudar a rodar o Docker em varias arquiteturas.

A primiera coisa eh copiar a parte do qemu e do buildx

O campo name é para colcoar um nome no step que estasendo executado.. Uma descrição do passo que ele esta dando no momento,que é executaro Docker na nossa Actione conseguir gerar o build para nós.

Vamos agora copiar e colar a parte do Build and Push!

Alguns pontosa serem levados em consiferação

Pq existe aqui o id docker?_build?

Pq quando colocamos Id, podemos pegar o resldado dessa action e utilizar como entrada de um outro step!

essa action vai fazer um build e depois vai dar um push no docerhub. Mas nao queremos que ele faça o push agora, apenas o build da imagem.

A tag vai ser o nome do repositorio e o nome da imagem

Nesse caso, temos 3 passos^Fazer o setup do docker para qle conseguir funcionar em diversas aquiteuras, configurar o buil e fazer o build para uma imagem com o nome determinado na tag nessa máquina local temporaria que temosdo github action.



Vamos subir!

```yaml
name: ci-golang-workflow
on:
  pull_request:
    branches:
      - develop
      # Todas as vezes que subirmos para o branch develop, queremos que algo aconteça
jobs:
  check-application:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-go@v2
        with:
          go-version: 1.15
      - run: go test
      - run: go run math.go

      - name: Set up QEMU
        uses: docker/setup-qemu-action@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
        
      - name: Build and push
        uses: docker/build-push-action@v3
        with:
          push: false
          tags: rogeriocassares/fullcycle-ci-go:latest

```

Entao:

```bash
git add ci.yaml
# Conventionalcommits 
git push origin feature/ci-docker

```

E pronto! O novo branch foi criado dentro do repositorio e apareceu para gerarmos o PR e vai começar a rodar os testes!

Vamos desablitar os checks com diversas opçoes para poder rodaro status check!

Conseguimos buildar o Docker dentro do nosso ambiente de CI COM A TAG!

Agora sim temos a certeza de que esta tudo funcionando aqui dentro pois conseguimos executar a aplicação Go, rodar os testes e gerar o Buil da imagem que vamos utilizar para enviar para produção!





#### Dando push na imagem automaticamente



Vamos subir essa imagem gerada no Docker Hub!

Precisamos utilizar uma action que faz o Login no Docker Hub!

Ao ives de usar o usuario e sanha, vamos utilizar o login e o nosso token!

NO arquivo yaml, antes de gerarmos o build and push, vamos usar a action de login!

Aqui temos algo importante.

O que seria secrets.DOCKERHUB_USERNAME?

Já pesnou se para cada vez que configurassemos o pipelineci tivessemos que expor o nosso usuário e token?Entao mantemos isso como segredo e o github  tem essa opção! Vamos adicionar esses dois SECRES com o valor que a gente quer!



No github, Secrets, New Secret!

secrets.DOCKERHUB_USERNAME e DOCKERHUB_TOKEN

COmo conseguimos esse dockerhub token?

Vamos logar no dockerhub, settings, security, New access Tokens.

Vamos copiar entao o token do docker hub e copiar para a a secret do Github!

```yaml
name: ci-golang-workflow
on:
  pull_request:
    branches:
      - develop
      # Todas as vezes que subirmos para o branch develop, queremos que algo aconteça
jobs:
  check-application:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-go@v2
        with:
          go-version: 1.15

      - run: go test
      - run: go run math.go

      - name: Set up QEMU
        uses: docker/setup-qemu-action@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Login to DockerHub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v3
        with:
          push: true
          tags: rogeriocassares/fullcycle-ci-go:latest

```



Vamos agora dar um gitadd no ci.yaml e etc.

```bash
❯ git push origin feature/ci-docker
```

O JOb vai começar a rodar e SIM! FUNCIONOU!!!

AGora vamos testar direto do terminal!!!



```bash
docker run --rm rogeriocassares/fullcycle-ci-go
```



Yes! Glorias a Deus! Funcionou!



## Sonarqube

### Iniciando com Sonarqube

SOnarqube faz a analise de todas as linhas do códgo e consegue verificar bugs de segurança, bugs normais ,debitostecnicos, o quanto decobertura o nosso codigo tem na partede testes e baseado numa serie de parametros u epodemos configurar, podemos configurar se passou ou nao passou em um teste de qualidade. 

sonarqube.org

O sonarqube tb tem uma versao nas nuvens para ser hospedado.

Vamos conhecero Sonarqube e integrarao nosso processo de CI para garatir que somentecodigo de qualidade entre no nosso repositorio.

Parte docs, try out sonarkube. 



Vamos rodar o sonarqube utilizando o docker!

https://docs.sonarqube.org/latest/setup/get-started-2-minutes/

[From the Docker image](https://docs.sonarqube.org/latest/setup/get-started-2-minutes/#)

Find the Community Edition Docker image on [Docker Hub](https://hub.docker.com/_/sonarqube/).

1. Start the server by running:

```console
$ docker run -d --name sonarqube -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true -p 9000:9000 sonarqube:latest
```

Once your instance is up and running, Log in to [http://localhost:9000](http://localhost:9000/) using System Administrator credentials:

- login: admin
- password: admin



COmoquefuncionamos principais conceitosdele? ISSO EH MUITO IMPORTNANTE CONFIGURAR, PARAMETRIZAR E CONFIGURAR COMO ESSAS FERRAMENTASFUNCIONAM!

usuariosenha: sonarqube



ESSEEH UM ABIENTE DE TESTE POR ENQUANTO! NAO RODAR COM ESSE DOCKER EM PRODUÇÃO DESSE JEITO.



#### Conceito principais

Podemos adicionar um projeto no sonarqube e teremos variaveis globais e locais para cada projeto

As rules determinam o que eh certo e o que eh errado em determinada linguagem de program

Por exemplo, na linguagem go, existem 44 regras que ele usa para trabalhar com Go. Elas sao definidas por cadegorias, codesmell (nao impedem de funcionar), CATEROGOTIAS QUE SAO BLOCKERS, ETC.

O Sonarqube, na verdae é um compliant para que possamos usar para cada libguagem para identificar niveis de qualidade de codigo. 



Entao temos regras de acordo com a linguagem e categorizadas por tipo de severidade e problemas que isso pode causar.

Ele traz o exemplos e ele traz o tipo de severidade  que o problema vai causa baseado no nivel de qulidade do codigo

Geralmente filtramos pela linguagem e pelo tipo, por exemplo, coisas que podem afetar na segurança do codigo

A partir dessas regras temos os Quality Profiles pela linguagem de prograação tb.

Por padrao, ele já tem um perfil criao por linguagem de programação. 



Por padrao, o sonaqube tem o Sonar Way em quality profiles.

Ele pega as regras qu criamos pela linguagem, cria um perfil e atacha esse perfil naquela linguagem



Por exemplo em sonarway js. Temos o recommended e o defaul. Quando formos rodar o nosso projeto, vamos rodar baseado nos nossos perfis e baseado nessas rules sabemos qual o tipo de problema que é.



O mais legal em relação a tudo isso é que podemos criar as coisas em relação a esse tipo apenas clicando no icone da engrenagem e dando um copy para o nome do nosso perfil.

Com esse perfil criado, conseguimos ver todas as regras que estao ativas e baseado nessas regras agora temos a opçao de conseguir ativar e dsativar esses caras. 

Vamos sempre lembrar. Temos o perfil, dentro do perfil temos regras. Podemos criar um perfil novo para nos e escolher as regras e a linguagem que queremos que esse perfil faça parte e se é default ou nao para cada linguagem.

Isso tudo é baseado de forma Global que estamos colocando.

E ENTAO A PARTIR DISSO CONSEGUIMOS ESCOLHER QUAL QUE EH O PROJETO QUE ESSE CARA TEM E DE QUEM ELE ESTA HERDANDO.



Por ultimo temos o quality gate. Basicamente é u portao de qualidade. Baseado nesse nivel de qualidade que definimos iremos falar se o proj esta passando ou nao dentro dos requisitos de qualidade. 

Entao temos as regras, temos o perfil de qualidade, e temos o gate de qualidade e baseado nesse gate falamos que esta passando ou nao.



O sonar way define se um projeto está passando ou nao no portao de qualidade. Nesse caso, ele exisge que, no minimo, tenha 80% de cobertura, nao ter mais de 2% de codigo duplicado, manutenção de codigo tem que ser A,  e etc.



Baseado nisso, conseguimos definir o que é qualidade. Mas dependendo do projeto, podemos mudar o nosso nivel de qualidade.

Podemos entao copiar esse gate de qualidade e baseado no nosso novo padrao podemos definir o nosso nivel de qualidade e definir quais prohjetos estao sujeitos a ter essa regra.



POrtanto, qualquer projeto que entrar, vao ser baseados ness novo Gate



3 coisas pricipais. Regras, Quality Profiles, Quality Gates.

#### Instalando o primeiro projeto

Vamos criar um prjeto bem simple com go

Agora, vamos adicionar manualmente um projeto no sonarqube.

Poject key/name go-project

Agora, para cada key desse projeto temos que ter um token que representa pq quado geramos as infos pro SQ pegar isso temos que saber de qual projeto estamos falando 

ANalyse locally - Token: go-project

**sqp_ef028b986ccb61ef69d7aa80c37f96024504039b**

Qual linguagem de progr estamos utilizando?

OS é com Linux

E para isso vamos ter que instalar o comando scanner. Vamos ter que ter o na nossa maquina ou na maquina de CI.

O SOnar scanner eh uma ferramenta que pega todas as info do proj e envia elas ao sonarqube

Por padrao, vamos criar o sonar-project.properties



ONde esta o codigo fonte, quais arquivos de testes ...

#### Execute the Scanner

Running a SonarQube analysis is straighforward. You just need to execute the following commands in your project's folder.



No terminal da aplicação go, vamos colar e dar um enter.

```bash
sonar-scanner \
  -Dsonar.projectKey=go-project \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=sqp_ef028b986ccb61ef69d7aa80c37f96024504039b
```



Ao executar estes comandos, ele cria uma pasta chamada .scannerwork e voltamos ao nosso dash do sonarqube e vimos que já temos um projeto rolando!

Agora, com o projeto temos um novo submenu.

Nesse projeto parece que está tudo ok. Mas deu 0% de cobertura pq nao fizemos nenhuma configuração para isso. 

Ele nao vai barrar tb.

Mesmo com as infos de cobertura de codigo com menos de 20 linhas ele tb nao vai barrar por causa do pouco numero de linhas. 

E qualquer mudança que fizermos, ele sempre vai cair nessa pagina e o mais interessante é quando tivermos um novo código, com o codigo novo, ele começa a acomparar um com o outro e começa a ver a evolução de bugs, de debitos técnicos conforme o tempo for passando. E conforme formos tendo problemas, clicamos em issues e podemos configurar por tipo de bug, vulnerabilidade, bloquei de quality gate pq eh algo muito grave, etc.



Quando clicamos em code podemos ver o codigo fonte do nosso projeto e baseao nesse arquivo podemos ver quantos bugs, quantas vulnerabilitadade tem para cada um. 

E conforme vamos analisando o código, ele vainos falando se os códigos possuem ou nao cobertura de código.  Ele marca o qu etem e o que naoi tem.



#### Trabalhando com cobertura de codigo

Como esta a nossa cobertura de testes em relação ao nosso codigo.

Percebemos que o sonarqube nao executa testes para fazer isso, mas pega a output dos nossos testes e baseado nessas outputs ele pega a informação para conseguir saber as portencetagens e vai nos falar a parte de quality gates etc.

Vamos criar um arquivo de testes em go:

sum_test.go

E vamos rodar o test

```bash
go test
```



Agora, para falar pro sonarqube, podemos gerar um aquivo de resultado do test coverage.out:

```bash
❯ go test -coverprofile=coverage.out
PASS
coverage: 50.0% of statements
ok      rogeriocassares/go-sonarscanner 0.002s
```



Aqui podemos perceber que deu 50 % de cobertura.

Agoram, vamos gerar um arquivo sonar-properties e alguns pontos impotntes:

Agora quando nos rodarmos o sonar-scanner nao precisamos colcoar aqueles montes de parameros!

Entao:

```bash
sonar-scanner
```

Toda vez que sobe as vezes o sonarqube demora um pouco para receber a info.

Em overall Code podemos ver que ja temos 50% de cobertura de codigo



Se vermos em code, sum.go, podemos ver o que está coberto por codigo ou nao.

POdemos verificar que, apesar de ter 50% de cobertura, pq possui poucas linhas de codigo. pq le nao vai bloquear

Vamos adiconar algumas linhas a mais apenas agora para ver se ele realmete bloqueia.

Fizemos uma modificação, e rodamos o o go test  sonar-scanner novamente

e vimos que a cobertura esta 20%



vamos rodar o sonar-scanner



E agora vimos que nao passou no quality gate!

E entao ele mostra ttb as partes que estao com cobertura de codigo!



Para todas as linguagem de pro existem formas de exportar os arquivos de cobertura e passarmos o arquivos de resultados.



#### Cobrindo codifo com js

Criamos uma pasta js e damos 

```bash
npm init

npm install jest @types/jest sonar-scanner --only-dev
```

em em package.json em test, vamos mudar o comando para "jest --coverage"

Criamos um arquivo sum.js e tb um sum.test.js e coloá-los dentro de uma pasta chamada src para nao mix com node_mods

vamos enato rodar o npm

```bash
❯ npm run test

> js@1.0.0 test
> jest --coverage

 PASS  src/sum.test.js
  ✓ add 1 + 2 to be equal3 (1 ms)

---------|---------|----------|---------|---------|-------------------
File     | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s 
---------|---------|----------|---------|---------|-------------------
...files |     100 |      100 |     100 |     100 |                   
 sum.js  |     100 |      100 |     100 |     100 |                   
---------|---------|----------|---------|---------|-------------------
Test Suites: 1 passed, 1 total
Tests:       1 passed, 1 total
Snapshots:   0 total
Time:        0.439 s, estimated 1 s
Ran all test suites.
```



E passou no teste!

E o mais legal é que ele gera uma pasta chamada coverage com o aruivo Icov.info que deve ser o enviado para o nsonarqube.



Vamos criar o sonar-projet.properties



e entao adicionar um proj no sonarqube

TOken

**sqp_97d9b7d2ded264cc125cc83837bc11d6abf87485**



```BASH
sonar-scanner
```



Vamos ver lá no painel web

e passou! com 100% de cobertura!

E os problemas que acontecerm podemos adicionar desenvolvedores criando usuários, falar qu e o bug está resolvido ... etc

Ele consegue trabalhar com multiplas linguagens ao mesmo tempo!



Ponto muito importante! Se formos em 

Project Setting, General Setting, podemos perceber em analusis scope, que podemos configurar tudo que confiuramos no .properties, mas é recomendável sempre termos o arquivo.



OUTRA COISA:

Em relaçao a parte de codigo, em quality gate, podemos incluisve configurar quais projetos fazem parte de cada quality gate por padrao.

Ao clicar em projetos, vamos ver todos os nossos projetos, se passou nao passou, aprovado ou nao e etc!



#### Preparando para o ambiente SonarCloud

Poemos fazer isso tb no nosso proproop server.

Entao vamos pegar o o codigo wque estamos tarbalhando e quando criarmos uma PR, vairodar o github action, vairodar os testes, e depois vai poassar pelo quality gate do sonar cloud. Se estiver tudo ok ele vai deixar fazer o merge!

A primeira coisa, vamos subir a aplicaão Go e criar um arquivo .gitignore para nao subir nada que está dentro da pasta .scannerwork

vamos iniciar o git na pasta go

```bash
git init
git status
```

No arquivo doe sonar- properties nao vamos mais precisar passar as linhas login pq iremos usar um serviço na nuvem!

Vamos criar um repositorio fullcycle-sonarcloud no git hub 

Vamos adicionar a orign

```bash
git add .

git commit -m 'feat: add some function'
git branch -M main

git remote add origin https://github.com/rogeriocassares/fullcycle-sonarcloud.git

git push origin main


git checkout -b develop
git push origin develop



```

Agora, vamos criar a nossa pasta no github para fazer o gitflow e depois fazer os detalhes do sonarcloud

criar pasta .github/workflows com o arquivo ci.yaml

```ỳaml
name: ci-sonarcloud
on:
  pull_request:
    branches:
      - develop

jobs:
  run-ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-go@v2
        with:
          go-version: 1.15
      - run: go test -coverprofile=coverage.out


      
```

Agora vamos verificar se o nosso ci está rodando. Para isso:



```bash
git checkout -b feature/ci
git add .
git commit -m 'ci: github actions'
git push origin feature/ci
```



Vamos no github e vemos que lá apareceu o compare e PR.

Vamos mandar isso selecionando o branch develop. E depois criamos as nossas regras em relação a proteção de branch etc.

fUNCIONOU!



Agora avamos configurar a develop como branch defaul e exigir:

Rquire status check to passs before merge

Requisere branchs to be updates

run-ci



Entao toda a PR antes de dar merge tem que passar no Run-ci de status check

Vamos restringir a admins e usuarios e salvar



Agora vamos fazer o processo p para rodar no sonarcloud. Esse processo pode rodar com ou sem CI. Entao vamos criar e depiois descobfigurar cada push para fazer isso com Ci



#### Executando SOnarCloud

sonarcloud.io

Vamos criar um novo projeto. Analyze new project

Criamos uma nova configuração para permitir esse repositorio ser lido pelo SOnarcloud.

Nesse caso, vamos selecionar que vamos trabalhar com github actions.





# nalyze with a GitHub Action

1

## Create a GitHub Secret

In your GitHub repository, go to [Settings > Secrets](https://github.com/rogeriocassares/fullcycle-sonarcloud/settings/secrets) and create a new secret with the following details:

1. In the Name field, enter `SONAR_TOKEN` 
2. In the Value field, enter `7e6ea7a9a656c24e642927813126181ede71b716` 

Continue



Entao vamos criar um SECRET do github CONFORME ELE NOS INDICOU

Vamos selecionar outra linguagens e vemos agora como devem,os grar o jobs





## Create or update a `.github/workflows/build.yml` file

#### What option best describes your build?

- Maven
- Gradle
- C, C++ or ObjC
- .NET
- Other (for JS, TS, Go, Python, PHP, ...)

Create or update your `.github/workflows/build.yml` 

Here is a base configuration to run a SonarCloud analysis on your master branch and Pull Requests. If you already have some GitHub Actions, you might want to just add some of these new steps to an existing one.

Copy

```
...        
      - name: SonarCloud Scan
        uses: SonarSource/sonarcloud-github-action@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}  # Needed to get PR information, if any
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```



Enato vamos subir para o github.

```bash
git add .
git commit -m 'ci? add sonarcloud'
git push origin feature/ci
```

Vamos ver se esta rodando no github actions e 



Nao deu certo pq temos que ajustar a projectKey a a organization ainda!



```properties
sonar.projectKey=rogeriocassares_fullcycle-sonarcloud
sonar.organization=rogeriocassares

sonar.sources=.
sonar.exclusions=**/*_test.go

sonar.tests=.
sonar.test.inclusions=**/*_test.go
# sonar.host.url=
# sonar.login=
sonar.go.coverage.reportPaths=coverage.out


```

Entao agora vamos subir novamente pro git e verificar as actions de PR

```bash
git add .
git commit -m 'ci: setup sonar-project.properties '
git push origin feature/ci
```

Imaginemos que o SoanrCloud vai gerir varias empresas. Entao isso permite que tenhamos projectkeys repetidos mas com organizations diferentes.



E foi!!!





Agora, com isso, quando formos no sonarcloud ja termemos em myproject as opções que precisamos! Enato vamos no sonarcloud, em projects



Está marcando aqui que 

"develop" branch has not been analyzed yet.

E depois vimos que falhou!

Nao deixou passar a PR pq nao temos cobertura de codigo o suficiente.

Isso significa que toda a estrutura que fizemos para os nossos testes TAMBEM esta sendo utilizada como base para a parte do quality gate quando temos a PR.





### **[sonarcloud](https://github.com/marketplace/sonarcloud) bot** commented [8 minutes ago](https://github.com/rogeriocassares/fullcycle-sonarcloud/pull/6#issuecomment-1184563243)

SonarCloud Quality Gate failed.  [![Quality Gate failed](https://camo.githubusercontent.com/4ea51c1f64ee3746f631653a02ab678ca6a3efb5f5cb474402faed2e3dcf90b5/68747470733a2f2f736f6e6172736f757263652e6769746875622e696f2f736f6e6172636c6f75642d6769746875622d7374617469632d7265736f75726365732f76322f636865636b732f5175616c6974794761746542616467652f6661696c65642d313670782e706e67)](https://sonarcloud.io/dashboard?id=rogeriocassares_fullcycle-sonarcloud&pullRequest=6)[![Bug](https://camo.githubusercontent.com/4c6102327f5a954f9c8acaf2e2714183157a9e41717b371b2cd585cf25057310/68747470733a2f2f736f6e6172736f757263652e6769746875622e696f2f736f6e6172636c6f75642d6769746875622d7374617469632d7265736f75726365732f76322f636f6d6d6f6e2f6275672d313670782e706e67)](https://sonarcloud.io/project/issues?id=rogeriocassares_fullcycle-sonarcloud&pullRequest=6&resolved=false&types=BUG) [![A](https://camo.githubusercontent.com/1cba125a897d7fa47033a3b3b2be2bbee680d34d4f004a215564659b853fb201/68747470733a2f2f736f6e6172736f757263652e6769746875622e696f2f736f6e6172636c6f75642d6769746875622d7374617469632d7265736f75726365732f76322f636865636b732f526174696e6742616467652f412d313670782e706e67)](https://sonarcloud.io/project/issues?id=rogeriocassares_fullcycle-sonarcloud&pullRequest=6&resolved=false&types=BUG) [0 Bugs](https://sonarcloud.io/project/issues?id=rogeriocassares_fullcycle-sonarcloud&pullRequest=6&resolved=false&types=BUG) [![Vulnerability](https://camo.githubusercontent.com/3ba1ee49636ffc3427e38649a9f8a65ee392f28e8a662fcf96ce24cefbb520e9/68747470733a2f2f736f6e6172736f757263652e6769746875622e696f2f736f6e6172636c6f75642d6769746875622d7374617469632d7265736f75726365732f76322f636f6d6d6f6e2f76756c6e65726162696c6974792d313670782e706e67)](https://sonarcloud.io/project/issues?id=rogeriocassares_fullcycle-sonarcloud&pullRequest=6&resolved=false&types=VULNERABILITY) [![A](https://camo.githubusercontent.com/1cba125a897d7fa47033a3b3b2be2bbee680d34d4f004a215564659b853fb201/68747470733a2f2f736f6e6172736f757263652e6769746875622e696f2f736f6e6172636c6f75642d6769746875622d7374617469632d7265736f75726365732f76322f636865636b732f526174696e6742616467652f412d313670782e706e67)](https://sonarcloud.io/project/issues?id=rogeriocassares_fullcycle-sonarcloud&pullRequest=6&resolved=false&types=VULNERABILITY) [0 Vulnerabilities](https://sonarcloud.io/project/issues?id=rogeriocassares_fullcycle-sonarcloud&pullRequest=6&resolved=false&types=VULNERABILITY) [![Security Hotspot](https://camo.githubusercontent.com/fb735cbe76f8d5e1679c76ce83b740ceb1eaf62de4f7bf88623dc9953261aff7/68747470733a2f2f736f6e6172736f757263652e6769746875622e696f2f736f6e6172636c6f75642d6769746875622d7374617469632d7265736f75726365732f76322f636f6d6d6f6e2f73656375726974795f686f7473706f742d313670782e706e67)](https://sonarcloud.io/project/security_hotspots?id=rogeriocassares_fullcycle-sonarcloud&pullRequest=6&resolved=false&types=SECURITY_HOTSPOT) [![A](https://camo.githubusercontent.com/1cba125a897d7fa47033a3b3b2be2bbee680d34d4f004a215564659b853fb201/68747470733a2f2f736f6e6172736f757263652e6769746875622e696f2f736f6e6172636c6f75642d6769746875622d7374617469632d7265736f75726365732f76322f636865636b732f526174696e6742616467652f412d313670782e706e67)](https://sonarcloud.io/project/security_hotspots?id=rogeriocassares_fullcycle-sonarcloud&pullRequest=6&resolved=false&types=SECURITY_HOTSPOT) [0 Security Hotspots](https://sonarcloud.io/project/security_hotspots?id=rogeriocassares_fullcycle-sonarcloud&pullRequest=6&resolved=false&types=SECURITY_HOTSPOT) [![Code Smell](https://camo.githubusercontent.com/8fe18b2dfb6f7d4e44582f281b29f617eb5ae07c248d2002ca586e91da219212/68747470733a2f2f736f6e6172736f757263652e6769746875622e696f2f736f6e6172636c6f75642d6769746875622d7374617469632d7265736f75726365732f76322f636f6d6d6f6e2f636f64655f736d656c6c2d313670782e706e67)](https://sonarcloud.io/project/issues?id=rogeriocassares_fullcycle-sonarcloud&pullRequest=6&resolved=false&types=CODE_SMELL) [![A](https://camo.githubusercontent.com/1cba125a897d7fa47033a3b3b2be2bbee680d34d4f004a215564659b853fb201/68747470733a2f2f736f6e6172736f757263652e6769746875622e696f2f736f6e6172636c6f75642d6769746875622d7374617469632d7265736f75726365732f76322f636865636b732f526174696e6742616467652f412d313670782e706e67)](https://sonarcloud.io/project/issues?id=rogeriocassares_fullcycle-sonarcloud&pullRequest=6&resolved=false&types=CODE_SMELL) [0 Code Smells](https://sonarcloud.io/project/issues?id=rogeriocassares_fullcycle-sonarcloud&pullRequest=6&resolved=false&types=CODE_SMELL)[![20.0%](https://camo.githubusercontent.com/3f04cff3eeef8477afe696ae55c570cbb6ed02f16152497c14251828329a3e91/68747470733a2f2f736f6e6172736f757263652e6769746875622e696f2f736f6e6172636c6f75642d6769746875622d7374617469632d7265736f75726365732f76322f636865636b732f436f76657261676543686172742f302d313670782e706e67)](https://sonarcloud.io/component_measures?id=rogeriocassares_fullcycle-sonarcloud&pullRequest=6&metric=new_coverage&view=list) [20.0% Coverage](https://sonarcloud.io/component_measures?id=rogeriocassares_fullcycle-sonarcloud&pullRequest=6&metric=new_coverage&view=list) [![0.0%](https://camo.githubusercontent.com/8047c63e1f9ed03f63001e1eadce4676bade3e0f83ec690a9c625287796248a6/68747470733a2f2f736f6e6172736f757263652e6769746875622e696f2f736f6e6172636c6f75642d6769746875622d7374617469632d7265736f75726365732f76322f636865636b732f4475706c69636174696f6e732f332d313670782e706e67)](https://sonarcloud.io/component_measures?id=rogeriocassares_fullcycle-sonarcloud&pullRequest=6&metric=new_duplicated_lines_density&view=list) [0.0% Duplication](https://sonarcloud.io/component_measures?id=rogeriocassares_fullcycle-sonarcloud&pullRequest=6&metric=new_duplicated_lines_density&view=list)



### Some checks were not successful

2 successful and 1 failing checks



[![@github-actions](https://avatars.githubusercontent.com/in/15368?s=40&v=4)](https://github.com/apps/github-actions)

**ci-sonarcloud / run-ci (pull_request)** Successful in 1m

Required[Details](https://github.com/rogeriocassares/fullcycle-sonarcloud/runs/7342682968?check_suite_focus=true)



[![@sonarcloud](https://avatars.githubusercontent.com/in/12526?s=40&v=4)](https://github.com/apps/sonarcloud)

**SonarCloud Code Analysis** Failing after 50s — Quality Gate failed

[Details](https://github.com/rogeriocassares/fullcycle-sonarcloud/pull/6/checks?check_run_id=7342713924)



[![@github-code-scanning](https://avatars.githubusercontent.com/in/57789?s=40&v=4)](https://github.com/apps/github-code-scanning)

**Code scanning results / SonarCloud** — No new or fixed alerts





E olha só! Nao passou! Agor aparece um bot do sonarcloud nos falando que a cobertura de testes está baixa e por isso nao deixza passar

Mas mesmo assim podemos dar o merge pq nao está cobnfiurado a parte de merge.



Vamos editar a rule de branch para colocar o status check no sonar cloud run analisys.

Agora ele nao permite mais que possamos dar o merge pq nao esta passando.



Entao vamos comentar os codigos que nao possuem testes em go e fazer um novo commit.



```bash
git add .
git commit -m 'ci: Check if quality gate is working on sonar cloud'
git push origin feature/ci
```





E os testes vao começar a rodar novamente para rodar o processo da PR. Podemos ver isso em Actions



Vamos clarear algumas coisas aqui. 

Embora tenha sido aprovado no Actions o processo que foi reprovado pelo SOnarCloud, o processo de analise do SonnarCloud é ssincrono e a resposta nao eh na hora. Entao esse passar é, na verdade, enviar para o sonarcloud e o bot do sonarcloud instalado no github vai nos dizer se esse processo vai passar ou nao.



Se formos analisar a PR, ela fala que ainda estamos com 50% de cobertura e por isso ainda nao passou.

podemos verificar isso no sonarcloud tb!



Para isso, podemos fazer a config na parte de qualitygate e criamos a nossa caso queiramos que possamos mudaros pontos de cobertura. 





eNTAO AGORA VEMOS COMO PODEMOS trabalhar e nao vai entrar codigo ruim no nosso repositorio.

Inclusive, podemos fazer push com Docker e um montao de coisas com CI!



#### Trocando de Quality Gate

O codigo nao passou por conta do quality gate

aADMIN -> qUALITY GATE -> E ETC

Principalemnte no sonarCLoud, nao criamos profiles e etc no projeto, ma criamos em nivel de organization.



Para isso, My Orgaization e lá veremos o menu conforme haviamos fisto no sonaqube. e entao em quality gates temos a opção de criar a nossa ou copiar uma existente.



Vamos copiar e colcoar Code Gate com QUality gate > 45% e atribuir isso ao projeto do full-cycle-sonarcloud.

E agora inso no nosso projeto em Quality gate, temos a opção de trocar aquela que fizemos anteriormente.

Provalemente, para refletir o novo código, ele deve rodar novamente e é isso que faremos.



Entao, vamos dar um enter para fazer qualquer alteação no nosso código e vamos subir novamente!

```bash
git add .
git commit -m 'ci: Check if quality gate is working on sonar cloud'
git push origin feature/ci
```



Agora o github está rodando os testes no actions,  enviar para o sonarcloud, 

Lembrando que agora etsamos rodadno com uma outra quality gate agora.



Passou! E entao agora podemos dar um merge apesar de 50% de cobertura pq o uality Gate passou!



Demos o merge, e deletamos a branch no github e no diretorio.

```bash

git pull origin developgit branch -d feature/ci
git pull origin develop
```

