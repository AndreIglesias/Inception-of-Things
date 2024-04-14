# P1

## Creating a Kubernetes Cluster with K3s on Virtual Machines Provisioned by Vagrant

### Overview

This guide walks through the process of setting up a Kubernetes cluster using K3s on virtual machines provisioned by Vagrant. K3s is a lightweight Kubernetes distribution designed for resource-constrained environments, making it ideal for testing and development purposes.

## Steps to test

- Run the virtual machines:
```bash
vagrant up
```

- Connect ssh to server master:
```bash
vagrant ssh ciglesiaS
```

 - Verify ip addres:
 ```bash
ip addr | grep eth1
```

 - Check the cluster:
 ```bash
kubectl get nodes -o wide
```


## Vagrant

Vagrant is a command-line utility for managing the lifecycle of virtual machines. It allows you to isolate dependencies and their configurations within a single, disposable, and consistent environment.

## Initializing the Vagrant Project

To initialize the Vagrant project, choose the desired Debian box from [Debian Boxes](https://app.vagrantup.com/debian) and run:

```bash
vagrant init debian/bookworm64
```

## Managing Virtual Machines

- Start the Vagrant VM:
```bash
vagrant up
```
- SSH into a VM:
```bash
vagrant ssh ciglesiaS
```
- Check the status of active VMs:
```bash
vagrant global-status
```
- Reload the Vagrantfile and restart the VM:
```bash
vagrant reload --provision
```
- Destroy the virtual machines:
```bash
vagrant destroy -f
```

## K3S

> [!NOTE]
> [K3s](https://k3s.io/) is a lightweight Kubernetes distribution designed for resource-constrained environments.

K3s is like a mini-version of Kubernetes, the popular system for managing containerized applications. It's designed to work on computers or devices with limited resources, like laptops, IoT gadgets, or edge computing devices.

> [!NOTE]
> When you have a lot of different programs you want to run on your computer or a group of computers. Now, these programs might need different resources, like memory or processing power, and they might need to talk to each other. Managing all of this manually can get really complicated.
>
> Here's where Kubernetes (or K8s for short) comes in. It's like having a smart manager for your programs. Instead of you having to keep track of everything, Kubernetes does it for you. It makes sure each program gets what it needs to run smoothly and helps them communicate with each other.

> The server is configured in controller mode.
> The server worker is configured in agent mode.

![K3s](/docs/k3s.svg)

### Installation

Simple **server** and **Agent** setup:
```bash
sudo k3s server &
# Kubeconfig is written to /etc/rancher/k3s/k3s.yaml
sudo k3s kubectl get node

# On a different node run the below command. 
# NODE_TOKEN comes from /var/lib/rancher/k3s/server/node-token on your server
sudo k3s agent --server https://myserver:6443 --token ${NODE_TOKEN}
```

### Checking Cluster Information

Check the K3s server API:

On the master server, we can check the K3s server API with:
```bash
kubectl cluster-info
```

### Managing Nodes

View nodes in the cluster:

```bash
kubectl get nodes -o wide
```

![p1](../docs/p1.png)

## Kubernetes Concepts

| Concept               | Description                                                                                                                                                     | Example                                                                                                                                                                  |
|-----------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Cluster               | A collection of physical or virtual machines (nodes) grouped together to run containerized applications orchestrated by Kubernetes.                              | A Kubernetes cluster consists of one or more master nodes and multiple worker nodes, collectively managing and executing containerized applications.                     |
| Master Node           | Manages the Kubernetes cluster, including the control plane components such as API server, scheduler, controller manager, and etcd.                             | A cluster may have one or more master nodes responsible for coordinating the cluster's operations.                                                                      |
| Worker Nodes          | Hosts containerized applications (pods) and runs the Kubernetes runtime environment.                                                                             | A cluster typically has multiple worker nodes where the actual application containers are deployed and executed.                                                         |
| Pods                  | Smallest deployable unit in Kubernetes, encapsulating one or more containers and shared resources.                                                              | An example pod may consist of a frontend container and a backend container, both serving a web application.                                                              |
| ReplicaSets           | Ensures a specified number of pod replicas are running at any given time, maintaining desired pod replicas by creating or deleting pods as needed.                 | A ReplicaSet may ensure that three replicas of a web server pod are running to handle incoming traffic.                                                                  |
| Services              | Provides a consistent way to access a set of pods, defining a logical set of pods and policies for accessing them.                                               | A service may expose a set of pods as a single, stable endpoint, allowing clients to access the pods without needing to know their individual IP addresses.           |
| Labels and Selectors | Key-value pairs attached to Kubernetes objects, used for grouping and selecting objects within Kubernetes.                                                     | Pods may be labeled with "app=frontend" and "env=production", allowing selectors to identify all pods with these labels for certain operations.                       |
| Namespaces            | Logically partitions resources within a cluster, useful for organizing and isolating objects and resources.                                                     | Namespaces can be used to isolate resources for different teams or projects within a cluster, ensuring resource and access separation.                                   |
| Persistent Volumes    | Provides persistent storage for stateful applications, representing physical storage resources, and requested by pods through Persistent Volume Claims.        | A Persistent Volume may represent a network-attached storage volume, and a Persistent Volume Claim can request storage of a certain size and access mode for a pod. |

## Additional Commands
### Vagrant
```bash
vagrant init            # Initialize the Vagrantfile.
vagrant up              # Raise virtual machines.
vagrant destroy         # Destroy virtual machines.
vagrant global status   # Show the status of active virtual machines.
vagrant reload          # Reload the Vagrantfile and restart the virtual machine.
```
### Kubectl
```bash
kubectl get all -n [namespace-name]                # View all resources in a specific namespace.
kubectl get all --all-namespaces                   # View all resources in all namespaces.
kubectl get [resource] -n [namespace] -o yaml      # Show YAML manifest information about a specific Kubernetes resource in a namespace.
kubectl describe [resource] -n [namespace]         # Show detailed information about a specific Kubernetes resource in a namespace.
kubectl exec -it [pod-name] -- /bin/sh             # Access the Pod.
kubectl apply -f [file.yaml]                       # Apply configuration from a YAML file.
kubectl delete [resource-name]                     # Delete a Kubernetes resource.
kubectl edit [resource-type] [resource-name]       # Edit a Kubernetes resource in a text editor.
kubectl rollout restart deployment [deployment-name]  # Restart a deployment.
```
