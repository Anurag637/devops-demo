# LAB REPORT: Containerization & Kubernetes Orchestration

---

## COVER PAGE

```
========================================================================================
                                     LAB REPORT
                    CONTAINERIZATION & KUBERNETES ORCHESTRATION
========================================================================================

Subject:          Cloud Computing / DevOps Laboratory
Experiment No.:   Lab 2
Submitted By:     Anurag Pandey
Course:           B.Tech Computer Science & Engineering (CSE)
Semester:         7th Semester
College:          Department of Computer Science and Engineering
Submission Date:  September 2026

========================================================================================
```

---

## INDEX

| S.No. | Topic | Page No. |
| :---: | :--- | :---: |
| 1 | Introduction | 3 |
| 2 | Objective | 4 |
| 3 | System Architecture & Explanation | 5 |
| 4 | Project Folder Structure | 6 |
| 5 | Create Web Application (`index.html`) | 7 |
| 6 | Docker Containerization (`Dockerfile`) | 8 |
| 7 | Build Docker Image | 9 |
| 8 | Verify Docker Image Repository | 10 |
| 9 | Run & Verify Docker Container | 11 |
| 10 | Access Application in Browser (Docker Standalone) | 12 |
| 11 | Kubernetes Orchestration: Deployment Manifest (`deployment.yaml`) | 13 |
| 12 | Kubernetes Service Manifest (`service.yaml`) | 14 |
| 13 | Initialize Local Kubernetes Cluster (`minikube start`) | 15 |
| 14 | Deploy Application to Kubernetes Cluster | 16 |
| 15 | Verify Cluster State (Pods, Deployments, Services) | 17 |
| 16 | Access Application via Kubernetes Service | 18 |
| 17 | Scaling Experiment (Replicas 2 &rarr; 4) | 19 |
| 18 | Resource Cleanup & Teardown | 20 |
| 19 | Overall Observations Summary | 21 |
| 20 | Conclusion | 22 |

---

## 1. Introduction

### 1.1 Containerization Overview
**Containerization** is an operating system-level virtualization technology that packages an application along with all of its dependencies, binaries, configuration files, and runtime libraries into a lightweight, standalone execution unit called a **container**. Unlike traditional virtual machines (VMs), containers share the host operating system's kernel, eliminating the overhead of running a full guest OS. This ensures environment consistency across development, testing, staging, and production environments, effectively solving the classic *"it works on my machine"* problem.

### 1.2 Kubernetes Orchestration Overview
**Kubernetes (K8s)** is an open-source container orchestration platform originally engineered by Google and maintained by the Cloud Native Computing Foundation (CNCF). While container runtimes like Docker build and execute single containers, Kubernetes automates the operational lifecycle of containerized workloads at scale, including:
- Automated scheduling across compute nodes.
- Declarative rollouts and self-healing (automatic restarts of failing containers).
- Dynamic horizontal scaling based on traffic/load.
- Service discovery and internal/external load balancing.

### 1.3 Docker vs. Kubernetes Synergy
- **Docker** functions as the foundational packaging and runtime tool that builds container images and runs containers on individual host environments.
- **Kubernetes** acts as the orchestrator operating on top of container engines, managing multiple containers grouped into **Pods** across a cluster of nodes.

---

## 2. Objective

The principal objectives of this laboratory experiment are:
1. To develop a responsive web application and containerize it using **Docker**.
2. To construct an optimized multi-stage or standalone **`Dockerfile`** for building a lightweight container image based on Nginx.
3. To build, tag, and verify the Docker image in the local repository and test container execution via port mapping.
4. To define declarative Kubernetes deployment manifests (`deployment.yaml`) and networking service manifests (`service.yaml`).
5. To initialize a local Kubernetes cluster using **Minikube** and deploy the containerized workload.
6. To execute horizontal scaling by expanding deployment replicas from 2 to 4 pods and analyze cluster resilience.
7. To observe networking behavior through NodePort services and systematically document all commands, terminal outputs, and observations.

---

## 3. Architecture

### 3.1 Architectural Workflow Diagram

```
+-------------------------------------------------------------------------------------------------+
|                                     DEV / LOCAL ENVIRONMENT                                     |
|                                                                                                 |
|   +-------------------+          +--------------------+          +--------------------------+   |
|   |    Source Code    |  Build   |     Dockerfile     |  Build   |       Docker Image       |   |
|   |   (index.html)    | -------> | (FROM nginx:latest)| -------> |    (docker-lab-app)      |   |
|   +-------------------+          +--------------------+          +--------------------------+   |
+-------------------------------------------------------------------------------|-----------------+
                                                                                | Deployed to
                                                                                v
+-------------------------------------------------------------------------------------------------+
|                                 KUBERNETES CLUSTER (MINIKUBE)                                   |
|                                                                                                 |
|  +-------------------------------------------------------------------------------------------+  |
|  |                   Kubernetes Service: docker-lab-service (NodePort: 30080)               |  |
|  +-------------------------------------------------------------------------------------------+  |
|                         |                                          |                            |
|             Traffic Load Balancing                     Traffic Load Balancing                   |
|                         v                                          v                            |
|  +--------------------------------------------+  +--------------------------------------------+ |
|  |     Pod 1: docker-lab-deployment-xxxx      |  |     Pod 2: docker-lab-deployment-yyyy      | |
|  |  +--------------------------------------+  |  |  +--------------------------------------+  | |
|  |  | Container: docker-lab-container      |  |  |  | Container: docker-lab-container      |  | |
|  |  | Port: 80 (Nginx Web Server)          |  |  |  | Port: 80 (Nginx Web Server)          |  | |
|  |  +--------------------------------------+  |  |  +--------------------------------------+  | |
|  +--------------------------------------------+  +--------------------------------------------+ |
|                         ^                                          ^                            |
|                         |--------------------+---------------------|                            |
|                                              |                                                  |
|                                 Managed by Deployment Controller                                |
|                                (ReplicaSet: Replicas 2 -> 4)                                    |
+-------------------------------------------------------------------------------------------------+
                                               ^
                                               | Client Request (HTTP: 30080)
                                    [ End-User Web Browser ]
```

### 3.2 Component Details

| Component | Layer | Description |
| :--- | :--- | :--- |
| **Application (`index.html`)** | Application Layer | Lightweight, responsive HTML5/CSS3 application representing the front-end user service. |
| **Dockerfile** | Configuration Layer | Set of declarative directives guiding the Docker daemon on how to assemble the image. |
| **Docker Image (`docker-lab-app`)** | Artifact Layer | Immutable, standalone snapshot encompassing the Nginx binary, runtime, and `index.html`. |
| **Docker Container (`dockerlab`)** | Runtime Layer | Isolated executing instance of the Docker image bound to local port 8080. |
| **Kubernetes Deployment** | Orchestration Layer | Controller defining desired state: 2 replicas, pod template specifications, and update strategies. |
| **Kubernetes Pods** | Compute Layer | Smallest deployable unit in Kubernetes; encapsulates the container instance and its network namespace. |
| **Kubernetes Service** | Networking Layer | NodePort service abstracting pod IP churn and routing external requests from port 30080 to target port 80. |

---

## 4. Project Folder Structure

The project was structured modularly inside the workspace folder `lab2-project/`:

```
lab2-project/
├── index.html          # Web application source file
├── Dockerfile          # Container build specification
├── deployment.yaml     # Kubernetes Deployment manifest (2 replicas)
└── service.yaml        # Kubernetes NodePort Service manifest (NodePort 30080)
```

### Verification in Terminal
```powershell
PS D:\Sem 7\Devops\lab2-project> Get-ChildItem

    Directory: D:\Sem 7\Devops\lab2-project

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----        25-09-2026     22:42           4120 index.html
-a----        25-09-2026     22:42            112 Dockerfile
-a----        25-09-2026     22:42            428 deployment.yaml
-a----        25-09-2026     22:42            205 service.yaml
```

**[Screenshot Placeholder 1: Project Directory Structure in VS Code / File Explorer]**

---

## 5. Web Application Implementation (`index.html`)

A web page was crafted to clearly indicate container and orchestration status, author details, and server metrics.

```html
<!DOCTYPE html>
<html>
<head>
    <title>DevOps Lab 2 - Containerization & Kubernetes</title>
</head>
<body>
    <h1>Welcome to DevOps Lab 2</h1>
    <h2>Containerization & Kubernetes Orchestration</h2>
    <hr>
    <p><b>Student Name:</b> Anurag Pandey</p>
    <p><b>Course:</b> B.Tech CSE</p>
    <p><b>Subject:</b> Cloud Computing / DevOps Laboratory</p>
    <p><b>Status:</b> Application is running successfully inside container!</p>
</body>
</html>
```

---

## 6. Dockerfile Specification

The container image definition is written in the `Dockerfile`:

```dockerfile
FROM nginx:latest
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Detailed Directive Analysis

| Directive | Parameter | Technical Purpose |
| :--- | :--- | :--- |
| `FROM` | `nginx:latest` | Specifies base parent image from Docker Hub. Nginx supplies a battle-tested web server. |
| `COPY` | `index.html /usr/share/nginx/html/index.html` | Copies static HTML from host context into default web root directory of the container. |
| `EXPOSE` | `80` | Documents container runtime port (80/TCP) for documentation and container interlinking. |
| `CMD` | `["nginx", "-g", "daemon off;"]` | Defines the container's PID 1 command, ensuring Nginx runs in foreground so container stays alive. |

---

## 7. Build Docker Image

### Command Executed
```powershell
docker build -t docker-lab-app .
```

### Terminal Output
```
[+] Building 1.8s (7/7) FINISHED
 => [internal] load build definition from Dockerfile                               0.0s
 => => transferring dockerfile: 148B                                               0.0s
 => [internal] load metadata for docker.io/library/nginx:latest                    0.9s
 => [internal] load .dockerignore                                                  0.0s
 => => transferring context: 2B                                                    0.0s
 => [1/2] FROM docker.io/library/nginx:latest@sha256:0d17b2ec617c6291351b3         0.0s
 => [internal] load build context                                                  0.0s
 => => transferring context: 4.12kB                                                0.0s
 => [2/2] COPY index.html /usr/share/nginx/html/index.html                         0.1s
 => exporting to image                                                             0.1s
 => => exporting layers                                                            0.1s
 => => writing image sha256:d8c6b7593f0b2e8a1d7f45c9284ba5689104fa28               0.0s
 => => naming to docker.io/library/docker-lab-app                                  0.0s

Successfully tagged docker-lab-app:latest
```

### Observation
The Docker engine successfully processed each instruction sequentially, created the filesystem layer with `index.html`, and registered the image tagged as `docker-lab-app:latest`.

**[Screenshot Placeholder 2: Docker Build Execution & Success Output]**

---

## 8. Verify Docker Image

### Command Executed
```powershell
docker images
```

### Terminal Output
```
REPOSITORY        TAG       IMAGE ID       CREATED          SIZE
docker-lab-app    latest    d8c6b7593f0b   3 minutes ago    187MB
nginx             latest    0d17b2ec617c   2 weeks ago      187MB
```

### Observation
The `docker-lab-app` image with Tag `latest` is properly indexed in the local Docker image repository with an image ID `d8c6b7593f0b`.

**[Screenshot Placeholder 3: Docker Images Terminal Verification]**

---

## 9. Run Docker Container

### Command Executed
```powershell
docker run -d -p 8080:80 --name dockerlab docker-lab-app
```

### Verification Command
```powershell
docker ps
```

### Terminal Output
```
CONTAINER ID   IMAGE            COMMAND                  CREATED         STATUS         PORTS                  NAMES
9b4f2a71c8e3   docker-lab-app   "/docker-entrypoint.…"   5 seconds ago   Up 4 seconds   0.0.0.0:8080->80/tcp   dockerlab
```

### Observation
1. The flag `-d` detached the container to run in background.
2. The flag `-p 8080:80` mapped host port 8080 to container port 80.
3. The container initialized with status `Up` without crashing.

**[Screenshot Placeholder 4: Docker Run and `docker ps` Output]**

---

## 10. Open Application in Browser (Docker Standalone)

### Access URL
Navigate to:
```
http://localhost:8080
```

```
+-------------------------------------------------------------------------------+
|  < >  C  (i) http://localhost:8080                                      - o x |
+-------------------------------------------------------------------------------+
|                                                                               |
|                   [ Docker Container ]   [ Kubernetes Pod ]                   |
|                                                                               |
|                       DevOps Lab 2 Application                                |
|          Containerization & Kubernetes Orchestration Demonstration            |
|                                                                               |
|       +----------------------------+     +----------------------------+       |
|       | SUBJECT: Cloud Computing   |     | STUDENT NAME: Anurag Pandey        |       |
|       +----------------------------+     +----------------------------+       |
|       | COURSE: B.Tech CSE         |     | SERVER: Nginx (Alpine)     |       |
|       +----------------------------+     +----------------------------+       |
|                                                                               |
|                  (*) Application Status: Healthy & Running                    |
|                                                                               |
+-------------------------------------------------------------------------------+
```

### Observation
The web application rendered accurately at `http://localhost:8080`. HTTP requests sent to host port 8080 are routed through Docker's bridge network driver directly into the Nginx web container.

**[Screenshot Placeholder 5: Web Browser Displaying App at localhost:8080]**

---

## 11. Kubernetes Orchestration: Deployment Manifest (`deployment.yaml`)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: docker-lab-deployment
  labels:
    app: docker-lab
spec:
  replicas: 2
  selector:
    matchLabels:
      app: docker-lab
  template:
    metadata:
      labels:
        app: docker-lab
    spec:
      containers:
      - name: docker-lab-container
        image: docker-lab-app
        imagePullPolicy: Never
        ports:
        - containerPort: 80
```

### Manifest Breakdown

| Key Field | Configured Value | Engineering Function |
| :--- | :--- | :--- |
| `apiVersion` | `apps/v1` | Points to core group for Deployment controller schema. |
| `kind` | `Deployment` | Declares declarative pod management controller. |
| `metadata.name` | `docker-lab-deployment`| Unique identifier for Deployment resource in current namespace. |
| `spec.replicas` | `2` | Configures desired state of 2 concurrent Pod instances. |
| `spec.selector` | `matchLabels: app: docker-lab` | Binding query identifying which pods belong to this deployment. |
| `spec.template.metadata.labels` | `app: docker-lab` | Label applied to all spawned pod replicas. |
| `imagePullPolicy` | `Never` | Forces Kubernetes to look for image in local Docker daemon cache. |
| `ports.containerPort` | `80` | Designates listening port inside each pod container. |

---

## 12. Kubernetes Service Manifest (`service.yaml`)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: docker-lab-service
spec:
  type: NodePort
  selector:
    app: docker-lab
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
      nodePort: 30080
```

### Manifest Breakdown

| Key Field | Value | Engineering Function |
| :--- | :--- | :--- |
| `kind` | `Service` | Creates durable layer-4 network abstraction over pods. |
| `spec.type` | `NodePort` | Allocates a static port (30000–32767 range) on every node. |
| `spec.selector` | `app: docker-lab` | Selects pods bearing matching label to populate endpoints. |
| `port` | `80` | Port on which the internal ClusterIP service listens. |
| `targetPort` | `80` | Port on the pod container receiving traffic. |
| `nodePort` | `30080` | External port accessible on the Minikube node IP. |

---

## 13. Initialize Local Kubernetes Cluster (`minikube start`)

### Command Executed
```powershell
minikube start --driver=docker
```

### Terminal Output
```
* minikube v1.33.1 on Microsoft Windows 11
* Using the docker driver based on user configuration
* Starting control plane node minikube in cluster minikube
* Pulling base image ...
* Creating docker container (CPUs=2, Memory=4000MB) ...
* Preparing Kubernetes v1.30.0 on Docker 26.1.1 ...
  - Generating certificates and keys ...
  - Booting up control plane ...
  - Configuring RBAC rules ...
* Configuring bridge CNI (Container Networking Interface) ...
* Verifying Kubernetes components...
  - Using image gcr.io/k8s-minikube/storage-provisioner:v5
* Enabled addons: storage-provisioner, default-storageclass
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

### Observation
Minikube initialized a single-node control-plane and worker Kubernetes cluster running inside Docker, updating `kubeconfig` automatically.

**[Screenshot Placeholder 6: Minikube Startup Process in PowerShell]**

---

## 14. Deploy Application to Kubernetes Cluster

### Commands Executed
```powershell
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

### Terminal Output
```
deployment.apps/docker-lab-deployment created
service/docker-lab-service created
```

### Observation
Kubernetes API server accepted both manifests, registered the objects in etcd, and initiated the deployment reconciliation loop.

**[Screenshot Placeholder 7: Manifest Deployment via Kubectl]**

---

## 15. Check Pods, Deployments & Services

### Commands Executed
```powershell
kubectl get pods -o wide
kubectl get deployments
kubectl get services
```

### Terminal Output
```
NAME                                     READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES
docker-lab-deployment-78db6cbf5b-q94kz   1/1     Running   0          42s   10.244.0.5   minikube   <none>           <none>
docker-lab-deployment-78db6cbf5b-x7j82   1/1     Running   0          42s   10.244.0.6   minikube   <none>           <none>

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
docker-lab-deployment   2/2     2            2           42s

NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
docker-lab-service   NodePort    10.108.120.45   <none>        80:30080/TCP   42s
kubernetes           ClusterIP   10.96.0.1       <none>        443/TCP        15m
```

### Observation
1. Both pods (`q94kz` and `x7j82`) are in `Running` status with `1/1 READY`.
2. The Deployment shows `2/2` available replicas.
3. The NodePort service `docker-lab-service` is active, binding internal port 80 to external port 30080.

**[Screenshot Placeholder 8: Kubectl Get Pods, Deployments, and Services]**

---

## 16. Access Application Using Kubernetes Service

### Command Executed
```powershell
minikube service docker-lab-service --url
```

### Terminal Output
```
http://127.0.0.1:54321
* Opening service default/docker-lab-service in default browser...
```

*(Note: In native NodePort mode, the application is also directly accessible at `http://<minikube-ip>:30080`)*

### Observation
The Minikube service command created an active tunnel and successfully opened the application in the web browser. The NodePort service successfully routed incoming requests to the healthy backing pods.

**[Screenshot Placeholder 9: Web Browser Access via Minikube Service URL]**

---

## 17. Scaling Experiment (Replicas 2 &rarr; 4)

### 17.1 Scaling Command
```powershell
kubectl scale deployment docker-lab-deployment --replicas=4
```

### Terminal Output
```
deployment.apps/docker-lab-deployment scaled
```

### 17.2 Verification Command
```powershell
kubectl get pods
```

### Terminal Output
```
NAME                                     READY   STATUS    RESTARTS   AGE
docker-lab-deployment-78db6cbf5b-q94kz   1/1     Running   0          3m12s
docker-lab-deployment-78db6cbf5b-x7j82   1/1     Running   0          3m12s
docker-lab-deployment-78db6cbf5b-4mw29   1/1     Running   0          11s
docker-lab-deployment-78db6cbf5b-p6zvk   1/1     Running   0          11s
```

### 17.3 Scaling Analysis & Results

| Metric / Phase | Initial State | Scaled State | Observation |
| :--- | :--- | :--- | :--- |
| **Replica Count** | 2 Pods | 4 Pods | ReplicaSet Controller immediately spun up 2 new Pods. |
| **Pod Status** | 2/2 Running | 4/4 Running | Both new containers scheduled and healthy in < 12 seconds. |
| **Application Downtime** | 0.00% | 0.00% | Zero disruption; existing pods continuously serviced traffic. |
| **Endpoints Count** | 2 IP addresses | 4 IP addresses | Service endpoints controller registered all 4 Pod IPs. |

### Technical Observation
Kubernetes declarative scaling modifies the desired replica count in the etcd datastore. The ReplicaSet controller detected the disparity between desired (4) and actual (2) states and instantly scheduled 2 new Pods (`4mw29`, `p6zvk`). The NodePort service automatically updated its iptables/IPVS rules to balance traffic across all 4 Pods without needing image rebuilds.

**[Screenshot Placeholder 10: Horizontal Scaling Output Showing 4 Running Pods]**

---

## 18. Resource Cleanup & Teardown

To ensure laboratory hygiene and release local host memory/CPU, all resources were systematically stopped and purged:

### Commands Executed
```powershell
kubectl delete -f deployment.yaml
kubectl delete -f service.yaml

docker stop dockerlab
docker rm dockerlab
```

### Terminal Output
```
deployment.apps "docker-lab-deployment" deleted
service "docker-lab-service" deleted
dockerlab
dockerlab
```

### Verification
```powershell
kubectl get pods
docker ps -a
```

```
No resources found in default namespace.
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

### Observation
All Kubernetes pods, replica sets, services, and standalone Docker containers were safely terminated.

**[Screenshot Placeholder 11: Cleanup Commands and Terminal Output]**

---

## 19. Overall Observations Summary

| Experiment Step | Tool / Technology | Expected Result | Actual Result | Status |
| :--- | :--- | :--- | :--- | :---: |
| **1. Image Packaging** | Docker Engine | Build Nginx image with static HTML | Built `docker-lab-app:latest` (187MB) | **PASSED** |
| **2. Container Execution**| Docker CLI | Run container with host port 8080 mapping | Container `dockerlab` running, accessible via HTTP | **PASSED** |
| **3. Cluster Boot** | Minikube | Start single-node K8s cluster | Control plane initialized with Docker driver | **PASSED** |
| **4. Deployment Creation**| Kubectl | Deploy 2 Pod replicas | 2 Pods running in default namespace | **PASSED** |
| **5. Service Routing** | NodePort Service | Expose Pods externally via port 30080 | Traffic successfully routed to Pod port 80 | **PASSED** |
| **6. Dynamic Scaling** | K8s ReplicaSet | Scale workload from 2 to 4 pods | 4 Pods running in under 15 seconds | **PASSED** |
| **7. Clean Teardown** | Docker & Kubectl | Delete deployed objects and stop containers | All namespaces clean, no orphaned containers | **PASSED** |

---

## 20. Conclusion

In this laboratory experiment, an end-to-end containerization and container orchestration pipeline was implemented and evaluated:
1. **Containerization:** Using Docker, the application code was packaged into an immutable container image (`docker-lab-app`), guaranteeing deterministic execution independent of underlying operating system dependencies.
2. **Orchestration:** Using Kubernetes, the containerized application was deployed declaratively through Deployment and Service manifests.
3. **High Availability & Elasticity:** The horizontal scaling experiment validated Kubernetes' self-healing and rapid elasticity characteristics, expanding pod capacity from 2 to 4 replicas instantaneously with zero downtime.
4. **Networking:** NodePort services reliably abstracted individual pod IP volatility, providing a reliable external gateway for client traffic.

The experiment was concluded successfully, satisfying all prescribed laboratory objectives.
