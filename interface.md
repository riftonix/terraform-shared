# RouterOS iac interface

Цель: новые road-warrior клиенты, VPN egress-интерфейсы, маршрутизируемые подсети и DNS-имена должны добавляться в одном месте - в `iac/routeros/variables.tf`. `main.tf` должен в основном собирать производные структуры через `for`, а не содержать отдельные `locals` под каждый новый VPN.

## Что считаем сущностями

### Road-warrior client

Клиент WireGuard, который подключается к `wg-clients` и получает доступ к одному или нескольким egress.

Источник прав клиента - только `allowed_egress`.

```hcl
variable "road_warrior_clients" {
  description = "WireGuard road-warrior clients and their egress policy"
  type = map(object({
    address        = string
    comment        = optional(string)
    allowed_egress = optional(set(string), ["ru", "kz"])
    enabled        = optional(bool, true)
  }))
  default = {
    riftmob = {
      address        = "172.16.20.2/32"
      allowed_egress = ["ru", "kz", "cryptotrek"]
    }
    afinamob = {
      address        = "172.16.20.3/32"
      allowed_egress = ["ru", "kz"]
    }
    strogino = {
      address        = "172.16.20.4/32"
      allowed_egress = ["ru", "kz", "cryptotrek"]
    }
  }
}
```

Правило: чтобы дать клиенту доступ к новому VPN, добавляем имя egress в `allowed_egress`. Отдельные списки вида `cryptotrek_clients`, `cryptotrek_client_names`, `strogino_routes` не заводим.

### Egress

Egress - логический выход для policy routing. Он может быть:

- `ru`: основной интернет через `main`;
- `kz`: WireGuard backbone;
- `cryptotrek`: OpenVPN client;
- будущий OpenVPN/WireGuard выход.

Целевая переменная:

```hcl
variable "egresses" {
  description = "Traffic egress definitions used by RouterOS policy routing and firewall"
  type = map(object({
    enabled = optional(bool, true)

    routing_table = optional(string)
    gateway       = optional(string)

    destination_prefixes        = optional(set(string), [])
    destination_prefix_sets     = optional(set(string), [])
    static_destination_prefixes = optional(set(string), [])
    dns_names                   = optional(set(string), [])
    dns_forward_to              = optional(list(string), [])

    allow_sources = optional(bool, true)
    create_nat    = optional(bool, false)
    comment       = optional(string)
  }))
  default = {
    ru = {
      routing_table = "main"
      comment       = "RU egress"
    }

    kz = {
      routing_table            = "to-kz"
      gateway                  = "wg-backbone"
      destination_prefix_sets  = ["kz_asns"]
      dns_names                = [
        "ipinfo.io",
        "speedtest.net",
        "youtube.com",
        "youtu.be",
        "accounts.google.com",
        "*.googleapis.com",
        "*.gstatic.com",
        "gmail.com",
        "*.claude.ai",
        "*.anthropic.com",
        "*.claude.com",
      ]
      comment = "KZ egress"
    }

    cryptotrek = {
      routing_table = "to-cryptotrek"
      gateway       = "ovpn-cryptotrek"

      destination_prefixes = [
        "192.168.7.0/24",
        "192.168.11.0/24",
      ]

      allow_sources = true
      create_nat    = true
      comment       = "Cryptotrek OpenVPN egress"
    }
  }
}
```

`gateway` в этой переменной - имя RouterOS-интерфейса. Если интерфейс создается Terraform-модулем, `main.tf` может заменить это имя на output модуля, но в переменной все равно должно быть видно, куда логически направляется трафик.

Для egress есть две модели маршрутизации:

- `destination_prefixes` - policy-routing модель, как у `kz`: подсети попадают в address-list, клиенты получают routing mark, а отдельная routing table содержит default route через `gateway`.
- `static_destination_prefixes` - route-модель: подсети получают явные `/ip route` в `main` через `gateway`.

Для Cryptotrek используем `destination_prefixes`, чтобы доступ к удаленным подсетям получали только клиенты с `allowed_egress = "cryptotrek"`. Это исключает общий маршрут в `main` и не дает другим road-warrior клиентам случайно использовать OpenVPN-интерфейс.

### Prefix set

Некоторые маршруты не хочется писать руками. Например, `kz` сейчас строится из ASN и `collapse_prefixes.py`.

Чтобы не смешивать статические подсети и внешние источники, вводим отдельную переменную:

```hcl
variable "egress_prefix_sets" {
  description = "Reusable destination prefix sets for egress policy"
  type = map(object({
    type      = string
    resources = set(string)
  }))
  default = {
    kz_asns = {
      type = "asn"
      resources = [
        "AS15169",
        "AS396982",
        "AS36040",
        "AS399358",
        "AS62041",
        "AS62014",
        "AS59930",
        "AS32934",
        "AS13335",
      ]
    }
  }
}
```

На первом этапе можно оставить существующий `var.egress_asns`, но целевая форма лучше как `egress_prefix_sets`, потому что она позволяет добавить второй набор ASN или другой источник без новой переменной.

### OpenVPN client

OpenVPN-клиент - это отдельный интерфейс RouterOS. Для каждого клиента используем один экземпляр `routeros-openvpn-client`.

Целевая переменная:

```hcl
variable "openvpn_clients" {
  description = "RouterOS OpenVPN client interfaces"
  type = map(object({
    enabled = optional(bool, true)

    interface_name   = string
    ovpn_config_path = string

    egress = string

    ovpn_user_var         = optional(string)
    ovpn_password_var     = optional(string)
    key_passphrase_var    = optional(string)
    skip_cert_import      = optional(bool, false)
    create_nat            = optional(bool, true)
    comment               = optional(string)
  }))
  default = {
    cryptotrek = {
      interface_name   = "ovpn-cryptotrek"
      ovpn_config_path = "openvpn-clients/cryptotrek/cryptotrek.ovpn"
      egress           = "cryptotrek"
      comment          = "Cryptotrek OpenVPN egress"
    }
  }
}
```

Секреты остаются отдельными sensitive variables и приходят из `.envrc`. Не кладем секреты в `openvpn_clients.default`.

Для текущего Cryptotrek:

```hcl
variable "cryptotrek_openvpn_user" {
  type      = string
  sensitive = true
  default   = ""
}

variable "cryptotrek_openvpn_password" {
  type      = string
  sensitive = true
  default   = ""
}

variable "cryptotrek_openvpn_key_passphrase" {
  type      = string
  sensitive = true
  default   = ""
}
```

## Как должен выглядеть `main.tf`

### Нормализация входа

В `locals` оставляем только нормализацию и склейку производных данных:

```hcl
locals {
  road_warrior_clients = {
    for name, client in var.road_warrior_clients : name => client
    if client.enabled
  }

  enabled_egresses = {
    for name, egress in var.egresses : name => egress
    if egress.enabled
  }

  enabled_openvpn_clients = {
    for name, client in var.openvpn_clients : name => client
    if client.enabled
  }
}
```

Под конкретный egress не должно быть locals вида `cryptotrek_destination_prefixes` или `cryptotrek_forward_rules`, если это можно получить из `var.egresses`.

### Egress policy

`module.rurouter_egress_policy.egresses` должен собираться из `local.enabled_egresses`.

Идея:

```hcl
egresses = {
  for name, egress in local.enabled_egresses : name => {
    routing_table               = egress.routing_table
    gateway                     = local.egress_gateways[name]
    destination_prefixes        = local.egress_destination_prefixes[name]
    static_destination_prefixes = egress.static_destination_prefixes
    dns_names                   = egress.dns_names
    dns_forward_to              = egress.dns_forward_to
    comment                     = egress.comment
  }
}
```

`local.egress_gateways` решает техническую проблему Terraform: gateway для `kz` приходит из `module.rurouter_wireguard.interface_name`, gateway для OpenVPN - из соответствующего `module.rurouter_openvpn_clients[*].interface_name`, а `ru` остается `null` или `main`.

### Firewall

Forward-правила для egress должны строиться одинаково для всех egress, где `allow_sources = true`.

Разрешающие правила:

```hcl
allowed_forwards = {
  for entry in local.allowed_egress_forward_rules : entry.key => {
    src_address   = entry.src_address
    dst_address   = entry.dst_address
    out_interface = entry.out_interface
    comment       = entry.comment
  }
}
```

Где `local.allowed_egress_forward_rules` получается из трех источников:

- `road_warrior_clients`;
- `client.allowed_egress`;
- маршрутизируемых подсетей egress: для `kz` и `cryptotrek` это `destination_prefixes`; для egress с явными route в `main` это `static_destination_prefixes`.

То есть клиент получает forward только к тем подсетям, чей egress явно указан в его `allowed_egress`.

Drop-правила:

```hcl
drop_forwards = {
  for name, egress in local.enabled_egresses : "${name}_other" => {
    out_interface = local.egress_gateways[name]
    comment       = "Drop other traffic to ${name} egress"
  }
  if egress.allow_sources && local.egress_gateways[name] != null
}
```

Это блокирует попытку отправить через VPN трафик, который не был явно разрешен через `allowed_egress` и маршрутизируемые подсети egress.

NAT-правила строятся из тех же данных, но только для egress, где `create_nat = true`:

```hcl
srcnats = {
  for entry in local.egress_srcnat_rules : entry.key => {
    src_address   = entry.src_address
    dst_address   = entry.dst_address
    out_interface = entry.out_interface
    comment       = entry.comment
  }
}
```

Для Cryptotrek `create_nat = true`, потому что удаленная сторона не знает обратный маршрут до road-warrior адресов `172.16.20.x`. NAT должен быть scoped: только разрешенные клиенты, только Cryptotrek-подсети, только `out_interface = ovpn-cryptotrek`.

## Как добавлять новый OpenVPN egress

1. Создать директорию:

```text
iac/routeros/openvpn-clients/<name>/
```

2. Положить туда `.ovpn` и несекретные файлы рядом. Секретные `.ovpn`, `.key`, `.p12` остаются в `.gitignore`.

3. Добавить запись в `var.egresses`:

```hcl
newvpn = {
  routing_table = "to-newvpn"
  gateway       = "ovpn-newvpn"

  destination_prefixes = ["10.10.0.0/16"]
  allow_sources        = true
  create_nat           = true
  comment              = "New VPN egress"
}
```

4. Добавить запись в `var.openvpn_clients`:

```hcl
newvpn = {
  interface_name   = "ovpn-newvpn"
  ovpn_config_path = "openvpn-clients/newvpn/client.ovpn"
  egress           = "newvpn"
  comment          = "New VPN egress"
}
```

5. Добавить egress нужным клиентам:

```hcl
riftmob = {
  address        = "172.16.20.2/32"
  allowed_egress = ["ru", "kz", "cryptotrek", "newvpn"]
}
```

Больше ничего под конкретный `newvpn` в `main.tf` добавляться не должно.

## Этапы внедрения

### Этап 1: убрать egress-данные из `main.tf`

Добавить `variable "egresses"` и перенести туда:

- `cryptotrek.destination_prefixes`;
- `kz.dns_names`;
- комментарии egress;
- routing table names.

В `main.tf` оставить только вычисление module outputs и передачу данных в `routeros-egress-policy`.

### Этап 2: унифицировать firewall forward

Заменить `cryptotrek_forward_rules` на общий `allowed_egress_forward_rules`, который проходит по всем `var.egresses`.

После этого добавление второго OpenVPN не потребует нового `local.<vpn>_forward_rules`.

### Этап 3: стандартизировать OpenVPN clients

Добавить `variable "openvpn_clients"`.

Ограничение Terraform: если для каждого OpenVPN нужны разные sensitive variables, полностью универсальный `for_each` усложняется. Практичный вариант:

- описание интерфейса, файла и egress хранить в `var.openvpn_clients`;
- секреты оставить отдельными variables;
- в `main.tf` пока создавать модуль Cryptotrek явно, но брать `name`, `ovpn_config_path`, `egress`, `create_nat`, `comment` из `var.openvpn_clients["cryptotrek"]`.

Когда появится второй OpenVPN, станет понятно, достаточно ли этой схемы или нужно перейти к единой sensitive map.

### Этап 4: заменить `egress_asns` на `egress_prefix_sets`

Текущий `egress_asns` работает только для одного набора ASN. Если появится второй ASN-based egress, лучше перейти на `egress_prefix_sets`.

## Инварианты

- `allowed_egress` - единственное место, где задается, какие клиенты имеют право использовать egress.
- `egresses[*].destination_prefixes`, `egresses[*].static_destination_prefixes` и `egresses[*].dns_names` - единственное место, где задается, какой трафик уходит в egress.
- `main.tf` не содержит списков клиентов под конкретный egress.
- `main.tf` не содержит prefix/dns lists под конкретный egress, кроме временных bridge-locals на этапе миграции.
- OpenVPN-модуль не знает про firewall.
- Firewall не знает про конкретный Cryptotrek, только про общий egress contract.
- Один `routeros-openvpn-client` создает один RouterOS OpenVPN client interface.
