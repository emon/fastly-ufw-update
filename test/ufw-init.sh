#!/bin/sh

MAGIC_WORD='from https://api.fastly.com/public-ip-list'

while read IP dummy; do
    echo sudo ufw allow in from ${IP} to any port ssh comment "${MAGIC_WORD}"
         sudo ufw allow in from ${IP} to any port ssh comment "${MAGIC_WORD}"
done <<EOF
23.235.32.0/20	# Fastly
43.249.72.0/22	# Fastly
103.244.50.0/24	# Fastly
103.245.222.0/23	# Fastly
103.245.224.0/24	# Fastly
104.156.80.0/20	# Fastly
146.75.0.0/16	# Fastly
151.101.0.0/16	# Fastly
157.52.64.0/18	# Fastly
167.82.0.0/17	# Fastly
130.54.0.0/16	# dummy
133.3.0.0/16	# dummy
8.8.8.8/32	# dummy
EOF
