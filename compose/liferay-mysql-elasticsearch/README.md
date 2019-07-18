### Run in Local Dev

```console
$ git clone https://github.com/igor-baiborodine/docker-liferay-portal-ce.git
$ cd docker-liferay-portal-ce/compose/liferay-mysql-elasticsearch   
$ docker-compose up -d
```
Wait for it to initialize completely, and visit http://localhost:80 or http://host-ip:80 (as appropriate).

#### References
 - [Configuring the Adapter with an OSGi `.config` File](https://portal.liferay.dev/docs/7-1/deploy/-/knowledge_base/d/configuring-the-liferay-elasticsearch-connector#configuring-the-adapter-with-an-osgi-config-file)
