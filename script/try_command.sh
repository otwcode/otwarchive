#¡/bin/bash
MAX_LOOP=${TRIES:-3}
n=0
export TEST_RUN="$1"
if [ -n "$3" ] ; then
  export CFG_NAME="$3"
fi
echo "Browserstack config: <${CFG_NAME}><${COFG_NAME}>" 
rm /tmp/coverage.tar
tar cvf /tmp/coverage.tar ./coverage
until [ $n -ge $MAX_LOOP ]
 do
    echo "Attempt $n"
    bash -c "$2" && break  # substitute your command here
    n=$[$n+1]
    rm -rf ./coverage
    tar xvfp /tmp/coverage.tar
done
if [ $n -eq $MAX_LOOP ] ;  then
 exit 1
fi
exit 0
