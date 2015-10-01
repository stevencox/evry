#!/usr/bin/env bash

SPARK_LOCAL_IP=$(hostname -I | sed -e "s, ,,g")
export LIBPROCESS_IP=${SPARK_LOCAL_IP}

MESOS_NATIVE_JAVA_LIBRARY=/usr/local/lib/libmesos.so
export MESOS_MASTER=mesos://${SPARK_LOCAL_IP}:5050

export MASTER=$MESOS_MASTER
#export SPARK_EXECUTOR_URI=hdfs://mesos-prod.isilon-1.oscar.priv:8020/user/cluster/spark/spark-1.4.1-bin-hadoop2.4.tgz
export SPARK_EXECUTOR_URI=${STARS_DIST}/spark-1.5.0-bin-hadoop2.6.tgz

export SPARK_DAEMON_JAVA_OPTS+=""

echo "Initializing Spark Environment"
source ${STARS_CONF}/env.sh

