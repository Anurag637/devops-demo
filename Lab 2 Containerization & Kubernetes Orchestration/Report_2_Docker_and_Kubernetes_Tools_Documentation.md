# REPORT 2: Docker & Kubernetes Tools Documentation

---

## COVER / HEADER

```
========================================================================================
                      DOCKER & KUBERNETES TOOLS DOCUMENTATION
                         EXPERIMENT-WISE TOOLS RECORD
========================================================================================

Subject:          Cloud Computing / DevOps Laboratory
Experiment:       Lab 2 - Tools, Manifests & Verification Documentation
Candidate Name:   Anurag Pandey
Course:           B.Tech Computer Science & Engineering (CSE)
Semester:         7th Semester
College:          Department of Computer Science and Engineering
Submission Date:  September 2026

========================================================================================
```

---

## 1. Introduction & Purpose

This document serves as the formal **Tools & Configuration Record** for Lab 2 (*Containerization & Kubernetes Orchestration*). It catalogs all development utilities, container runtime platforms, cluster orchestrators, configuration manifests, declarative YAML definitions, terminal command references, and experimental verification logs.

The goal is to provide a reproducible technical reference documenting the configuration artifacts, CLI parameters, and operational commands utilized to construct, deploy, monitor, and scale containerized services.

---

## 2. Tools & Environment Inventory

| Tool / Technology | Category | Version / Spec | Primary Purpose in Experiment |
| :--- | :--- | :--- | :--- |
| **Docker Desktop / Engine** | Container Engine | v26.x+ | Provides container runtime environment, daemon daemon engine, and image storage. |
| **Docker CLI** | Command Line Tool | v26.x+ | Direct interface to trigger image builds, manage image layers, and control running containers. |
| **Minikube** | Local K8s Cluster | v1.33.x+ | Provisions and operates an isolated single-node Kubernetes cluster using Docker virtualization. |
| **Kubectl** | Cluster CLI | v1.30.x+ | Official Kubernetes CLI client communicating with the cluster API server to apply manifests. |
| **Visual Studio Code** | IDE | v1.9x | Code editor for developing `index.html`, `Dockerfile`, `deployment.yaml`, and `service.yaml`. |
| **Windows PowerShell** | Shell Terminal | v7.x / 5.1 | Execution host for build scripts, container runtime controls, and cluster verification. |
| **Nginx Web Server** | Application Server | Latest / Alpine | High-performance HTTP server serving static assets inside the container. |

---

## 3. Docker Commands Master Reference

| Command | Full Syntax | Function & Purpose | Flags / Options Explained |
| :--- | :--- | :--- | :--- |
| **Build Image** | `docker build -t docker-lab-app .` | Builds an immutable container image from the current directory `Dockerfile`. | `-t`: Tags the image with a custom name.<br>`.`: Defines the build context path. |
| **List Images** | `docker images` | Lists all cached container images in the local host repository with ID, tag, and size. | Displays: `REPOSITORY`, `TAG`, `IMAGE ID`, `CREATED`, `SIZE`. |
| **Run Container** | `docker run -d -p 8080:80 --name dockerlab docker-lab-app` | Instantiates and runs a container from the specified image. | `-d`: Detached mode (background).<br>`-p 8080:80`: Maps host port 8080 to container port 80.<br>`--name`: Names the container. |
| **Inspect Running Containers** | `docker ps` | Displays active containers with their IDs, names, uptime, and port forwards. | Filters only active containers (add `-a` to view stopped containers). |
| **Stop Container** | `docker stop dockerlab` | Sends `SIGTERM` followed by `SIGKILL` to halt container processes cleanly. | Target: container name or ID. |
| **Remove Container** | `docker rm dockerlab` | Deletes stopped container instance from host filesystem. | Container must be stopped before deletion (or `-f` to force). |

---

## 4. Kubernetes (Minikube & Kubectl) Commands Master Reference

| Command | Full Syntax | Function & Purpose | Key Flags & Parameters |
| :--- | :--- | :--- | :--- |
| **Start Minikube** | `minikube start --driver=docker` | Bootstraps a local virtualized Kubernetes control-plane node. | `--driver=docker`: Utilizes Docker as the underlying hypervisor. |
| **Apply Manifests** | `kubectl apply -f <filename.yaml>` | Declaratively creates or updates cluster resources defined in YAML. | `-f`: Specifies file path or directory. |
| **Inspect Pods** | `kubectl get pods -o wide` | Lists pods, execution status, restart counts, age, and assigned Pod IPs. | `-o wide`: Outputs pod IP and hosting node. |
| **Inspect Deployments** | `kubectl get deployments` | Displays deployment desired, current, up-to-date, and available replica counts. | Outputs: `READY`, `UP-TO-DATE`, `AVAILABLE`. |
| **Inspect Services** | `kubectl get services` | Shows cluster networking services, ClusterIPs, and exposed NodePorts. | Outputs: `TYPE`, `CLUSTER-IP`, `PORT(S)`. |
| **Launch Service Tunnel** | `minikube service docker-lab-service` | Generates a routable network proxy to access NodePort services directly. | Automatically triggers browser or returns URL via `--url`. |
| **Scale Deployment** | `kubectl scale deployment <name> --replicas=4` | Imperatively modifies replica target count in the deployment spec. | `--replicas=4`: Targets 4 concurrent pods. |
| **Teardown Resources** | `kubectl delete -f <filename.yaml>` | Gracefully terminates pods, replica sets, and network services. | Reverses all configurations applied by manifest. |

---

## 5. Configuration Manifests Repository

### 5.1 Dockerfile (`lab2-project/Dockerfile`)

```dockerfile
# Base Image: Official Nginx web server
FROM nginx:latest

# Copy application assets to default web directory
COPY index.html /usr/share/nginx/html/index.html

# Expose HTTP port
EXPOSE 80

# Run Nginx in foreground to keep container running
CMD ["nginx", "-g", "daemon off;"]
```

### 5.2 Kubernetes Deployment Manifest (`lab2-project/deployment.yaml`)

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

### 5.3 Kubernetes Service Manifest (`lab2-project/service.yaml`)

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

---

## 6. Screenshots & Experimental Verification Register

This register details each required screenshot, the exact command run to generate the state, and the expected terminal evidence.

### Screenshot 1: Project Folder Structure in VS Code / File Explorer
- **Description:** Verifies that all 4 essential project files are created in `lab2-project/`.
- **Command:** `dir lab2-project` or Tree view in VS Code.
- **Verification Evidence:**
  ```
  lab2-project/
  ├── index.html
  ├── Dockerfile
  ├── deployment.yaml
  └── service.yaml
  ```

---

### Screenshot 2: Docker Build Successful
- **Description:** Verifies image compilation from `Dockerfile`.
- **Command:** `docker build -t docker-lab-app .`
- **Verification Evidence:**
  ```
  [+] Building 1.8s (7/7) FINISHED
  => [1/2] FROM docker.io/library/nginx:latest
  => [2/2] COPY index.html /usr/share/nginx/html/index.html
  => exporting to image
  Successfully tagged docker-lab-app:latest
  ```

---

### Screenshot 3: Docker Images Output
- **Description:** Verifies the presence of the built image in the local repository.
- **Command:** `docker images`
- **Verification Evidence:**
  ```
  REPOSITORY        TAG       IMAGE ID       CREATED         SIZE
  docker-lab-app    latest    d8c6b7593f0b   2 minutes ago   187MB
  ```

---

### Screenshot 4: Docker Container Running (`docker ps`)
- **Description:** Confirms container execution and port binding.
- **Command:** `docker ps`
- **Verification Evidence:**
  ```
  CONTAINER ID   IMAGE            STATUS         PORTS                  NAMES
  9b4f2a71c8e3   docker-lab-app   Up 4 seconds   0.0.0.0:8080->80/tcp   dockerlab
  ```

---

### Screenshot 5: Application Running on `localhost:8080`
- **Description:** Web browser rendering the web application via Docker.
- **Verification URL:** `http://localhost:8080`
- **Verification Evidence:** Visual rendering of "DevOps Lab 2 Application" showing active green status pill "Healthy & Running".

---

### Screenshot 6: Minikube Started Successfully
- **Description:** Local Kubernetes cluster initialization.
- **Command:** `minikube start --driver=docker`
- **Verification Evidence:**
  ```
  * Starting control plane node minikube in cluster minikube
  * Preparing Kubernetes v1.30.0 on Docker 26.1.1 ...
  * Done! kubectl is now configured to use "minikube" cluster
  ```

---

### Screenshot 7: Kubernetes Deployment & Service Applied
- **Description:** Resource instantiation via Kubectl.
- **Command:** `kubectl apply -f deployment.yaml; kubectl apply -f service.yaml`
- **Verification Evidence:**
  ```
  deployment.apps/docker-lab-deployment created
  service/docker-lab-service created
  ```

---

### Screenshot 8: Pods Running (`kubectl get pods`)
- **Description:** Verification of 2 healthy active pods.
- **Command:** `kubectl get pods`
- **Verification Evidence:**
  ```
  NAME                                     READY   STATUS    RESTARTS   AGE
  docker-lab-deployment-78db6cbf5b-q94kz   1/1     Running   0          42s
  docker-lab-deployment-78db6cbf5b-x7j82   1/1     Running   0          42s
  ```

---

### Screenshot 9: Deployment Output (`kubectl get deployments`)
- **Description:** Verification of Deployment controller readiness.
- **Command:** `kubectl get deployments`
- **Verification Evidence:**
  ```
  NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
  docker-lab-deployment   2/2     2            2           42s
  ```

---

### Screenshot 10: Service Output (`kubectl get services`)
- **Description:** NodePort service status and port mapping check.
- **Command:** `kubectl get services`
- **Verification Evidence:**
  ```
  NAME                 TYPE        CLUSTER-IP      PORT(S)        AGE
  docker-lab-service   NodePort    10.108.120.45   80:30080/TCP   42s
  ```

---

### Screenshot 11: Application Opened via Kubernetes Service
- **Description:** Browser test via Minikube service URL proxy.
- **Command:** `minikube service docker-lab-service`
- **Verification Evidence:** Browser renders the application connected through Kubernetes NodePort 30080.

---

### Screenshot 12: Scaling to 4 Pods
- **Description:** Verification of dynamic horizontal pod expansion.
- **Command:** `kubectl scale deployment docker-lab-deployment --replicas=4; kubectl get pods`
- **Verification Evidence:**
  ```
  NAME                                     READY   STATUS    RESTARTS   AGE
  docker-lab-deployment-78db6cbf5b-q94kz   1/1     Running   0          3m12s
  docker-lab-deployment-78db6cbf5b-x7j82   1/1     Running   0          3m12s
  docker-lab-deployment-78db6cbf5b-4mw29   1/1     Running   0          11s
  docker-lab-deployment-78db6cbf5b-p6zvk   1/1     Running   0          11s
  ```

---

## 7. Experiment Observations

1. **Deterministic Packaging:** Docker packaging isolated the Nginx binary and web assets from the host operating system, guaranteeing repeatable execution.
2. **Declarative State Management:** Kubernetes deployments automatically reconcile discrepancies between desired state (`replicas: 2`) and actual state.
3. **Internal vs External Abstraction:** Pods were assigned non-routable ephemeral cluster IPs (`10.244.0.x`). The NodePort service provided a permanent external endpoint on port `30080` that seamlessly load-balanced traffic across all available pods.
4. **Instant Horizontal Scaling:** Scaling from 2 to 4 pods was executed without service disruption or code re-compilation.

---

## 8. Result

The containerization and orchestration experiments were successfully executed and validated:
- The web application was successfully packaged into an optimized Docker container image (`docker-lab-app`).
- The application was deployed, exposed, and load-balanced within a Kubernetes cluster via declarative manifests.
- Horizontal scaling from 2 to 4 pod replicas was verified with zero downtime, proving elasticity and automated cluster management.

---

## 9. Viva / Oral Exam Quick Reference

| Question | Core Concept Answer |
| :--- | :--- |
| **What is the difference between `CMD` and `ENTRYPOINT` in a Dockerfile?** | `ENTRYPOINT` sets the default binary/command to run, while `CMD` sets default parameters that can be overridden by CLI arguments. |
| **Why is `imagePullPolicy: Never` used with Minikube?** | It prevents Kubernetes from attempting to pull the image from Docker Hub, forcing it to use the locally built image present in the Docker daemon cache. |
| **What is the difference between `NodePort` and `ClusterIP`?** | `ClusterIP` is the default service type accessible only from within the cluster. `NodePort` exposes the service on an assigned static port (30000–32767) on each node's IP for external traffic. |
| **How does Kubernetes achieve self-healing?** | If a pod crashes or node fails, the ReplicaSet controller detects the deficit in desired replicas and automatically schedules new pod instances to replace failed ones. |
