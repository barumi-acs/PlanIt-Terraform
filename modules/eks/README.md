# EKS Module

이 모듈은 AWS EKS (Elastic Kubernetes Service) 클러스터와 관련 리소스를 생성합니다.

## 구성 요소

### 파일 구조
```
modules/eks/
├── main.tf              # 전체 컨트롤 타워 (모듈 설명)
├── eks-cluster.tf       # EKS Control Plane (뇌)
├── eks-nodegroups.tf    # Worker Nodes (일꾼들)
├── iam.tf               # IAM 역할 및 정책 (통행증)
├── variables.tf         # 입력 변수
├── outputs.tf           # 출력 값
└── README.md            # 이 파일
```

### 생성되는 리소스

1. **EKS Cluster (Control Plane)**
   - EKS 클러스터
   - 클러스터 보안 그룹
   - Control Plane 로깅

2. **EKS Node Group (Worker Nodes)**
   - Managed Node Group
   - 노드 보안 그룹
   - Auto Scaling 설정

3. **IAM Roles & Policies**
   - 클러스터 역할 (AmazonEKSClusterPolicy, AmazonEKSVPCResourceController)
   - 노드 그룹 역할 (AmazonEKSWorkerNodePolicy, AmazonEKS_CNI_Policy, AmazonEC2ContainerRegistryReadOnly)
   - CloudWatch 로그 정책 (선택적)
   - EBS CSI 드라이버 정책 (선택적)

4. **EKS Add-ons**
   - VPC CNI (Pod 네트워킹)
   - CoreDNS (DNS 해석)
   - kube-proxy (네트워크 프록시)
   - EBS CSI Driver (영구 볼륨 지원)

## 사용 방법

### 기본 사용

```hcl
module "eks" {
  source = "./modules/eks"

  create_eks_cluster  = true
  cluster_name        = "planit-dev-eks-cluster"
  environment         = "dev"
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.subnets.private_subnet_ids

  # Cluster Configuration
  cluster_version         = "1.28"
  endpoint_private_access = true
  endpoint_public_access  = true

  # Node Group Configuration
  node_desired_size   = 3
  node_min_size       = 2
  node_max_size       = 6
  node_instance_types = ["t3.medium"]
  node_disk_size      = 20

  tags = {
    Project     = "PlanIt"
    Environment = "DEV"
    ManagedBy   = "Terraform"
  }
}
```

### 프로덕션 환경 예시

```hcl
module "eks" {
  source = "./modules/eks"

  create_eks_cluster  = true
  cluster_name        = "planit-prod-eks-cluster"
  environment         = "prod"
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.subnets.private_subnet_ids

  # Cluster Configuration
  cluster_version         = "1.28"
  endpoint_private_access = true
  endpoint_public_access  = false  # 프로덕션: 공개 액세스 비활성화

  # Node Group Configuration
  node_desired_size   = 5
  node_min_size       = 3
  node_max_size       = 10
  node_instance_types = ["t3.large"]
  node_disk_size      = 50

  # Add-ons
  enable_vpc_cni_addon      = true
  enable_coredns_addon      = true
  enable_kube_proxy_addon   = true
  enable_ebs_csi_driver     = true
  enable_cloudwatch_logs    = true

  tags = {
    Project     = "PlanIt"
    Environment = "PROD"
    ManagedBy   = "Terraform"
  }
}
```

## 입력 변수

### 필수 변수

| 변수 | 설명 | 타입 |
|------|------|------|
| `cluster_name` | EKS 클러스터 이름 | string |
| `vpc_id` | VPC ID | string |
| `private_subnet_ids` | Private 서브넷 ID 목록 | list(string) |
| `environment` | 환경 이름 | string |

### 선택적 변수

| 변수 | 설명 | 기본값 |
|------|------|--------|
| `create_eks_cluster` | EKS 클러스터 생성 여부 | false |
| `cluster_version` | Kubernetes 버전 | "1.28" |
| `node_desired_size` | 노드 수 (desired) | 3 |
| `node_min_size` | 최소 노드 수 | 2 |
| `node_max_size` | 최대 노드 수 | 6 |
| `node_instance_types` | 인스턴스 타입 목록 | ["t3.medium"] |
| `node_disk_size` | 디스크 크기 (GB) | 20 |

전체 변수 목록은 `variables.tf` 파일을 참조하세요.

## 출력 값

| 출력 | 설명 |
|------|------|
| `cluster_endpoint` | EKS 클러스터 API 엔드포인트 |
| `cluster_certificate_authority` | 클러스터 CA 데이터 |
| `cluster_security_group_id` | 클러스터 보안 그룹 ID |
| `node_group_security_group_id` | 노드 그룹 보안 그룹 ID |
| `kubeconfig_command` | kubectl 설정 명령어 |

전체 출력 목록은 `outputs.tf` 파일을 참조하세요.

## 아키텍처

### 네트워크 구성
- **Control Plane**: AWS 관리형 (Private + Public 엔드포인트)
- **Worker Nodes**: Private Subnet에 배포
- **통신**: 보안 그룹으로 제어

### 보안
- IAM 역할 기반 권한 관리
- 보안 그룹으로 네트워크 격리
- EBS 볼륨 암호화
- Private Subnet 배포로 외부 노출 최소화

### 확장성
- Auto Scaling Group 기반 노드 관리
- Horizontal Pod Autoscaler 지원
- Cluster Autoscaler 호환

## 5개 마이크로서비스 지원

이 모듈은 다음 5개 마이크로서비스를 위해 설계되었습니다:
1. User-svc
2. Schedule-svc
3. Strategy-svc
4. Insight-svc
5. InsightAI-svc

기본 노드 설정 (3 desired, 2 min, 6 max)은 이러한 서비스를 효율적으로 실행하도록 구성되어 있습니다.

## kubectl 설정

클러스터 생성 후 kubectl을 설정하려면:

```bash
# Terraform output에서 명령어 확인
terraform output -module=eks kubeconfig_command

# 또는 직접 실행
aws eks update-kubeconfig --region ap-northeast-2 --name planit-dev-eks-cluster

# 연결 확인
kubectl get nodes
kubectl get pods --all-namespaces
```

## 모니터링

### CloudWatch Logs
Control Plane 로그는 CloudWatch Logs로 전송됩니다:
- API 서버 로그
- Audit 로그
- Authenticator 로그
- Controller Manager 로그
- Scheduler 로그

### 노드 모니터링
```bash
# 노드 상태 확인
kubectl get nodes -o wide

# 리소스 사용량 확인
kubectl top nodes
kubectl top pods --all-namespaces
```

## 트러블슈팅

### 클러스터 상태 확인
```bash
aws eks describe-cluster --name planit-dev-eks-cluster
```

### 노드 그룹 상태 확인
```bash
aws eks describe-nodegroup \
  --cluster-name planit-dev-eks-cluster \
  --nodegroup-name planit-dev-eks-cluster-node-group
```

### Pod 문제 진단
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl get events --sort-by='.lastTimestamp'
```

## 주의사항

1. **비용**: EKS 클러스터는 시간당 요금이 부과됩니다
2. **노드 수**: 프로덕션 환경에서는 최소 3개 이상의 노드 권장
3. **버전 업그레이드**: Kubernetes 버전 업그레이드 시 호환성 확인 필요
4. **보안**: 프로덕션에서는 `endpoint_public_access = false` 권장

## 참고 자료

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
