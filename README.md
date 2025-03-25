# Курсовая работа на профессии "DevOps-инженер с нуля" - `Сулименков Алексей`

# Содержание

- [Задача](#Задача)
- [Инфраструктура](#Инфраструктура)
  - [Сайт](#Сайт)
  - [Мониторинг](#Мониторинг)
  - [Логи](#Логи)
  - [Сеть](#Сеть)
  - [Резервное копирование](#Резервное-копирование)
  - [Дополнительно](#Дополнительно)
- [Выполнение работы](#Выполнение-работы)
- [Критерии сдачи](#Критерии-сдачи)
- [Как правильно задавать вопросы дипломному руководителю](#Как-правильно-задавать-вопросы-дипломному-руководителю)

---

## Задача

Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в [Yandex Cloud](https://cloud.yandex.com/).

**Примечание**: в курсовой работе используется система мониторинга Prometheus. Вместо Prometheus вы можете использовать Zabbix. Задание для курсовой работы с использованием Zabbix находится по [ссылке](https://github.com/netology-code/fops-sysadm-diplom/blob/diplom-zabbix/README.md).

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

## Инфраструктура

Для развёртки инфраструктуры используйте Terraform и Ansible.

Параметры виртуальной машины (ВМ) подбирайте по потребностям сервисов, которые будут на ней работать.

Ознакомьтесь со всеми пунктами из этой секции, не беритесь сразу выполнять задание, не дочитав до конца. Пункты взаимосвязаны и могут влиять друг на друга.

### Сайт

Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.

Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.

Создайте [Target Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/target-group), включите в неё две созданных ВМ.

Создайте [Backend Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/backend-group), настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.

Создайте [HTTP router](https://cloud.yandex.com/docs/application-load-balancer/concepts/http-router). Путь укажите — /, backend group — созданную ранее.

Создайте [Application load balancer](https://cloud.yandex.com/en/docs/application-load-balancer/) для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.

Протестируйте сайт
`curl -v <публичный IP балансера>:80`

### Мониторинг

Создайте ВМ, разверните на ней Prometheus. На каждую ВМ из веб-серверов установите Node Exporter и [Nginx Log Exporter](https://github.com/martin-helmich/prometheus-nginxlog-exporter). Настройте Prometheus на сбор метрик с этих exporter.

Создайте ВМ, установите туда Grafana. Настройте её на взаимодействие с ранее развернутым Prometheus. Настройте дешборды с отображением метрик, минимальный набор — Utilization, Saturation, Errors для CPU, RAM, диски, сеть, http_response_count_total, http_response_size_bytes. Добавьте необходимые [tresholds](https://grafana.com/docs/grafana/latest/panels/thresholds/) на соответствующие графики.

### Логи

Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.

### Сеть

Разверните один VPC. Сервера web, Prometheus, Elasticsearch поместите в приватные подсети. Сервера Grafana, Kibana, application load balancer определите в публичную подсеть.

Настройте [Security Groups](https://cloud.yandex.com/docs/vpc/concepts/security-groups) соответствующих сервисов на входящий трафик только к нужным портам.

Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh. Настройте все security groups на разрешение входящего ssh из этой security group. Эта вм будет реализовывать концепцию bastion host. Потом можно будет подключаться по ssh ко всем хостам через этот хост.

### Резервное копирование

Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.

---

## Ответ

Application load balancer http://158.160.153.202:80 если несколько раз обновить, видно изменение IP адреса VM

Grafana http://51.250.90.196:3000

Kibana http://158.160.35.17:5601

Конфигурационные файлы прилагаю.

<details> <summary>Terraform развернулся без ошибок</summary>

```log
yandex_vpc_network.network-1: Creating...
yandex_vpc_gateway.nat_gateway: Creating...
yandex_alb_http_router.tf-router: Creating...
yandex_alb_http_router.tf-router: Creation complete after 0s [id=ds7g2o3fkoaot4nfi1uh]
yandex_vpc_gateway.nat_gateway: Creation complete after 1s [id=enpkq164iic31dggq1vr]
yandex_vpc_network.network-1: Creation complete after 2s [id=enpcvre90earshl5a19r]
yandex_vpc_route_table.rt-1: Creating...
yandex_vpc_subnet.subnet-2: Creating...
yandex_vpc_subnet.subnet-1: Creating...
yandex_vpc_security_group.firewall-external-security: Creating...
yandex_vpc_security_group.elasticsearch_sg: Creating...
yandex_vpc_security_group.balancer-security: Creating...
yandex_vpc_security_group.prometheus_sg: Creating...
yandex_vpc_security_group.kibana_sg: Creating...
yandex_vpc_security_group.grafana_sg: Creating...
yandex_vpc_subnet.subnet-2: Creation complete after 1s [id=e2lbhl8i2ak5h8fbk221]
yandex_vpc_subnet.subnet-1: Creation complete after 2s [id=e9blgijjsr6qngchc3rp]
yandex_vpc_security_group.balancer-security: Creation complete after 3s [id=enpqfi9eea6c191o5pej]
yandex_alb_load_balancer.alb: Creating...
yandex_vpc_route_table.rt-1: Creation complete after 3s [id=enppr2lcoq12ik0rtgcq]
yandex_vpc_subnet.subnet-lan-b: Creating...
yandex_vpc_subnet.subnet-lan-a: Creating...
yandex_vpc_subnet.subnet-lan-a: Creation complete after 1s [id=e9bqjgjisadfj6uh861q]
yandex_compute_instance.vm1: Creating...
yandex_vpc_subnet.subnet-lan-b: Creation complete after 2s [id=e2lq2tif0k7q8pk4mr3b]
yandex_compute_instance.vm2: Creating...
yandex_vpc_security_group.grafana_sg: Creation complete after 5s [id=enpa89l45m86912d5jpc]
yandex_compute_instance.grafana: Creating...
yandex_vpc_security_group.prometheus_sg: Creation complete after 7s [id=enpvtneuilkt638blsup]
yandex_compute_instance.prometheus: Creating...
yandex_vpc_security_group.elasticsearch_sg: Creation complete after 10s [id=enptn36l0m6cigv6lgvs]
yandex_compute_instance.elasticsearch: Creating...
yandex_vpc_security_group.firewall-external-security: Still creating... [10s elapsed]
yandex_vpc_security_group.kibana_sg: Still creating... [10s elapsed]
yandex_alb_load_balancer.alb: Still creating... [10s elapsed]
yandex_compute_instance.vm1: Still creating... [10s elapsed]
yandex_compute_instance.vm2: Still creating... [10s elapsed]
yandex_compute_instance.grafana: Still creating... [10s elapsed]
yandex_vpc_security_group.firewall-external-security: Creation complete after 16s [id=enp5jn6k1od7disfm724]
yandex_compute_instance.firewall: Creating...
yandex_compute_instance.prometheus: Still creating... [10s elapsed]
yandex_compute_instance.elasticsearch: Still creating... [10s elapsed]
yandex_vpc_security_group.kibana_sg: Still creating... [20s elapsed]
yandex_alb_load_balancer.alb: Still creating... [20s elapsed]
yandex_compute_instance.vm1: Still creating... [20s elapsed]
yandex_compute_instance.vm2: Still creating... [20s elapsed]
yandex_compute_instance.grafana: Still creating... [20s elapsed]
yandex_vpc_security_group.kibana_sg: Creation complete after 26s [id=enppomef112kq95cgfd1]
yandex_compute_instance.kibana: Creating...
yandex_compute_instance.firewall: Still creating... [10s elapsed]
yandex_compute_instance.prometheus: Still creating... [20s elapsed]
yandex_compute_instance.elasticsearch: Still creating... [20s elapsed]
yandex_alb_load_balancer.alb: Still creating... [30s elapsed]
yandex_compute_instance.vm1: Still creating... [30s elapsed]
yandex_compute_instance.vm2: Still creating... [30s elapsed]
yandex_compute_instance.grafana: Still creating... [30s elapsed]
yandex_compute_instance.kibana: Still creating... [10s elapsed]
yandex_compute_instance.firewall: Still creating... [20s elapsed]
yandex_compute_instance.prometheus: Still creating... [30s elapsed]
yandex_compute_instance.elasticsearch: Still creating... [30s elapsed]
yandex_alb_load_balancer.alb: Still creating... [40s elapsed]
yandex_compute_instance.vm1: Still creating... [40s elapsed]
yandex_compute_instance.vm2: Still creating... [40s elapsed]
yandex_compute_instance.grafana: Still creating... [40s elapsed]
yandex_compute_instance.kibana: Still creating... [20s elapsed]
yandex_compute_instance.firewall: Still creating... [30s elapsed]
yandex_compute_instance.vm2: Creation complete after 42s [id=epdnu4o6v8up3h8i4rjs]
yandex_compute_instance.prometheus: Still creating... [40s elapsed]
yandex_compute_instance.elasticsearch: Still creating... [40s elapsed]
yandex_compute_instance.elasticsearch: Creation complete after 42s [id=fhmhab6itmfni9kd1u2g]
local_file.elasticsearch: Creating...
local_file.elasticsearch: Creation complete after 0s [id=6658224b5e6b2337508519b7ff986c9ff972f0b1]
yandex_alb_load_balancer.alb: Still creating... [50s elapsed]
yandex_compute_instance.vm1: Still creating... [50s elapsed]
yandex_compute_instance.prometheus: Creation complete after 47s [id=fhm5juo7au691akdvbrf]
local_file.prometheus: Creating...
local_file.prometheus: Creation complete after 0s [id=4ed48434646f1f2e207dd2cba2142ec4445b651f]
yandex_compute_instance.grafana: Still creating... [50s elapsed]
yandex_compute_instance.vm1: Creation complete after 51s [id=fhmrjrfap0vr5burg8vp]
yandex_alb_target_group.tg: Creating...
local_file.web: Creating...
local_file.web: Creation complete after 0s [id=b922be492439ed6dd3dd77f1c1d995b8ab12d09c]
yandex_alb_target_group.tg: Creation complete after 1s [id=ds70o6kq1q1pur19u33a]
yandex_alb_backend_group.bg: Creating...
yandex_compute_instance.kibana: Still creating... [30s elapsed]
yandex_alb_backend_group.bg: Creation complete after 0s [id=ds75pel35a1n3llcpu4n]
yandex_alb_virtual_host.my-virtual-host: Creating...
yandex_compute_instance.firewall: Still creating... [40s elapsed]
yandex_alb_virtual_host.my-virtual-host: Creation complete after 1s [id=ds7g2o3fkoaot4nfi1uh/my-virtual-host]
yandex_alb_load_balancer.alb: Still creating... [1m0s elapsed]
yandex_compute_instance.grafana: Creation complete after 58s [id=fhmm5egekchq8k0ivg93]
local_file.grafana: Creating...
local_file.grafana: Creation complete after 0s [id=e28e0e57594abf150445ba9c7dbb8f1db6960a25]
yandex_compute_instance.firewall: Creation complete after 48s [id=fhmc37h9p0prmo9g13du]
local_file.firewall: Creating...
local_file.firewall: Creation complete after 0s [id=cc1c4e3ac63cb64fa08a5208619a9668bc4a0f7e]
yandex_compute_instance.kibana: Still creating... [40s elapsed]
yandex_alb_load_balancer.alb: Still creating... [1m10s elapsed]
yandex_compute_instance.kibana: Creation complete after 48s [id=fhmincat8u9ng3liurv4]
local_file.kiabana: Creating...
local_file.kiabana: Creation complete after 0s [id=b5ff977133799776cfd58e316f8548b803d78bca]
yandex_alb_load_balancer.alb: Still creating... [1m20s elapsed]
yandex_alb_load_balancer.alb: Still creating... [1m30s elapsed]
yandex_alb_load_balancer.alb: Still creating... [1m40s elapsed]
yandex_alb_load_balancer.alb: Still creating... [1m50s elapsed]
yandex_alb_load_balancer.alb: Still creating... [2m0s elapsed]
yandex_alb_load_balancer.alb: Still creating... [2m10s elapsed]
yandex_alb_load_balancer.alb: Still creating... [2m20s elapsed]
yandex_alb_load_balancer.alb: Still creating... [2m30s elapsed]
yandex_alb_load_balancer.alb: Still creating... [2m40s elapsed]
yandex_alb_load_balancer.alb: Still creating... [2m50s elapsed]
yandex_alb_load_balancer.alb: Still creating... [3m0s elapsed]
yandex_alb_load_balancer.alb: Still creating... [3m10s elapsed]
yandex_alb_load_balancer.alb: Still creating... [3m20s elapsed]
yandex_alb_load_balancer.alb: Still creating... [3m30s elapsed]
yandex_alb_load_balancer.alb: Still creating... [3m40s elapsed]
yandex_alb_load_balancer.alb: Still creating... [3m50s elapsed]
yandex_alb_load_balancer.alb: Still creating... [4m0s elapsed]
yandex_alb_load_balancer.alb: Still creating... [4m10s elapsed]
yandex_alb_load_balancer.alb: Still creating... [4m20s elapsed]
yandex_alb_load_balancer.alb: Still creating... [4m30s elapsed]
yandex_alb_load_balancer.alb: Still creating... [4m40s elapsed]
yandex_alb_load_balancer.alb: Still creating... [4m50s elapsed]
yandex_alb_load_balancer.alb: Still creating... [5m0s elapsed]
yandex_alb_load_balancer.alb: Creation complete after 5m1s [id=ds7tlhnpp5h045i6cc6r]

Apply complete! Resources: 31 added, 0 changed, 0 destroyed.
```

</details>

После развертывания Firewall, он же Бастион, туда скопирован ключ ssh и папка ansible. С данной VM все устанавливалось через ansible.

#ОЧЕНЬ ДОРОГО, за час больше 200р, поэтому выключил .
![ОЧЕНЬ ДОРОГО](https://github.com/biparasite/HW-sysadm-diplom/blob/main/rental.png)

![ОЧЕНЬ ДОРОГО](https://github.com/biparasite/HW-sysadm-diplom/blob/main/ip.png)

![ОЧЕНЬ ДОРОГО](https://github.com/biparasite/HW-sysadm-diplom/blob/main/grafana.png)
