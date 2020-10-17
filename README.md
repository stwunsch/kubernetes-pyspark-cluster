# How to run a (Py)Spark cluster in standalone mode with Kubernetes

This repository explains how to run (Py)Spark 3.0.1 in standalone mode using Kubernetes. The standalone mode ([see here](https://spark.apache.org/docs/latest/spark-standalone.html)) uses a master-worker architecture to distribute the work from the application among the available resources.

See [here](https://github.com/stwunsch/docker-pyspark-cluster) for my notes about how to set up a similar cluster using docker compose.

## Install the required software

For the following instructions, I'll assume you have `python3`, `docker`, `minikube` and a Linux distribution running.

```bash
# Create and source a virtual Python environment
python3 -m venv py3_venv
source py3_venv/bin/activate

# Install the dependencies from the requirements.txt
pip install -r requirements.txt
```

## Start a local Kubernetes cluster

To test the Kubernetes configuration locally, you can use `minikube` to start your own local Kubernetes cluster. Typically, it's as simple as following:

```bash
# Start Kubernetes cluster
minikube start

# Check that the cluster is up
kubectl cluster-info
```

## Inspect, build and upload the docker image

The deployment of the Spark standalone cluster requires suitable container images, which will run the master and worker processes. These images have to be accessible from a container registry, e.g., [hub.docker.com](https://hub.docker.com). You can take the image from my public repository at [https://hub.docker.com/r/stwunsch/spark/tags](https://hub.docker.com/r/stwunsch/spark/tags) or use the following commands to build and upload the image from the [Dockerfile in this repository](Dockerfile). The Dockerfile downloads the Spark release 3.0.1 and makes the scripts `start-master.sh` and `start-slave.sh` accessible, which will be used to start the master and worker processes of the (Py)Spark cluster.

```bash
# Build and tag the image
docker build . -t <your user>/spark:3.0.1

# Upload the image (by default to Docker Hub)
docker push <your user>/spark:3.0.1
```

## Have a look at the Kubernetes configs

The Kubernetes configs are typically written in yaml files, see [`spark-master.yml`](spark-master.yml) and [`spark-worker.yml`](spark-worker.yml). In Kubernetes terminology, each of these files specify a deployment, one for the master and one for the multiple workers.

The deployment of the master contains an additional service, which exposes the Spark cluster to the outside of the Kubernetes cluster. The default Spark port 7077 is accessible from the outside via the port 30000 via the IP of the Kubernetes cluster, which can be found by running `minikube ip`. Further, the service exposes port 30001, which allows us to access the Spark web UI to verify easily the working state of the deployment.

The deployment of the workers follows the same schema than the master but without the service. The service of the master deployment allows to connect the workers to the master via the hostname `spark-master-service`, no further configuration is required. The configuration allows you to set the number of workers via the number of `replicas` and the environment variabes `SPARK_WORKER_CORES` and `SPARK_WORKER_MEMORY` injected into the containers control the resources attributed to each worker.

## Start the master and workers as Kubernetes deployments

Use the following commands to start the master and worker processes.

```bash
# Deploy the master
kubectl apply -f spark-master.yml

# Deploy the workers
kubectl apply -f spark-worker.yml
```

To check the health of the system, you can access the web UI of the Spark master via the IP returned by `minikube ip` and the port 30001 in your browser with `http://<ip return by minikube ip>:30001`. Alternatively we can ask the Kubernetes cluster about the details of the deployments:

```
# Print all Kubernetes resources
kubectl get all

# Get detailed information about specific resources
kubectl describe <name of a resource, e.g., deployment.apps/spark-master>
```

## Test it!

After sourcing the Python virtual environment (see above), you can run the test program in [`test.py](test.py) on the Spark cluster managed by Kubernetes. Note the lines in the script, which get the cluster IP from the `minikube ip` command and insert this information in the Spark session.

```bash
# Calculate Pi
python test.py
```

Further, you can play with the scaling features of Kubernetes, which allow to scale up or down the number of workers easily. On top, you get a fail safe deployment since lost workers (for any reason) are automatically replaced by Kuberenetes and register themselves again to the master. However, for a fail safe deployment of the master, additional steps would have to be taken.

```bash
# Scale up to 8 workers
kubectl scale deployment.apps/spark-worker --replicas=8
```

## Shut down the Kubernetes cluster

To shut down the deployments, you can use the labels `app=spark`, `role=master` or `role=worker` and the command `kubectl delete`:

```bash
# Delete all workers
kubectl delete all -l role=worker

# Delete the master
kubectl delete all -l role=master

# Or delete everything in one go
kubectl delete all -l app=spark

# Shut down the Kubernetes cluster
minikube stop
```
