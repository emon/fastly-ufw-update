#!/bin/sh

# sample of rules
# [ 1] 22/tcp                     ALLOW IN    23.235.32.0/20             # from https://api.fastly.com/public-ip-list
# [ 2] 22/tcp                     ALLOW IN    43.249.72.0/22             # from https://api.fastly.com/public-ip-list
# [ 3] 22/tcp                     ALLOW IN    103.244.50.0/24            # from https://api.fastly.com/public-ip-list
# [ 4] 22/tcp                     ALLOW IN    103.245.222.0/23           # from https://api.fastly.com/public-ip-list
# [ 5] 22/tcp                     ALLOW IN    103.245.224.0/24           # from https://api.fastly.com/public-ip-list
# [ 6] 22/tcp                     ALLOW IN    104.156.80.0/20            # from https://api.fastly.com/public-ip-list
# [ 7] 22/tcp                     ALLOW IN    146.75.0.0/16              # from https://api.fastly.com/public-ip-list
# [ 8] 22/tcp                     ALLOW IN    151.101.0.0/16             # from https://api.fastly.com/public-ip-list
# [ 9] 22/tcp                     ALLOW IN    157.52.64.0/18             # from https://api.fastly.com/public-ip-list
# [10] 22/tcp                     ALLOW IN    167.82.0.0/17              # from https://api.fastly.com/public-ip-list
# [11] 22/tcp                     ALLOW IN    130.54.0.0/16              # from https://api.fastly.com/public-ip-list
# [12] 22/tcp                     ALLOW IN    133.3.0.0/16               # from https://api.fastly.com/public-ip-list
# [13] 22/tcp                     ALLOW IN    8.8.8.8                    # from https://api.fastly.com/public-ip-list


MAGIC_WORD='from https://api.fastly.com/public-ip-list'

ufw status numbered | tee /dev/stderr | tac | grep "${MAGIC_WORD}" | while read rule; do
    NUM=`echo $rule | grep -o '\[[[:space:]]*[0-9]*\]' | grep -o '[0-9]*'`
    echo  ufw delete ${NUM}
    yes | ufw delete ${NUM}
done
