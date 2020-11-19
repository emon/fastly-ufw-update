# fastly-allow-ufw

https://api.fastly.com/public-ip-list
で公開されている Fastly のIPアドレスリストを定期的に取得し、
それらのIPアドレスから本サーバへ sftp 接続できるよう、
ufw のルールを更新する。
