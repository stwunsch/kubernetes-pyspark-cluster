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
