# Cilium - Installation

**Pages:** 26

---

## Weave Net — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/installation/cni-chaining-weave/

**Contents:**
- Weave Net
- Create a CNI configuration
- Deploy Cilium with the portmap plugin enabled
- Validate the Installation
- Next Steps

This guide instructs how to install Cilium in chaining configuration on top of Weave Net.

Some advanced Cilium features may be limited when chaining with other CNI plugins, such as:

Layer 7 Policy (see GitHub issue 12454)

IPsec Transparent Encryption (see GitHub issue 15596)

Create a chaining.yaml file based on the following template to specify the desired CNI chaining configuration:

Deploy the ConfigMap:

Setup Helm repository:

Deploy Cilium release via Helm:

The new CNI chaining configuration will not apply to any pod that is already running the cluster. Existing pods will be reachable and Cilium will load-balance to them but policy enforcement will not apply to them and load-balancing is not performed for traffic originating from existing pods.

You must restart these pods in order to invoke the chaining configuration on them.

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

To validate that Cilium has been properly installed, you can run

Run the following command to validate that your cluster has proper network connectivity:

The connectivity test may fail to deploy due to too many open files in one or more of the pods. If you notice this error, you can increase the inotify resource limits on your host machine (see Pod errors due to “too many open files”).

Congratulations! You have a fully functional Kubernetes cluster with Cilium. 🎉

You can monitor as Cilium and all required components are being installed:

It may take a couple of minutes for all components to come up:

You can deploy the “connectivity-check” to test connectivity between pods. It is recommended to create a separate namespace for this.

Deploy the check with:

It will deploy a series of deployments which will use various connectivity paths to connect to each other. Connectivity paths include with and without service load-balancing and various network policy combinations. The pod name indicates the connectivity variant and the readiness and liveness gate indicates success or failure of the test:

If you deploy the connectivity check to a single node cluster, pods that check multi-node functionalities will remain in the Pending state. This is expected since these pods need at least 2 nodes to be scheduled successfully.

Once done with the test, remove the cilium-test namespace:

Setting up Hubble Observability

Inspecting Network Flows with the CLI

Service Map & Hubble UI

Identity-Aware and HTTP-Aware Policy Enforcement

Setting up Cluster Mesh

---

## Installation using Azure CNI Powered by Cilium in AKS — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/installation/k8s-install-aks/

**Contents:**
- Installation using Azure CNI Powered by Cilium in AKS
- Create the cluster
- Validate the Installation
- Delegated Azure IPAM

This guide walks you through the installation of Cilium on AKS (Azure Kubernetes Service) via the Azure Container Network Interface (CNI) Powered by Cilium option.

Create an Azure CNI Powered by Cilium AKS cluster with network-plugin azure and --network-dataplane cilium. You can create the cluster either in podsubnet or overlay mode. In both modes, traffic is routed through the Azure Virtual Network Stack. The choice between these modes depends on the specific use case and requirements of the cluster. Refer to the related documentation to know more about these two modes.

See also the detailed instructions from scratch.

See also the detailed instructions from scratch.

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

To validate that Cilium has been properly installed, you can run

Run the following command to validate that your cluster has proper network connectivity:

The connectivity test may fail to deploy due to too many open files in one or more of the pods. If you notice this error, you can increase the inotify resource limits on your host machine (see Pod errors due to “too many open files”).

Congratulations! You have a fully functional Kubernetes cluster with Cilium. 🎉

You can monitor as Cilium and all required components are being installed:

It may take a couple of minutes for all components to come up:

You can deploy the “connectivity-check” to test connectivity between pods. It is recommended to create a separate namespace for this.

Deploy the check with:

It will deploy a series of deployments which will use various connectivity paths to connect to each other. Connectivity paths include with and without service load-balancing and various network policy combinations. The pod name indicates the connectivity variant and the readiness and liveness gate indicates success or failure of the test:

If you deploy the connectivity check to a single node cluster, pods that check multi-node functionalities will remain in the Pending state. This is expected since these pods need at least 2 nodes to be scheduled successfully.

Once done with the test, remove the cilium-test namespace:

Delegated Azure IPAM (IP Address Manager) manages the IP allocation for pods created in Azure CNI Powered by Cilium clusters. It assigns IPs that are routable in Azure Virtual Network stack. To know more about the Delegated Azure IPAM, see Azure Delegated IPAM.

---

## Installation Using K3s — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/installation/k3s/

**Contents:**
- Installation Using K3s
- Install a Master Node
- Install Agent Nodes (Optional)
- Configure Cluster Access
- Install Cilium
- Validate the Installation
- Next Steps

This guide walks you through installation of Cilium on K3s, a highly available, certified Kubernetes distribution designed for production workloads in unattended, resource-constrained, remote locations or inside IoT appliances.

Cilium is presently supported on amd64 and arm64 architectures.

The first step is to install a K3s master node making sure to disable support for the default CNI plugin and the built-in network policy enforcer:

If running Cilium in Kubernetes Without kube-proxy mode, add option --disable-kube-proxy

K3s can run in standalone mode or as a cluster making it a great choice for local testing with multi-node data paths. Agent nodes are joined to the master node using a node-token which can be found on the master node at /var/lib/rancher/k3s/server/node-token.

Install K3s on agent nodes and join them to the master node making sure to replace the variables with values from your environment:

Should you encounter any issues during the installation, please refer to the Troubleshooting section and/or seek help on Cilium Slack.

Please consult the Kubernetes Requirements for information on how you need to configure your Kubernetes cluster to operate with Cilium.

For the Cilium CLI to access the cluster in successive steps you will need to use the kubeconfig file stored at /etc/rancher/k3s/k3s.yaml by setting the KUBECONFIG environment variable:

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

Install Cilium with --set=ipam.operator.clusterPoolIPv4PodCIDRList="10.42.0.0/16" to match k3s default podCIDR 10.42.0.0/16.

If you are using Rancher Desktop, you may need to override the cni path by adding the additional flag --set 'cni.binPath=/usr/libexec/cni'

Install Cilium by running:

To validate that Cilium has been properly installed, you can run

Run the following command to validate that your cluster has proper network connectivity:

The connectivity test may fail to deploy due to too many open files in one or more of the pods. If you notice this error, you can increase the inotify resource limits on your host machine (see Pod errors due to “too many open files”).

Congratulations! You have a fully functional Kubernetes cluster with Cilium. 🎉

Setting up Hubble Observability

Inspecting Network Flows with the CLI

Service Map & Hubble UI

Identity-Aware and HTTP-Aware Policy Enforcement

Setting up Cluster Mesh

---

## External Installers — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/installation/external-toc/

**Contents:**
- External Installers

---

## Considerations on Node Pool Taints and Unmanaged Pods — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/installation/taints/

**Contents:**
- Considerations on Node Pool Taints and Unmanaged Pods

Depending on the environment or cloud provider being used, a CNI plugin and/or configuration file may be pre-installed in nodes belonging to a given cluster where Cilium is being installed or already running. Upon starting on a given node, and if it is intended as the exclusive CNI plugin for the cluster, Cilium does its best to take ownership of CNI on the node. However, a couple situations can prevent this from happening:

Cilium can only take ownership of CNI on a node after starting. Pods starting before Cilium runs on a given node may get IPs from the pre-configured CNI.

Some cloud providers may revert changes made to the CNI configuration by Cilium during operations such as node reboots, updates or routine maintenance.

This is notably the case with GKE (non-Dataplane V2), in which node reboots and upgrades will undo changes made by Cilium and re-instate the default CNI configuration.

To help overcome this situation to the largest possible extent in environments and cloud providers where Cilium isn’t supported as the single CNI, Cilium can manipulate Kubernetes’s taints on a given node to help preventing pods from starting before Cilium runs on said node. The mechanism works as follows:

The cluster administrator places a specific taint (see below) on a given uninitialized node. Depending on the taint’s effect (see below), this prevents pods that don’t have a matching toleration from either being scheduled or altogether running on the node until the taint is removed.

Cilium runs on the node, initializes it and, once ready, removes the aforementioned taint.

From this point on, pods will start being scheduled and running on the node, having their networking managed by Cilium.

If Cilium is temporarily removed from the node, the Operator will re-apply the taint (but only with NoSchedule).

By default, the taint key is node.cilium.io/agent-not-ready, but in some scenarios (such as when Cluster Autoscaler is being used but its flags cannot be configured) this key may need to be tweaked. This can be done using the agent-not-ready-taint-key option. In the aforementioned example, users should specify a key starting with ignore-taint.cluster-autoscaler.kubernetes.io/. When such a value is used, the Cluster Autoscaler will ignore it when simulating scheduling, allowing the cluster to scale up.

The taint’s effect should be chosen taking into account the following considerations:

If NoSchedule is used, pods won’t be scheduled to a node until Cilium has the chance to remove the taint. However, one practical effect of this is that if some external process (such as a reboot) resets the CNI configuration on said node, pods that were already scheduled will be allowed to start concurrently with Cilium when the node next reboots, and hence may become unmanaged and have their networking being managed by another CNI plugin.

If NoExecute is used, pods won’t be executed (nor scheduled) on a node until Cilium has had the chance to remove the taint. One practical effect of this is that whenever the taint is added back to the node by some external process (such as during an upgrade or eventually a routine operation), pods will be evicted from the node until Cilium has had the chance to remove the taint.

Another important thing to consider is the concept of node itself, and the different point of views over a node. For example, the instance/VM which backs a Kubernetes node can be patched or reset filesystem-wise by a cloud provider, or altogether replaced with an entirely new instance/VM that comes back with the same name as the already-existing Kubernetes Node resource. Even though in said scenarios the node-pool-level taint will be added back to the Node resource, pods that were already scheduled to the node having this name will run on the node at the same time as Cilium, potentially becoming unmanaged. This is why NoExecute is recommended, as assuming the taint is added back in this scenario, already-scheduled pods won’t run.

However, on some environments or cloud providers, and as mentioned above, it may happen that a taint established at the node-pool level is added back to a node after Cilium has removed it and for reasons other than a node upgrade/reset. The exact circumstances in which this may happen may vary, but this may lead to unexpected/undesired pod evictions in the particular case when NoExecute is being used as the taint effect. It is, thus, recommended that in each deployment and depending on the environment or cloud provider, a careful decision is made regarding the taint effect (or even regarding whether to use the taint-based approach at all) based on the information above, on the environment or cloud provider’s documentation, and on the fact that one is essentially establishing a trade-off between having unmanaged pods in the cluster (which can lead to dropped traffic and other issues) and having unexpected/undesired evictions (which can lead to application downtime).

Taking into account all of the above, throughout the Cilium documentation we recommend NoExecute to be used as we believe it to be the least disruptive mode that users can use to deploy Cilium on cloud providers.

---

## Installation using Rancher Kubernetes Engine — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/installation/k8s-install-rke/

**Contents:**
- Installation using Rancher Kubernetes Engine
- Install a Cluster Using RKE1
- Install a Cluster Using RKE2
- Deploy Cilium
- Validate the Installation
- Next Steps

This guide walks you through installation of Cilium on standalone Rancher Kubernetes Engine (RKE) clusters, SUSE’s CNCF-certified Kubernetes distribution with built-in security and compliance capabilities. RKE solves the common frustration of installation complexity with Kubernetes by removing most host dependencies and presenting a stable path for deployment, upgrades, and rollbacks.

If you’re using the Rancher Management Console/UI to install your RKE clusters, head over to the Installation using Rancher guide.

The first step is to install a cluster based on the RKE1 Kubernetes installation guide. When creating the cluster, make sure to change the default network plugin in the generated config.yaml file.

The first step is to install a cluster based on the RKE2 Kubernetes installation guide. You can either use the RKE2-integrated Cilium version or you can configure the RKE2 cluster with cni: none (see doc), and install Cilium with Helm. You can use either method while the directly integrated one is recommended for most users.

Cilium power-users might want to use the cni: none method as Rancher is using a custom rke2-cilium Helm chart with independent release cycles for its integrated Cilium version. By instead using the out-of-band Cilium installation (based on the official Cilium Helm chart), power-users gain more flexibility from a Cilium perspective.

Install Cilium via helm install:

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

Install Cilium by running:

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

To validate that Cilium has been properly installed, you can run

Run the following command to validate that your cluster has proper network connectivity:

The connectivity test may fail to deploy due to too many open files in one or more of the pods. If you notice this error, you can increase the inotify resource limits on your host machine (see Pod errors due to “too many open files”).

Congratulations! You have a fully functional Kubernetes cluster with Cilium. 🎉

You can monitor as Cilium and all required components are being installed:

It may take a couple of minutes for all components to come up:

You can deploy the “connectivity-check” to test connectivity between pods. It is recommended to create a separate namespace for this.

Deploy the check with:

It will deploy a series of deployments which will use various connectivity paths to connect to each other. Connectivity paths include with and without service load-balancing and various network policy combinations. The pod name indicates the connectivity variant and the readiness and liveness gate indicates success or failure of the test:

If you deploy the connectivity check to a single node cluster, pods that check multi-node functionalities will remain in the Pending state. This is expected since these pods need at least 2 nodes to be scheduled successfully.

Once done with the test, remove the cilium-test namespace:

Setting up Hubble Observability

Inspecting Network Flows with the CLI

Service Map & Hubble UI

Identity-Aware and HTTP-Aware Policy Enforcement

Setting up Cluster Mesh

---

## CNI Chaining — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/installation/cni-chaining/

**Contents:**
- CNI Chaining

CNI chaining allows to use Cilium in combination with other CNI plugins.

With Cilium CNI chaining, the base network connectivity and IP address management is managed by the non-Cilium CNI plugin, but Cilium attaches eBPF programs to the network devices created by the non-Cilium plugin to provide L3/L4 network visibility, policy enforcement and other advanced features.

---

## Generic Veth Chaining — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/installation/cni-chaining-generic-veth/

**Contents:**
- Generic Veth Chaining
- Validate that the current CNI plugin is using veth
- Create a CNI configuration to define your chaining configuration
- Deploy Cilium with the portmap plugin enabled

The generic veth chaining plugin enables CNI chaining on top of any CNI plugin that is using a veth device model. The majority of CNI plugins use such a model.

Some advanced Cilium features may be limited when chaining with other CNI plugins, such as:

Layer 7 Policy (see GitHub issue 12454)

IPsec Transparent Encryption (see GitHub issue 15596)

Log into one of the worker nodes using SSH

Run ip -d link to list all network devices on the node. You should be able spot network devices representing the pods running on that node.

A network device might look something like this:

The veth keyword on line 3 indicates that the network device type is virtual ethernet.

If the CNI plugin you are chaining with is currently not using veth then the generic-veth plugin is not suitable. In that case, a full CNI chaining plugin is required which understands the device model of the underlying plugin. Writing such a plugin is trivial, contact us on Cilium Slack for more details.

Create a chaining.yaml file based on the following template to specify the desired CNI chaining configuration:

Deploy the ConfigMap:

Setup Helm repository:

Deploy Cilium release via Helm:

---

## Installation with external etcd — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/installation/k8s-install-external-etcd/

**Contents:**
- Installation with external etcd
- When do I need to use a kvstore?
- Requirements
- Kvstore and Cilium dependency
- Configure Cilium
  - Optional: Configure the SSL certificates
- Validate the Installation
- Next Steps

This guide walks you through the steps required to set up Cilium on Kubernetes using an external etcd. Use of an external etcd provides better performance and is suitable for larger environments.

Should you encounter any issues during the installation, please refer to the Troubleshooting section and/or seek help on Cilium Slack.

Unlike the section Cilium Quick Installation, this guide explains how to configure Cilium to use an external kvstore such as etcd. If you are unsure whether you need to use a kvstore at all, the following is a list of reasons when to use a kvstore:

If you are running in an environment where you observe a high overhead in state propagation caused by Kubernetes events.

If you do not want Cilium to store state in Kubernetes custom resources (CRDs).

If you run a cluster with more pods and more nodes than the ones tested in the Scalability report.

Make sure your Kubernetes environment is meeting the requirements:

Linux kernel >= 5.10 or equivalent

Kubernetes in CNI mode

Mounted eBPF filesystem mounted on all worker nodes

Recommended: Enable PodCIDR allocation (--allocate-node-cidrs) in the kube-controller-manager (recommended)

Refer to the section Requirements for detailed instruction on how to prepare your Kubernetes environment.

You will also need an external etcd version 3.4.0 or higher.

When using an external kvstore, it’s important to break the circular dependency between Cilium and kvstore. If kvstore pods are running within the same cluster and are using a pod network then kvstore relies on Cilium. However, Cilium also relies on the kvstore, which creates a circular dependency. There are two recommended ways of breaking this dependency:

Deploy kvstore outside of cluster or on separately managed cluster.

Deploy kvstore pods with a host network, by specifying hostNetwork: true in the pod spec.

When using an external kvstore, the address of the external kvstore needs to be configured in the ConfigMap. Download the base YAML and configure it with Helm:

Setup Helm repository:

Deploy Cilium release via Helm:

If you do not want Cilium to store state in Kubernetes custom resources (CRDs), consider setting identityAllocationMode:

Create a Kubernetes secret with the root certificate authority, and client-side key and certificate of etcd:

Adjust the helm template generation to enable SSL for etcd and use https instead of http for the etcd endpoint URLs:

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

To validate that Cilium has been properly installed, you can run

Run the following command to validate that your cluster has proper network connectivity:

The connectivity test may fail to deploy due to too many open files in one or more of the pods. If you notice this error, you can increase the inotify resource limits on your host machine (see Pod errors due to “too many open files”).

Congratulations! You have a fully functional Kubernetes cluster with Cilium. 🎉

You can monitor as Cilium and all required components are being installed:

It may take a couple of minutes for all components to come up:

You can deploy the “connectivity-check” to test connectivity between pods. It is recommended to create a separate namespace for this.

Deploy the check with:

It will deploy a series of deployments which will use various connectivity paths to connect to each other. Connectivity paths include with and without service load-balancing and various network policy combinations. The pod name indicates the connectivity variant and the readiness and liveness gate indicates success or failure of the test:

If you deploy the connectivity check to a single node cluster, pods that check multi-node functionalities will remain in the Pending state. This is expected since these pods need at least 2 nodes to be scheduled successfully.

Once done with the test, remove the cilium-test namespace:

Setting up Hubble Observability

Inspecting Network Flows with the CLI

Service Map & Hubble UI

Identity-Aware and HTTP-Aware Policy Enforcement

Setting up Cluster Mesh

---

## Installation on Broadcom VMware ESXi / NSX — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/installation/k8s-install-broadcom-vmware-esxi-nsx/

**Contents:**
- Installation on Broadcom VMware ESXi / NSX
- Deploying Cilium on Broadcom VMware vSphere ESXi with or without NSX(-T)
- Troubleshooting
  - Pod Communication Failure Across Hosts

Cilium can be installed on VMware ESXi with or without NSX by using official image.

Cilium can be deployed on VMware vSphere ESXi, with or without NSX(-T). However, there are known issues when using tunnel mode with VXLAN as the encapsulation.

Install Cilium via helm install with VXLAN Protocol

With NSX(-T), use a custom port for the tunnelPort flag, for instance --set tunnelPort=8223. GitHub issue 21801 tracks some reports of problems with offloads when using the VXLAN UDP port standard (4789) or draft (8472).

Install Cilium via helm install with Geneve Protocol

NSX(-T) with Network Virtualization (with Edge T0/T1) also uses Geneve Protocol between Transport Nodes (ESXi, Edge). Be aware when troubleshooting that the Geneve traffic you observe on the network may be generated by either NSX(-T) or Cilium.

When deploying Cilium with some old release ESXi (7) or with NSX-T (3.x/4.x), with VXLAN encapsulation, the inter-host pod communication may fail, except for ICMP (ping), which still functions.

In the Cilium-health status you will see:

The problem originates from a bug in the VMXNET3 driver related to NIC offload support for VXLAN encapsulation. This is due to the use of an outdated standard port (8472) for VXLAN.

In this case you need to change to VXLAN Port --set tunnelPort=8223 or use Geneve tunnel Protocol --set tunnelProtocol=geneve. There is some workaround about Disable NIC Offload but it is not recommended solution.

---

## Cilium Quick Installation — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/

**Contents:**
- Cilium Quick Installation
- Create the Cluster
- Install the Cilium CLI
- Install Cilium
- Validate the Installation
- Next Steps

This guide will walk you through the quick default installation. It will automatically detect and use the best configuration possible for the Kubernetes distribution you are using. All state is stored using Kubernetes custom resource definitions (CRDs).

This is the best installation method for most use cases. For large environments (> 500 nodes) or if you want to run specific datapath modes, refer to the Getting Started guide.

Should you encounter any issues during the installation, please refer to the Troubleshooting section and/or seek help on Cilium Slack.

If you don’t have a Kubernetes Cluster yet, you can use the instructions below to create a Kubernetes cluster locally or using a managed Kubernetes service:

The following commands create a Kubernetes cluster using Google Kubernetes Engine. See Installing Google Cloud SDK for instructions on how to install gcloud and prepare your account.

Please make sure to read and understand the documentation page on taint effects and unmanaged pods.

The following commands create a Kubernetes cluster using Azure Kubernetes Service with no CNI plugin pre-installed (BYOCNI). See Azure Cloud CLI for instructions on how to install az and prepare your account, and the Bring your own CNI documentation for more details about BYOCNI prerequisites / implications.

The following commands create a Kubernetes cluster with eksctl using Amazon Elastic Kubernetes Service. See eksctl Installation for instructions on how to install eksctl and prepare your account.

Please make sure to read and understand the documentation page on taint effects and unmanaged pods.

Install kind >= v0.7.0 per kind documentation: Installation and Usage

Cilium may fail to deploy due to too many open files in one or more of the agent pods. If you notice this error, you can increase the inotify resource limits on your host machine (see Pod errors due to “too many open files”).

Install minikube ≥ v1.28.0 as per minikube documentation: Install Minikube. The following command will bring up a single node minikube cluster prepared for installing cilium.

This may not install the latest version of cilium.

It might be necessary to add --host-dns-resolver=false if using the Virtualbox provider, otherwise DNS resolution may not work after Cilium installation.

Kubespray requires Python ≥ 3.10 for recent versions. For environment setup and dependencies installation, see the Kubespray Ansible documentation.

Setting kube_network_plugin: cni ensures the cluster deploys without any network plugin, allowing Cilium to be installed separately afterward.

(Adjust the path to your private SSH key.)

For more detailed configuration options, refer to the Kubespray documentation.

Install Rancher Desktop >= v1.1.0 as per Rancher Desktop documentation: Install Rancher Desktop.

Next you need to configure Rancher Desktop to disable the built-in CNI so you can install Cilium.

Configuring Rancher Desktop is done using a YAML configuration file. This step is necessary in order to disable the default CNI and replace it with Cilium.

Next you need to start Rancher Desktop with containerd and create a override.yaml:

After the file is created move it into your Rancher Desktop’s lima/_config directory:

Finally, open the Rancher Desktop UI and go to the Troubleshooting panel and click “Reset Kubernetes”.

After a few minutes Rancher Desktop will start back up prepared for installing Cilium.

This is a beta feature. Please provide feedback and file a GitHub issue if you experience any problems.

The AlibabaCloud ENI integration with Cilium is subject to the following limitations:

It is currently only enabled for IPv4.

It only works with instances supporting ENI. Refer to Instance families for details.

Setup a Kubernetes on AlibabaCloud. You can use any method you prefer. The quickest way is to create an ACK (Alibaba Cloud Container Service for Kubernetes) cluster and to replace the CNI plugin with Cilium. For more details on how to set up an ACK cluster please follow the official documentation.

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

To learn more about the Cilium CLI, check out eCHO episode 8: Exploring the Cilium CLI.

You can install Cilium on any Kubernetes cluster. Pick one of the options below:

These are the generic instructions on how to install Cilium into any Kubernetes cluster. The installer will attempt to automatically pick the best configuration options for you. Please see the other tabs for distribution/platform specific instructions which also list the ideal default configuration for particular platforms.

Kubernetes must be configured to use CNI (see Network Plugin Requirements)

See System Requirements for more details on the system requirements.

Install Cilium into the Kubernetes cluster pointed to by your current kubectl context:

To install Cilium on Google Kubernetes Engine (GKE), perform the following steps:

Default Configuration:

The cluster should be created with the taint node.cilium.io/agent-not-ready=true:NoExecute using --node-taints option. However, there are other options. Please make sure to read and understand the documentation page on taint effects and unmanaged pods.

Install Cilium into the GKE cluster:

On AKS, Cilium can be installed either manually by administrators via Bring your own CNI or automatically by AKS via Azure CNI Powered by Cilium. Bring your own CNI offers more flexibility and customization as administrators have full control over the installation, but it does not integrate natively with the Azure network stack and administrators need to handle Cilium upgrades. Azure CNI Powered by Cilium integrates natively with the Azure network stack and upgrades are handled by AKS, but it does not offer as much flexibility and customization as it is controlled by AKS. The following instructions assume Bring your own CNI. For Azure CNI Powered by Cilium, see the external installer guide Installation using Azure CNI Powered by Cilium in AKS for dedicated instructions.

The AKS cluster must be created with --network-plugin none. See the Bring your own CNI documentation for more details about BYOCNI prerequisites / implications.

Make sure that you set a cluster pool IPAM pod CIDR that does not overlap with the default service CIDR of AKS. For example, you can use --helm-set ipam.operator.clusterPoolIPv4PodCIDRList=192.168.0.0/16.

Install Cilium into the AKS cluster:

To install Cilium on Amazon Elastic Kubernetes Service (EKS), perform the following steps:

Default Configuration:

For more information on AWS ENI mode, see AWS ENI.

To chain Cilium on top of the AWS CNI, see AWS VPC CNI plugin.

You can also bring up Cilium in a Single-Region, Multi-Region, or Multi-AZ environment for EKS.

The EKS Managed Nodegroups must be properly tainted to ensure applications pods are properly managed by Cilium:

managedNodeGroups should be tainted with node.cilium.io/agent-not-ready=true:NoExecute to ensure application pods will only be scheduled once Cilium is ready to manage them. However, there are other options. Please make sure to read and understand the documentation page on taint effects and unmanaged pods.

Below is an example on how to use ClusterConfig file to create the cluster:

The AWS ENI integration of Cilium is currently only enabled for IPv4. If you want to use IPv6, use a datapath/IPAM mode other than ENI.

Install Cilium into the EKS cluster.

If you have to uninstall Cilium and later install it again, that could cause connectivity issues due to aws-node DaemonSet flushing Linux routing tables. The issues can be fixed by restarting all pods, alternatively to avoid such issues you can delete aws-node DaemonSet prior to installing Cilium.

To install Cilium on OpenShift, perform the following steps:

Default Configuration:

Cilium is a Certified OpenShift CNI Plugin and is best installed when an OpenShift cluster is created using the OpenShift installer. Please refer to Installation on OpenShift OKD for more information.

To install Cilium top of a standalone Rancher Kubernetes Engine 1 (RKE1) or Rancher Kubernetes Engine 2 (RKE2) cluster, follow the installation instructions provided in the dedicated Installation using Rancher Kubernetes Engine guide.

If your RKE1/2 cluster is managed by Rancher (non-standalone), follow the Installation using Rancher guide instead.

Install Cilium into your newly created RKE cluster:

To install Cilium on k3s, perform the following steps:

Default Configuration:

Install your k3s cluster as you normally would but making sure to disable support for the default CNI plugin and the built-in network policy enforcer so you can install Cilium on top:

For the Cilium CLI to access the cluster in successive steps you will need to use the kubeconfig file stored at /etc/rancher/k3s/k3s.yaml by setting the KUBECONFIG environment variable:

Install Cilium into your newly created Kubernetes cluster:

You can install Cilium using Helm on Alibaba ACK, refer to Installation using Helm for details.

If the installation fails for some reason, run cilium status to retrieve the overall status of the Cilium deployment and inspect the logs of whatever pods are failing to be deployed.

You may be seeing cilium install print something like this:

This indicates that your cluster was already running some pods before Cilium was deployed and the installer has automatically restarted them to ensure all pods get networking provided by Cilium.

To validate that Cilium has been properly installed, you can run

Run the following command to validate that your cluster has proper network connectivity:

The connectivity test may fail to deploy due to too many open files in one or more of the pods. If you notice this error, you can increase the inotify resource limits on your host machine (see Pod errors due to “too many open files”).

Congratulations! You have a fully functional Kubernetes cluster with Cilium. 🎉

Setting up Hubble Observability

Inspecting Network Flows with the CLI

Service Map & Hubble UI

Identity-Aware and HTTP-Aware Policy Enforcement

Setting up Cluster Mesh

---

## AWS VPC CNI plugin — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/installation/cni-chaining-aws-cni/

**Contents:**
- AWS VPC CNI plugin
- Setting up a cluster on AWS
- Restart existing pods
- Validate the Installation
- Advanced
  - Enabling security groups for pods (EKS)
- Next Steps

This guide explains how to set up Cilium in combination with the AWS VPC CNI plugin. In this hybrid mode, the AWS VPC CNI plugin is responsible for setting up the virtual network devices as well as for IP address management (IPAM) via ENIs. After the initial networking is setup for a given pod, the Cilium CNI plugin is called to attach eBPF programs to the network devices set up by the AWS VPC CNI plugin in order to enforce network policies, perform load-balancing and provide encryption.

Some advanced Cilium features may be limited when chaining with other CNI plugins, such as:

Layer 7 Policy (see GitHub issue 12454)

IPsec Transparent Encryption (see GitHub issue 15596)

If you require advanced features of Cilium, consider migrating fully to Cilium. To help you with the process, you can watch two Principal Engineers at Meltwater talk about how they migrated Meltwater’s production Kubernetes clusters - from the AWS VPC CNI plugin to Cilium.

Please ensure that you are running version 1.11.2 or newer of the AWS VPC CNI plugin to guarantee compatibility with Cilium.

If you are running an older version, as in the above example, you can upgrade it with:

Follow the instructions in the Cilium Quick Installation guide to set up an EKS cluster, or use any other method of your preference to set up a Kubernetes cluster on AWS.

Ensure that the aws-vpc-cni-k8s plugin is installed — which will already be the case if you have created an EKS cluster. Also, ensure the version of the plugin is up-to-date as per the above.

Setup Helm repository:

Deploy Cilium via Helm:

This will enable chaining with the AWS VPC CNI plugin. It will also disable tunneling, as it’s not required since ENI IP addresses can be directly routed in the VPC. For the same reason, masquerading can be disabled as well.

The new CNI chaining configuration will not apply to any pod that is already running in the cluster. Existing pods will be reachable, and Cilium will load-balance to them, but not from them. Policy enforcement will also not be applied. For these reasons, you must restart these pods so that the chaining configuration can be applied to them.

The following command can be used to check which pods need to be restarted:

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

To validate that Cilium has been properly installed, you can run

Run the following command to validate that your cluster has proper network connectivity:

The connectivity test may fail to deploy due to too many open files in one or more of the pods. If you notice this error, you can increase the inotify resource limits on your host machine (see Pod errors due to “too many open files”).

Congratulations! You have a fully functional Kubernetes cluster with Cilium. 🎉

You can monitor as Cilium and all required components are being installed:

It may take a couple of minutes for all components to come up:

You can deploy the “connectivity-check” to test connectivity between pods. It is recommended to create a separate namespace for this.

Deploy the check with:

It will deploy a series of deployments which will use various connectivity paths to connect to each other. Connectivity paths include with and without service load-balancing and various network policy combinations. The pod name indicates the connectivity variant and the readiness and liveness gate indicates success or failure of the test:

If you deploy the connectivity check to a single node cluster, pods that check multi-node functionalities will remain in the Pending state. This is expected since these pods need at least 2 nodes to be scheduled successfully.

Once done with the test, remove the cilium-test namespace:

Cilium can be used alongside the security groups for pods feature of EKS in supported clusters when running in chaining mode. Follow the instructions below to enable this feature:

The following guide requires jq and the AWS CLI to be installed and configured.

Make sure that the AmazonEKSVPCResourceController managed policy is attached to the IAM role associated with the EKS cluster:

Then, as mentioned above, make sure that the version of the AWS VPC CNI plugin running in the cluster is up-to-date:

Next, patch the kube-system/aws-node DaemonSet in order to enable security groups for pods:

After the rollout is complete, all nodes in the cluster should have the vps.amazonaws.com/has-trunk-attached label set to true:

From this moment everything should be in place. For details on how to actually associate security groups to pods, please refer to the official documentation.

Setting up Hubble Observability

Inspecting Network Flows with the CLI

Service Map & Hubble UI

Identity-Aware and HTTP-Aware Policy Enforcement

Setting up Cluster Mesh

---

## Azure CNI (Legacy) — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/installation/cni-chaining-azure-cni/

**Contents:**
- Azure CNI (Legacy)
- Create an AKS + Cilium CNI configuration
- Deploy Cilium
- Restart unmanaged Pods
- Validate the Installation
- Next Steps

For most users, the best way to run Cilium on AKS is either AKS BYO CNI as described in Cilium Quick Installation or Azure CNI Powered by Cilium. This guide provides alternative instructions to run Cilium with Azure CNI in a chaining configuration. This is the legacy way of running Azure CNI with cilium as Azure IPAM is legacy, for more information see Azure IPAM.

Some advanced Cilium features may be limited when chaining with other CNI plugins, such as:

Layer 7 Policy (see GitHub issue 12454)

IPsec Transparent Encryption (see GitHub issue 15596)

If you’d like a video explanation of the Azure CNI Powered by Cilium, check out eCHO episode 70: Azure CNI Powered by Cilium.

This guide explains how to set up Cilium in combination with Azure CNI in a chaining configuration. In this hybrid mode, the Azure CNI plugin is responsible for setting up the virtual network devices as well as address allocation (IPAM). After the initial networking is setup, the Cilium CNI plugin is called to attach eBPF programs to the network devices set up by Azure CNI to enforce network policies, perform load-balancing, and encryption.

Create a chaining.yaml file based on the following template to specify the desired CNI chaining configuration. This ConfigMap will be installed as the CNI configuration file on all nodes and defines the chaining configuration. In the example below, the Azure CNI, portmap, and Cilium are chained together.

Deploy the ConfigMap:

Setup Helm repository:

Deploy Cilium release via Helm:

This will create both the main cilium daemonset, as well as the cilium-node-init daemonset, which handles tasks like mounting the eBPF filesystem and updating the existing Azure CNI plugin to run in ‘transparent’ mode.

If you did not create a cluster with the nodes tainted with the taint node.cilium.io/agent-not-ready, then unmanaged pods need to be restarted manually. Restart all already running pods which are not running in host-networking mode to ensure that Cilium starts managing them. This is required to ensure that all pods which have been running before Cilium was deployed have network connectivity provided by Cilium and NetworkPolicy applies to them:

This may error out on macOS due to -r being unsupported by xargs. In this case you can safely run this command without -r with the symptom that this will hang if there are no pods to restart. You can stop this with ctrl-c.

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

To validate that Cilium has been properly installed, you can run

Run the following command to validate that your cluster has proper network connectivity:

The connectivity test may fail to deploy due to too many open files in one or more of the pods. If you notice this error, you can increase the inotify resource limits on your host machine (see Pod errors due to “too many open files”).

Congratulations! You have a fully functional Kubernetes cluster with Cilium. 🎉

You can monitor as Cilium and all required components are being installed:

It may take a couple of minutes for all components to come up:

You can deploy the “connectivity-check” to test connectivity between pods. It is recommended to create a separate namespace for this.

Deploy the check with:

It will deploy a series of deployments which will use various connectivity paths to connect to each other. Connectivity paths include with and without service load-balancing and various network policy combinations. The pod name indicates the connectivity variant and the readiness and liveness gate indicates success or failure of the test:

If you deploy the connectivity check to a single node cluster, pods that check multi-node functionalities will remain in the Pending state. This is expected since these pods need at least 2 nodes to be scheduled successfully.

Once done with the test, remove the cilium-test namespace:

Setting up Hubble Observability

Inspecting Network Flows with the CLI

Service Map & Hubble UI

Identity-Aware and HTTP-Aware Policy Enforcement

Setting up Cluster Mesh

---

## Installation on OpenShift OKD — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/installation/k8s-install-openshift-okd/

**Contents:**
- Installation on OpenShift OKD

There is currently no community-maintained installation of Cilium on OpenShift. However, Cilium can be installed on OpenShift by using vendor-maintained OLM images. These images, and the relevant installation instructions for them, can be found on the Red Hat Ecosystem Catalog:

Isovalent Enterprise for Cilium Software Page

Certified Isovalent Enterprise for Cilium OLM container images

To learn more about OpenShift and Cilium, check out eCHO episode 31: OpenShift Test Environment with Cilium.

---

## Migrating a cluster to Cilium — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/installation/k8s-install-migration/

**Contents:**
- Migrating a cluster to Cilium
- Background
  - Migration via dual overlays
- Requirements
- Limitations
- Overview
- Migration procedure
  - Preparation
  - Migration
  - Post-migration

Cilium can be used to migrate from another cni. Running clusters can be migrated on a node-by-node basis, without disrupting existing traffic or requiring a complete cluster outage or rebuild depending on the complexity of the migration case.

This document outlines how migrations with Cilium work. You will have a good understanding of the basic requirements, as well as see an example migration which you can practice using Kind.

When the kubelet creates a Pod’s Sandbox, the installed CNI, as configured in /etc/cni/net.d/, is called. The cni will handle the networking for a pod - including allocating an ip address, creating & configuring a network interface, and (potentially) establishing an overlay network. The Pod’s network configuration shares the same life cycle as the PodSandbox.

In the case of migration, we typically reconfigure /etc/cni/net.d/ to point to Cilium. However, any existing pods will still have been configured by the old network plugin and any new pods will be configured by the newer CNI. To complete the migration all Pods on the cluster that are configured by the old cni must be recycled in order to be a member of the new CNI.

A naive approach to migrating a CNI would be to reconfigure all nodes with a new CNI and then gradually restart each node in the cluster, thus replacing the CNI when the node is brought back up and ensuring that all pods are part of the new CNI.

This simple migration, while effective, comes at the cost of disrupting cluster connectivity during the rollout. Unmigrated and migrated nodes would be split in to two “islands” of connectivity, and pods would be randomly unable to reach one-another until the migration is complete.

Instead, Cilium supports a hybrid mode, where two separate overlays are established across the cluster. While pods on a given node can only be attached to one network, they have access to both Cilium and non-Cilium pods while the migration is taking place. As long as Cilium and the existing networking provider use a separate IP range, the Linux routing table takes care of separating traffic.

In this document we will discuss a model for live migrating between two deployed CNI implementations. This will have the benefit of reducing downtime of nodes and workloads and ensuring that workloads on both configured CNIs can communicate during migration.

For live migration to work, Cilium will be installed with a separate CIDR range and encapsulation port than that of the currently installed CNI. As long as Cilium and the existing CNI use a separate IP range, the Linux routing table takes care of separating traffic.

Live migration requires the following:

A new, distinct Cluster CIDR for Cilium to use

Use of the Cluster Pool IPAM mode

A distinct overlay, either protocol or port

An existing network plugin that uses the Linux routing stack, such as Flannel, Calico, or AWS-CNI

Currently, Cilium migration has not been tested with:

Changing IP families (e.g. from IPv4 to IPv6)

Migrating from Cilium in chained mode

An existing NetworkPolicy provider

During migration, Cilium’s NetworkPolicy and CiliumNetworkPolicy enforcement will be disabled. Otherwise, traffic from non-Cilium pods may be incorrectly dropped. Once the migration process is complete, policy enforcement can be re-enabled. If there is an existing NetworkPolicy provider, you may wish to temporarily delete all NetworkPolicies before proceeding.

It is strongly recommended to install Cilium using the cluster-pool IPAM allocator. This provides the strongest assurance that there will be no IP collisions.

Migration is highly dependent on the exact configuration of existing clusters. It is, thus, strongly recommended to perform a trial migration on a test or lab cluster.

The migration process utilizes the per-node configuration feature to selectively enable Cilium CNI. This allows for a controlled rollout of Cilium without disrupting existing workloads.

Cilium will be installed, first, in a mode where it establishes an overlay but does not provide CNI networking for any pods. Then, individual nodes will be migrated.

In summary, the process looks like:

Install cilium in “secondary” mode

Cordon, drain, migrate, and reboot each node

Remove the existing network provider

(Optional) Reboot each node again

Optional: Create a Kind cluster and install Flannel on it.

Optional: Monitor connectivity.

You may wish to install a tool such as goldpinger to detect any possible connectivity issues.

Select a new CIDR for pods. It must be distinct from all other CIDRs in use.

For Kind clusters, the default is 10.244.0.0/16. So, for this example, we will use 10.245.0.0/16.

Select a distinct encapsulation port. For example, if the existing cluster is using VXLAN, then you should either use GENEVE or configure Cilium to use VXLAN with a different port.

For this example, we will use VXLAN with a non-default port of 8473.

Create a helm values-migration.yaml file based on the following example. Be sure to fill in the CIDR you selected in step 1.

Configure any additional Cilium Helm values.

Cilium supports a number of Helm configuration options. You may choose to auto-detect typical ones using the cilium-cli. This will consume the template and auto-detect any other relevant Helm values. Review these values for your particular installation.

Install cilium using helm.

At this point, you should have a cluster with Cilium installed and an overlay established, but no pods managed by Cilium itself. You can verify this with the cilium command.

Create a per-node config that will instruct Cilium to “take over” CNI networking on the node. Initially, this will apply to no nodes; you will roll it out gradually via the migration process.

At this point, you are ready to begin the migration process. The basic flow is:

Select a node to be migrated. It is not recommended to start with a control-plane node.

Cordon and, optionally, drain the node in question.

Draining is not strictly required, but it is recommended. Otherwise pods will encounter a brief interruption while the node is rebooted.

Label the node. This causes the CiliumNodeConfig to apply to this node.

Restart Cilium. This will cause it to write its CNI configuration file.

If using kind, do so with docker:

Validate that the node has been successfully migrated.

Ensure the IP address of the pod is in the Cilium CIDR(s) supplied above and that the apiserver is reachable.

Once you are satisfied everything has been migrated successfully, select another unmigrated node in the cluster and repeat these steps.

Perform these steps once the cluster is fully migrated.

Ensure Cilium is healthy and that all pods have been migrated:

Update the Cilium configuration:

Cilium should be the primary CNI

NetworkPolicy should be enforced

The Operator can restart unmanaged pods

Optional: use eBPF Host-Routing. Enabling this will cause a short connectivity interruption on each node as the daemon restarts, but improves networking performance.

You can do this manually, or via the cilium tool (this will not apply changes to the cluster):

Then, apply the changes to the cluster:

Delete the per-node configuration:

Delete the previous network plugin.

At this point, all pods should be using Cilium for networking. You can easily verify this with cilium status. It is now safe to delete the previous network plugin from the cluster.

Most network plugins leave behind some resources, e.g. iptables rules and interfaces. These will be cleaned up when the node next reboots. If desired, you may perform a rolling reboot again.

---

## Installation using Kubespray — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/installation/k8s-install-kubespray/

**Contents:**
- Installation using Kubespray
- Installing Kubespray
- Infrastructure Provisioning
  - Configure AWS credentials
  - Configure Terraform Variables
  - Apply the configuration
- Installing Kubernetes cluster with Cilium as CNI
- Validate Cluster
- Validate the Installation
- Delete Cluster

The guide is to use Kubespray for creating an AWS Kubernetes cluster running Cilium as the CNI. The guide uses:

Latest Cilium released version (instructions for using the version are mentioned below)

Please consult Kubespray Prerequisites and Cilium System Requirements.

Install dependencies from requirements.txt

We will use Terraform for provisioning AWS infrastructure.

Export the variables for your AWS credentials

We will start by specifying the infrastructure needed for the Kubernetes cluster.

Open the file and change any defaults particularly, the number of master, etcd, and worker nodes. You can change the master and etcd number to 1 for deployments that don’t need high availability. By default, this tutorial will create:

VPC with 2 public and private subnets

Bastion Hosts and NAT Gateways in the Public Subnet

Three of each (masters, etcd, and worker nodes) in the Private Subnet

AWS ELB in the Public Subnet for accessing the Kubernetes API from the internet

Terraform scripts using CoreOS as base image.

Example terraform.tfvars file:

terraform init to initialize the following modules

Once initialized , execute:

This will generate a file, aws_kubespray_plan, depicting an execution plan of the infrastructure that will be created on AWS. To apply, execute:

Terraform automatically creates an Ansible Inventory file at inventory/hosts.

Kubespray uses Ansible as its substrate for provisioning and orchestration. Once the infrastructure is created, you can run the Ansible playbook to install Kubernetes and all the required dependencies. Execute the below command in the kubespray clone repo, providing the correct path of the AWS EC2 ssh private key in ansible_ssh_private_key_file=<path to EC2 SSH private key file>

We recommend using the latest released Cilium version by passing the variable when running the ansible-playbook command. For example, you could add the following flag to the command below: -e cilium_version=v1.11.0.

If you are interested in configuring your Kubernetes cluster setup, you should consider copying the sample inventory. Then, you can edit the variables in the relevant file in the group_vars directory.

To check if cluster is created successfully, ssh into the bastion host with the user core.

Execute the commands below from the bastion host. If kubectl isn’t installed on the bastion host, you can login to the master node to test the below commands. You may need to copy the private key to the bastion host to access the master node.

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

To validate that Cilium has been properly installed, you can run

Run the following command to validate that your cluster has proper network connectivity:

The connectivity test may fail to deploy due to too many open files in one or more of the pods. If you notice this error, you can increase the inotify resource limits on your host machine (see Pod errors due to “too many open files”).

Congratulations! You have a fully functional Kubernetes cluster with Cilium. 🎉

You can monitor as Cilium and all required components are being installed:

It may take a couple of minutes for all components to come up:

You can deploy the “connectivity-check” to test connectivity between pods. It is recommended to create a separate namespace for this.

Deploy the check with:

It will deploy a series of deployments which will use various connectivity paths to connect to each other. Connectivity paths include with and without service load-balancing and various network policy combinations. The pod name indicates the connectivity variant and the readiness and liveness gate indicates success or failure of the test:

If you deploy the connectivity check to a single node cluster, pods that check multi-node functionalities will remain in the Pending state. This is expected since these pods need at least 2 nodes to be scheduled successfully.

Once done with the test, remove the cilium-test namespace:

---

## Installation using Helm — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/installation/k8s-install-helm/

**Contents:**
- Installation using Helm
- Install Cilium
- Restart unmanaged Pods
- Validate the Installation
- Next Steps

This guide will show you how to install Cilium using Helm. This involves a couple of additional steps compared to the Cilium Quick Installation and requires you to manually select the best datapath and IPAM mode for your particular environment.

Setup Helm repository:

These are the generic instructions on how to install Cilium into any Kubernetes cluster using the default configuration options below. Please see the other tabs for distribution/platform specific instructions which also list the ideal default configuration for particular platforms.

Default Configuration:

Kubernetes must be configured to use CNI (see Network Plugin Requirements)

See System Requirements for more details on the system requirements.

Deploy Cilium release via Helm:

To install Cilium on Google Kubernetes Engine (GKE), perform the following steps:

Default Configuration:

The cluster should be created with the taint node.cilium.io/agent-not-ready=true:NoExecute using --node-taints option. However, there are other options. Please make sure to read and understand the documentation page on taint effects and unmanaged pods.

Extract the Cluster CIDR to enable native-routing:

Deploy Cilium release via Helm:

The NodeInit DaemonSet is required to prepare the GKE nodes as nodes are added to the cluster. The NodeInit DaemonSet will perform the following actions:

Reconfigure kubelet to run in CNI mode

Mount the eBPF filesystem

On AKS, Cilium can be installed either manually by administrators via Bring your own CNI or automatically by AKS via Azure CNI Powered by Cilium. Bring your own CNI offers more flexibility and customization as administrators have full control over the installation, but it does not integrate natively with the Azure network stack and administrators need to handle Cilium upgrades. Azure CNI Powered by Cilium integrates natively with the Azure network stack and upgrades are handled by AKS, but it does not offer as much flexibility and customization as it is controlled by AKS. The following instructions assume Bring your own CNI. For Azure CNI Powered by Cilium, see the external installer guide Installation using Azure CNI Powered by Cilium in AKS for dedicated instructions.

The AKS cluster must be created with --network-plugin none. See the Bring your own CNI documentation for more details about BYOCNI prerequisites / implications.

Make sure that you set a cluster pool IPAM pod CIDR that does not overlap with the default service CIDR of AKS. For example, you can use --helm-set ipam.operator.clusterPoolIPv4PodCIDRList=192.168.0.0/16.

Deploy Cilium release via Helm:

Installing Cilium via helm is supported only for AKS BYOCNI cluster and not for Azure CNI Powered by Cilium clusters.

To install Cilium on Amazon Elastic Kubernetes Service (EKS), perform the following steps:

Default Configuration:

For more information on AWS ENI mode, see AWS ENI.

To chain Cilium on top of the AWS CNI, see AWS VPC CNI plugin.

You can also bring up Cilium in a Single-Region, Multi-Region, or Multi-AZ environment for EKS.

The EKS Managed Nodegroups must be properly tainted to ensure applications pods are properly managed by Cilium:

managedNodeGroups should be tainted with node.cilium.io/agent-not-ready=true:NoExecute to ensure application pods will only be scheduled once Cilium is ready to manage them. However, there are other options. Please make sure to read and understand the documentation page on taint effects and unmanaged pods.

Below is an example on how to use ClusterConfig file to create the cluster:

The AWS ENI integration of Cilium is currently only enabled for IPv4. If you want to use IPv6, use a datapath/IPAM mode other than ENI.

Patch VPC CNI (aws-node DaemonSet)

Cilium will manage ENIs instead of VPC CNI, so the aws-node DaemonSet has to be patched to prevent conflict behavior.

Deploy Cilium release via Helm:

This helm command sets eni.enabled=true and routingMode=native, meaning that Cilium will allocate a fully-routable AWS ENI IP address for each pod, similar to the behavior of the Amazon VPC CNI plugin.

This mode depends on a set of Required Privileges from the EC2 API.

Cilium can alternatively run in EKS using an overlay mode that gives pods non-VPC-routable IPs. This allows running more pods per Kubernetes worker node than the ENI limit but includes the following caveats:

Pod connectivity to resources outside the cluster (e.g., VMs in the VPC or AWS managed services) is masqueraded (i.e., SNAT) by Cilium to use the VPC IP address of the Kubernetes worker node.

The EKS API Server is unable to route packets to the overlay network. This implies that any webhook which needs to be accessed must be host networked or exposed through a service or ingress.

To set up Cilium overlay mode, follow the steps below:

Excluding the lines for eni.enabled=true, ipam.mode=eni and routingMode=native from the helm command will configure Cilium to use overlay routing mode (which is the helm default).

Flush iptables rules added by VPC CNI

To install Cilium on OpenShift, perform the following steps:

Default Configuration:

Cilium is a Certified OpenShift CNI Plugin and is best installed when an OpenShift cluster is created using the OpenShift installer. Please refer to Installation on OpenShift OKD for more information.

To install Cilium top of a standalone Rancher Kubernetes Engine 1 (RKE1) or Rancher Kubernetes Engine 2 (RKE2) cluster, follow the installation instructions provided in the dedicated Installation using Rancher Kubernetes Engine guide.

If your RKE1/2 cluster is managed by Rancher (non-standalone), follow the Installation using Rancher guide instead.

To install Cilium on k3s, perform the following steps:

Default Configuration:

Install your k3s cluster as you normally would but making sure to disable support for the default CNI plugin and the built-in network policy enforcer so you can install Cilium on top:

For the Cilium CLI to access the cluster in successive steps you will need to use the kubeconfig file stored at /etc/rancher/k3s/k3s.yaml by setting the KUBECONFIG environment variable:

Configure Rancher Desktop:

To install Cilium on Rancher Desktop, perform the following steps:

Configuring Rancher Desktop is done using a YAML configuration file. This step is necessary in order to disable the default CNI and replace it with Cilium.

Next you need to start Rancher Desktop with containerd and create a override.yaml:

After the file is created move it into your Rancher Desktop’s lima/_config directory:

Finally, open the Rancher Desktop UI and go to the Troubleshooting panel and click “Reset Kubernetes”.

After a few minutes Rancher Desktop will start back up prepared for installing Cilium.

To install Cilium on Talos Linux, perform the following steps.

Prerequisites / Limitations

Cilium’s Talos Linux support is only tested with Talos versions >=1.5.0.

As Talos does not allow loading Kernel modules by Kubernetes workloads, SYS_MODULE needs to be dropped from the Cilium default capability list.

Talos Linux’s Forwarding kube-dns to Host DNS (enabled by default since Talos 1.8+) doesn’t work together with Cilium’s eBPF Host-Routing. To make it work, you must set bpf.hostLegacyRouting to true as DNS won’t work otherwise.

The official Talos Linux documentation already covers many different Cilium deployment options inside their Deploying Cilium CNI guide. Thus, this guide will only focus on the most recommended deployment option, from a Cilium perspective:

Deployment via official Cilium Helm chart

Cilium Kube-Proxy replacement enabled

Reuse the cgroupv2 mount that Talos already provides

Kubernetes Host Scope IPAM mode as Talos, by default, assigns PodCIDRs to v1.Node resources

Configure Talos Linux

Before installing Cilium, there are two Talos Linux Kubernetes configurations that need to be adjusted:

Ensuring no other CNI is deployed via cluster.network.cni.name: none

Disabling Kube-Proxy deployment via cluster.proxy.disabled: true

Prepare a patch.yaml file:

Next, generate the configuration files for the Talos cluster by using the talosctl gen config command:

To run Cilium with Kube-Proxy replacement enabled, it’s required to configure k8sServiceHost and k8sServicePort, and point them to the Kubernetes API. Luckily, Talos Linux provides KubePrism which allows it to access the Kubernetes API in a convenient way, which solely relies on host networking without using an external loadbalancer. This KubePrism endpoint can be accessed from every Talos Linux node on localhost:7445.

To install Cilium on ACK (Alibaba Cloud Container Service for Kubernetes), perform the following steps:

Disable ACK CNI (ACK Only):

If you are running an ACK cluster, you should delete the ACK CNI.

Cilium will manage ENIs instead of the ACK CNI, so any running DaemonSet from the list below has to be deleted to prevent conflicts.

If you are using ACK with Flannel (DaemonSet kube-flannel-ds), the Cloud Controller Manager (CCM) will create a route (Pod CIDR) in VPC. If your cluster is a Managed Kubernetes you cannot disable this behavior. Please consider creating a new cluster.

The next step is to remove CRD below created by terway* CNI

Create AlibabaCloud Secrets:

Before installing Cilium, a new Kubernetes Secret with the AlibabaCloud Tokens needs to be added to your Kubernetes cluster. This Secret will allow Cilium to gather information from the AlibabaCloud API which is needed to implement ToGroups policies.

AlibabaCloud Access Keys:

To create a new access token the following guide can be used. These keys need to have certain RAM Permissions:

As soon as you have the access tokens, the following secret needs to be added, with each empty string replaced by the associated value as a base64-encoded string:

The base64 command line utility can be used to generate each value, for example:

This secret stores the AlibabaCloud credentials, which will be used to connect to the AlibabaCloud API.

Install Cilium release via Helm:

You must ensure that the security groups associated with the ENIs (eth1, eth2, …) allow for egress traffic to go outside of the VPC. By default, the security groups for pod ENIs are derived from the primary ENI (eth0).

If you’d like to learn more about Cilium Helm values, check out eCHO episode 117: A Tour of the Cilium Helm Values.

If you did not create a cluster with the nodes tainted with the taint node.cilium.io/agent-not-ready, then unmanaged pods need to be restarted manually. Restart all already running pods which are not running in host-networking mode to ensure that Cilium starts managing them. This is required to ensure that all pods which have been running before Cilium was deployed have network connectivity provided by Cilium and NetworkPolicy applies to them:

This may error out on macOS due to -r being unsupported by xargs. In this case you can safely run this command without -r with the symptom that this will hang if there are no pods to restart. You can stop this with ctrl-c.

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

To validate that Cilium has been properly installed, you can run

Run the following command to validate that your cluster has proper network connectivity:

The connectivity test may fail to deploy due to too many open files in one or more of the pods. If you notice this error, you can increase the inotify resource limits on your host machine (see Pod errors due to “too many open files”).

Congratulations! You have a fully functional Kubernetes cluster with Cilium. 🎉

You can monitor as Cilium and all required components are being installed:

It may take a couple of minutes for all components to come up:

You can deploy the “connectivity-check” to test connectivity between pods. It is recommended to create a separate namespace for this.

Deploy the check with:

It will deploy a series of deployments which will use various connectivity paths to connect to each other. Connectivity paths include with and without service load-balancing and various network policy combinations. The pod name indicates the connectivity variant and the readiness and liveness gate indicates success or failure of the test:

If you deploy the connectivity check to a single node cluster, pods that check multi-node functionalities will remain in the Pending state. This is expected since these pods need at least 2 nodes to be scheduled successfully.

Once done with the test, remove the cilium-test namespace:

Setting up Hubble Observability

Inspecting Network Flows with the CLI

Service Map & Hubble UI

Identity-Aware and HTTP-Aware Policy Enforcement

Setting up Cluster Mesh

---

## Installation Using Rancher Desktop — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/installation/rancher-desktop/

**Contents:**
- Installation Using Rancher Desktop
- Configure Rancher Desktop
- Install Cilium
- Validate the Installation
- Next Steps

This guide walks you through installation of Cilium on Rancher Desktop, an open-source desktop application for Mac, Windows and Linux.

Configuring Rancher Desktop is done using a YAML configuration file. This step is necessary in order to disable the default CNI and replace it with Cilium.

Next you need to start Rancher Desktop with containerd and create a override.yaml:

After the file is created move it into your Rancher Desktop’s lima/_config directory:

Finally, open the Rancher Desktop UI and go to the Troubleshooting panel and click “Reset Kubernetes”.

After a few minutes Rancher Desktop will start back up prepared for installing Cilium.

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

Install Cilium by running:

To validate that Cilium has been properly installed, you can run

Run the following command to validate that your cluster has proper network connectivity:

The connectivity test may fail to deploy due to too many open files in one or more of the pods. If you notice this error, you can increase the inotify resource limits on your host machine (see Pod errors due to “too many open files”).

Congratulations! You have a fully functional Kubernetes cluster with Cilium. 🎉

Setting up Hubble Observability

Inspecting Network Flows with the CLI

Service Map & Hubble UI

Identity-Aware and HTTP-Aware Policy Enforcement

Setting up Cluster Mesh

---

## Portmap (HostPort) — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/installation/cni-chaining-portmap/

**Contents:**
- Portmap (HostPort)
- Deploy Cilium with the portmap plugin enabled
- Restart existing pods

Starting from Cilium 1.8, the Kubernetes HostPort feature is supported natively through Cilium’s eBPF-based kube-proxy replacement. CNI chaining is therefore not needed anymore. For more information, see section Container HostPort Support.

However, for the case where Cilium is deployed as kubeProxyReplacement=false, the HostPort feature can then be enabled via CNI chaining with the portmap plugin which implements HostPort. This guide documents how to enable the latter for the chaining case.

For more general information about the Kubernetes HostPort feature, check out the upstream documentation: Kubernetes hostPort-CNI plugin documentation.

Before using HostPort, read the Kubernetes Configuration Best Practices to understand the implications of this feature.

Install the portmap binaries. Some Kubernetes distributions will do this for you, in which case you don’t need to do anything. However, if portmap is not available on your worker nodes, you must install it into /opt/cni/bin/. You can find binaries from the CNI project releases page.

Setup Helm repository:

Deploy Cilium release via Helm:

You can combine the cni.chainingMode=portmap option with any of the other installation guides.

As Cilium is deployed as a DaemonSet, it will write a new CNI configuration. The new configuration now enables HostPort. Any new pod scheduled is now able to make use of the HostPort functionality.

The new CNI chaining configuration will not apply to any pod that is already running the cluster. Existing pods will be reachable and Cilium will load-balance to them but policy enforcement will not apply to them and load-balancing is not performed for traffic originating from existing pods. You must restart these pods in order to invoke the chaining configuration on them.

---

## Installation with K8s distributions — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/installation/k8s-toc/

**Contents:**
- Installation with K8s distributions

---

## Installation Using Kind — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/installation/kind/

**Contents:**
- Installation Using Kind
- Install Dependencies
- Configure kind
- Create a cluster
- Install Cilium
- Validate the Installation
- Next Steps
- Attaching a Debugger
- Troubleshooting
  - Unable to contact k8s api-server

This guide uses kind to demonstrate deployment and operation of Cilium in a multi-node Kubernetes cluster running locally on Docker.

Install docker stable as described in Install Docker Engine

Install kubectl version >= v1.14.0 as described in the Kubernetes Docs

Install helm >= v3.13.0 per Helm documentation: Installing Helm

Install kind >= v0.7.0 per kind documentation: Installation and Usage

Configuring kind cluster creation is done using a YAML configuration file. This step is necessary in order to disable the default CNI and replace it with Cilium.

Create a kind-config.yaml file based on the following template. It will create a cluster with 3 worker nodes and 1 control-plane node.

By default, the latest version of Kubernetes from when the kind release was created is used.

To change the version of Kubernetes being run, image has to be defined for each node. See the Node Configuration documentation for more information.

By default, kind uses the following pod and service subnets:

If any of these subnets conflicts with your local network address range, update the networking section of the kind configuration file to specify different subnets that do not conflict or you risk having connectivity issues when deploying Cilium. For example:

To create a cluster with the configuration defined above, pass the kind-config.yaml you created with the --config flag of kind.

After a couple of seconds or minutes, a 4 nodes cluster should be created.

A new kubectl context (kind-kind) should be added to KUBECONFIG or, if unset, to ${HOME}/.kube/config:

The cluster nodes will remain in state NotReady until Cilium is deployed. This behavior is expected.

Setup Helm repository:

Preload the cilium image into each worker node in the kind cluster:

Then, install Cilium release via Helm:

To enable Cilium’s Socket LB (Kubernetes Without kube-proxy), cgroup v2 needs to be enabled, and Kind nodes need to run in separate cgroup namespaces, and these namespaces need to be different from the cgroup namespace of the underlying host so that Cilium can attach BPF programs at the right cgroup hierarchy. To verify this, run the following commands, and ensure that the cgroup values are different:

One way to enable cgroup v2 is to set the kernel parameter systemd.unified_cgroup_hierarchy=1. To enable cgroup namespaces, a container runtime needs to configured accordingly. For example in Docker, dockerd’s --default-cgroupns-mode has to be set to private.

Another requirement for the Socket LB on Kind to properly function is that either cgroup v1 controllers net_cls and net_prio are disabled (or cgroup v1 altogether is disabled e.g., by setting the kernel parameter cgroup_no_v1="all"), or the host kernel should be 5.14 or more recent to include this fix.

See the Pull Request for more details.

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

To validate that Cilium has been properly installed, you can run

Run the following command to validate that your cluster has proper network connectivity:

The connectivity test may fail to deploy due to too many open files in one or more of the pods. If you notice this error, you can increase the inotify resource limits on your host machine (see Pod errors due to “too many open files”).

Congratulations! You have a fully functional Kubernetes cluster with Cilium. 🎉

You can monitor as Cilium and all required components are being installed:

It may take a couple of minutes for all components to come up:

You can deploy the “connectivity-check” to test connectivity between pods. It is recommended to create a separate namespace for this.

Deploy the check with:

It will deploy a series of deployments which will use various connectivity paths to connect to each other. Connectivity paths include with and without service load-balancing and various network policy combinations. The pod name indicates the connectivity variant and the readiness and liveness gate indicates success or failure of the test:

If you deploy the connectivity check to a single node cluster, pods that check multi-node functionalities will remain in the Pending state. This is expected since these pods need at least 2 nodes to be scheduled successfully.

Once done with the test, remove the cilium-test namespace:

Setting up Hubble Observability

Inspecting Network Flows with the CLI

Service Map & Hubble UI

Identity-Aware and HTTP-Aware Policy Enforcement

Setting up Cluster Mesh

Cilium’s Kind configuration enables access to Delve debug server instances running in the agent and operator Pods by default. See Debugging to learn how to use it.

In the Cilium agent logs you will see:

As Kind is running nodes as containers in Docker, they’re sharing your host machines’ kernel. If the socket LB wasn’t disabled, the eBPF programs attached by Cilium may be out of date and no longer routing api-server requests to the current kind-control-plane container.

Recreating the kind cluster and using the helm command Install Cilium will detach the inaccurate eBPF programs.

Check if Cilium agent pods are crashing with following logs. This may indicate that you are deploying a kind cluster in an environment where Cilium is already running (for example, in the Cilium development VM). This can also happen if you have other overlapping BPF cgroup type programs attached to the parent cgroup hierarchy of the kind container nodes. In such cases, either tear down Cilium, or manually detach the overlapping BPF cgroup programs running in the parent cgroup hierarchy by following the bpftool documentation. For more information, see the Pull Request.

With Kind we can simulate Cluster Mesh in a sandbox too.

This time we need to create (2) config.yaml, one for each kubernetes cluster. We will explicitly configure their pod-network-cidr and service-cidr to not overlap.

Example kind-cluster1.yaml:

Example kind-cluster2.yaml:

We can now create the respective clusters:

We can deploy Cilium, and complete setup by following the Cluster Mesh guide with Setting up Cluster Mesh. For Kind, we’ll want to deploy the NodePort service into the kube-system namespace.

---

## Installation k0s Using k0sctl — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/installation/k0s/

**Contents:**
- Installation k0s Using k0sctl
- Install a Master Node
- Configure Cluster Access
- Install Cilium
- Validate the Installation
- Next Steps

This guide walks you through installation of Cilium on k0s, an open source, all-inclusive Kubernetes distribution, which is configured with all of the features needed to build a Kubernetes cluster.

Cilium is presently supported on amd64 and arm64 architectures.

Ensure you have the k0sctl binary installed locally.

How to do this is out of the scope of this guide, please refer to your favorite virtualization tool. After deploying the VMs, export their IP addresses to environment variables (see example below). These will be used in a later step.

Prepare the yaml configuration file k0sctl will use:

Next step is editing k0s-myk0scluster-config.yaml:

Finally apply the config file:

If running Cilium in Kubernetes Without kube-proxy mode disable kube-proxy in the k0s config file

For the Cilium CLI to access the cluster in successive steps you will need to generate the kubeconfig file, store it in ~/.kube/k0s-mycluster.config and setting the KUBECONFIG environment variable:

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

Install Cilium by running:

To validate that Cilium has been properly installed, you can run

Run the following command to validate that your cluster has proper network connectivity:

The connectivity test may fail to deploy due to too many open files in one or more of the pods. If you notice this error, you can increase the inotify resource limits on your host machine (see Pod errors due to “too many open files”).

Congratulations! You have a fully functional Kubernetes cluster with Cilium. 🎉

Setting up Hubble Observability

Inspecting Network Flows with the CLI

Service Map & Hubble UI

Identity-Aware and HTTP-Aware Policy Enforcement

Setting up Cluster Mesh

---

## Installation using Kops — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/installation/k8s-install-kops/

**Contents:**
- Installation using Kops
- Prerequisites
- Installing kops
- Setting up IAM Group and User
- Cilium Prerequisites
- Creating a Cluster
- Validate the Installation
- Deleting a Cluster
- Further reading on using Cilium with Kops
- Appendix: Details of kops flags used in cluster creation

As of kops 1.9 release, Cilium can be plugged into kops-deployed clusters as the CNI plugin. This guide provides steps to create a Kubernetes cluster on AWS using kops and Cilium as the CNI plugin. Note, the kops deployment will automate several deployment features in AWS by default, including AutoScaling, Volumes, VPCs, etc.

Kops offers several out-of-the-box configurations of Cilium including Kubernetes Without kube-proxy, AWS ENI, and dedicated etcd cluster for Cilium. This guide will just go through a basic setup.

aws account with permissions: * AmazonEC2FullAccess * AmazonRoute53FullAccess * AmazonS3FullAccess * IAMFullAccess * AmazonVPCFullAccess

Assuming you have all the prerequisites, run the following commands to create the kops user and group:

kops requires the creation of a dedicated S3 bucket in order to store the state and representation of the cluster. You will need to change the bucket name and provide your unique bucket name (for example a reverse of FQDN added with short description of the cluster). Also make sure to use the region where you will be deploying the cluster.

The above steps are sufficient for getting a working cluster installed. Please consult kops aws documentation for more detailed setup instructions.

Ensure the System Requirements are met, particularly the Linux kernel and key-value store versions.

The default AMI satisfies the minimum kernel version required by Cilium, which is what we will use in this guide.

Note that you will need to specify the --master-zones and --zones for creating the master and worker nodes. The number of master zones should be * odd (1, 3, …) for HA. For simplicity, you can just use 1 region.

To keep things simple when following this guide, we will use a gossip-based cluster. This means you do not have to create a hosted zone upfront. cluster NAME variable must end with k8s.local to use the gossip protocol. If creating multiple clusters using the same kops user, then make the cluster name unique by adding a prefix such as com-company-emailid-.

You may be prompted to create a ssh public-private key pair.

(Please see Deleting a Cluster)

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

To validate that Cilium has been properly installed, you can run

Run the following command to validate that your cluster has proper network connectivity:

The connectivity test may fail to deploy due to too many open files in one or more of the pods. If you notice this error, you can increase the inotify resource limits on your host machine (see Pod errors due to “too many open files”).

Congratulations! You have a fully functional Kubernetes cluster with Cilium. 🎉

You can monitor as Cilium and all required components are being installed:

It may take a couple of minutes for all components to come up:

You can deploy the “connectivity-check” to test connectivity between pods. It is recommended to create a separate namespace for this.

Deploy the check with:

It will deploy a series of deployments which will use various connectivity paths to connect to each other. Connectivity paths include with and without service load-balancing and various network policy combinations. The pod name indicates the connectivity variant and the readiness and liveness gate indicates success or failure of the test:

If you deploy the connectivity check to a single node cluster, pods that check multi-node functionalities will remain in the Pending state. This is expected since these pods need at least 2 nodes to be scheduled successfully.

Once done with the test, remove the cilium-test namespace:

To undo the dependencies and other deployment features in AWS from the kops cluster creation, use kops to destroy a cluster immediately with the parameter --yes:

See the kops networking documentation for more information on the configuration options kops offers.

See the kops cluster spec documentation for a comprehensive list of all the options

The following section explains all the flags used in create cluster command.

--state=${KOPS_STATE_STORE} : KOPS uses an S3 bucket to store the state of your cluster and representation of your cluster

--node-count 3 : No. of worker nodes in the kubernetes cluster.

--topology private : Cluster will be created with private topology, what that means is all masters/nodes will be launched in a private subnet in the VPC

--master-zones eu-west-1a,eu-west-1b,eu-west-1c : The 3 zones ensure the HA of master nodes, each belonging in a different Availability zones.

--zones eu-west-1a,eu-west-1b,eu-west-1c : Zones where the worker nodes will be deployed

--networking cilium : Networking CNI plugin to be used - cilium. You can also use cilium-etcd, which will use a dedicated etcd cluster as key/value store instead of CRDs.

--cloud-labels "Team=Dev,Owner=Admin" : Labels for your cluster that will be applied to your instances

${NAME} : Name of the cluster. Make sure the name ends with k8s.local for a gossip based cluster

---

## Installation using kubeadm — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/installation/k8s-install-kubeadm/

**Contents:**
- Installation using kubeadm
- Create the cluster
- Deploy Cilium
- Validate the Installation
- Next Steps

This guide describes deploying Cilium on a Kubernetes cluster created with kubeadm.

For installing kubeadm on your system, please refer to the official kubeadm documentation The official documentation also describes additional options of kubeadm which are not mentioned here.

If you are interested in using Cilium’s kube-proxy replacement, please follow the Kubernetes Without kube-proxy guide and skip this one.

Initialize the control plane via executing on it:

If you want to use Cilium’s kube-proxy replacement, kubeadm needs to skip the kube-proxy deployment phase, so it has to be executed with the --skip-phases=addon/kube-proxy option:

For more information please refer to the Kubernetes Without kube-proxy guide.

Afterwards, join worker nodes by specifying the control-plane node IP address and the token returned by kubeadm init:

Setup Helm repository:

Deploy Cilium release via Helm:

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

To validate that Cilium has been properly installed, you can run

Run the following command to validate that your cluster has proper network connectivity:

The connectivity test may fail to deploy due to too many open files in one or more of the pods. If you notice this error, you can increase the inotify resource limits on your host machine (see Pod errors due to “too many open files”).

Congratulations! You have a fully functional Kubernetes cluster with Cilium. 🎉

You can monitor as Cilium and all required components are being installed:

It may take a couple of minutes for all components to come up:

You can deploy the “connectivity-check” to test connectivity between pods. It is recommended to create a separate namespace for this.

Deploy the check with:

It will deploy a series of deployments which will use various connectivity paths to connect to each other. Connectivity paths include with and without service load-balancing and various network policy combinations. The pod name indicates the connectivity variant and the readiness and liveness gate indicates success or failure of the test:

If you deploy the connectivity check to a single node cluster, pods that check multi-node functionalities will remain in the Pending state. This is expected since these pods need at least 2 nodes to be scheduled successfully.

Once done with the test, remove the cilium-test namespace:

Setting up Hubble Observability

Inspecting Network Flows with the CLI

Service Map & Hubble UI

Identity-Aware and HTTP-Aware Policy Enforcement

Setting up Cluster Mesh

---

## Calico — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/installation/cni-chaining-calico/

**Contents:**
- Calico
- Create a CNI configuration
- Deploy Cilium with the portmap plugin enabled
- Validate the Installation
- Next Steps

This guide instructs how to install Cilium in chaining configuration on top of Calico.

Some advanced Cilium features may be limited when chaining with other CNI plugins, such as:

Layer 7 Policy (see GitHub issue 12454)

IPsec Transparent Encryption (see GitHub issue 15596)

Create a chaining.yaml file based on the following template to specify the desired CNI chaining configuration:

Deploy the ConfigMap:

Setup Helm repository:

Deploy Cilium release via Helm:

The new CNI chaining configuration will not apply to any pod that is already running the cluster. Existing pods will be reachable and Cilium will load-balance to them but policy enforcement will not apply to them and load-balancing is not performed for traffic originating from existing pods.

You must restart these pods in order to invoke the chaining configuration on them.

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

To validate that Cilium has been properly installed, you can run

Run the following command to validate that your cluster has proper network connectivity:

The connectivity test may fail to deploy due to too many open files in one or more of the pods. If you notice this error, you can increase the inotify resource limits on your host machine (see Pod errors due to “too many open files”).

Congratulations! You have a fully functional Kubernetes cluster with Cilium. 🎉

You can monitor as Cilium and all required components are being installed:

It may take a couple of minutes for all components to come up:

You can deploy the “connectivity-check” to test connectivity between pods. It is recommended to create a separate namespace for this.

Deploy the check with:

It will deploy a series of deployments which will use various connectivity paths to connect to each other. Connectivity paths include with and without service load-balancing and various network policy combinations. The pod name indicates the connectivity variant and the readiness and liveness gate indicates success or failure of the test:

If you deploy the connectivity check to a single node cluster, pods that check multi-node functionalities will remain in the Pending state. This is expected since these pods need at least 2 nodes to be scheduled successfully.

Once done with the test, remove the cilium-test namespace:

Setting up Hubble Observability

Inspecting Network Flows with the CLI

Service Map & Hubble UI

Identity-Aware and HTTP-Aware Policy Enforcement

Setting up Cluster Mesh

---

## Installation using Rancher — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/installation/k8s-install-rancher-existing-nodes/

**Contents:**
- Installation using Rancher
- Introduction
- Prerequisites
- Create a New Cluster
- Optional: Add Cilium to Rancher Registries

If you’re not using the Rancher Management Console/UI to install your clusters, head over to the installation guides for standalone RKE clusters.

Rancher comes with official support for Cilium. For most Rancher users, that’s the recommended way to use Cilium on Rancher-managed clusters.

However, as Rancher is using a custom rke2-cilium Helm chart with independent release cycles, Cilium power-users might want to use an out-of-band Cilium installation instead, based on the official Cilium Helm chart, on top of their Rancher-managed RKE1/RKE2 downstream clusters. This guide explains how to achieve this.

This guide only shows a step-by-step guide for Rancher-managed (non-standalone) RKE2 clusters.

However, for a legacy RKE1 cluster, it’s even easier. You also need to edit the cluster YAML and change network.cni to none as described in the RKE 1 standalone guide, but there’s no need to copy over a Control Plane node local KubeConfig manually. Luckily, Rancher allows access to RKE1 clusters in Updating state, which are not ready yet. Hence, there’s no chicken-egg issue to resolve.

Fully functioning Rancher Version 2.x instance

At least one empty Linux VM, to be used as initial downstream “Custom Cluster” (Control Plane) node

DNS record pointing to the Kubernetes API of the downstream “Custom Cluster” Control Plane node(s) or L4 load-balancer

In Rancher UI, navigate to the Cluster Management page. In the top right, click on the Create button to create a new cluster.

On the Cluster creation page select to create a new Custom cluster:

When the Create Custom page opens, provide at least a name for the cluster. Go through the other configuration options and configure the ones that are relevant for your setup.

Next to the Cluster Options section click the box to Edit as YAML. The configuration for the cluster will open up in an editor in the window.

Within the Cluster CustomResource (provisioning.cattle.io/v1), the relevant parts to change are spec.rkeConfig.machineGlobalConfig.cni, spec.rkeConfig.machineGlobalConfig.tls-san, and optionally spec.rkeConfig.chartValues.rke2-calico and spec.rkeConfig.machineGlobalConfig.disable-kube-proxy:

It’s required to add a DNS record, pointing to the Control Plane node IP(s) or an L4 load-balancer in front of them, under spec.rkeConfig.machineGlobalConfig.tls-san, as that’s required to resolve a chicken-egg issue further down the line.

Ensure that spec.rkeConfig.machineGlobalConfig.cni is set to none and spec.rkeConfig.machineGlobalConfig.tls-san lists the mentioned DNS record:

Optionally, if spec.rkeConfig.chartValues.rke2-calico is not empty, remove the full object as you won’t deploy Rancher’s default CNI. At the same time, change spec.rkeConfig.machineGlobalConfig.disable-kube-proxy to true in case you want to run Cilium without Kube-Proxy.

Make any additional changes to the configuration that are appropriate for your environment. When you are ready, click Create and Rancher will create the cluster.

The cluster will stay in Updating state until you add nodes. Click on the cluster. In the Registration tab you should see the generated Registation command you need to run on the downstream cluster nodes.

Do not forget to select the correct node roles. Rancher comes with the default to deploy all three roles (etcd, Control Plane, and Worker), which is often not what you want for multi-node clusters.

A few seconds after you added at least a single node, you should see the new node(s) in the Machines tab. The machine will be stuck in Reconciling state and won’t become Active:

That’s expected as there’s no CNI running on this cluster yet. Unfortunately, this also means critical pods like rke2-coredns-rke2-coredns-* and cattle-cluster-agent-* are stuck in PENDING state. Hence, the downstream cluster is not yet able to register itself on Rancher.

As a next step, you need to resolve this chicken-egg issue by directly accessing the downstream cluster’s Kubernetes API, without going via Rancher. Rancher will not allow access to this downstream cluster, as it’s still in Updating state. That’s why you can’t use the downstream cluster’s KubeConfig provided by the Rancher management console/UI.

Copy /etc/rancher/rke2/rke2.yaml from the first downstream cluster Control Plane node to your jump/bastion host where you have helm installed and can access the Cilium Helm charts.

Search and replace 127.0.0.1 (clusters[0].cluster.server) with the already mentioned DNS record pointing to the Control Plane / L4 load-balancer IP(s).

Check if you can access the Kubernetes API:

If successful, you can now install Cilium via Helm CLI:

After a few minutes, you should see that the node changed to the Ready status:

Back in the Rancher UI, you should see that the cluster changed to the healthy Active status:

That’s it. You can now normally work with this cluster as if you installed the CNI the default Rancher way. Additional nodes can now be added straightaway and the “local Control Plane RKE2 KubeConfig” workaround is not required anymore.

One small, optional convenience item would be to add the Cilium Helm repository to Rancher so that, in the future, Cilium can easily be upgraded via Rancher UI.

You have two options available:

Option 1: Navigate to Cluster Management -> Advanced -> Repositories and click the Create button:

Option 2: Alternatively, you can also just add the Cilium Helm repository on a single cluster by navigating to <your-cluster> -> Apps -> Repositories:

For either option, in the window that opens, add the official Cilium Helm chart repository (https://helm.cilium.io) to the Rancher repository list:

Once added, you should see the Cilium repository in the repositories list:

If you now head to <your-cluster> -> Apps -> Installed Apps, you should see the cilium app. Ensure All Namespaces or Project: System -> kube-system is selected at the top of the page.

Since you added the Cilium repository, you will now see a small hint on this app entry when there’s a new Cilium version released. You can then upgrade directly via Rancher UI.

---
