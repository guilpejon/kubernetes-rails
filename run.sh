###############
# DOCKER STEP #
###############

# build the image
docker build -t guilpejon/kubernetes-rails-example:latest .

# run the image
docker run -p 3000:3000 guilpejon/kubernetes-rails-example:latest

# push the image to dockerhub
docker push guilpejon/kubernetes-rails-example:latest

###################
# KUBERNETES STEP #
###################

# download the config file from the kubernetes cluster and put it in ~/.kube/
# then you can export KUBECONFIG or use --kubeconfig in the kubectl calls
export KUBECONFIG=~/.kube/kubernetes-rails-kubeconfig.yaml

# give the docker credentials on dockerhub to kubernetes since it is a private repo
kubectl create secret docker-registry my-docker-secret --docker-server=DOCKER_REGISTRY_SERVER --docker-username=DOCKER_USER --docker-password=DOCKER_PASSWORD --docker-email=DOCKER_EMAIL
kubectl edit serviceaccounts default
# add this after "secrets:"
# imagePullSecrets:
# - name: my-docker-secret

# apply the configuration on config/kube and creates the load balancer
kubectl apply -f config/kube

# find "LoadBalancer Ingress:" in the command bellow to learn the IP of the cluster
kubectl describe service kubernetes-rails-load-balancer

#######################
# KUBERNETES COMMANDS #
#######################

# check if the pods are running properly
kubectl get pods
# get details about a pod
kubectl describe pod pod-name

# check if the services are running properly
kubectl get services
# get details about a service
kubectl describe service service-name

# fix configurations and regenerate the pods
kubectl delete --all pods

###########
# SECRETS #
###########

# get the value from config/master.key
# important to run this after the pod is alive
kubectl create secret generic rails-secrets --from-literal=rails_master_key='example'

###############
# CLEANING UP #
###############

# get all pods, services and deployments
kubectl get pods,services,deployments

# delete all pods, services and deployments
kubectl delete pods,services,deployments --all
