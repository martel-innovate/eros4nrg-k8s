### PROJECT CONVERTED FROM DOCKER-FILES TO K8S Manifests.

The files in this folder, feature a modular, Kubernetes data platform designed for deployment on an Amazon EKS (Elastic Kubernetes Service) cluster. It ingests, transforms, stores, secures, and analyzes data captured from IoT sources in real time.

The architecture is built around microservices deployed using Kustomize, enabling granular control over each component and its dependencies.

The platform is composed of the following core modules:

*   **IoT Stream**: Captures live data from APIs or databases and loads it into a data lake.
    
*   **Data Pipeline**: Transforms and restructures raw data into metadata and data tables, storing the result in PostgreSQL.
    
*   **Data Catalogue**: A FastAPI-based microservice to expose structured data via a REST API.
    
*   **Predictive Analysis**: Offers forecasting capabilities using Facebook Prophet, MLP, and CatBoost.
    
*   **Keycloak**: Secures access with centralized identity and access management.
    

📚 Table of Contents
--------------------
    
1.  [Project Structure](#Project-Structure)
    
2.  [Installation](#Installation)
    
3.  [Usage](#Usage)

4.  [Configuration](#Configuration)
    
5.  [Docker Images](#Docker-Images)


# Project-Structure

The Kubernetes manifests are organized using kustomize, allowing modular deployment of each component. 
Here's a high-level view of the folder structure:
```
k8s/
├── deploy/
│   ├── data-catalogue.yaml
│   ├── keycloak.yaml
│   ├── kustomization.yaml
|   ├── ...
├── svc/
│   ├── iotdata.yaml
│   ├── postgres.yaml
|   ├── ...
│   └── kustomization.yaml
├── pvcs/
│   ├── keycloak.yaml
│   ├── iotdata.yaml
│   ├── postgres.yaml
│   └── kustomization.yaml
├── secrets/
|    ├── postgres.yaml
|    ├── keycloak.yaml
│    └── kustomization.yaml
├── storageclass/
|    ├── aws-ebs-sc.yaml
│    └── kustomization.yaml
├── namespace/
|    ├── nemo.yaml
│    └── kustomization.yaml
├── kustomization.yaml
├── tmp.yaml                  # Deployment sequence generated w/ `kubectl kustomize . > tmp.yaml` (where . stands for the root dir (/k8s))
```


### Deployment Order

1.  **Namespace and Storage Class**
    
2.  **Persistent Volumes**
    
3.  **PostgreSQL**
    
4.  **Keycloak**

5. **Grafana**
    
6.  **IoT Stream**
    
7.  **Data Pipeline**
    
8.  **Data Catalogue**
    
9.  **Predictive Analysis**  # Training_env


Each component is deployed using Kustomize overlays, making it easy to manage and extend.

# Installation

> **Prerequisites**:
> 
> *   AWS EKS cluster configured and accessible via kubectl
>     
> *   kubectl and kustomize installed
>     
> *   IAM roles, EBS CSI driver, and necessary AWS permissions in place
>     

The installation can eiter be done using the usual `kubectl apply -f filename.yaml` or via kustomize (`kubectl apply -k folder/`), adding piece cake every component.

### 1\. Clone the Repository

`$ git clone https://your-repo-url.git`

`$ cd your-repo/k8s`

### 2\. Deploy the Namespace and StorageClass

`   kubectl apply -k namespace/   `

`   kubectl apply -k storageclass/   `

This step sets up:

*   nemo namespace
    
*   EBS-backed StorageClass
    
*   Optional ConfigMaps for Grafana or initial settings
    

### 3\. Apply Persistent Volume Claims

`   kubectl apply -k pvcs/   `

### 4\. Deploy Components One at a Time 

Deploy each component

- Using `kubectl apply`

```
Example:
Deploy PostgreSQL Deploy + svc + PVC:

$ kubectl apply -f pvcs/postgres.yaml

$ kubectl apply -f deploy/postgres.yaml

$ kubectl apply -f svc/postgres.yaml
```

- Using `kustomizer`

Example:
Deploy PostgreSQL Deploy + svc + PVC:

Our `k8s/kustomization.yaml` will look like:

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: nemo

resources:
- deploy/
- secrets/
- pvcs/
- namespace/
- svc/
```
And in each kustomization file in sub-folders we'll add/remove the required resources.

### Example (pvcs/kustomization.yaml)

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- postgres.yaml
```

And so on for every other subfolder.

Kustomizer enables us to logically split our project in modules for better and granular deployments, enabling clarity and improving maintenance activities.


# Usage

Once deployed, the platform operates as follows:

1.  **IoT Stream** pulls real-time data from APIs or databases and loads it into the data lake.
    
2.  **Data Pipeline** transforms, cleans, and loads structured data into PostgreSQL.
    
3.  **Data Catalogue** provides an HTTP API (via FastAPI) to query stored datasets.
    
4.  **Predictive Analysis** uses models like Prophet, MLP, and CatBoost to forecast trends.
    
5.  **Keycloak** governs access to APIs and services with secure authentication flows.
    

To access services:

*   Use the **Ingress** controller endpoint for external access.
    
*   Query the **Data Catalogue** API at /api/v1/
    
*   Authenticate users or services via the **Keycloak** login endpoint.
    

# Configuration

🔧 Configuration
----------------

The platform relies on a few key configuration areas across Kubernetes and service-level settings:

### 1\. **Namespace**

All components are deployed under the nemo namespace:

```
apiVersion: v1
kind: Namespace
metadata:
  name: nemo
```

### 2\. **Storage Class (EBS)**

A dynamic storage class is configured to provision EBS volumes for stateful services like PostgreSQL:

```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-auto-sc
provisioner: ebs.csi.eks.amazonaws.com
volumeBindingMode: WaitForFirstConsumer
parameters:
  type: gp2
  fsType: ext4
  encrypted: "true"
allowVolumeExpansion: true
```

### 3\. **Secrets & Environment Variables**

*   Database credentials, API keys, and Keycloak secrets should be provided using Kubernetes **Secrets**.
    
*   Each deployment file may include envFrom or env definitions to inject config into pods.
    

### 4\. **Ingress & Service Exposure**

Ingress resources are defined to route external traffic to internal services. Be sure to set the correct host values and TLS settings if applicable.


# Docker-Images

Each component is containerized and should be built and pushed to a container registry (e.g., ECR, Docker Hub).

Images can be built using the DockerFiles of each component.

- [data-catalogue](../data_catalogue/DockerFile)
- [data-pipeline](../data_pipeline/DockerFile)
- [iot-streams](../iot_streams/DockerFile)
- [training-environment](../training_environment/DockerFile)

Note that those images (in our scenario) are hosted on a private registry and this is why whe use 

```
imagePullSecrets:
        - name: marco-regcred
```
in our deployments.

### ⚠️ Each image should:


*   Expose required ports (e.g., 8000 for FastAPI)
    
*   Use minimal base images with specific versions (not latest)
    
*   Be secured with non-root users where possible
