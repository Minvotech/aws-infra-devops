# elastick search :
helm repo add elastic https://helm.elastic.co
helm repo update
helm install elk-elasticsearch elastic/elasticsearch -f .\elk-stack\elasticsearch\values.yml --namespace elk

= > Uninstall :  helm uninstall elk-elasticsearch -n elk
# 1. Watch all cluster members come up.
#   $ kubectl get pods --namespace=elk -l app=elasticsearch-master -w
# 2. Retrieve elastic user's password.
#   $ kubectl get secrets --namespace=elk elasticsearch-master-credentials -ojsonpath='{.data.password}' | base64 -d
# 3. Test cluster health using Helm test.
#   $ helm --namespace=elk test elk-elasticsearch

# kibana :
helm install elk-kibana2 elastic/kibana -f .\elk-stack\kibana\values.yml  --namespace elk


# 1. Watch all containers come up.
#   $ kubectl get pods --namespace=elk -l release=elk-kibana2 -w
# 2. Retrieve the elastic user's password.
#   $ kubectl get secrets --namespace=elk elasticsearch-master-credentials -ojsonpath='{.data.password}' | base64 -d
# 3. Retrieve the kibana service account token.
#   $ kubectl get secrets --namespace=elk elk-kibana2-kibana-es-token -ojsonpath='{.data.token}' | base64 -d

= > Uninstall :  helm uninstall elk-kibana2 -n elk
# logstash :
helm install elk-logstash elastic/logstash -f .\elk-stack\logstash\values.yml  --namespace elk
#$ kubectl get pods --namespace=elk -l app=elk-logstash-logstash -w

= > Uninstall :  helm uninstall elk-logstash -n elk

# filebeat :
helm install elk-filebeat elastic/filebeat .\elk-stack\filebeat\values.yml  --namespace elk

= > Uninstall :  helm uninstall elk-filebeat -n elk

#kubectl get pods --namespace=elk -l app=elk-filebeat-filebeat -w
