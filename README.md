# CRT_analysis
Bash скрипт будет отслеживать дату окончания действия CRL-файла и отправлять оповещение в Zabbix за две недели до истечения срока.
Скрипт будет проверять поле Next Update в CRL-файле и вычислять, сколько дней осталось до этой даты. Если до истечения срока осталось 14 дней или меньше, скрипт вернет значение 1 и 2 если срок истек. Это буду использовать в Zabbix для генерации триггера.

## Настройка в Zabbix:
Сохраните скрипт на сервере Zabbix, например, в /usr/lib/zabbix/alertscripts/check_crl_expiry.sh

Сделайте скрипт исполняемым:

bash'''
chmod +x /usr/lib/zabbix/alertscripts/check_crl_expiry.sh
chown zabbix:zabbix /usr/lib/zabbix/alertscripts/check_crl_expiry.sh
'''
Установите зависимости (если не установлены):

'''bash
#### #Для Debian/Ubuntu:
sudo apt install wget openssl

#### #Для CentOS/RHEL:
sudo yum install wget openssl
'''
Настройте элемент данных в Zabbix:

Name: CRL Expiry Check

Type: External check

Key: check_crl_expiry.sh

Type of information: Numeric (unsigned)

Update interval: 1d (раз в день)

Создайте триггеры:

Для предупреждения об истечении срока:

'''
{Your_Host:check_crl_expiry.sh.last()}=1
'''
Severity: Warning
Name: CRL will expire in 14 days

Для критического состояния (просроченный CRL):

text
{Your_Host:check_crl_expiry.sh.last()}=2
Severity: High
Name: CRL has expired

Настройте оповещения через Actions в Zabbix.
