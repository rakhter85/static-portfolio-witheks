# static-portfolio-witheks

# 🚀 Static Portfolio DevOps Project

This project automates the build, scan, and deployment of a static HTML portfolio using Docker, Helm, GitHub Actions, and Amazon EKS. It provisions infrastructure with CloudFormation, scans code with SonarQube, and sends notifications via AWS SNS. CloudWatch is enabled for cluster observability.

---

## 🧰 Tech Stack

- **Frontend**: Static HTML/CSS
- **Containerization**: Docker
- **Orchestration**: Amazon EKS + Helm
- **Infrastructure as Code**: AWS CloudFormation
- **CI/CD**: GitHub Actions
- **Code Quality**: SonarQube
- **Notifications**: AWS SNS
- **Monitoring**: AWS CloudWatch

---

## 📦 Folder Structure

```
static-portfolio/
├── Dockerfile
├── index.html
├── helm-chart/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── deployment.yaml
│       └── service.yaml
├── cloudformation/
│   ├── vpc.yaml
│   ├── iam-roles.yaml
│   ├── eks-cluster.yaml
│   └── eks-nodegroup.yaml
├── .github/
│   └── workflows/
│       └── ci-cd.yaml
└── deploy.sh
```

---

## 🛠️ Prerequisites

- AWS CLI, kubectl, Helm, Docker installed locally
- AWS account with permissions for EKS, IAM, CloudFormation, SNS
- DockerHub account
- SonarQube server and token
- GitHub repository with secrets configured

---

## 🔐 GitHub Secrets Required

| Secret Name             | Description                          |
|-------------------------|--------------------------------------|
| `DOCKERHUB_USERNAME`    | DockerHub username                   |
| `DOCKERHUB_PASSWORD`    | DockerHub password or token          |
| `SONAR_TOKEN`           | SonarQube token                      |
| `AWS_ACCESS_KEY_ID`     | IAM access key ID                    |
| `AWS_SECRET_ACCESS_KEY` | IAM secret access key                |
| `SNS_TOPIC_ARN`         | ARN of AWS SNS topic                 |

---

## 🧱 Infrastructure Setup

Run the `deploy.sh` script to provision:

```bash
bash deploy.sh
```

This will:
1. Create VPC, subnets, and security group
2. Create IAM roles for EKS
3. Deploy EKS cluster with CloudWatch logging
4. Deploy EKS node group

---

## 🐳 Docker Setup

```Dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
```

Build and push manually (optional):

```bash
docker build -t your-dockerhub/static-portfolio:latest .
docker push your-dockerhub/static-portfolio:latest
```

---

## 📦 Helm Chart

- `values.yaml`: defines image and service type
- `deployment.yaml`: defines pod and container
- `service.yaml`: exposes app via LoadBalancer

Deploy manually (optional):

```bash
helm upgrade --install static-portfolio ./helm-chart --namespace default
```

---

## 🚀 CI/CD Pipeline

Triggered on push to `main`:

- Builds Docker image
- Pushes to DockerHub
- Runs SonarQube scan
- Deploys to EKS via Helm
- Sends SNS notification
- Logs activity in CloudWatch

---

## 📣 SNS Notifications

- Success: `"✅ CI/CD succeeded for branch <branch>"`
- Failure: `"❌ CI/CD failed for branch <branch>"`

---

## 📊 CloudWatch Integration

Enabled via `eks-cluster.yaml`:

```yaml
Logging:
  ClusterLogging:
    EnabledTypes:
      - Type: api
      - Type: audit
      - Type: authenticator
```

---

## 🧠 Author

**Rokshana** — DevOps Engineer  
Expert in cloud-native automation, CI/CD pipelines, and infrastructure as code.

---

## 📌 Notes

- All CloudFormation templates use dynamic references (no hardcoded IDs)
- Helm chart is modular and reusable
- CI/CD pipeline is fully automated and production-ready

```
