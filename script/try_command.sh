#¡/bin/bash
MAX_LOOP=${TRIES:-3}
n=0
until [ $n -ge $MAX_LOOP ]
 do
    echo "Attempt $n"
    bash -c "$1" && break  # substitute your command here
    n=$[$n+1]
    sleep 5
done
if [ $n -eq $MAX_LOOP ] ;  then
 exit 1
fi
exit 0
