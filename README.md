
#  Дипломная работа по профессии «Системный администратор» - Дьяков Владимир

### Задача
Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в [Yandex Cloud](https://cloud.yandex.com/) и отвечать минимальным стандартам безопасности: запрещается выкладывать токен от облака в git. Используйте [инструкцию](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart#get-credentials).

### Инфраструктура
Для развёртки инфраструктуры используйте Terraform и Ansible.  

Не используйте для ansible inventory ip-адреса! Вместо этого используйте fqdn имена виртуальных машин в зоне ".ru-central1.internal". Пример: example.ru-central1.internal  - для этого достаточно при создании ВМ указать name=example, hostname=examle !! 

Важно: используйте по-возможности **минимальные конфигурации ВМ**:2 ядра 20% Intel ice lake, 2-4Гб памяти, 10hdd, прерываемая. 

**Так как прерываемая ВМ проработает не больше 24ч, перед сдачей работы на проверку дипломному руководителю сделайте ваши ВМ постоянно работающими.**

Ознакомьтесь со всеми пунктами из этой секции, не беритесь сразу выполнять задание, не дочитав до конца. Пункты взаимосвязаны и могут влиять друг на друга.

### Сайт
Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.

Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.

Виртуальные машины не должны обладать внешним Ip-адресом, те находится во внутренней сети. Доступ к ВМ по ssh через бастион-сервер. Доступ к web-порту ВМ через балансировщик yandex cloud.

Настройка балансировщика:

1. Создайте [Target Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/target-group), включите в неё две созданных ВМ.

2. Создайте [Backend Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/backend-group), настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.

3. Создайте [HTTP router](https://cloud.yandex.com/docs/application-load-balancer/concepts/http-router). Путь укажите — /, backend group — созданную ранее.

4. Создайте [Application load balancer](https://cloud.yandex.com/en/docs/application-load-balancer/) для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.

Протестируйте сайт
`curl -v <публичный IP балансера>:80` 

### Мониторинг
Создайте ВМ, разверните на ней Zabbix. На каждую ВМ установите Zabbix Agent, настройте агенты на отправление метрик в Zabbix. 

Настройте дешборды с отображением метрик, минимальный набор — по принципу USE (Utilization, Saturation, Errors) для CPU, RAM, диски, сеть, http запросов к веб-серверам. Добавьте необходимые tresholds на соответствующие графики.

### Логи
Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.

### Сеть
Разверните один VPC. Сервера web, Elasticsearch поместите в приватные подсети. Сервера Zabbix, Kibana, application load balancer определите в публичную подсеть.

Настройте [Security Groups](https://cloud.yandex.com/docs/vpc/concepts/security-groups) соответствующих сервисов на входящий трафик только к нужным портам.

Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh.  Эта вм будет реализовывать концепцию  [bastion host]( https://cloud.yandex.ru/docs/tutorials/routing/bastion) . Синоним "bastion host" - "Jump host". Подключение  ansible к серверам web и Elasticsearch через данный bastion host можно сделать с помощью  [ProxyCommand](https://docs.ansible.com/ansible/latest/network/user_guide/network_debug_troubleshooting.html#network-delegate-to-vs-proxycommand) . Допускается установка и запуск ansible непосредственно на bastion host.(Этот вариант легче в настройке)

Исходящий доступ в интернет для ВМ внутреннего контура через [NAT-шлюз](https://yandex.cloud/ru/docs/vpc/operations/create-nat-gateway).

### Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.

---

## Выполнение работы

На локальной машине устанавливаем terraform, ansible, ус.

Создаем необходимые файлы конфигурации для [terraform](terraform/) и [ansible](ansible/). 

Разворачиваем инфраструктуру с помощью terraform.

```
cd terraform
terraform init
terraform plan
terraform apply
```

![img](img/01.png)

Инфраструктура развернута, сформирован файл инвентаря для ansible ([hosts.ini](./terraform/hosts.ini)).

Виртуальные машины:
![img](img/02.png)

Диски:
![img](img/03.png)

Расписание снимков:
![img](img/04.png)

Сеть и группы безопасности:
![img](img/05.png)
![img](img/06.png)
![img](img/07.png)

Балансировщик:
![img](img/08.png)
![img](img/09.png)
![img](img/10.png)
![img](img/11.png)

### Установка nginx

Разворачиваем nginx с помощью ansible на веб-серверах.

```
cd ../ansible
ansible-playbook nginx.yaml
```

![img](img/12.png)

Проверяем доступность сайта:

```
curl -v 158.160.180.23:80
```

![img](img/13.png)
![img](img/14.png)
![img](img/15.png)

### Установка Zabbix

Разворачиваем zabbix server с помощью ansible на ВМ zabbix.

```
ansible-playbook zserver.yaml
```

![img](img/16.png)

Проверяем работу fronted zabbix server:

![img](img/17.png)

Устанавливаем zabbix agent на веб-серверах.

```
ansible-playbook zagent.yaml
```

![img](img/18.png)

Добавляем hosts веб-серверов на zabbix server и привязываем шаблон.

![img](img/19.png)
![img](img/20.png)

Создаем dashboard.

![img](img/21.png)
![img](img/22.png)

### Установка elasticsearch, kibana, filebeat

Устанавливаем elasticsearch на ВМ elastic

```
ansible-playbook elastic.yaml
```

![img](img/23.png)

Устанавливаем kibana на ВМ kibana.

```
ansible-playbook kibana.yaml
```

![img](img/24.png)

Проверяем работу kibana:

![img](img/25.png)

Устанавливаем filebeat на веб-серверах.

```
ansible-playbook filebeat.yaml
```

![img](img/26.png)

Проверяем поступление логов nginx в elasticsearch.

![img](img/27.png)