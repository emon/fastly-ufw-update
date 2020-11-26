# fastly-allow-ufw

https://api.fastly.com/public-ip-list
で公開されている Fastly のIPアドレスリストを定期的に取得し、
それらのIPアドレスから本サーバへ sftp 接続できるよう、
ufw のルールを更新する。

## 動作確認

ufw を有効にする。
```
sudo ufw enable
```

本スクリプトをダウンロードして、ufw にダミー用のルールを設定する。

```
git clone https://github.com/emon/fastly-ufw-update.git
cd fastly-ufw-update/
sudo ./test/ufw-test-setup.sh	# ufw にテスト用のダミーのルールを設定する
```
ダミーのルールとして、
- fastly の本物のIPアドレスの一部
- fastly とは関係のないIPアドレス

を登録している。

### ufw-update.sh

`ufw-update.sh` は引数にサブコマンド名を取る。
```

./script/ufw-update.sh
Usage: ./ufw-update.sh [command]
 show        - show local and fastly's latest rules
 show local  - show local ufw rules
 show remote - show fastly's latest rules
 diff        - diff local and remote
 apply       - apply latest rules
```

多くのサブコマンドは管理者権限が必要なため `sudo` 経由で実行する必要がある。

#### ufw-update.sh show
ローカル(ufw)の設定と、fastly の公開している最新情報を、それぞれ表示する。
下記でローカル設定として表示されているのは、上記の `ufw-test-setup.sh` で登録したダミーのルール。

```
sudo ./ufw-update.sh show
# local ufw rules
103.244.50.0/24
103.245.222.0/23
103.245.224.0/24
104.156.80.0/20
130.54.0.0/16
133.3.0.0/16
146.75.0.0/16
151.101.0.0/16
157.52.64.0/18
167.82.0.0/17
23.235.32.0/20
43.249.72.0/22
8.8.8.8
# fastly's latest rules
23.235.32.0/20
43.249.72.0/22
103.244.50.0/24
103.245.222.0/23
103.245.224.0/24
104.156.80.0/20
146.75.0.0/16
151.101.0.0/16
157.52.64.0/18
167.82.0.0/17
167.82.128.0/20
167.82.160.0/20
167.82.224.0/20
172.111.64.0/18
185.31.16.0/22
199.27.72.0/21
199.232.0.0/16
```

#### ufw-update.sh diff
ローカル設定と、fastly の公開している最新情報との差分を表示する。
```
sudo ./ufw-update.sh diff
@@ -5,2 +4,0 @@
-130.54.0.0/16
-133.3.0.0/16
@@ -10,0 +9,7 @@
+167.82.128.0/20
+167.82.160.0/20
+167.82.224.0/20
+172.111.64.0/18
+185.31.16.0/22
+199.232.0.0/16
+199.27.72.0/21
@@ -13 +17,0 @@
-8.8.8.8
```

#### ufw-update.sh apply

diff で表示されている差分を適用する。
環境変数 `DEBUG_LEVEL` に `1` を設定すると `ufw` での登録内容を表示する。

```
DEBUG_LEVEL=1 sudo --preserve-env=DEBUG_LEVEL ./ufw-update.sh apply
ufw delete allow in from 130.54.0.0/16 to any port ssh
Rule deleted
ufw delete allow in from 133.3.0.0/16 to any port ssh
Rule deleted
ufw allow in from 167.82.128.0/20 to any port ssh comment from https://api.fastly.com/public-ip-list
Rule added
ufw allow in from 167.82.160.0/20 to any port ssh comment from https://api.fastly.com/public-ip-list
Rule added
ufw allow in from 167.82.224.0/20 to any port ssh comment from https://api.fastly.com/public-ip-list
Rule added
ufw allow in from 172.111.64.0/18 to any port ssh comment from https://api.fastly.com/public-ip-list
Rule added
ufw allow in from 185.31.16.0/22 to any port ssh comment from https://api.fastly.com/public-ip-list
Rule added
ufw allow in from 199.232.0.0/16 to any port ssh comment from https://api.fastly.com/public-ip-list
Rule added
ufw allow in from 199.27.72.0/21 to any port ssh comment from https://api.fastly.com/public-ip-list
Rule added
ufw delete allow in from 8.8.8.8 to any port ssh
Rule deleted
```

再度実行すると差分が無いため、何も表示されない。
```
DEBUG_LEVEL=1 sudo --preserve-env=DEBUG_LEVEL ./ufw-update.sh apply
```

## cron での実行

`ufw-update.sh` と同一ディレクトリ内の `jq.py` を呼び出している。jquery をパースするためだけに利用している。
python3.8 で動作を確認した。

## rsyslog の設定

本リポジトリ内の rsyslog.d ディレクトリ内の設定ファイルをコピーして rsyslogd に適用する。
```
sudo cp fastly-allow-ufw/rsyslog.d/30-fastly-allow-ufw.conf /etc/rsyslog.d/
sudo systemctl restart rsyslog.service
sudo touch /var/log/fastly-ufw-update.log
```

`/var/log/fastly-ufw-update.log` に下記のようなログが残るようになる。

```log:/var/log/fastly-ufw-update.log
[debug] ./ufw-update.sh show
[debug] finished

[debug] ./ufw-update.sh diff
[debug] finished

[debug] ./ufw-update.sh apply
[info] ufw delete allow in from 130.54.0.0/16 to any port ssh
[info] ufw delete allow in from 133.3.0.0/16 to any port ssh
[info] ufw allow in from 167.82.128.0/20 to any port ssh comment from https://api.fastly.com/public-ip-list
[info] ufw allow in from 167.82.160.0/20 to any port ssh comment from https://api.fastly.com/public-ip-list
[info] ufw allow in from 167.82.224.0/20 to any port ssh comment from https://api.fastly.com/public-ip-list
[info] ufw allow in from 172.111.64.0/18 to any port ssh comment from https://api.fastly.com/public-ip-list
[info] ufw allow in from 185.31.16.0/22 to any port ssh comment from https://api.fastly.com/public-ip-list
[info] ufw allow in from 199.232.0.0/16 to any port ssh comment from https://api.fastly.com/public-ip-list
[info] ufw allow in from 199.27.72.0/21 to any port ssh comment from https://api.fastly.com/public-ip-list
[info] ufw delete allow in from 8.8.8.8 to any port ssh
[debug] finished

[debug] ./ufw-update.sh apply
[debug] finished
```
