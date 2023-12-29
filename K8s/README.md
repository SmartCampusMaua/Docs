# K8S

## 1. Iniciando com k8s

O K8s é um gerenciador e um orquestrador de containers. Podemos pedir para o k8s orquestrar os nossos containeres docker e ter uma certa *peace of mind*.

O K8s é um produto *open-source* utilizado para automatizar a implantação, o dimensionamento e o gerenciamento de applicativos em container.

Alguns conceitos extremamente importantes:

O K8s veio do Google, do projeto interno chamado de Bord. A ideia principal era rodar processos e jobs em uma quantidade gigantesca de clusters e máquinas. A melhoria foi um outro gerenciador chamado de omega e evoluiu para o k8s. Por esse know-how, o GCP da google é muito estável na orquestração de containers.

O k8s é disponibilizado através de um conjunto de APIs. Tudo o que fazemos no k8s é, na verdade, uma chamada API através de endpoints que o server disponibiliza para o usuário. Na maioria das vezes, usamos o `kubectl` para comandar o k8s.

Quase tuuo no k8s é baseado em estados e, baseado no estado desse objeto, o k8s toma determinadas ações. Então, vamos imaginar que temos um `deployment`. Entenda que o `deployment` é um objeto que o k8s consegue configurar diversos containeres para nós.

Então esse `deployment` é um objeto que configuramos e mandamos esse objeto para o k8s. O k8s recebe esse objeto, lê todo esse objeto, e o provisiona para nós os containers que precisamos. Por isso, trabalhar com k8s, na verdade, é trabalhar com os sete diversos tipos de objetos que o k8s trabalha.

O mais interessante é que com o k8s conseguimos trabalhar com projetos declarativos mais ou menos como trabalhamos com o `compose` do docker. Conseguimos criar um arquivo `yaml`, passar todas as especificações e rodar uma vez. Ou seja, o objeto vai ser criado. Caso deseja-se alterar, modifica-se o arquivo, aplica-se o arquivo e as alterações serão realizadas.

O k8s trabalha em clusters. O cluster é um conjunto de máquinas que juntas tem um grande poder computacional para realizar diversos tipos de tarefas.

No caso do k8s, vamos ter um nó que chamamos de `master`. E esse `master` é quem vai controlar todo o processo que os outros nós vão fazer. 

Então, pensando nesses nós, o master vai ter alguns serviços que o k8s disponibiliza.

Eles sao `api server`, o `controlle manager`, e o `scheduller`.

Tudo isso é em relação ao `master`.

Já o node que não é `master` possuem o `kubelet` e o `kubeproxy`. Então eles fazem a comunicação com o `master` para receber os comandos e como eles vao conseguir fazer os acessos entre um nó e outro através dos proxys.

Cada máquina possui uma quantidade de vCPU e memória. Cada máquina é conhecida como um `Node`. 

No fim, o k8s soma todos esses recuros e ele sabe o quanto ele tem de espaço para provisionar os recusros para os serviços que ele vai rodar para a gente.

Os `pods` são unidades que contem os containers provisionados. O `Pod` representa os processos rodando no cluster.

Toda vez que vemos um `pod`, tem um container. Geralmente um `pod` para cada container que está rodando a nossa aplicação.

`Deployment` é um outro tipo de objeto que tem o objetivo de provisonar os `pods`, mas para provisionar, precisa saber quantas réplicas de cada `pod` ele vai provisionar. Isto é dado através de um `ReplicaSet`, que é onde falamos quantas replicas vamos querer de cada set de `pods`.

Se um `pod` de uma `replicaset` cair, o k8s vai reiniciar sozinho.

Os `pods` vao ocupar uma máquina de acordo com os recursos e os `replicasets` disponíveis. Caso não exista recurso disponível para os `RS`, ele vai ficar pendente até que esse recurso possa ser novamente disponibilizado.


### 2. Instalando o k3d

O k3d é uma ferramenta que instancia um ambiente de cluster k8s na máquina local e o gerencia.

Ele instala o k8s rodando containers docker. Cada container será como uma máquina no cluster.

O k3d trabalha com o `kubectl`, que pode ser baixado através do `apt get` ou através de um binario.


### 3. Criando primeiro cluster com k3d

O k3d pode ser instalado a partir do script a seguir:
```bash
❯ wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash 
```

Para criar o cluster k3d:
```bash
❯ k3d cluster create fullcycle
--------               
INFO[0000] Prep: Network
INFO[0000] Created network 'k3d-fullcycle'
INFO[0000] Created image volume k3d-fullcycle-images
INFO[0000] Starting new tools node...
INFO[0000] Starting Node 'k3d-fullcycle-tools'
INFO[0001] Creating node 'k3d-fullcycle-server-0'
INFO[0001] Creating LoadBalancer 'k3d-fullcycle-serverlb'
INFO[0001] Using the k3d-tools node to gather environment information
INFO[0001] Starting new tools node...
INFO[0001] Starting Node 'k3d-fullcycle-tools'
INFO[0002] Starting cluster 'fullcycle'
INFO[0002] Starting servers...
INFO[0002] Starting Node 'k3d-fullcycle-server-0'
INFO[0006] All agents already running.
INFO[0006] Starting helpers...
INFO[0006] Starting Node 'k3d-fullcycle-serverlb'
INFO[0013] Injecting records for hostAliases (incl. host.k3d.internal) and for 3 network members into CoreDNS configmap...
INFO[0015] Cluster 'fullcycle' created successfully!
INFO[0015] You can now use it like this:
kubectl cluster-info
```

Quando se trabalha com k8s, o `kubectl` é um client para comunicação com o cluster.

Nesse ínterim, para o kubectl se comunicar com o cluster existe um arquivo em uma pasta chamada `~/.kube` e dentro do arquivo `config` devem estar todas as credencias para o acesso ao cluster. O mais interessante de tudo é que nesse config pode ter a configuração de contexto para a conexão com diversos clusters.

Com isso, pode-se ter um cluster em cada nuvem como Digital Ocean, AWS, Azure, GCP. Para isso, basta modificar o contexto,  isto é, em qual cluster o kubectl deve se conectar.

Para fazer o `kubectl` obter o contexto do cluster `k3d-fullcycle` é necessário executar o comando abaixo:
```bash
❯ kubectl cluster-info --context k3d-fullcycle
--------
Kubernetes control plane is running at https://0.0.0.0:57862
CoreDNS is running at https://0.0.0.0:57862/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
Metrics-server is running at https://0.0.0.0:57862/api/v1/namespaces/kube-system/services/https:metrics-server:https/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

Nesse momento, o nó `k8s control-plane` está rodando no endereço https://127.0.0.1:57862 e o `kubedns` em https://127.0.0.1:57862/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy. Isso significa que o cluster k8s está rodando com apenas um nó e o `kubectl` apontando para esse cluster.

Para saber se está tudo certo, a primeira coisa é verificar se o `docker` está rodando um container `k3d`:
```bash
❯ docker ps
CONTAINER ID   IMAGE                              COMMAND                  CREATED         STATUS                          PORTS                                     NAMES
26ec86fbf5fc   ghcr.io/k3d-io/k3d-tools:5.5.1     "/app/k3d-tools noop"    5 minutes ago   Up 5 minutes                                                              k3d-fullcycle-tools
23c4afe78797   ghcr.io/k3d-io/k3d-proxy:5.5.1     "/bin/sh -c nginx-pr…"   5 minutes ago   Up 5 minutes                    80/tcp, 0.0.0.0:57862->6443/tcp           k3d-fullcycle-serverlb
296afaae1069   rancher/k3s:v1.26.4-k3s1           "/bin/k3d-entrypoint…"   5 minutes ago   Up 5 minutes                                                              k3d-fullcycle-server-0
```

Como pode ser visto acima, o k3d funcionando no docker! Mas a melhor forma de verificar nesse momento é com o `kubectl`.
```bash
❯ kubectl get nodes
NAME                     STATUS   ROLES                  AGE     VERSION
k3d-fullcycle-server-0   Ready    control-plane,master   6m50s   v1.26.4+k3s1
```

O comando acima demonstra-se muito interessante, pois vai nos trazer todos os nós do cluster k8s. Além disso, informa se os nós estão `Ready` e pronto para serem utilizados. Isso é um ponto extremamente importante!

### Criando cluster multi-node

Para criar um cluster multi-node é necessário executar o mesmo processo que até o momento e adicionar um novo node.

Para listar todos os clusters k3d:
```bash
k3d cluster list
--------
NAME               SERVERS   AGENTS   LOADBALANCER
fullcycle          1/1       0/0      true
```

Nota-se apenas um cluster chamado `fullcycle`, criado com o comando `k3d cluster create fullcycle`.

Para deletá-lo: 
```bash
k3d cluster delete fullcycle
INFO[0000] Deleting cluster 'fullcycle'
INFO[0000] Deleting cluster network 'k3d-fullcycle'
INFO[0000] Deleting 1 attached volumes...
INFO[0000] Removing cluster details from default kubeconfig...
INFO[0000] Removing standalone kubeconfig file (if there is one)...
INFO[0000] Successfully deleted cluster fullcycle!
```

Listando novamente para validar a exclusão do cluster:
```bash
❯ k3d cluster list
NAME   SERVERS   AGENTS   LOADBALANCER
```

Para adicionar mais nós no cluster, pode-se definir um arquivo de configuração `.yaml` de como ele será criado:
```bash
nano k3d.yaml
```

```yaml
apiVersion: k3d.io/v1alpha5
kind: Simple
metadata:
  name: fullcycle
servers: 1
agents: 3
```

E então criar o novo cluster:
````bash
❯ k3d cluster create --config ./k3d.yaml
INFO[0000] Using config file ./k3d.yaml (k3d.io/v1alpha5#simple) 
INFO[0000] Prep: Network                                
INFO[0000] Created network 'k3d-fullcycle'              
INFO[0000] Created image volume k3d-fullcycle-images    
INFO[0000] Starting new tools node...                   
INFO[0000] Starting Node 'k3d-fullcycle-tools'          
INFO[0001] Creating node 'k3d-fullcycle-server-0'       
INFO[0001] Creating node 'k3d-fullcycle-agent-0'        
INFO[0001] Creating node 'k3d-fullcycle-agent-1'        
INFO[0001] Creating node 'k3d-fullcycle-agent-2'        
INFO[0001] Creating LoadBalancer 'k3d-fullcycle-serverlb' 
INFO[0001] Using the k3d-tools node to gather environment information 
INFO[0001] Starting new tools node...                   
INFO[0001] Starting Node 'k3d-fullcycle-tools'          
INFO[0002] Starting cluster 'fullcycle'                 
INFO[0002] Starting servers...                          
INFO[0002] Starting Node 'k3d-fullcycle-server-0'       
INFO[0006] Starting agents...                           
INFO[0006] Starting Node 'k3d-fullcycle-agent-2'        
INFO[0006] Starting Node 'k3d-fullcycle-agent-1'        
INFO[0006] Starting Node 'k3d-fullcycle-agent-0'        
INFO[0011] Starting helpers...                          
INFO[0011] Starting Node 'k3d-fullcycle-serverlb'       
INFO[0017] Injecting records for hostAliases (incl. host.k3d.internal) and for 6 network members into CoreDNS configmap... 
INFO[0019] Cluster 'fullcycle' created successfully!    
INFO[0019] You can now use it like this:                
kubectl cluster-info
````

Para verificar as informações do novo cluster
```bash
❯ kubectl cluster-info
----
Kubernetes control plane is running at https://0.0.0.0:59331
CoreDNS is running at https://0.0.0.0:59331/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
Metrics-server is running at https://0.0.0.0:59331/api/v1/namespaces/kube-system/services/https:metrics-server:https/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

Para verificar os 4 containers rodando:
```bash
❯ docker ps
----
CONTAINER ID   IMAGE                              COMMAND                  CREATED              STATUS                          PORTS                                     NAMES
46efcfcdae2c   ghcr.io/k3d-io/k3d-tools:5.5.1     "/app/k3d-tools noop"    About a minute ago   Up About a minute                                                         k3d-fullcycle-tools
a8b3b4267031   ghcr.io/k3d-io/k3d-proxy:5.5.1     "/bin/sh -c nginx-pr…"   About a minute ago   Up About a minute               80/tcp, 0.0.0.0:59331->6443/tcp           k3d-fullcycle-serverlb
500e145ba37a   rancher/k3s:v1.26.4-k3s1           "/bin/k3d-entrypoint…"   About a minute ago   Up About a minute                                                         k3d-fullcycle-agent-2
59569eb565c3   rancher/k3s:v1.26.4-k3s1           "/bin/k3d-entrypoint…"   About a minute ago   Up About a minute                                                         k3d-fullcycle-agent-1
20ddadc4ef74   rancher/k3s:v1.26.4-k3s1           "/bin/k3d-entrypoint…"   About a minute ago   Up About a minute                                                         k3d-fullcycle-agent-0
fbef1707cefb   rancher/k3s:v1.26.4-k3s1           "/bin/k3d-entrypoint…"   About a minute ago   Up About a minute                                                         k3d-fullcycle-server-0
```

E então verificar os nós:
```bash
❯ kubectl get nodes
NAME                     STATUS   ROLES                  AGE     VERSION
k3d-fullcycle-server-0   Ready    control-plane,master   2m39s   v1.26.4+k3s1
k3d-fullcycle-agent-2    Ready    <none>                 2m35s   v1.26.4+k3s1
k3d-fullcycle-agent-0    Ready    <none>                 2m35s   v1.26.4+k3s1
k3d-fullcycle-agent-1    Ready    <none>                 2m35s   v1.26.4+k3s1
```

Com isso, verifica-se que existem 4 nós rodando no cluster `k3d-fullcycle`, todos `Ready`, sendo um deles o `control-plane,master`.


### Mudança de contexto e a extensão do VSCode

Eventualmente pode-se ter diversos clusters em uma mesma máquina e isso pode ser um pouco complexo para saber quais estão disponíveis ou qual o contexto deve ser utilizado mesmo que essas configurações estajam no `kubeconfig` e, para isso, existem algumas ferramentas que podem ajudar.

Com o `kubectl`, há uma opção chamada de `config`.
```bash
❯ kubectl config
--------
Modify kubeconfig files using subcommands like "kubectl config set current-context my-context"

 The loading order follows these rules:

  1.  If the --kubeconfig flag is set, then only that file is loaded. The flag may only be set once and no merging takes
place.
  2.  If $KUBECONFIG environment variable is set, then it is used as a list of paths (normal path delimiting rules for
your system). These paths are merged. When a value is modified, it is modified in the file that defines the stanza. When
a value is created, it is created in the first file that exists. If no files in the chain exist, then it creates the
last file in the list.
  3.  Otherwise, ${HOME}/.kube/config is used and no merging takes place.

Available Commands:
  current-context   Display the current-context
  delete-cluster    Delete the specified cluster from the kubeconfig
  delete-context    Delete the specified context from the kubeconfig
  delete-user       Delete the specified user from the kubeconfig
  get-clusters      Display clusters defined in the kubeconfig
  get-contexts      Describe one or many contexts
  get-users         Display users defined in the kubeconfig
  rename-context    Rename a context from the kubeconfig file
  set               Set an individual value in a kubeconfig file
  set-cluster       Set a cluster entry in kubeconfig
  set-context       Set a context entry in kubeconfig
  set-credentials   Set a user entry in kubeconfig
  unset             Unset an individual value in a kubeconfig file
  use-context       Set the current-context in a kubeconfig file
  view              Display merged kubeconfig settings or a specified kubeconfig file

Usage:
  kubectl config SUBCOMMAND [options]

Use "kubectl <command> --help" for more information about a given command.
Use "kubectl options" for a list of global command-line options (applies to all commands).
```

A partir do `config`, podem ser listados todos os arquivos de configuração de contexto dos clusteres:
```bash
❯ kubectl config get-clusters
NAME
k3d-fullcycle
```

Nesse cado, tem-se 1 cluster configurado no `kubeconfig`. Mas o contexto do `kubectl` poderia ser alterado para qualquer um dos clusters que aparecerem na lista. E então com o comando de `kubectl get nodes` é possível identificar como que está o cluster.
```bash
❯ kubectl get nodes
--------
NAME                     STATUS   ROLES                  AGE     VERSION
k3d-fullcycle-server-0   Ready    control-plane,master   8m2s    v1.26.4+k3s1
k3d-fullcycle-agent-2    Ready    <none>                 7m58s   v1.26.4+k3s1
k3d-fullcycle-agent-1    Ready    <none>                 7m58s   v1.26.4+k3s1
k3d-fullcycle-agent-0    Ready    <none>                 7m58s   v1.26.4+k3s1
```

Com esses comandos, é possível listar os clusters e de qual cluster será utilizado o contexto com o que `kubectl` deve trabalhar.

Pode não ser tão prático fazer isso todas as vezes e utilizando a extensão `Kubernetes` do `VSCode` torna-se mais interativo. Essa extensão evidencia quais são os clusters no momento  e quais estão ativos ao contexto do `kubectl`.

Para navegar entre os contextos, basta clicar com o botão direito do mouse e escolher a opçãp `Set to current cluster`. ISSO É REALMENTE BEM PRÁTICO! E ENTAO AS CONFIGURAÇÕES DOS CLUSTERS ESTARÃO DISPONÍVEIS PARA ADMINISTRAR. 


## Primeiros passos na pratica

### Criando aplicação exemplo e imagem

Para criar uma aplicação muito básica em `golang` e obter um serviço para instanciar no cluster, deve ser gerado um `Dockerfile` (uma imagem com o arquivo `server.go`):

server.go:
```go

```

Dockerfile:
```Dockerfile
FROM golang:1.15
COPY server.go .
RUN go build -o server .
CMD ["./server"]
```

Para gerar a imagem `rogeriocassares/hello-go` com o `Dockerfile`:
```bash
docker build -t rogeriocassares/hello-go .
```

Para executar a imagem na porta `80` utilizando Docker:
```bash
docker run --rm -p 80:8080 rogeriocassares/hello-go
```

Para verificar o funcionamento no navegador, basta acessar o endereço http://localhost:80

E então fazer um `push` para o registry do Docker Hub:
```bash
docker push rogeriocassares/hello-go
```

Pronto! Agora uma imagem Docker esyá disponível para colocá-la para funcionar no k8s!


### Trabalhando com Pods!

O `Pod` é o menor objeto do k8s. Dentro do `Pod` tem-se, na grande maioria das vezes, apenas um container rodando. O `Pod` é como uma máquina que tem um IP contém apenas um container rodando dentro dessa máquina.

Para criar um instâncias usando o k8s, é recomendável utilizar aqruivos `.yaml`.

O k8s tem uma API e toda vez que qualquer coisa é feita no k8s, é através dessa API e o próprio cluster gerencia os agendamentos das tarefas, denominados de *Schedulers*.

Eventualmemte, cada tipo de arquivo de configuração pode ter uma versão diferente dessa API.

Nesses arquivos, a `label` é uma etiqueta que auxilia a fazer filtros, buscas e criar regras, por exemplo.

Se for necessário criar um `Pod` e filtr;a-lo pela `label` *app go server* pode ser feito através da configuraçãp abaixo:

k8s/pod.yaml:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: "goserver"
  labels:
    app: "goserver"
spec:
  containers:
    - name: "goserver"
      image: "rogeriocassares/hello-go:latest"
```

Para instanciar um `Pod`, basta aplicar o seu arquivo de configuração: 
```bash
❯ kubectl apply -f k8s/pod.yaml 
pod/goserver created
```

E então, verificar o `STATUS`  com o comando `kubectl get pod` ou `kubectl get po`:
```bash
❯ kubectl get po
--------
NAME       READY   STATUS    RESTARTS   AGE
goserver   1/1     Running   0          17h
```

Como pode ser visto, apesar de o `Pod` estar rodando no k8s, ainda não foi criado nenhum mecanismo de rede para acessar esse container dentro do `Pod`.

Para isso, é possível executar um comando de port-forward para que a porta do `Pod` esteja disponível no endereço http://localhost:8000 :
```bash
❯ kubectl port-forward pod/goserver 8000:8080
```

Executar um redirecionamento de porta é uma maneira apenas para verificar se o `Pod` está funcionando, mesmo que não tenha sido criada nenhuma regra nem configuração.

Nota-se que, provavelemnte a porta 80 é necessário de uma permissap *sudo*.

Para deletar o `Pod`, basta o comando:
```bash
❯ kubectl delete pod goserver
pod "goserver" deleted
```

E vê-se que não há mais nenhum `Pod`:
```bash
❯ kubectl get po             
No resources found in default namespace.
```

Logo, apagando o `Pod`, ele não está sendo criado novamente. É muito arriscado criar apenas um `Pod` e deixá-lo rodando pois ele não vai reiniciar automaticamente.


### Criando o primeiro ReplicaSet

A grande vantagem do k8s é gerenciar e garantir a disponibilidade e criar vários `Pods` para escalar a aplicação. QUanto mais `Pods`, mais divido o tráfego e, portanto, maior a robustez.

Para recriar `Pods` automaticamente, existe o `ReplicaSet` (`RS`). O `RS` é um objeto que gerencia os `Pods` com os seus containers. Pode-se falar quantas réplicas de um determinado `Pod` for necessário. Se em algum momento um `Pod` for removido ou cair, o `RS` recriará e manterá sempre o número do `RS` configurado:

k8s/replicaset.yaml
```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 3
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go"
```

Quando da necessidade de se colocar uma `label`, podem ser selecionadas somente as `labels` que tem certa `spec`. Então, a propriedade `selector` servirá para o filtro das `labels` para selecionar a aplicação e encaminahr o tráfego para eles através dos `services`.

Após a prioridade replicas, coloca-se o `Pod` que deseja-se criar como um `template`.

Para aplicar o arquivo de configuração do `RS`:
```bash
❯ kubectl apply -f k8s/replicaset.yaml 
replicaset.apps/goserver created
```

Para verificar os `Pods` criados pelo `RS`:
```bash
❯ kubectl get po
NAME             READY   STATUS              RESTARTS   AGE
goserver-fbgq7   0/1     ContainerCreating   0          36s
goserver-h7bpl   0/1     ContainerCreating   0          36s
goserver-a37af   0/1     ContainerCreating   0          36s
```

E ao se observar o nome do `RS`:
```bash
❯ kubectl get replicaset
NAME       DESIRED   CURRENT   READY   AGE
goserver   3         3         0       21h
```

Vê-se que o `RS` tem o nome de `goserver` e o `Pod` tem o nome `goserver-NOME_ALEATORIO_DO_POD`!

O `RS` não apenas cria, mas gerencia o `Pod`! 

Para testar, basta deletar um `Pod`:
```bash
❯ kubectl delete po goserver-fbgq7
--------
```
E verificar a quantidade de `Pods` no `RS`:
```bash
❯ kubectl get replicaset           
NAME       DESIRED   CURRENT   READY   AGE
goserver   3         2         0       21h
rogerio in FullCycle/3.0/4.K8s 
```

Ao aumentar ou diminuir o número de réplicas e aplicarmos novamente o `RS`, o número de `Pods` de cada `RS` são atualizados automaticamente!


### O problema do ReplicaSet

Se o código-fonte do arquivo `server.go` for modificado:

server.go v2
```go
package main

import (
	"net/http"
)

func main() {
	http.HandleFunc("/", Hello)
	http.ListenAndServe(":8080", nil)
}

func Hello(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("<h1>Hello Fullcycle!!!</h1>"))
}
```

E criada uma nova imagem docker, alterando a tag para `:v2`, por exemplo, `push` dessa nova versão para o Docker Hub:
````bash
❯ docker build -t rogeriocassares/hello-go:v2 .

❯ docker push rogeriocassares/hello-go:v2 
````

Alterar o arquivo `k8s/replicaset.yaml` vamos mudar de `latest` para `v2`:

k8s/replicaset.yaml
```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 3
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go:v2"
```

Aplicar o novo arquivo de configuração para a nova imagem:
```bash
❯ kubectl apply -f k8s/replicaset.yaml 
```

===
Descrevendo os `Pods`, observa-se que não houve mudança nos nomes dos `Pods`! Eles não foram trocados mesmo que o `RS` esteja com uma versão mais recente:
```bash
❯ kubectl describe po goserver-fbgq7

Containers:
  goserver:
    Image:        rogeriocassares/hello-go:latest
```

A partir daí, constata-se que a imagem é a `latest` ainda e nao é a `v2`! Portanto, esses `Pods` devem ser deletados:
```bash
❯ kubectl delete po goserver-fbgq7  
pod "goserver-fbgq7" deleted
```

Ao verificar os Pods, observa-se que novas instâncias estão subindo:
```bash
❯ kubectl get po
NAME             READY   STATUS    RESTARTS   AGE
goserver-dj8gr   0/1     Pending   0          12m
goserver-bv28s   0/1     Pending   0          12m
goserver-jgjh7   0/1     Pending   0          12m
```

Ao descrever um dos novos `Pods` criados, é possível observar que estão sendo criados agora com a nova imagem `v2`!
```bash
❯ kubectl describe po goserver-rcg4z 

Containers:
  goserver:
    Image:        rogeriocassares/hello-go:v2
```

Assim, conclui-se que a única forma de subir uma nova versão da imagem dos `Pods` em um `RS` é matando cada um dos `Pods` para o `RS` gerar cada um dos `Pods` com as novas versoes!

Isto é, o `RS` não altera a versão dos `Pods` automaticamente ao menos que os `Pods` sejam deletados. Para que isso ocorra, deve ser utilizado o `Deployment`!

NOTA: CASO OS `PODS` NAO SAIAM DO STATUS `PENDING`, PODE ESTAR TENDO ALGUM TIPO DE CONFLITO.

Para o teste do Deployment, é interessante realizar a remoção de todos os testes prévios como imagens e containers e o cluster k3d-fullcycle, deixando tudo zerado.
```bash
❯ kubectl config delete-cluster k3d-fullcycle
deleted cluster k3d-fullcycle from /home/rogerio/.kube/config
```
```bash
❯ kubectl config get-clusters                 
NAME
```
Remover todos os containers:
```bash
❯ docker rm $(docker ps -a -q) -f
```

Remover todas as imagens:
```bash
❯ docker rmi $(docker images -q) -f
```

Limpar o restante das imagens do Docker:
```bash
❯ sudo docker system prune -af
```
Limpar todos os Volumes do Docker:
```bash
❯ sudo docker volume prune -f
```

Verificar a inexistência de imagens do Docker:
```bash
❯ docker image ls -a
REPOSITORY   TAG       IMAGE ID   CREATED   SIZE
```

Criar novamente um cluster utilizando um ambiente Docker do zero:
```bash
❯ k3d cluster create fullcycle
INFO[0000] Prep: Network                                
INFO[0000] Created network 'k3d-fullcycle'              
INFO[0000] Created image volume k3d-fullcycle-images    
INFO[0000] Starting new tools node...                   
INFO[0001] Pulling image 'ghcr.io/k3d-io/k3d-tools:5.4.4' 
INFO[0001] Creating node 'k3d-fullcycle-server-0'       
INFO[0006] Pulling image 'docker.io/rancher/k3s:v1.23.8-k3s1' 
INFO[0012] Starting Node 'k3d-fullcycle-tools'          
INFO[0090] Creating LoadBalancer 'k3d-fullcycle-serverlb' 
INFO[0091] Pulling image 'ghcr.io/k3d-io/k3d-proxy:5.4.4' 
INFO[0107] Using the k3d-tools node to gather environment information 
INFO[0107] HostIP: using network gateway 192.168.96.1 address 
INFO[0107] Starting cluster 'fullcycle'                 
INFO[0107] Starting servers...                          
INFO[0107] Starting Node 'k3d-fullcycle-server-0'       
INFO[0112] All agents already running.                  
INFO[0112] Starting helpers...                          
INFO[0112] Starting Node 'k3d-fullcycle-serverlb'       
INFO[0119] Injecting records for hostAliases (incl. host.k3d.internal) and for 2 network members into CoreDNS configmap... 
INFO[0121] Cluster 'fullcycle' created successfully!    
INFO[0121] You can now use it like this:                
```

### Implementando Deployment

O `RS` tem alguns limites de criação de novos `Pods`. A partir disso, o k8s tem um objeto que resolve tudo isso e é denominado `deployment`

*Deployment -> ReplicaSet -> Pod*

O `Deployment` cria o `RS`, que gerencia os `Pods`.

Portanto, ao ser aplicada uma nova configuração no `Deployment`, um novo `RS` será gerado, matando todas as réplicas anteriores e subindo as novas replicas automaticamente.

Para criar o arquivo de `Deployment` pode-se duplicar a configuração do `RS`, mudando apenas o tipo (`kind`) para `Deployment` ao invés de `ReplicaSet`.

k8s/deployment.yaml:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 1
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go:v2"

```

Para testar, será alterado no arquivo de configuração acima de `rogeriocassares/hello-go:v2` para `rogeriocassares/hello-go:latest` e será aplicado o arquivo no cluster utilizando o `kubectl`:
```bash
❯ kubectl apply -f k8s/deployment.yaml 
deployment.apps/goserver created
```

Para verificar os nosvos `Pods`:
```bash
❯ kubectl get po
NAME                        READY   STATUS    RESTARTS   AGE
goserver-6675499669-jln2q   1/1     Running   0          52s
goserver-6675499669-swxbq   1/1     Running   0          8s
goserver-6675499669-r6hhb   1/1     Running   0          8s
```

E então é possível observar que o nome de dos `Pods` estão um pouco diferente: `goserver-6675499669-jln2q`.

Verificando o nome do `RS`:
```bash
❯ kubectl get replicaset
NAME                  DESIRED   CURRENT   READY   AGE
goserver-6675499669   10        10        10      2m52s
```

Fica claro que: `NOME_DO_DEPLOYMENT-NOME_DA_RS-NOME_DO_POD`, isto é, o `Deployment` gerencia o `RS`, que gerencia o `Pod`!

Alterando novamente de `latest` para `v2` com o `Deployment` e reaplicar o arquivo de configuração:
```bash
❯ kubectl get po                      
NAME                        READY   STATUS              RESTARTS   AGE
goserver-6675499669-t67j5   1/1     Running             0          5m15s
goserver-6675499669-mvfg7   1/1     Terminating         0          5m15s
goserver-54dd6d8758-hskhw   0/1     ContainerCreating   0          2s
```

Incrível! Novos `Pods` foram gerados com um novo `RS` e os antigos `Pods` e `RS` estão sendo removidos!

Dessa forma, por padrão, não há downtime porque ele vai criando os novos e terminando os antigos conforme eles vao subindo! Ao subirem os novos `Pods`, ele vai fazendo uma troca progressiva para não ficar nenhum tempo fora do ar! Ao final todos os novos Pods devem estar rodando:
```bash
❯ kubectl get po
NAME                        READY   STATUS    RESTARTS   AGE
goserver-54dd6d8758-5nw46   1/1     Running   0          3m
goserver-54dd6d8758-hskhw   1/1     Running   0          3m
goserver-54dd6d8758-6x7lz   1/1     Running   0          3m
```

Para descrever se realmente a nova imagem foi aplicada:
```bash
❯ kubectl describe pod goserver-54dd6d8758-5nw46
Name:         goserver-54dd6d8758-5nw46
Namespace:    default
Priority:     0
Node:         k3d-fullcycle-server-0/192.168.96.2
Start Time:   Thu, 21 Jul 2022 11:51:26 -0300
Labels:       app=goserver
              pod-template-hash=54dd6d8758
Annotations:  <none>
Status:       Running
IP:           10.42.0.22
IPs:
  IP:           10.42.0.22
Controlled By:  ReplicaSet/goserver-54dd6d8758
Containers:
  goserver:
    Container ID:   containerd://e58e8ea926d5f080578c3f1a2374963f47605f707c70f7572bb33ea3a166cbf5
    Image:          rogeriocassares/hello-go:v2
    Image ID:       docker.io/rogeriocassares/hello-go@sha256:2fdeab95d81a92603b44a7ee8e3236495db06b07606a4cd7abeddb8ad4030fb6
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Thu, 21 Jul 2022 11:51:29 -0300
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-9lh6g (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-9lh6g:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  3m55s  default-scheduler  Successfully assigned default/goserver-54dd6d8758-5nw46 to k3d-fullcycle-server-0
  Normal  Pulling    3m54s  kubelet            Pulling image "rogeriocassares/hello-go:v2"
  Normal  Pulled     3m53s  kubelet            Successfully pulled image "rogeriocassares/hello-go:v2" in 1.366639434s
  Normal  Created    3m53s  kubelet            Created container goserver
  Normal  Started    3m53s  kubelet            Started container goserver
```

Está! Portanto, para o dia-a-dia, não se trabalha com RS ou Pods diretamente, mas com Deployments, que gerenciam os RS!

Verificando-se os RS abaixo, observa-se duas instâncias. Um antigo (latest) e o outro mais atual (v2):
```bash
❯ kubectl get replicasets
NAME                  DESIRED   CURRENT   READY   AGE
goserver-6675499669   0         0         0       12m
goserver-54dd6d8758   10        10        10      6m25s
```

Aqui percebe-se que o k8s nao mata o `RS`, mas os mantêm! O que que vai acontecer é que ele nao vai utilizar o RS. Isso é extremamente importante!

Com isso, quando a versão da imagem é alterada, por exemplo, vai ser criado um novo `RS` e o antigo apenas nao vai ser utilizado.


### Rollout e Revisão

Caso uma aplicação esteja rodando e ela estiver com algum tipo de bug e for preciso voltar imendiatamente para a versao anterior, não seria viável ir ao arquivo de `deployment.yaml` e modificar o nome da imagem para aplicar novamente a imagem antiga. Na realidade, o k8s tem uma solução para isso.

Para obter a lista do histórico de tudo o que está acontecendo das versões:
```bash
❯ kubectl rollout history deployment goserver
deployment.apps/goserver 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
```

O `kubectl` trouxe para duas revisões. Uma é a `latest` e a outra é a `v2`.

Agora, como é possível voltar pra a versão anterior?

Verificando-se os nossos `Pods` atuais:
```bash
❯ kubectl get po 
NAME                        READY   STATUS    RESTARTS   AGE
goserver-54dd6d8758-5nw46   1/1     Running   0          32m
goserver-54dd6d8758-hskhw   1/1     Running   0          32m
goserver-54dd6d8758-6x7lz   1/1     Running   0          32m
```

E fazendo um rollout para fazer o *undo* do `Deployment`. Desta forma, ele vai voltar para a última versão do `RS`:
```bash
❯ kubectl rollout undo deployment goserver
--------
deployment.apps/goserver rolled back
```

Mas também é possível voltar para uma versão específica:
```bash
❯ kubectl rollout undo deployment goserver --to-revision=
```

Verificando os `Pods` observa-se que o k8s está terminando alguns pods e iniciando outros:
```bash
❯ kubectl get po
NAME                        READY   STATUS              RESTARTS   AGE
goserver-6675499669-tnb98   1/1     Running             0          8s
goserver-54dd6d8758-vls8d   1/1     Terminating         0          36m
goserver-6675499669-gznx7   0/1     Pending             0          4s
goserver-6675499669-x4lb8   0/1     ContainerCreating   0          5s
```

Até que tudo estejam iniciados e rodando:
```bash
❯ kubectl get po
NAME                        READY   STATUS    RESTARTS   AGE
goserver-6675499669-79zpk   1/1     Running   0          74s
goserver-6675499669-b2j5x   1/1     Running   0          74s
goserver-6675499669-tnb98   1/1     Running   0          74s
```
Para descrever ao menos um dos `Pods` e verificar qual a versão que está sendo utilizada:
```bash
❯ kubectl describe po goserver-6675499669-79zpk
Name:         goserver-6675499669-79zpk
Namespace:    default
Priority:     0
Node:         k3d-fullcycle-server-0/192.168.96.2
Start Time:   Thu, 21 Jul 2022 12:27:27 -0300
Labels:       app=goserver
              pod-template-hash=6675499669
Annotations:  <none>
Status:       Running
IP:           10.42.0.32
IPs:
  IP:           10.42.0.32
Controlled By:  ReplicaSet/goserver-6675499669
Containers:
  goserver:
    Container ID:   containerd://b289fa78c3fd8bfae213cfa0f1b4efd1f51ee37306128aab52e47c12ec3d9642
    Image:          rogeriocassares/hello-go:latest
    Image ID:       docker.io/rogeriocassares/hello-go@sha256:e3d0adf90eea6b94606c26c0c890f3c207b274ce70cc8eeb3fc66fc41247abb0
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Thu, 21 Jul 2022 12:27:29 -0300
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-9g8bh (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-9g8bh:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  2m14s  default-scheduler  Successfully assigned default/goserver-6675499669-79zpk to k3d-fullcycle-server-0
  Normal  Pulling    2m14s  kubelet            Pulling image "rogeriocassares/hello-go:latest"
  Normal  Pulled     2m13s  kubelet            Successfully pulled image "rogeriocassares/hello-go:latest" in 1.399799047s
  Normal  Created    2m13s  kubelet            Created container goserver
  Normal  Started    2m13s  kubelet            Started container goserver
```

Que incrível! Agora o k8s está utilizando a versão `latest` e não mais a `v2`. Ele realmente fez o rollout para o deploy anterior do `Deployment` `goserver`.

Verificando os `RS`:
```bash
❯ kubectl get replicasets
NAME                  DESIRED   CURRENT   READY   AGE
goserver-54dd6d8758   0         0         0       40m
goserver-6675499669   10        10        10      46m
```

De acordo com o comando acima, o `RS` anterior foi zerada e passou-se a utilizar o `RS` antigo mas nenhuma deles foi apagado!

Sobre o histórico, agora pode-se contemplar a revisão 2 e 3, sendo que a revisão é a versão rodando agora:
```bash
❯ kubectl rollout history deployment goserver 
deployment.apps/goserver 
REVISION  CHANGE-CAUSE
2         <none>
3         <none>
```

Se mudar explicitamente para a revisão 2:
```bash
❯ kubectl rollout undo deployment goserver --to-revision=2
deployment.apps/goserver rolled back
```

Observando os `RS`:
```bash
❯ kubectl get replicasets                                 
NAME                  DESIRED   CURRENT   READY   AGE
goserver-6675499669   3         3         3       50m
goserver-54dd6d8758   10        10        5       44m
```

E verificando os `Pods`:
```bash
❯ kubectl get po
NAME                        READY   STATUS    RESTARTS   AGE
goserver-54dd6d8758-kh86r   1/1     Running   0          68s
goserver-54dd6d8758-szhzj   1/1     Running   0          68s
goserver-54dd6d8758-fpbfx   1/1     Running   0          68s
```

Pronto! Os `Pods` dos `RS` antigos foram terminados e a imagem `v2` subiu novamente:
```bash
❯ kubectl describe po goserver-54dd6d8758-kh86r
Name:         goserver-54dd6d8758-kh86r
Namespace:    default
Priority:     0
Node:         k3d-fullcycle-server-0/192.168.96.2
Start Time:   Thu, 21 Jul 2022 12:35:36 -0300
Labels:       app=goserver
              pod-template-hash=54dd6d8758
Annotations:  <none>
Status:       Running
IP:           10.42.0.40
IPs:
  IP:           10.42.0.40
Controlled By:  ReplicaSet/goserver-54dd6d8758
Containers:
  goserver:
    Container ID:   containerd://9ed0cde08cc14d6134ee73d7195ad3298751c67b4a035552bfbbf597a5a912c0
    Image:          rogeriocassares/hello-go:v2
    Image ID:       docker.io/rogeriocassares/hello-go@sha256:2fdeab95d81a92603b44a7ee8e3236495db06b07606a4cd7abeddb8ad4030fb6
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Thu, 21 Jul 2022 12:35:38 -0300
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-dgqq6 (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-dgqq6:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  2m7s  default-scheduler  Successfully assigned default/goserver-54dd6d8758-kh86r to k3d-fullcycle-server-0
  Normal  Pulling    2m6s  kubelet            Pulling image "rogeriocassares/hello-go:v2"
  Normal  Pulled     2m5s  kubelet            Successfully pulled image "rogeriocassares/hello-go:v2" in 1.540216096s
  Normal  Created    2m5s  kubelet            Created container goserver
  Normal  Started    2m5s  kubelet            Started container goserver
```

Dessa maneira, fica claro como é possível trabalhar e controlar as versões do `RS`. É interessante ver que para cada elemento que se está trabalhando, é possível ver os eventos que estão acontecendo!

Descrevendo o `Deployment` do `goserver`:
```bash
❯ kubectl describe deployment goserver
Name:                   goserver
Namespace:              default
CreationTimestamp:      Thu, 21 Jul 2022 11:45:29 -0300
Labels:                 app=goserver
Annotations:            deployment.kubernetes.io/revision: 4
Selector:               app=goserver
Replicas:               10 desired | 10 updated | 10 total | 10 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=goserver
  Containers:
   goserver:
    Image:        rogeriocassares/hello-go:v2
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   goserver-54dd6d8758 (10/10 replicas created)
Events:
  Type    Reason             Age                   From                   Message
  ----    ------             ----                  ----                   -------
  Normal  ScalingReplicaSet  56m                   deployment-controller  Scaled up replica set goserver-6675499669 to 1
  Normal  ScalingReplicaSet  56m                   deployment-controller  Scaled up replica set goserver-6675499669 to 10
  Normal  ScalingReplicaSet  50m                   deployment-controller  Scaled up replica set goserver-54dd6d8758 to 3
  Normal  ScalingReplicaSet  50m                   deployment-controller  Scaled up replica set goserver-54dd6d8758 to 5
  Normal  ScalingReplicaSet  50m                   deployment-controller  Scaled down replica set goserver-6675499669 to 8
  Normal  ScalingReplicaSet  50m                   deployment-controller  Scaled up replica set goserver-54dd6d8758 to 6
  Normal  ScalingReplicaSet  50m                   deployment-controller  Scaled down replica set goserver-6675499669 to 7
  Normal  ScalingReplicaSet  50m                   deployment-controller  Scaled down replica set goserver-6675499669 to 6
  Normal  ScalingReplicaSet  50m                   deployment-controller  Scaled up replica set goserver-54dd6d8758 to 7
  Normal  ScalingReplicaSet  14m                   deployment-controller  Scaled up replica set goserver-6675499669 to 5
  Normal  ScalingReplicaSet  14m                   deployment-controller  Scaled down replica set goserver-54dd6d8758 to 8
  Normal  ScalingReplicaSet  14m                   deployment-controller  Scaled up replica set goserver-6675499669 to 3
  Normal  ScalingReplicaSet  14m                   deployment-controller  Scaled down replica set goserver-54dd6d8758 to 7
  Normal  ScalingReplicaSet  14m                   deployment-controller  Scaled up replica set goserver-6675499669 to 6
  Normal  ScalingReplicaSet  14m                   deployment-controller  Scaled down replica set goserver-54dd6d8758 to 6
  Normal  ScalingReplicaSet  14m                   deployment-controller  Scaled up replica set goserver-6675499669 to 7
  Normal  ScalingReplicaSet  14m                   deployment-controller  Scaled down replica set goserver-54dd6d8758 to 5
  Normal  ScalingReplicaSet  14m                   deployment-controller  Scaled up replica set goserver-6675499669 to 8
  Normal  ScalingReplicaSet  6m42s (x18 over 50m)  deployment-controller  (combined from similar events): Scaled down replica set goserver-6675499669 to 8
```

Verifica-se a estrátégia de `RollingUpdateStrategy`, de no máximo 5% indiponível enquanto outros 25% vão surgindo, por exemplo. O mais importante de tudo é o campo `Réplicas`, que mostra quantas estão disponíveis, e os eventos que se pode ter.

A descrição do `Deployment` mostra tudo o que vai acontecendo, quando scale up/down, cria um novo e etc.

Inclusive é possível ver com qual `RS` ele está trabalhando, mostrando o número da revisão, no caso, revisão 4:
```bash
❯ kubectl rollout history deployment goserver             
deployment.apps/goserver 
REVISION  CHANGE-CAUSE
3         <none>
4         <none>
```

## Services

### Entendendo o conceito de Services

De acordo com as diretivas anteriores, a aplicação está funcionando e o tanto de `Pods` rodando da mesma maneira.

Entretanto, como se faz para acessar a aplicação e quais deses `Pods` serão acessados e para qual cada usuário deve ser encaminhado?

O primeiro ponto é que a aplicação rodando não significa que ela pode ser acessada. Então cria-se o `Services`, que é a porta de entrada para a aplicação.

Imagina-se que um `Service` é criadox e toda vez que alguém acessá-lo ele vai redirecionar para uma aplicação como um Load-Balance.

Nós não é preciso preocupar-se com esse tipo de balanceamento de carga inicialmemte! Basta atribuir o `Service` ao `Deployment`, inicialmente e entender como funcionam o `Filtro` e `Selector`; e o k8s gerencia tudo isso.

No fim das contas,cria-se um `Service`, o k8s faz uma função de `Service Discovery`, seleciona qual o melhor `Pod` para ser acessado naquele momento e dar o acesso para o usuário!

O `Port-Forwarder` é um recurso que se utiliza para acessar um `Pod` ou um `Service` quando não há um IP direto para acessar essa máquina.

Obviamente, quando a aplicação estiver em produção, ninguém vai conseguir dar um `Port-Forwarder`. Será necessário ter que passar pelo menos um dominio ou um IP e esse IP sempre vai ser apontado para um determinado `Service`.

No fim das coisas, tudo não passa de associação!


### Utilizando um ClusterIP

Ao criar um arquivo chamado `k8s/service.yaml`, o campo `Selector` é´o responsavel por filtrar todos os `Pods` que estarão instanciados neste `Serviço`.

Supondo que existam 500 `Pods` em uma aplicação, quais deles serão utilizados para esse `Service`?

O selector serve para filtrar e saber quais `Pods` serão utilizados nessa aplicação.

Quando no arquivo de `Deployment`, pode ser observado o campo `Selector`. Ele é o reponsável por indicar qual filtro que será fazer essa seleção. No caso do `deployment.yaml` a seleção é´o `app: goserver`. 

Logo, ao descrever para o `Service`, habilita-se para que ele abraja todos os `Pods` cuja a parte de `matchlabel` dentro do `Selector` onde o app é o `goserver`.

O `Service` vai verificar se cada `Deployment` tem como `label` no selector -> matchlabel app igual a `goserver`. Então todos os `Pods` desse `Deployment` farão parte daquele `Service`.

Essa é a descrição é o filtro e é dessa forma que se diferencia um Serviço do outro.

Se existir um `Service` de `nginx`, por exemplo, ele vai filtrar apenas os `Pods` que tenham um `matchlabel` com a regra que foi colocada tipo `app: goserver` ou `server: nginx`.

No caso aqui, o `Selector` é `app: goserver` e, nesse momento, ele vai abranger todos os `Pods` que o `matchlabel` for `app: goserver`.

Outra coisa importantissisma! Qual o `type` do `Service`?

Os tipos são:
- ClusterIP, 
- Node Port, 
- Load Balancer e 
- Headless Service.


#### ClusterIP.

Quais portas deverão ser acessadas em relação aos `Pods`? Entualmente, é interessante colocar um nome como uma regra para varias portas uttlizando os `-` para definir os nomes.

No `Service` escrito em `go`, a porta `8080` está sendo disponbilizada com o protocolo `TCP`.

service.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: goserver-service
spec:
  selector:
    app: goserver
  type: ClusterIP
  ports:
  - name: goserver-service
    port: 8080
    protocol: TCP
```

Aplicando o arquivo `service.yaml` no cluster:
```bash
❯ kubectl apply -f k8s/service.yaml
service/goserver-service created
```

Verifica-se se realmente o serviço foi criado com o comando `kubectl get services` ou  `kubectl get svc`:
```bash
❯ kubectl get svc     
NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
kubernetes         ClusterIP   10.43.0.1       <none>        443/TCP    124m
goserver-service   ClusterIP   10.43.174.111   <none>        8080/TCP   47s
```

De acordo com a resposta do comando acima, há dois `Services`.

O `kubectl` é o `Service` padrão para receber requisição da API e etc. 

Já o `goserver-service` é  o `Service` que foi criado. Se a resposta for analisada, têm-se o `TYPE` `ClusterIP` e um `IP`!

Esse `ClusterIP` é um `IP` interno do servidor. Então todos que estiverem dentro do cluster k8s vão conseguir acessar esse IP e esse `Service` nesse IP vai indicar qual dos `Pods` disponíveis é possível acessar.

Assim, pode-se chamar o `app` pelo `IP` ou pelo nome do `Service` em que ele está associado, visto eu o k8s trabalha com resolução de nome via `DNS` e esse host se torna visível dentro do k8s. Com isso, na maioria das vezes, é preferível chamar um `Service` pelo nome ao invés do `IP`.

E como acessar os `Pods` estando o usuário fora do Cluster?

Isso é possível resolver com um redirecionamento de portas, para que quando uma porta da máquina for acessada, seja redirecionada para a Porta Correta do `Service`:
```bash
❯ kubectl port-forward svc/goserver-service 8000:8080
Forwarding from 127.0.0.1:8000 -> 8080
Forwarding from [::1]:8000 -> 8080
```

Pronto! Acessando o endereço, é possível obter uma resposta de dentro do `Pod`!
```bash
❯ curl http://localhost:8000
<h1>Hello Fullcycle!!!</h1>%  
```

A diferença é que antes havia um acesso direto a um `Pod`; agora, para um `Service` e este `Service` vai chamar automaticamente um dos `Pods` criados para fazer esse tipo de balanceamento!



### Diferenças entre Port e targetPort

Até agora, foram mostrados `Services` e redirecionadas as requisições para a porta `8080`.

E como fazer com que o usuário acesse o `Service` na porta 80 de uma aplicação que esteja rodando na porta `8000` no cluster? É possível observar que duas coisas aqui: o `Service` e o `Pod` (container).

No k8s é possível acessar o `Service` pela porta `80` e o `Service` vai redirecionar para a porta `8000` do Pod/Container.

Para testar, basta gerar uma nova versão `v3` do `server.go` para a porta `8000`, e modificar o `Deployment` para isso.

k8s/server.go
```go
package main

import (
	"net/http"
)

func main() {
	http.HandleFunc("/", Hello)
	http.ListenAndServe(":8000", nil)
}

func Hello(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("<h1>Hello Fullcycle!!!</h1>"))
}
```

Para construir a nova imagem e enviá-la ao Docker Hub:
```bash
❯ docker build -t rogeriocassares/hello-go:v3 .
❯ docker push rogeriocassares/hello-go:v3
```

E então deve ser modificado o aquivo `deployment.yaml`.

k8s/deployment.yaml:
```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 10
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go:v3"
```

E aplicado o novo arquivo `deployment.yaml`:
```bash
❯ kubectl apply -f k8s/deployment.yaml 
deployment.apps/goserver configured
```

Se for determinada uma porta errada do container no acesso do `Service`, não vai funcionar! Isso porque o acesso será realizado na porta 80 e e redirecionado o `Service` para a porta `8080` da aplicação do container, que não tem nada funcionando. 

Para tentar ver o erro, ao acessar a porta `9000` da máquina, o usuário acessa o serviço na `8080`:
```bash
❯ kubectl port-forward svc/goserver-service 9000:8080
```

Então vê-se que isso não funcionou ao acessar o `http://localhost:9000`, pois o redirecionamento ocorreu para a porta `8080`, sendo que o container está rodando na porta `8000`.

Para resolver isso, pode ser acessado um `container` na porta `8080` e fazer com que o serviço redirecione para a porta que desejada dentro do container. Isso acontece com o `targetPort`, que é a porta do container!

Então todas as vezes em que o `Service` for acessado na porta `8080`, ele vai redirecionar para a porta `8000` do container.

Nota: Caso o `targetPort` não for definido, será a porta do Container.

k8s/service.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: goserver-service
spec:
  selector:
    app: goserver
  type: ClusterIP
  ports:
  - name: goserver-service
    port: 8080
    targetPort: 8000
    protocol: TCP
```

Aplicando o novo serviço no k8s:
```bash
❯ kubectl apply -f k8s/service.yaml 
service/goserver-service configured
```

E aplicando um `port-forward` na porta `9000`:
```bash
❯ kubectl port-forward svc/goserver-service 9000:8080
Forwarding from 127.0.0.1:9000 -> 8000
Forwarding from [::1]:9000 -> 8000
```

Isto é, `Client/localhost-pc (:9000) -> goserver-service (:8080) -> Pod/Container (:8000)`.

Logo, se for acessado o endereço `http://localhost:9000`
```bash
❯ curl http://localhost:9000
<h1>Hello Fullcycle!!!</h1>
```

Pronto! A relação entre `Port` e `targetPort` é que a `Port` é a porta do `Service` e não a porta do `Pod` (Container).


### Utilizando proxy para acessar a API do Kubernetes

O k8s funciona em orientado à API e o `kubectl` conversa com essa API a todo o momento.

O `kubectl` nada mais é que o executável de um *client* que se comunica com a API do k8s através de certificados autenticados e essa API do k8s pode ser acessada diretamente e é isso que será visto agora.

Primeiramente, o k8s está em uma rede fechada. E como é possível acessar essa rede fechada?

O comando `kubectl proxy` gera um `proxy` da máquina do usuário com o cluster k8s para realizar esse acesso, por exemplo:
```bash
❯ kubectl proxy --port=8080 
Starting to serve on 127.0.0.1:8080
```

Nesse ponto, toda vez que for acessada a porta `8080` será estabelecida uma conexão na API do k8s.

Ao acessar `http://localhost:8080` na web, todos os objetos da API do k8s são listados.
```json
// 20220721184325
// http://localhost:8080/

{
  "paths": [
    "/.well-known/openid-configuration",
    "/api",
    "/api/v1",
    "/apis",
    "/apis/",
    "/apis/admissionregistration.k8s.io",
    "/apis/admissionregistration.k8s.io/v1",
    "/apis/apiextensions.k8s.io",
    "/apis/apiextensions.k8s.io/v1",
    "/apis/apiregistration.k8s.io",
    "/apis/apiregistration.k8s.io/v1",
    "/apis/apps",
    "/apis/apps/v1",
    "/apis/authentication.k8s.io",
    "/apis/authentication.k8s.io/v1",
    "/apis/authorization.k8s.io",
    "/apis/authorization.k8s.io/v1",
    "/apis/autoscaling",
    "/apis/autoscaling/v1",
    "/apis/autoscaling/v2",
    "/apis/autoscaling/v2beta1",
    "/apis/autoscaling/v2beta2",
    "/apis/batch",
    "/apis/batch/v1",
    "/apis/batch/v1beta1",
    "/apis/certificates.k8s.io",
    "/apis/certificates.k8s.io/v1",
    "/apis/coordination.k8s.io",
    "/apis/coordination.k8s.io/v1",
    "/apis/discovery.k8s.io",
    "/apis/discovery.k8s.io/v1",
    "/apis/discovery.k8s.io/v1beta1",
    "/apis/events.k8s.io",
    "/apis/events.k8s.io/v1",
    "/apis/events.k8s.io/v1beta1",
    "/apis/flowcontrol.apiserver.k8s.io",
    "/apis/flowcontrol.apiserver.k8s.io/v1beta1",
    "/apis/flowcontrol.apiserver.k8s.io/v1beta2",
    "/apis/helm.cattle.io",
    "/apis/helm.cattle.io/v1",
    "/apis/k3s.cattle.io",
    "/apis/k3s.cattle.io/v1",
    "/apis/metrics.k8s.io",
    "/apis/metrics.k8s.io/v1beta1",
    "/apis/networking.k8s.io",
    "/apis/networking.k8s.io/v1",
    "/apis/node.k8s.io",
    "/apis/node.k8s.io/v1",
    "/apis/node.k8s.io/v1beta1",
    "/apis/policy",
    "/apis/policy/v1",
    "/apis/policy/v1beta1",
    "/apis/rbac.authorization.k8s.io",
    "/apis/rbac.authorization.k8s.io/v1",
    "/apis/scheduling.k8s.io",
    "/apis/scheduling.k8s.io/v1",
    "/apis/storage.k8s.io",
    "/apis/storage.k8s.io/v1",
    "/apis/storage.k8s.io/v1beta1",
    "/apis/traefik.containo.us",
    "/apis/traefik.containo.us/v1alpha1",
    "/healthz",
    "/healthz/autoregister-completion",
    "/healthz/etcd",
    "/healthz/log",
    "/healthz/ping",
    "/healthz/poststarthook/aggregator-reload-proxy-client-cert",
    "/healthz/poststarthook/apiservice-openapi-controller",
    "/healthz/poststarthook/apiservice-registration-controller",
    "/healthz/poststarthook/apiservice-status-available-controller",
    "/healthz/poststarthook/bootstrap-controller",
    "/healthz/poststarthook/crd-informer-synced",
    "/healthz/poststarthook/generic-apiserver-start-informers",
    "/healthz/poststarthook/kube-apiserver-autoregistration",
    "/healthz/poststarthook/priority-and-fairness-config-consumer",
    "/healthz/poststarthook/priority-and-fairness-config-producer",
    "/healthz/poststarthook/priority-and-fairness-filter",
    "/healthz/poststarthook/rbac/bootstrap-roles",
    "/healthz/poststarthook/scheduling/bootstrap-system-priority-classes",
    "/healthz/poststarthook/start-apiextensions-controllers",
    "/healthz/poststarthook/start-apiextensions-informers",
    "/healthz/poststarthook/start-cluster-authentication-info-controller",
    "/healthz/poststarthook/start-kube-aggregator-informers",
    "/healthz/poststarthook/start-kube-apiserver-admission-initializer",
    "/livez",
    "/livez/autoregister-completion",
    "/livez/etcd",
    "/livez/log",
    "/livez/ping",
    "/livez/poststarthook/aggregator-reload-proxy-client-cert",
    "/livez/poststarthook/apiservice-openapi-controller",
    "/livez/poststarthook/apiservice-registration-controller",
    "/livez/poststarthook/apiservice-status-available-controller",
    "/livez/poststarthook/bootstrap-controller",
    "/livez/poststarthook/crd-informer-synced",
    "/livez/poststarthook/generic-apiserver-start-informers",
    "/livez/poststarthook/kube-apiserver-autoregistration",
    "/livez/poststarthook/priority-and-fairness-config-consumer",
    "/livez/poststarthook/priority-and-fairness-config-producer",
    "/livez/poststarthook/priority-and-fairness-filter",
    "/livez/poststarthook/rbac/bootstrap-roles",
    "/livez/poststarthook/scheduling/bootstrap-system-priority-classes",
    "/livez/poststarthook/start-apiextensions-controllers",
    "/livez/poststarthook/start-apiextensions-informers",
    "/livez/poststarthook/start-cluster-authentication-info-controller",
    "/livez/poststarthook/start-kube-aggregator-informers",
    "/livez/poststarthook/start-kube-apiserver-admission-initializer",
    "/logs",
    "/metrics",
    "/openapi/v2",
    "/openid/v1/jwks",
    "/readyz",
    "/readyz/autoregister-completion",
    "/readyz/etcd",
    "/readyz/informer-sync",
    "/readyz/log",
    "/readyz/ping",
    "/readyz/poststarthook/aggregator-reload-proxy-client-cert",
    "/readyz/poststarthook/apiservice-openapi-controller",
    "/readyz/poststarthook/apiservice-registration-controller",
    "/readyz/poststarthook/apiservice-status-available-controller",
    "/readyz/poststarthook/bootstrap-controller",
    "/readyz/poststarthook/crd-informer-synced",
    "/readyz/poststarthook/generic-apiserver-start-informers",
    "/readyz/poststarthook/kube-apiserver-autoregistration",
    "/readyz/poststarthook/priority-and-fairness-config-consumer",
    "/readyz/poststarthook/priority-and-fairness-config-producer",
    "/readyz/poststarthook/priority-and-fairness-filter",
    "/readyz/poststarthook/rbac/bootstrap-roles",
    "/readyz/poststarthook/scheduling/bootstrap-system-priority-classes",
    "/readyz/poststarthook/start-apiextensions-controllers",
    "/readyz/poststarthook/start-apiextensions-informers",
    "/readyz/poststarthook/start-cluster-authentication-info-controller",
    "/readyz/poststarthook/start-kube-aggregator-informers",
    "/readyz/poststarthook/start-kube-apiserver-admission-initializer",
    "/readyz/shutdown",
    "/version"
  ]
}
```

Isso tudo é o k8s que está expondo. Uma das APIs que mais utilizadas é a API `v1`, que é a API que para entrar nos `Services`. Para saber mais, basta clicar nela.

Ao acessar `http://localhost:8080/api/v1/namespaces/default/services/goserver-service`, o `endpoint` do `Service` que foi criado e que traz as principais alterações que foram realizadas no `service.yaml` para evidenciar mais informações em relação àquilo que se está fazendo.
```json
// 20220721184803
// http://localhost:8080/api/v1/namespaces/default/services/goserver-service

{
  "kind": "Service",
  "apiVersion": "v1",
  "metadata": {
    "name": "goserver-service",
    "namespace": "default",
    "uid": "bcb3cb12-6692-4036-bfb9-7252b7a25473",
    "resourceVersion": "5903",
    "creationTimestamp": "2022-07-21T16:06:45Z",
    "annotations": {
      "kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"v1\",\"kind\":\"Service\",\"metadata\":{\"annotations\":{},\"name\":\"goserver-service\",\"namespace\":\"default\"},\"spec\":{\"ports\":[{\"name\":\"goserver-service\",\"port\":8080,\"protocol\":\"TCP\",\"targetPort\":8000}],\"selector\":{\"app\":\"goserver\"},\"type\":\"ClusterIP\"}}\n"
    },
    "managedFields": [
      {
        "manager": "kubectl-client-side-apply",
        "operation": "Update",
        "apiVersion": "v1",
        "time": "2022-07-21T16:06:45Z",
        "fieldsType": "FieldsV1",
        "fieldsV1": {
          "f:metadata": {
            "f:annotations": {
              ".": {
                
              },
              "f:kubectl.kubernetes.io/last-applied-configuration": {
                
              }
            }
          },
          "f:spec": {
            "f:internalTrafficPolicy": {
              
            },
            "f:ports": {
              ".": {
                
              },
              "k:{\"port\":8080,\"protocol\":\"TCP\"}": {
                ".": {
                  
                },
                "f:name": {
                  
                },
                "f:port": {
                  
                },
                "f:protocol": {
                  
                },
                "f:targetPort": {
                  
                }
              }
            },
            "f:selector": {
              
            },
            "f:sessionAffinity": {
              
            },
            "f:type": {
              
            }
          }
        }
      }
    ]
  },
  "spec": {
    "ports": [
      {
        "name": "goserver-service",
        "protocol": "TCP",
        "port": 8080,
        "targetPort": 8000
      }
    ],
    "selector": {
      "app": "goserver"
    },
    "clusterIP": "10.43.174.111",
    "clusterIPs": [
      "10.43.174.111"
    ],
    "type": "ClusterIP",
    "sessionAffinity": "None",
    "ipFamilies": [
      "IPv4"
    ],
    "ipFamilyPolicy": "SingleStack",
    "internalTrafficPolicy": "Cluster"
  },
  "status": {
    "loadBalancer": {
      
    }
  }
}
```

Qualquer coisa que for feita no k8s acontece via API e aqui está a API para a consulta.

Basicamente, o `kubectl apply` faz uma requisição em um desses `endpoints` para criar qualquer coisa que se precisa no cluster do `k8s`.


### Utilizando NodePort

O `NodePort` é um tipo diferente de `Service`. Esse serviço é o mais arcaico que se pode ter quando se deseja acessar o cluster `k8s` de fora dele.

O `ClusterIP` gera um `IP` interno no cluster para acessar esses serviços internamente.

Quando é necessário acessar o cluster de fora, é preciso ter outros tipos de serviços e um deles é `NodePort`

O `NodePort` funciona da seguinte maneira: Supondo que se tenha o `Node 1`, o `Node 2`, o `Node 3` e o `Node 4` com diversos `Pods` cada máquina. Então há a nec essidade de acessar um serviço utilizando o `NodePort`.

Quando se fala de usar o `NodePort`, usa-se uma porta alta no `Node 1`, por exemplo. Porta alta é com o número maior que `30000` e menor que `32767`; para o exemplo, `30001`. Quando se fala disso e cria-se o `NodePort`, essa porta `3001` vai ser aberta em todos os `Nodes`!

E o que vai acontecer é que qualquer pessoa que souber o `IP` ou endereço de qualquer um dos `Nodes` do cluster e acessar essa porta vai cair em nos serviços.

Portanto, o `NodePort` gera uma porta e libera a porta em todos os `Nodes` do cluster, independente do `Node` que a ser acessado e então é possível entrar nesses serviços.

Geralmente, esse tipo é quando se quer fazer uma demontraçãoo ou uma forma temporária de subir um serviço e vai sair do ar, ou trabalhar com um próprio `Load Balance` etc. Na prática, com aplicações em produção, vai ser muito dificil colocar esse tipo de serviço no ar porque existem serviços mais adequados em relação a isso.

Se nao passar nada no arquivo de configuração, ele vai gerar uma porta automaticamente.

k8s/service.yaml:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: goserver-service
spec:
  selector:
    app: goserver
  type: NodePort
  ports:
  - name: goserver-service
    port: 8080
    targetPort: 8000
    protocol: TCP
    nodePort: 30001

```

Ao aplicar esse serviço:
```bash
❯ kubectl apply -f k8s/service.yaml
service/goserver-service configured
```

Verificando o `NodePort`

```bash
❯ kubectl get svc
NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
kubernetes         ClusterIP   10.43.0.1       <none>        443/TCP          8h
goserver-service   NodePort    10.43.174.111   <none>        8080:30001/TCP   5h59m
```

O que está acontecendo é que ao acessar qualquer um dos `Nodes` do cluster pela porta `30001` vai cair na porta `8080` do serviço! E todo mundo que cair na porta `8080` do serviço vai ser redirecionado para a porta `8000` do container que está rodando esse serviço.

Supondo que esse cluster tenha 1 Master e 4 Workres, ao entrar em qualquer um deles na porta `30001`, irá cair nesse service `goserver-service`.

Então, a ideia do `NodePort` é conseguir expor uma porta para fora do cluster.


### Trabalhando com LoadBalancer
Primeiramente, é importante deletar o serviço `NodePort`

````bash
❯ kubectl get svc                                       
NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
kubernetes         ClusterIP   10.43.0.1       <none>        443/TCP          23h
goserver-service   NodePort    10.43.174.111   <none>        8080:30001/TCP   21h

❯ kubectl delete svc goserver-service
service "goserver-service" deleted
````

E configurar o tipo de serviço como LoadBalancer em service.yaml:

k8s/service.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: goserver-service
spec:
  selector:
    app: goserver
  type: LoadBalancer
  ports:
  - name: goserver-service
    port: 8080
    targetPort: 8000
    protocol: TCP
```

O `ClusterIP` é o `IP` interno do servidor, o `NodePort` expõe uma porta através de qualquer um dos `Nodes`. O `LoadBalancer` gera um `IP` para acessar a aplicação de fora.

Esse tipo de serviço é muito utilizado quando se utiliza um cluster gerenciado, um cluster `k8s` que está conectado a um provedor de nuvem, por exemplo.

Na AWS, quando um servidor do tipo `LoadBalancer` é criado, ele vai gerar automaticamente um `IP` externo e todos que acessarem esse `IP` externo devem conseguir acessar determinado servidor.

Aplicando o arquivo de configuração:
```bash
❯ kubectl apply -f k8s/service.yaml
service/goserver-service created
```
Ao verificar o serviço criado:
```bash
❯ kubectl get svc                    
NAME               TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)          AGE
kubernetes         ClusterIP      10.43.0.1       <none>         443/TCP          24h
goserver-service   LoadBalancer   10.43.203.126   192.168.96.2   8080:30210/TCP   6s
```

Da mesma forma que o `Cluster IP`, tem um `IP` interno, o `LoadBalancer` tb gera!

Mas o `LoadBalancer` gera um `IP` externo também. isto é, um `IP` que pode passar para qualquer outro sistema.

Em uma AWS, ao rodar esse serviço, vai aparecer um novo `IP` e qualquer pessoa vai poder acessar esse IP.

Uma coisa interessante de quando se utiliza o `LoadBalancer` é que ele também gera um `NodePort` (`:30210`). 

Por isso, o `LoadBalancer` é o suprasumo. Ele contém o `ClusterIP` e o `NodePort` ao mesmo tempo em que tem um IP exclusivo!

NOTA: Normalmente utilizado quando deseja-se expor qualquer aplicação para a Internet de maneira geral. 


## Objetos de Configuração

### Entendendo objetos de configuração

Não nessariamente objetos `k8s`, mas também como configurar variáveis de ambiente das aplicações `k8s` para a aplicação ou, eventualmente, injetar um arquivo de configuração que criado para as informações dinâmicas que se precida. Esses objetos também são responsáveis em como guardar senhas e dados sensíveis no `k8s` para que sejam usados como variáveis de ambiente dentro da aplicação.

Por conta disso, existem alguns objetos para ajudar a criar esses arquivos e dados sensíves de uma forma muito tranquila.

O que  muda de um ambiente `dev` para `prod` geralmente são esses dados sensíveis que o `k8s` estabelece nesses recursos!

### Usando variáveis de ambiente

Para configurar variáveis de ambiente no `k8s` para que a aplicaçao consiga acessá-los, a primeira coisa é adicionar variáveis de ambiente na aplicação `server.go` para que ela as acesse.

```go
package main

import (
	"fmt"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/", Hello)
	http.ListenAndServe(":8000", nil)
}

func Hello(w http.ResponseWriter, r *http.Request) {
	name := os.Getenv("NAME")
	age := os.Getenv("AGE")
	fmt.Fprintf(w, "Hello, I am %s. I am %s.", name, age)
}
```

E gerar o `build` e dar o `push` no Docker Registry!
```bash
❯ docker build -t rogeriocassares/hello-go:v4 .
❯ docker push rogeriocassares/hello-go:v4 
```

Ao configurar o `deployment` com uma replica, `v4`, e colocar uma `label` com `env`!

k8s/deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 1
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go:v4"
          env:
            - name: NAME
              value: "Rogerio"
            - name: AGE
              value: "29"
```

E aplicar esse arquivo no k8s:
```bash
❯ kubectl apply -f  k8s/deployment.yaml           
deployment.apps/goserver configured
```

Fazendo a configuração de porta para acessar a aplicação e ver se está tudo funcionando:
```bash
❯ kubectl port-forward svc/goserver-service 9000:8080
Forwarding from 127.0.0.1:9000 -> 8000
Forwarding from [::1]:9000 -> 8000
```

Ao acessar http://localhost:9000, funcionou!

### Variáveis de ambiente com ConfigMap

Não é muito legal colocar variáveis de ambiente dentro do `deployment.yaml`, mas sim em um arquivo separadp e importá-lo no `deployment.yaml`.

Para isso, o `k8s` possui o `ConfigMap`.

O `ConfigMap` basicamente é uma mapa de configuração em que é possível utilizá-lo de diversas formas na aplicação.

Primeiro exemplo:

Ao criar um arquivo de `configmap-env.yaml`:

k8s/configmap-env.yaml
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: goserver-env
data:
  NAME: "Rogerio"
  AGE: "29"
```

Após criar o mapa de configuração, basta fazer uma pequena mudança no `deployment.yaml`.

k8s/deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 1
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go:v4"
          env:
            - name: NAME
              valueFrom:
                configMapKeyRef:
                  name: goserver-env
                  key: NAME

            - name: AGE
              valueFrom:
                configMapKeyRef:
                  name: goserver-env
                  key: AGE
```

Ao alterar o `deployment.yaml`, o `ConfigMap` é uma referência para o arquivo.

Nota: Se o `ConfigMap` for alterado, o `Deployment` não vai ser modificado automaticvamente! É necessário recriar e alterar o `Deployment` para ele ler o novo `ConfigMap`!


Ao aplicar o `ConfigMap`:
```bash
❯ kubectl apply -f k8s/configmap-env.yaml
configmap/goserver-env created
```

E aplicar o `Deployment`:
```bash
❯ kubectl apply -f k8s/deployment.yaml 
deployment.apps/goserver configured
```

Observa-se que o `Deployent` está usando o `ConfigMap`. Para verificar se funcionou, basta utilizar o port-forward:
```bash
❯ kubectl port-forward svc/goserver-service 9000:8080
Forwarding from 127.0.0.1:9000 -> 8000
Forwarding from [::1]:9000 -> 8000
```

Ao acessar http://localhost:9000, funcionou!

Entretanto, existe uma forma mais fácil, nem sempre aplicável.

Supondo pegar todas as variáveis que estão no `ConfigMap` e transformá-las em variáveis de ambiente, tendo 100 parâmetros como variaveis de ambiente o arquivo de `Deployment` vai ficar enorme!

Ao invés de colocar `env`, pode-se colocar `envFrom` e vai ele puxar todas as `keys` do `ConfigMap` no formato de variável de ambiente! E o `Deployment` fica como assim:

k8s/deployment:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 1
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go:v4"
          envFrom:
            - configMapRef:
                name: goserver-env    
          # env:
          #   - name: NAME
          #     valueFrom:
          #       configMapKeyRef:
          #         name: goserver-env
          #         key: NAME
          #   - name: AGE
          #     valueFrom:
          #       configMapKeyRef:
          #         name: goserver-env
          #         key: AGE
```

Para verificar o funcionamento, basta aplicar o `deployment.yaml`, executar o `PortForward` e acessar http://localhost:9000.

```bash
❯ kubectl apply -f k8s/deployment.yaml

❯ kubectl port-forward svc/goserver-service 9000:8080
Forwarding from 127.0.0.1:9000 -> 8000
Forwarding from [::1]:9000 -> 8000
```

E funcionou!

Portanto, há três formas claras de se trabalhar com `k8s` usando variáveis de ambiente:
1. colocando `env` e passando a `key` e o `value`
2. colcoando o `configmap` e passando a `key` e o value passando o `configmap`
3. pegar todos as `keys` do `configmao` e colocando para variável de ambiente no `Deployment`.



### Injetando ConfigMap na aplicação

Muitas vezes há arquivos que são dinâmicos. Por exemplo, um arquivo de `token` e esse `token` tem que estar na raiz do projeto. Esse arquivo muda de projeto pra projeto.

Ou muitas vezes há a necessidade de colocar um arquivo `.env` na raiz do nosso projeto também!

Ou ainda fazer a substituição de um arquivo que já existe no projeto por um outro criado com uma configuração específica como subir o `nginx` com um arquivo `.conf` e, posteriormente, colocar esse arquivo `.conf` no lugar do `.conf` original.

Atualmente, deve ser realizada a alteração no `nginx`, gerar uma nova imagem e subir tudo novvamente.

Mas se mudar uma porta ou domínio, não é necessário sair criando imagens e tudo isso pode ser feito de forma mais flexível.

Então, o `configmap` pode ser um arquivo físico que vai ser injetado lá no container para utilizar!

Isso realmente é fantátisco e muito utilizado no k8s!

No exemplo do server.go, supondo que devem ser criados membros da família. Para isso, pode ser criada uma função `ConfigMap` e ler um arquivo que vai estar dentro do projeto. Para ler esse arquivo e imprimir o valor desse arquivo:

server.go
```go
package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/configmap", ConfigMap)
	http.HandleFunc("/", Hello)
	http.ListenAndServe(":8000", nil)
}

func Hello(w http.ResponseWriter, r *http.Request) {
	name := os.Getenv("NAME")
	age := os.Getenv("AGE")
	fmt.Fprintf(w, "Hello, I am %s. I am %s.", name, age)
}

func ConfigMap(w http.ResponseWriter, r *http.Request) {

	data, err := ioutil.ReadFile("myfamily/family.txt")
	if err != nil {
		log.Fatalf("Error reading file: ", err)
	}
	fmt.Fprintf(w, "My family: %s.", string(data))
}
```

Build e push:
```bash
❯ docker build -t rogeriocassares/hello-go
❯ docker push rogeriocassares/hello-go:v5
```

Criar um arquivo `configmap-family.yaml`:

configmap-family.yaml
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: configmap-family
data:
  members: "pai, mae, irmao 1, irmao2, irmao3"
```

E aplicar esse arquivo ao k8s:
```bash
❯ kubectl apply -f k8s/configmap-family.yaml 
configmap/configmap-family created
```

Agora que com o `configmap` e a imagem criados, falta fazer o ajuste no `Deployment`!

Quando se fala em um arquivo de um `configmap` injetar na aplicação uma informação, fala-se de um volume que está sendo injetado na aplicação.

Uma vez que esse volume exista, é necessário declará-lo e aplicação.

No `configmap` é preciso falar quais itens devem ser montados para ele.

Agora, com o volume declarado, é nnecessário que montar o volume dentro do `Deployment`, dentro do `Container`. com o `volumeMounts`, montando o volume config na pasta `/go/myfamily` dentro da aplicação.

deployment.yaml:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 1
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go:v5"
          envFrom:
            - configMapRef:
                name: goserver-env

          volumeMounts:
            - mountPath: "/go/myfamily"
              name: config

      volumes:
        - name: config
          configMap:
            name: configmap-family
            items:
              - key: members
                path: "family.txt"
```

Aplicar o deployment:
```bash
❯ kubectl apply -f k8s/deployment.yaml
deployment.apps/goserver configured
```

E está rodando!
```bash
❯ kubectl get po
NAME                        READY   STATUS    RESTARTS   AGE
goserver-6bc696c769-wl458   1/1     Running   0          25s
```

Fazendo o `port-forward`:
```bash
❯ kubectl port-forward svc/goserver-service 9000:8080
Forwarding from 127.0.0.1:9000 -> 8000
Forwarding from [::1]:9000 -> 8000
```

Para ver se está tudo certo, basta acessar http://localhost:9000 e está tudo ok!

Acessando também em http://localhost:9000/configmap, funcionou!!!

Como se pode ver se deu erro?

É possível ver se o `Pod` reiniciou:
```bash
❯ kubectl get po
NAME                        READY   STATUS    RESTARTS   AGE
goserver-6bc696c769-wl458   1/1     Running   0          4m41s
```

Para acessar o `Pod`, basta copiar o seu nome e fazer exatamente como se faz no `docker`, fazendo um `exec` nele e acessando o arquivo `family.txt` montado no `Pod`!

```bash
❯ kubectl exec -it goserver-6bc696c769-wl458 bash
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
root@goserver-6bc696c769-wl458:/go# ls
bin  myfamily  server  server.go  src
root@goserver-6bc696c769-wl458:/go# cat myfamily/family.txt 
pai, mae, irmao 1, irmao2, irmao3root@goserver-6bc696c769-wl458:/go#
```

Nota-se que o arquivo foi montado! Então o erro não deve estar no `Deployment` mas pode ser no programa `aerver.go`.

Para acessar os logs:
```bash
❯ kubectl logs goserver-6bc696c769-wl458
```

Ao verificar os logs foi constatado que o caminho no `server.go` deve ser alterado para a raiz.

server.go:
```go
package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/configmap", ConfigMap)
	http.HandleFunc("/", Hello)
	http.ListenAndServe(":8000", nil)
}

func Hello(w http.ResponseWriter, r *http.Request) {
	name := os.Getenv("NAME")
	age := os.Getenv("AGE")
	fmt.Fprintf(w, "Hello, I am %s. I am %s.", name, age)
}

func ConfigMap(w http.ResponseWriter, r *http.Request) {

	data, err := ioutil.ReadFile("/go/myfamily/family.txt")
	if err != nil {
		log.Fatalf("Error reading file: ", err)
	}
	fmt.Fprintf(w, "My family: %s.", string(data))
}

```

Build e push:
```bash
❯ docker build -t rogeriocassares/hello-go:v5.1 .
❯ docker push rogeriocassares/hello-go:v5.1
```

Ajustando o `Deployment` para a versão `5.1`:

k8s/deployment.yaml:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 1
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go:v5.1"
          envFrom:
            - configMapRef:
                name: goserver-env

          volumeMounts:
            - mountPath: "/go/myfamily"
              name: config

      volumes:
        - name: config
          configMap:
            name: configmap-family
            items:
              - key: members
                path: "family.txt"
```

Aplicando o `Deployment` com o `port-forward`:

```bash
❯ kubectl apply -f k8s/deployment.yaml              
deployment.apps/goserver configured

❯ kubectl port-forward svc/goserver-service 9000:8080
Forwarding from 127.0.0.1:9000 -> 8000
Forwarding from [::1]:9000 -> 8000
```

Acessando http://localhost:9000 e http://localhost:9000/configmap, ambos funcionaram!!!

Para garantir que esses arquivos nunca serão modificados, pode-se colocar uma configuração de `readonly: true` em `volumeMonts`.

k8s/deployment.yaml:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 1
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go:v5.1"
          envFrom:
            - configMapRef:
                name: goserver-env

          volumeMounts:
            - mountPath: "/go/myfamily"
              name: config
              readOnly: true

      volumes:
        - name: config
          configMap:
            name: configmap-family
            items:
              - key: members
                path: "family.txt"
```

Assim, ninguem e nem o próprio sistema vai conseguir modificar!


#### Secrets e variáveis de ambiente

`Secrets` é um objeto do k8s para guardar dados mais sensíveis. Os dados do `secret` fica um pouco mais ofuscado que no `configmap` mas não é a forma mais segura do mundo. 

Existem integrações do k8s com `vault`, `kms` para ninguém ter acesso a esses `secrets`. 

Existem também alguns tipos de `secrtes`, mas, na prática, o que é utilizado é um `secret` do tipo opaco, que não deixa esses `secrets` visíveis e facilmente a vista, mas essa visibilidade é uma pseudo visibilidade. 

Supondo que na aplicação `server.go` será criado um novo `endpoint` para `secret`.

server.go:
```go
package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/secret", Secret)
	http.HandleFunc("/configmap", ConfigMap)
	http.HandleFunc("/", Hello)
	http.ListenAndServe(":8000", nil)
}

func Hello(w http.ResponseWriter, r *http.Request) {
	name := os.Getenv("NAME")
	age := os.Getenv("AGE")
	fmt.Fprintf(w, "Hello, I am %s. I am %s.", name, age)
}

func Secret(w http.ResponseWriter, r *http.Request) {
	user := os.Getenv("USER")
	password := os.Getenv("PASSWORD")
	fmt.Fprintf(w, "User: %s. Paswword: %s.", user, password)
}

func ConfigMap(w http.ResponseWriter, r *http.Request) {

	data, err := ioutil.ReadFile("/go/myfamily/family.txt")
	if err != nil {
		log.Fatalf("Error reading file: ", err)
	}
	fmt.Fprintf(w, "My family: %s.", string(data))
}

```

Pronto. Para gerar uma nova versão:
```bash
❯ docker build -t rogeriocassares/hello-go:v5.2 .
❯ docker push rogeriocassares/hello-go:v5.2
```

E criar um arquivo `k8s/secret.yaml`, colocando os valores de secret em base64:
```bash
❯ echo "rogerio" | base64
cm9nZXJpbwo=

❯ echo "123456" | base64
MTIzNDU2Cg==
```

Pronto! Fica assim:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: goserver-secret
type: Opaque
data:
  USER: "cm9nZXJpbwo="
  PASSWORD: "MTIzNDU2Cg=="
```

Atenção! Base64 não é criptografia! O importante aqui é não ter uma forma visual descaradamente. Esse é um padrão do k8s. Existem formas mais seguras de terceiros. 

Aplicando o `secret`:
```bash
❯ kubectl apply -f k8s/secret.yaml 
secret/goserver-secret created
```

Agora como fazer para o `server.go` utilizar o `secret`?

É necessário colocar `secretRef` ao inves de `configmapRef` no `Deployment`.

k8s/deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 1
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go:v5.2"
          envFrom:
            - configMapRef:
                name: goserver-env
            - secretRef:
                name: goserver-secret

          volumeMounts:
            - mountPath: "/go/myfamily"
              name: config
              readOnly: true

      volumes:
        - name: config
          configMap:
            name: configmap-family
            items:
              - key: members
                path: "family.txt"
```

E aplicar o `Deployment`:
```bash
❯ kubectl apply -f k8s/deployment.yaml 
deployment.apps/goserver configured
```

E também o `port-forward`:
```bash
❯ kubectl port-forward svc/goserver-service 9000:8080
Forwarding from 127.0.0.1:9000 -> 8000
Forwarding from [::1]:9000 -> 8000
```

Acessando http://localhost:9000/secret, funcionou!

E não se pode esquecer que agora isso virou variável de ambiente! Veja:
```bash
❯ kubectl get po
NAME                       READY   STATUS    RESTARTS   AGE
goserver-855f7c97b-kdlcw   1/1     Running   0          3m9s

❯ kubectl exec -it goserver-855f7c97b-kdlcw -- bash
root@goserver-855f7c97b-kdlcw:/go# echo $USER
rogerio
root@goserver-855f7c97b-kdlcw:/go# echo $PASSWORD
123456
```
Nota: 
Nos procedimentos acima foi notório observar como se trabalhar com variáveis de ambiente e os `secrets` são, basicamente, variáveis de ambiente.
Para tentar proteger um pouco mais, pode-se integrar com outros sistemas.



## Probes

### Entendendo o health check

O conceito de Probes é uma forma para verificar se a aplicação está saudável e, se não estiver, tomar uma ação. 

Uma aplicação e o seu ciclo de vida são coisas bem distintas. Para entender quando trabalhar com o `health-check`, é preciso conhecer o momento da aplicação. Isso vai ajudar a garantir que ela fique sempre disponível.

Se a aplicação está funcionando no ar e está tudo ok, é necessário um mecanismo que a verifique. Se não estiver, o que se pode fazer? Geralmente no k8s a aplicação é a aplicação é reiniciada do container para que ela volte ao normal.

Por outro lado, existe um outro fator. Quando está a aplicação está subindo pela primeira vez, como identificar que ela está´pronta para subir para o ambiente de produção?

Por exemplo, quando sobe um banco de dados, pode demorar, às vezes, uns 10 segundos para iniciar. Nesse momento em que o banco de dados está iniciando, não é desejável nenhum tráfego para esse `Pod` pois vai gerar um erro. 

Então tem que ser possível garantir o envio de trafego apenas quando a aplicação estiver pronta.

Nesse momento, há dois pontos impiortantes: quando a aplicação já está no ar e quando ela ainda está sendo inicializada.

Supondo que a aplicação está no ar e esta tudo funcionando e ocorra problema. Obviamente que é possível reiniciar o processo. Mas antes de reiniciar o processo, é necessário não mais redirecionar para aquele determinado `Pod` porque senão vai continuar dando erro.

É a história de saber que existe um problema e continuar enviando o tráfego de problema.

Nesse caso, tem que parar de enviar o tráfego e reiniciar o container.

Por conta disso, existem `liveness probe`, `readyness probe` e `startup probe`. 

Esses assuntos são extremamente importantes e tem que tomar cuidado para não cair em ciladas.



### Criando endpoint Healthz

Para criar um endpoint de medição da saúde do container, deve-se alterar o `server.go` para gerar um problema. De tempos em tempos será verificada a saúde da aplicação.

```go
package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"time"
)

var startedAt = time.Now()

func main() {
	http.HandleFunc("/healthz", Healthz)
	http.HandleFunc("/secret", Secret)
	http.HandleFunc("/configmap", ConfigMap)
	http.HandleFunc("/", Hello)
	http.ListenAndServe(":8000", nil)
}

func Hello(w http.ResponseWriter, r *http.Request) {
	name := os.Getenv("NAME")
	age := os.Getenv("AGE")
	fmt.Fprintf(w, "Hello, I am %s. I am %s.", name, age)
}

func Secret(w http.ResponseWriter, r *http.Request) {
	user := os.Getenv("USER")
	password := os.Getenv("PASSWORD")
	fmt.Fprintf(w, "User: %s. Paswword: %s.", user, password)
}

func ConfigMap(w http.ResponseWriter, r *http.Request) {

	data, err := ioutil.ReadFile("/go/myfamily/family.txt")
	if err != nil {
		log.Fatalf("Error reading file: ", err)
	}
	fmt.Fprintf(w, "My family: %s.", string(data))
}

func Healthz(w http.ResponseWriter, r *http.Request) {

	duration := time.Since(startedAt)

	if duration.Seconds() > 25 {
		w.WriteHeader(500)
		w.Write([]byte(fmt.Sprintf("Duration: %v", duration.Seconds())))
	} else {
		w.WriteHeader(200)
		w.Write([]byte("ok"))
	}
}

```

A ideia do programa acima é funcionar normalmente, mas depois de 25 segundos ela vai começar a gerar um erro (500) para testar algumas coisas.

Para gerar um build com a versão `5.3`, dar um push no docker hub e aplicar um novo `Deployment` com essa nova versão:

```bash
❯ docker build -t rogeriocassares/hello-go:v5.3 .
❯ docker push rogeriocassares/hello-go:v5.3
```

k8s/deployment.yaml:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 1
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go:v5.3"
          envFrom:
            - configMapRef:
                name: goserver-env
            - secretRef:
                name: goserver-secret

          volumeMounts:
            - mountPath: "/go/myfamily"
              name: config
              readOnly: true

      volumes:
        - name: config
          configMap:
            name: configmap-family
            items:
              - key: members
                path: "family.txt"
```

Aplicando `Deployment`:
```bash
❯ kubectl apply -f k8s/deployment.yaml 
deployment.apps/goserver configured

❯ kubectl get po
NAME                       READY   STATUS    RESTARTS   AGE
goserver-df7547bb9-9w57h   1/1     Running   0          26s
```

Nesse caso, o `Pod` continua rodando pois a aplicação do k8s não sabe que ela está com problema!

Realizando o `port-foeward`:
```bash
❯ kubectl port-forward svc/goserver-service 9000:8080
Forwarding from 127.0.0.1:9000 -> 8000
Forwarding from [::1]:9000 -> 8000
```

E acessando a aplicação http://localhost:9000/healthz, percebe-se que, agora, há um erro no console do navegador!
```bash
Failed to load resource: the server responded with a status of 500 (Internal Server Error)
```

Aqui entra o `liveness probe`. Ele será executado de tempos em tempos para verificar se a aplicação está saudável.

Então, há um problema: um `endpoint` para verificar esse problema mas ainda assim o k8s não sabe dessa existência, pois para ele o container está rodando, então permite funcionar!

### Liveness na prática

Para usar os próprios recursos do k8s com o `liveness probe`, deve ser configurado o arquivo `deployment.yaml`, na parte do container usando a porta do container e não do service.

k8s/deployment.yaml:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 1
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go:v5.3"
          livenessProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 5
            failureThreshold: 1
            timeoutSeconds: 1
            successThreshold: 1

          envFrom:
            - configMapRef:
                name: goserver-env
            - secretRef:
                name: goserver-secret

          volumeMounts:
            - mountPath: "/go/myfamily"
              name: config
              readOnly: true

      volumes:
        - name: config
          configMap:
            name: configmap-family
            items:
              - key: members
                path: "family.txt"
```

Dentro do `liveness probe`, existem 3 tipos pricipais. `HTTP`, `COMMAND` e `TCP`.

Geralmente o mais utilizado e a parte do `HTTP`.

Alguns testes podem ser feitos para também testar coisas mais integradas. Ao invés de ser apenas a aplicação, pode ser a integração com o banco de dados. Nesse caso, um sistema integrado pode ser mais conservador e colocar um valor de`timeoutSconds` maior. Apenas a aplicação deve responder bem rápido.

O parâmetro successThreshold server para configurar quantas vezes o teste tem que passar para dar certo e pode-se verificar essa aplicação de maneira online com o comando `watch`:
```bash
❯ kubectl apply -f k8s/deployment.yaml&& watch -n1 kubectl get po
deployment.apps/goserver configured

Every 1,0s: kubectl get po                        rogerio-pc: Thu Jul 28 11:16:45 2022

NAME                        READY   STATUS    RESTARTS   AGE
goserver-7869cb67f7-p2qx7   1/1     Running   0          33s
```

Percebe-se que após 50 segundos, o container já foi reiniciado 2 vezes por causa da configurações que havia sido feita no `Deployment`:
```bash
Every 1,0s: kubectl get po                        rogerio-pc: Thu Jul 28 11:17:24 2022

NAME                        READY   STATUS    RESTARTS      AGE
goserver-7869cb67f7-p2qx7   1/1     Running   2 (11s ago)   72
```

Agora ao alterar o `failureThresold` para `3`, significa que precisa testar 3 vezes pelo menos antes de reinciar o container.

k8s/deployment.yaml:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 1
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go:v5.3"
          livenessProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 5
            failureThreshold: 3
            timeoutSeconds: 1
            successThreshold: 1

          envFrom:
            - configMapRef:
                name: goserver-env
            - secretRef:
                name: goserver-secret

          volumeMounts:
            - mountPath: "/go/myfamily"
              name: config
              readOnly: true

      volumes:
        - name: config
          configMap:
            name: configmap-family
            items:
              - key: members
                path: "family.txt"
```

Para testar:
```bash
Every 1,0s: kubectl get po                        rogerio-pc: Thu Jul 28 11:28:53 2022

NAME                        READY   STATUS    RESTARTS      AGE
goserver-6dc5fc9dc5-g7whd   1/1     Running   1 (17s ago)   58s
```

Funcionou! Entao o `liveness probe` tenta 3 vezes para reiniciar o container.

Para usar esse recurso, não há segredo, mas esse recurso em conjunto com outros pode se tornar um pouco mais complexo.

Se for desejável verificar o histórico de testar do container, pode-se pedir para descrever o `Pod`:
```bash
❯ kubectl get po   
NAME                        READY   STATUS    RESTARTS       AGE
goserver-6dc5fc9dc5-g7whd   1/1     Running   6 (107s ago)   5m53s

❯ kubectl describe po goserver-6dc5fc9dc5-g7whd
Name:         goserver-6dc5fc9dc5-g7whd
Namespace:    default
Priority:     0
Node:         k3d-fullcycle-server-0/192.168.96.2
Start Time:   Thu, 28 Jul 2022 11:27:56 -0300
Labels:       app=goserver
              pod-template-hash=6dc5fc9dc5
Annotations:  <none>
Status:       Running
IP:           10.42.0.132
IPs:
  IP:           10.42.0.132
Controlled By:  ReplicaSet/goserver-6dc5fc9dc5
Containers:
  goserver:
    Container ID:   containerd://ad3ffe74e6e3dde37e21be2ac13a8e56b465191af447ca87dbc0cbc5a8e85d73
    Image:          rogeriocassares/hello-go:v5.3
    Image ID:       docker.io/rogeriocassares/hello-go@sha256:5cf03363ba6784f729b800bb7e32a357c8acf9a4b56811424519152ee1ab1bad
    Port:           <none>
    Host Port:      <none>
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       Error
      Exit Code:    2
      Started:      Thu, 28 Jul 2022 11:33:35 -0300
      Finished:     Thu, 28 Jul 2022 11:34:11 -0300
    Ready:          False
    Restart Count:  6
    Liveness:       http-get http://:8000/healthz delay=0s timeout=1s period=5s #success=1 #failure=3
    Environment Variables from:
      goserver-env     ConfigMap  Optional: false
      goserver-secret  Secret     Optional: false
    Environment:       <none>
    Mounts:
      /go/myfamily from config (ro)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-crxvr (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             False 
  ContainersReady   False 
  PodScheduled      True 
Volumes:
  config:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      configmap-family
    Optional:  false
  kube-api-access-crxvr:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason     Age                    From               Message
  ----     ------     ----                   ----               -------
  Normal   Scheduled  7m29s                  default-scheduler  Successfully assigned default/goserver-6dc5fc9dc5-g7whd to k3d-fullcycle-server-0
  Normal   Pulled     7m26s                  kubelet            Successfully pulled image "rogeriocassares/hello-go:v5.3" in 3.437009418s
  Normal   Pulled     6m47s                  kubelet            Successfully pulled image "rogeriocassares/hello-go:v5.3" in 1.896422462s
  Normal   Pulled     6m7s                   kubelet            Successfully pulled image "rogeriocassares/hello-go:v5.3" in 2.055890405s
  Normal   Created    6m7s (x3 over 7m26s)   kubelet            Created container goserver
  Normal   Started    6m7s (x3 over 7m25s)   kubelet            Started container goserver
  Warning  Unhealthy  5m29s (x9 over 6m59s)  kubelet            Liveness probe failed: HTTP probe failed with statuscode: 500
  Normal   Killing    5m29s (x3 over 6m49s)  kubelet            Container goserver failed liveness probe, will be restarted
  Normal   Pulling    5m29s (x4 over 7m29s)  kubelet            Pulling image "rogeriocassares/hello-go:v5.3"
  Warning  BackOff    2m20s (x7 over 3m24s)  kubelet            Back-off restarting failed container
```

Percebe-se que a `liveness probe` falhou, deu um estado de `unhealthy` e subiu novamente.

### Entendendo Readiness Probe

O `Readiness Probe` verifica quando a aplicação está pronta para receber tráfego e é um dos pontos principais quando se desenvolve uma aplicação. Às vezes, no momento em que o container sobe a aplicação, ela pode não estar 100% pronta pois os processos ainda podem estar rodando, uma carga pode estar acontecendo, ele pode estar ainda subindo um monte de processos, pode ainda estar se conectando com o banco de dados etc. Pode estar acontecendo um monte de coisas que demora, como uma aplicação legada, enfim. Então percebe-se que não é possível mandar trafego para uma aplicação que ainda não se encontra pronta. Por isso há o `readiness probe`.

O `readiness probe` verifica se a aplicação está pronta. E como executar?

Modificando o arquivo `server.go` para que se a duração da aplicação for menor que 10, isto é, pelo menos 10 segundos para iniciar, vai dar problema falando que aplicação ainda não se encontra pronta. Enquanto isso, não se deseja que o tráfego seja enviado para a aplicação.

server.go:
```go
package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"time"
)

var startedAt = time.Now()

func main() {
	http.HandleFunc("/healthz", Healthz)
	http.HandleFunc("/secret", Secret)
	http.HandleFunc("/configmap", ConfigMap)
	http.HandleFunc("/", Hello)
	http.ListenAndServe(":8000", nil)
}

func Hello(w http.ResponseWriter, r *http.Request) {
	name := os.Getenv("NAME")
	age := os.Getenv("AGE")
	fmt.Fprintf(w, "Hello, I am %s. I am %s.", name, age)
}

func Secret(w http.ResponseWriter, r *http.Request) {
	user := os.Getenv("USER")
	password := os.Getenv("PASSWORD")
	fmt.Fprintf(w, "User: %s. Paswword: %s.", user, password)
}

func ConfigMap(w http.ResponseWriter, r *http.Request) {

	data, err := ioutil.ReadFile("/go/myfamily/family.txt")
	if err != nil {
		log.Fatalf("Error reading file: ", err)
	}
	fmt.Fprintf(w, "My family: %s.", string(data))
}

func Healthz(w http.ResponseWriter, r *http.Request) {

	duration := time.Since(startedAt)

	if duration.Seconds() < 10 {
		w.WriteHeader(500)
		w.Write([]byte(fmt.Sprintf("Duration: %v", duration.Seconds())))
	} else {
		w.WriteHeader(200)
		w.Write([]byte("ok"))
	}
}
```

Para o build e push:
```bash
❯ docker build -t rogeriocassares/hello-go:v5.4 .
❯ docker push rogeriocassares/hello-go:v5.4
```

E modificar o `Deployment`, comentando `liveness probe` e apenas verificar.

k8s/deployment.yaml:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 1
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go:v5.4"
          # livenessProbe:
          #   httpGet:
          #     path: /healthz
          #     port: 8000
          #   periodSeconds: 5
          #   failureThreshold: 3
          #   timeoutSeconds: 1
          #   successThreshold: 1

          envFrom:
            - configMapRef:
                name: goserver-env
            - secretRef:
                name: goserver-secret

          volumeMounts:
            - mountPath: "/go/myfamily"
              name: config
              readOnly: true

      volumes:
        - name: config
          configMap:
            name: configmap-family
            items:
              - key: members
                path: "family.txt"

```

Aplicando e verificando o `Deployment`:
```bash
❯ kubectl apply -f k8s/deployment.yaml&& watch -n1 kubectl get po
```

Aqui, mesmo que a aplicação ainda não esteja pronta, o tráfego já está sendo enviado para a ela e isso não pode acontecer.

O próximo passp é deletar o `Deployment` e aplicar de novo com um `port-forward` para verificar como a aplicação ainda nao está pronta:
```bash
❯ kubectl delete deploy goserver
deployment.apps "goserver" deleted

❯ kubectl apply -f k8s/deployment.yaml               

❯ kubectl port-forward svc/goserver-service 9000:8080
```

Acessando http://localhost:9000/healthz, vê-se que o ok aparece apenas após os 10 segundos, indicando que a aplicação está funcionando, mas o desejo é que as pessoas apenas acessem a aplicação quando ela estiver pronta! Por conta isso existe o `readiness probe`.

O `readiness probe` faz exatamente o que o `liveness probe` faz, mas voltado fazer a verificação que a aplicação está pronta. O `readiness` também realizará a consulta na porta `8000` conforme o tempo determinado e pode ser configurado para a frequência de problemas como se detectar apenas uma vez, significando que a aplicação ainda não está pronta. Dessa forma, o parâmetro `failureThreshold` já sabemos que é `1`, e o timeout `periodSeconds`, por default também é `1`.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 1
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go:v5.4"
          readinessProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 3
            failureThreshold: 3

          # livenessProbe:
          #   httpGet:
          #     path: /healthz
          #     port: 8000
          #   periodSeconds: 5
          #   failureThreshold: 3
          #   timeoutSeconds: 1
          #   successThreshold: 1

          envFrom:
            - configMapRef:
                name: goserver-env
            - secretRef:
                name: goserver-secret

          volumeMounts:
            - mountPath: "/go/myfamily"
              name: config
              readOnly: true

      volumes:
        - name: config
          configMap:
            name: configmap-family
            items:
              - key: members
                path: "family.txt"
```

Para aplicar e verificar:
```bash
❯ kubectl apply -f k8s/deployment.yaml&& watch -n1 kubectl get po

Every 1,0s: kubectl get po                        rogerio-pc: Thu Jul 28 12:49:53 2022

NAME                        READY   STATUS    RESTARTS   AGE
goserver-8f445fcd8-j949n    1/1     Running   0          6m33s
goserver-6b4f59b7d4-vjlm6   0/1     Running   0          5s
```

Mesmo após criado, o `Pod` ainda não está `Ready`, mas após os 3 + 3 + 3 + 3 segundos ele passa a subir:
```bash
Every 1,0s: kubectl get po                        rogerio-pc: Thu Jul 28 12:50:13 2022

NAME                        READY   STATUS    RESTARTS   AGE
goserver-6b4f59b7d4-vjlm6   1/1     Running   0          24s
```

Portanto, o `readines`s espera até que o container esteja pronto para começar a mandar o tráfego! Enquanto isso não acontecer, significa que o `Pod` ainda não está pronto.

Uma outra coisa muito importante é perceber que o `Pod` anterior ainda estava disponível até que o novo estivesse pronto para que pudesse ser terminado e a aplicação não ter `downtime`.Essa forma é como o k8s trabalha.

Nesse caso, sabe-se que a aplicação demora pelo menos 10 segundos para ficar pronta. Então não é necessário ficar pedindo que nesses 10 segundos iniciais o k8s fique enviando tráfego para a aplicação porque não adianta.

Uma opção que também funciona para o `liveness` é o `intitialDelaySeconds`, que é um offset de tempo para começar a verificar. Então o periodo que o k8s vai começar a fazer as requisições vai ser apenas esse `initialDelaySeconds`.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 1
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go:v5.4"
          readinessProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 3
            failureThreshold: 1
            initialDelaySeconds: 10

          # livenessProbe:
          #   httpGet:
          #     path: /healthz
          #     port: 8000
          #   periodSeconds: 5
          #   failureThreshold: 3
          #   timeoutSeconds: 1
          #   successThreshold: 1

          envFrom:
            - configMapRef:
                name: goserver-env
            - secretRef:
                name: goserver-secret

          volumeMounts:
            - mountPath: "/go/myfamily"
              name: config
              readOnly: true

      volumes:
        - name: config
          configMap:
            name: configmap-family
            items:
              - key: members
                path: "family.txt"
```

Ao aplicar e verificar:
```bash
❯ kubectl apply -f k8s/deployment.yaml&& watch -n1 kubectl get po

Every 1,0s: kubectl get po                        rogerio-pc: Thu Jul 28 13:04:30 2022

NAME                        READY   STATUS    RESTARTS   AGE
goserver-6b4f59b7d4-vjlm6   1/1     Running   0          14m
goserver-f44f9df49-qg6zt    0/1     Running   0          5s
```

Após uns 13 ou 14 segundos ele sobe normalmente.
```bash
Every 1,0s: kubectl get po                        rogerio-pc: Thu Jul 28 13:04:58 2022

NAME                       READY   STATUS    RESTARTS   AGE
goserver-f44f9df49-qg6zt   1/1     Running   0          33s
```

Funcionou! Basta esperar um pouquinho para começar a subir as `probes`!


### Combinando Liveness e Readiness Probes

Descomentando a parte de `livenessProbe` no `yaml`, deve-se agguardar 10 segundos para o `readiness` finalizar e o `liveness` verificar o processo a cada 5 segundos e, pensando em reiniciar o processo toda a vez que der um erro: `failureThreshold: 1`.

k8s/deployment.yaml:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 1
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go:v5.4"
          readinessProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 3
            failureThreshold: 1
            initialDelaySeconds: 10

          livenessProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 5
            failureThreshold: 1
            timeoutSeconds: 1
            successThreshold: 1

          envFrom:
            - configMapRef:
                name: goserver-env
            - secretRef:
                name: goserver-secret

          volumeMounts:
            - mountPath: "/go/myfamily"
              name: config
              readOnly: true

      volumes:
        - name: config
          configMap:
            name: configmap-family
            items:
              - key: members
                path: "family.txt"
```

Aplicando o `Deployment` e observando-o:
```bash
Every 1,0s: kubectl get po                        rogerio-pc: Thu Jul 28 14:33:03 2022

NAME                        READY   STATUS             RESTARTS     AGE
goserver-f44f9df49-qg6zt    1/1     Running            0            88m
goserver-78d5d7b499-lmrxj   0/1     CrashLoopBackOff   2 (9s ago)   24s
```

O que acontece aqui é o seguinte: O container fica reinciando sem parar e gera um monte de problemas. Depois de um tempo em `running`, ele aguarda ficar pronto mas reinicia de novo!

Isso acontece porque o `readiness` tem que aguardar 10 seundos para garantir que o container está pronto e então o container só vai ficar pronto `READY 1/1` quando receber essa resposta do `readiness`, que funcionou.

O `liveness` vai verificar a cada 5 segundos se o container está no ar. Se não estiver, ele reinicia.

Nesse caso, não deu nem tempo do `readiness` realmente ficar pronto que ele já reiniciou o container através do `liveness`.

Então toda vez que está para o readiness ficar pronto, o `liveness` vai lá e reinicia o container, matando o container e subindo de novo.

Por isso, é preciso sempre ter em mente que o `readiness` tem que funcionar em algum momento, porque se ele não funcionar, o `liveness` vai reiniciar o container e o `readiness` nunca vai ficar pronto. Esse é um ponto extremamanete importante para se prestar atenção!

A primeira coisa, seria adicionar um `initialDelaySeconds` também no `livenessProbe`. Porque o `liveness` só iria começar a contar após os 10 segundos e provavelmente teria tempo para o `readiness` ficar pronto.

O `readiness` testa de 3 em 3 segundos. E o `liveness` testa a cada 5 segundos. Mas quando ficar pronto, ambos vão testar ao mesmo tempo. Para ver se vai dar tempo de um `readiness` ficar pronto para o `liveness` poder testar, deve ser aplicaddo o `Deployment` descrito abaixo:

k8s/deployment.yaml:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 1
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go:v5.4"
          readinessProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 3
            failureThreshold: 1
            initialDelaySeconds: 10

          livenessProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 5
            failureThreshold: 1
            timeoutSeconds: 1
            successThreshold: 1
            initialDelaySeconds: 10

          envFrom:
            - configMapRef:
                name: goserver-env
            - secretRef:
                name: goserver-secret

          volumeMounts:
            - mountPath: "/go/myfamily"
              name: config
              readOnly: true

      volumes:
        - name: config
          configMap:
            name: configmap-family
            items:
              - key: members
                path: "family.txt"
```

Ao aplicar o `Deployment`:
```bash
Every 1,0s: kubectl get po                        rogerio-pc: Thu Jul 28 15:03:29 2022

NAME                       READY   STATUS    RESTARTS   AGE
goserver-f44f9df49-qg6zt   1/1     Running   0          119m
goserver-c7b4666f8-bfh4t   0/1     Running   0          7s
```

E funcionou!
```bash
Every 1,0s: kubectl get po                        rogerio-pc: Thu Jul 28 15:05:09 2022

NAME                       READY   STATUS    RESTARTS      AGE
goserver-c7b4666f8-bfh4t   1/1     Running   4 (66s ago)   107s
```

Outra coisa, é o `readiness` não verifica apenas na inicialização do container. Ele fica a cada 3 segundos verificando se o container está `READY` mesmo após ter sido iniciado. Ele não quer ver se está `live`, mas `READY`. Se não estiver `READY` ele desvia o tráfego enquanto o `liveness` tenta reinciar.

Portanto, o `readiness` tira o tráfego fora; o `liveness` recria o processo. 

Verificando o `server.go`, demora-se 10 segundos para subir a aplicação. Mas para testar mais algumas coisas, foi realizada uma modificação para que quando a aplicação ficar mais de 30 segundos no ar, ela também apresente um erro.

inicio (10segundos) -> READY (+20) -> Erro (aplicaão não funcionando corretamente)

```go
package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"time"
)

var startedAt = time.Now()

func main() {
	http.HandleFunc("/healthz", Healthz)
	http.HandleFunc("/secret", Secret)
	http.HandleFunc("/configmap", ConfigMap)
	http.HandleFunc("/", Hello)
	http.ListenAndServe(":8000", nil)
}

func Hello(w http.ResponseWriter, r *http.Request) {
	name := os.Getenv("NAME")
	age := os.Getenv("AGE")
	fmt.Fprintf(w, "Hello, I am %s. I am %s.", name, age)
}

func Secret(w http.ResponseWriter, r *http.Request) {
	user := os.Getenv("USER")
	password := os.Getenv("PASSWORD")
	fmt.Fprintf(w, "User: %s. Paswword: %s.", user, password)
}

func ConfigMap(w http.ResponseWriter, r *http.Request) {

	data, err := ioutil.ReadFile("/go/myfamily/family.txt")
	if err != nil {
		log.Fatalf("Error reading file: ", err)
	}
	fmt.Fprintf(w, "My family: %s.", string(data))
}

func Healthz(w http.ResponseWriter, r *http.Request) {

	duration := time.Since(startedAt)

	if duration.Seconds() < 10 || duration.Seconds() > 30 {
		w.WriteHeader(500)
		w.Write([]byte(fmt.Sprintf("Duration: %v", duration.Seconds())))
	} else {
		w.WriteHeader(200)
		w.Write([]byte("ok"))
	}
}
```

Para buildar, e realizar o push da nova imagem:
```bash
❯ docker build -t rogeriocassares/hello-go:v5.5 .
❯ docker push rogeriocassares/hello-go:v5.5      
```

Para subir o `readiness` sozinho:

k8s/deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 1
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go:v5.5"
          readinessProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 3
            failureThreshold: 1
            initialDelaySeconds: 10

          # livenessProbe:
          #   httpGet:
          #     path: /healthz
          #     port: 8000
          #   periodSeconds: 5
          #   failureThreshold: 1
          #   timeoutSeconds: 1
          #   successThreshold: 1
          #   initialDelaySeconds: 10

          envFrom:
            - configMapRef:
                name: goserver-env
            - secretRef:
                name: goserver-secret

          volumeMounts:
            - mountPath: "/go/myfamily"
              name: config
              readOnly: true

      volumes:
        - name: config
          configMap:
            name: configmap-family
            items:
              - key: members
                path: "family.txt"
```

Ao aplicar o `deployment` e observar, nota-se que o comportamento que se espera é que demore cerca de 14 segundos para a aplicação ficar `READY` após ter sido verificada pelo `readiness`, depois de 30 segundos, o k8s vai verificar que a imagem está fora pois a aplicação deu erro e o `Pod` vai ficar com o status `NOT READY`!
```bash
❯ kubectl apply -f k8s/deployment.yaml&& watch -n1 kubectl get po

Every 1,0s: kubectl get po                        rogerio-pc: Thu Jul 28 17:46:06 2022

NAME                        READY   STATUS    RESTARTS   AGE
goserver-57755dc668-5wbl4   0/1     Running   0          2m30s
```

Ou seja, o `Pod` está rodando mas so tráfego não está sendo enviado para ele nesse momento. porque o `readiness` ainda não o permitiu! 

Nesse caso, para voltar a funcionar, o `liveness` é quem reinicia o Container.

Então, enquando o `readiness` verifica o Container e desabilita-o, o `liveness` verifica que está fora e reinicia para habilitá-lo novamemte.

Nesse momento, ao reativar o `liveness` e pode ser observado o que deve vai acontcer.

k8s/deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 1
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go:v5.5"
          readinessProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 3
            failureThreshold: 1
            initialDelaySeconds: 10

          livenessProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 5
            failureThreshold: 1
            timeoutSeconds: 1
            successThreshold: 1
            initialDelaySeconds: 10

          envFrom:
            - configMapRef:
                name: goserver-env
            - secretRef:
                name: goserver-secret

          volumeMounts:
            - mountPath: "/go/myfamily"
              name: config
              readOnly: true

      volumes:
        - name: config
          configMap:
            name: configmap-family
            items:
              - key: members
                path: "family.txt"
```

Aplicando o `deployment` e observando:
```bash
❯ kubectl apply -f k8s/deployment.yaml&& watch -n1 kubectl get po
deployment.apps/goserver configured
```

O que aconteceu foi o seguinte: a aplicação demorou 10 segundos para subir e então o `readiness` habilitou o status com `READY`. Depois de 30 segundos, a aplicação começou a dar um erro `500` novamente, ambos perceberam que estava fora do ar, e o `readiness` parou o `Pod`, deixando ele como `NOT READY`.

O `liveness` ficou observando que não existia nada na requisição e reiniciou o container que, após 10 segundos, ficou como `READY` pelo `readiness` e eles não estão conseguindo se reconciliar pois cada um tem uma taxa de intervalo!

Provavelmente, deve-se aumentar o tempo de inicialização do `liveness` para que, quando reiniciar o container, exista tempo para o `readiness` subi-lo no ar!

k8s/deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 1
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go:v5.5"
          readinessProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 3
            failureThreshold: 1
            initialDelaySeconds: 10

          livenessProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 5
            failureThreshold: 1
            timeoutSeconds: 1
            successThreshold: 1
            initialDelaySeconds: 15

          envFrom:
            - configMapRef:
                name: goserver-env
            - secretRef:
                name: goserver-secret

          volumeMounts:
            - mountPath: "/go/myfamily"
              name: config
              readOnly: true

      volumes:
        - name: config
          configMap:
            name: configmap-family
            items:
              - key: members
                path: "family.txt"
```

E aplicando o `deployment` e observando-o:
```bash
❯ kubectl apply -f k8s/deployment.yaml&& watch -n1 kubectl get po
```

Nota-se `READY` após 10s, `NOT READY` após 33 segundos, e reinciado; após 45 segundos, `READY` novamente!

E quando não se sabe quanto tempo demora a aplicação? 10s, 20s, um minuto etc? Há uma variação muito grande! 

E se demorar um minuto para subir a aplicação e ela subir em 10 segundos?

Seria necessário esperar mais 50 segundos até um novo ciclo acontecer para enviar o tráfego para a aplicação.


### Trabalhando com o startupProbe

O `startupProbe` surgiu a partir da versão `1.6` do k8s e auxilia no trade-off entre o `livesness` e o `readiness`.

O `startupProbe` funciona como se fosse o `readiness` mas somente no processo de inicialização.

O `startupProbe` fica fazendo a verificação até ele ficar pronto. Quando ele ficou pronto, aí sim o `readiness` e o `liveness` começam a contar. Então não há mais o problema inicial citado anteriormente.

Nesse caso, tem que se tomar cuidado principalmente com uma coisa: desde o início pode-se até colocar um `initialDelay`. De acordo com o `periodSceconds`, a cada 3 segundos ele vai tentar fazer o processo de verificação com o `failureThreshold` de `1`. Entao, a cada 3 segundos ele vai fazer a verificação e o `starttuProbe` vai parar e o container nunca vai ficar pronto.

Se for colocafo um treshold de `10`, significa que a cada 3 segunos ele vai tentar uma vez, durante 10 vezes. Ou seja, ele vai tentar pelo menos por 30 segundos. É só a partir desse tempo que o `liveness` e o `readiness` são liberados para começarem a operar.

E isso é o mais interessante, porque se a aplicação demora até dois minutos ou mais para funcioonar, o `startupProbe` vai ficar perguntando se a aplicação está pronta ou não. Assim que estiver pronto ele já libera!

No caso de utilizar o `startupProbe`, o `initialDelaySeconds` pode ser removido do `liveness` e do `readiness` pois o próprio `startupProbe` já verificou se a aplicação está pronta para rodar.

k8s/deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 1
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go:v5.5"
          startupProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 3
            failureThreshold: 1
            # initialDelaySeconds: 10

          readinessProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 3
            failureThreshold: 1
            # initialDelaySeconds: 10

          livenessProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 5
            failureThreshold: 1
            timeoutSeconds: 1
            successThreshold: 1
            # initialDelaySeconds: 15

          envFrom:
            - configMapRef:
                name: goserver-env
            - secretRef:
                name: goserver-secret

          volumeMounts:
            - mountPath: "/go/myfamily"
              name: config
              readOnly: true

      volumes:
        - name: config
          configMap:
            name: configmap-family
            items:
              - key: members
                path: "family.txt"
```

Ao aplicar o deployment e verificar:
```bash
❯ kubectl apply -f k8s/deployment.yaml&& watch -n1 kubectl get po
```

Nesse momento, o container deve estar funcionando tranquilamente e provavelemte haverá o problema após os 30 segundos que não vai ficar mais pronto por causa do `readiness` e o `liveness` vai reiniciar o container.

Agora, startup será até os 90 segundos. Assim que ele testar que a aplicação ficou pronta, ele vai novamente liberar para o `readiness` e para o `liveness` novamente.

O `startup` verifica se está tudo ok, 
O `readiness` tira isso do trafego
O `liveness` reinicia o container
O `startup` verifica se está tudo ok para iniciar o processo e quando tiver ele libera o tráfego novamente para a aplicação.

Ẽ SEMPRE RECOMENDADO USAR `STARTUP PROBE` PORQUE ELE Ẽ QUEM VAI FALAR A PARTIR DE QUANDO O `LIVENESS` E O `READINESS` PODERÁ SER UTILIZADO. A DOCUMENTAÇÃO DO K8S TEM MUITOS DETALHES!


## Resources e HPA

### Instalando o metrics -server

Com o k8s sempre é possível aumentar a quantidade de réplicas e `Pods`. Mas para que aumentar? Quanto de consumo e recursos cada `Pod` vai consumir?

Quantos para escalar? E se um sistema tiver muito mais consumo que outro. Como isso funciona?

Quando se trabalha com Nuvem, há o `autoscaling` das instâncias de acordo com o consumo de recursos. Mas e se os limites que devem atingr para começcar a escalar não for conhecido?

Para isso, existe o HPA - HORIZONTAL PODS AUTOSCALE e ele é utilizado com o `metrics-server`, que coleta as métricas em tempo real de quanto de recurso cada `Pod` está consumindo em determinado momento.

Essas informações são importantes para tomar decisões. Inclusive, uma coisa muito comum para fazer isso é o Prometheus. que gera um dashboard no Grafana.

Normalmente com k8s na nuvem (gereniado), esse `metrics-server` jã vem instalado default.

Por padrão, o `metric-server` exige uma conexão segura entre todos os clusters e ele é escalável até `5000` nodes no k8s. Para isso, é preciso trabalar com TLS. Mas o grande ponto é que isso será feito com um bypass no TLS para executar em ambientes de `dev`.

Para acessar o repositorio do k8s `metrics-server`: https://github.com/kubernetes-sigs/metrics-server

Na documentação, ele prevê um `deployment` padrão, mas ainda é necessãria uma configuração para que ele funcione no k3d para devOps.

Vamos baixar esse arquivos para o diretório do k8s:
```bash
❯ cd k8s
❯ wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

Foi realizadoo download do arquivo `components.yaml`:

k8s/components.yaml
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    k8s-app: metrics-server
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    rbac.authorization.k8s.io/aggregate-to-view: "true"
  name: system:aggregated-metrics-reader
rules:
- apiGroups:
  - metrics.k8s.io
  resources:
  - pods
  - nodes
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    k8s-app: metrics-server
  name: system:metrics-server
rules:
- apiGroups:
  - ""
  resources:
  - nodes/metrics
  verbs:
  - get
- apiGroups:
  - ""
  resources:
  - pods
  - nodes
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server-auth-reader
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: extension-apiserver-authentication-reader
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server:system:auth-delegator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: system:metrics-server
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:metrics-server
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: v1
kind: Service
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
spec:
  ports:
  - name: https
    port: 443
    protocol: TCP
    targetPort: https
  selector:
    k8s-app: metrics-server
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: metrics-server
  strategy:
    rollingUpdate:
      maxUnavailable: 0
  template:
    metadata:
      labels:
        k8s-app: metrics-server
    spec:
      containers:
      - args:
        - --cert-dir=/tmp
        - --secure-port=4443
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-use-node-status-port
        - --metric-resolution=15s
        image: k8s.gcr.io/metrics-server/metrics-server:v0.6.1
        imagePullPolicy: IfNotPresent
        livenessProbe:
          failureThreshold: 3
          httpGet:
            path: /livez
            port: https
            scheme: HTTPS
          periodSeconds: 10
        name: metrics-server
        ports:
        - containerPort: 4443
          name: https
          protocol: TCP
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /readyz
            port: https
            scheme: HTTPS
          initialDelaySeconds: 20
          periodSeconds: 10
        resources:
          requests:
            cpu: 100m
            memory: 200Mi
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000
        volumeMounts:
        - mountPath: /tmp
          name: tmp-dir
      nodeSelector:
        kubernetes.io/os: linux
      priorityClassName: system-cluster-critical
      serviceAccountName: metrics-server
      volumes:
      - emptyDir: {}
        name: tmp-dir
---
apiVersion: apiregistration.k8s.io/v1
kind: APIService
metadata:
  labels:
    k8s-app: metrics-server
  name: v1beta1.metrics.k8s.io
spec:
  group: metrics.k8s.io
  groupPriorityMinimum: 100
  insecureSkipTLSVerify: true
  service:
    name: metrics-server
    namespace: kube-system
  version: v1beta1
  versionPriority: 100
```

E entao renomeá-lo para `metric-server.yaml`.

No campo `deployment` desse arquivo, ele passa alguns argumentos ao criar o container.

k8s/components.yaml
```yaml
containers:
      - args:
        - --cert-dir=/tmp
        - --secure-port=4443
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-use-node-status-port
        - --metric-resolution=15s
```

Um dos argumentps necessários para passar é o `--kubectl-insecure-tls`:

k8s/components.yaml
```yaml
containers:
      - args:
        - --cert-dir=/tmp
        - --secure-port=4443
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-use-node-status-port
        - --metric-resolution=15s
        - --kubelet-insecure-tls
```

Agora, ele vai permitir rodar como TLS inseguro para precisar trabalhar com o TLS

Para aplicar o `metrics-server`:
```bash
❯ cd ../
❯ kubectl apply -f k8s/metric-server.yaml                                                        
serviceaccount/metrics-server unchanged
clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader unchanged
clusterrole.rbac.authorization.k8s.io/system:metrics-server unchanged
rolebinding.rbac.authorization.k8s.io/metrics-server-auth-reader unchanged
clusterrolebinding.rbac.authorization.k8s.io/metrics-server:system:auth-delegator unchanged
clusterrolebinding.rbac.authorization.k8s.io/system:metrics-server unchanged
service/metrics-server unchanged
deployment.apps/metrics-server configured
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io unchanged
```

E como saber que o `metric-server` esta funcionando?

O k8s tem algo chamado de `kubectl get apiservices`, que mostra todos os serviços disponíveis na API e pode-se observar o `kube-system/metrics-server`, que é exatamente o serviço para verificar se está tudo ok e se a coluna `AVAILABLE` estiver `True` significa que a instalação deu tudo certo:
```bash
❯ kubectl get apiservices
NAME                                   SERVICE                      AVAILABLE   AGE
v1.admissionregistration.k8s.io        Local                        True        30d
v1.apps                                Local                        True        30d
v1.authentication.k8s.io               Local                        True        30d
v1.                                    Local                        True        30d
v1.apiextensions.k8s.io                Local                        True        30d
v1.authorization.k8s.io                Local                        True        30d
v1.autoscaling                         Local                        True        30d
v2.autoscaling                         Local                        True        30d
v2beta1.autoscaling                    Local                        True        30d
v2beta2.autoscaling                    Local                        True        30d
v1.batch                               Local                        True        30d
v1beta1.batch                          Local                        True        30d
v1.certificates.k8s.io                 Local                        True        30d
v1.coordination.k8s.io                 Local                        True        30d
v1beta1.discovery.k8s.io               Local                        True        30d
v1.discovery.k8s.io                    Local                        True        30d
v1beta1.events.k8s.io                  Local                        True        30d
v1.events.k8s.io                       Local                        True        30d
v1beta1.flowcontrol.apiserver.k8s.io   Local                        True        30d
v1beta2.flowcontrol.apiserver.k8s.io   Local                        True        30d
v1.networking.k8s.io                   Local                        True        30d
v1.node.k8s.io                         Local                        True        30d
v1beta1.node.k8s.io                    Local                        True        30d
v1.policy                              Local                        True        30d
v1beta1.policy                         Local                        True        30d
v1.rbac.authorization.k8s.io           Local                        True        30d
v1.scheduling.k8s.io                   Local                        True        30d
v1.storage.k8s.io                      Local                        True        30d
v1beta1.storage.k8s.io                 Local                        True        30d
v1.k3s.cattle.io                       Local                        True        3h41m
v1alpha1.traefik.containo.us           Local                        True        3h41m
v1.helm.cattle.io                      Local                        True        3h41m
v1beta1.metrics.k8s.io                 kube-system/metrics-server   True        21s
```

E foi! Agora, está tudo pronto para o próximo passo e trabalhar com a aplicação com gerenciamento de recursos, fazer escalonamento automático e muito mais!



### Entendendo a utilização de Resources

Apos o metric server funcionando, vamos enntender o seguinte conceito  para utilizarmos em qualquer Pod que subirmos no k8s. Se nao usarmos isso, O Pod pode começcar a consumir todos os recursos do node/clustere ehpor conta disso que recisamos configurar os recursos do nossosistema. O quanto cada pod precisa para rodar e ateh onde é o limite que permitimos ele consumir os recursos dos nossos nodes. 

No arquivo deploymen.yaml, vamos adicionar, antes da startuProbe, a tag resources:

As requsets siginifica o quanto que o sistema que estamos trabalhando exige comoo mĩnimo para funcionar. As vezes vamos usar um sistema com s requisitos minimos necessarios para funcionar tanto em termos de cpu e memoria.

CPU tem uma unidade de medida e chamamos de vCPU. A CPU possui 1000 milicores. Ou seja, o quanto se consegue usar de uma CPU. Podemos falar que a aplicação exisge 500m, Isso significa metade de uma vCPU inteira! Entao podemos utilizar essaunidade de medida ou em porcentagem, como 0.5, por exemplo. 



Nesse caso, vamosutilizar 100m para funcionar. Quanto à memoria, estamos precisando utilziar 20MB de memõria. E como chgamos nesses numeros?

Nao tem como chegarmos nesses numeros sem testarmos. Precisamos fazer benchmarks e testes de stress para chegarmos no melhor numero possivel aqui!

Vamos falar disso tb!

POrtanto os valores aqui aplicados é o MÍNIMO que a aplicação precisa para rodar. Quando configuramos este valor, estamos "sequestrando"/RESERVANDOestes recursos donosso cluster para o nosso Pod.

Entao quando falamos que precisamos de 100milicires, o Pod vai pegar qual node que o cluster tem que disponiblize esses 100m, Entao vai ficar reservado para tal POd de acordo com o Scheduler do k8s. 

E se colocarmos um valor absurdo e nao ivermos máquina/recuro o suficiente no cluster para esse processo? Entao quando esse pod for criado ele vai ficar como pendente, esperando o tempo todo algum node/maquina teraquela capacidade para ele poder provisionar.

Quando falamosde minimo, ele vai reservar nosistemaentao ninuem pode modificar ou utilizar o espaço jã reservado no sistema.



o LImits, é at~w onde o Pod pode utilizar de recursos no cluster. Nesse caso, colcoamsoo minimo de 100m, mas as vezes vamos trer um pico de acesso e /ou a aplicação vai cair quando acessarmos muito esse cara.

Apesar de já termos reservado 100m, até onde deixamos esse cara consumir no servidor? Se deixarmos ateh 500m, quando esse Pod começar a receber requisiçao ele vai ter garantido 100m, mas com muitos acesos, ele pode chegar até 500m. Mais que isso, ele nao vai usar nem vai ter perigo de derrubar outros recursos que estao acontencendo.

DISCLAIMER!

A NOSSA MÁQUINA/CLUSTER É FINITO E TEMOS UM NUMERO DE RECURSOS. IMAGINA QUE TEOMOS 3VCPUS E PARA A APLCIACAO FUNCIONAR COM 100m, ENTAO PODEROAMOS UTILIZAR 300 Pods que vai funcionar pq temos recursos. Maso nosso limite é 500m. Entao se pegarmos esse 500m, e multiplicar pela quantidade de vCPUS que temos, percebemos que ele vai estourar abruptamente. Entao aquivimos que o que reservamos de minimo ele tem recursos para utilizar, mas o limite que chegamos, se todos trabalharem no limite, a nossa maquina nao terá recusrsos para segurar. Entao a dica é sempretentar evitar que A SOMA DE TODOS OS LIMITES ULTRAPASSE A QUANTIDADE DISPONIVEL DE RECURSOS NO NOSSO CLUSTER. Mesmo que esses limites nao sejam utilizados ao mesmo tempo, entao vamos gastar dinheiro para comprar mais maquinas e a máquina vai ficar ociosa pq nao estamos sempre no limite, entao, esse cao, vamos apostar mais umenos como overbooking. Vender mais passagens que cabe no voo pq acreditamos quenem todo mundo vai comparecere se comparecer fazemos um sorteio ara alguem deisitir e entao resolve-se o problema.

Pode-se tentarpegar uma média e deixamos que a soma doslimites vao o mãximo em tanto para podermos ter algo seguro e equilibrio enteconsumo de máquina, ociosidade e a utilização. Entao temos um limite de CPU que podesubir e descer.

Já no caso da memoria, nao eh tao parecido pq memõria ẽ algo bem fixo. Nao podemos passar de tanto limite, pq cpu as vezes consegumos estourar um pouquinho para amis ou para menos e a máquina consegue resolver asituação. Jã namemória essa situação nao pode ser resolvida tao facilmente pq memoria é algo que é muito limitada. Nao conseguimos passar um pouqinho mais em relaçao aquela parte da memoria.Aqui vamoscolocar o minimo de 20 e max de 25.

Lembrando que se tivermos 10 replicas dessa aplicaçao, vamos estar consumindo NO MÍNIMO 1 vCPU e no máx, 5vCPUscaso tudo estoureo limite. Entao em nossa máquina operando no max, deveriamos tr 5vCPUs apenas para essa aplicação, fora o restante que deve ser consumido pelo OS do k8s, pelo master, pelo scheduler,pelos controles, pelos kubeletes, dns, etc que o k8s utiliza.

Agora vamoacriar e ajustar e vamos ver o consumo que ele está fazendo.

deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 1
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go:v5.5"

          resources:
            requests:
              cpu: "0.3"
              memory: 20Mi
            limits:
              cpu: "0.3"
              memory: 25Mi

          startupProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 30
            failureThreshold: 1
            # initialDelaySeconds: 10

          readinessProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 3
            failureThreshold: 1
            # initialDelaySeconds: 10

          livenessProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 5
            failureThreshold: 1
            timeoutSeconds: 1
            successThreshold: 1
            # initialDelaySeconds: 15

          envFrom:
            - configMapRef:
                name: goserver-env
            - secretRef:
                name: goserver-secret

          volumeMounts:
            - mountPath: "/go/myfamily"
              name: config
              readOnly: true

      volumes:
        - name: config
          configMap:
            name: configmap-family
            items:
              - key: members
                path: "family.txt"

```



### Aplicando deploment om resources

Vamos aplicar o arquivo de deployment

```bash
❯ kubectl apply -f k8s/deployment.yaml 
deployment.apps/goserver configured

❯ kubectl get po
NAME                        READY   STATUS    RESTARTS      AGE
goserver-5f949ccff9-pgbs6   1/1     Running   1 (29s ago)   64s
```





Agora que esta funcionando, uma das alternativas para vermos ele funcionando é o kubectl top com o nome do Pod.

```bash
❯ kubectl top pod goserver-5f949ccff9-pgbs6
NAME                        CPU(cores)   MEMORY(bytes)   
goserver-5f949ccff9-pgbs6   0m           1Mi 
```

Entao aqui ele vai mostrar como esta o nosso consumo e como ele esta em relacao à parte de memória.

Agora que temos essa opção conosco, vamos perceber que se começarmos a utilizar muito esse Pod, ele vai chegar no limite e vai começar a usar todo esse limite, nao vai mais conseguir servir as requisições e entao vai engasgar o nosso serviço e acontecer como em qualquer outra máquina.

Logo, uma vez que fazemos isso, estamos delimitando e para podermos escalar, basta, nesse caso, criarmos mais replicas!

A partir de agora estamos prontos para poder criarmos mais replias e conforme criamos mais replicas, e começamos a acessar os services, o k8s vai cmeçar a fazer o balanceamento de carga para que tenhamos uma distribuição mas igual para trabalharmos commais pods para suportar todos os acessos, mas mesmo assim limitando o uso de recursos dentrodo nosso CLuster!

## Criando e configurando um HPA

Afinal, como fazemos para escalar?

O HPA (hORIZONTAL POD AUTOSCALING) é o responsável por pegar aquelas metricas , verificando como está o trafego e como esta a cpu e memória. E baseado no estado de CPU ele vai começar a provisionar novas replicas para podermos trabalhar.

Isso é'muuuuito importante!

O HPA nao usa apenas a CPU como ponto de escala ou nao. Podemos utilizar mais metricxas ao mesmo tempo. Inclusive metricas customizadas. Por outro lado isso vai depender muito do tipo de aplicação e na maioria das vezes apenas o hpa de cpu vai funcionar.

Se algum dia precisamos de outra metrica para escalar que nao seja o hpa de cpu, bastra acessar a documentaçao do k8s.

Vamos ver agora como utilizar o hpa para nos auxiliar nos aspectos de escala!

Criamos um novo arquivo chamado hpa.yaml:

````yaml
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: goserver-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    name: goserver
    kind: Deployment
  minReplicas: 1
  maxReplicas: 5
  targetCPUUtilizationPercentage: 30
````



Vamos aplicar o arquivo:

````bash
❯ kubectl apply -f k8s/hpa.yaml 
horizontalpodautoscaler.autoscaling/goserver-hpa created
````

Pronto! Agora vamos verificar o hpa

````bash
❯ kubectl get hpa
NAME           REFERENCE             TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
goserver-hpa   Deployment/goserver   <unknown>/30%   1         5         1          88s
````

Agora, temos como referencia o Deployment/goserver e o target temos como 30% para começar a agir. Porem, nesse momento o valor de cpu utilizado esta como desconhecido. 

Como acabamos de criar, o k8s ainda demora de 1 a 2 minutos para conseguir criar as métricas no metric server.

````bash
❯ kubectl get hpa
NAME           REFERENCE             TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
goserver-hpa   Deployment/goserver   0%/30%    1         5         1          3m26s
````



Executando novamente o comando, agora já'estamois conseguindo pegar as metricas e nesse momento estamos utilizando 0% de cpu.



No proximo video, vamos usar uma ferramente para fazer o teste de estresse para acessar a aplicaçáo e verificar o hpa funcionado!



## Versao da imagem para o teste de stress

Na aula "Teste de stress com fortio" a imagem que está sendo utilizada é a rogeriocassares/hello-go:v9.7
que é diferente da versão v5.5 usada no deployment.yaml da aula "Aplicando deployment com resources".

O que muda é que na versão 5.5 o código do server.go gerava erro após 30 segundos de execução no pod.
Na versão 9.7 este erro após 30 segundos é removido e o teste de stress funcionará normalmente.

Versão 5.5 (rogeriocassares/hello-go:5.5)

````go
func Healthz(w http.ResponseWriter, r *http.Request) {
  duration := time.Since(startedAt)

  if duration.Seconds() < 10 || duration.Seconds() > 30 {
    w.WriteHeader(500)
    w.Write([]byte(fmt.Sprintf("Duration: %v", duration.Seconds())))
  } else {
    w.WriteHeader(200)
    w.Write([]byte("ok"))
  }
}
````



Na versão 9.7 (rogeriocassares/hello-go:v9.7)

````go
func Healthz(w http.ResponseWriter, r *http.Request) {
  duration := time.Since(startedAt)

  if duration.Seconds() < 10 {
    w.WriteHeader(500)
    w.Write([]byte(fmt.Sprintf("Duration: %v", duration.Seconds())))
  } else {
    w.WriteHeader(200)
    w.Write([]byte("ok"))
  }
}
````



Build uma nova imagem Dockerfile e push to the Docker Hub!

````bash
❯ docker build -t rogeriocassares/hello-go:v9.7 .
❯ docker push rogeriocassares/hello-go:v9.7
````



Portanto, para que você consiga acompanhar a aula "Teste de stress com fortio", utilize a
imagem `rogeriocassares/hello-go:v9.7 no deployment.yaml`.

````yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 1
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go:v9.7"

          resources:
            requests:
              cpu: "0.3"
              memory: 20Mi
            limits:
              cpu: "0.3"
              memory: 25Mi

          startupProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 30
            failureThreshold: 1
            # initialDelaySeconds: 10

          readinessProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 3
            failureThreshold: 1
            # initialDelaySeconds: 10

          livenessProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 5
            failureThreshold: 1
            timeoutSeconds: 1
            successThreshold: 1
            # initialDelaySeconds: 15

          envFrom:
            - configMapRef:
                name: goserver-env
            - secretRef:
                name: goserver-secret

          volumeMounts:
            - mountPath: "/go/myfamily"
              name: config
              readOnly: true

      volumes:
        - name: config
          configMap:
            name: configmap-family
            items:
              - key: members
                path: "family.txt"

````

Aplique agora o novo deployment.yaml

````bash
❯ kubectl apply -f k8s/deployment.yaml 
````



## Atualização no comando do Fortio

Com a atualização do kubectl para a versão 1.21, o parâmetro --generator do comando

````bash
kubectl run -it --generator=run-pod/v1 fortio --rm --image=fortio/fortio -- load -qps 800 -t 120s -c 70 "http://goserver-service:8080/healthz"
````


passou a não ser mais suportado, apresentando o erro "Error: unknown flag: --generator".

Para a realização do teste, execute o comando sem este parâmetro, ficando da seguinte maneira:

````bash
$ kubectl run -it fortio --rm --image=fortio/fortio -- load -qps 800 -t 120s -c 70 "http://goserver-service:8080/healthz"
````


Com isto, será possível ver os pods escalando no teste de stress.



## Teste de stress com Fortio

Essa ferramenta é uma ferramena em go e nos ajuda a passar parametros e cria threads para fazer o acesso, a quantidade de queries por segundo, a quantidade de tempo qque queremos executar e a url que queremos trabalhar vamnos ver funcionand o.

O fortio tb tem uma imagem docker. Entao vamos criar um pod do fortio e quando esse pode for criado vamos pedir para ele gerar um teste de stress e tudo isso via comando para vermos como conseguomos executar uma operaçáo usando um pod e quando terminamos essa opereçao, ele mata o pod automaticamente. 

Vamos rodar um pod do kubernets via terminal como se fosse um docker! Vamos rodar um pod no terminal e remover a imagem assim que ele acabar e essa imagem virá do docker hub fortio/fortio.

````bash
❯ kubectl run -it fortio --rm --image=fortio/fortio -- load -qps 800 -t 120s -c 70 "http://goserver-service:8080/healthz"
````

Entao criamos uma nova aba no terminal e digitamos

````bash
 ❯ watch -n1 kubectl get hpa
 ----
 Every 1,0s: kubectl get hpa                            rogerio-pc: Wed Nov 16 15:46:10 2022

NAME           REFERENCE             TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
goserver-hpa   Deployment/goserver   6%/30%    1         5         1          65m
````

Dessa forma podemos perceber que, apesar de muitos acessos, o uso da CPU nao passou de 20%, e por isso nao conseguimos ver o hpa escalar para outros Pods.

Entao, vamos siminuir o valor de cpu por request no arquivo de `deployments.yaml` de 0.3 para 0.05 de cpu.

````yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 1
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go:v9.7"

          resources:
            requests:
              cpu: "0.05"
              memory: 20Mi
            limits:
              cpu: "0.05"
              memory: 25Mi

          startupProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 30
            failureThreshold: 1
            # initialDelaySeconds: 10

          readinessProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 3
            failureThreshold: 1
            # initialDelaySeconds: 10

          livenessProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 5
            failureThreshold: 1
            timeoutSeconds: 1
            successThreshold: 1
            # initialDelaySeconds: 15

          envFrom:
            - configMapRef:
                name: goserver-env
            - secretRef:
                name: goserver-secret

          volumeMounts:
            - mountPath: "/go/myfamily"
              name: config
              readOnly: true

      volumes:
        - name: config
          configMap:
            name: configmap-family
            items:
              - key: members
                path: "family.txt"

````



E entao aplucamos novamentre o arquivo de deployment:

````bash
❯ kubectl apply -f k8s/deployment.yaml
````

Para conseguirmos visualizar o hpa funcionando

````bash
❯ kubectl run -it fortio --rm --image=fortio/fortio -- load -qps 800 -t 120s -c 70 "http://goserver-service:8080/healthz"
````



Entao, se vericarmos novamente o `kubectl get hpa`

````bash
❯ kubectl get hpa
----
NAME           REFERENCE             TARGETS
   MINPODS   MAXPODS   REPLICAS   AGE
goserver-hpa   Deployment/goserver   92%/30%
   1         5         4          80m
   
````

Vemos que foram criados 4 Pods com autoscaling!

`````bàsh
❯ kubectl get po
----
NAME                        READY   STATUS    RESTARTS   AGE
goserver-7fdf7d7865-7zzmj   1/1     Running   0          10m
fortio                      1/1     Running   0          2m11s
goserver-7fdf7d7865-6z4qm   1/1     Running   0          94s
goserver-7fdf7d7865-vzvmr   1/1     Running   0          64s
goserver-7fdf7d7865-klgwg   1/1     Running   0          64s
`````



Para descer as replicas, o kubectl espera um determinado tempo para diminuir.

Também é interessante usilizar uma ferramenta chamada k6.io para fazer teste de stress, pq da [ara fazer visita de varias paginas, pausar e etc.

Vamos fazer ainda um otro deste e configurar o nosso hpa para até 30 pods:

````yaml
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: goserver-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    name: goserver
    kind: Deployment
  minReplicas: 1
  maxReplicas: 30
  targetCPUUtilizationPercentage: 25
````

Aplicando o novo arquivo:

````bash
❯ kubectl apply -f k8s/hpa.yaml 
````

E entao executamos em um terminal co comando 

````bash
❯  watch -n1 kubectl get hpa
````

e no outro o teste de estresse por 220s:

````bash
❯ kubectl run -it fortio --rm --image=fortio/fortio -- load -qps 800 -t 220s -c 70 "http://goserver-service:8080/healthz"
````



Após um tempo, vimos que o hpa ultrapassou o limite de 25% de CPU e copmeçou a criar novas replicas do Pod. 

````bash
Every 1,0s: kubectl get hpa                     rogerio-pc: Wed Nov 16 16:15:41 2022

NAME           REFERENCE             TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
goserver-hpa   Deployment/goserver   34%/25%   1         30        4          94m


Every 1,0s: kubectl get hpa                     rogerio-pc: Wed Nov 16 16:17:05 2022

NAME           REFERENCE             TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
goserver-hpa   Deployment/goserver   26%/25%   1         30        4          95m

````

Pronto! Lembrando que há a espera inicial de 10 segundos para os Pods ficarem prontos! E 4 pods com 5 miliCores de cpu deram conta do recado!



## Statefulsets e Volumes Persistentes

### Entendendo volumes persistentes

Tudo o que fizemos até agora foi deploy  e escala de aplicaçáo que era totralemte stateless. Isto é, uma aplicaçao sem estado e nao interessa quantas vezes as requisiçoes acontecem que as sesspes nao estao guardadas na aplicaçáo.

Mandamos requeste e recebemos response. Ao criar e remover pods os dados nao sao perdidos pois sao stateless. Nao ha problemas em perder dados.

Por outrop lado, existem aplicaóés que desejamos persistior dados em nossas aplicaóés como o caesso a um DB. Conforme as operaçoes vao acaontecendo elas vao lendo e acessando. O porblema eh que se o pod for perdido, vamos perder os dados como a remoçao de um container.\



Para isso temos um volume, que permite que montemos uma pasta dentro do nosso container e conforme vamos escrevendo nela ele vai escrevendo para um armazenamento em disco.

Com o k8s tb é totalmente psossivel fazermos isso e escrevermos em disco na amazon, no azure, e tudo mais. Mas uma oiutra coisa muito interessante que faalaremos, é em relaçáo a volumes persistentes.

Quando trabalhamos com nuvem, temos algo chamado como pool de storage.

Vamos imageniar que criuamos um pool de storage de 1TB e deixamos disponivel para o nosso cluster k8s.

Entao quando quisermos subir uma apolicaçáo e criar um hd para guardar dados, podemos fazer uma Claim de 50GB para guardar um pouco de nossos dados, disponiblizando do 1TB, 50GB solicitado.

Quando trabalhamos com volumes persistenmntes no k8s sempre teremos 2 opçoes:

Uma parte estatica e uma parte dinamica.

A parte estática é quando é criada um pool de storage para a aplicaçáo ou varios pools de storage e solicitamos uma parte desse storage e entao se disponibliza um determinado espaço. Essa é a forma mais utilizada quando se trabalha com onPremises.

Quando trabalaha-se mais com nuvem, existe algo chamado de StorageClass. Ela é uma especifica;cao que faz com que se tengha um ndriver para que,m dinamcamente se consiga provisionar volumes, espaçoes em disco para uma determianda aplicaçáo.



Vamos imageniar que agora temos uma StorageClass da AWS configurada no nosso k8s. Entao todas as vezes que eu precisar de um volume persistente, faremos uma Claim e, automaticamente a Claim vai chamar a StorageClass e a StorageClass vai disponibilizar o espaço que precisamos (BlockStorage na AWS) por exemplo. 

Claim --> StorageClass --> Dsiponibilizar o espaço --> BlockStorage

Entao, o modelo estático é quando já deixamos defindo um monte de blocos (pool de storage) definiddos e entao fazemos uma solicitaçáo. Ou temos uma opçáo de criarmos uma StorageClass e ela, para cada vcez que fizermos uma solicitaçáo, essa StorageClass fala com o driver/tipo de disco/ rede que esta configurado para disponibilizar aquele pedaço para nós. 

Todas as vezes que o Wesley trabalhou com k8s em prod, uma vez que tb ele sempre utiliza serviços gerenciados, sempre foi atraves de StorageClass e nunca atraves de um formato estático.

Como que criariamos um pool de volumes? Vamos criar para fins de testes.

Crie um arquivo pv.yaml (persistent volume):

````bash
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv1
spec:
  capacity:
    storage: 50Gi
  accessModes:
    - ReadWriteOnce

````



Com isso, criamos um volume persistente , isto é, teremos um espaço de volume persistente disponiblizado., Depois criamso uma Claim para solicitar um pedaço do volume persistente.

Se trabalhamos com StorageClass por padrao, nao precisamos disso pois o StorageClass vai gerar dinamicamente os pedaços de espaço que estamos pedindo. 

Normalmente quando fazemos esse tipo de coisa, podemos acrescentar um epaço como local-device que vai pegar um espaço que está'disponiblizado no disco do nosso node para utilizar como volume persistente, por exemplo

````yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv1
spec:
  capacity:
    storage: 50Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: local-device
````



A grande questao nao eh essa, mas que temnos duas formas de trabalhar: estática onde o es[aço já'está criado e definido (apenas requisitamos um espaço para a nossa aplicaçáo) e a dinamica que consiste em um StoageClass que sabe como vai funcionar e tem as credenciais para obter o pedaço de espaço que precisamos ali para ele.



Agora, o grande ponto é'o seguinte. De acord com o tipo de Storage que temos, temos o tipo de acesso (AccessMode). 

Dentre os AccessModes, temos o ReadWriteOnce/Many/Only. Qual a diferença entre todos eles?

O acesso a disco é algo extremamente copmplexo.

Imaginemos que temos 3 Pods acessando um disco de 50GB dentro de um Node1. Por enquanto nao há'nenhum problema para leitrura e etc.

O grande problema é que se tivermos o Pod3 no Node2, teriamos que ser aptos a gravar em um Volume em um Node a partir de um Volume que está em outro Node! Como sabemos que o arquivo que vamos querer gravar nao está sendo usado? Teremos que dar um lock nesse arquivo? Fica dficil.



O tipo de acesso mais comum de ser utilizado é o ReadWriteOnde, que significa que podemos gravar, ler, desde que estejam,os dentro do mesmo Node. Entao os Pods que estao dentro do mesmo Node do Volume podem ler e Gravar dentro desse mesmo Node. 

Existem alguns formatos de storage que permitem que psosamos ler e gravar em diferentes Nodes acessando. Mas sao outros sistemas de arquivos. 

Existe uma tabela no site do k8s que explica para cada Volume Pluginm, o tipo de acesso que podemos ter:

https://kubernetes.io/docs/concepts/storage/persistent-volumes/



Se algum dos plugins permitirem todos os tipos, a performance cai bastante pois tem que ter lock e um monte de outros tipos de controle.

E por isso o ReadWriteOnce é o mais comum de acontecer.



Portanto aqui temos duas opçoes: Criar antecipadamente o volume que queremos para o cluster e conforme os Pods vao subindo eles vao solicitando  esses volumes que devem ser disponiblizados.

Na maioria das vexes, vamos criar um Persistent Volume Claim.

No proximo topico, saberemos qual storageClass é criada por padrao no kind/k3d  e como muda de acordo com o clud provider e faremos alguns exemplos.



### Criando Volumes persistentes e montando

Vamos executar o seguinte comando:

````bash
❯ kubectl get storageclass
NAME                   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  118d
````

Com esse comando vemos que o storageClass padrao aqui é o rancher.io/local-path. Esse local-path provalemente pega um pedaço em disco e disponibliza para que isso vire um volume persistente no k8s.

O garnde ponto é que isso sempre muda de provedor para provedor. Na digital ocean, por exemplo, o provedor é um do-block-storage.

Isso significa que todas as vezes que fizermos uma Claim, esse provedor vai ser chamado e muito provavelemente ele tem uma interface com o armazenamento da Digital Ocean que deve gerar um disco lá'dentro.

No kind ou k3d, est;a gerando um local. Mas na nuvem, vai ser gerado um novo volume dentro de cada Nuvem.

Como consegfuimos fazer testes e entao verificar os volumes que estao rodando? Vamos duplicar o squivo de pv.yaml que fizemos anteriormente e chamá-lo de pvc (persistent volime claim), que faremos a solicitaçáo de que precisamos de um determinado volume!

pvc.yaml

````yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: goserver-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
````



Com isso, dizemos ao k8s que estamos solicitando (fazendo uma Claim) de um volume persistente cujo nome é goserver-pvc que possui um AccessMode de ReadWriteOnce em que solicitaremos 5GB de recurso para ele.

Vamos aplicar esse arquivo:

````bash
❯ kubectl apply -f k8s/pvc.yaml 
persistentvolumeclaim/goserver-pvc created
````

Pronto! Criamos. Vamos verificar:

````bash
NAME           STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
goserver-pvc   Pending                                      local-path     58s
````



Vemos que a nossa goserver-pvc está'pendente e foi criada! Nesse momento ela está'pendente pq ainda nao foi realizada uma conexao. 

Vamos ver:

````bash
❯ kubectl get storageclass
NAME                   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  118d
````



No comando acima podemos ver que o VolumeBindingMode está'com um estado de WaitForConsumer. Entao ao invés de ele já sair liberando e esperando, ele espera receber o bind para fazer a liberaçáo para nós.

Para fazer o bind devemos montar entao o nosso volume. 

Vamos no nosso arquivo de deployment.yaml e na parte de volumes, vamos colocar goserver-volume (aqui poderia ser qualquer outro nome). Em pesistentVolumeClaim -> ClaimName deve ser o goserver-pvc

Entao, aqui estamos criando um volume goserver-pvc que utiliza um persistentVolumeClaim que tem o nom de goserver-pvc . 

Além disso, é necessário ainda escrever em volumeMounts o mountPath correspondente

Logo, montaremos o goserver-volume no endereço "/go/pvc" e quando chamarmos o goserver-volume, ele vai chamas o clume to persistent volume claim goserver-pvc que acabamos por criar.

````yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 1
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go:v9.7"

          resources:
            requests:
              cpu: "0.05"
              memory: 20Mi
            limits:
              cpu: "0.05"
              memory: 25Mi

          startupProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 30
            failureThreshold: 1
            # initialDelaySeconds: 10

          readinessProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 3
            failureThreshold: 1
            # initialDelaySeconds: 10

          livenessProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 5
            failureThreshold: 1
            timeoutSeconds: 1
            successThreshold: 1
            # initialDelaySeconds: 15

          envFrom:
            - configMapRef:
                name: goserver-env
            - secretRef:
                name: goserver-secret

          volumeMounts:
            - mountPath: "/go/myfamily"
              name: config
              readOnly: true
            - mountPath: "/go/pvc"
              name: goserver-volume

      volumes:
        - name: goserver-volume
          persistentVolumeClaim:
            claimName: goserver-pvc

        - name: config
          configMap:
            name: configmap-family
            items:
              - key: members
                path: "family.txt"

````



Vamos agora atualizar o nosso deployment

````bash
❯ kubectl apply -f k8s/deployment.yaml 
deployment.apps/goserver configured
````

E agora, vamos ver como esta o nosso pvc:

````bash
❯ kubectl get pvc
NAME           STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
goserver-pvc   Bound    pvc-d667b579-d412-48d2-be0e-d5dd83d54ad2   5Gi        RWO            local-path     18m
````

Vemos que o goserver-pvc esta como bound com um certo id com a capacidade de 5GB como ReadWriteOnce!

Depois vamos discutir como faremos isso com aplicaçoes com Bando de Dados!

Nessa aplicaçáo goserver, apesar de ela ser stateless, estamos criuando um volume para podermos guardar qualquer coisa.



Agora, vamos pegar o nosso pod

````bahs
❯ kubectl get po
NAME                        READY   STATUS    RESTARTS   AGE
goserver-64695797bb-7rpg2   1/1     Running   0          3m47s
````

Vamos entrar nele e vemos que temos uma pasta denominada pvc!

````bash
❯ kubectl exec -it goserver-64695797bb-7rpg2 -- bash
root@goserver-64695797bb-7rpg2:/go# ls
bin  myfamily  pvc  server  server.go  src
````

Vamos entrar nessa pasta e criar um aquivo oi

````bash
root@goserver-64695797bb-7rpg2:/go# cd pvc/
root@goserver-64695797bb-7rpg2:/go/pvc# touch oi
root@goserver-64695797bb-7rpg2:/go/pvc# ls
oi
````

Vamos sair do Pod e removê-lo. Se esse diretório pvc nao estivesse dentro de um volume persistente, iriamos perder o aqruivo que criamos. 

````bash
root@goserver-64695797bb-7rpg2:/go/pvc# ^C
root@goserver-64695797bb-7rpg2:/go/pvc# exit
command terminated with exit code 130

❯ kubectl delete pod goserver-64695797bb-7rpg2
pod "goserver-64695797bb-7rpg2" deleted
````



Mas montamos esse volume de forma persistente entao o arquivo oi deve estar contido da mesma maneira dentro do Pod que criamos!

````bash
❯ kubectl get po
NAME                        READY   STATUS    RESTARTS   AGE
goserver-64695797bb-8gqxd   0/1     Running   0          12s

❯ kubectl exec -it goserver-64695797bb-8gqxd -- bash
root@goserver-64695797bb-8gqxd:/go# cat pvc/oi 
root@goserver-64695797bb-8gqxd:/go#
````

E lá está! Isso aconteceu pq estamos trabalhando com volumes no k8s! Entao se estamos trabalhando com uma aplicaçáo no k8s e essa aplicaçao nao pode perder inform,açoes em hipotese alguma, podemos criar um volume e mandar os dados serem guardados ali.

Lembrando que o AccessMode ''e de ReadWriteOnce. Isso significa que outros Pods que estiverem em outro Node nao conseguirao acessar necessariamente esse volume aqui!



### Entendendo Stateteless vs Stateful

Temos dois tipos basicos de aplica'coes: stateless e stateful

O grande ponto eh que as aplica'coes stateless nao precisa guardar estado ou informa'cao. Ela simplesmente recebe uma chamada, ela processa, consulta um banco de dados, uma api, retorna uma resposta e acabou.

Já uma aplicaçao stateful ela precisa manter estado e o dado. Se ela nao fizer isso nao tem como ela funcionar. A forma mais facil de entender uma aplicaçao stateful eh pensando em um banco de dados, por exemplo.

Agora, essa aplicaçáo deve ter um disco em nossa aplicaçáo. Entao tudo o que acontece no bancoi de ddados está conectado a um dusco.

Isso significa que se a aplicaçáo morrer, os dados nao serao perfifos pois estarao gravados em disco. e nisso podemos fazer exatamente como fizemos no exemplo anterior, Criamos um disco persistente, atachamos no deployment do MySQL e fiamos felizes.

Mas as vezes o MySQL nao funciona mais sozinho pois temos Nodes Slvaes do MYQL como em um cluster!

No final das contas, nessa topologia, todos vao gravar no Master e ler nos MySQL slaves.

Supondo que cada instancia do MYSQL seja um Pod, como sabemos qual será o Master/Slave? E o processo de carregamento? Primeiro o Master carrega e depois o Slvae. E depois que o Slave subiu ele vai carregar os dados do disco do master para sincronizar. E ai quando o Slave 1 estiver pronto o Slave 2 sobe e copia os dados do Slcvae 1 para todos os dados agora estarem sincronizados. Tudo isso é Pod!

Quando trabalhamos com deployment, temos uma regra NOME_DEPLOYMENT-NOME_REPLICA_SET-RANDOM.

eNTAO SE MANDARMOS SUBIR 3 REPLICAS DESSE POD, TODOS VAO SUBIR AO MESMO TEMPO. QUAL SERÁ'O MASTER E COMO SUBIREMOS UM DE CADA VEZ E SINCRONIZAMOS EM QUEM EH O MASTER? ESSE É UM GRANDE PROBLEMA!

Por isso, quando famos de uma aplicaçao stateful, precisamos que ela suba de forma ordenada. Nao da para fazermos isso com Pods! E o processo de downsizing é'pior ainda! Vamos ter que matar Pods. E se for o master?



Entao precisamos de um mecanismo que nos ajude nesse tipo de processo. Que façá essa escala horizontal mas que o faça baseado em determinada ordem!

Precisamos tambem de um mecanismo que quando desescalamos, removedo nodes, seja como uma pilha, de tras para frente.

Os nomes randomicos que o k8s gera para a gente nao funciona mais.

Por isso vamos trabalhar com statefulksets.

O Statefulsets é um objeto do k8s muito parecido com o deployment mas que ele tem essas nuancias que vaoi nos ajudar a criar os pods em determinadas areas, Nao serao mais randomicos mas seguirao um determinada ordem para conseguirmos trabalhar etc.



### Criando Statefulset

Vamos criar um arquivo chamado statefulset.yaml que subirá um mysql. Vamos fazer um teste e escrever, primeiramente a estrutura como um Deplyment:

````yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
spec:
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql
    
````

E vamos aplicá-lo

````bash
❯ kubectl apply -f k8s/statefulset.yaml 
deployment.apps/mysql created
````

E vamos ver os Pods criados

````bash
❯ kubectl get po
NAME                        READY   STATUS              RESTARTS       AGE
goserver-64695797bb-8gqxd   1/1     Running             1 (116m ago)   17h
mysql-94c4ddd88-rqc8s       0/1     ContainerCreating   0              36s
mysql-94c4ddd88-8pz2k       0/1     ContainerCreating   0              36s
mysql-94c4ddd88-wdpxt       0/1     ContainerCreating   0              36s

````

Ainda nao deu certo pq faltam passar as variaveis de ambiente.

````bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
spec:
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: root
````

Aplicando o aquivo ao k8s novamente:

````bash
❯ kubectl get po
NAME                        READY   STATUS    RESTARTS       AGE
goserver-64695797bb-8gqxd   1/1     Running   1 (121m ago)   17h
mysql-59f7587fc-mmd8f       1/1     Running   0              9s
mysql-59f7587fc-wtj8k       1/1     Running   0              7s
mysql-59f7587fc-xxxwm       1/1     Running   0              4s
````

Agora temos 3 containers/Pods rodando nosso Mysql. Qual deles seria o master? Nao conseguimos garantir a ordem e isso nos atrapalha muito!

Vamos deletar o deploy mysql que criamos!

````bash
❯ kubectl delete deploy mysql
deployment.apps "mysql" deleted
````

E mudar o tipo do yaml para StatefulSet. Todas as vezes que formos subir um StatefulSet precisamos tb colocar um serviceName. E todas as vezes que formos trabalhar com statefulSets vamos trabalhar com algo como headless service.

````yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: mysql-h
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: root
````

Vamos colocá-lo para rodar:

````bash
❯ kubectl apply -f k8s/statefulset.yaml 
statefulset.apps/mysql created
````

Pronto! Agora criamos um statedfulset e vamos ver o que esrta acontecendo.

````bash
❯ kubectl get po
NAME                        READY   STATUS    RESTARTS       AGE
goserver-64695797bb-8gqxd   1/1     Running   1 (152m ago)   18h
mysql-0                     1/1     Running   0              2m1s
mysql-1                     1/1     Running   0              20s
mysql-2                     1/1     Running   0              18s
````



Olha que legal! A partir de agora o statefulset já tem uma ordem para criaçao e nao eh mais randomico! Se quisermos entao criar, já é diferente, e se colocarmos para 8 replicas, ele vai criar em sequencia, um por vez e garante a nós a ordem de criaçao dos Pods! Isso é'muito importante pois precisamos ter nocao dessa ordem de criaçao quando estamos trabalhando com StatefulSet! E caso desejemos diminuir o numero de Pods, o proprio k8s vai começar a deletar os statefulsets Pods de tras para frente pq ele precisa dessa ordem sendo trabalhada e respeitada!

O mais interessante de tudo isso é'que como esses Pods sao statefuls, eles tem a orem de criaçao e de saida, temos que definir um DNS name para ele, que nesse caso chamamos de mysql-h que na verdade é um headless service que vai nos ajudar durante todo esse processo.



Caso desejassemos que a criaçao dos Statefulsets nao precisasse seguir uma sequencia de criaçáo e pudesse ser criada de forma paralela, basta adicionarmos a tag podManagementPolicy como parallel. Vamos testar isso com 8 replicas conforme o aquivo abaixo.

````yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: mysql-h
  podManagementPolicy: Parallel
  replicas: 8
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: root
````



Deletando o StatefulS e aplicando novamente o arquivo no nosso cluster

````bash
❯ kubectl delete statefulset mysql
statefulset.apps "mysql" deleted

❯ kubectl apply -f k8s/statefulset.yaml 
statefulset.apps/mysql created
````



Verificando os Pods:

````bash
❯ kubectl get po
NAME                        READY   STATUS              RESTARTS       AGE
goserver-64695797bb-8gqxd   1/1     Running             1 (165m ago)   18h
mysql-0                     0/1     ContainerCreating   0              53s
mysql-1                     0/1     ContainerCreating   0              53s
mysql-2                     0/1     ContainerCreating   0              53s
mysql-3                     0/1     ContainerCreating   0              53s
mysql-4                     0/1     ContainerCreating   0              53s
mysql-5                     0/1     ContainerCreating   0              53s
mysql-6                     0/1     ContainerCreating   0              53s
mysql-7                     0/1     ContainerCreating   0              53s
````

Podemos escalar os Pods tb via linha de comando!

````bash
❯ kubectl scale statefulset mysql --replicas=5
statefulset.apps/mysql scaled
````

Agora ele cria tudo em paralelo e nao fica esperando criar um ou outro. 

Nisso podemos controlar tb esse tipo de comportamento, apesar de que, na maioria das vezes, é'desejavel criar um após o outro!

````
❯ kubectl get po
NAME                        READY   STATUS    RESTARTS       AGE
goserver-64695797bb-8gqxd   1/1     Running   1 (169m ago)   18h
mysql-0                     1/1     Running   0              4m1s
mysql-3                     1/1     Running   0              4m1s
mysql-2                     1/1     Running   0              4m1s
mysql-4                     1/1     Running   0              4m1s
mysql-1                     1/1     Running   0              4m1s
````



### Criando headless serviceþ



Dentre os Pods que criamos do MYSQL, apenas o Pod Master vai realizar a grvaçáo no banco de dados. Os outros devem sewr de leitura. O problema é'que sabemos que quando estamos trabalhando com k8s e colocamos um Service no meio, o Servicxe e faz o load balancer. Imaginemmos que seja criado o MySQL Service. Todos que enviarem uma requisiçáo para o MySQL Service serao apontados para os Pods, mas apenas um deles pode escrever! Nesse caso, se quisessemos gravar precisariamos enviar oara o master e para leitura, apenas para os slaves.



Com isso, é'interessante que cada Pod tenha o seu respectivo Service. Entao gravaris no MySQL-0 e leriamos no MySQL-1 para frente.

Para fazermos isso, devemos utilizar o headless service. Ele basicamente é um servi;co que é'criado e forçámos ele a nao ter um IP interno dentro da aplica;cao e ele basicamente eh apenas um apontamento de DNS.

Isso significa que qiando criamos um headless service mandando MySQL Service master, ele apponta para o Service Master. Caso apontarmos para Mysql-h (headless) slave 1, ele vai apontar para o Slave 1. Nao tem um IP feito nele. Ele simplesmente é'um apontamento de DNS que o k8s faz internamente. Precisamos fazer isso para termos a possibilidade de escolher para qual Pod precisamos ir pq sabemos que cada Pod tem uma funçao diferente dentro do nosso processp pq eles sao StatefulSet! 

Portanto, ao invés de termos uma barreira (SERVICE) que ficaria balanceando essa carga, teremos no final um service para o master e um service para cada Node MySQL slave como apenas um apontamento via DNS, isto é, um headless service!

Vamos duplicar o arquivo de service.yaml e renomear para mysql-service-h.yaml (headless)

````bash
apiVersion: v1
kind: Service
metadata:
  name: mysql-h
spec:
  selector:
    app: mysql
  ports:
    - port: 3306
  clusterIP: None
````

Quando colocamos o clusterIP como None, o service sabe que nao vai trabalhar com IP para fazer as relaçoes, mas vai trabalhar com o DNS. Nesse ponto ele vai fal;ar: Como eu sei etao quais sao todos os Pods necessários para criar esse tipo de Headless Service? Ele vai fazer isso atraves do Service Name!

No arquivo de configurtaçao do StatefulSet, foi criado um serviceName! Entao esse serviceName do statefulSet deve ser identico ao nome do nosso serviço descrito em mysql-service-h.yaml

Logo, esse serviço vai resolver tudo o que precisamos via DNS, independente da quantidade de replicas que formos tendo. 



Lembrando: O serviceName do statefulSet tem que bater com o serviceName do service que estamos criando para ele. E o clusterIP tem que ser None. Baseado nisso, vamos conseguir o tao sonhado headless service!

Vamos deletar o statefulset do Mysql

````bash
❯ kubectl delete statefulset mysql
\statefulset.apps "mysql" deleted
````

E agora vamos apluicar o statefulset com algumas replicas 

````yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  replicas: 4
  serviceName: mysql-h
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: root
````

E aplicamos o novo arquivo 

````bash
❯ kubectl apply -f k8s/statefulset.yaml 
statefulset.apps/mysql created
````

E agora vcamos criar o nosso service headless

````bash
❯ kubectl apply -f k8s/mysql-service-h.yaml
service/mysql created
````



Pronto! Vamos ver na pratica o que isso esta acontecendo!

````bash
❯ kubectl get po                        
NAME                        READY   STATUS    RESTARTS        AGE
goserver-64695797bb-8gqxd   1/1     Running   4 (4h39m ago)   47h
mysql-0                     1/1     Running   0               5m9s
mysql-1                     1/1     Running   0               5m9s
mysql-2                     1/1     Running   0               5m9s
mysql-3                     1/1     Running   0               5m9s

````

Nesse caso temos o mysql-0 como o master. Entao se alguem quiser escrever alguma coisa deve se conectar no mysql-0 via DNS. 

Ao executarmos o comando de verificar os serviços, percebemos que temos o nosso mysql-h com CluserIp e batendo na porta 3306 na porta external.

````bash
❯ kubectl get svc                       
NAME               TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)          AGE
kubernetes         ClusterIP      10.43.0.1       <none>         443/TCP          120d
goserver-service   LoadBalancer   10.43.203.126   192.168.96.2   8080:30210/TCP   119d
mysql-h            ClusterIP      None            <none>         3306/TCP         110s
````



Uma vez que criamos esses statefulsets e eles estao sendo criados e o serviceName 'e o mysql-h, o matchlabesls ;e o app: mysql do statefulset que linka com o app: mysql do mysql-service-h.yaml, pors etc. Agora precisamos que quando vamos trabalhar com o service, ele gere inclusive o service de outros camaradas, eventualmente.

Basicamente, o que acontece agora 'e o seguinte: Todas as vezes em que precisarmos chamar o noisso Master ou qualquer coisa desse tipo, faremos o seguinte.



Vamos entrar dentro de um Pos para ficar mais facil e dar um ping no dns do servi'co que criamos!

 ````bash
 ❯ kubectl exec -it goserver-64695797bb-8gqxd -- bash
 root@goserver-64695797bb-8gqxd:/go# ping mysql-h
 PING mysql-h.default.svc.cluster.local (10.42.0.184) 56(84) bytes of data.
 64 bytes from mysql-1.mysql-h.default.svc.cluster.local (10.42.0.184): icmp_seq=1 ttl=64 time=0.137 ms
 64 bytes from mysql-1.mysql-h.default.svc.cluster.local (10.42.0.184): icmp_seq=2 ttl=64 time=0.059 ms
 64 bytes from mysql-1.mysql-h.default.svc.cluster.local (10.42.0.184): icmp_seq=3 ttl=64 time=0.055 ms
 ````

OLha só! Ele está caindo em mysql-1! Vamos ver agora para colocarmos no mysql-0.

````bash
root@goserver-64695797bb-8gqxd:/go# ping mysql-0.mysql-h
PING mysql-0.mysql-h.default.svc.cluster.local (10.42.0.183) 56(84) bytes of data.
64 bytes from mysql-0.mysql-h.default.svc.cluster.local (10.42.0.183): icmp_seq=1 ttl=64 time=0.158 ms
64 bytes from mysql-0.mysql-h.default.svc.cluster.local (10.42.0.183): icmp_seq=2 ttl=64 time=0.055 ms
64 bytes from mysql-0.mysql-h.default.svc.cluster.local (10.42.0.183): icmp_seq=3 ttl=64 time=0.060 ms
````

O que aconteceu aqui foi que, através desse serviço, baseado no nome, chamar o Pod quie queremos e isso é'o mais importante!

Entao com esse headless service, basta colcoarmos o nome do Pod que queremos chamar na frente ponto mysql-h e ele vi conseguir nos redirecionar exatamente para o Pod que estavamos querendo chegar!

Isso é incrivel pq basicamente estamos realizando apontamentos dinamicos de DNS sem a necessidade de termos algo por IP!

Agora para cada POD conseguimos chamar baseado nessa convençáo!

NOME_DO_POD.NOME_DO_SVC.NAMESPACE.svc.cluster.local

Logicamente o k8s deixa passarmos uma resoluçáo mais simples, a nao ser que tenhamos um outro namepace e entao temos que passar toda essa resoluçáo. 

Com isso, o k8s estabelece que se precisarmos falar com o master é mysql-0. Acima disso, sabemos que vamos conseguir falar com os outros Pods.

Essa ideia de conseguirmos trabalhar com statefulset e headless service sempre vai nos ajudar bastante.

O grande segredo mesmo é que o nome do servico em mysql-service-h, por exemplo, seja o mesmo nome do serviceName que está setado no statefulSet.yaml.



### Criando Volumes Dinamicamente com StatefulSet

Agora, o grande ponto é quie o nosso banco de dados vai precisar gravar os dados no banco. Vamos precisar de um volume persistente para que os dados fiquei guardados caso o Pod venha a morrer.

Entao aprendemos que podemos criar um PrsistentVolumeClaim, que entao vai gerar um volume e ele vaqi dar um bind com o nosso Pod e vai ficar tudo feliz. 

O grande ponto eh quem em alguns casos vamos querer criar um bamnco de dados por réplica. P;or exemplo, tem 4 mysql e além da aplicaçáo mysql vamos querer criar 5 voluimes persistentes para guardarmos os dados do nosso mysql. E isso nao vamos querer fazer manualmente pq quando formos querer escalar na mai nao vamos querer dizer com é um persistent volume claim que qeueremos fazer.

E se tivesse uma forma que todas as vezes que estivermos trabalhando com o Statefulset e quisermos aumentar a quantidade de replicas, automaticamewnte ele gera um novo volume persistente automaticamewnte?



Sim! Entao, ao invés de trabaltarmos no pv.yaml, basicamente o que faremos é um pedaço do template de pv,yaml dentro do template de statefulset.yaml.

E entao todas as vezes que criarmos uma nova réplica, novos olumes serao criados e atachados na nossa aplicação.



Basicamente, agora vamos criar uma área chamada volumeClaimTemplate no arquivo statefulset para ser utilizado todas as vezes que quisermos escalar uma nova replica nossa. E dentro da spec do container do mysql camos colocar o volumeMOunths com o caminho do lugar ondeos arquivos do mysql  que criamos ficam gravados e em name vamos colocar o nome do volume que colocamos no template.

Nesse momento entao queremos dizer que a todo o momento que criamos uma nova replica ele vai automaticamente criar uma claim para chamar um volume e vai atachar automaticamente esse volume para esse nosso detrerminado POd!

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  replicas: 4
  serviceName: mysql-h
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: root
          volumeMounts:
            - mountPath: /var/lib/mysql
              name: mysql-volume

  volumeClaimTemplates:
  - metadata:
      name: mysql-volume
    spec: 
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 5Gi

```



Vamos colcoarpara funcionar desde o começo

```bash
❯ kubectl delete statefulset mysql
statefulset.apps "mysql" deleted

❯ kubectl apply -f k8s/statefulset.yaml
statefulset.apps/mysql created
```

Podemosver aqui que os Pods foram criados.

```bash
❯ kubectl get po
NAME                        READY   STATUS    RESTARTS      AGE
goserver-64695797bb-8gqxd   1/1     Running   5 (26h ago)   3d3h
mysql-0                     1/1     Running   0             55m
mysql-1                     1/1     Running   0             55m
mysql-2                     1/1     Running   0             55m
mysql-3                     1/1     Running   0             55m
```



Mas como entao saberemos que o nosso volume foi criado? Nesse caso, vamos fazer o seguinte:

```bash
❯ kubectl get pvc
NAME                   STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
goserver-pvc           Bound    pvc-d667b579-d412-48d2-be0e-d5dd83d54ad2   5Gi        RWO            local-path     3d4h
mysql-volume-mysql-0   Bound    pvc-e40122d4-6fc3-4b28-acbe-c6ffcfb6e709   5Gi        RWO            local-path     57m
mysql-volume-mysql-1   Bound    pvc-dd85f32c-3791-4390-aba5-201912e75a7b   5Gi        RWO            local-path     56m
mysql-volume-mysql-2   Bound    pvc-005d8aff-d672-43db-8836-9aecc6b95a3b   5Gi        RWO            local-path     56m
mysql-volume-mysql-3   Bound    pvc-25c8cd32-590e-4b10-9b32-f32268d79ea0   5Gi        RWO            local-path     56m
```

O que temos acima sao os volumes que criamos baseados no mysql.

Nesse caso, ele criou um volume para cada Pod!

Agora vamos imaginar o seguinte. Que por algum motivo o Pod mysql-1 ẽ deletado. Oque acontece a partirde agora é que o Scheduler do k8s vai perceber que um pod nao mais existe e ele vai criar um outro e esse Volume 1 vai ser reatachado. O que aconteceu é que o volume nao foi apagado pois esta separado do POd!

Com isso conseguimos trabalhar de forma muito eficiente trabalhando com o statefulset.

POrtanto, basicamente conseguimos criar replicas de forma ordenada, matar service de forma ordenada, criar headless service para fazer a requisicao cai no serviço que desejamos e criartemplatesde volumes que a cada POd que eh criado ele gera um volume que atacha nesse emplate. E se caso viermos a atar um determinado POd o volume nao vai ser removido, mas assim que ele for recreiado ele reatacha no nosso volume!

Temos agora uma aplicaçcao mais que completa para trabalharcom aplicaçoes que precisam guardar dados, trabalhar com volumes persistentes, que precisam ter ordem de criacao e remçcao, contar com indice de identificaçao etc.



### Devo usarmeu banco de dados no kubernetes

A grabde pergunta ẽ se devemos guardar nosso db dentro k8s. Eh seguro?Eh rapido? O que devemos fazer?

Em relaçcao a parte de estrutura, o k8s tem diversos recursos para nos ajudar durante todo esse processo. 

O grande ponto eh que quando temos o nosso projeto pode ser interessante deixar o banco de dados fora do k8s.

Isso posto pois as aplicações ainda nao estao maduras o suficientes para serem escaladas ou para o limitese metricas! Banco de dados é algo muito complexo, principalmente se estamos ridando aplicações muito criticas!

Se temos um sistema simples e nao temos muita dor de cabeça, nao ha problema nenhum em colcoar dentro do k8s. Mas em uma aplicação critica, o banco de dados eh uma aplicaçcao tao tunavel e tao paralelo que o wesley tende a deixar o banco de dados fora do kubernetes.

A estrutura que ele trabalha hoje ele tem mysql postgres elasticsearch  e todos esses bancos de dados nao ficam dentro do seus cluster k8s. 

Ele usaserviços gerenciados pra ter paz pos sabe que esses serviços vao conseguir gerenciar melhor do que gerenciariamos no k8s por nao sermos especialistas. Podemos escolher um Amazon RDS ou GOgleCLoud Databases onde gerencia odbe tem zonas de disponibilidades, backups e etc. Ẽ algo tao critico que ele prefere deixar fora do k8s. Ele conhece pessoas que deixam dentro do k8s e esta tudo ok, ja trabalhou com db no k8s e nao teve problemas e etc. Mas ha uma recomendaçao pessoal principalmente se for um serviço muito critico. 

Isso nao significaque possamos ter um wordpress no nosso k8s em que deixamos o banco de dados rodando no k8s e tb o upload de arquivos com voumes persistens para o wp-content para colocarmos ali por exemplo.

Isso pq pode ser muito critico para misturar no k8s. Ẽ importante pensar nisso!

É sempreimportante tb nas clouds garantirmos que se esta fazendo um correo backup!



## Ingress

### VIsao Geral

Vimos que temos um tipo de service que o o LoadBalancer.Nesse serviço, especificamente geraumIP externo quando estamos rodando serviços gerenviaveis do k8s comoo GKE (Google)  o EKS (AWS) e o AKS (Azure). 

Agora vamos imaginar que estamos em uma arquitetura rodando microserviços e naquela arquietura temos 10 micrseriços para funcionar com acesso a Web. 

Intuitivamente colocariamos esses microsserviços para funionarem como LoadBalancer, vamos pegar o IP de cada um, confihurar o DNS e sermosfelizes.

Mas normalmente quando fazemos isso, ele vai gerar na nuvem um LOad Balancer e gerar um IP e isso tem custo! É aqula qhistoria que nao tem tanto sentido termos tantos LOaBalancers por serviço.

E é por conta disso que o k8s tem um serviço muito interessante que se chama Ingress, OINgress acaba sendo como o ponto unico de entrada na nossa aplicaao. Assim configuramos o Ingress e ele ẽ um Service LOadBalancer que vai ter um IP.

Vamos imaginar que tenhamos  10 serviços ali. ENtao todas as vezes que quisermos acessar qualquer um desses seriços vamos bater no IP do ingress. E ai baseado no hostname e no Path que a pessoa estã acessando, configuramos para que quando acesso via alguma URL vai para tal serviço ou .admin, manda para o serviço do adim; catalogo, manda para o serviço do caalogo ; busca.algumacoisa, manda para o microsserviço de busca. 

Portanto, o ingress acaba sendo o ponto unico de entrada e ele faz o roteamente nos serviços que queremos. Nesse caso ele acaba por lembrar uma API Gtaeway, que faz o roteamento das coisas tb. ELe tb lemra muito um Proxy reverso que pega a requisiçcao e roteia para onde quisermos.

N realizadade a grande sacada de se trabalhar como Ingress no k8s, ẽ que existe um contolador que ẽ o Ingress COntroler do nginx!

Entao podemos ter um nginx por baixo dos planos e ele vai receber as requisiçoese fazer os apontamentos (isso ẽ tranasparente quando usamos esse controlador do k8s).

Nesse capitulo vaos apredercomo instalar, como configurar e como fazemos isso do zero até configurarmos o DNSao vivo para conseguirmos colocarmos no ar!



### COnfigurando Aplicaçao no GKE

Primeiramente, vamos acessar o google compite plataform (GCP) e criar um cluster k8s com apenas uma maquina.

Acesse https://console.cloud.google.com/ e faça o login.

Clique em acessar o console e crie um projeto fullcycle-examples;

Depois vá em Kubernetes Engine e crie umcluster.

]AQUI EU NAO SEGUI EM DIANTE PARA NAO TER QUE GERAR CUSTOS]

Com a linha d comando instalada (gcloud), exevute o seguinte comando 

```bash
gcloud container clusters get-credentials cusros-fullcycle --zone us-central1-c --project fullcycle-examles
```

Com isso, o setup das credenciais foi realizado automaticamente.

Com o comando abaixo:

```bash
kubectl get nodes
```

Teremos o resultado dos Node queforam criados no GCP!

Nesse momento, a nossa mãquina estã atachada com o k8s do Google e nao mais do local.

Agora, vamos imaginar que estamos em nossa mãquina e queremos fazero deploy para um CLoud Provider. Ou estamos em um CLoud Provider e desejamos fazer um deploy para outro CLoud Provider.

Basta entao aplicarmos o diretorio onde estao localizados todos os nossos arquivos de manifest (yaml).

```bash
kubectl apply -f k8s/
```

E incrivelmente o kubectl vai aplicar todos os arquivos AUTOMATICAMENTE!!!

Aunicaque ee nao reconheceu foi a do kind, que foi feita para o server local mesmo. 

Equando dermos 

```bash
kubectl get po
```

Devemos ver todos os nossos POds sendo criados jã na nuvem!!! QUe incrivel isso!

Com apenasum comando jã está tudo la no ar!

Outra cosia que vamos precisar fazer tb é verificar os services. 

```bash
kubectl het svc
```

E podemos notar que pela primeira vez o EXTERNAL IP apareceu! Isso pq o serviço do goserver ẽ loadbalancer. Se tivessemos mais serviços, cada serviço iria gerar um External Ip e teriamos que pagar por cada um deles!

Se formos no nosso navegador e acessarmos esse External IP vemos que estã tudo funcionado apenas ridando os maifestos do k8s!



### Instalando o Ingress Nginx Controller

Existem diversosformasde trabalharmos com o Ingress e vamosutilizaro IngressNginx. Para fazer ainstalação existem diversas formas, mas vamos trabalhar agora com o Helm. 

Vamos digitar no GOogle  ingress nginx helm chart;

https://kubernetes.github.io/ingress-nginx/deploy/

Aqui vemos que podemos realizar a instalaçao de diversas maneiras, incluisive usando o KE (Google). 

Entao, o quepodemos fazer ẽescolher o nosso Cloud Provider e seguir o processo de instalação. A outra opçcao ehusando Helm, Mas quando formos colcoar em produçao, é muiti importante que façamos a insalaçao de acordo com cada CLoud pq ele vai trabalhar com a partede permissao, vai fazer os attaches de arbach e etc.

No nosso caos generico agora, vamos copiar a linha de instalaçao abaixo e colar. UMa coisa importante é que somente a versao 3 do helm eh permitida.

Um ponto importante eh que quando damos um helm install nginx, perceba que estamos rodando isso e ele vai instalar em um namespace padrao. Namespaces no k8s sao espaços que acabamos separando aplicaçoes e contextos. Inclusive para cadanamespace conseguimos colocar regras de permissionamento, de recursos computacionais, de quais usuaros podem acessar, regras de service accounts que podem rodar. Etao isso eh um ponto importante. COmo estamos nesse exemplo, vamos rodar dessa forma, que ele vai instalar o igress-nginx no nosso namespace default. Mas na vida real isso normalmente eh separado em um namespace chamado ingress nginx, por exeplo.

Vamos instalar o hlm para o ubuntu via apt

```bash
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

E entao

```bash
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace
  
----

Release "ingress-nginx" does not exist. Installing it now.
NAME: ingress-nginx
LAST DEPLOYED: Sat Nov 19 23:28:53 2022
NAMESPACE: ingress-nginx
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The ingress-nginx controller has been installed.
It may take a few minutes for the LoadBalancer IP to be available.
You can watch the status by running 'kubectl --namespace ingress-nginx get services -o wide -w ingress-nginx-controller'

An example Ingress that makes use of the controller:
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: example
    namespace: foo
  spec:
    ingressClassName: nginx
    rules:
      - host: www.example.com
        http:
          paths:
            - pathType: Prefix
              backend:
                service:
                  name: exampleService
                  port:
                    number: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
      - hosts:
        - www.example.com
        secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls
```



Aõs a instalaçao / update, instalamos o ingress-mginx e tb eslesestã dando um template para nõs de como podemos criar um manifesto de Ingress com o host e tb com o TLS.

COmo podemos ver se o nossoIngress COntroler esta rodando? Vamos ver com o comando abaixo

```bash
❯ kubectl get svc
```

Como no nosso caso nao estamos na nuvem, o Ingress COtroler parece estar pendente aguardando um IP externo.

Ẽ no IP externo que devemos estar ligado. Todo mundo que for entrar pela nossa aplicação vaientrar pelo nosso IP externo ahora. Depois podemos atẽ mudar o service go goserver e tirar o external IP dele pq nao precisaremos do External IP mais pq usaremos apenas o External Ip do Ingress Controler.

Entao uma vez que temos o ingress contoler instalado e rodando podemos ver o Pod responsavel pelo Ingress com o comando 

```bash
❯ kubectl get po 
```

Por isso que normalmente nõsseparamos por namespace pq nao tem muito sentido o Ingress ficar rdando no mesmo namespace que estao rodando as nossas aplicações. 

### Configurando Ingress e DNS

Agora vamos criar um novo arquivo chamado Ingress.yaml. Nesse arquivo temos algumas annotations. Elas sao importantes porque cada sistema que for utilizar desse ingress pode pegar essas annotations e poder interpretar para utilizar alguma funcionalidade. No nosso caso, a nossa annotation vai informar que vamos utilizar o ingress do nginx.

Vamos aplicar esse arquivo de ingress

````bash
❯ kubectl apply -f k8s/ingress.yaml                                                                
error: resource mapping not found for name: "ingress-host" namespace: "" from "k8s/ingress.yaml": no matches for kind "Ingress" in version "networking.k8s.io/v1beta1"
ensure CRDs are installed first
````

Como em nosos caso nao temos um IP externo por estarmos testanto em um server local, o Ingress dá'esse tipo de erro pois nao foi possivel configurar um Namespace para esse service

 Uma vez que temos o ingress-host criado, ao chegar uma requisiçáo no dominio indicado, 

Caso déssemos um

````bash
kubectl get svc
````

Deveriamos visualizar o ingress-nginx-controller service como LoadBalancer e IP externo.

Com o IP copiado, colocaríamos ele no Gerenciamento de DNS e entao o IP externo estaria atachado no DNS. Ao colcoar o DNS no navegador, veriamos a aplicaçáo funcionando!

Se colocassemos /admin no ingress.svc, e aplicarmos o arquivo no k8s, bastaria acessar o endereço no navegador com /admin!

Aqui agora o mais importante é sabermos que poderiamos instancias vsrios prefixos e sufixos e urls e que cada um deles mandaria para um dos serviços do k8s e nao precisariamos mais do tipo de service do goserver-service como LoadBalancer, mas como ClusterIP e economizariamos uma grana. 

Vamos fazer isso. 

````yaml
apiVersion: v1
kind: Service
metadata:
  name: goserver-service
spec:
  selector:
    app: goserver
  type: ClusterIP
  ports:
  - name: goserver-service
    port: 8080
    targetPort: 8000
    protocol: TCP

````



E aplicamos a nova configuraçáo de service

````bash
❯ kubectl apply -f k8s/service.yaml 
service/goserver-service configured

❯ kubectl get svc                  
NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
kubernetes         ClusterIP   10.43.0.1       <none>        443/TCP    103m
mysql-h            ClusterIP   None            <none>        3306/TCP   101m
goserver-service   ClusterIP   10.43.191.199   <none>        8080/TCP   101m

````

É possivel que de um erro ao atualizar se for realizada essa mudanáaca na Cloud. Basta deletar e aoplicá-lo novamente. 



Nesse ponto, podemos ter agora quantos services quisermos e que vai rotear quando chegar nesse IP será o nosso service do Ingress com Load Balancer, que nos fornece um IP externo!



## Cert Manager

### Instalando o Cert Manager

Existem 2 formas gerais para fazermos a instala';çao dos cerificados no k8s.  A priemira forma é o que o ingress sugere.

Criamos um secret e passamos um crt do certificado. E ai a configuraçáo do TLS le o crt e a key e ai esta aplicado o nosso certificado. Se comprarmos im certificado normal, pgaamos ele, criamos o secret e colcoamos a configuraçáo basica ali. 



Mas hoje em dia temos o Cert Manager do lets Encrypt que gera os certificados para nós automaticamente e gerencia o tempo de validaçáo e gera os novos certificados para nós de maneira automatica.

Hohje em dia está sendo grandemente utilizado este método ao inves de ficar renovando e alterando servidor e tudo mais. Vamos ver como fazemos isso!



Acessando a documentaçao disponivel em https://cert-manager.io/v1.1-docs/installation/kubernetes/ ele mostra como fazemos a instalaçáo. Mas a ideia principal é'que instalemos o manifesto. 

Se tivermos usando o Google (GKE), ele vai pedir para rodarmos um comando para garantir que teremos permissao 

````bash
kubectl create clusterrolebinding cluster-admin-binding \
    --clusterrole=cluster-admin \
    --user=$(gcloud config get-value core/account)
````



Nota: o k8s trabalha com permissionamentoS. eSSE PERMISSIONAMENTO ESTA LIGADO DIRETAMENTE AO USU;ÁRIO QUE ESTA CADASTRADO NO SERVIÇO IDENTIDADE DO GOOGLE CLOUD.

Entao ele tem que falar que o nosso usuário, referente a tal no k8s e esse cara no k8s deve ter acesso a esse tipo de role que ele vá trabalhar.

O cert manager tem a opçáo que podemos instalar utilizando Helm ou a opçao que podemos instalar baseada no passo a passo que ele vai mostrar para nós. 

Para variar um pouco, vamos fazer pelo passo a passo. Importante: da mesma forma que estamos trabalhando com o Ingress e criamos um namesmpaxe para o Ingress, devemos criar um namespace especifico para o CertManegr para nao ficar misturando com os nossos Pods. 

Ele vai ter ali basicamente os seus permissionamentos e etc. Vamos seguir o passo a passo. 



Vamos criar um namespacce para o cert manager

````bash
❯ kubectl create namespace cert-manager
namespace/cert-manager created
````

E listar todos os namespace que temos:

````bash
❯ kubectl get ns
NAME              STATUS   AGE
cert-manager      Active   31s
default           Active   3h27m
ingress-nginx     Active   89m
kube-node-lease   Active   3h27m
kube-public       Active   3h27m
kube-system       Active   3h27m
````



Os namespaces kube* sao os padroes do k8s. O dfefault é o que estamos rodando na nossa aplicação e o cert-manager é o que acabamos de criar.

Agora. podemos usar a isntalaçáo com helm ou manual. 



Vamos fazer a manual:

````bash
❯ kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.3.0/cert-manager.yaml
----
customresourcedefinition.apiextensions.k8s.io/certificaterequests.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/certificates.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/challenges.acme.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/clusterissuers.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/issuers.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/orders.acme.cert-manager.io created
Warning: resource namespaces/cert-manager is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
namespace/cert-manager configured
serviceaccount/cert-manager-cainjector created
serviceaccount/cert-manager created
serviceaccount/cert-manager-webhook created
clusterrole.rbac.authorization.k8s.io/cert-manager-cainjector created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-issuers created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-clusterissuers created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-certificates created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-orders created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-challenges created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-ingress-shim created
clusterrole.rbac.authorization.k8s.io/cert-manager-view created
clusterrole.rbac.authorization.k8s.io/cert-manager-edit created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-cainjector created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-issuers created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-clusterissuers created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-certificates created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-orders created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-challenges created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-ingress-shim created
role.rbac.authorization.k8s.io/cert-manager-cainjector:leaderelection created
role.rbac.authorization.k8s.io/cert-manager:leaderelection created
role.rbac.authorization.k8s.io/cert-manager-webhook:dynamic-serving created
rolebinding.rbac.authorization.k8s.io/cert-manager-cainjector:leaderelection created
rolebinding.rbac.authorization.k8s.io/cert-manager:leaderelection created
rolebinding.rbac.authorization.k8s.io/cert-manager-webhook:dynamic-serving created
service/cert-manager created
service/cert-manager-webhook created
Warning: Autopilot set default resource requests for Deployment cert-manager/cert-manager-cainjector, as resource requests were not specified. See http://g.co/gke/autopilot-defaults.
deployment.apps/cert-manager-cainjector created
Warning: Autopilot set default resource requests for Deployment cert-manager/cert-manager, as resource requests were not specified. See http://g.co/gke/autopilot-defaults.
deployment.apps/cert-manager created
Warning: Autopilot set default resource requests for Deployment cert-manager/cert-manager-webhook, as resource requests were not specified. See http://g.co/gke/autopilot-defaults.
deployment.apps/cert-manager-webhook created
Warning: AdmissionWebhookController: mutated namespaceselector of the webhooks to enforce GKE Autopilot policies.
mutatingwebhookconfiguration.admissionregistration.k8s.io/cert-manager-webhook created
validatingwebhookconfiguration.admissionregistration.k8s.io/cert-manager-webhook created


````

Agora, vamos dar um get Pots para namespaces 

````bash
❯ kubectl get po -n cert-manager
NAME                                       READY   STATUS    RESTARTS   AGE
cert-manager-5f8676b596-r7zln              1/1     Running   0          2m28s
cert-manager-cainjector-59445c7dc9-vq644   1/1     Running   0          2m29s
cert-manager-webhook-55f6cd8bc6-q5qz7      1/1     Running   0          2m27s

````

Pronto! Agora que temos os Pods responsssáveis pelo Cer Manager, vamos criar o set Issue. Esse é que fará a geraçáo e o issue do nosso certificado.



### Configurando e emitindo certificado

Vamos fazer o nosso certificado funcionar. Vamos criar um tipo de objeto Ussuer pq instalamos o Cert-Manager. Esse arquivo chamaremos de cert manager que é'chamado de clusterIssuer. Ele é que vai se responsabilizar para fazer a geraçáo dos nossos certificados.

No arquivo abaixo, o kind só é possivel pq instalamos a API do cert-manager

cluster-issue.yaml

````yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt
  namespace: cert-manager
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: roger10cassares@gmail.com
    privateKeySecretRef:
      name: letsencrypt-tls
    solvers:
    - http01:
        ingress:
          class: nginx

````



E agora vamos aplicar essa configuraçáo

````bash
❯ kubectl apply -f k8s/cluster-issuer.yaml
Error from server (InternalError): error when creating "k8s/cluster-issuer.yaml": Internal error occurred: failed calling webhook "webhook.cert-manager.io": failed to call webhook: Post "https://cert-manager-webhook.cert-manager.svc:443/mutate?timeout=10s": x509: certificate signed by unknown authority
````

SE NAO FOSSE ESSE ERRO, A PARTIR DE AGORA ESTARAMOS APTOS A GERAR OS NOSSOS CERTIFICADOS CONFORME FORMOS PRECISANDO.



Utilizando o ingress comum dns configurado corretamente, podemos aplicar o comando 

```bash
❯ kubectl apply -f k8s/cluster-issuer.yaml
```

A partir de aoraestamosaptosa trabalhar no Ingress efazer comque ele gere os nossos certificados conforme formos precisando. 

Vamos entao trabalhar com o Ingress e trabalhar com as annotations. As annotations vao ser uteis aqui para a gente para resolvermos exatamente sse  tipo de problema e o cert manager saber que vamos usar o ingress para a emissao desse tipo de certificado.



!!!!!!!!!!!!!!!!!!!!!!!!!!



## Namespaces e Service ACCOUNTS

## Namespaces

Agora vamos falar de alguns assuntos extremamente imopoortantes quando formos fazer deploy., colocar em produçao a nossa app com k8s ou mesmo como vamos conseguir separar os nossos projetos na hora que formos fazer a instalaçao.  

A primeira coisa a se entender é o coneceito de Namespaces. Para que serve o namepace? O namespace é basicamente uma separacao virtual logica do nosso cluster k8s para onde fazemos a instalacao de cada coisa.

Entao, por exemplo, todas as vezes que a gente estava instalanmdo qualquer coisa estavamos instalando no namespace default.

Se dermos o comando abaixo com a respectiva saida

```bash
kubectl get po
No resources found in default namespace.
```

Isso significa que sempre que vamois acessar o k8s quando fazemos uma instalaçao e quando nao falamos qual eh o namespace, ele vao instalart tudo aquilo no nosso namespace padrao.

Mas para que o namespace?



Vamos imaginar que temos um projeto1. Entao tudo o que formos instalar, vamos instalar esse projeto 1 no namespace 1.

\Se formos instalar um projeto2 no namespace2, é possivel fazer essa separaçao. 

Mas o mais bacana de tudo é que quando estamos trabvalhando com esses dois projetos, eventua;mente, se setarmos recursos do nosso k8s, podemos falar que o namespace1 tem tanto de recurso. E o namespace 2 tem menos recursos! Entao um namespace nao consegue extrapolar e prejudicar o outro ali no k8s. Tb toda a parte de segurança e de acesso nós conseguimos fazer essa separaçao tb com o namespace. 

Portanto, é sempre recomendado, toda a vez em que formos criar um projeto específico ou fazer um deploy de forma geral dentro de um projeto como um todo, cria um namespace específico para aquele projeto porque vai ficar tudo muito mais separado. 

Uma outra coisa importante tb que muita gente faz, é semprar os namepaces de um ambiente de desenvolvimento de um ambiente de produçao. No caso, o wesley, de forma geral recomenda que se ternha um cluster para cada coisa, mas se vc só tem or;camento para um cluster, vc ainda pode separar pq terás ainda que em um cluster, a mesma aplicaçao em modo de desenvolvimento e em modo de produçao apenas criando o namespace. Vamos ver isso na pratica!

```bash
❯ kubectl get ns
NAME              STATUS   AGE
cert-manager      Active   43h
default           Active   2d4h
ingress-nginx     Active   2d1h
kube-node-lease   Active   2d4h
kube-public       Active   2d4h
kube-system       Active   2d4h
```

Ele vai mostrar todos os namespaces que temos nosso cluster.

O default é sempre quando nao passamos nada. 

Se dermos o seguinte comando

```bahs
❯ kubectl get po -n=kube-system 
NAME                                                     READY   STATUS    RESTARTS   AGE
anetd-2whr4                                              1/1     Running   0          2d4h
anetd-cxptw                                              1/1     Running   0          2d1h
anetd-dpqzb                                              1/1     Running   0          2d1h
anetd-kchls                                              1/1     Running   0          2d1h
anetd-kltq6                                              1/1     Running   0          2d1h
anetd-kwqfg                                              1/1     Running   0          2d4h
anetd-rgwsl                                              1/1     Running   0          43h
antrea-controller-horizontal-autoscaler-8484b5d7-hnttk   1/1     Running   0          2d4h
egress-nat-controller-5bb85946bc-fwc9z                   1/1     Running   0          2d4h
event-exporter-gke-5dc976447f-4lc62                      2/2     Running   0          2d4h
filestore-node-7mfnl                                     3/3     Running   0          2d1h
filestore-node-869gh                                     3/3     Running   0          2d1h
filestore-node-glf5w                                     3/3     Running   0          2d1h
filestore-node-jjxw4                                     3/3     Running   0          2d4h
filestore-node-kmqg8                                     3/3     Running   0          2d1h
filestore-node-mkv9x                                     3/3     Running   0          2d4h
filestore-node-t87th                                     3/3     Running   0          43h
fluentbit-gke-big-2wzkq                                  2/2     Running   0          43h
fluentbit-gke-small-57mnv                                2/2     Running   0          2d4h
fluentbit-gke-small-bcngv                                2/2     Running   0          2d1h
fluentbit-gke-small-dfr5t                                2/2     Running   0          2d1h
fluentbit-gke-small-lxjk2                                2/2     Running   0          2d1h
fluentbit-gke-small-sl2nl                                2/2     Running   0          2d4h
fluentbit-gke-small-sr7ff                                2/2     Running   0          2d1h
gke-metadata-server-2c4d8                                1/1     Running   0          2d1h
gke-metadata-server-95p2c                                1/1     Running   0          43h
gke-metadata-server-lqtrt                                1/1     Running   0          2d1h
gke-metadata-server-rg6rv                                1/1     Running   0          2d4h
gke-metadata-server-wtwpc                                1/1     Running   0          2d4h
gke-metadata-server-x5lq8                                1/1     Running   0          2d1h
gke-metadata-server-ztr2k                                1/1     Running   0          2d1h
gke-metrics-agent-2gzpp                                  1/1     Running   0          2d4h
gke-metrics-agent-79mds                                  1/1     Running   0          2d4h
gke-metrics-agent-9scsb                                  1/1     Running   0          2d1h
gke-metrics-agent-c9w7v                                  1/1     Running   0          2d1h
gke-metrics-agent-n725x                                  1/1     Running   0          43h
gke-metrics-agent-pxh8v                                  1/1     Running   0          2d1h
gke-metrics-agent-tfml4                                  1/1     Running   0          2d1h
ip-masq-agent-d5vm4                                      1/1     Running   0          2d4h
ip-masq-agent-h2w57                                      1/1     Running   0          2d1h
ip-masq-agent-jzg6q                                      1/1     Running   0          2d4h
ip-masq-agent-mmx9d                                      1/1     Running   0          2d1h
ip-masq-agent-tmb8p                                      1/1     Running   0          43h
ip-masq-agent-wsnwz                                      1/1     Running   0          2d1h
ip-masq-agent-z5hqt                                      1/1     Running   0          2d1h
konnectivity-agent-775dbdcf94-5gst4                      1/1     Running   0          2d4h
konnectivity-agent-775dbdcf94-89hvg                      1/1     Running   0          2d1h
konnectivity-agent-775dbdcf94-bx6cr                      1/1     Running   0          2d1h
konnectivity-agent-775dbdcf94-f529g                      1/1     Running   0          2d1h
konnectivity-agent-775dbdcf94-m54rr                      1/1     Running   0          2d1h
konnectivity-agent-775dbdcf94-nvc5r                      1/1     Running   0          2d4h
konnectivity-agent-autoscaler-658b588bb6-9jr6d           1/1     Running   0          2d4h
kube-dns-598f9895c6-2x9tj                                4/4     Running   0          2d4h
kube-dns-598f9895c6-j9jdx                                4/4     Running   0          2d4h
kube-dns-autoscaler-fbc66b884-d9cvs                      1/1     Running   0          2d4h
l7-default-backend-6b99559c7d-pgwdh                      1/1     Running   0          2d4h
metrics-server-v0.5.2-9b67f66b8-fbgwf                    2/2     Running   0          2d1h
netd-4fldl                                               1/1     Running   0          43h
netd-7hn2l                                               1/1     Running   0          2d4h
netd-hwzpg                                               1/1     Running   0          2d1h
netd-j768z                                               1/1     Running   0          2d1h
netd-l79zq                                               1/1     Running   0          2d1h
netd-n5fjg                                               1/1     Running   0          2d1h
netd-zsvgm                                               1/1     Running   0          2d4h
node-local-dns-4nc8r                                     1/1     Running   0          2d1h
node-local-dns-86kbb                                     1/1     Running   0          2d4h
node-local-dns-f6tck                                     1/1     Running   0          2d1h
node-local-dns-h2jpc                                     1/1     Running   0          2d1h
node-local-dns-hx9kx                                     1/1     Running   0          43h
node-local-dns-qzmwd                                     1/1     Running   0          2d4h
node-local-dns-w2l7n                                     1/1     Running   0          2d1h
pdcsi-node-55b7c                                         2/2     Running   0          2d4h
pdcsi-node-hr4pr                                         2/2     Running   0          2d1h
pdcsi-node-hwfvd                                         2/2     Running   0          2d4h
pdcsi-node-mnddl                                         2/2     Running   0          2d1h
pdcsi-node-r5tpx                                         2/2     Running   0          2d1h
pdcsi-node-znhw7                                         2/2     Running   0          2d1h
pdcsi-node-zt8c2                                         2/2     Running   0          43h
```

 

Ele vai listar todos os Pods que estao rodando no kube-system. E até agora nós nao havíamos visto, de uma forma geral, esses namespaces rodando pq eles estao separados por namespaces. E dessa forma fica muito melhor de conseguirmos trabalhar e separar, de fato, de forma geral as nossas aplicações.

Mas como criuamos um namespcxae utilizando o k8s? 

Veja

```bash
❯ kubectl create ns dev 
namespace/dev created
```

Pronto! Vamos ver

```bash
❯ kubectl get ns
NAME              STATUS   AGE
cert-manager      Active   43h
default           Active   2d4h
dev               Active   28s
ingress-nginx     Active   2d1h
kube-node-lease   Active   2d4h
kube-public       Active   2d4h
kube-system       Active   2d4h
```

Aora vemos que temos um namespace dev que podemos trabalhar. Agora, todas as vezes que formos fazer e subir um novo deployment, basta identificarmos em qual namespace queremos trabalhar! 

```bash
❯ kubectl apply -d k8s/.yaml -n=dev 
```

E entao o k8s fará o provisionamento do manifesto no nsmaspace dev! 

Também, o que podemos fazer, é que quando estamos em um arquivo de deployment, quando chega ali nos metadados (metadata), podemos colocar o nome do namespace que queremos realizar o apply.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: dev
  name: goserver
  labels:
    app: goserver
spec:
  selector:
    matchLabels:
      app: goserver
  replicas: 1
  template:
    metadata:
      labels:
        app: "goserver"
    spec:
      containers:
        - name: goserver
          image: "rogeriocassares/hello-go:v9.7"

          resources:
            requests:
              cpu: "0.05"
              memory: 20Mi
            limits:
              cpu: "0.05"
              memory: 25Mi

          startupProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 30
            failureThreshold: 1
            # initialDelaySeconds: 10

          readinessProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 3
            failureThreshold: 1
            # initialDelaySeconds: 10

          livenessProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 5
            failureThreshold: 1
            timeoutSeconds: 1
            successThreshold: 1
            # initialDelaySeconds: 15

          envFrom:
            - configMapRef:
                name: goserver-env
            - secretRef:
                name: goserver-secret

          volumeMounts:
            - mountPath: "/go/myfamily"
              name: config
              readOnly: true
            - mountPath: "/go/pvc"
              name: goserver-volume

      volumes:
        - name: goserver-volume
          persistentVolumeClaim:
            claimName: goserver-pvc

        - name: config
          configMap:
            name: configmap-family
            items:
              - key: members
                path: "family.txt"

```





`Enato, de forma geral, nós precisamos citar sempre o processo do ns para conseguirmos =organizar. Tudo o que fizemos até agora, ou se vamos subir algo muito simples no k8s, nao tem problemna colocar no default. Mas, vioa de regra, é recomendado que exista um namespace por projeto! 

De qualquer forma a criatividade é o limite! Entao podemos organizar por namespaces por projeto, por namespace chamdo dev-proj1. dev-proj2 e dev-proj3 com prod-proj1, prod-prod2 e prod-proj3, por exemplo. Ou somente dev com tudo o que roda como dev e prod com tudo o que rodamos como prod.

Agora vamos criar um novo deployment para falar inclusive sobre segurança! POis o k8s vem bem aberto na parte de segurança e isso pode trazer alguns riscos para nós.



### Contextos por namespace

Agora vmaos ver como trabalhar com namespace no nosso dia a dia sem confundir qualk ambiente que estamos no nosso monento. 

Vamos imaginar qquer queremos fazer um deployment. Na hora que formos fazer o deployment, passamos o namespace que queremos. Mas e se esquecemos de passar, o que vai acontecer? Ja pensou se estamos fazendo um deployment que é para ser feito no dev e sem querer fazemos no ambiente de produçao?

Entao o que faremos é criar um deployment bem simples e vamos explorar os secursos de namespaces.

Vamos criar um diretorio namespaces e um arquiovo de deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: server
spec:
  selector:
    matchLabels:
      app: server
  template:
    metadata:
      labels:
        app: server
    spec:
      containers:
      - name: server
        image: rogeriocassares/hello-express
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 3000

```



Vamos aplicá-lo!

```bash
❯ kubectl apply -f deployment.yaml 
Warning: Autopilot set default resource requests for Deployment default/server, as resource requests were not specified. See http://g.co/gke/autopilot-defaults.
deployment.apps/server created
```

Pronto! Criamos o nosso deployment

```bash
❯ kubectl get po
NAME                        READY   STATUS    RESTARTS   AGE
goserver-546c7b4948-qnmz2   1/1     Running   0          2d2h
mysql-0                     1/1     Running   0          2d2h
mysql-1                     1/1     Running   0          2d2h
server-6cd8bdcb98-826cl     1/1     Running   0          53s
```



Entretanto, temos ele rodfando no namespace default!

Vamos agora rodar o mesmo comando com -n=dev

❯ kubectl apply -f deployment.yaml -n=dev
Warning: Autopilot set default resource requests for Deployment dev/server, as resource requests were not specified. See http://g.co/gke/autopilot-defaults.
deployment.apps/server created

O que fizemos agora foi criar esse mesmo POd / deployment no novo namespace dev.

Agora vamos criar um namespace  de produçao

```bash
❯ kubectl create namespace prod
namespace/prod created
```

E vamos rodar esse mesmo comando do deployment no namespace prod!

```bash
❯ kubectl apply -f deployment.yaml -n=prod
Warning: Autopilot set default resource requests for Deployment prod/server, as resource requests were not specified. See http://g.co/gke/autopilot-defaults.
deployment.apps/server created
```



Vamos listar os pods no namespace default

```bash
❯ kubectl get po
NAME                        READY   STATUS    RESTARTS   AGE
goserver-546c7b4948-qnmz2   1/1     Running   0          2d2h
mysql-0                     1/1     Running   0          2d2h
mysql-1                     1/1     Running   0          2d2h
server-6cd8bdcb98-826cl     1/1     Running   0          7m8s
```

Agora, vamos listar  o namespace dev

❯ kubectl get po -n=dev
NAME                      READY   STATUS    RESTARTS   AGE
server-6cd8bdcb98-rqhz9   1/1     Running   0          3m47s

E se colcoarmos prod

```bash
❯ kubectl get po -n=prod
NAME                      READY   STATUS    RESTARTS   AGE
server-6cd8bdcb98-s2ggl   1/1     Running   0          2m25s
```

Ele traz o mesmo ambiente no namespace de produçao! ENtao poderiamos fazer essa separaçao.

COmo podemos ver todos os deployments juntios?

Lembra-se que trabalhamos tanto com labels nos squivos de maifestos .yaml? Entao poderiamos trabalhar e fazermos um filtro pelas labels!

Vamos ver com as labels como server

```bash
❯ kubectl get po -l app=server
NAME                      READY   STATUS    RESTARTS   AGE
server-6cd8bdcb98-826cl   1/1     Running   0          11m
```



Entao aqui conseguimos ver todos os Pods em que o app é igual a server.





Agora, tem umas coisas muito interessantes que devemos levar em consifderaçao!

Vamos ver o sqguinte:

Vamos imaginar que estamos trabalhando no nosso dia a dia e queremos pegar os Pos do dev

```bash
❯ kubectl get po -n=dev
NAME                      READY   STATUS    RESTARTS   AGE
server-6cd8bdcb98-rqhz9   1/1     Running   0          35m
```

Agora vamos rodar um deployment

```bash
❯ kubectl apply -f deployment.yaml 
Warning: Autopilot increased resource requests for Deployment default/server to meet requirements. See http://g.co/gke/autopilot-resources.
deployment.apps/server configured
```

OH naoo! Era para rodarmos no ambiente de dev e nao de produçao!

E agora? 

Vemos que quando começamos a trabalhar dessa forma começamos a ter um perigo muito grande. E é por conta disso que a gente pode utilizar um recurso do k8s que é bem interessante e que é chamado de contextos.

Quando estamos trabalhando com o k8s, existe um arquivo que é chamado de config

❯ cat ~/.kube/config

Esse arquivo traz um arquivo tb com toidas as  credenciais que estamos trabalhando no k8s.

O que podemo tb fazwer para ver essas configuraçoes?

POdemos verificar atraves dos comanbdos do kubectl.

```bash
❯ kubectl config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://34.151.193.17
  name: gke_brilliant-tide-369315_southamerica-east1_autopilot-cluster-3
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://34.27.46.86
  name: gke_brilliant-tide-369315_us-central1_autopilot-cluster-1
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://0.0.0.0:35809
  name: k3d-fullcycle
contexts:
- context:
    cluster: gke_brilliant-tide-369315_southamerica-east1_autopilot-cluster-3
    user: gke_brilliant-tide-369315_southamerica-east1_autopilot-cluster-3
  name: gke_brilliant-tide-369315_southamerica-east1_autopilot-cluster-3
- context:
    cluster: gke_brilliant-tide-369315_us-central1_autopilot-cluster-1
    user: gke_brilliant-tide-369315_us-central1_autopilot-cluster-1
  name: gke_brilliant-tide-369315_us-central1_autopilot-cluster-1
- context:
    cluster: k3d-fullcycle
    user: admin@k3d-fullcycle
  name: k3d-fullcycle
- context:
    cluster: k3d-fullcycle-k3d
    user: admin@k3d-fullcycle-k3d
  name: k3d-fullcycle-k3d
- context:
    cluster: kind-fullcycle
    user: kind-fullcycle
  name: kind-fullcycle
current-context: gke_brilliant-tide-369315_southamerica-east1_autopilot-cluster-3
kind: Config
preferences: {}
users:
- name: admin@k3d-fullcycle
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED
- name: admin@k3d-fullcycle-k3d
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED
- name: gke_brilliant-tide-369315_southamerica-east1_autopilot-cluster-3
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      args: null
      command: gke-gcloud-auth-plugin
      env: null
      installHint: Install gke-gcloud-auth-plugin for use with kubectl by following
        https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
      interactiveMode: IfAvailable
      provideClusterInfo: true
- name: gke_brilliant-tide-369315_us-central1_autopilot-cluster-1
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      args: null
      command: gke-gcloud-auth-plugin
      env: null
      installHint: Install gke-gcloud-auth-plugin for use with kubectl by following
        https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
      interactiveMode: IfAvailable
      provideClusterInfo: true
- name: kind-fullcycle
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED
```



E quando damos esse comando acima, eke traz as configuraçoes do cluster que estamos utilizando do GKE, nesse caso. Isso ;e um ponto. Mas essas configuraçoes, por padrao, elas fazem com que o nosso contexto principal entre direto no nosso namespace default e veja tudo o que está lá/

MAs o que podemos fazer? POdemos criar novos contexto para nos ajudar no dia a dia!

Vamos analisar o comando abaixo

❯ kubectl config current-context
gke_brilliant-tide-369315_southamerica-east1_autopilot-cluster-3

o K8s nos mostra o nome do nosso  contexto atual que é o descrito acima. 

Vamos configurar um contexto agora com o nosso cluster e usuário atuais!

```bash
❯ kubectl config set-context dev --namespace=dev --cluste
r=gke_brilliant-tide-369315_southamerica-east1_autopilot-cluster-3 --user=gke_brilliant-tide-369315_southamerica-east1_autopilot-cluster-3
Context "dev" created.
```

Nesse momento, criamos um contexto chamado dev. Agora vamos criar um contexto chamado prod!

```bash
❯ kubectl config set-context prod --namespace=prod --cluster=gke_brilliant-tide-369315_southamerica-east1_autopilot-cluster-3 --user=gke_brilliant-tide-369315_southamerica-east1_autopilot-cluster-3
Context "prod" created.
```

Pronto!

Agora temos dois contextos! Um chamado dev e o outro chamado prod. 

Entao, quamdo damos um

❯ kubectl config view       
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://34.151.193.17
  name: gke_brilliant-tide-369315_southamerica-east1_autopilot-cluster-3
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://34.27.46.86
  name: gke_brilliant-tide-369315_us-central1_autopilot-cluster-1
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://0.0.0.0:35809
  name: k3d-fullcycle
    contexts:
- context:
    cluster: gke_brilliant-tide-369315_southamerica-east1_autopilot-cluster-3
    namespace: dev
    user: gke_brilliant-tide-369315_southamerica-east1_autopilot-cluster-3
  name: dev
- context:
    cluster: gke_brilliant-tide-369315_southamerica-east1_autopilot-cluster-3
    user: gke_brilliant-tide-369315_southamerica-east1_autopilot-cluster-3
  name: gke_brilliant-tide-369315_southamerica-east1_autopilot-cluster-3
- context:
    cluster: gke_brilliant-tide-369315_us-central1_autopilot-cluster-1
    user: gke_brilliant-tide-369315_us-central1_autopilot-cluster-1
  name: gke_brilliant-tide-369315_us-central1_autopilot-cluster-1
- context:
    cluster: k3d-fullcycle
    user: admin@k3d-fullcycle
  name: k3d-fullcycle
- context:
    cluster: k3d-fullcycle-k3d
    user: admin@k3d-fullcycle-k3d
  name: k3d-fullcycle-k3d
- context:
    cluster: kind-fullcycle
    user: kind-fullcycle
  name: kind-fullcycle
- context:
    cluster: gke_brilliant-tide-369315_southamerica-east1_autopilot-cluster-3
    namespace: prod
    user: gke_brilliant-tide-369315_southamerica-east1_autopilot-cluster-3
  name: prod
    current-context: gke_brilliant-tide-369315_southamerica-east1_autopilot-cluster-3
    kind: Config
    preferences: {}
    users:
- name: admin@k3d-fullcycle
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED
- name: admin@k3d-fullcycle-k3d
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED
- name: gke_brilliant-tide-369315_southamerica-east1_autopilot-cluster-3
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      args: null
      command: gke-gcloud-auth-plugin
      env: null
      installHint: Install gke-gcloud-auth-plugin for use with kubectl by following
        https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
      interactiveMode: IfAvailable
      provideClusterInfo: true
- name: gke_brilliant-tide-369315_us-central1_autopilot-cluster-1
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      args: null
      command: gke-gcloud-auth-plugin
      env: null
      installHint: Install gke-gcloud-auth-plugin for use with kubectl by following
        https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
      interactiveMode: IfAvailable
      provideClusterInfo: true
- name: kind-fullcycle
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED

```bash

```

Vemos que nessas configuraçoes vamos poder trabalhar com um contexto chamado prod e um contexto chamado dev.

Agora as coisas ficam um pouco mais simples, pois podemos executar 

❯ kubectl config use-context dev
Switched to context "dev".

E agora estamos no contexto dev.  Vamos verificar

```bash
❯ kubectl config current-context
```

Agora se dermos 

```bash
❯ kubectl get po
NAME                      READY   STATUS    RESTARTS   AGE
server-6cd8bdcb98-rqhz9   1/1     Running   0          58m
```

Estamos vendo que ele está mostrando o nosso Pod que estava rodando agora ali.

Agora vamos fazer o deletar o deploymente server onde o namespace é o default

```bash
kubectl delete deployment server -n=default 
deployment.apps "server" deleted
```

E tb vamos matar onde o namespace é igual a prod

```bash
❯ kubectl delete deployment server -n=prod   
deployment.apps "server" deleted
```

Vamos verificar os Pod que estao rodando no nosso namespace

```bash
❯ kubectl get po
NAME                      READY   STATUS    RESTARTS   AGE
server-6cd8bdcb98-rqhz9   1/1     Running   0          62m
```

O nosso Pod ainda está rodando pois estamos em modo de dev!

Agora vamos mudar de contexto para o prod

```bash
❯ kubectl config use-context prod
Switched to context "prod".
```

Vamos verificar os Pods rodando nesse contexto que se refere ao namespace prod:

```bash
❯ kubectl get po
No resources found in prod namespace.
```

E nao veio nada aqui no nosso namespace Por pq estamos por padrao no nosso namespace PRod!

ISSO AQUI AJUDA DEMAIS QUANDO ESTAMOS TRABALHANDO NO MODO DE PRODUÇAO E NO MODO DE DESENVOLVIMENTO QUANDO ESTAMOS UTILIZANDO O K8S NO DIA A DIA!

ENTAO SE ESTAMOS FAZENDO ESSE TIPO DE SEPARAÇAO, DEVEMOS TRABALHAR MINIMAMENTE COM ALGUMACOISA DESSE TIPO POIS VAI FACILITAR MUOITO A NOSS VIDA POIS CONSEGUIMOS TER ESSAS DIFERENÇARS E CONBFIGURAR ISSO PARA O NOSSO AMBIENTE.



### Entendendo Service Accounts

Ua consideraçcao extremamente importante que devemoster e lembrar sempre antes de subir umaaplicaçcao no ar com ok8s. O que acontece é que quandosubimosuma aplica]cao nok8s, essa aplicaçao, de um forma ou de outra, precisa teruma permissao para rodar dentro do k8s.

Entao, vamos imaginar que toda vez que subimos um deployment, um Pod ou qualquer coisa desse tipo, esse caa está sendo executado no k8s. O que aconteceé que toda vez queentramos nesse Pd, esse Pod, de alguma forma necessita ter credenciais para estar rodando ali 

Entao tudo isso é feito atraves de algo que chamamos de SERVICE ACCOUNT, ISTO É, UMA CONTA DE SERVIÇO. qUALQUER COISA QUE SUBIRMOS NO k8S podemos pegar, por exemplo, um Deployment e falar que a sua conta de serviço é x e a parir das permissoes que existem naquela conta de serviço, aquele Pod vai poder secomunicar de alguma forma com a API do k8s.

Entao isso significa que,  imaginamos que sbimos a nossa aplicaão de forma tudo certinha. E alguem entao consegue invadir essanossa aplicaçao. E uma vez que ela invada essa aplicaçao, ela pode tentar falar com a API do k8s. E se ela falar com a API do k8s, ela pode, por exemplo, pegar, os Pods, deletá-los, criar deployments, rodar comandos nos nossos POds, e o pior de tudo isso é que ela consegue ir escalando tudo isso para acessar os Services, acessar o kube-system, acessar outros namespaces e dai ja da para perceber que basta uma aplicaçao ter algum problema de segurança que a pessoa ou o hacker vai conseguir escalar o acesso para o nosso cluster inteiro! 

NIsso já da para perceber o quao grave é isso!

Por padra, o k8s já possui uma Service Account que ele utiliza para todos os depoyments que fazemos,

```bash
❯ kubectl get serviceaccounts 
NAME      SECRETS   AGE
default   1         78d

```

Entao, tudo o que estamos criando no k8s, seja Deployments ou qualquer outra coisa, tudo isso está sendo gerado atraves do Service Account DEFAULT! 

Entretanto, existe um pequenino problema quando estamos rodando como Service Account Default no k8s. O problema é que a Service Account Default nos permite fazer tudo!

Isso significa que se alguem entrar na nossaaplica~cao que esteja utilizando a serviceaccount padrao, simplesmente essa pessoa vai conseguir fazer tudo! Vale a paena criar entao uma Service Account por projeto e ai cria-se uma permissao especifica para aquele serviço possa apenas, por exemplo, ler os Pods, listar os pods, paraqueee possa teruma acesso bem limitado e ele nao consiga ir mais para frente e nem executar operaçes em nosso cluster. 



Vejamos:

```bash
❯ kubectl get po
NAME                        READY   STATUS      RESTARTS        AGE
goserver-64695797bb-lnqqh   0/1     Error       53 (135m ago)   78d
mysql-2                     0/1     Pending     0               40m
goserver-64695797bb-lfqt9   0/1     Error       0               45m
goserver-64695797bb-8vs7c   0/1     Pending     0               40m
mysql-1                     0/1     Pending     0               39m
mysql-3                     0/1     Completed   0               45m
mysql-0                     0/1     Pending     0               39m

```

Vamos pegar um Pod e descrevê-lo.

```bash
❯ kubectl describe po goserver-64695797bb-lnqqh
Name:             goserver-64695797bb-lnqqh
Namespace:        default
Priority:         0
Service Account:  default
Node:             k3d-fullcycle-server-0/172.21.0.3
Start Time:       Mon, 21 Nov 2022 10:58:19 -0300
Labels:           app=goserver
                  pod-template-hash=64695797bb
Annotations:      <none>
Status:           Failed
Reason:           Evicted
Message:          The node was low on resource: ephemeral-storage. Container goserver was using 36Ki, which exceeds its request of 0. 
IP:               10.42.0.232
IPs:
  IP:           10.42.0.232
Controlled By:  ReplicaSet/goserver-64695797bb
Containers:
  goserver:
    Container ID:   containerd://efbbad677de7045b7da0ab79c2ceae8456a04b0e181db2629cdf9ae3f1411ac8
    Image:          rogeriocassares/hello-go:v9.7
    Image ID:       docker.io/rogeriocassares/hello-go@sha256:a78e4c05be9147e62eb9f19ae0bc26c9d1404605fa07dde9a9fb9a0416fa4da6
    Port:           <none>
    Host Port:      <none>
    State:          Terminated
      Reason:       Error
      Exit Code:    2
      Started:      Tue, 07 Feb 2023 19:18:14 -0300
      Finished:     Tue, 07 Feb 2023 20:48:32 -0300
    Last State:     Terminated
      Reason:       Unknown
      Exit Code:    255
      Started:      Sat, 04 Feb 2023 16:30:42 -0300
      Finished:     Tue, 07 Feb 2023 19:17:39 -0300
    Ready:          False
    Restart Count:  53
    Limits:
      cpu:     50m
      memory:  25Mi
    Requests:
      cpu:      50m
      memory:   20Mi
    Liveness:   http-get http://:8000/healthz delay=0s timeout=1s period=5s #success=1 #failure=1
    Readiness:  http-get http://:8000/healthz delay=0s timeout=1s period=3s #success=1 #failure=1
    Startup:    http-get http://:8000/healthz delay=0s timeout=1s period=30s #success=1 #failure=1
    Environment Variables from:
      goserver-env     ConfigMap  Optional: false
      goserver-secret  Secret     Optional: false
    Environment:       <none>
    Mounts:
      /go/myfamily from config (ro)
      /go/pvc from goserver-volume (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-nqt7v (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             False 
  ContainersReady   False 
  PodScheduled      True 
Volumes:
  goserver-volume:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  goserver-pvc
    ReadOnly:   false
  config:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      configmap-family
    Optional:  false
  kube-api-access-nqt7v:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason       Age                From     Message
  ----     ------       ----               ----     -------
  Warning  Evicted      46m                kubelet  The node was low on resource: ephemeral-storage. Container goserver was using 36Ki, which exceeds its request of 0.
  Normal   Killing      46m                kubelet  Stopping container goserver
  Warning  FailedMount  42m (x5 over 43m)  kubelet  MountVolume.SetUp failed for volume "config" : object "default"/"configmap-family" not registered
  Warning  FailedMount  42m (x5 over 42m)  kubelet  MountVolume.SetUp failed for volume "kube-api-access-nqt7v" : object "default"/"kube-root-ca.crt" not registered
```

E se percebemos aqui, vemos que ele está montando um Volume dentro do nosso Pod! Isso porque além dos volumes que costumamos configurar, ele monta, automaticamente um outro volume em Mounts! E esse volume está na seguinte pasta /var/run/secrets/kubernetes.io/serviceaccount e ele está pegando, muito provavelmente os valores que estao dentro do segredo que o acompanha em kube-api-access-nqt7v dentro do serviceaccount default.

Vamos dar uma explorada nele!

```bash
❯ kubectl exec -it goserver-64695797bb-lnqqh -- bash
/usr/src/app# cd /var/run/secrets/kubernetes.io/serviceaccount
/var/run/secrets/kubernetes.io/serviceaccount# ls
ca.crt  namespace  token
```

Entao, nessa pasta, temos acesso ao qual certificado que ele está usando no k8s, acesso a qual namespace esse Pod esta rodando, e tambem acesso ao token JWT que o k8s vai utilizar para conseguirmos fazer as chamadas na API.

O problemaé que esses arquivos eles fazem parte do nosso Service Account default, que permite, simplesmente, qualque um fazer o que quiser, isto ẽ, com essas informaçoes, ele consegue simplesmente executar comandos na API do k8s sem nenhum problema ou dificuldades. Entao preceisamos começar a ter um fator de limite para que todo mundo, de uma forma ou de outra, que consiga invadir a nossa aplicaçao, nao possa escalar. Isto ẃ, queremos reduzir esse risco!

Vamos entao aprender a fazer e a atribuir uma service ccount para o nosso deployment e criar todas as permissoes que precisamos. 



### Criando Service Account e Roles



Agoravamos criar uma niva Service Account, permissões, atribuir para o nosso deployment, e fazer tudo funcionar!

Dentro de namespaces vamos criar um aquivo chamado security.yaml.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: server
```



Vamos aplicar este arquivo 

```bash
❯ kubectl apply -f k8s/namespaces/security.yaml 
serviceaccount/server created
```

E verificar os nossos Services Accounts

```bash
❯ kubectl get serviceaccounts
NAME      SECRETS   AGE
default   1         81d
server    1         56s
```



A nossa ideia é conseguirmos sair do default e ir para o nosso serice Account. Mas nao adianta nada a gente mudar o nosso service account para o server e o service tb ter a permissao para fazer tudo! 

Entao a nossa ideia é criarmos uma role. Uma role é uma funçao, um papel. Isto é., qual é a funçcai que determinada coisa que vamos criar terá. 

O k8s trabalha com algo chamado de RBAC (rOLE Access Based). Isso significa que baseado em alguns papeis podemos dar determinado acesso para cada um. 

UM api group determina quais sao os recursos que a gente vai poder trabalhar baseado na API que esse cara trabalha.

```bash
❯ kubectl get serviceaccounts
NAME      SECRETS   AGE
default   1         81d
server    1         56s
rogerio in fullcycle-kubernetes on  main [!?] 
❯ kubectl api-resources
NAME                              SHORTNAMES   APIVERSION                             NAMESPACED   KIND
bindings                                       v1                                     true         Binding
componentstatuses                 cs           v1                                     false        ComponentStatus
configmaps                        cm           v1                                     true         ConfigMap
endpoints                         ep           v1                                     true         Endpoints
events                            ev           v1                                     true         Event
limitranges                       limits       v1                                     true         LimitRange
namespaces                        ns           v1                                     false        Namespace
nodes                             no           v1                                     false        Node
persistentvolumeclaims            pvc          v1                                     true         PersistentVolumeClaim
persistentvolumes                 pv           v1                                     false        PersistentVolume
pods                              po           v1                                     true         Pod
podtemplates                                   v1                                     true         PodTemplate
replicationcontrollers            rc           v1                                     true         ReplicationController
resourcequotas                    quota        v1                                     true         ResourceQuota
secrets                                        v1                                     true         Secret
serviceaccounts                   sa           v1                                     true         ServiceAccount
services                          svc          v1                                     true         Service
mutatingwebhookconfigurations                  admissionregistration.k8s.io/v1        false        MutatingWebhookConfiguration
validatingwebhookconfigurations                admissionregistration.k8s.io/v1        false        ValidatingWebhookConfiguration
customresourcedefinitions         crd,crds     apiextensions.k8s.io/v1                false        CustomResourceDefinition
apiservices                                    apiregistration.k8s.io/v1              false        APIService
controllerrevisions                            apps/v1                                true         ControllerRevision
daemonsets                        ds           apps/v1                                true         DaemonSet
deployments                       deploy       apps/v1                                true         Deployment
replicasets                       rs           apps/v1                                true         ReplicaSet
statefulsets                      sts          apps/v1                                true         StatefulSet
tokenreviews                                   authentication.k8s.io/v1               false        TokenReview
localsubjectaccessreviews                      authorization.k8s.io/v1                true         LocalSubjectAccessReview
selfsubjectaccessreviews                       authorization.k8s.io/v1                false        SelfSubjectAccessReview
selfsubjectrulesreviews                        authorization.k8s.io/v1                false        SelfSubjectRulesReview
subjectaccessreviews                           authorization.k8s.io/v1                false        SubjectAccessReview
horizontalpodautoscalers          hpa          autoscaling/v2                         true         HorizontalPodAutoscaler
cronjobs                          cj           batch/v1                               true         CronJob
jobs                                           batch/v1                               true         Job
certificatesigningrequests        csr          certificates.k8s.io/v1                 false        CertificateSigningRequest
leases                                         coordination.k8s.io/v1                 true         Lease
endpointslices                                 discovery.k8s.io/v1                    true         EndpointSlice
events                            ev           events.k8s.io/v1                       true         Event
flowschemas                                    flowcontrol.apiserver.k8s.io/v1beta2   false        FlowSchema
prioritylevelconfigurations                    flowcontrol.apiserver.k8s.io/v1beta2   false        PriorityLevelConfiguration
helmchartconfigs                               helm.cattle.io/v1                      true         HelmChartConfig
helmcharts                                     helm.cattle.io/v1                      true         HelmChart
addons                                         k3s.cattle.io/v1                       true         Addon
nodes                                          metrics.k8s.io/v1beta1                 false        NodeMetrics
pods                                           metrics.k8s.io/v1beta1                 true         PodMetrics
ingressclasses                                 networking.k8s.io/v1                   false        IngressClass
ingresses                         ing          networking.k8s.io/v1                   true         Ingress
networkpolicies                   netpol       networking.k8s.io/v1                   true         NetworkPolicy
runtimeclasses                                 node.k8s.io/v1                         false        RuntimeClass
poddisruptionbudgets              pdb          policy/v1                              true         PodDisruptionBudget
podsecuritypolicies               psp          policy/v1beta1                         false        PodSecurityPolicy
clusterrolebindings                            rbac.authorization.k8s.io/v1           false        ClusterRoleBinding
clusterroles                                   rbac.authorization.k8s.io/v1           false        ClusterRole
rolebindings                                   rbac.authorization.k8s.io/v1           true         RoleBinding
roles                                          rbac.authorization.k8s.io/v1           true         Role
priorityclasses                   pc           scheduling.k8s.io/v1                   false        PriorityClass
csidrivers                                     storage.k8s.io/v1                      false        CSIDriver
csinodes                                       storage.k8s.io/v1                      false        CSINode
csistoragecapacities                           storage.k8s.io/v1beta1                 true         CSIStorageCapacity
storageclasses                    sc           storage.k8s.io/v1                      false        StorageClass
volumeattachments                              storage.k8s.io/v1                      false        VolumeAttachment
ingressroutes                                  traefik.containo.us/v1alpha1           true         IngressRoute
ingressroutetcps                               traefik.containo.us/v1alpha1           true         IngressRouteTCP
ingressrouteudps                               traefik.containo.us/v1alpha1           true         IngressRouteUDP
middlewares                                    traefik.containo.us/v1alpha1           true         Middleware
middlewaretcps                                 traefik.containo.us/v1alpha1           true         MiddlewareTCP
serverstransports                              traefik.containo.us/v1alpha1           true         ServersTransport
tlsoptions                                     traefik.containo.us/v1alpha1           true         TLSOption
tlsstores                                      traefik.containo.us/v1alpha1           true         TLSStore
traefikservices                                traefik.containo.us/v1alpha1           true         TraefikService
```



Quando acessarmos o api-resources, vamos ver lá em cima o Nome do recurso e o respectivo api-group. Quando nao temos o api-group podemos deixá-lo em branco.

POrexeplo, o apigroup de namespace nao existe, nem o do configmap, persistenvolumes, pods ... Mas olha sõ quem tem um apigroup: deployments. O apigroup de deployments chama apps. Entao se quisermos saber qual API group que queremos liberar para a pessoa ter acesso podemos dar uma olhada nas respostas desse comando aqui tb.

Entao, em nosso arquivo yaml, o primeiro grupo de apigroups deve ser em branco,pq vamos passar algumas regras e alguns papeis que nao existem apigroups nesse nosso caso.

Qauis sao os resources que queremos trabalhar? Quais sao os verbos que eles vao poder utilizar nesses recursos que vamos dar a ele no k8s?

Todos que tiverem essa regra vao poder acionar os recursos relacionados aos verbos 

Fazemos a mesma coisa com um apiGroup de Deployments.

COm isso estamos criando uma serie de regras que deixamos todos verem os serviços, ver os pods e ver os deployments. Mas perceba que nao esta sendo permitido colocar write em nada.  E esses tipos de coisas fazem muita diferença!

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: server

---

apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: server-read
rules:
- apiGroups: [""]
  resources: ["pods, services"]
  verbs: ["get", "watch", "list"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "watch", "list"]
```



Vamos verificar se tudo foi criado certinho

```bash
❯ kubectl apply -f k8s/namespaces/security.yaml
serviceaccount/server unchanged
role.rbac.authorization.k8s.io/server-read created
```

Masainda nao está pronto pq ainda precisamos pegar esse papel/role e atribuir para a nossa serviceaccount, isto é, precisamos fazer um bind, ou seja, indicar a cada sericeaccount qual role ele deve seguir!

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: server

---

apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: server-read
rules:
- apiGroups: [""]
  resources: ["pods, services"]
  verbs: ["get", "watch", "list"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "watch", "list"]

---

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: server-read-bind
subjects:
- kind: ServiceAccount
  name: server
  namespace: prod
roleRef:
  kind: Role
  name: server-read
  apiGroup: rbac.authorization.k8s.io



```

Com isso, criamos a nossa serviceaccount, criamos a nossa role e agora atribuimos a nossa role ao nosso serviceaccount. Entao vamos ver se vai funcionar.

```bash
❯ kubectl apply -f k8s/namespaces/security.yaml
serviceaccount/server unchanged
role.rbac.authorization.k8s.io/server-read unchanged
rolebinding.rbac.authorization.k8s.io/server-read-bind created
```



Estã agora funcionando? Nao ainda! Pq ainda temos que falar para o nosso deployment que a serviceaccount que ele vai utilizar agora é o server!

Enatao vamos configurar o nosso deployment e, em cima das nossas especificaçoes, antes do container, inserimos a configuraçao de sericeaccount:  server

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: server
spec:
  selector:
    matchLabels:
      app: server
  template:
    metadata:
      labels:
        app: server
    spec:
      serviceAccount: server
      containers:
      - name: server
        image: rogeriocassares/hello-express
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 3000

```

Agora, nesse deploment estamos falando: Quando esse deployment for criado, a serviceAccount desse deployment que vai utilizar, os pods que vao ser criados em cima dessa serviceaccount vai ser o server. E o server como serviceaccount vai ter a role chamada de server-read, que dá acesso a nós listarmos, tantos os nossos pods, como os nossos services etc. Fora isso nao dá mais para fazer nada. 

Em tese, agora, a nossa aplicaçao, se alguem for ter acesso a ela, nao iria conseguir escalar esse acesso para o restante do nosso cluster k8s.

Vamos aplicar:

```bash
❯ kubectl apply -f k8s/namespaces/deployment.yaml 
deployment.apps/server created
```

```bash
❯ kubectl get po
NAME                        READY   STATUS    RESTARTS        AGE
...
server-7d6c74d698-n7xsv     1/1     Running   0               79s
```

Vamos descrevê-lo

```bash
❯ kubectl describe po server-7d6c74d698-n7xsv
Name:             server-7d6c74d698-n7xsv
Namespace:        default
Priority:         0
Service Account:  server
Node:             k3d-fullcycle-server-0/172.21.0.2
Start Time:       Fri, 10 Feb 2023 21:33:14 -0300
Labels:           app=server
                  pod-template-hash=7d6c74d698
Annotations:      <none>
Status:           Running
IP:               10.42.0.14
IPs:
  IP:           10.42.0.14
Controlled By:  ReplicaSet/server-7d6c74d698
Containers:
  server:
    Container ID:   containerd://a75dc1261860b73c218bc8d183f831a6f247f003b70b908b9a31bf47811457e3
    Image:          rogeriocassares/hello-express
    Image ID:       docker.io/rogeriocassares/hello-express@sha256:06997702425f89e928b0bc89ca3aa8db5c2b8489ed0d256607d822e5c2a07d43
    Port:           3000/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Fri, 10 Feb 2023 21:33:47 -0300
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     500m
      memory:  128Mi
    Requests:
      cpu:        500m
      memory:     128Mi
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-mxlgv (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-mxlgv:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Guaranteed
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  2m36s  default-scheduler  Successfully assigned default/server-7d6c74d698-n7xsv to k3d-fullcycle-server-0
  Normal  Pulling    2m24s  kubelet            Pulling image "rogeriocassares/hello-express"
  Normal  Pulled     2m4s   kubelet            Successfully pulled image "rogeriocassares/hello-express" in 20.237085134s
  Normal  Created    2m4s   kubelet            Created container server
  Normal  Started    2m4s   kubelet            Started container server
```



E agora vamos ver se ,udou em Mounts e vimos que ele nao esta mais usando o default, e sim o token! 

Entao se alguem agora de dentro daquele nosso Pod tentar acessar aapi do k8s simplesmente nao vai conseguir pq ele nao tem permissoes para isso. 

E somente de fazer isso, mesmo sendo algo muito simples como copiar, colar e aplicar em nossos pods, já teremmos uma super paz de espirito pq no minimo trouxemos um poc mais de segurança para o nosso cluster k8s.



### Cluster Role

Algumas diferenças sutis que temos nos Roles e no RoleBinding.

O que que acontece é que quando fizemos as configurações e criamos o nsso Role server-read etc, ele dá acesso aos componentes dos apiGroups baseados dentro do namespace que estávamos colocando pq o role vai trabalhar apenas no namespace que utilizamos ali por padrao. 

Agora, e se quiséssemos fazer isso em relacao ao cluster como um todo? E se quiséssemos que em algum ommento todo mundo que tivesse ali, por exemplo em nosso serviceaccount server pudesse listar, watch, get e pegar as informaçoes de todos os pods que ele está trabalhando? COmo conseguiriamos ampliar todo esse escopo ali para gente. 

Nesse caso temos um outro tipo de role que consegumis fazer e isso acaba expandindo de forma geral para todo o nosso cluster e nao somente ali focado em nosso namespace. Para isso, o objeto é similar, mas outro. 



Ao inves de colocarmos Role, colocaremos ClusterROle. Entao esse grpo de permissionamento que estamos colocando é agora em nivel de CLuster!

 E a mesma coisa ali no RoleBinding! COlocaremos ClusterRoleBinding.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: server

---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: server-read
rules:
- apiGroups: [""]
  resources: ["pods, services"]
  verbs: ["get", "watch", "list"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "watch", "list"]

---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: server-read-bind
subjects:
- kind: ServiceAccount
  name: server
  namespace: prod
roleRef:
  kind: ClusterRole
  name: server-read
  apiGroup: rbac.authorization.k8s.io



```

Entao quando aplicamos esse arquivo, esse novo nivel de permissao começa a ser aplicado a nivel de cluster.

```bash
❯ kubectl apply -f k8s/namespaces/security.yaml  
serviceaccount/server unchanged
clusterrole.rbac.authorization.k8s.io/server-read created
clusterrolebinding.rbac.authorization.k8s.io/server-read-bind created
```



Agora, por exemplo, se alguem acessar o nosso pod e tentar pegar quais sao os Pods que estao no namespace kubesystem, esse cara vai conseguir pq estamos utilizando o CLusterROle, isto é, dando acesso ao cluster de forma geral e nao mais somente àquele namespace. 

Esse tipo de coisa é muito importante entendermos pelo menos as diferen~ca. 

COmo devs de forma geral nao precisamos ir no detalhe, mas tratando0se dessa segurança basica, que nao é algo tao dificil, vale muito apena entendermos e como podemos fazer.

De forma geral, o Wesey costuma trabalhar apenas com Role e RoleBinding pq estamos focando na granularidade da nossa aplicaç"ao que estamos colocando no ar.

Normalmente, se estivermos querendo gerenciar o nosso cluster de forma mais geral, que normalmente nao é dev que façam mas pode vir a ser, ai podemos trabalhar com CLusterRole e ClusterRoleBinding!

























