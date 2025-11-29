# Дипломный практикум в Yandex.Cloud - Лепишин Алексей
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
     * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
     * [Решение "Создание облачной инфраструктуры"](#решение-создание-облачной-инфраструктуры)
     * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
     * [Решение "Создание Kubernetes кластера"](#решение-создание-kubernetes-кластера)
     * [Создание тестового приложения](#создание-тестового-приложения)
     * [Решение "Создание тестового приложения"](#решение-создание-тестового-приложения)
     * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
     * [Решние "Подготовка cистемы мониторинга и деплой приложения"](#решние-подготовка-cистемы-мониторинга-и-деплой-приложения)
     * [Деплой инфраструктуры в terraform pipeline](#деплой-инфраструктуры-в-terraform-pipeline)
     * [Решение "Деплой инфраструктуры в terraform pipeline"](#решение-деплой-инфраструктуры-в-terraform-pipeline)
     * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
     * [Решние "Установка и настройка CI/CD"](#решние-установка-и-настройка-cicd)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
Для облачного k8s используйте региональный мастер(неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://developer.hashicorp.com/terraform/language/backend) для Terraform:  
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)
3. Создайте конфигурацию Terrafrom, используя созданный бакет ранее как бекенд для хранения стейт файла. Конфигурации Terraform для создания сервисного аккаунта и бакета и основной инфраструктуры следует сохранить в разных папках.
4. Создайте VPC с подсетями в разных зонах доступности.
5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://developer.hashicorp.com/terraform/language/backend) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий, стейт основной конфигурации сохраняется в бакете или Terraform Cloud
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

#### Решение "Создание облачной инфраструктуры"

1. Сервисный аккаунт

- Создаем сервисный аккаунт из папки [**service-account**](https://github.com/Liberaty/diplom/blob/main/service-account) с правами editor. Для дальнейшей работы из под этого сервисного аккаунта понадобятся его id и ключ, их выводим в output как sensitive данные, которые можно будет затем увидеть командами ```terraform output -json service_account_keys | jq -r '.access_key'``` и ```terraform output -json service_account_keys | jq -r '.secret_key'``` . Они нам понадобятся в дальнейшем в terraform.tfvars файле и в backend.hcl

![1.1.png](https://github.com/Liberaty/diplom/blob/main/img/1.1.png?raw=true)

- Убедимся, что сервисный аккаунт создан

![1.2.png](https://github.com/Liberaty/diplom/blob/main/img/1.2.png?raw=true)

2. S3 хранилище

- Создаём папку [**backend**](https://github.com/Liberaty/diplom/blob/main/backend), где в terraform.tfvars добавляем полученные ранее id и ключ при создании сервисного аккаунта (пример в [**terraform.tfvars.example**](https://github.com/Liberaty/diplom/blob/main/backend/terraform.tfvars.example)). В [**bucket.tf**](https://github.com/Liberaty/diplom/blob/main/backend/bucket.tf) создаем s3-bucket с именем **lepishin-tfstate** и добавляем на него права доступа явно для сервис аккаунта **terraform**

![1.3.png](https://github.com/Liberaty/diplom/blob/main/img/1.3.png?raw=true)

- Так же убедимся, что S3 создан

![1.4.png](https://github.com/Liberaty/diplom/blob/main/img/1.4.png?raw=true)

3. Backend

- Подготавливаем папку [**infrastructure**](https://github.com/Liberaty/diplom/blob/main/infrastructure), где в [**providers.tf**](https://github.com/Liberaty/diplom/blob/main/infrastructure/providers.tf) описываем ранее созданный бакет как бекенд для хранения стейт файла **terraform.tfstate**. Так как мы не можем использовать переменные в блоке backend "s3", то запишем значения ключей в файл **backend.hcl** (пример в [**backend.hcl.example**](https://github.com/Liberaty/diplom/blob/main/infrastructure/backend.hcl.example)), и запустим инициализацию с ключом ```terraform init -backend-config=backend.hcl``` 

![1.5.png](https://github.com/Liberaty/diplom/blob/main/img/1.5.png?raw=true)

- После применения убедимся, что файл terraform.tfstate создался в нашем бакете

![1.6.png](https://github.com/Liberaty/diplom/blob/main/img/1.6.png?raw=true)

4. VPC

- В файле [**vpc.tf**](https://github.com/Liberaty/diplom/blob/main/infrastructure/vpc.tf) описываем создание VPC с подсетями в разных зонах доступности (ru-central1-a,ru-central1-b,ru-central1-d) и теперь применим

![1.7.png](https://github.com/Liberaty/diplom/blob/main/img/1.7.png?raw=true)

- Видим, что сети созданы в различных зонах:

![1.8.png](https://github.com/Liberaty/diplom/blob/main/img/1.8.png?raw=true)

---
### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

#### Решение "Создание Kubernetes кластера"

1. VM для k8s

- Описываем в [**k8s-workers.tf**](https://github.com/Liberaty/diplom/blob/main/infrastructure/k8s-workers.tf) и в [**k8s-masters.tf**](https://github.com/Liberaty/diplom/blob/main/infrastructure/k8s-masters.tf) создание виртуальных машин для master и worker нод, размещенных в ранее созданных подсетях, далее применяем

![2.1.png](https://github.com/Liberaty/diplom/blob/main/img/2.1.png?raw=true)

- так же были созданы файлы [**ansible.tf**](https://github.com/Liberaty/diplom/blob/main/infrastructure/ansible.tf) и шаблон [**inventory.tftpl**](https://github.com/Liberaty/diplom/blob/main/infrastructure/templates/inventory.tftpl) для автоматической генерации [**inventory.yml**](https://github.com/Liberaty/diplom/blob/main/ansible/inventory/inventory.yml) при изменении IP адресов VM по пути ```diplom/ansible/kubespray/inventory/mycluster/inventory.ini```

![2.2.png](https://github.com/Liberaty/diplom/blob/main/img/2.2.png?raw=true)

2. Подготовка к установке k8s через Kubespray

- Воспользуемся Kubespray для деплоя кластера k8s. Для этого склонируем его репозиторий ```git submodule add -b v2.28.0 https://github.com/kubernetes-sigs/kubespray.git```, перейдем в скачанную папку ```cd kubespray```, включим виртуальное окружение ```source .venv/bin/activate``` и установим необходимые зависимости `pip install -r requirements.txt`.

- После скопируем папку `cp -rfp inventory/sample inventory/mycluster` и применим ```terraform apply```, чтобы заменился **/inventory/mycluster/inventory.ini**, в **inventory/mycluster/group_vars/all/all.yml** добавим версию `kube_version: 1.31.0`, а в **inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml** добавим `supplementary_addresses_in_ssl_keys:`, который будет содержать значение внешнего IP-адреса мастера в сертификате.

- Так же в **kubspray/ansible.cfg** добавил свои значения `private_key_file = ~/.ssh/id_ed25519` и `remote_user = cloud-user`, иначе playbook будет устанавливаться от текущего пользователя.

3. Установка k8s завершена

- После запуска `ansible-playbook -i inventory/mycluster/inventory.ini cluster.yml -b -v` получаем успешный результат:

![2.3.png](https://github.com/Liberaty/diplom/blob/main/img/2.3.png?raw=true)

4. Забираем `~/.kube/config` на локальную VM

- Забираем файл конфигурации с сервера для подключения к кластеру `ssh cloud-user@158.160.58.191 "sudo cat /etc/kubernetes/admin.conf" > ~/.kube/config`, меняем внутри файла адрес сервера **127.0.0.1** на наш внешний IP мастера и даем на него права `chmod 600 ~/.kube/config`. После чего проверяем доступ командой `kubectl get pods -n kube-system`:

![2.4.png](https://github.com/Liberaty/diplom/blob/main/img/2.4.png?raw=true)

---
### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

#### Решение "Создание тестового приложения"

1. Yandex Container Registry

- Создадим файл [**registry.tf**](https://github.com/Liberaty/diplom/blob/main/infrastructure/regestry.tf), который создаст Yandex Container Registry.

![3.1.png](https://github.com/Liberaty/diplom/blob/main/img/3.1.png?raw=true)

2. Подготовка репозитория для тестового приложения

- Создадим новый репозиторий [**test-app**](https://github.com/Liberaty/test-app), который наполним файлами:

- 1. [**Dockerfile**](https://github.com/Liberaty/test-app/blob/main/Dockerfile)

- 2. [**index.html**](https://github.com/Liberaty/test-app/blob/main/index.html)

- 3. [**nginx.conf**](https://github.com/Liberaty/test-app/blob/main/nginx.conf)

3. Docker-образ

- Сначала соберем образ ```docker build -t cr.yandex/crpmfosr6bfe40c2vn2j/test-app:1.0.0 .``` и потом запушим его в наш **registry** ```docker push cr.yandex/crpmfosr6bfe40c2vn2j/test-app:1.0.0```

![3.2.png](https://github.com/Liberaty/diplom/blob/main/img/3.2.png?raw=true)

4. Контейнер в YCR

- Проверяем, что образ появился в нашем registry

![3.3.png](https://github.com/Liberaty/diplom/blob/main/img/3.3.png?raw=true)

![3.4.png](https://github.com/Liberaty/diplom/blob/main/img/3.4.png?raw=true)

---
### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:
1. Воспользоваться пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). Альтернативный вариант - использовать набор helm чартов от [bitnami](https://github.com/bitnami/charts/tree/main/bitnami).

#### Решние "Подготовка cистемы мониторинга и деплой приложения"

1. Prometheus+Grafana

- Добавим helm репозиторий `helm repo add prometheus-community https://prometheus-community.github.io/helm-charts`, и запустим установку командой `helm install kube-prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace`, в итоге получаем результат

![4.1.png](https://github.com/Liberaty/diplom/blob/main/img/4.1.png?raw=true)

- Проверяем, что все поды в namespace monitoring запущены командой `kubectl get pods -o wide -n monitoring` и видим, что всё ок

![4.2.png](https://github.com/Liberaty/diplom/blob/main/img/4.2.png?raw=true)

2. Deploy приложения

- Для деплоя нашего приложения, в папке [**k8s-configs**](https://github.com/Liberaty/diplom/blob/main/k8s-configs), создаём манифесты с помощью terraform, написав не хитрый файлик **k8s-create-configs.tf**(https://github.com/Liberaty/diplom/blob/main/infrastructure/k8s-create-configs.tf), который создаёт их по шаблонам из этой папки [**templates**](https://github.com/Liberaty/diplom/blob/main/k8s-configs/templates):

- 1. [**namespace.yaml**](https://github.com/Liberaty/diplom/blob/main/k8s-configs/namespace.yaml)
- 2. [**deployment.yaml**](https://github.com/Liberaty/diplom/blob/main/k8s-configs/deployment.yaml)
- 3. [**service.yaml**](https://github.com/Liberaty/diplom/blob/main/k8s-configs/service.yaml) 

![4.3.png](https://github.com/Liberaty/diplom/blob/main/img/4.3.png?raw=true)

- Теперь применим эти манифесты и теперь видим что поды запущены

![4.4.png](https://github.com/Liberaty/diplom/blob/main/img/4.4.png?raw=true)

3. Настройка Ingress Controller

- Для того, чтобы и grafana и наше приложение работали по одному и тому же 80 порту, я установил ingress-nginx контроллер из `helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx` и запустил со следующими параметрами `helm install my-nginx-ingress-controller ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace --set controller.hostNetwork=true --set controller.service.enabled=false`.

![4.5.png](https://github.com/Liberaty/diplom/blob/main/img/4.5.png?raw=true)

- Далее с помощью **Terraform** также создал [**app-ingress.yaml**](https://github.com/Liberaty/diplom/blob/main/k8s-configs/app-ingress.yaml) и [**grafana-ingress.yaml**](https://github.com/Liberaty/diplom/blob/main/k8s-configs/grafana-ingress.yaml) и применил их

- После этого добавил в **configmap** код, указанный ниже, командой `kubectl -n monitoring edit cm kube-prometheus-grafana`:

```
[server]
domain = 158.160.118.67
root_url = http://158.160.118.67/monitor/
serve_from_sub_path = true
```

Это нужно для корректной работы Grafana на subpath, далее перезапустил kube-prometheus-grafana командой `kubectl -n monitoring rollout restart deploy/kube-prometheus-grafana`

- Убедимся, что по внешнему IP [**http://158.160.118.67/monitor**](http://158.160.118.67/monitor) открывается grafana

- - логин: admin
- - пароль: tower_watch

Видим, что дашборды мониторинга с данными присутствуют

![4.6.png](https://github.com/Liberaty/diplom/blob/main/img/4.7.png?raw=true)

- А по адресу [**http://158.160.118.67**](http://158.160.118.67) откроется наша статичная страница с приложением

![4.7.png](https://github.com/Liberaty/diplom/blob/main/img/4.7.png?raw=true)

### Деплой инфраструктуры в terraform pipeline

1. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ на 80 порту к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ на 80 порту к тестовому приложению.
5. Atlantis или terraform cloud или ci/cd-terraform

#### Решение "Деплой инфраструктуры в terraform pipeline"



---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.

#### Решние "Установка и настройка CI/CD"



---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)