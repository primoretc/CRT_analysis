# CRT_analysis
Bash скрипт будет отслеживать дату окончания действия CRL-файла (Certificate Revocation List)) и отправлять оповещение в Zabbix за две недели до истечения срока.
Скрипт будет проверять поле Next Update в CRL-файле и вычислять, сколько дней осталось до этой даты. Если до истечения срока осталось 14 дней или меньше, скрипт вернет значение 1 и 2 если срок истек. Это буду использовать в Zabbix для генерации триггера.



## Настройка в Zabbix:
Сохранить скрипт на сервере Zabbix, например, в /usr/lib/zabbix/alertscripts/check_crl_expiry.sh

Сделать скрипт исполняемым:

```
chmod +x /usr/lib/zabbix/alertscripts/check_crl_expiry.sh
chown zabbix:zabbix /usr/lib/zabbix/alertscripts/check_crl_expiry.sh
```
Установить зависимости (если не установлены):

```
#Для Debian/Ubuntu:
sudo apt install wget openssl

#Для CentOS/RHEL:
sudo yum install wget openssl
```

Настроить элемент данных в Zabbix:

**Name:** ```CRL Expiry Check```

**Type:** ```External check```

**Key:** ```check_crl_expiry.sh```

**Type of information:** ```Numeric (unsigned)```

**Update interval:** ```1d (раз в день)```

Создайте триггеры:

Для предупреждения об истечении срока:

**Expression** ```{Your_Host:check_crl_expiry.sh.last()}=1```

**Severity:** ```Warning```
**Name:**  ```CRL will expire in 14 days```

Для критического состояния (просроченный CRL):

**Expression** ```{Your_Host:check_crl_expiry.sh.last()}=2```
**Severity:** ```High```
**Name:** ```CRL has expired```

## Важные замечания:
**Формат CRL-файла:** Убедиться, что в скрипте указан правильный формат CRL-файла (DER или PEM). По умолчанию используется DER. Если файл в формате PEM, закомментировать строку с -inform DER и раскомментировать строку с -inform PEM.

**Временная зона:** Убедиться, что временная зона сервера совпадает с временной зоной в CRL-файле, чтобы расчет дней был точным.

**Частота проверки:** Рекомендуется запускать проверку раз в день, чтобы избежать излишней нагрузки.



Настроить оповещения через Actions в Zabbix.
