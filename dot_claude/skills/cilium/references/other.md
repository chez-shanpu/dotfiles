# Cilium - Other

**Pages:** 45

---

## Limiting Identity-Relevant Labels — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/operations/performance/scalability/identity-relevant-labels/

**Contents:**
- Limiting Identity-Relevant Labels
- Configuring Identity-Relevant Labels
- Including Labels
- Excluding Labels

We recommend that operators with larger environments limit the set of identity-relevant labels to avoid frequent creation of new security identities. Many Kubernetes labels are not useful for policy enforcement or visibility. A few good examples of such labels include timestamps or hashes. These labels, when included in evaluation, cause Cilium to generate a unique identity for each pod instead of a single identity for all of the pods that comprise a service or application.

By default, Cilium considers all labels to be relevant for identities, with the following exceptions:

Ignore all io.kubernetes labels

Ignore all other kubernetes.io labels

!statefulset\.kubernetes\.io/pod-name

Ignore statefulset.kubernetes.io/pod-name label

!apps\.kubernetes\.io/pod-index

Ignore apps.kubernetes.io/pod-index label

!batch\.kubernetes\.io/job-completion-index

Ignore batch.kubernetes.io/job-completion-index label

!batch\.kubernetes\.io/controller-uid

Ignore batch.kubernetes.io/controller-uid label

!beta\.kubernetes\.io

Ignore all beta.kubernetes.io labels

Ignore all k8s.io labels

!pod-template-generation

Ignore all pod-template-generation labels

Ignore all pod-template-hash labels

!controller-revision-hash

Ignore all controller-revision-hash labels

Ignore all annotation labels

Ignore all controller-uid labels

Ignore all etcd_node labels

The above label patterns are all exclusive label patterns, that is to say they define which label keys should be ignored. These are identified by the presence of the ! character.

Label configurations that do not contain the ! character are inclusive label patterns. Once at least one inclusive label pattern is added, only labels that match the inclusive label configuration may be considered relevant for identities. Additionally, when at least one inclusive label pattern is configured, the following inclusive label patterns are automatically added to the configuration:

Include all reserved: labels

io\.kubernetes\.pod\.namespace

Include all io.kubernetes.pod.namespace labels

io\.cilium\.k8s\.namespace\.labels

Include all io.cilium.k8s.namespace.labels labels

io\.cilium\.k8s\.policy\.cluster

Include all io.cilium.k8s.policy.cluster labels

io\.cilium\.k8s\.policy\.serviceaccount

Include all io.cilium.k8s.policy.serviceaccount labels

Include all app.kubernetes.io labels

To limit the labels used for evaluating Cilium identities, edit the Cilium ConfigMap object using kubectl edit cm -n kube-system cilium-config and insert a line to define the label patterns to include or exclude. Alternatively, this attribute can also be set via helm option --set labels=<values>.

The double backslash in \\. is required to escape the slash in the YAML string so that the regular expression contains \..

Label patterns are regular expressions that are implicitly anchored at the start of the label. For example example\.com will match labels that start with example.com, whereas .*example\.com will match labels that contain example.com anywhere. Be sure to escape periods in domain names to avoid the pattern matching too broadly and therefore including or excluding too many labels.

The label patterns are using regular expressions. Therefore, using kind$ or ^kind$ can exactly match the label key kind, not just the prefix.

Upon defining a custom list of label patterns in the ConfigMap, Cilium adds the provided list of label patterns to the default list of label patterns. After saving the ConfigMap, if the Operator is managing identities (Identity Management Mode), restart both the Cilium Operators and Agents to pickup the new label pattern setting. If the Agent is managing identities, restart the Cilium Agents to pickup the new label pattern.

Configuring Cilium with label patterns via labels Helm value does not override the default set of label patterns. That is to say, you can consider this configuration to append a list of label configurations to the defaults listed above.

If you wish to configure this setting in a declarative way including the exact set of label prefixes to be considered for determining workload security identities, you should instead configure the label-prefix-file configuration flag.

Existing identities will not change as a result of this new configuration. To apply the new label pattern setting to existing identities, restart the corresponding Cilium pod on the node where the workload is running. Upon restart, new identities will be created. The old identities will be garbage collected by the Cilium Operator once they are no longer used by any Cilium endpoints.

When specifying multiple label patterns to evaluate, provide the list of labels as a space-separated string.

Labels can be defined as a list of labels to include. Only the labels specified and the default inclusive labels will be used to evaluate Cilium identities:

The above configuration would only include the following label keys when evaluating Cilium identities:

io.kubernetes.pod.namespace

io.cilium.k8s.namespace.labels

io.cilium.k8s.policy.cluster

io.cilium.k8s.policy.serviceaccount

Note that io.kubernetes.pod.namespace is already included in default label io.kubernetes.pod.namespace.

Labels with the same prefix as defined in the configuration will also be considered. This lists some examples of label keys that would also be evaluated for Cilium identities:

Because we have $ in label key kind$ and other$. Only label keys using exactly kind and other will be evaluated for Cilium.

When a single inclusive label is added to the filter, all labels not defined in the default list will be excluded. For example, pods running with the security labels team=team-1, env=prod will have the label env=prod ignored as soon Cilium is started with the filter team.

Label patterns can also be specified as a list of exclusions. Exclude labels by placing an exclamation mark after colon separating the prefix and pattern. When defined as a list of exclusions, Cilium will include the set of default labels, but will exclude any matches in the provided list when evaluating Cilium identities:

The provided example would cause Cilium to exclude any of the following label matches:

---

## Software Bill of Materials — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/configuration/sbom/

**Contents:**
- Software Bill of Materials
- Prerequisites
- Download SBOM
- Verify SBOM attestation

A Software Bill of Materials (SBOM) is a complete, formally structured list of components that are required to build a given piece of software. SBOM provides insight into the software supply chain and any potential concerns related to license compliance and security that might exist.

The Cilium SBOM is generated using the syft tool. To learn more about SBOM, see what is an SBOM.

You can download the SBOM in-toto attestation from the supplied Cilium image using the following command:

To verify the SBOM in-toto attestation on the supplied Cilium image, run the following command:

It can be validated that the image was signed using GitHub Actions in the Cilium repository from the Certificate subject and Certificate issuer URL fields of the output.

The in-toto Attestation Framework provides a specification for generating verifiable claims about any aspect of how a piece of software is produced. Consumers or users of software can then validate the origins of the software, and establish trust in its supply chain, using in-toto attestations.

---

## Scalability — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/operations/performance/scalability/

**Contents:**
- Scalability

---

## System Requirements — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/operations/system_requirements/

**Contents:**
- System Requirements
- Summary
- Architecture Support
- Linux Distribution Compatibility & Considerations
  - Flatcar on AWS EKS in ENI mode
  - Ubuntu 22.04 on Raspberry Pi
- Linux Kernel
  - Base Requirements
  - Requirements for Iptables-based Masquerading
  - Requirements for Tunneling and Routing

Before installing Cilium, please ensure that your system meets the minimum requirements below. Most modern Linux distributions already do.

When running Cilium using the container image cilium/cilium, the host system must meet these requirements:

Hosts with either AMD64 or AArch64 architecture

Linux kernel >= 5.10 or equivalent (e.g., 4.18 on RHEL 8.10)

When running Cilium as a native process on your host (i.e. not running the cilium/cilium container image) these additional requirements must be met:

When running Cilium without Kubernetes these additional requirements must be met:

Key-Value store etcd >= 3.1.0

>= 5.10 or >= 4.18 on RHEL 8.10

Key-Value store (etcd)

Cilium images are built for the following platforms:

The following table lists Linux distributions that are known to work well with Cilium. Some distributions require a few initial tweaks. Please make sure to read each distribution’s specific notes below before attempting to run Cilium.

Container-Optimized OS

Tumbleweed, >=Leap 15.4

RedHat Enterprise Linux

The above list is based on feedback by users. If you find an unlisted Linux distribution that works well, please let us know by opening a GitHub issue or by creating a pull request that updates this guide.

Flatcar is known to manipulate network interfaces created and managed by Cilium. When running the official Flatcar image for AWS EKS nodes in ENI mode, this may cause connectivity issues and potentially prevent the Cilium agent from booting. To avoid this, disable DHCP on the ENI interfaces and mark them as unmanaged by adding

to /etc/systemd/network/01-no-dhcp.network and then

Before running Cilium on Ubuntu 22.04 on a Raspberry Pi, please make sure to install the following package:

Cilium leverages and builds on the kernel eBPF functionality as well as various subsystems which integrate with eBPF. Therefore, host systems are required to run a recent Linux kernel to run a Cilium agent. More recent kernels may provide additional eBPF functionality that Cilium will automatically detect and use on agent start. For this version of Cilium, it is recommended to use kernel 5.10 or later (or equivalent such as 4.18 on RHEL 8.10). For a list of features that require newer kernels, see Required Kernel Versions for Advanced Features.

In order for the eBPF feature to be enabled properly, the following kernel configuration options must be enabled. This is typically the case with distribution kernels. When an option can be built as a module or statically linked, either choice is valid.

If you are not using BPF for masquerading (enable-bpf-masquerade=false, the default value), then you will need the following kernel configuration options.

Cilium uses tunneling protocols like VXLAN by default for pod-to-pod communication across nodes, as well as policy routing for various traffic management functionality. The following kernel configuration options are required for proper operation:

L7 proxy redirection currently uses TPROXY iptables actions as well as socket matches. For L7 redirection to work as intended kernel configuration must include the following modules:

When xt_socket kernel module is missing the forwarding of redirected L7 traffic does not work in non-tunneled datapath modes. Since some notable kernels (e.g., COS) are shipping without xt_socket module, Cilium implements a fallback compatibility mode to allow L7 policies and visibility to be used with those kernels. Currently this fallback disables ip_early_demux kernel feature in non-tunneled datapath modes, which may decrease system networking performance. This guarantees HTTP and Kafka redirection works as intended. However, if HTTP or Kafka enforcement policies are never used, this behavior can be turned off by adding the following to the helm configuration command line:

The IPsec Transparent Encryption feature requires a lot of kernel configuration options, most of which to enable the actual encryption. Note that the specific options required depend on the algorithm. The list below corresponds to requirements for GCM-128-AES.

The Bandwidth Manager requires the following kernel configuration option to change the packet scheduling algorithm.

The netkit device mode requires the following kernel configuration option to create netkit devices.

Additional kernel features continues to progress in the Linux community. Some of Cilium’s features are dependent on newer kernel versions and are thus enabled by upgrading to more recent kernel versions as detailed below.

Minimum Kernel Version

Multicast Support in Cilium (Beta) (AMD64)

Multicast Support in Cilium (Beta) (AArch64)

Cilium optionally uses a distributed Key-Value store to manage, synchronize and distribute security identities across all cluster nodes. The following Key-Value stores are currently supported:

Cilium can be used without a Key-Value store when CRD-based state management is used with Kubernetes. This is the default for new Cilium installations. Larger clusters will perform better with a Key-Value store backed identity management instead, see Cilium Quick Installation for more details.

See Key-Value Store for details on how to configure the cilium-agent to use a Key-Value store.

This requirement is only needed if you run cilium-agent natively. If you are using the Cilium container image cilium/cilium, clang+LLVM is included in the container image.

LLVM is the compiler suite that Cilium uses to generate eBPF bytecode programs to be loaded into the Linux kernel. The minimum supported version of LLVM available to cilium-agent should be >=18.1. The version of clang installed must be compiled with the eBPF backend enabled.

See https://releases.llvm.org/ for information on how to download and install LLVM.

If you are running Cilium in an environment that requires firewall rules to enable connectivity, you will have to add the following rules to ensure Cilium works properly.

It is recommended but optional that all nodes running Cilium in a given cluster must be able to ping each other so cilium-health can report and monitor connectivity among nodes. This requires ICMP Type 0/8, Code 0 open among all nodes. TCP 4240 should also be open among all nodes for cilium-health monitoring. Note that it is also an option to only use one of these two methods to enable health monitoring. If the firewall does not permit either of these methods, Cilium will still operate fine but will not be able to provide health information.

For IPsec enabled Cilium deployments, you need to ensure that the firewall allows ESP traffic through. For example, AWS Security Groups doesn’t allow ESP traffic by default.

If you are using WireGuard, you must allow UDP port 51871.

If you are using VXLAN overlay network mode, Cilium uses Linux’s default VXLAN port 8472 over UDP, unless Linux has been configured otherwise. In this case, UDP 8472 must be open among all nodes to enable VXLAN overlay mode. The same applies to Geneve overlay network mode, except the port is UDP 6081.

If you are running in direct routing mode, your network must allow routing of pod IPs.

As an example, if you are running on AWS with VXLAN overlay networking, here is a minimum set of AWS Security Group (SG) rules. It assumes a separation between the SG on the master nodes, master-sg, and the worker nodes, worker-sg. It also assumes etcd is running on the master nodes.

Master Nodes (master-sg) Rules:

Port Range / Protocol

Worker Nodes (worker-sg):

Port Range / Protocol

If you use a shared SG for the masters and workers, you can condense these rules into ingress/egress to self. If you are using Direct Routing mode, you can condense all rules into ingress/egress ANY port/protocol to/from self.

The following ports should also be available on each node:

Port Range / Protocol

cluster health checks (cilium-health)

Mutual Authentication port

Spire Agent health check port (listening on 127.0.0.1 or ::1)

cilium-agent pprof server (listening on 127.0.0.1)

cilium-operator pprof server (listening on 127.0.0.1)

Hubble Relay pprof server (listening on 127.0.0.1)

cilium-envoy health listener (listening on 127.0.0.1)

cilium-agent health status API (listening on 127.0.0.1 and/or ::1)

cilium-agent gops server (listening on 127.0.0.1)

operator gops server (listening on 127.0.0.1)

Hubble Relay gops server (listening on 127.0.0.1)

cilium-envoy Admin API (listening on 127.0.0.1)

cilium-agent Prometheus metrics

cilium-operator Prometheus metrics

cilium-envoy Prometheus metrics

WireGuard encryption tunnel endpoint

Some distributions mount the bpf filesystem automatically. Check if the bpf filesystem is mounted by running the command.

If the eBPF filesystem is not mounted in the host filesystem, Cilium will automatically mount the filesystem.

Mounting this BPF filesystem allows the cilium-agent to persist eBPF resources across restarts of the agent so that the datapath can continue to operate while the agent is subsequently restarted or upgraded.

Optionally it is also possible to mount the eBPF filesystem before Cilium is deployed in the cluster, the following command must be run in the host mount namespace. The command must only be run once during the boot process of the machine.

A portable way to achieve this with persistence is to add the following line to /etc/fstab and then run mount /sys/fs/bpf. This will cause the filesystem to be automatically mounted when the node boots.

If you are using systemd to manage the kubelet, see the section Mounting BPFFS with systemd.

When running in AWS ENI IPAM mode, Cilium will install per-ENI routing tables for each ENI that is used by Cilium for pod IP allocation. These routing tables are added to the host network namespace and must not be otherwise used by the system. The index of those per-ENI routing tables is computed as 10 + <eni-interface-index>. The base offset of 10 is chosen as it is highly unlikely to collide with the main routing table which is between 253-255.

The following privileges are required to run Cilium. When running the standard Kubernetes DaemonSet, the privileges are automatically granted to Cilium.

Cilium interacts with the Linux kernel to install eBPF program which will then perform networking tasks and implement security rules. In order to install eBPF programs system-wide, CAP_SYS_ADMIN privileges are required. These privileges must be granted to cilium-agent.

The quickest way to meet the requirement is to run cilium-agent as root and/or as privileged container.

Cilium requires access to the host networking namespace. For this purpose, the Cilium pod is scheduled to run in the host networking namespace directly.

---

## Monitoring & Metrics — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/observability/metrics/

**Contents:**
- Monitoring & Metrics
- Cilium Metrics
  - Installation
- Hubble Metrics
  - Installation
  - OpenMetrics
- Cluster Mesh API Server Metrics
  - Installation
- Example Prometheus & Grafana Deployment
- Metrics Reference

Cilium and Hubble can both be configured to serve Prometheus metrics. Prometheus is a pluggable metrics collection and storage system and can act as a data source for Grafana, a metrics visualization frontend. Unlike some metrics collectors like statsd, Prometheus requires the collectors to pull metrics from each source.

Cilium and Hubble metrics can be enabled independently of each other.

Cilium metrics provide insights into the state of Cilium itself, namely of the cilium-agent, cilium-envoy, and cilium-operator processes. To run Cilium with Prometheus metrics enabled, deploy it with the prometheus.enabled=true Helm value set.

Cilium metrics are exported under the cilium_ Prometheus namespace. Envoy metrics are exported under the envoy_ Prometheus namespace, of which the Cilium-defined metrics are exported under the envoy_cilium_ namespace. When running and collecting in Kubernetes they will be tagged with a pod name and namespace.

You can enable metrics for cilium-agent (including Envoy) with the Helm value prometheus.enabled=true. cilium-operator metrics are enabled by default, if you want to disable them, set Helm value operator.prometheus.enabled=false.

The ports can be configured via prometheus.port, envoy.prometheus.port, or operator.prometheus.port respectively.

When metrics are enabled, all Cilium components will have the following annotations. They can be used to signal Prometheus whether to scrape metrics:

To collect Envoy metrics the Cilium chart will create a Kubernetes headless service named cilium-agent with the prometheus.io/scrape:'true' annotation set:

This additional headless service in addition to the other Cilium components is needed as each component can only have one Prometheus scrape and port annotation.

Prometheus will pick up the Cilium and Envoy metrics automatically if the following option is set in the scrape_configs section:

While Cilium metrics allow you to monitor the state Cilium itself, Hubble metrics on the other hand allow you to monitor the network behavior of your Cilium-managed Kubernetes pods with respect to connectivity and security.

To deploy Cilium with Hubble metrics enabled, you need to enable Hubble with hubble.enabled=true and provide a set of Hubble metrics you want to enable via hubble.metrics.enabled.

Some of the metrics can also be configured with additional options. See the Hubble exported metrics section for the full list of available metrics and their options.

The port of the Hubble metrics can be configured with the hubble.metrics.port Helm value.

For details on enabling Hubble metrics with TLS see the Hubble Metrics TLS and Authentication section of the documentation.

L7 metrics such as HTTP, are only emitted for pods that enable Layer 7 Protocol Visibility.

When deployed with a non-empty hubble.metrics.enabled Helm value, the Cilium chart will create a Kubernetes headless service named hubble-metrics with the prometheus.io/scrape:'true' annotation set:

Set the following options in the scrape_configs section of Prometheus to have it scrape all Hubble metrics from the endpoints automatically:

Additionally, you can opt-in to OpenMetrics by setting hubble.metrics.enableOpenMetrics=true. Enabling OpenMetrics configures the Hubble metrics endpoint to support exporting metrics in OpenMetrics format when explicitly requested by clients.

Using OpenMetrics supports additional functionality such as Exemplars, which enables associating metrics with traces by embedding trace IDs into the exported metrics.

Prometheus needs to be configured to take advantage of OpenMetrics and will only scrape exemplars when the exemplars storage feature is enabled.

OpenMetrics imposes a few additional requirements on metrics names and labels, so this functionality is currently opt-in, though we believe all of the Hubble metrics conform to the OpenMetrics requirements.

Cluster Mesh API Server metrics provide insights into the state of the clustermesh-apiserver process, the kvstoremesh process (if enabled), and the sidecar etcd instance. Cluster Mesh API Server metrics are exported under the cilium_clustermesh_apiserver_ Prometheus namespace. KVStoreMesh metrics are exported under the cilium_kvstoremesh_ Prometheus namespace. Etcd metrics are exported under the etcd_ Prometheus namespace.

You can enable the metrics for different Cluster Mesh API Server components by setting the following values:

clustermesh-apiserver: clustermesh.apiserver.metrics.enabled=true

kvstoremesh: clustermesh.apiserver.metrics.kvstoremesh.enabled=true

sidecar etcd instance: clustermesh.apiserver.metrics.etcd.enabled=true

You can figure the ports by way of clustermesh.apiserver.metrics.port, clustermesh.apiserver.metrics.kvstoremesh.port and clustermesh.apiserver.metrics.etcd.port respectively.

You can automatically create a Prometheus Operator ServiceMonitor by setting clustermesh.apiserver.metrics.serviceMonitor.enabled=true.

If you don’t have an existing Prometheus and Grafana stack running, you can deploy a stack with:

It will run Prometheus and Grafana in the cilium-monitoring namespace. If you have either enabled Cilium or Hubble metrics, they will automatically be scraped by Prometheus. You can then expose Grafana to access it via your browser.

Open your browser and access http://localhost:3000/

To expose any metrics, invoke cilium-agent with the --prometheus-serve-addr option. This option takes a IP:Port pair but passing an empty IP (e.g. :9962) will bind the server to all available interfaces (there is usually only one in a container).

To customize cilium-agent metrics, configure the --metrics option with "+metric_a -metric_b -metric_c", where +/- means to enable/disable the metric. For example, for really large clusters, users may consider to disable the following two metrics as they generate too much data:

cilium_node_connectivity_status

cilium_node_connectivity_latency_seconds

You can then configure the agent with --metrics="-cilium_node_connectivity_status -cilium_node_connectivity_latency_seconds".

Cilium Feature Metrics are exported under the cilium_feature Prometheus namespace.

The following tables categorize feature metrics into four groups:

Advanced Connectivity and Load Balancing (adv_connect_and_lb)

This category includes features related to advanced networking and load balancing capabilities, such as Bandwidth Manager, BGP, Envoy Proxy, and Cluster Mesh.

Control Plane (controlplane)

These metrics track control plane configurations, including identity allocation modes and IP address management (IPAM).

Metrics in this group monitor datapath configurations, such as Internet protocol modes, chaining modes, and network modes.

Network Policies (network_policies)

This group encompasses metrics related to policy enforcement, including Cilium Network Policies, Host Firewall, DNS policies, and Mutual Auth.

For example, to check if the Bandwidth Manager is enabled on a Cilium agent, observe the metric cilium_feature_adv_connect_and_lb_bandwidth_manager_enabled. All metrics follow the format cilium_feature + group name + metric name. A value of 0 indicates that the feature is disabled, while 1 indicates it is enabled.

For metrics of type “counter”, the agent has processed the associated object (e.g., a network policy) but might not be actively enforcing it. These metrics serve to observe if the object has been received and processed, but not necessarily enforced by the agent.

Possible Label Values

bandwidth_manager_enabled

Bandwidth Manager enabled on the agent

BGP enabled on the agent

"ipv4-ipv6-dual-stack"

Big TCP enabled on the agent

cilium_envoy_config_enabled

Cilium Envoy Config enabled on the agent

cilium_node_config_enabled

Cilium Node Config enabled on the agent

max_connected_clusters

Mode of the active Cluster Mesh connections/peers

"clustermesh-apiserver"

"clustermesh-apiserver_or_etcd"

egress_gateway_enabled

Egress Gateway enabled on the agent

Envoy Proxy mode enabled on the agent

k8s_internal_traffic_policy_enabled

K8s Internal Traffic Policy enabled on the agent

kube_proxy_replacement_enabled

KubeProxyReplacement enabled on the agent

L2 LB announcement enabled on the agent

l2_pod_announcement_enabled

L2 pod announcement enabled on the agent

node_port_configuration

Node Port configuration enabled on the agent

node_port_configuration

node_port_configuration

SCTP enabled on the agent

transparent_encryption

Encryption mode enabled on the agent

transparent_encryption

VTEP enabled on the agent

Possible Label Values

cilium_endpoint_slices_enabled

Cilium Endpoint Slices enabled on the agent

Identity Allocation mode enabled on the agent

"doublewrite-readcrd"

"doublewrite-readkvstore"

IPAM mode enabled on the agent

Possible Label Values

Chaining mode enabled on the agent

Datapath config mode enabled on the agent

"ipv4-ipv6-dual-stack"

IP mode enabled on the agent

Network mode enabled on the agent

Possible Label Values

Mode to apply CIDR Policies to Nodes

cilium_clusterwide_envoy_config_total

Cilium Clusterwide Envoy Config have been ingested since the agent started

cilium_clusterwide_network_policies_total

Cilium Clusterwide Network Policies have been ingested since the agent started

cilium_envoy_config_total

Cilium Envoy Config have been ingested since the agent started

cilium_network_policies_total

Cilium Network Policies have been ingested since the agent started

Deny Policies have been ingested since the agent started

DNS Policies have been ingested since the agent started

ToFQDNs Policies have been ingested since the agent started

host_firewall_enabled

Host firewall enabled on the agent

host_network_policies_total

Host Network Policies have been ingested since the agent started

http_header_matches_policies_total

HTTP HeaderMatches Policies have been ingested since the agent started

HTTP/GRPC Policies have been ingested since the agent started

ingress_cidr_group_policies_total

Ingress CIDR Group Policies have been ingested since the agent started

internal_traffic_policy_services_total

K8s Services with Internal Traffic Policy have been ingested since the agent started

Layer 3 and Layer 4 policies have been ingested since the agent started

local_redirect_policies_total

Local Redirect Policies have been ingested since the agent started

local_redirect_policy_enabled

Local Redirect Policy enabled on the agent

Mutual Auth enabled on the agent

mutual_auth_policies_total

Mutual Auth Policies have been ingested since the agent started

non_defaultdeny_policies_enabled

Non DefaultDeny Policies is enabled in the agent

non_defaultdeny_policies_total

Non DefaultDeny Policies have been ingested since the agent started

other_l7_policies_total

Other L7 Policies have been ingested since the agent started

sni_allow_list_policies_total

SNI Allow List Policies have been ingested since the agent started

tls_inspection_policies_total

TLS Inspection Policies have been ingested since the agent started

Number of endpoints managed by this agent

Maximum interface index observed for existing endpoints

endpoint_regenerations_total

Count of all endpoint regenerations that have completed

endpoint_regeneration_time_stats_seconds

Endpoint regeneration time stats

Count of all endpoints

The default enabled status of endpoint_max_ifindex is dynamic. On earlier kernels (typically with version lower than 5.10), Cilium must store the interface index for each endpoint in the conntrack map, which reserves 16 bits for this field. If Cilium is running on such a kernel, this metric will be enabled by default. It can be used to implement an alert if the ifindex is approaching the limit of 65535. This may be the case in instances of significant Endpoint churn.

services_events_total

Number of services events labeled by action type

service_implementation_delay

Duration in seconds to propagate the data plane programming of a service, its network and endpoints from the time the service or the service pod was changed excluding the event queue latency

Number of nodes that cannot be reached

unreachable_health_endpoints

Number of health endpoints that cannot be reached

node_health_connectivity_status

source_cluster, source_node_name, type, status

Number of endpoints with last observed status of both ICMP and HTTP connectivity between the current Cilium agent and other Cilium nodes

node_health_connectivity_latency_seconds

source_cluster, source_node_name, type, address_type, protocol

Histogram of the last observed latency between the current Cilium agent and other Cilium nodes in seconds

clustermesh_global_services

source_cluster, source_node_name

The total number of global services in the cluster mesh

clustermesh_remote_clusters

source_cluster, source_node_name

The total number of remote clusters meshed with the local cluster

clustermesh_remote_cluster_failures

source_cluster, source_node_name, target_cluster

The total number of failures related to the remote cluster

clustermesh_remote_cluster_nodes

source_cluster, source_node_name, target_cluster

The total number of nodes in the remote cluster

clustermesh_remote_cluster_last_failure_ts

source_cluster, source_node_name, target_cluster

The timestamp of the last failure of the remote cluster

clustermesh_remote_cluster_readiness_status

source_cluster, source_node_name, target_cluster

The readiness status of the remote cluster

datapath_conntrack_dump_resets_total

Number of conntrack dump resets. Happens when a BPF entry gets removed while dumping the map is in progress.

datapath_conntrack_gc_runs_total

Number of times that the conntrack garbage collector process was run

datapath_conntrack_gc_key_fallbacks_total

The number of alive and deleted conntrack entries at the end of a garbage collector run labeled by datapath family

datapath_conntrack_gc_entries

The number of alive and deleted conntrack entries at the end of a garbage collector run

datapath_conntrack_gc_duration_seconds

Duration in seconds of the garbage collector process

Total number of xfrm errors

Number of keys in use

Number of XFRM states

Number of XFRM policies

bpf_syscall_duration_seconds

Duration of eBPF system call performed

mapName (deprecated), map_name, operation, outcome

Number of eBPF map operations performed. mapName is deprecated and will be removed in 1.10. Use map_name instead.

Map pressure is defined as a ratio of the required map size compared to its configured size. Values < 1.0 indicate the map’s utilization, while values >= 1.0 indicate that the map is full. Policy map metrics are only reported when the ratio is over 0.1, ie 10% full.

Maximum size of eBPF maps by group of maps (type of map that have the same max capacity size). Map types with size of 65536 are not emitted, missing map types can be assumed to be 65536.

bpf_maps_virtual_memory_max_bytes

Max memory used by eBPF maps installed in the system

bpf_progs_virtual_memory_max_bytes

Max memory used by eBPF programs installed in the system

bpf_ratelimit_dropped_total

Total drops resulting from BPF ratelimiter, tagged by source of drop

Both bpf_maps_virtual_memory_max_bytes and bpf_progs_virtual_memory_max_bytes are currently reporting the system-wide memory usage of eBPF that is directly and not directly managed by Cilium. This might change in the future and only report the eBPF memory usage directly managed by Cilium.

Total dropped packets

Total forwarded packets

Total forwarded bytes

Number of policies currently loaded

policy_regeneration_total

Deprecated, will be removed in Cilium 1.17 - use endpoint_regenerations_total instead. Total number of policies regenerated successfully

policy_regeneration_time_stats_seconds

Deprecated, will be removed in Cilium 1.17 - use endpoint_regeneration_time_stats_seconds instead. Policy regeneration time stats labeled by the scope

Highest policy revision number in the agent

Number of policy changes by outcome

policy_endpoint_enforcement_status

Number of endpoints labeled by policy enforcement status

policy_implementation_delay

Time in seconds between a policy change and it being fully deployed into the datapath, labeled by the policy’s source

policy_selector_match_count_max

The maximum number of identities selected by a network policy selector

policy_incremental_update_duration

The time taken for newly learned identities to be added to the policy system, including BPF policy maps and L7 proxies.

Number of redirects installed for endpoints

proxy_upstream_reply_seconds

error, protocol_l7, scope

Seconds waited for upstream server to reply to a request

proxy_datapath_update_timeout_total

Number of total datapath update timeouts due to FQDN IP updates

Number of total L7 requests/responses

Number of identities currently allocated

identity_label_sources

Number of identities which contain at least one label from the given label source

Number of alive and deleted identities at the end of a garbage collector run

outcome, identity_type

Number of times identity garbage collector has run

outcome, identity_type

Duration of the last successful identity GC run

Number of errors interacting with the ipcache

Number of events interacting with the ipcache

identity_cache_timer_duration

Seconds required to execute periodic policy processes. name="id-alloc-update-policy-maps" is the time taken to apply incremental updates to the BPF policy maps.

identity_cache_timer_trigger_latency

Seconds spent waiting for a previous process to finish before starting the next round. name="id-alloc-update-policy-maps" is the time waiting before applying incremental updates to the BPF policy maps.

identity_cache_timer_trigger_folds

Number of timer triggers that were coalesced in to one execution. name="id-alloc-update-policy-maps" applies the incremental updates to the BPF policy maps.

Last timestamp when Cilium received an event from a control plane source, per resource and per action

k8s_event_lag_seconds

Lag for Kubernetes events - computed value between receiving a CNI ADD event from kubelet and a Pod event received from kube-api-server

controllers_runs_total

Number of times that a controller process was run

controllers_runs_duration_seconds

Duration in seconds of the controller process

controllers_group_runs_total

Number of times that a controller process was run, labeled by controller group name

Number of failing controllers

The controllers_group_runs_total metric reports the success and failure count of each controller within the system, labeled by controller group name and completion status. Due to the large number of controllers, enabling this metric is on a per-controller basis. This is configured using an allow-list which is passed as the controller-group-metrics configuration flag, or the prometheus.controllerGroupMetrics helm value. The current recommended default set of group names can be found in the values file of the Cilium Helm chart. The special names “all” and “none” are supported.

subprocess_start_total

Number of times that Cilium has started a subprocess

kubernetes_events_received_total

scope, action, validity, equal

Number of Kubernetes events received

kubernetes_events_total

scope, action, outcome

Number of Kubernetes events processed

k8s_cnp_status_completion_seconds

Duration in seconds in how long it took to complete a CNP status update

k8s_terminating_endpoints_events_total

Number of terminating endpoint events received from Kubernetes

k8s_client_api_latency_time_seconds

Duration of processed API calls labeled by path and method

k8s_client_rate_limiter_duration_seconds

Kubernetes client rate limiter latency in seconds. Broken down by path and method

k8s_client_api_calls_total

host, method, return_code

Number of API calls made to kube-apiserver labeled by host, method and return code

Current depth of workqueue

k8s_workqueue_adds_total

Total number of adds handled by workqueue

k8s_workqueue_queue_duration_seconds

Duration in seconds an item stays in workqueue prior to request

k8s_workqueue_work_duration_seconds

Duration in seconds to process an item from workqueue

k8s_workqueue_unfinished_work_seconds

Duration in seconds of work in progress that hasn’t been observed by work_duration. Large values indicate stuck threads. You can deduce the number of stuck threads by observing the rate at which this value increases.

k8s_workqueue_longest_running_processor_seconds

Duration in seconds of the longest running processor for workqueue

k8s_workqueue_retries_total

Total number of retries handled by workqueue

Total number of IPs in the IPAM pool labeled by family

Number of IPAM events received labeled by action and datapath family type

Number of allocated IP addresses

kvstore_operations_duration_seconds

action, kind, outcome, scope

Duration of kvstore operation

kvstore_events_queue_seconds

Seconds waited before a received event was queued

kvstore_quorum_errors_total

Number of quorum errors

kvstore_sync_errors_total

scope, source_cluster

Number of times synchronization to the kvstore failed

kvstore_sync_queue_size

scope, source_cluster

Number of elements queued for synchronization in the kvstore

kvstore_initial_sync_completed

scope, source_cluster, action

Whether the initial synchronization from/to the kvstore has completed

agent_bootstrap_seconds

Duration of various bootstrap phases

api_process_time_seconds

Processing time of all the API calls made to the cilium-agent, labeled by API method, API path and returned HTTP code.

fqdn_gc_deletions_total

Number of FQDNs that have been cleaned on FQDN garbage collector job

Number of domains inside the DNS cache that have not expired (by TTL), per endpoint

Number of IPs inside the DNS cache associated with a domain that has not expired (by TTL), per endpoint

fqdn_alive_zombie_connections

Number of IPs associated with domains that have expired (by TTL) yet still associated with an active connection (aka zombie), per endpoint

Number of registered ToFQDN selectors

Number of jobs runs that returned an error

jobs_one_shot_run_seconds

Histogram of one shot job run duration

jobs_timer_run_seconds

Histogram of timer job run duration

jobs_observer_run_seconds

Histogram of observer job run duration

cidrgroups_referenced

Enabled Number of CNPs and CCNPs referencing at least one CiliumCIDRGroup. CNPs with empty or non-existing CIDRGroupRefs are not considered

cidrgroup_translation_time_stats_seconds

Disabled CIDRGroup translation time stats

api_limiter_adjustment_factor

Most recent adjustment factor for automatic adjustment

api_limiter_processed_requests_total

api_call, outcome, return_code

Total number of API requests processed

api_limiter_processing_duration_seconds

Mean and estimated processing duration in seconds

api_limiter_rate_limit

Current rate limiting configuration (limit and burst)

api_limiter_requests_in_flight

Current and maximum allowed number of requests in flight

api_limiter_wait_duration_seconds

Mean, min, and max wait duration

api_limiter_wait_history_duration_seconds

Histogram of wait duration per API call processed

vrouter, neighbor, neighbor_asn

Current state of the BGP session with the peer, Up = 1 or Down = 0

vrouter, neighbor, neighbor_asn, afi, safi

Number of routes advertised to the peer

vrouter, neighbor, neighbor_asn, afi, safi

Number of routes received from the peer

reconcile_errors_total

Number of reconciliation runs that returned an error

reconcile_run_duration_seconds

Histogram of reconciliation run duration

All metrics are enabled only when the BGP Control Plane is enabled.

cilium-operator can be configured to serve metrics by running with the option --enable-metrics. By default, the operator will expose metrics on port 9963, the port can be changed with the option --operator-prometheus-serve-addr.

Cilium Operator Feature Metrics are exported under the cilium_operator_feature Prometheus namespace.

The following tables categorize feature metrics into the following groups:

Advanced Connectivity and Load Balancing (adv_connect_and_lb)

This category includes features related to advanced networking and load balancing capabilities, such as Gateway API, Ingress Controller, LB IPAM, Node IPAM and L7 Aware Traffic Management.

For example, to check if the Gateway API is enabled on a Cilium operator, observe the metric cilium_operator_feature_adv_connect_and_lb_gateway_api_enabled. All metrics follows the format cilium_operator_feature + group name + metric name. A value of 0 indicates that the feature is disabled, while 1 indicates it is enabled.

For metrics of type “counter,” the operator has processed the associated object (e.g., a network policy) but might not be actively enforcing it. These metrics serve to observe if the object has been received and processed, but not necessarily enforced by the operator.

Possible Label Values

GatewayAPI enabled on the operator

ingress_controller_enabled

IngressController enabled on the operator

l7_aware_traffic_management_enabled

L7 Aware Traffic Management enabled on the operator

LB IPAM enabled on the operator

Node IPAM enabled on the operator

All metrics are exported under the cilium_operator_ Prometheus namespace.

reconcile_errors_total

resource_kind, resource_name

Number of errors returned per BGP resource reconciliation

reconcile_run_duration_seconds

Histogram of reconciliation run duration

All metrics are enabled only when the BGP Control Plane is enabled.

IPAM metrics are all Enabled only if using the AWS, Alibabacloud or Azure IPAM plugins.

Number of IPs allocated

ipam_ip_allocation_ops

Number of IP allocation operations.

Number of IP release operations.

ipam_interface_creation_ops

Number of interfaces creation operations.

ipam_release_duration_seconds

type, status, subnet_id

Release ip or interface latency in seconds

ipam_allocation_duration_seconds

type, status, subnet_id

Allocation ip or interface latency in seconds

ipam_available_interfaces

Number of interfaces with addresses available

Number of nodes by category { total | in-deficit | at-capacity }

Number of synchronization operations with external IPAM API

ipam_api_duration_seconds

operation, response_code

Duration of interactions with external IPAM API.

ipam_api_rate_limit_duration_seconds

Duration of rate limiting while accessing external IPAM API

Number of available IPs on a node (taking into account plugin specific NIC/Address limits).

Number of currently used IPs on a node.

Number of IPs needed to satisfy allocation on a node.

lbipam_conflicting_pools

Number of conflicting pools

Number of available IPs per pool

Number of used IPs per pool

lbipam_services_matching

Number of matching services

lbipam_services_unsatisfied

Number of services which did not get requested IPs

controllers_group_runs_total

Number of times that a controller process was run, labeled by controller group name

The controllers_group_runs_total metric reports the success and failure count of each controller within the system, labeled by controller group name and completion status. Due to the large number of controllers, enabling this metric is on a per-controller basis. This is configured using an allow-list which is passed as the controller-group-metrics configuration flag, or the prometheus.controllerGroupMetrics helm value. The current recommended default set of group names can be found in the values file of the Cilium Helm chart. The special names “all” and “none” are supported.

number_of_ceps_per_ces

The number of CEPs batched in a CES

number_of_cep_changes_per_ces

The number of changed CEPs in each CES update

The number of completed CES syncs by outcome

ces_queueing_delay_seconds

CiliumEndpointSlice queueing delay in seconds

The total number of pods observed to be unmanaged by Cilium operator

When the “Double Write” identity allocation mode is enabled, the following metrics are available:

doublewrite_crd_identities

The total number of CRD identities

doublewrite_kvstore_identities

The total number of identities in the KVStore

doublewrite_crd_only_identities

The number of CRD identities not present in the KVStore

doublewrite_kvstore_only_identities

The number of identities in the KVStore not present as a CRD

cid_controller_work_queue_event_count

Counts processed events by CID controller work queues

cid_controller_work_queue_latency

Duration of CID controller work queues enqueuing and processing latencies in seconds

The Operator uses internal queues to manage the processing of various tasks. Currently only the Cilium Node Synchronizer queues are reporting the metrics listed below.

Current depth of workqueue

Total number of adds handled by workqueue

workqueue_queue_duration_seconds

Duration in seconds an item stays in workqueue prior to request

workqueue_work_duration_seconds

Duration in seconds to process an item from workqueue

workqueue_unfinished_work_seconds

Duration in seconds of work in progress that hasn’t been observed by work_duration. Large values indicate stuck threads. You can deduce the number of stuck threads by observing the rate at which this value increases.

workqueue_longest_running_processor_seconds

Duration in seconds of the longest running processor for workqueue

workqueue_retries_total

Total number of retries handled by workqueue

Hubble metrics are served by a Hubble instance running inside cilium-agent. The command-line options to configure them are --enable-hubble, --hubble-metrics-server, and --hubble-metrics. --hubble-metrics-server takes an IP:Port pair, but passing an empty IP (e.g. :9965) will bind the server to all available interfaces. --hubble-metrics takes a space-separated list of metrics. It’s also possible to configure Hubble metrics to listen with TLS and optionally use mTLS for authentication. For details see Hubble Metrics TLS and Authentication.

Some metrics can take additional semicolon-separated options per metric, e.g. --hubble-metrics="dns:query;ignoreAAAA http:destinationContext=workload-name" will enable the dns metric with the query and ignoreAAAA options, and the http metric with the destinationContext=workload-name option.

Hubble metrics support configuration via context options. Supported context options for all metrics:

sourceContext - Configures the source label on metrics for both egress and ingress traffic.

sourceEgressContext - Configures the source label on metrics for egress traffic (takes precedence over sourceContext).

sourceIngressContext - Configures the source label on metrics for ingress traffic (takes precedence over sourceContext).

destinationContext - Configures the destination label on metrics for both egress and ingress traffic.

destinationEgressContext - Configures the destination label on metrics for egress traffic (takes precedence over destinationContext).

destinationIngressContext - Configures the destination label on metrics for ingress traffic (takes precedence over destinationContext).

labelsContext - Configures a list of labels to be enabled on metrics.

There are also some context options that are specific to certain metrics. See the documentation for the individual metrics to see what options are available for each.

See below for details on each of the different context options.

Most Hubble metrics can be configured to add the source and/or destination context as a label using the sourceContext and destinationContext options. The possible values are:

All Cilium security identity labels

Kubernetes namespace name

Kubernetes pod name and namespace name in the form of namespace/pod.

All known DNS names of the source or destination (comma-separated)

The IPv4 or IPv6 address

Reserved identity label.

Kubernetes pod’s workload name and namespace in the form of namespace/workload-name.

Kubernetes pod’s workload name (workloads are: Deployment, Statefulset, Daemonset, ReplicationController, CronJob, Job, DeploymentConfig (OpenShift), etc).

Kubernetes pod’s app name, derived from pod labels (app.kubernetes.io/name, k8s-app, or app).

When specifying the source and/or destination context, multiple contexts can be specified by separating them via the | symbol. When multiple are specified, then the first non-empty value is added to the metric as a label. For example, a metric configuration of flow:destinationContext=dns|ip will first try to use the DNS name of the target for the label. If no DNS name is known for the target, it will fall back and use the IP address of the target instead.

There are 3 cases in which the identity label list contains multiple reserved labels:

reserved:kube-apiserver and reserved:host

reserved:kube-apiserver and reserved:remote-node

reserved:kube-apiserver and reserved:world

In all of these 3 cases, reserved-identity context returns reserved:kube-apiserver.

Hubble metrics can also be configured with a labelsContext which allows providing a list of labels that should be added to the metric. Unlike sourceContext and destinationContext, instead of different values being put into the same metric label, the labelsContext puts them into different label values.

The source IP of the flow.

The namespace of the pod if the flow source is from a Kubernetes pod.

The pod name if the flow source is from a Kubernetes pod.

The name of the source pod’s workload (Deployment, Statefulset, Daemonset, ReplicationController, CronJob, Job, DeploymentConfig (OpenShift)).

The kind of the source pod’s workload, for example, Deployment, Statefulset, Daemonset, ReplicationController, CronJob, Job, DeploymentConfig (OpenShift).

The app name of the source pod, derived from pod labels (app.kubernetes.io/name, k8s-app, or app).

The destination IP of the flow.

destination_namespace

The namespace of the pod if the flow destination is from a Kubernetes pod.

The pod name if the flow destination is from a Kubernetes pod.

The name of the destination pod’s workload (Deployment, Statefulset, Daemonset, ReplicationController, CronJob, Job, DeploymentConfig (OpenShift)).

destination_workload_kind

The kind of the destination pod’s workload, for example, Deployment, Statefulset, Daemonset, ReplicationController, CronJob, Job, DeploymentConfig (OpenShift).

The app name of the source pod, derived from pod labels (app.kubernetes.io/name, k8s-app, or app).

Identifies the traffic direction of the flow. Possible values are ingress, egress and unknown.

When specifying the flow context, multiple values can be specified by separating them via the , symbol. All labels listed are included in the metric, even if empty. For example, a metric configuration of http:labelsContext=source_namespace,source_pod will add the source_namespace and source_pod labels to all Hubble HTTP metrics.

To limit metrics cardinality hubble will remove data series bound to specific pod after one minute from pod deletion. Metric is considered to be bound to a specific pod when at least one of the following conditions is met:

sourceContext is set to pod and metric series has source label matching <pod_namespace>/<pod_name>

destinationContext is set to pod and metric series has destination label matching <pod_namespace>/<pod_name>

labelsContext contains both source_namespace and source_pod and metric series labels match namespace and name of deleted pod

labelsContext contains both destination_namespace and destination_pod and metric series labels match namespace and name of deleted pod

Hubble metrics are exported under the hubble_ Prometheus namespace.

This metric, unlike other ones, is not directly tied to network flows. It’s enabled if any of the other metrics is enabled.

Number of lost events

perf_event_ring_buffer

observer_events_queue

rcode, qtypes, ips_returned

Number of DNS queries observed

rcode, qtypes, ips_returned

Number of DNS responses observed

dns_response_types_total

Number of DNS response types

Include the query as label “query”

Ignore any AAAA requests/responses

This metric supports Context Options.

This metric supports Context Options.

flows_processed_total

type, subtype, verdict

Total number of flows processed

This metric supports Context Options.

This metric counts all non-reply flows containing the reserved:world label in their destination identity. By default, dropped flows are counted if and only if the drop reason is Policy denied. Set any-drop option to count all dropped flows.

Total number of flows to reserved:world.

Count any dropped flows regardless of the drop reason.

Include the destination port as label port.

Only count non-reply SYNs for TCP flows.

This metric supports Context Options.

Deprecated, use httpV2 instead. These metrics can not be enabled at the same time as httpV2.

method, protocol, reporter

Count of HTTP requests

method, status, reporter

Count of HTTP responses

http_request_duration_seconds

Histogram of HTTP request duration in seconds

method is the HTTP method of the request/response.

protocol is the HTTP protocol of the request, (For example: HTTP/1.1, HTTP/2).

status is the HTTP status code of the response.

reporter identifies the origin of the request/response. It is set to client if it originated from the client, server if it originated from the server, or unknown if its origin is unknown.

This metric supports Context Options.

httpV2 is an updated version of the existing http metrics. These metrics can not be enabled at the same time as http.

The main difference is that http_requests_total and http_responses_total have been consolidated, and use the response flow data.

Additionally, the http_request_duration_seconds metric source/destination related labels now are from the perspective of the request. In the http metrics, the source/destination were swapped, because the metric uses the response flow data, where the source/destination are swapped, but in httpV2 we correctly account for this.

method, protocol, status, reporter

Count of HTTP requests

http_request_duration_seconds

Histogram of HTTP request duration in seconds

method is the HTTP method of the request/response.

protocol is the HTTP protocol of the request, (For example: HTTP/1.1, HTTP/2).

status is the HTTP status code of the response.

reporter identifies the origin of the request/response. It is set to client if it originated from the client, server if it originated from the server, or unknown if its origin is unknown.

Include extracted trace IDs in HTTP metrics. Requires OpenMetrics to be enabled.

This metric supports Context Options.

Number of ICMP messages

This metric supports Context Options.

topic, api_key, error_code, reporter

Count of Kafka requests by topic

kafka_request_duration_seconds

topic, api_key, reporter

Histogram of Kafka request duration by topic

This metric supports Context Options.

port_distribution_total

Numbers of packets distributed by destination port

This metric supports Context Options.

This metric supports Context Options.

This is dynamic hubble exporter metric.

dynamic_exporter_exporters_total

Number of configured hubble exporters

This is dynamic hubble exporter metric.

Status of exporter (1 - active, 0 - inactive)

name identifies exporter name

This is dynamic hubble exporter metric.

dynamic_exporter_reconfigurations_total

Number of dynamic exporters reconfigurations

This is dynamic hubble exporter metric.

dynamic_exporter_config_hash

Hash of last applied config

This is dynamic hubble exporter metric.

dynamic_exporter_config_last_applied

Timestamp of last applied config

To expose any metrics, invoke clustermesh-apiserver with the --prometheus-serve-addr option. This option takes a IP:Port pair but passing an empty IP (e.g. :9962) will bind the server to all available interfaces (there is usually only one in a container).

All metrics are exported under the cilium_clustermesh_apiserver_ Prometheus namespace.

Duration in seconds to complete bootstrap

kvstore_operations_duration_seconds

action, kind, outcome, scope

Duration of kvstore operation

kvstore_events_queue_seconds

Seconds waited before a received event was queued

kvstore_quorum_errors_total

Number of quorum errors

kvstore_sync_errors_total

scope, source_cluster

Number of times synchronization to the kvstore failed

kvstore_sync_queue_size

scope, source_cluster

Number of elements queued for synchronization in the kvstore

kvstore_initial_sync_completed

scope, source_cluster, action

Whether the initial synchronization from/to the kvstore has completed

api_limiter_processed_requests_total

api_call, outcome, return_code

Total number of API requests processed

api_limiter_processing_duration_seconds

Mean and estimated processing duration in seconds

api_limiter_rate_limit

Current rate limiting configuration (limit and burst)

api_limiter_requests_in_flight

Current and maximum allowed number of requests in flight

api_limiter_wait_duration_seconds

Mean, min, and max wait duration

controllers_group_runs_total

Number of times that a controller process was run, labeled by controller group name

The controllers_group_runs_total metric reports the success and failure count of each controller within the system, labeled by controller group name and completion status. Enabling this metric is on a per-controller basis. This is configured using an allow-list which is passed as the controller-group-metrics configuration flag. The current default set for clustermesh-apiserver found in the Cilium Helm chart is the special name “all”, which enables the metric for all controller groups. The special name “none” is also supported.

To expose any metrics, invoke kvstoremesh with the --prometheus-serve-addr option. This option takes a IP:Port pair but passing an empty IP (e.g. :9964) binds the server to all available interfaces (there is usually only one interface in a container).

All metrics are exported under the cilium_kvstoremesh_ Prometheus namespace.

Duration in seconds to complete bootstrap

The total number of remote clusters meshed with the local cluster

remote_cluster_failures

source_cluster, target_cluster

The total number of failures related to the remote cluster

remote_cluster_last_failure_ts

source_cluster, target_cluster

The timestamp of the last failure of the remote cluster

remote_cluster_readiness_status

source_cluster, target_cluster

The readiness status of the remote cluster

kvstore_operations_duration_seconds

action, kind, outcome, scope

Duration of kvstore operation

kvstore_events_queue_seconds

Seconds waited before a received event was queued

kvstore_quorum_errors_total

Number of quorum errors

kvstore_sync_errors_total

scope, source_cluster

Number of times synchronization to the kvstore failed

kvstore_sync_queue_size

scope, source_cluster

Number of elements queued for synchronization in the kvstore

kvstore_initial_sync_completed

scope, source_cluster, action

Whether the initial synchronization from/to the kvstore has completed

api_limiter_processed_requests_total

api_call, outcome, return_code

Total number of API requests processed

api_limiter_processing_duration_seconds

Mean and estimated processing duration in seconds

api_limiter_rate_limit

Current rate limiting configuration (limit and burst)

api_limiter_requests_in_flight

Current and maximum allowed number of requests in flight

api_limiter_wait_duration_seconds

Mean, min, and max wait duration

controllers_group_runs_total

Number of times that a controller process was run, labeled by controller group name

The controllers_group_runs_total metric reports the success and failure count of each controller within the system, labeled by controller group name and completion status. Enabling this metric is on a per-controller basis. This is configured using an allow-list which is passed as the controller-group-metrics configuration flag. The current default set for kvstoremesh found in the Cilium Helm chart is the special name “all”, which enables the metric for all controller groups. The special name “none” is also supported.

nat_endpoint_max_connection

Saturation of the most saturated distinct NAT mapped connection, in terms of egress-IP and remote endpoint address.

These metrics are for monitoring Cilium’s NAT mapping functionality. NAT is used by features such as Egress Gateway and BPF masquerading.

The NAT map holds mappings for masqueraded connections. Connection held in the NAT table that are masqueraded with the same egress-IP and are going to the same remote endpoints IP and port all require a unique source port for the mapping. This means that any Node masquerading connections to a distinct external endpoint is limited by the possible ephemeral source ports.

Given a Node forwarding one or more such egress-IP and remote endpoint tuples, the nat_endpoint_max_connection metric is the most saturated such connection in terms of a percent of possible source ports available. This metric is especially useful when using the egress gateway feature where it’s possible to overload a Node if many connections are all going to the same endpoint. In general, this metric should normally be fairly low. A high number here may indicate that a Node is reaching its limit for connections to one or more external endpoints.

---

## 

**URL:** https://docs.cilium.io/en/stable/_downloads/cf9ee6e71b2988e2ef225c7d156e31ed/rancher-desktop-override.yaml

---

## Terminology — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/gettingstarted/terminology/

**Contents:**
- Terminology
- Labels
  - What is a Label?
  - Label Source
- Endpoint
  - Identification
  - Endpoint Metadata
- Identity
  - What is an Identity?
  - Security Relevant Labels

Labels are a generic, flexible and highly scalable way of addressing a large set of resources as they allow for arbitrary grouping and creation of sets. Whenever something needs to be described, addressed or selected, it is done based on labels:

Endpoint are assigned labels as derived from the container runtime, orchestration system, or other sources.

Overview of Network Policy select pairs of Endpoint which are allowed to communicate based on labels. The policies themselves are identified by labels as well.

A label is a pair of strings consisting of a key and value. A label can be formatted as a single string with the format key=value. The key portion is mandatory and must be unique. This is typically achieved by using the reverse domain name notion, e.g. io.cilium.mykey=myvalue. The value portion is optional and can be omitted, e.g. io.cilium.mykey.

Key names should typically consist of the character set [a-z0-9-.].

When using labels to select resources, both the key and the value must match, e.g. when a policy should be applied to all endpoints with the label my.corp.foo then the label my.corp.foo=bar will not match the selector.

A label can be derived from various sources. For example, an endpoint will derive the labels associated to the container by the local container runtime as well as the labels associated with the pod as provided by Kubernetes. As these two label namespaces are not aware of each other, this may result in conflicting label keys.

To resolve this potential conflict, Cilium prefixes all label keys with source: to indicate the source of the label when importing labels, e.g. k8s:role=frontend, container:user=joe, k8s:role=backend. This means that when you run a Docker container using docker run [...] -l foo=bar, the label container:foo=bar will appear on the Cilium endpoint representing the container. Similarly, a Kubernetes pod started with the label foo: bar will be represented with a Cilium endpoint associated with the label k8s:foo=bar. A unique name is allocated for each potential source. The following label sources are currently supported:

container: for labels derived from the local container runtime

k8s: for labels derived from Kubernetes

reserved: for special reserved labels, see Special Identities.

unspec: for labels with unspecified source

When using labels to identify other resources, the source can be included to limit matching of labels to a particular type. If no source is provided, the label source defaults to any: which will match all labels regardless of their source. If a source is provided, the source of the selecting and matching labels need to match.

Cilium makes application containers available on the network by assigning them IP addresses. Multiple application containers can share the same IP address; a typical example for this model is a Kubernetes Pod. All application containers which share a common address are grouped together in what Cilium refers to as an endpoint.

Allocating individual IP addresses enables the use of the entire Layer 4 port range by each endpoint. This essentially allows multiple application containers running on the same cluster node to all bind to well known ports such as 80 without causing any conflicts.

The default behavior of Cilium is to assign both an IPv6 and IPv4 address to every endpoint. However, this behavior can be configured to only allocate an IPv6 address with the --enable-ipv4=false option. If both an IPv6 and IPv4 address are assigned, either address can be used to reach the endpoint. The same behavior will apply with regard to policy rules, load-balancing, etc. See IP Address Management (IPAM) for more details.

For identification purposes, Cilium assigns an internal endpoint id to all endpoints on a cluster node. The endpoint id is unique within the context of an individual cluster node.

An endpoint automatically derives metadata from the application containers associated with the endpoint. The metadata can then be used to identify the endpoint for security/policy, load-balancing and routing purposes.

The source of the metadata will depend on the orchestration system and container runtime in use. The following metadata retrieval mechanisms are currently supported:

Pod labels (via k8s API)

Container labels (via Docker API)

Metadata is attached to endpoints in the form of Labels.

The following example launches a container with the label app=benchmark which is then associated with the endpoint. The label is prefixed with container: to indicate that the label was derived from the container runtime.

An endpoint can have metadata associated from multiple sources. A typical example is a Kubernetes cluster which uses containerd as the container runtime. Endpoints will derive Kubernetes pod labels (prefixed with the k8s: source prefix) and containerd labels (prefixed with container: source prefix).

All Endpoint are assigned an identity. The identity is what is used to enforce basic connectivity between endpoints. In traditional networking terminology, this would be equivalent to Layer 3 enforcement.

An identity is identified by Labels and is given a cluster wide unique identifier. The endpoint is assigned the identity which matches the endpoint’s Security Relevant Labels, i.e. all endpoints which share the same set of Security Relevant Labels will share the same identity. This concept allows to scale policy enforcement to a massive number of endpoints as many individual endpoints will typically share the same set of security Labels as applications are scaled.

The identity of an endpoint is derived based on the Labels associated with the pod or container which are derived to the endpoint. When a pod or container is started, Cilium will create an endpoint based on the event received by the container runtime to represent the pod or container on the network. As a next step, Cilium will resolve the identity of the endpoint created. Whenever the Labels of the pod or container change, the identity is reconfirmed and automatically modified as required.

Not all Labels associated with a container or pod are meaningful when deriving the Identity. Labels may be used to store metadata such as the timestamp when a container was launched. Cilium requires to know which labels are meaningful and are subject to being considered when deriving the identity. For this purpose, the user is required to specify a list of string prefixes of meaningful labels. The standard behavior is to include all labels which start with the prefix id., e.g. id.service1, id.service2, id.groupA.service44. The list of meaningful label prefixes can be specified when starting the agent.

All endpoints which are managed by Cilium will be assigned an identity. In order to allow communication to network endpoints which are not managed by Cilium, special identities exist to represent those. Special reserved identities are prefixed with the string reserved:.

The identity could not be derived.

The local host. Any traffic that originates from or is designated to one of the local host IPs.

Any network endpoint outside of the cluster

An endpoint that is not managed by Cilium, e.g. a Kubernetes pod that was launched before Cilium was installed.

This is health checking traffic generated by Cilium agents.

An endpoint for which the identity has not yet been resolved is assigned the init identity. This represents the phase of an endpoint in which some of the metadata required to derive the security identity is still missing. This is typically the case in the bootstrapping phase.

The init identity is only allocated if the labels of the endpoint are not known at creation time. This can be the case for the Docker plugin.

The collection of all remote cluster hosts. Any traffic that originates from or is designated to one of the IPs of any host in any connected cluster other than the local node.

reserved:kube-apiserver

Remote node(s) which have backend(s) serving the kube-apiserver running.

Given to the IPs used as the source address for connections from Ingress proxies.

The following is a list of well-known identities which Cilium is aware of automatically and will hand out a security identity without requiring to contact any external dependencies such as the kvstore. The purpose of this is to allow bootstrapping Cilium and enable network connectivity with policy enforcement in the cluster for essential services without depending on any dependencies.

k8s-app=kube-dns, eks.amazonaws.com/component=kube-dns

k8s-app=kube-dns, eks.amazonaws.com/component=coredns

name=cilium-operator, io.cilium/app=operator

Note: if cilium-cluster is not defined with the cluster-name option, the default value will be set to “default”.

Identities are valid in the entire cluster which means that if several pods or containers are started on several cluster nodes, all of them will resolve and share a single identity if they share the identity relevant labels. This requires coordination between cluster nodes.

The operation to resolve an endpoint identity is performed with the help of the distributed key-value store which allows to perform atomic operations in the form generate a new unique identifier if the following value has not been seen before. This allows each cluster node to create the identity relevant subset of labels and then query the key-value store to derive the identity. Depending on whether the set of labels has been queried before, either a new identity will be created, or the identity of the initial query will be returned.

Cilium refers to a node as an individual member of a cluster. Each node must be running the cilium-agent and will operate in a mostly autonomous manner. Synchronization of state between Cilium agents running on different nodes is kept to a minimum for simplicity and scale. It occurs exclusively via the Key-Value store or with packet metadata.

Cilium will automatically detect the node’s IPv4 and IPv6 address. The detected node address is printed out when the cilium-agent starts:

---

## Cilium Operator — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/internals/cilium_operator/

**Contents:**
- Cilium Operator
- Highly Available Cilium Operator
- CRD Registration
- IPAM
- Load Balancer IP Address Management
- KVStore operations
  - K8s Services synchronization
  - K8s Nodes synchronization
  - Heartbeat update
- Identity garbage collection

This document provides a technical overview of the Cilium Operator and describes the cluster-wide operations it is responsible for.

The Cilium Operator uses Kubernetes leader election library in conjunction with lease locks to provide HA functionality. The capability is supported on Kubernetes versions 1.14 and above. It is Cilium’s default behavior since the 1.9 release.

The number of replicas for the HA deployment can be configured using Helm option operator.replicas.

The operator is an integral part of Cilium installations in Kubernetes environments and is tasked to perform the following operations:

The default behavior of the Cilium Operator is to register the CRDs used by Cilium. The following custom resources are registered by the Cilium Operator:

CiliumBGPAdvertisement

CiliumBGPClusterConfig

CiliumBGPNodeConfigOverride

CiliumBGPPeeringPolicy

CiliumClusterwideEnvoyConfig

CiliumClusterwideNetworkPolicy

CiliumEgressGatewayPolicy

CiliumGatewayClassConfig

CiliumL2AnnouncementPolicy

CiliumLoadBalancerIPPool

CiliumLocalRedirectPolicy

Cilium Operator is responsible for IP address management when running in the following modes:

Cluster Scope (Default)

When running in IPAM mode Kubernetes Host Scope, the allocation CIDRs used by cilium-agent is derived from the fields podCIDR and podCIDRs populated by Kubernetes in the Kubernetes Node resource.

For CRD-Backed IPAM allocation mode, it is the job of Cloud-specific operator to populate the required information about CIDRs in the CiliumNode resource.

Cilium currently has native support for the following Cloud providers in CRD IPAM mode:

Azure - cilium-operator-azure

AWS - cilium-operator-aws

For more information on IPAM visit IP Address Management (IPAM).

When LoadBalancer IP Address Management (LB IPAM) is used, Cilium Operator manages IP address for type: LoadBalancer services.

These operations are performed only when KVStore is enabled for the Cilium Operator. In addition, KVStore operations are only required when cilium-operator is running with any of the below options:

--synchronize-k8s-services

--synchronize-k8s-nodes

--identity-allocation-mode=kvstore

Cilium Operator performs the job of synchronizing Kubernetes services to external KVStore configured for the Cilium Operator if running with --synchronize-k8s-services flag.

The Cilium Operator performs this operation only for shared services (services that have service.cilium.io/shared annotation set to true). This is meaningful when running Cilium to setup a ClusterMesh.

Similar to K8s services, Cilium Operator also synchronizes Kubernetes nodes information to the shared KVStore.

When a Node object is deleted it is not possible to reliably cleanup the corresponding CiliumNode object from the Agent itself. The Cilium Operator holds the responsibility to garbage collect orphaned CiliumNodes.

The Cilium Operator periodically updates the Cilium’s heartbeat path key with the current time. The default key for this heartbeat is cilium/.heartbeat in the KVStore. It is used by Cilium Agents to validate that KVStore updates can be received.

Each workload in Kubernetes is assigned a security identity that is used for policy decision making. This identity is based on common workload markers like labels. Cilium supports two identity allocation mechanisms:

CRD Identity allocation

KVStore Identity allocation

Both the mechanisms of identity allocation require the Cilium Operator to perform the garbage collection of stale identities. This garbage collection is necessary because a 16-bit unsigned integer represents the security identity, and thus we can only have a maximum of 65536 identities in the cluster.

CRD identity allocation uses Kubernetes custom resource CiliumIdentity to represent a security identity. This is the default behavior of Cilium and works out of the box in any K8s environment without any external dependency.

The Cilium Operator maintains a local cache for CiliumIdentities with the last time they were seen active. A controller runs in the background periodically which scans this local cache and deletes identities that have not had their heartbeat life sign updated since identity-heartbeat-timeout.

One thing to note here is that an Identity is always assumed to be live if it has an endpoint associated with it.

While the CRD allocation mode for identities is more common, it is limited in terms of scale. When running in a very large environment, a saner choice is to use the KVStore allocation mode. This mode stores the identities in an external store like etcd.

For more information on Cilium’s scalability visit Scalability report.

The garbage collection mechanism involves scanning the KVStore of all the identities. For each identity, the Cilium Operator search in the KVStore if there are any active users of that identity. The entry is deleted from the KVStore if there are no active users.

CiliumEndpoint object is created by the cilium-agent for each Pod in the cluster. The Cilium Operator manages a controller to handle the garbage collection of orphaned CiliumEndpoint objects. An orphaned CiliumEndpoint object means that the owner of the endpoint object is not active anymore in the cluster. CiliumEndpoints are also considered orphaned if the owner is an existing Pod in PodFailed or PodSucceeded state. This controller is run periodically if the endpoint-gc-interval option is specified and only once during startup if the option is unspecified.

When using Cloud-provider-specific constructs like toGroups in the network policy spec, the Cilium Operator performs the job of converting these constructs to derivative CNP/CCNP objects without these fields.

For more information, see how Cilium network policies incorporate the use of toGroups to lock down external access using AWS security groups.

When Ingress or Gateway API support is enabled, the Cilium Operator performs the task of parsing Ingress or Gateway API objects and converting them into CiliumEnvoyConfig objects used for configuring the per-node Envoy proxy.

Additionally, Secrets used by Ingress or Gateway API objects will be synced to a Cilium-managed namespace that the Cilium Agent is then granted access to. This reduces the permissions required of the Cilium Agent.

When Cilium’s Mutual Authentication Support is enabled, the Cilium Operator is responsible for ensuring that each Cilium Identity has an associated identity in the certificate management system. It will create and delete identity registrations in the configured certificate management section as required. The Cilium Operator does not, however have any to the key material in the identities.

That information is only shared with the Cilium Agent via other channels.

---

## Getting Started with the Star Wars Demo — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/gettingstarted/demo/

**Contents:**
- Getting Started with the Star Wars Demo
- Deploy the Demo Application
- Check Current Access
- Apply an L3/L4 Policy
- Inspecting the Policy
- Apply and Test HTTP-aware L7 Policy
- Clean-up
- Next Steps

When we have Cilium deployed and kube-dns operating correctly we can deploy our demo application.

In our Star Wars-inspired example, there are three microservices applications: deathstar, tiefighter, and xwing. The deathstar runs an HTTP webservice on port 80, which is exposed as a Kubernetes Service to load-balance requests to deathstar across two pod replicas. The deathstar service provides landing services to the empire’s spaceships so that they can request a landing port. The tiefighter pod represents a landing-request client service on a typical empire ship and xwing represents a similar service on an alliance ship. They exist so that we can test different security policies for access control to deathstar landing services.

Application Topology for Cilium and Kubernetes

The file http-sw-app.yaml contains a Kubernetes Deployment for each of the three services. Each deployment is identified using the Kubernetes labels (org=empire, class=deathstar), (org=empire, class=tiefighter), and (org=alliance, class=xwing). It also includes a deathstar-service, which load-balances traffic to all pods with label (org=empire, class=deathstar).

Kubernetes will deploy the pods and service in the background. Running kubectl get pods,svc will inform you about the progress of the operation. Each pod will go through several states until it reaches Running at which point the pod is ready.

Each pod will be represented in Cilium as an Endpoint in the local cilium agent. We can invoke the cilium-dbg tool inside the Cilium pod to list them (in a single-node installation kubectl -n kube-system exec ds/cilium -- cilium-dbg endpoint list lists them all, but in a multi-node installation, only the ones running on the same node will be listed):

Both ingress and egress policy enforcement is still disabled on all of these pods because no network policy has been imported yet which select any of the pods.

From the perspective of the deathstar service, only the ships with label org=empire are allowed to connect and request landing. Since we have no rules enforced, both xwing and tiefighter will be able to request landing. To test this, use the commands below.

When using Cilium, endpoint IP addresses are irrelevant when defining security policies. Instead, you can use the labels assigned to the pods to define security policies. The policies will be applied to the right pods based on the labels irrespective of where or when it is running within the cluster.

We’ll start with the basic policy restricting deathstar landing requests to only the ships that have label (org=empire). This will not allow any ships that don’t have the org=empire label to even connect with the deathstar service. This is a simple policy that filters only on IP protocol (network layer 3) and TCP protocol (network layer 4), so it is often referred to as an L3/L4 network security policy.

Note: Cilium performs stateful connection tracking, meaning that if policy allows the frontend to reach backend, it will automatically allow all required reply packets that are part of backend replying to frontend within the context of the same TCP/UDP connection.

L4 Policy with Cilium and Kubernetes

We can achieve that with the following CiliumNetworkPolicy:

CiliumNetworkPolicies match on pod labels using an “endpointSelector” to identify the sources and destinations to which the policy applies. The above policy whitelists traffic sent from any pods with label (org=empire) to deathstar pods with label (org=empire, class=deathstar) on TCP port 80.

To apply this L3/L4 policy, run:

Now if we run the landing requests again, only the tiefighter pods with the label org=empire will succeed. The xwing pods will be blocked!

This works as expected. Now the same request run from an xwing pod will fail:

This request will hang, so press Control-C to kill the curl request, or wait for it to time out.

If we run cilium-dbg endpoint list again we will see that the pods with the label org=empire and class=deathstar now have ingress policy enforcement enabled as per the policy above.

You can also inspect the policy details via kubectl

In the simple scenario above, it was sufficient to either give tiefighter / xwing full access to deathstar’s API or no access at all. But to provide the strongest security (i.e., enforce least-privilege isolation) between microservices, each service that calls deathstar’s API should be limited to making only the set of HTTP requests it requires for legitimate operation.

For example, consider that the deathstar service exposes some maintenance APIs which should not be called by random empire ships. To see this run:

While this is an illustrative example, unauthorized access such as above can have adverse security repercussions.

L7 Policy with Cilium and Kubernetes

Cilium is capable of enforcing HTTP-layer (i.e., L7) policies to limit what URLs the tiefighter is allowed to reach. Here is an example policy file that extends our original policy by limiting tiefighter to making only a POST /v1/request-landing API call, but disallowing all other calls (including PUT /v1/exhaust-port).

Update the existing rule to apply L7-aware policy to protect deathstar using:

We can now re-run the same test as above, but we will see a different outcome:

As this rule builds on the identity-aware rule, traffic from pods without the label org=empire will continue to be dropped causing the connection to time out:

As you can see, with Cilium L7 security policies, we are able to permit tiefighter to access only the required API resources on deathstar, thereby implementing a “least privilege” security approach for communication between microservices. Note that path matches the exact url, if for example you want to allow anything under /v1/, you need to use a regular expression:

You can observe the L7 policy via kubectl:

It is also possible to monitor the HTTP requests live by using cilium-dbg monitor:

The above output demonstrates a successful response to a POST request followed by a PUT request that is denied by the L7 policy.

We hope you enjoyed the tutorial. Feel free to play more with the setup, read the rest of the documentation, and reach out to us on the Cilium Slack with any questions!

Setting up Hubble Observability

Inspecting Network Flows with the CLI

Service Map & Hubble UI

Identity-Aware and HTTP-Aware Policy Enforcement

Setting up Cluster Mesh

---

## 

**URL:** https://docs.cilium.io/en/stable/_images/cilium_http_gsg.png

---

## Configure TLS with Hubble — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/observability/hubble/configuration/tls/

**Contents:**
- Configure TLS with Hubble
- Enable TLS on the Hubble API
  - Troubleshooting
  - Validating the Installation
- Hubble Metrics TLS and Authentication
- Access the Hubble API with TLS Enabled

This page provides guidance to configure Hubble with TLS in a way that suits your environment. Instructions to enable Hubble are provided as part of each Cilium Getting Started guide.

When Hubble Relay is deployed, Hubble listens on a TCP port on the host network. This allows Hubble Relay to communicate with all Hubble instances in the cluster. Connections between Hubble instances and Hubble Relay are secured using mutual TLS (mTLS) by default.

TLS certificates can be generated automatically or manually provided.

The following options are available to configure TLS certificates automatically:

cilium’s certgen (using a Kubernetes CronJob)

Each of these method handles certificate rotation differently, but the end result is the secrets containing the key pair will be updated. As Hubble server and Hubble Relay support TLS certificates hot reloading, including CA certificates, this does not disrupt any existing connection. New connections are automatically established using the new certificates without having to restart Hubble server or Hubble Relay.

When using certgen, TLS certificates are generated at installation time and a Kubernetes CronJob is scheduled to renew them (regardless of their expiration date). The certgen method is easier to implement than cert-manager but less flexible.

This method relies on cert-manager to generate the TLS certificates. cert-manager has becomes the de facto way to manage TLS on Kubernetes, and it has the following advantages compared to the other documented methods:

Support for multiple issuers (e.g. a custom CA, Vault, Let’s Encrypt, Google’s Certificate Authority Service, and more) allowing to choose the issuer fitting your organization’s requirements.

Manages certificates via a CRD which is easier to inspect with Kubernetes tools than PEM files.

First, install cert-manager and setup an issuer. Please make sure that your issuer is able to create certificates under the cilium.io domain name.

Install/upgrade Cilium including the following Helm flags:

When using Helm, TLS certificates are (re-)generated every time Helm is used for install or upgrade.

The downside of the Helm method is that while certificates are automatically generated, they are not automatically renewed. Consequently, running helm upgrade is required when certificates are about to expire (i.e. before the configured hubble.tls.auto.certValidityDuration).

In order to provide your own TLS certificates, hubble.tls.auto.enabled must be set to false, secrets containing the certificates must be created in the kube-system namespace, and the secret names must be provided to Helm.

Provided files must be base64 encoded PEM certificates.

In addition, the Common Name (CN) and Subject Alternative Name (SAN) of the certificate for Hubble server MUST be set to *.{cluster-name}.hubble-grpc.cilium.io where {cluster-name} is the cluster name defined by cluster.name (defaults to default).

Once the certificates have been issued, the secrets must be created in the kube-system namespace.

Each secret must contain the following keys:

tls.crt: The certificate file.

tls.key: The private key file.

ca.crt: The CA certificate file.

The following examples demonstrates how to create the secrets.

Create the hubble server certificate secret:

If hubble-relay is enabled, the following secrets must be created:

If hubble-ui is enabled, the following secret must be created:

Lastly, if the Hubble metrics API is enabled, the following secret must be created:

After the secrets have been created, the secret names must be provided to Helm and automatic certificate generation must be disabled:

hubble.relay.tls.server.existingSecret and hubble.ui.tls.client.existingSecret only need to be provided when hubble.relay.tls.server.enabled=true (default false).

hubble.ui.tls.client.existingSecret only needs to be provided when hubble.ui.enabled (default false).

hubble.metrics.tls.server.existingSecret only needs to be provided when hubble.metrics.tls.enabled (default false). For more details on configuring the Hubble metrics API with TLS, see Hubble Metrics TLS and Authentication.

If you encounter issues after enabling TLS, you can use the following instructions to help diagnose the problem.

While installing Cilium or cert-manager you may get the following error:

This happens when cert-manager’s webhook (which is used to verify the Certificate’s CRD resources) is not available. There are several ways to resolve this issue. Pick one of the following options:

Install cert-manager CRDs before Cilium and cert-manager (see cert-manager’s documentation about installing CRDs with kubectl):

Then install cert-manager, configure an issuer, and install Cilium.

Upgrade Cilium from an installation with TLS disabled:

Then install cert-manager, configure an issuer, and upgrade Cilium enabling TLS:

Disable cert-manager validation (assuming Cilium is installed in the kube-system namespace):

Then install Cilium, cert-manager, and configure an issuer.

Configure cert-manager to expose its webhook within the host network namespace:

Then configure an issuer and install Cilium.

If you are using ArgoCD, you may encounter issues on the initial installation because of how ArgoCD handles Helm hooks specified in the helm.sh/hook annotation.

The hubble-generate-certs Job specifies a post-install Helm hook in order to generate the required Certificates at initial install time, since the CronJob will only run on the configured schedule which could be hours or days after the initial installation.

Since ArgoCD will only run post-install hooks after all pods are ready and running, you may encounter a situation where the hubble-generate-certs Job is never run.

It cannot be configured as a pre-install hook because it requires Cilium to be running first, and Hubble Relay cannot become ready until certificates are provisioned.

To work around this, you can manually run the certgen CronJob:

When using Helm certificates are not automatically renewed. If you encounter issues with expired certificates, you can manually renew them by running helm upgrade to renew the certificates.

If you encounter issues with the certificates, you can check the certificates and keys by decoding them:

The same commands can be used for the other secrets as well.

If hubble-relay is enabled but not responding or the pod is failing it’s readiness probe, check the certificates and ensure the client certificate is issued by the CA (ca.crt) specified in the hubble-server-certs secret.

Additionally you must ensure the Common Name (CN) and Subject Alternative Name (SAN) of the certificate for Hubble server MUST be set to *.{cluster-name}.hubble-grpc.cilium.io where {cluster-name} is the cluster name defined by cluster.name (defaults to default).

The following section guides you through validating that TLS is enabled for Hubble and the connection between Hubble Relay and Hubble Server is using mTLS to secure the session. Additionally, the commands below can be used to troubleshoot issues with your TLS configuration if you encounter any issues.

Before beginning verify TLS has been configured correctly by running the following command:

You should see that the hubble-disable-tls configuration option is set to false.

Start by creating a Hubble CLI pod within the namespace that Hubble components are running in (for example: kube-system):

List Hubble Servers by running hubble watch peers within the newly created pod:

Copy the IP and the server name of the first peer into the following environment variables for the next steps:

If the TLS.ServerName is missing from your output then TLS is not enabled for the Hubble server and the following steps will not work. If this is the case, please refer to the previous sections to enable TLS.

Connect to the first peer with the Hubble Relay client certificate to confirm that the Hubble server is accepting connections from clients who present the correct certificate:

Now try to query the Hubble server without providing any client certificate:

You can also try to connect without TLS:

To troubleshoot the connection, install OpenSSL in the Hubble CLI pod:

Then, use OpenSSL to connect to the Hubble server get more details about the TLS handshake:

Breaking the output down:

Server Certificate: This is the server certificate presented by the server.

Acceptable client certificate CA names: These are the CA names that the server accepts for client certificates.

SSL handshake has read 1108 bytes and written 387 bytes: Details on the handshake. Errors could be presented here if any occurred.

Verification: OK: The server certificate is valid.

Verify return code: 0 (ok): The server certificate was verified successfully.

error:0A00045C:SSL routines:ssl3_read_bytes:tlsv13 alert certificate required: The server requires a client certificate to be provided. Since a client certificate was not provided, the connection failed.

If you provide the correct client certificate and key, the connection should be successful:

Press ctrl-d to signal the TLS session and connection should be terminated. After the session has ended you will see output similar to the following:

The output of this OpenSSL command is similar to the previous output, but without the error message.

There is also an additional section, starting with Post-Handshake New Session Ticket arrived, the presence of which indicates that the client certificate is valid and a TLS session was established. The summary of the TLS session printed after the connection has ended can also be used as an indicator of the established TLS session.

Starting with Cilium 1.16, Hubble supports configuring TLS on the Hubble metrics API in addition to the Hubble observer API.

This can be done by specifying the following options to Helm at install or upgrade time, along with the TLS configuration options described in the previous section.

This section assumes that you have already enabled Hubble metrics.

To enable TLS on the Hubble metrics API, add the following Helm flag to your list of options:

If you also want to enable authentication using mTLS on the Hubble metrics API, first create a ConfigMap with a CA certificate to use for verifying client certificates:

Then, add the following flags to your Helm command to enable mTLS:

After the configuration is applied, clients will be required to authenticate using a certificate signed by the configured CA certificate to access the Hubble metrics API.

When using TLS with the Hubble metrics API you will need to update your Prometheus scrape configuration to use HTTPS by setting a tls_config and provide the path to the CA certificate. When using mTLS you will also need to provide a client certificate and key signed by the CA certificate for Prometheus to authenticate to the Hubble metrics API.

The examples are adapted from Inspecting Network Flows with the CLI.

Before you can access the Hubble API with TLS enabled, you need to obtain the CA certificate from the secret that was created when enabling TLS. The following examples demonstrate how to obtain the CA certificate and use it to access the Hubble API.

Run the following command to obtain the CA certificate from the hubble-relay-server-certs secret:

After obtaining the CA certificate you can use the --tls to enable TLS and --tls-ca-cert-files flag to specify the CA certificate. Additionally, when port-forwarding to Hubble Relay, you will need to specify the --tls-server-name flag:

To persist these options for the shell session, set the following environment variables:

---

## Verifying Image Signatures — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/configuration/verify-image-signatures/

**Contents:**
- Verifying Image Signatures
- Prerequisites
- Verify Signed Container Images

You will need to install cosign.

Since version 1.13, all Cilium container images are signed using cosign.

Let’s verify a Cilium image’s signature using the cosign verify command:

cosign is used to verify images signed in KEYLESS mode. To learn more about keyless signing, please refer to Keyless Signatures.

--certificate-github-workflow-name string contains the workflow claim from the GitHub OIDC Identity token that contains the name of the executed workflow. For the names of workflows used to build Cilium images, see the build-images workflows under Cilium workflows.

--certificate-github-workflow-ref string contains the ref claim from the GitHub OIDC Identity token that contains the git ref that the workflow run was based upon.

--certificate-identity is used to verify the identity of the certificate from the GitHub build images release workflow.

---

## Community Meetings — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/community/community/

**Contents:**
- Community Meetings
- Weekly Community Meeting
- Monthly APAC Community Meeting
- Slack
- Slack channels
- How to create a Slack channel
- Special Interest Groups

The Cilium contributors gather regularly for a Zoom call open to everyone. During that time, we discuss:

Status of the next releases for each supported Cilium release

Current state of our CI: flakes being investigated and upcoming changes

Development items for the next release

Any other community-relevant topics during the open session

If you want to discuss something during the next meeting’s open session, you can add it to the meeting’s Google doc. The Zoom link to the meeting is available in the #development Slack channel and in the meeting notes.

This is a weekly meeting for all contributors.

Date: Every Wednesday at 8:00 AM US/Pacific (Los Angeles)

Meeting notes: Google Doc

This is a monthly community meeting held at APAC friendly time.

Date: Every third Wednesday at 4:30 UTC

Meeting notes: Google Doc

Our Cilium & eBPF Slack is the main discussion space for the Cilium community.

General user discussions & questions

Kubernetes-specific questions

Questions on network policies

Release announcements only

Questions on Cilium Service Mesh

Questions on Tetragon

You can join the following channels if you are looking to contribute to Cilium code, documentation, or website:

Development discussions around Cilium

Development discussion for the eBPF Go library

SIG-specific discussions (see below)

Discussing a specific area of the project

Testing and CI discussions

Development discussions around cilium.io

If you are interested in eBPF, then the following channels are for you:

General eBPF questions

Questions on the eBPF Go library

Questions on BPF Linux Security Modules (LSM)

Contributions to eCHO News

Discussions around eBPF for Windows

Our Slack hosts channels for eBPF and Cilium-related events online and in person.

Cilium and eBPF capture-the-flag challenges

Open a new GitHub issue in the cilium/community repo

Specify the title “Slack: <Name>”

Provide a description

Find two Cilium committers to comment in the issue that they approve the creation of the Slack channel

Not all Slack channels need to be listed on this page, but you can submit a PR if you would like to include it here

The Cilium project has Special Interest Groups, or SIGs, with a common purpose of advancing the project with respect to a specific topic, such as network policy or documentation. Their goal is to enable a distributed decision structure and code ownership, as well as providing focused forums for getting work done, making decisions, and on boarding new contributors.

To learn more about what they are, how to get involved, or which ones are currently active, please check out the SIG.md in the community repo

---

## Scalability report — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/operations/performance/scalability/report/

**Contents:**
- Scalability report
- Setup
- Steps
  - 1. Install Kubernetes v1.18.3 with EndpointSlice feature enabled
  - 2. Deploy Prometheus, Grafana and Cilium
  - 3. Provision 2 worker nodes
  - 4. Deploy 5 namespaces with 25 deployments on each namespace
  - 5. Provision 998 additional nodes (total 1000 nodes)
  - 6. Deploy 25 more deployments on each namespace
  - 7. Scale each deployment to 200 replicas (50000 pods in total)

This report is intended for users planning to run Cilium on clusters with more than 200 nodes in CRD mode (without a kvstore available). In our development cycle we have deployed Cilium on large clusters and these were the options that were suitable for our testing:

--set endpointHealthChecking.enabled=false and --set healthChecking=false disable endpoint health checking entirely. However it is recommended that those features be enabled initially on a smaller cluster (3-10 nodes) where it can be used to detect potential packet loss due to firewall rules or hypervisor settings.

--set ipam.mode=kubernetes is set to "kubernetes" since our cloud provider has pod CIDR allocation enabled in kube-controller-manager.

--set k8sServiceHost and --set k8sServicePort were set with the IP address of the loadbalancer that was in front of kube-apiserver. This allows Cilium to not depend on kube-proxy to connect to kube-apiserver.

--set prometheus.enabled=true and --set operator.prometheus.enabled=true were just set because we had a Prometheus server probing for metrics in the entire cluster.

Our testing cluster consisted of 3 controller nodes and 1000 worker nodes. We have followed the recommended settings from the official Kubernetes documentation and have provisioned our machines with the following settings:

Cloud provider: Google Cloud

Controllers: 3x n1-standard-32 (32vCPU, 120GB memory and 50GB SSD, kernel 5.4.0-1009-gcp)

Workers: 1 pool of 1000x custom-2-4096 (2vCPU, 4GB memory and 10GB HDD, kernel 5.4.0-1009-gcp)

Metrics: 1x n1-standard-32 (32vCPU, 120GB memory and 10GB HDD + 500GB HDD) this is a dedicated node for prometheus and grafana pods.

All 3 controller nodes were behind a GCE load balancer.

Each controller contained etcd, kube-apiserver, kube-controller-manager and kube-scheduler instances.

The CPU, memory and disk size set for the workers might be different for your use case. You might have pods that require more memory or CPU available so you should design your workers based on your requirements.

During our testing we had to set the etcd option quota-backend-bytes=17179869184 because etcd failed once it reached around 2GiB of allocated space.

We provisioned our worker nodes without kube-proxy since Cilium is capable of performing all functionalities provided by kube-proxy. We created a load balancer in front of kube-apiserver to allow Cilium to access kube-apiserver without kube-proxy, and configured Cilium with the options --set k8sServiceHost=<KUBE-APISERVER-LB-IP-ADDRESS> and --set k8sServicePort=<KUBE-APISERVER-LB-PORT-NUMBER>.

Our DaemonSet updateStrategy had the maxUnavailable set to 250 pods instead of 2, but this value highly depends on your requirements when you are performing a rolling update of Cilium.

For each step we took, we provide more details below, with our findings and expected behaviors.

To test the most up-to-date functionalities from Kubernetes and Cilium, we have performed our testing with Kubernetes v1.18.3 and the EndpointSlice feature enabled to improve scalability.

Since Kubernetes requires an etcd cluster, we have deployed v3.4.9.

We have used Prometheus v2.18.1 and Grafana v7.0.1 to retrieve and analyze etcd, kube-apiserver, cilium and cilium-operator metrics.

This helped us to understand if our testing cluster was correctly provisioned and all metrics were being gathered.

Each deployment had 1 replica (125 pods in total).

To measure only the resources consumed by Cilium, all deployments used the same base image registry.k8s.io/pause:3.2. This image does not have any CPU or memory overhead.

We provision a small number of pods in a small cluster to understand the CPU usage of Cilium:

The mark shows when the creation of 125 pods started. As expected, we can see a slight increase of the CPU usage on both Cilium agents running and in the Cilium operator. The agents peaked at 6.8% CPU usage on a 2vCPU machine.

For the memory usage, we have not seen a significant memory growth in the Cilium agent. On the eBPF memory side, we do see it increasing due to the initialization of some eBPF maps for the new pods.

The first mark represents the action of creating nodes, the second mark when 1000 Cilium pods were in ready state. The CPU usage increase is expected since each Cilium agent receives events from Kubernetes whenever a new node is provisioned in the cluster. Once all nodes were deployed the CPU usage was 0.15% on average on a 2vCPU node.

As we have increased the number of nodes in the cluster to 1000, it is expected to see a small growth of the memory usage in all metrics. However, it is relevant to point out that an increase in the number of nodes does not cause any significant increase in Cilium’s memory consumption in both control and dataplane.

This will now bring us a total of 5 namespaces * (25 old deployments + 25 new deployments)=250 deployments in the entire cluster. We did not install 250 deployments from the start since we only had 2 nodes and that would create 125 pods on each worker node. According to the Kubernetes documentation the maximum recommended number of pods per node is 100.

Having 5 namespaces with 50 deployments means that we have 250 different unique security identities. Having a low cardinality in the labels selected by Cilium helps scale the cluster. By default, Cilium has a limit of 16k security identities, but it can be increased with bpf-policy-map-max in the Cilium ConfigMap.

The first mark represents the action of scaling up the deployments, the second mark when 50000 pods were in ready state.

It is expected to see the CPU usage of Cilium increase since, on each node, Cilium agents receive events from Kubernetes when a new pod is scheduled and started.

The average CPU consumption of all Cilium agents was 3.38% on a 2vCPU machine. At one point, roughly around minute 15:23, one of those Cilium agents picked 27.94% CPU usage.

Cilium Operator had a stable 5% CPU consumption while the pods were being created.

Similar to the behavior seen while increasing the number of worker nodes, adding new pods also increases Cilium memory consumption.

As we increased the number of pods from 250 to 50000, we saw a maximum memory usage of 573MiB for one of the Cilium agents while the average was 438 MiB.

For the eBPF memory usage we saw a max usage of 462.7MiB

This means that each Cilium agent’s memory increased by 10.5KiB per new pod in the cluster.

Here we have created 125 L4 network policies and 125 L7 policies. Each policy selected all pods on this namespace and was allowed to send traffic to another pod on this namespace. Each of the 250 policies allows access to a disjoint set of ports. In the end we will have 250 different policies selecting 10000 pods.

In this case we saw one of the Cilium agents jumping to 100% CPU usage for 15 seconds while the average peak was 40% during a period of 90 seconds.

As expected, increasing the number of policies does not have a significant impact on the memory usage of Cilium since the eBPF policy maps have a constant size once a pod is initialized.

The first mark represents the point in time when we ran kubectl create to create the CiliumNetworkPolicies. Since we created the 250 policies sequentially, we cannot properly compute the convergence time. To do that, we could use a single CNP with multiple policy rules defined under the specs field (instead of the spec field).

Nevertheless, we can see the time it took the last Cilium agent to increment its Policy Revision, which is incremented individually on each Cilium agent every time a CiliumNetworkPolicy (CNP) is received, between second 15:45:44 and 15:45:46 and see when was the last time an Endpoint was regenerated by checking the 99th percentile of the “Endpoint regeneration time”. In this manner, that it took less than 5s. We can also verify the maximum time was less than 600ms for an endpoint to have the policy enforced.

The difference between these policies and the previous ones installed is that these select all pods in all namespaces. To recap, this means that we will now have 250 different network policies selecting 10000 pods and 250 different network policies selecting 50000 pods on a cluster with 1000 nodes. Similarly to the previous step we will deploy 125 L4 policies and another 125 L7 policies.

Similar to the creation of the previous 250 CNPs, there was also an increase in CPU usage during the creation of the CCNPs. The CPU usage was similar even though the policies were effectively selecting more pods.

As all pods running in a node are selected by all 250 CCNPs created, we see an increase of the Endpoint regeneration time which peaked a little above 3s.

In this step we have “accidentally” deleted 10000 random pods. Kubernetes will then recreate 10000 new pods so it will help us understand what the convergence time is for all the deployed network polices.

The first mark represents the point in time when pods were “deleted” and the second mark represents the point in time when Kubernetes finished recreating 10k pods.

Besides the CPU usage slightly increasing while pods are being scheduled in the cluster, we did see some interesting data points in the eBPF memory usage. As each endpoint can have one or more dedicated eBPF maps, the eBPF memory usage is directly proportional to the number of pods running in a node. If the number of pods per node decreases so does the eBPF memory usage.

We inferred the time it took for all the endpoints to get regenerated by looking at the number of Cilium endpoints with the policy enforced over time. Luckily enough we had another metric that was showing how many Cilium endpoints had policy being enforced:

The focus of this test was to study the Cilium agent resource consumption at scale. However, we also monitored some metrics of the control plane nodes such as etcd metrics and CPU usage of the k8s-controllers and we present them in the next figures.

Memory consumption of the 3 etcd instances during the entire scalability testing.

CPU usage for the 3 controller nodes, average latency per request type in the etcd cluster as well as the number of operations per second made to etcd.

All etcd metrics, from left to right, from top to bottom: database size, disk sync duration, client traffic in, client traffic out, peer traffic in, peer traffic out.

These experiments helped us develop a better understanding of Cilium running in a large cluster entirely in CRD mode and without depending on etcd. There is still some work to be done to optimize the memory footprint of eBPF maps even further, as well as reducing the memory footprint of the Cilium agent. We will address those in the next Cilium version.

We can also determine that it is scalable to run Cilium in CRD mode on a cluster with more than 200 nodes. However, it is worth pointing out that we need to run more tests to verify Cilium’s behavior when it loses the connectivity with kube-apiserver, as can happen during a control plane upgrade for example. This will also be our focus in the next Cilium version.

---

## Configuration — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/configuration/

**Contents:**
- Configuration
- cilium-config ConfigMap
- Making Changes
- Core Agent
- Security

Your Cilium installation is configured by one or more Helm values - see Helm Reference. These helm values are converted to arguments for the individual components of a Cilium installation, such as cilium-agent and cilium-operator, and stored in a ConfigMap.

These arguments are stored in a shared ConfigMap called cilium-config (albeit without the leading --). For example, a typical installation may look like

You may change the configuration of a running installation in three ways:

Do so by providing new values to Helm and applying them to the existing installation. By setting the value rollOutCiliumPods=true, the agent pods will be gradually restarted.

Via cilium config set

The Cilium CLI has the ability to update individual values in the cilium-config ConfigMap. By default Cilium Agent pods are restarted when configuration is changed. To gradually restart do cilium config set --restart=false ... and manually delete agent pods to pick up the changes.

Via CiliumNodeConfig objects

Cilium also supports configuration on sets of nodes. See the Per-node configuration page for more details. This requires that pods be manually deleted for changes to take effect.

---

## Setting up Hubble Observability — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/observability/hubble/setup/

**Contents:**
- Setting up Hubble Observability
- Enable Hubble in Cilium
- Install the Hubble Client
- Validate Hubble API Access
- Troubleshooting Hubble Deployment
  - Hubble Relay
  - Hubble
- Next Steps

Hubble is the observability layer of Cilium and can be used to obtain cluster-wide visibility into the network and security layer of your Kubernetes cluster.

This guide assumes that Cilium has been correctly installed in your Kubernetes cluster. Please see Cilium Quick Installation for more information. If unsure, run cilium status and validate that Cilium is up and running.

Enabling Hubble requires the TCP port 4244 to be open on all nodes running Cilium. This is required for Relay to operate correctly.

In order to enable Hubble and install Hubble relay, run the command cilium hubble enable as shown below:

If you installed Cilium via helm install, Hubble is enabled by default. You may enable Hubble Relay with the following command:

Run cilium status to validate that Hubble is enabled and running:

In order to access the observability data collected by Hubble, you must first install Hubble CLI.

Select the tab for your platform below and install the latest release of Hubble CLI.

Download the latest hubble release:

Download the latest hubble release:

Download the latest hubble release:

and move the hubble.exe CLI to a directory listed in the %PATH% environment variable after extracting it from the tarball.

The following commands use the -P (--port-forward) flag to automatically port-forward the Hubble Relay service from your local machine on port 4245.

You can also omit the flag and create a port-forward manually with the Cilium CLI:

For more information on this method, see Use Port Forwarding to Access Application in a Cluster.

Now you can validate that you can access the Hubble API via the installed CLI:

You can also query the flow API and look for flows:

If you port forward to a port other than 4245 (--port-forward-port PORT when using automatic port-forwarding), make sure to use the --server flag or HUBBLE_SERVER environment variable to set the Hubble server address (default: localhost:4245).

For more information, check out Hubble CLI’s help message by running hubble help status or hubble help observe as well as hubble config for configuring Hubble CLI.

If you have enabled TLS then you will need to specify additional flags to access the Hubble API.

Validate the state of Hubble and/or Hubble Relay by running cilium status:

If Hubble Relay is enabled, cilium status should display: OK. Otherwise, we should expect to see errors/warnings reported:

If warnings or errors are reported for both Cilium and Hubble Relay, it often hints at a misconfiguration in Hubble or the Hubble system failing to start. Since Hubble is a non-critical system running in the Cilium Agent, it is expected for the Cilium pods to remain running and healthy even when Hubble fails to start. See the Hubble section below for Hubble-specific troubleshooting steps.

Verify the state of the pods with:

If one or more pods are in Pending state, describe the pod(s) with:

If one or more pods are not in Running state, look at the pod(s) logs with:

If you face a connection refused error, it means that Hubble-Relay can’t connect to the Hubble API exposed by Cilium agents through the hubble-peer service. See the Hubble section below for Hubble-specific troubleshooting steps.

For TLS related errors, see Hubble TLS Troubleshooting.

If Hubble is enabled, cilium status should display: OK for Cilium. Otherwise, we should expect to see errors/warnings reported:

Verify the state of the pods with:

If one or more pods are in Pending state, describe the pod(s) with:

If one or more pods are not in Running state, look at the pod(s) logs with:

Inspecting Network Flows with the CLI

Service Map & Hubble UI

Configure TLS with Hubble

---

## Troubleshooting — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/operations/troubleshooting/

**Contents:**
- Troubleshooting
- Component & Cluster Health
  - Kubernetes
    - Detailed Status
    - Logs
  - Generic
- Observing Flows with Hubble
  - Ensure Hubble is running correctly
  - Observing flows of a specific pod
- Observing flows with Hubble Relay

This document describes how to troubleshoot Cilium in different deployment modes. It focuses on a full deployment of Cilium within a datacenter or public cloud. If you are just looking for a simple way to experiment, we highly recommend trying out the Getting Started guide instead.

This guide assumes that you have read the Networking Concepts and Securing Networks with Cilium which explain all the components and concepts.

We use GitHub issues to maintain a list of Cilium Frequently Asked Questions (FAQ). You can also check there to see if your question(s) is already addressed.

An initial overview of Cilium can be retrieved by listing all pods to verify whether all pods have the status Running:

If Cilium encounters a problem that it cannot recover from, it will automatically report the failure state via cilium-dbg status which is regularly queried by the Kubernetes liveness probe to automatically restart Cilium pods. If a Cilium pod is in state CrashLoopBackoff then this indicates a permanent failure scenario.

If a particular Cilium pod is not in running state, the status and health of the agent on that node can be retrieved by running cilium-dbg status in the context of that pod:

Alternatively, the k8s-cilium-exec.sh script can be used to run cilium-dbg status on all nodes. This will provide detailed status and health information of all nodes in the cluster:

… and run cilium-dbg status on all nodes:

Detailed information about the status of Cilium can be inspected with the cilium-dbg status --verbose command. Verbose output includes detailed IPAM state (allocated addresses), Cilium controller status, and details of the Proxy status.

To retrieve log files of a cilium pod, run (replace cilium-1234 with a pod name returned by kubectl -n kube-system get pods -l k8s-app=cilium)

If the cilium pod was already restarted due to the liveness problem after encountering an issue, it can be useful to retrieve the logs of the pod before the last restart:

When logged in a host running Cilium, the cilium CLI can be invoked directly, e.g.:

Hubble is a built-in observability tool which allows you to inspect recent flow events on all endpoints managed by Cilium.

To ensure the Hubble client can connect to the Hubble server running inside Cilium, you may use the hubble status command from within a Cilium pod:

cilium-agent must be running with the --enable-hubble option (default) in order for the Hubble server to be enabled. When deploying Cilium with Helm, make sure to set the hubble.enabled=true value.

To check if Hubble is enabled in your deployment, you may look for the following output in cilium-dbg status:

Pods need to be managed by Cilium in order to be observable by Hubble. See how to ensure a pod is managed by Cilium for more details.

In order to observe the traffic of a specific pod, you will first have to retrieve the name of the cilium instance managing it. The Hubble CLI is part of the Cilium container image and can be accessed via kubectl exec. The following query for example will show all events related to flows which either originated or terminated in the default/tiefighter pod in the last three minutes:

You may also use -o json to obtain more detailed information about each flow event.

Hubble Relay allows you to query multiple Hubble instances simultaneously without having to first manually target a specific node. See Observing flows with Hubble Relay for more information.

Hubble Relay is a service which allows to query multiple Hubble instances simultaneously and aggregate the results. See Setting up Hubble Observability to enable Hubble Relay if it is not yet enabled and install the Hubble CLI on your local machine.

The following commands use the -P (--port-forward) flag to automatically port-forward the Hubble Relay service from your local machine on port 4245.

You can also omit the flag and create a port-forward manually with the Cilium CLI:

For more information on this method, see Use Port Forwarding to Access Application in a Cluster.

You can verify that Hubble Relay can be reached by using the Hubble CLI and running the following command from your local machine:

This command should return an output similar to the following:

You may see details about nodes that Hubble Relay is connected to by running the following command:

As Hubble Relay shares the same API as individual Hubble instances, you may follow the Observing flows with Hubble section keeping in mind that limitations with regards to what can be seen from individual Hubble instances no longer apply.

The Cilium connectivity test deploys a series of services, deployments, and CiliumNetworkPolicy which will use various connectivity paths to connect to each other. Connectivity paths include with and without service load-balancing and various network policy combinations.

The connectivity tests this will only work in a namespace with no other pods or network policies applied. If there is a Cilium Clusterwide Network Policy enabled, that may also break this connectivity check.

To run the connectivity tests create an isolated test namespace called cilium-test to deploy the tests with.

The tests cover various functionality of the system. Below we call out each test type. If tests pass, it suggests functionality of the referenced subsystem.

Pod-to-pod (intra-host)

Pod-to-pod (inter-host)

Pod-to-service (intra-host)

Pod-to-service (inter-host)

Pod-to-external resource

eBPF routing is functional

Data plane, routing, network

eBPF service map lookup

VXLAN overlay port if used

Egress, CiliumNetworkPolicy, masquerade

The pod name indicates the connectivity variant and the readiness and liveness gate indicates success or failure of the test:

Information about test failures can be determined by describing a failed test pod

Cilium can rule out network fabric related issues when troubleshooting connectivity issues by providing reliable health and latency probes between all cluster nodes and a simulated workload running on each node.

By default when Cilium is run, it launches instances of cilium-health in the background to determine the overall connectivity status of the cluster. This tool periodically runs bidirectional traffic across multiple paths through the cluster and through each node using different protocols to determine the health status of each path and protocol. At any point in time, cilium-health may be queried for the connectivity status of the last probe.

For each node, the connectivity will be displayed for each protocol and path, both to the node itself and to an endpoint on that node. The latency specified is a snapshot at the last time a probe was run, which is typically once per minute. The ICMP connectivity row represents Layer 3 connectivity to the networking stack, while the HTTP connectivity row represents connection to an instance of the cilium-health agent running on the host or as an endpoint.

Sometimes you may experience broken connectivity, which may be due to a number of different causes. A main cause can be unwanted packet drops on the networking level. The tool cilium-dbg monitor allows you to quickly inspect and see if and where packet drops happen. Following is an example output (use kubectl exec as in previous examples if running with Kubernetes):

The above indicates that a packet to endpoint ID 25729 has been dropped due to violation of the Layer 3 policy.

If connectivity fails and cilium-dbg monitor --type drop shows xx drop (CT: Map insertion failed), then it is likely that the connection tracking table is filling up and the automatic adjustment of the garbage collector interval is insufficient.

Setting --conntrack-gc-interval to an interval lower than the current value may help. This controls the time interval between two garbage collection runs.

By default --conntrack-gc-interval is set to 0 which translates to using a dynamic interval. In that case, the interval is updated after each garbage collection run depending on how many entries were garbage collected. If very few or no entries were garbage collected, the interval will increase; if many entries were garbage collected, it will decrease. The current interval value is reported in the Cilium agent logs.

Alternatively, the value for bpf-ct-global-any-max and bpf-ct-global-tcp-max can be increased. Setting both of these options will be a trade-off of CPU for conntrack-gc-interval, and for bpf-ct-global-any-max and bpf-ct-global-tcp-max the amount of memory consumed. You can track conntrack garbage collection related metrics such as datapath_conntrack_gc_runs_total and datapath_conntrack_gc_entries to get visibility into garbage collection runs. Refer to Monitoring & Metrics for more details.

By default, datapath debug messages are disabled, and therefore not shown in cilium-dbg monitor -v output. To enable them, add "datapath" to the debug-verbose option.

A potential cause for policy enforcement not functioning as expected is that the networking of the pod selected by the policy is not being managed by Cilium. The following situations result in unmanaged pods:

The pod is running in host networking and will use the host’s IP address directly. Such pods have full network connectivity but Cilium will not provide security policy enforcement for such pods by default. To enforce policy against these pods, either set hostNetwork to false or use Host Policies.

The pod was started before Cilium was deployed. Cilium only manages pods that have been deployed after Cilium itself was started. Cilium will not provide security policy enforcement for such pods. These pods should be restarted in order to ensure that Cilium can provide security policy enforcement.

If pod networking is not managed by Cilium. Ingress and egress policy rules selecting the respective pods will not be applied. See the section Overview of Network Policy for more details.

For a quick assessment of whether any pods are not managed by Cilium, the Cilium CLI will print the number of managed pods. If this prints that all of the pods are managed by Cilium, then there is no problem:

You can run the following script to list the pods which are not managed by Cilium:

There are always multiple ways to approach a problem. Cilium can provide the rendering of the aggregate policy provided to it, leaving you to simply compare with what you expect the policy to actually be rather than search (and potentially overlook) every policy. At the expense of reading a very large dump of an endpoint, this is often a faster path to discovering errant policy requests in the Kubernetes API.

Start by finding the endpoint you are debugging from the following list. There are several cross references for you to use in this list, including the IP address and pod labels:

When you find the correct endpoint, the first column of every row is the endpoint ID. Use that to dump the full endpoint information:

Importing this dump into a JSON-friendly editor can help browse and navigate the information here. At the top level of the dump, there are two nodes of note:

spec: The desired state of the endpoint

status: The current state of the endpoint

This is the standard Kubernetes control loop pattern. Cilium is the controller here, and it is iteratively working to bring the status in line with the spec.

Opening the status, we can drill down through policy.realized.l4. Do your ingress and egress rules match what you expect? If not, the reference to the errant rules can be found in the derived-from-rules node.

The most important step in debugging policymap pressure is finding out which node(s) are impacted.

The cilium_bpf_map_pressure{map_name="cilium_policy_v2_*"} metric monitors the endpoint’s BPF policymap pressure. This metric exposes the maximum BPF map pressure on the node, meaning the policymap experiencing the most pressure on a particular node.

Once the node is known, the troubleshooting steps are as follows:

Find the Cilium pod on the node experiencing the problematic policymap pressure and obtain a shell via kubectl exec.

Use cilium policy selectors to get an overview of which selectors are selecting many identities.

The type of selector tells you what sort of policy rule could be having an impact. The three existing types of selectors are explained below, each with specific steps depending on the selector. See the steps below corresponding to the type of selector.

Consider bumping the policymap size as a last resort. However, keep in mind the following implications:

Increased memory consumption for each policymap.

Generally, as identities increase in the cluster, the more work Cilium performs.

At a broader level, if the policy posture is such that all or nearly all identities are selected, this suggests that the posture is too permissive.

Form in cilium policy selectors output

&LabelSelector{MatchLabels:map[string]string{cidr.1.1.1.1/32: ,}

MatchName: , MatchPattern: *

&LabelSelector{MatchLabels:map[string]string{any.name: curl,k8s.io.kubernetes.pod.namespace: default,}

An example output of cilium policy selectors:

From the output above, we see that all three selectors are in use. The significant action here is to determine which selector is selecting the most identities, because the policy containing that selector is the likely cause for the policymap pressure.

See section on identity-relevant labels.

Another aspect to consider is the permissiveness of the policies and whether it could be reduced.

One way to reduce the number of identities selected by a CIDR selector is to broaden the range of the CIDR, if possible. For example, in the above example output, the policy contains a /32 rule for each CIDR, rather than using a wider range like /30 instead. Updating the policy with this rule creates an identity that represents all IPs within the /30 and therefore, only requires the selector to select 1 identity.

See section on isolating the source of toFQDNs issues regarding identities and policy.

Cilium can be operated in CRD-mode and kvstore/etcd mode. When cilium is running in kvstore/etcd mode, the kvstore becomes a vital component of the overall cluster health as it is required to be available for several operations.

Operations for which the kvstore is strictly required when running in etcd mode:

As part of scheduling workloads/endpoints, agents will perform security identity allocation which requires interaction with the kvstore. If a workload can be scheduled due to re-using a known security identity, then state propagation of the endpoint details to other nodes will still depend on the kvstore and thus packets drops due to policy enforcement may be observed as other nodes in the cluster will not be aware of the new workload.

All state propagation between clusters depends on the kvstore.

New nodes require to register themselves in the kvstore.

The Cilium agent will eventually fail if it can’t connect to the kvstore at bootstrap time, however, the agent will still perform all possible operations while waiting for the kvstore to appear.

Operations which do not require kvstore availability:

All datapath forwarding, policy enforcement and visibility functions for existing workloads/endpoints do not depend on the kvstore. Packets will continue to be forwarded and network policy rules will continue to be enforced.

However, if the agent requires to restart as part of the Recovery behavior, there can be delays in:

processing of flow events and metrics

short unavailability of layer 7 proxies

Network policy updates will continue to be processed and applied.

All updates to services will be processed and applied.

The etcd status is reported when running cilium-dbg status. The following line represents the status of etcd:

The overall status. Either OK or Failure.

Number of total etcd endpoints and how many of them are reachable.

UUID of the lease used for all keys owned by this agent.

UUID of the lease used for locks acquired by this agent.

Status of etcd quorum. Either true or set to an error.

Number of consecutive quorum errors. Only printed if errors are present.

List of all etcd endpoints stating the etcd version and whether the particular endpoint is currently the elected leader. If an etcd endpoint cannot be reached, the error is shown.

In the event of an etcd endpoint becoming unhealthy, etcd should automatically resolve this by electing a new leader and by failing over to a healthy etcd endpoint. As long as quorum is preserved, the etcd cluster will remain functional.

In addition, Cilium performs a background check in an interval to determine etcd health and potentially take action. The interval depends on the overall cluster size. The larger the cluster, the longer the interval:

If no etcd endpoints can be reached, Cilium will report failure in cilium-dbg status. This will cause the liveness and readiness probe of Kubernetes to fail and Cilium will be restarted.

A lock is acquired and released to test a write operation which requires quorum. If this operation fails, loss of quorum is reported. If quorum fails for three or more intervals in a row, Cilium is declared unhealthy.

The Cilium operator will constantly write to a heartbeat key (cilium/.heartbeat). All Cilium agents will watch for updates to this heartbeat key. This validates the ability for an agent to receive key updates from etcd. If the heartbeat key is not updated in time, the quorum check is declared to have failed and Cilium is declared unhealthy after 3 or more consecutive failures.

Example of a status with a quorum failure which has not yet reached the threshold:

Example of a status with the number of quorum failures exceeding the threshold:

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

Validate that Cilium pods are healthy and ready:

Validate that Cluster Mesh is enabled and operational:

In case of errors, run the troubleshoot command to automatically investigate Cilium agents connectivity issues towards the ClusterMesh control plane in remote clusters:

The troubleshoot command performs a set of automatic checks to validate DNS resolution, network connectivity, TLS authentication, etcd authorization and more, and reports the output in a user friendly format.

When KVStoreMesh is enabled, the output of the troubleshoot command refers to the connections from the agents to the local cache, and it is expected to be the same for all the clusters they are connected to. Run the troubleshoot command inside the clustermesh-apiserver to investigate KVStoreMesh connectivity issues towards the ClusterMesh control plane in remote clusters:

You can specify one or more cluster names as parameters of the troubleshoot command to run the checks only towards a subset of remote clusters.

As an alternative to leveraging the tools presented in the previous section, you may perform the following steps to troubleshoot ClusterMesh issues.

Validate that each cluster is assigned a unique human-readable name as well as a numeric cluster ID (1-255).

Validate that the clustermesh-apiserver is initialized correctly for each cluster:

Validate that ClusterMesh is healthy running cilium-dbg status --all-clusters inside each Cilium agent:

When KVStoreMesh is enabled, additionally check its status and validate that it is correctly connected to all remote clusters:

Validate that the required TLS secrets are set up properly. By default, the following TLS secrets must be available in the namespace in which Cilium is installed:

clustermesh-apiserver-server-cert, which is used by the etcd container in the clustermesh-apiserver deployment. Not applicable if an external etcd cluster is used.

clustermesh-apiserver-admin-cert, which is used by the apiserver/kvstoremesh containers in the clustermesh-apiserver deployment, to authenticate against the sidecar etcd instance. Not applicable if an external etcd cluster is used.

clustermesh-apiserver-remote-cert, which is used by Cilium agents, or the kvstoremesh container in the clustermesh-apiserver deployment when KVStoreMesh is enabled, to authenticate against remote etcd instances.

clustermesh-apiserver-local-cert, which is used by Cilium agents to authenticate against the local etcd instance. Only applicable if KVStoreMesh is enabled.

Validate that the configuration for remote clusters is picked up correctly. For each remote cluster, an info log message New remote cluster configuration along with the remote cluster name must be logged in the cilium-agent logs.

If the configuration is not found, check the following:

The cilium-clustermesh Kubernetes secret is present and correctly mounted by the Cilium agent pods.

The secret contains a file for each remote cluster with the filename matching the name of the remote cluster as provided by the --cluster-name argument or the cluster-name ConfigMap option.

Each file named after a remote cluster contains a valid etcd configuration consisting of the endpoints to reach the remote etcd cluster, and the path of the certificate and private key to authenticate against that etcd cluster. Additional files may be included in the secret to provide the certificate and private key themselves.

The /var/lib/cilium/clustermesh directory inside any of the Cilium agent pods contains the files mounted from the cilium-clustermesh secret. You can use kubectl exec -ti -n kube-system ds/cilium -c cilium-agent -- ls /var/lib/cilium/clustermesh to list the files present.

Validate that the connection to the remote cluster could be established. You will see a log message like this in the cilium-agent logs for each remote cluster:

If the connection failed, you will see a warning like this:

If the connection fails, check the following:

When KVStoreMesh is disabled, validate that the hostAliases section in the Cilium DaemonSet maps each remote cluster to the IP of the LoadBalancer that makes the remote control plane available; When KVStoreMesh is enabled, validate the hostAliases section in the clustermesh-apiserver Deployment.

Validate that a local node in the source cluster can reach the IP specified in the hostAliases section. When KVStoreMesh is disabled, the cilium-clustermesh secret contains a configuration file for each remote cluster, it will point to a logical name representing the remote cluster; When KVStoreMesh is enabled, it exists in the cilium-kvstoremesh secret.

The name will NOT be resolvable via DNS outside the Cilium agent pods. The name is mapped to an IP using hostAliases. Run kubectl -n kube-system get daemonset cilium -o yaml when KVStoreMesh is disabled, or run kubectl -n kube-system get deployment clustermesh-apiserver -o yaml when KVStoreMesh is enabled, grep for the FQDN to retrieve the IP that is configured. Then use curl to validate that the port is reachable.

A firewall between the local cluster and the remote cluster may drop the control plane connection. Ensure that port 2379/TCP is allowed.

Run cilium-dbg node list in one of the Cilium pods and validate that it lists both local nodes and nodes from remote clusters. If remote nodes are not present, validate that Cilium agents (or KVStoreMesh, if enabled) are correctly connected to the given remote cluster. Additionally, verify that the initial nodes synchronization from all clusters has completed.

Validate the connectivity health matrix across clusters by running cilium-health status inside any Cilium pod. It will list the status of the connectivity health check to each remote node. If this fails, make sure that the network allows the health checking traffic as specified in the Firewall Rules section.

Validate that identities are synchronized correctly by running cilium-dbg identity list in one of the Cilium pods. It must list identities from all clusters. You can determine what cluster an identity belongs to by looking at the label io.cilium.k8s.policy.cluster. If remote identities are not present, validate that Cilium agents (or KVStoreMesh, if enabled) are correctly connected to the given remote cluster. Additionally, verify that the initial identities synchronization from all clusters has completed.

Validate that the IP cache is synchronized correctly by running cilium-dbg bpf ipcache list or cilium-dbg map get cilium_ipcache. The output must contain pod IPs from local and remote clusters. If remote IP addresses are not present, validate that Cilium agents (or KVStoreMesh, if enabled) are correctly connected to the given remote cluster. Additionally, verify that the initial IPs synchronization from all clusters has completed.

When using global services, ensure that global services are configured with endpoints from all clusters. Run cilium-dbg service list in any Cilium pod and validate that the backend IPs consist of pod IPs from all clusters running relevant backends. You can further validate the correct datapath plumbing by running cilium-dbg bpf lb list to inspect the state of the eBPF maps.

Run cilium-dbg debuginfo and look for the section k8s-service-cache. In that section, you will find the contents of the service correlation cache. It will list the Kubernetes services and endpoints of the local cluster. It will also have a section externalEndpoints which must list all endpoints of remote clusters.

The sections services and endpoints represent the services of the local cluster, the section externalEndpoints lists all remote services and will be correlated with services matching the same ServiceID.

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

Validate that the ds/cilium as well as the deployment/cilium-operator pods are healthy and ready.

Validate that nodePort.enabled is true.

Validate that runtime the values of enable-envoy-config and enable-ingress-controller are true. Ingress controller flag is optional if customer only uses CiliumEnvoyConfig or CiliumClusterwideEnvoyConfig CRDs.

Internally, the Cilium Ingress controller will create one Load Balancer service, one CiliumEnvoyConfig and one dummy Endpoint resource for each Ingress resource.

Validate that the Load Balancer service has either an external IP or FQDN assigned. If it’s not available after a long time, please check the Load Balancer related documentation from your respective cloud provider.

Check if there is any warning or error message while Cilium is trying to provision the CiliumEnvoyConfig resource. This is unlikely to happen for CEC resources originating from the Cilium Ingress controller.

Note that these Envoy resources are not validated by K8s at all, so any errors in the Envoy resources will only be seen by the Cilium Agent observing these CRDs. This means that kubectl apply will report success, while parsing and/or installing the resources for the node-local Envoy instance may have failed. Currently the only way of verifying this is by observing Cilium Agent logs for errors and warnings. Additionally, Cilium Agent will print warning logs for any conflicting Envoy resources in the cluster.

Note that Cilium Ingress Controller will configure required Envoy resource under the hood. Please check Cilium Agent logs if you are creating Envoy resources explicitly to make sure there is no conflict.

This section is for troubleshooting connectivity issues mainly for Ingress resources, but the same steps can be applied to manually configured CiliumEnvoyConfig resources as well.

It’s best to have debug and debug-verbose enabled with below values. Kindly note that any change of Cilium flags requires a restart of the Cilium agent and operator.

The originating source IP is used for enforcing ingress traffic.

The request normally traverses from LoadBalancer service to pre-assigned port of your node, then gets forwarded to the Cilium Envoy proxy, and finally gets proxied to the actual backend service.

The first step between cloud Load Balancer to node port is out of Cilium scope. Please check related documentation from your respective cloud provider to make sure your clusters are configured properly.

The second step could be checked by connecting with SSH to your underlying host, and sending the similar request to localhost on the relevant port:

Alternatively, you can also send a request directly to the Envoy proxy port. For Ingress, the proxy port is randomly assigned by the Cilium Ingress controller. For manually configured CiliumEnvoyConfig resources, the proxy port is retrieved directly from the spec.

If you see a response similar to the above, it means that the request is being redirected to proxy successfully. The http response will have one special header server: envoy accordingly. The same can be observed from hubble observe command Observing Flows with Hubble.

The most common root cause is either that the Cilium Envoy proxy is not running on the node, or there is some other issue with CEC resource provisioning.

Assuming that the above steps are done successfully, you can proceed to send a request via an external IP or via FQDN next.

Double-check whether your backend service is up and healthy. The Envoy Discovery Service (EDS) has a name that follows the convention <namespace>/<service-name>:<port>.

If everything is configured correctly, you will be able to see the flows from world (identity 2), ingress (identity 8) and your backend pod as per below.

Endpoint to endpoint communication on a single node succeeds but communication fails between endpoints across multiple nodes.

Run cilium-health status --verbose on the node of the source and destination endpoint. It should describe the connectivity from that node to other nodes in the cluster, and to a simulated endpoint on each other node. Identify points in the cluster that cannot talk to each other. If the command does not describe the status of the other node, there may be an issue with the KV-Store.

Run cilium-dbg monitor on the node of the source and destination endpoint. Look for packet drops.

When running in Encapsulation mode:

Run cilium-dbg bpf tunnel list and verify that each Cilium node is aware of the other nodes in the cluster. If not, check the logfile for errors.

If nodes are being populated correctly, run tcpdump -n -i cilium_vxlan on each node to verify whether cross node traffic is being forwarded correctly between nodes.

If packets are being dropped,

verify that the node IP listed in cilium-dbg bpf tunnel list can reach each other.

verify that the firewall on each node allows UDP port 8472.

When running in Native-Routing mode:

Run ip route or check your cloud provider router and verify that you have routes installed to route the endpoint prefix between all nodes.

Verify that the firewall on each node permits to route the endpoint IPs.

Identifies the Cilium pod that is managing a particular pod in a namespace:

Run a command within all Cilium pods of a cluster

Lists all Kubernetes pods in the cluster for which Cilium does not provide networking. This includes pods running in host-networking mode and pods that were started before Cilium was deployed.

Before you report a problem, make sure to retrieve the necessary information from your cluster before the failure state is lost.

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

Then, execute cilium sysdump command to collect troubleshooting information from your Kubernetes cluster:

Note that by default cilium sysdump will attempt to collect as much logs as possible and for all the nodes in the cluster. If your cluster size is above 20 nodes, consider setting the following options to limit the size of the sysdump. This is not required, but useful for those who have a constraint on bandwidth or upload size.

set the --node-list option to pick only a few nodes in case the cluster has many of them.

set the --logs-since-time option to go back in time to when the issues started.

set the --logs-limit-bytes option to limit the size of the log files (note: passed onto kubectl logs; does not apply to entire collection archive).

Ideally, a sysdump that has a full history of select nodes, rather than a brief history of all the nodes, would be preferred (by using --node-list). The second recommended way would be to use --logs-since-time if you are able to narrow down when the issues started. Lastly, if the Cilium agent and Operator logs are too large, consider --logs-limit-bytes.

Use --help to see more options:

If you are not running Kubernetes, it is also possible to run the bug collection tool manually with the scope of a single node:

The cilium-bugtool captures potentially useful information about your environment for debugging. The tool is meant to be used for debugging a single Cilium agent node. In the Kubernetes case, if you have multiple Cilium pods, the tool can retrieve debugging information from all of them. The tool works by archiving a collection of command output and files from several places. By default, it writes to the tmp directory.

Note that the command needs to be run from inside the Cilium pod/container.

When running it with no option as shown above, it will try to copy various files and execute some commands. If kubectl is detected, it will search for Cilium pods. The default label being k8s-app=cilium, but this and the namespace can be changed via k8s-namespace and k8s-label respectively.

If you want to capture the archive from a Kubernetes pod, then the process is a bit different

Please check the archive for sensitive information and strip it away before sharing it with us.

Below is an approximate list of the kind of information in the archive.

Resolve configuration

Cilium endpoint state

kubectl -n kube-system get pods

kubectl get pods,svc for all namespaces

cilium-dbg bpf * list

cilium-dbg endpoint get for each endpoint

cilium-dbg endpoint list

cilium-dbg policy get

cilium-dbg service list

If you are not running Kubernetes, you can use the cilium-dbg debuginfo command to retrieve useful debugging information. If you are running Kubernetes, this command is automatically run as part of the system dump.

cilium-dbg debuginfo can print useful output from the Cilium API. The output format is in Markdown format so this can be used when reporting a bug on the issue tracker. Running without arguments will print to standard output, but you can also redirect to a file like

Please check the debuginfo file for sensitive information and strip it away before sharing it with us.

The Cilium Slack community is a helpful first point of assistance to get help troubleshooting a problem or to discuss options on how to address a problem. The community is open to anyone.

If you believe to have found an issue in Cilium, please report a GitHub issue and make sure to attach a system dump as described above to ensure that developers have the best chance to reproduce the issue.

---

## Upgrade Guide — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/operations/upgrade/

**Contents:**
- Upgrade Guide
- Running pre-flight check (Required)
  - Clean up pre-flight check
- Upgrading Cilium
  - Step 1: Upgrade to latest patch version
  - Step 2: Use Helm to Upgrade your Cilium deployment
  - Step 3: Rolling Back
- Version Specific Notes
  - 1.18 Upgrade Notes
    - Removed Options

This upgrade guide is intended for Cilium running on Kubernetes. If you have questions, feel free to ping us on Cilium Slack.

Read the full upgrade guide to understand all the necessary steps before performing them.

Do not upgrade to 1.18 before reading the section 1.18 Upgrade Notes and completing the required steps. Skipping this step may lead to an non-functional upgrade.

The only tested rollback and upgrade path is between consecutive minor releases. Always perform rollbacks and upgrades between one minor release at a time. This means that going from (a hypothetical) 1.1 to 1.2 and back is supported while going from 1.1 to 1.3 and back is not.

Always update to the latest patch release of your current version before attempting an upgrade.

When rolling out an upgrade with Kubernetes, Kubernetes will first terminate the pod followed by pulling the new image version and then finally spin up the new image. In order to reduce the downtime of the agent and to prevent ErrImagePull errors during upgrade, the pre-flight check pre-pulls the new image version. If you are running in Kubernetes Without kube-proxy mode you must also pass on the Kubernetes API Server IP and / or the Kubernetes API Server Port when generating the cilium-preflight.yaml file.

After applying the cilium-preflight.yaml, ensure that the number of READY pods is the same number of Cilium pods running.

Once the number of READY pods are equal, make sure the Cilium pre-flight deployment is also marked as READY 1/1. If it shows READY 0/1, consult the CNP Validation section and resolve issues with the deployment before continuing with the upgrade.

Once the number of READY for the preflight DaemonSet is the same as the number of cilium pods running and the preflight Deployment is marked as READY 1/1 you can delete the cilium-preflight and proceed with the upgrade.

During normal cluster operations, all Cilium components should run the same version. Upgrading just one of them (e.g., upgrading the agent without upgrading the operator) could result in unexpected cluster behavior. The following steps will describe how to upgrade all of the components from one stable release to a later stable release.

Read the full upgrade guide to understand all the necessary steps before performing them.

Do not upgrade to 1.18 before reading the section 1.18 Upgrade Notes and completing the required steps. Skipping this step may lead to an non-functional upgrade.

The only tested rollback and upgrade path is between consecutive minor releases. Always perform rollbacks and upgrades between one minor release at a time. This means that going from (a hypothetical) 1.1 to 1.2 and back is supported while going from 1.1 to 1.3 and back is not.

Always update to the latest patch release of your current version before attempting an upgrade.

When upgrading from one minor release to another minor release, for example 1.x to 1.y, it is recommended to upgrade to the latest patch release for a Cilium release series first. Upgrading to the latest patch release ensures the most seamless experience if a rollback is required following the minor release upgrade. The upgrade guides for previous versions can be found for each minor version at the bottom left corner.

Helm can be used to either upgrade Cilium directly or to generate a new set of YAML files that can be used to upgrade an existing deployment via kubectl. By default, Helm will generate the new templates using the default values files packaged with each new release. You still need to ensure that you are specifying the equivalent options as used for the initial deployment, either by specifying a them at the command line or by committing the values to a YAML file.

Setup Helm repository:

To minimize datapath disruption during the upgrade, the upgradeCompatibility option should be set to the initial Cilium version which was installed in this cluster.

Generate the required YAML file and deploy it:

Deploy Cilium release via Helm:

Instead of using --set, you can also save the values relative to your deployment in a YAML file and use it to regenerate the YAML for the latest Cilium version. Running any of the previous commands will overwrite the existing cluster’s ConfigMap so it is critical to preserve any existing options, either by setting them at the command line or storing them in a YAML file, similar to:

You can then upgrade using this values file by running:

When upgrading from one minor release to another minor release using helm upgrade, do not use Helm’s --reuse-values flag. The --reuse-values flag ignores any newly introduced values present in the new release and thus may cause the Helm template to render incorrectly. Instead, if you want to reuse the values from your existing installation, save the old values in a values file, check the file for any renamed or deprecated values, and then pass it to the helm upgrade command as described above. You can retrieve and save the values from an existing installation with the following command:

The --reuse-values flag may only be safely used if the Cilium chart version remains unchanged, for example when helm upgrade is used to apply configuration changes without upgrading Cilium.

Occasionally, it may be necessary to undo the rollout because a step was missed or something went wrong during upgrade. To undo the rollout run:

This will revert the latest changes to the Cilium DaemonSet and return Cilium to the state it was in prior to the upgrade.

When rolling back after new features of the new minor version have already been consumed, consult the Version Specific Notes to check and prepare for incompatible feature use before downgrading/rolling back. This step is only required after new functionality introduced in the new minor version has already been explicitly used by creating new resources or by opting into new features via the ConfigMap.

This section details the upgrade notes specific to 1.18. Read them carefully and take the suggested actions before upgrading Cilium to 1.18. For upgrades to earlier releases, see the upgrade notes to the previous version.

The only tested upgrade and rollback path is between consecutive minor releases. Always perform upgrades and rollbacks between one minor release at a time. Additionally, always update to the latest patch release of your current version before attempting an upgrade.

Tested upgrades are expected to have minimal to no impact on new and existing connections matched by either no Network Policies, or L3/L4 Network Policies only. Any traffic flowing via user space proxies (for example, because an L7 policy is in place, or using Ingress/Gateway API) will be disrupted during upgrade. Endpoints communicating via the proxy must reconnect to re-establish connections.

cilium-dbg bpf policy now prints ANY and not reserved:unknown for a bpf policy entry that allows any peer identity.

The v2alpha1 version of CiliumBGPClusterConfig, CiliumBGPPeerConfig, CiliumBGPAdvertisement, CiliumBGPNodeConfig and CiliumBGPNodeConfigOverride CRDs was deprecated in favor of the v2 version. Change apiVersion: cilium.io/v2alpha1 to apiVersion: cilium.io/v2 for these CRDs in all your BGP configs. The previously deprecated field spec.transport.localPort in CiliumBGPPeerConfig has been removed and will be ignored if it was configured in the v2alpha1 version.

The CiliumBGPPeeringPolicy CRD is deprecated and will be removed in a future release. Please migrate to cilium.io/v2 BGP CRDs (CiliumBGPClusterConfig, CiliumBGPPeerConfig, CiliumBGPAdvertisement, CiliumBGPNodeConfigOverride) to configure BGP.

The v2alpha1 version of CiliumCIDRGroup CRD was deprecated in favor of the v2 version. Change apiVersion: cilium.io/v2alpha1 to apiVersion: cilium.io/v2 for all CiliumCIDRGroup resources.

The check for connectivity to the Kubernetes apiserver has been removed from the cilium-agent liveness probe. This can be turned back on by setting the helm option livenessProbe.requireK8sConnectivity to true.

The label io.cilium.k8s.policy.serviceaccount will be included in the default label list. If you configure your own identity-relevant labels on your cluster, the number of identities will temporarily increase during the upgrade, which will result in increased drops. If you would like to disable this new behavior, you can add !io\.cilium\.k8s\.policy\.serviceaccount to your identity-relevant labels to exclude the io.cilium.k8s.policy.serviceaccount label.

If using IPsec encryption the upgrade from v1.17 to v1.18 requires special attention. Please reference IPsec Transparent Encryption.

If using an IPsec deployment within a Google Cloud GKE cluster the default firewall rules for the cluster’s subnet must be updated to allow ESP traffic. See IPsec Transparent Encryption for details.

The Helm value of enableIPv4Masquerade in eni mode changes from true to false by default from 1.18. To keep the enableIPv4Masquerade enabled, explicitly set the value for this option to true, or use a value strictly lower than 1.18 for upgradeCompatibility.

This Cilium version now requires a v5.10 Linux kernel or newer.

CiliumIdentity CRD does not contain Security Labels in metadata anymore except for the namespace label.

The support for Envoy Go Extensions (proxylib) is deprecated, and will be removed in a future release.

The kube_proxy_healthz endpoint no longer requires Kubernetes control plane connectivity to succeed.

In a Cluster Mesh environment, network policy ingress and egress selectors currently select by default endpoints from all clusters unless one or more clusters are explicitly specified in the policy itself. The new policy-default-local-cluster flag allows to change this behavior, and only select endpoints from the local cluster, unless explicitly specified, to improve the default security posture. This option is intended to become the default in Cilium v1.19. If you are using Cilium ClusterMesh and network policies, you need to take action to update your network policies to avoid this change from breaking connectivity for applications across different clusters. There is no need to do anything for the Cilium 1.17 to 1.18 upgrade, but it is strongly recommended to check Preparing for a policy-default-local-cluster change for details and migration recommendations to update your network policies in advance for the Cilium 1.19 upgrade.

Creating or deleting policies via the local REST api is deprecated. This will be removed entirely in v1.19.

The cilium operator now needs the ec2:DescribeRouteTables IAM action permission when used in ENI mode.

The previously deprecated high-scale mode for ipcache has been removed.

The previously deprecated hubble-relay flag --dial-timeout has been removed.

The previously deprecated External Workloads feature has been removed. To remove stale resources, run kubectl delete crd ciliumexternalworkloads.cilium.io. In addition, you might want to delete a K8s secret used by External Workloads. Run kubectl -n kube-system get secrets to find one.

The previously deprecated --datapath-mode=lb-only for plain Docker mode has been removed.

The update-ec2-adapter-limit-via-api CLI flag for the operator has been removed since the operator will only and always use the EC2API to update the EC2 instance limit.

The aws-instance-limit-mapping CLI flag for the operator has been removed since the operator will only and always use the EC2API to update the EC2 instance limit.

The previously deprecated flag --enable-k8s-terminating-endpoint has been removed. The K8s terminating endpoints feature is unconditionally enabled.

The previously deprecated CONNTRACK_LOCAL option has been removed

The previously deprecated enableRuntimeDeviceDetection option has been removed

The previously deprecated and ignored operator flags ces-write-qps-limit, ces-write-qps-burst, ces-enable-dynamic-rate-limit, ces-dynamic-rate-limit-nodes, ces-dynamic-rate-limit-qps-limit, ces-dynamic-rate-limit-qps-burst have been removed.

The arping-refresh-period option has been removed. Cilium will now refresh neighbor entries based on the base_reachable_time_ms sysctl value associated with that entry.

Operator flag ces-slice-mode has been deprecated and will be removed in Cilium 1.19. CiliumEndpointSlice batching mode defaults to first-come-first-serve mode.

The flag value --datapath-mode=lb-only for plain Docker mode has been migrated into --bpf-lb-only and will be removed in Cilium 1.19.

k8s-api-server: This option has been deprecated in favor of k8s-api-server-urls and will be removed in Cilium 1.19.

--l2-pod-announcements-interface has been deprecated in favor of --l2-pod-announcements-interface-pattern and will be removed in Cilium 1.19.

The flag --enable-session-affinity (sessionAffinity in Helm) has been deprecated and will be removed in Cilium 1.19. The Session Affinity feature will be unconditionally enabled. Also, in Cilium 1.18, the feature is enabled by default.

The custom calls feature (--enable-custom-calls) has been deprecated, and will be removed in Cilium 1.19.

The flag --bpf-lb-proto-diff has been deprecated and will be removed in Cilium 1.19. Service protocol differentiation will be unconditionally enabled.

The flags --enable-recorder, --enable-hubble-recorder-api, --hubble-recorder-storage-path and --hubble-recorder-sink-queue-size have been deprecated. The Hubble Recorder feature will be removed in Cilium 1.19. You can use pwru with --filter-trace-xdp to trace XDP requests.

The flags --enable-node-port (nodePort.enabled in Helm), --enable-host-port, --enable-external-ips have been deprecated and will be removed in Cilium 1.19. The kube-proxy replacement features will be only enabled when --kube-proxy-replacent is set to true.

The flag --enable-k8s-endpoint-slice have been deprecated and will be removed in Cilium 1.19. The K8s Endpoint Slice feature will be unconditionally enabled.

The flag --enable-internal-traffic-policy (enableInternalTrafficPolicy in Helm) has been deprecated and will be removed in Cilium 1.19. The internalTrafficPolicy field in a Kubernetes Service object will be unconditionally respected.

The flag --enable-svc-source-range-check (svcSourceRangeCheck in Helm) has been deprecated and will be removed in Cilium 1.19. The feature will be enabled automatically when --kube-proxy-replacent is set to true.

The flag --egress-multi-home-ip-rule-compat and the old IP rule scheme has been deprecated and will be removed in Cilium 1.19. Running Cilium 1.18 with the flag set to false (default value) will migrate any existing IP rules to the new scheme.

The flag --enable-ipv4-egress-gateway has been deprecated in favor of --enable-egress-gateway and will be removed in Cilium 1.19.

The Helm options hubble.export.fileMaxSizeMb, hubble.export.fileMaxBackups and hubble.export.fileCompress have been deprecated in favor of their corresponding exporter type options and will be removed in Cilium 1.19. More specifically, the static exporter options are now located under hubble.export.static and the dynamic exporter options that generate a configmap containing the exporter configuration are now under hubble.export.dynamic.config.content.

The Helm option ciliumEndpointSlice.sliceMode has been removed. The slice mode defaults to first-come-first-serve mode.

The Helm chart now defaults to enabling exponential backoff for client-go by setting the environment variables KUBE_CLIENT_BACKOFF_BASE and KUBE_CLIENT_BACKOFF_DURATION on the Cilium daemonset. These can be customized using helm values k8sClientExponentialBackoff.backoffBaseSeconds and k8sClientExponentialBackoff.backoffMaxDurationSeconds. Users who were already setting these using extraEnv should either remove them from extraEnv or set k8sClientExponentialBackoff.enabled=false.

The deprecated Helm option hubble.relay.dialTimeout has been removed.

The new Helm option underlayProtocol allows selecting the IP family for the underlay. It defaults to IPv4.

k8s.apiServerURLs has been introduced to specify multiple Kubernetes API servers so that the agent can fail over to an active instance.

eni.updateEC2AdapterLimitViaAPI is removed since the operator will only and always use the EC2API to update the EC2 instance limit.

The Helm option l2PodAnnouncements.interface has been deprecated in favor of l2PodAnnouncements.interfacePattern and will be removed in Cilium 1.19.

The Helm value of enableIPv4Masquerade in eni mode changes from true to false by default from 1.18.

The Helm option clustermesh.apiserver.kvstoremesh.enabled has been deprecated and will be removed in Cilium 1.19. Starting from 1.19 KVStoreMesh will be unconditionally enabled when the Cluster Mesh API Server is enabled.

The l2NeighDiscovery.refreshPeriod option has been removed. Cilium will now refresh neighbor entries based on the base_reachable_time_ms sysctl value associated with that entry.

The l2NeighDiscovery.enabled option has been changed to default to false.

The deprecated Helm option enableCiliumEndpointSlice has been removed. Set ciliumEndpointSlice.enabled instead to enable CiliumEndpointSlices.

localRedirectPolicy helm option has been deprecated. Set localRedirectPolicies.enabled instead.

The new localRedirectPolicies.addressMatcherCIDRs option can be used to limit what addresses are allowed in an address match of a CiliumLocalRedirectPolicy.

node-role.kubernetes.io/control-plane , node-role.kubernetes.io/master , node.kubernetes.io/not-ready and node.cilium.io/agent-not-ready. This will block the operator running on drained nodes.

The new agent flag underlay-protocol allows selecting the IP family for the underlay. It defaults to IPv4.

k8s-api-server-urls: This option specifies a list of URLs for Kubernetes API server instances to support high availability for the servers. The agent will fail over to an active instance in case of connectivity failures at runtime.

The --enable-l2-neigh-discovery flag has been changed to default to false.

The kvstore-connectivity-timeout flag is renamed to identity-allocation-timeout to better reflect its purpose.

The kvstore-periodic-sync flag is renamed to identity-allocation-sync-interval to better reflect its purpose.

The previously unused kvstore-connectivity-timeout and kvstore-periodic-sync flags have been removed from the apiserver and kvstoremesh commands.

The deprecated flag k8s-mode (and related flags cilium-agent-container-name, k8s-namespace & k8s-label) have been removed. Cilium CLI should be used to gather a sysdump from a K8s cluster.

The following deprecated metrics were removed:

node_connectivity_status

node_connectivity_latency_seconds

doublewrite_identity_crd_total_count has been renamed to doublewrite_crd_identities

doublewrite_identity_kvstore_total_count has been renamed to doublewrite_kvstore_identities

doublewrite_identity_crd_only_count has been renamed to doublewrite_crd_only_identities

doublewrite_identity_kvstore_only_count has been renamed to doublewrite_kvstore_only_identities

The type of the cilium_agent_bootstrap_seconds metric has been changed from histogram to gauge.

cilium_agent_bgp_control_plane_reconcile_error_count has been renamed to cilium_agent_bgp_control_plane_reconcile_errors_total.

cilium_operator_bgp_control_plane_cluster_config_error_count has been renamed to cilium_operator_bgp_control_plane_reconcile_errors_total and its label bgp_cluster_config has been replaced with labels resource_kind and resource_name.

Upgrades are designed to have minimal impact on your running deployment. Networking connectivity, policy enforcement and load balancing will remain functional in general. The following is a list of operations that will not be available during the upgrade:

API-aware policy rules are enforced in user space proxies and are running as part of the Cilium pod. Upgrading Cilium causes the proxy to restart, which results in a connectivity outage and causes the connection to reset.

Existing policy will remain effective but implementation of new policy rules will be postponed to after the upgrade has been completed on a particular node.

Monitoring components such as cilium-dbg monitor will experience a brief outage while the Cilium pod is restarting. Events are queued up and read after the upgrade. If the number of events exceeds the event buffer size, events will be lost.

Beginning with Cilium 1.6, Kubernetes CRD-backed security identities can be used for smaller clusters. Along with other changes in 1.6, this allows kvstore-free operation if desired. It is possible to migrate identities from an existing kvstore deployment to CRD-backed identities. This minimizes disruptions to traffic as the update rolls out through the cluster.

When identities change, existing connections can be disrupted while Cilium initializes and synchronizes with the shared identity store. The disruption occurs when new numeric identities are used for existing pods on some instances and others are used on others. When converting to CRD-backed identities, it is possible to pre-allocate CRD identities so that the numeric identities match those in the kvstore. This allows new and old Cilium instances in the rollout to agree.

There are two ways to achieve this: you can either run a one-off cilium preflight migrate-identity script which will perform a point-in-time copy of all identities from the kvstore to CRDs (added in Cilium 1.6), or use the “Double Write” identity allocation mode which will have Cilium manage identities in both the kvstore and CRD at the same time for a seamless migration (added in Cilium 1.17).

The cilium preflight migrate-identity script is a one-off tool that can be used to copy identities from the kvstore into CRDs. It has a couple of limitations:

If an identity is created in the kvstore after the one-off migration has been completed, it will not be copied into a CRD. This means that you need to perform the migration on a cluster with no identity churn.

There is no easy way to revert back to --identity-allocation-mode=kvstore if something goes wrong after Cilium has been migrated to --identity-allocation-mode=crd

If these limitations are not acceptable, it is recommended to use the “Double Write” identity allocation mode instead.

The following steps show an example of performing the migration using the cilium preflight migrate-identity script. It is safe to re-run the command if desired. It will identify already allocated identities or ones that cannot be migrated. Note that identity 34815 is migrated, 17003 is already migrated, and 11730 has a conflict and a new ID allocated for those labels.

The steps below assume a stable cluster with no new identities created during the rollout. Once Cilium using CRD-backed identities is running, it may begin allocating identities in a way that conflicts with older ones in the kvstore.

The cilium preflight manifest requires etcd support and can be built with:

It is also possible to use the --k8s-kubeconfig-path and --kvstore-opt cilium CLI options with the preflight command. The default is to derive the configuration as cilium-agent does.

Once the migration is complete, confirm the endpoint identities match by listing the endpoints stored in CRDs and in etcd:

If a migration has gone wrong, it possible to start with a clean slate. Ensure that no Cilium instances are running with --identity-allocation-mode=crd and execute:

This is a beta feature. Please provide feedback and file a GitHub issue if you experience any problems.

The “Double Write” Identity Allocation Mode allows Cilium to allocate identities as KVStore values and as CRDs at the same time. This mode also has two versions: one where the source of truth comes from the kvstore (--identity-allocation-mode=doublewrite-readkvstore), and one where the source of truth comes from CRDs (--identity-allocation-mode=doublewrite-readcrd).

The high-level migration plan looks as follows:

Starting state: Cilium is running in KVStore mode.

Switch Cilium to “Double Write” mode with all reads happening from the KVStore. This is almost the same as the pure KVStore mode with the only difference being that all identities are duplicated as CRDs but are not used.

Switch Cilium to “Double Write” mode with all reads happening from CRDs. This is equivalent to Cilium running in pure CRD mode but identities will still be updated in the KVStore to allow for the possibility of a fast rollback.

Switch Cilium to CRD mode. The KVStore will no longer be used and will be ready for decommission.

This will allow you to perform a gradual and seamless migration with the possibility of a fast rollback at steps two or three.

Furthermore, when the “Double Write” mode is enabled, the Operator will emit additional metrics to help monitor the migration progress. These metrics can be used for alerting about identity inconsistencies between the KVStore and CRDs.

Note that you can also use this to migrate from CRD to KVStore mode. All operations simply need to be repeated in reverse order.

Re-deploy first the Operator and then the Agents with --identity-allocation-mode=doublewrite-readkvstore.

Monitor the Operator metrics and logs to ensure that all identities have converged between the KVStore and CRDs. The relevant metrics emitted by the Operator are:

cilium_operator_identity_crd_total_count and cilium_operator_identity_kvstore_total_count report the total number of identities in CRDs and KVStore respectively.

cilium_operator_identity_crd_only_count and cilium_operator_identity_kvstore_only_count report the number of identities that are only in CRDs or only in the KVStore respectively, to help detect inconsistencies.

In case further investigation is needed, the Operator logs will contain detailed information about the discrepancies between KVStore and CRD identities. Note that Garbage Collection for KVStore identities and CRD identities happens at slightly different times, so it is possible to see discrepancies in the metrics for certain periods of time, depending on --identity-gc-interval and --identity-heartbeat-timeout settings.

Once all identities have converged, re-deploy the Operator and the Agents with --identity-allocation-mode=doublewrite-readcrd. This will cause Cilium to read identities only from CRDs, but continue to write them to the KVStore.

Once you are ready to decommission the KVStore, re-deploy first the Agents and then the Operator with --identity-allocation-mode=crd. This will make Cilium read and write identities only to CRDs.

You can now decommission the KVStore.

Cilium network policies used to implicitly select endpoints from all the clusters. Cilium 1.18 introduced a new option called policy-default-local-cluster which will be set by default in Cilium 1.19. This option restricts endpoints selection to the local cluster by default. If you are using ClusterMesh and network policies this will be a breaking change and you need to take action before upgrading to Cilium 1.19.

This new option can be set in the ConfigMap or via the Helm value clustermesh.policyDefaultLocalCluster. You can set policy-default-local-cluster to false in Cilium 1.19 to keep the existing behavior, however this option will be deprecated and eventually removed in a future release so you should plan your migration to set policy-default-local-cluster to true.

The command cilium clustermesh inspect-policy-default-local-cluster --all-namespaces can help you discover all the policies that will change as a result of changing policy-default-local-cluster. You can also replace --all-namespaces with -n my-namespace if you want to only inspect policies from a particular namespace.

Below is an example where there is one network policy that needs to be updated:

In this situation you have only one CiliumNetworkPolicy which is affected by a policy-default-local-cluster change. Let’s take a look at the policy:

This network policy does not explicitly select a cluster. This means that with policy-default-local-cluster set to false it allows traffic coming from bar in any clusters connected in your ClusterMesh. With policy-default-local-cluster set to true, this policy allows traffic from bar from only the local cluster instead.

If foo and bar are always in the same cluster, no further action is necessary.

In case you want to do this on this individual policy rather than at a global level or that bar is located on a remote cluster you can update your policy like that:

If bar is located in multiple cluster you can also use a matchExpressions selecting multiple clusters like that:

Alternatively, you can also allow traffic from bar located in every cluster and restore the same behavior as setting policy-default-local-cluster to false but on this individual policy:

Running the CNP Validator will make sure the policies deployed in the cluster are valid. It is important to run this validation before an upgrade so it will make sure Cilium has a correct behavior after upgrade. Avoiding doing this validation might cause Cilium from updating its NodeStatus in those invalid Network Policies as well as in the worst case scenario it might give a false sense of security to the user if a policy is badly formatted and Cilium is not enforcing that policy due a bad validation schema. This CNP Validator is automatically executed as part of the pre-flight check Running pre-flight check (Required).

Start by deployment the cilium-pre-flight-check and check if the Deployment shows READY 1/1, if it does not check the pod logs.

In this example, we can see the CiliumNetworkPolicy in the default namespace with the name cnp-update is not valid for the Cilium version we are trying to upgrade. In order to fix this policy we need to edit it, we can do this by saving the policy locally and modify it. For this example it seems the .spec.labels has set an array of strings which is not correct as per the official schema.

To fix this policy we need to set the .spec.labels with the right format and commit these changes into Kubernetes.

After applying the fixed policy we can delete the pod that was validating the policies so that Kubernetes creates a new pod immediately to verify if the fixed policies are now valid.

Once they are valid you can continue with the upgrade process. Clean up pre-flight check

---

## Command Cheatsheet — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/cheatsheet/

**Contents:**
- Command Cheatsheet
- Command utilities:
  - JSON Output
  - Shell Tab-completion
- Command examples:
  - Basics
  - Policy management
    - Monitoring
  - Connectivity
  - Endpoints

Cilium is controlled via an easy command-line interface. This CLI is a single application that takes subcommands that you can find in the command reference guide.

All commands and subcommands have the option -h that will provide information about the options and arguments that the subcommand has. In case of any error in the command, Cilium CLI will return a non-zero status.

All the list commands will return a pretty printed list with the information retrieved from Cilium Daemon. If you need something more detailed you can use JSON output, to get the JSON output you can use the global option -o json

Moreover, Cilium also provides a JSONPath support, so detailed information can be extracted. JSONPath template reference can be found in Kubernetes documentation

If you use bash or zsh, Cilium CLI can provide tab completion for subcommands. If you want to install tab completion, you should run the following command in your terminal.

If you want to have Cilium completion always loaded, you can install using the following:

Check the status of the agent

Get a detailed status of the agent:

Get the current agent configuration

Importing a Cilium Network Policy

Get list of all imported policy rules

Monitor cilium-dbg datapath notifications

Verbose output (including debug if enabled)

Extra verbose output (including packet dissection)

Filter for only the events related to endpoint

Filter for only events on layer 7

Show notifications only for dropped packet events

Don’t dissect packet payload, display payload in hex information

Check cluster Connectivity

There is also a blog post related to this tool.

Get list of all local endpoints

Get detailed view of endpoint properties and state

Show recent endpoint specific log entries

Enable debugging output on the cilium-dbg monitor for this endpoint

Get list of loadbalancer services

Or you can get the loadbalancer information using bpf list

List node tunneling mapping information

Checking logs for verifier issue

List connection tracking entries:

Flush connection tracking entries:

If you running Cilium on top of Kubernetes you may also want a way to list all cilium endpoints or policies from a single Kubectl commands. Cilium provides all this information to the user by using Kubernetes Resource Definitions:

In Kubernetes you can use two kinds of policies, Kubernetes Network Policies or Cilium Network Policies. Both can be retrieved from the kubectl command:

To retrieve a list of all endpoints managed by cilium, Cilium Endpoint resource can be used.

---

## Service Map & Hubble UI — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/observability/hubble/hubble-ui/

**Contents:**
- Service Map & Hubble UI
- Enable the Hubble UI
- Open the Hubble UI
- Inspecting a wide variety of network traffic

This tutorial guides you through enabling the Hubble UI to access the graphical service map.

This guide assumes that Cilium and Hubble have been correctly installed in your Kubernetes cluster. Please see Cilium Quick Installation and Setting up Hubble Observability for more information. If unsure, run cilium status and validate that Cilium and Hubble are installed.

Enable the Hubble UI by running the following command:

If Hubble is already enabled with cilium hubble enable, you must first temporarily disable Hubble with cilium hubble disable. This is because the Hubble UI cannot be added at runtime.

Clusters sometimes come with Cilium, Hubble, and Hubble relay already installed. When this is the case you can still use Helm to install only Hubble UI on top of the pre-installed components.

You will need to set hubble.ui.standalone.enabled to true and optionally provide a volume to mount Hubble UI client certificates if TLS is enabled on Hubble Relay server side.

Below is an example deploying Hubble UI as standalone, with client certificates mounted from a my-hubble-ui-client-certs secret:

Please note that Hubble UI expects the certificate files to be available under the following paths:

Keep this in mind when providing the volume containing the certificate.

Open the Hubble UI in your browser by running cilium hubble ui. It will automatically set up a port forward to the hubble-ui service in your Kubernetes cluster and make it available on a local port on your machine.

The above command will block and continue running while the port forward is active. You can interrupt the command to abort the port forward and re-run the command to make the UI accessible again.

If your browser has not automatically opened the UI, open the page http://localhost:12000 in your browser. You should see a screen with an invitation to select a namespace, use the namespace selector dropdown on the left top corner to select a namespace:

In this example, we are deploying the Star Wars demo from the Identity-Aware and HTTP-Aware Policy Enforcement guide. However you can apply the same techniques to observe application connectivity dependencies in your own namespace, and clusters for application of any type.

Once the deployment is ready, issue a request from both spaceships to emulate some traffic.

These requests will then be displayed in the UI as service dependencies between the different pods:

In the bottom of the interface, you may also inspect each recent Hubble flow event in your current namespace individually.

In order to generate some network traffic, run the connectivity test in a loop:

To see the traffic in Hubble, open http://localhost:12000/cilium-test in your browser.

---

## Roadmap — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/community/roadmap/

**Contents:**
- Roadmap
- Release Cadence
  - Focus Areas
- Welcoming New Contributors

The Cilium project is community driven, thus the work that gets done and the project’s future roadmap is determined by what work individuals decide to do.

You are welcome to raise feature requests by creating them as GitHub issues. Please search the existing issues to avoid raising duplicates, if you find that someone else is making the same or similar request we encourage the use of GitHub emojis to express your support for an idea!

The most active way to influence the capabilities in Cilium is to get involved in development. We label issues with good-first-issue to help new potential contributors find issues and feature requests that are relatively self-contained and could be a good place to start. Please also read the Development for details of our pull request process and expectations, along with instructions for setting up your development environment.

We encourage you to discuss your ideas for significant enhancements and feature requests on the #development channel on Cilium Slack, bring them to the Community Meetings, and/or create a CFP design doc.

The project does not give date commitments since the work is dependent on the community. If you’re looking for commitments to apply engineering resources to work on particular features, one option is to discuss this with the companies who offer commercial distributions of Cilium and may be able to help.

We aim to make 2 to 3 point releases per year of Cilium and its core components (Hubble, Cilium CLI, Tetragon, etc.). We also make patch releases available as necessary for security or urgent fixes.

For a finer-granularity view, and insight into detailed enhancements and fixes, please refer to issues on GitHub. The Cilium committers are the main drivers of where the project is heading.

As a CNCF project we want to make it easier for new contributors to get involved with Cilium. This includes both code and non-code contributions such as documentation, blog posts, example configurations, presentations, training courses, testing and more. Check the Development documentation to understand how to get involved with code contributions, and the Get Involved guide for guidance on contributing blog posts, training and other resources.

---

## Per-node configuration — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/configuration/per-node-config/

**Contents:**
- Per-node configuration
- CiliumNodeConfig objects
- Example: selective XDP enablement
- Example: KubeProxyReplacement Rollout

The Cilium agent process (a.k.a. DaemonSet) supports setting configuration on a per-node basis. This allows overriding cilium-config ConfigMap for a node or set of nodes. It is managed by CiliumNodeConfig objects.

This feature is useful for:

Gradually rolling out changes.

Selectively enabling features that require specific hardware:

LoadBalancer & NodePort XDP Acceleration

A CiliumNodeConfig object allows for overriding ConfigMap / Agent arguments. It consists of a set of fields and a label selector. The label selector defines to which nodes the configuration applies. As is the standard with Kubernetes, an empty LabelSelector (e.g. {}) selects all nodes.

Creating or modifying a CiliumNodeConfig will not cause changes to take effect until pods are deleted and re-created (or their node is restarted).

To enable LoadBalancer & NodePort XDP Acceleration only on nodes with necessary hardware, one would label the relevant nodes and override their configuration.

To roll out kube-proxy replacement in a gradual manner, you may also wish to use the CiliumNodeConfig feature. This will label all migrated nodes with io.cilium.migration/kube-proxy-replacement: true

You must have installed Cilium with the Helm values k8sServiceHost and k8sServicePort. Otherwise, Cilium will not be able to reach the Kubernetes APIServer after kube-proxy is uninstalled.

You can apply these two values to a running cluster via helm upgrade.

Patch kube-proxy to only run on unmigrated nodes.

Configure Cilium to use kube-proxy replacement on migrated nodes

Select a node to migrate. Optionally, cordon and drain that node:

Delete Cilium DaemonSet to reload configuration:

Ensure Cilium has the correct configuration:

Cleanup: set default to kube-proxy-replacement:

Cleanup: delete kube-proxy daemonset, unlabel nodes

---

## 

**URL:** https://docs.cilium.io/en/stable/_downloads/1bca8c3d8bb912f689017e7092afe682/CiliumFuzzingAudit2022.pdf

---

## Component Overview — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/overview/component-overview/

**Contents:**
- Component Overview
- Cilium
- Hubble
- eBPF
- Data Store

A deployment of Cilium and Hubble consists of the following components running in a cluster:

The Cilium agent (cilium-agent) runs on each node in the cluster. At a high-level, the agent accepts configuration via Kubernetes or APIs that describes networking, service load-balancing, network policies, and visibility & monitoring requirements.

The Cilium agent listens for events from orchestration systems such as Kubernetes to learn when containers or workloads are started and stopped. It manages the eBPF programs which the Linux kernel uses to control all network access in / out of those containers.

The Cilium debug CLI client (cilium-dbg) is a command-line tool that is installed along with the Cilium agent. It interacts with the REST API of the Cilium agent running on the same node. The debug CLI allows inspecting the state and status of the local agent. It also provides tooling to directly access the eBPF maps to validate their state.

The in-agent Cilium debug CLI client described here should not be confused with the `cilium command line tool for quick-installing, managing and troubleshooting Cilium on Kubernetes clusters <https://github.com/cilium/cilium-cli>`_. That tool is typically installed remote from the cluster, and uses kubeconfig information to access Cilium running on the cluster via the Kubernetes API.

The Cilium Operator is responsible for managing duties in the cluster which should logically be handled once for the entire cluster, rather than once for each node in the cluster. The Cilium operator is not in the critical path for any forwarding or network policy decision. A cluster will generally continue to function if the operator is temporarily unavailable. However, depending on the configuration, failure in availability of the operator can lead to:

Delays in IP Address Management (IPAM) and thus delay in scheduling of new workloads if the operator is required to allocate new IP addresses

Failure to update the kvstore heartbeat key which will lead agents to declare kvstore unhealthiness and restart.

The CNI plugin (cilium-cni) is invoked by Kubernetes when a pod is scheduled or terminated on a node. It interacts with the Cilium API of the node to trigger the necessary datapath configuration to provide networking, load-balancing and network policies for the pod.

The Hubble server runs on each node and retrieves the eBPF-based visibility from Cilium. It is embedded into the Cilium agent in order to achieve high performance and low-overhead. It offers a gRPC service to retrieve flows and Prometheus metrics.

Relay (hubble-relay) is a standalone component which is aware of all running Hubble servers and offers cluster-wide visibility by connecting to their respective gRPC APIs and providing an API that represents all servers in the cluster.

The Hubble CLI (hubble) is a command-line tool able to connect to either the gRPC API of hubble-relay or the local server to retrieve flow events.

The graphical user interface (hubble-ui) utilizes relay-based visibility to provide a graphical service dependency and connectivity map.

eBPF is a Linux kernel bytecode interpreter originally introduced to filter network packets, e.g. tcpdump and socket filters. It has since been extended with additional data structures such as hashtable and arrays as well as additional actions to support packet mangling, forwarding, encapsulation, etc. An in-kernel verifier ensures that eBPF programs are safe to run and a JIT compiler converts the bytecode to CPU architecture specific instructions for native execution efficiency. eBPF programs can be run at various hooking points in the kernel such as for incoming and outgoing packets.

Cilium is capable of probing the Linux kernel for available features and will automatically make use of more recent features as they are detected.

For more detail on kernel versions, see: Linux Kernel.

Cilium requires a data store to propagate state between agents. It supports the following data stores:

The default choice to store any data and propagate state is to use Kubernetes custom resource definitions (CRDs). CRDs are offered by Kubernetes for cluster components to represent configurations and state via Kubernetes resources.

All requirements for state storage and propagation can be met with Kubernetes CRDs as configured in the default configuration of Cilium. A key-value store can optionally be used as an optimization to improve the scalability of a cluster as change notifications and storage requirements are more efficient with direct key-value store usage.

The currently supported key-value stores are:

It is possible to leverage the etcd cluster of Kubernetes directly or to maintain a dedicated etcd cluster.

---

## Getting Help — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/gettingstarted/gettinghelp/

**Contents:**
- Getting Help
- FAQ
- Slack
- GitHub
- Training
- Enterprise support
- Security Bugs

Cilium is a project with a growing community. There are numerous ways to get help with Cilium if needed:

Cilium Frequently Asked Questions (FAQ): Cilium uses GitHub tags to maintain a list of questions asked by users. We suggest checking to see if your question is already answered.

Chat: The best way to get immediate help if you get stuck is to ask in one of the Cilium Slack channels.

Bug Tracker: All the issues are addressed in the GitHub issue tracker. If you want to report a bug or a new feature please file the issue according to the GitHub template.

Contributing: If you want to contribute, reading the Development should help you.

Training courses: Our website lists training courses that have been approved by the Cilium project.

Distributions: Enterprise-ready, supported and approved Cilium distributions are listed on the Cilium website.

Security: We strongly encourage you to report security vulnerabilities to our private security mailing list: security@cilium.io - first, before disclosing them in any public forums.

This is a private mailing list where only members of the Cilium internal security team are subscribed to, and is treated as top priority.

---

## Layer 7 Protocol Visibility — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/observability/visibility/

**Contents:**
- Layer 7 Protocol Visibility
- Security Implications
- Limitations

This feature requires enabling L7 Proxy support.

While Monitoring Datapath State provides introspection into datapath state, by default, it will only provide visibility into L3/L4 packet events. If you want L7 protocol visibility, you can use L7 Cilium Network Policies (see Layer 7 Examples).

To enable visibility for L7 traffic, create a CiliumNetworkPolicy that specifies L7 rules. Traffic flows matching a L7 rule in a CiliumNetworkPolicy will become visible to Cilium and, thus, can be exposed to the end user. It’s important to remember that L7 network policies not only enables visibility but also restrict what traffic is allowed to flow in and out of a Pod.

The following example enables visibility for DNS (TCP/UDP/53) and HTTP (ports TCP/80 and TCP/8080) traffic within the default namespace by specifying two L7 rules – one for DNS and one for HTTP. It also restricts egress communication and drops anything that is not matched. L7 matching conditions on the rules have been omitted or wildcarded, which will permit all requests that match the L4 section of each rule:

Based on the above policy, Cilium will pick up all TCP/UDP/53, TCP/80 and TCP/8080 egress traffic from Pods in the default namespace and redirect it to the proxy (see Proxy Injection) such that the output of cilium monitor or hubble observe shows the L7 flow details. Below is the example of running hubble observe -f -t l7 -o compact command:

Monitoring Layer 7 traffic involves security considerations for handling potentially sensitive information, such as usernames, passwords, query parameters, API keys, and others.

By default, Hubble does not redact potentially sensitive information present in Layer 7 Hubble Flows.

To harden security, Cilium provides the --hubble-redact-enabled option which enables Hubble to handle sensitive information present in Layer 7 flows. More specifically, it offers the following features for supported Layer 7 protocols:

For HTTP: redacting URL query (GET) parameters (--hubble-redact-http-urlquery)

For HTTP: redacting URL user info (for example, password used in basic auth) (--hubble-redact-http-userinfo)

For HTTP headers: redacting all headers except those defined in the --hubble-redact-http-headers-allow list or redacting only the headers defined in the --hubble-redact-http-headers-deny list

For more information on configuring Cilium, see Cilium Configuration.

DNS visibility is available on egress only.

L7 policies for SNATed IPv6 traffic (e.g., pod-to-world) require a kernel with the fix applied. The stable kernel versions with the fix are 6.14.1, 6.12.22, 6.6.86, 6.1.133, 5.15.180, 5.10.236. See GitHub issue 37932 for the reference.

---

## Internals — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/internals/

**Contents:**
- Internals

---

## Hubble internals — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/internals/hubble/

**Contents:**
- Hubble internals
- Hubble Architecture
  - Hubble server
    - The Observer service
    - The Peer service
  - Hubble Relay

This documentation section is targeted at developers who are interested in contributing to Hubble. For this purpose, it describes Hubble internals.

This documentation covers the Hubble server (sometimes referred as “Hubble embedded”) and Hubble Relay components but does not cover the Hubble UI and CLI.

Hubble builds on top of Cilium and eBPF to enable deep visibility into the communication and behavior of services as well as the networking infrastructure in a completely transparent manner. One of the design goals of Hubble is to achieve all of this at large scale.

Hubble’s server component is embedded into the Cilium agent in order to achieve high performance with low-overhead. The gRPC services offered by Hubble server may be consumed locally via a Unix domain socket or, more typically, through Hubble Relay. Hubble Relay is a standalone component which is aware of all Hubble instances and offers full cluster visibility by connecting to their respective gRPC APIs. This capability is usually referred to as multi-node. Hubble Relay’s main goal is to offer a rich API that can be safely exposed and consumed by the Hubble UI and CLI.

Hubble exposes gRPC services from the Cilium process that allows clients to receive flows and other type of data.

The Hubble server component implements two gRPC services. The Observer service which may optionally be exposed via a TCP socket in addition to a local Unix domain socket and the Peer service, which is served on both as well as being exposed as a Kubernetes Service when enabled via TCP.

The Observer service is the principal service. It provides four RPC endpoints: GetFlows, GetNodes, GetNamespaces and ServerStatus.

GetNodes returns a list of metrics and other information related to each Hubble instance.

ServerStatus returns a summary of the information in GetNodes.

GetNamespaces returns a list of namespaces that had network flows within the last one hour.

GetFlows returns a stream of flow related events.

Using GetFlows, callers get a stream of payloads. Request parameters allow callers to specify filters in the form of allow lists and deny lists to provide fine-grained filtering of data. When multiple flow filters are provided, only one of them has to match for a flow to be included/excluded. When both allow and deny filters are specified, the result will contain all flows matched by the allow list that are not also simultaneously matched by the deny list.

In order to answer GetFlows requests, Hubble stores monitoring events from Cilium’s event monitor into a user-space ring buffer structure. Monitoring events are obtained by registering a new listener on Cilium monitor. The ring buffer is capable of storing a configurable amount of events in memory. Events are continuously consumed, overriding older ones once the ring buffer is full.

Additionally, the Observer service also provides the GetAgentEvents and GetDebugEvents RPC endpoints to expose data about the Cilium agent events and Cilium datapath debug events, respectively. Both are similar to GetFlows except they do not implement filtering capabilities.

For efficiency, the internal buffer length is a bit mask of ones + 1. The most significant bit of this bit mask is the same position of the most significant bit position of ‘n’. In other terms, the internal buffer size is always a power of 2 with 1 slot reserved for the writer. In effect, from a user perspective, the ring buffer capacity is one less than a power of 2. As the ring buffer is a hot code path, it has been designed to not employ any locking mechanisms and uses atomic operations instead. While this approach has performance benefits, it also has the downsides of being a complex component.

Due to its complex nature, the ring buffer is typically accessed via a ring reader that abstracts the complexity of this data structure for reading. The ring reader allows reading one event at the time with ‘previous’ and ‘next’ methods but also implements a follow mode where events are continuously read as they are written to the ring buffer.

The Peer service sends information about Hubble peers in the cluster in a stream. When the Notify method is called, it reports information about all the peers in the cluster and subsequently sends information about peers that are updated, added, or removed from the cluster. Thus, it allows the caller to keep track of all Hubble instances and query their respective gRPC services.

This service is exposed as a Kubernetes Service and is primarily used by Hubble Relay in order to have a cluster-wide view of all Hubble instances.

The Peer service obtains peer change notifications by subscribing to Cilium’s node manager. To this end, it internally defines a handler that implements Cilium’s datapath node handler interface.

Hubble Relay is the Hubble component that brings multi-node support. It leverages the Peer service to obtain information about Hubble instances and consume their gRPC API in order to provide a more rich API that covers events from across the entire cluster (or even multiple clusters in a ClusterMesh scenario).

Hubble Relay was first introduced as a technology preview with the release of Cilium v1.8 and was declared stable with the release of Cilium v1.9.

Hubble Relay implements the Observer service for multi-node. To that end, it maintains a persistent connection with every Hubble peer in a cluster with a peer manager. This component provides callers with the list of peers. Callers may report when a peer is unreachable, in which case the peer manager will attempt to reconnect.

As Hubble Relay connects to every node in a cluster, the Hubble server instances must make their API available (by default on port 4244). By default, Hubble server endpoints are secured using mutual TLS (mTLS) when exposed on a TCP port in order to limit access to Hubble Relay only.

---

## VLAN 802.1q support — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/configuration/vlan-802.1q/

**Contents:**
- VLAN 802.1q support

Cilium enables firewalling on native devices in use and will filter all unknown traffic. VLAN 802.1q packets will always be passed through their main device with associated tag (e.g. VLAN device is eth0.4000 and its main interface is eth0). By default, Cilium will allow all tags from the native devices (i.e. if eth0.4000 is controlled by Cilium and has an eBPF program attached, then VLAN tag 4000 will be allowed on device eth0). Additional VLAN tags may be allowed with the cilium-agent flag --vlan-bpf-bypass=4001,4002 (or Helm variable --set bpf.vlanBypass="[4001,4002]").

The list of allowed VLAN tags cannot be too big in order to keep eBPF program of predictable size. Currently this list should contain no more than 5 entries. If you need more, then there is only one way for now: you need to allow all tags with cilium-agent flag --vlan-bpf-bypass=0.

Currently, the cilium-agent will scan for available VLAN devices and tags only on startup.

---

## Performance & Scalability — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/operations/performance/

**Contents:**
- Performance & Scalability

Welcome to the performance and scalability guides. This section contains best-practices to tune various performance and scalability aspects. It also contains official benchmarks as measured by the development team in a standardized and repeatable bare metal environment.

---

## Further Reading — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/further_reading/

**Contents:**
- Further Reading
- Related Material
- Presentations
- Podcasts
- Community blog posts

BPF for security—and chaos—in Kubernetes

k8s-snowflake: Configs and scripts for bootstrapping an opinionated Kubernetes cluster anywhere using Cilium plugin

Using Cilium for NetworkPolicy: Kubernetes documentation on how to use Cilium to implement NetworkPolicy

Kubernetes on Edge Day, Europe 2022 - Connecting Klusters on the Edge with Deep Dive into Cilium Cluster Mesh: Video

Cloud Native Telco Day, Europe 2022 - Leveraging Cilium and SRv6 for Telco Networking: Video

KubeCon, Europe 2022 - A Guided Tour of Cilium Service Mesh: Video

eBPF Day, Europe, 2022 - IKEA Private Cloud, eBPF Based Networking, Load Balancing, and Observability with Cilium: Video

KubeCon, North America 2021 - Beyond printf & tcpdump: Debugging Kubernetes Networking with eBPF: Video

eBPF Summit, Virtual 2020 - Our eBPF Journey at Datadog: Video

eBPF Summit, Virtual 2020 - Building a Secure and Maintainable PaaS Leveraging Cilium: Video

eBPF Summit, Virtual 2020 - The Past, Present and Future of Cilium and Hubble at Palantir: Video

KubeCon, Europe 2020 - Hubble - eBPF Based Observability for Kubernetes: Video

Fosdem, Brussels, 2020 - BPF as a revolutionary technology for the container landscape: Slides, Video

KubeCon, North America 2019 - Understanding and Troubleshooting the eBPF Datapath in Cilium: Video

KubeCon, North America 2019 - Liberating Kubernetes from kube-proxy and iptables: Slides, Video

KubeCon, Europe 2019 - Using eBPF to Bring Kubernetes-Aware Security to the Linux Kernel: Video

KubeCon, Europe 2019 - Transparent Chaos Testing with Envoy , Cilium and BPF: Slides, Video

All Systems Go!, Berlin, Sept 2018 - Cilium - Bringing the BPF Revolution to Kubernetes Networking and Security Slides, Video

QCon, San Francisco 2018 - How to Make Linux Microservice-Aware with Cilium and eBPF: Slides, Video

KubeCon, North America 2018 - Connecting Kubernetes Clusters Across Cloud Providers: Slides, Video

KubeCon, North America 2018 - Implementing Least Privilege Security and Networking with BPF on Kubernetes: Slides, Video

KubeCon, Europe 2018 - Accelerating Envoy with the Linux Kernel: Video

Open Source Summit, North America - Cilium: Networking and security for containers with BPF and XDP: Video

DockerCon, Austin TX, Apr 2017 - Cilium - Network and Application Security with BPF and XDP: Slides, Video

CNCF/KubeCon Meetup, Berlin, Mar 2017 - Linux Native, HTTP Aware Network Security: Slides, Video

Docker Distributed Systems Summit, Berlin, Oct 2016: Slides, Video

NetDev1.2, Tokyo, Sep 2016 - cls_bpf/eBPF updates since netdev 1.1: Slides, Video

NetDev1.2, Tokyo, Sep 2016 - Advanced programmability and recent updates with tc’s cls_bpf: Slides, Video

ContainerCon NA, Toronto, Aug 2016 - Fast IPv6 container networking with BPF & XDP: Slides

Software Gone Wild by Ivan Pepelnjak, Oct 2016: Blog, MP3

OVS Orbit by Ben Pfaff, May 2016: Blog, MP3

Cilium for Network and Application Security with BPF and XDP, Apr 2017

Cilium, BPF and XDP, Google Open Source Blog, Nov 2016

---

## SCTP support (beta) — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/configuration/sctp/

**Contents:**
- SCTP support (beta)
- Enabling
- Limitations

This is a beta feature. Please provide feedback and file a GitHub issue if you experience any problems.

Pass --set sctp.enabled=true to helm.

You can also watch a video explanation of Cilium’s SCTP support in eCHO episode 78: Stream Control Transmission Protocol (SCTP).

Pod <-> Pod communication

Pod <-> Service communication [*]

Pod <-> Pod communication with network policies applied to SCTP traffic [*]

[*] SCTP support does not support rewriting ports for SCTP packets. This means that when defining services, the targetPort MUST equal the port, otherwise the packet will be dropped.

Policies for pod-to-VIP

Kube-proxy replacement (KPR) when port rewriting is necessary: for example, NodePort Services are not supported with the combination of KPR and SCTP.

---

## Governance — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/community/governance/

**Contents:**
- Governance

Governance documentation can be found in the Cilium Community repository.

---

## Tuning Guide — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/operations/performance/tuning/

**Contents:**
- Tuning Guide
- Recommendation
- netkit device mode
- eBPF Host-Routing
- IPv6 BIG TCP
- IPv4 BIG TCP
- Bypass iptables Connection Tracking
- Hubble
  - Increase Hubble Event Queue Size
  - Increase Aggregation Interval

This guide helps you optimize a Cilium installation for optimal performance.

The default out of the box deployment of Cilium is focused on maximum compatibility rather than most optimal performance. If you are a performance-conscious user, here are the recommended settings for operating Cilium to get the best out of your setup.

In-place upgrade by just enabling the config settings on an existing cluster is not possible since these tunings change the underlying datapath fundamentals and therefore require Pod or even node restarts.

The best way to consume this for an existing cluster is to utilize per-node configuration for enabling the tunings only on newly spawned nodes which join the cluster. See the Per-node configuration page for more details.

Each of the settings for the recommended performance profile are described in more detail on this page and in this KubeCon talk:

BIG TCP for IPv4/IPv6

Bandwidth Manager (optional, for BBR congestion control)

Per-CPU distributed LRU and increased map size ratio

eBPF clock probe to use jiffies for CT map

Supported NICs for BIG TCP: mlx4, mlx5, ice

To enable the main settings:

For enabling BBR congestion control in addition, consider adding the following settings to the above Helm install:

netkit devices provide connectivity for Pods with the goal to improve throughput and latency for applications as if they would have resided directly in the host namespace, meaning, it reduces the datapath overhead for network namespaces down to zero. The netkit driver in the kernel has been specifically designed for Cilium’s needs and replaces the old-style veth device type. See also the KubeCon talk on netkit for more details.

Cilium utilizes netkit in L3 device mode with blackholing traffic from the Pods when there is no BPF program attached. The Pod specific BPF programs are attached inside the netkit peer device, and can only be managed from the host namespace through Cilium. netkit in combination with eBPF-based host-routing achieves a fast network namespace switch for off-node traffic ingressing into the Pod or leaving the Pod. When netkit is enabled, Cilium also utilizes tcx for all attachments to non-netkit devices. This is done for higher efficiency as well as utilizing BPF links for all Cilium attachments. netkit is available for kernel 6.8 and onwards and it also supports BIG TCP. Once the base kernels become more ubiquitous, the veth device mode of Cilium will be deprecated.

To validate whether your installation is running with netkit, run cilium status in any of the Cilium Pods and look for the line reporting the status for “Device Mode” which should state “netkit”. Also, ensure to have eBPF host routing enabled - the reporting status under “Host Routing” must state “BPF”.

This is a beta feature. Please provide feedback and file a GitHub issue if you experience any problems. Known issues with this feature are tracked here.

In-place upgrade by just enabling netkit on an existing cluster is not possible since the CNI plugin cannot simply replace veth with netkit after Pod creation. Also, running both flavors in parallel is currently not supported.

The best way to consume this for an existing cluster is to utilize per-node configuration for enabling netkit on newly spawned nodes which join the cluster. See the Per-node configuration page for more details.

To enable netkit device mode with eBPF host-routing:

Even when network routing is performed by Cilium using eBPF, by default network packets still traverse some parts of the regular network stack of the node. This ensures that all packets still traverse through all of the iptables hooks in case you depend on them. However, they add significant overhead. For exact numbers from our test environment, see TCP Throughput (TCP_STREAM) and compare the results for “Cilium” and “Cilium (legacy host-routing)”.

We introduced eBPF-based host-routing in Cilium 1.9 to fully bypass iptables and the upper host stack, and to achieve a faster network namespace switch compared to regular veth device operation. This option is automatically enabled if your kernel supports it. To validate whether your installation is running with eBPF host-routing, run cilium status in any of the Cilium pods and look for the line reporting the status for “Host Routing” which should state “BPF”.

BPF host routing is incompatible with Istio (see GitHub issue 36022 for details).

eBPF-based kube-proxy replacement

eBPF-based masquerading

To enable eBPF Host-Routing:

eBPF host routing optimizes the host-internal packet routing, and packets no longer hit the netfilter tables in the host namespace. Therefore, it is incompatible with features relying on netfilter hooks (for example, GKE Workload Identities). Configure bpf.hostLegacyRouting=true or leverage Local Redirect Policy to work around this limitation.

IPv6 BIG TCP allows the network stack to prepare larger GSO (transmit) and GRO (receive) packets to reduce the number of times the stack is traversed which improves performance and latency. It reduces the CPU load and helps achieve higher speeds (i.e. 100Gbit/s and beyond).

To pass such packets through the stack BIG TCP adds a temporary Hop-By-Hop header after the IPv6 one which is stripped before transmitting the packet over the wire.

BIG TCP can operate in a DualStack setup, IPv4 packets will use the old lower limits (64k) if IPv4 BIG TCP is not enabled, and IPv6 packets will use the new larger ones (192k). Both IPv4 BIG TCP and IPv6 BIG TCP can be enabled so that both use the larger one (192k).

Note that Cilium assumes the default kernel values for GSO and GRO maximum sizes are 64k and adjusts them only when necessary, i.e. if BIG TCP is enabled and the current GSO/GRO maximum sizes are less than 192k it will try to increase them, respectively when BIG TCP is disabled and the current maximum values are more than 64k it will try to decrease them.

BIG TCP doesn’t require network interface MTU changes.

In-place upgrade by just enabling BIG TCP on an existing cluster is currently not possible since Cilium does not have access into Pods after they have been created.

The best way to consume this for an existing cluster is to either restart Pods or to utilize per-node configuration for enabling BIG TCP on newly spawned nodes which join the cluster. See the Per-node configuration page for more details.

eBPF-based kube-proxy replacement

eBPF-based masquerading

Tunneling and encryption disabled

Supported NICs: mlx4, mlx5, ice

To enable IPv6 BIG TCP:

Note that after toggling the IPv6 BIG TCP option the Kubernetes Pods must be restarted for the changes to take effect.

To validate whether your installation is running with IPv6 BIG TCP, run cilium status in any of the Cilium pods and look for the line reporting the status for “IPv6 BIG TCP” which should state “enabled”.

Similar to IPv6 BIG TCP, IPv4 BIG TCP allows the network stack to prepare larger GSO (transmit) and GRO (receive) packets to reduce the number of times the stack is traversed which improves performance and latency. It reduces the CPU load and helps achieve higher speeds (i.e. 100Gbit/s and beyond).

To pass such packets through the stack BIG TCP sets IPv4 tot_len to 0 and uses skb->len as the real IPv4 total length. The proper IPv4 tot_len is set before transmitting the packet over the wire.

BIG TCP can operate in a DualStack setup, IPv6 packets will use the old lower limits (64k) if IPv6 BIG TCP is not enabled, and IPv4 packets will use the new larger ones (192k). Both IPv4 BIG TCP and IPv6 BIG TCP can be enabled so that both use the larger one (192k).

Note that Cilium assumes the default kernel values for GSO and GRO maximum sizes are 64k and adjusts them only when necessary, i.e. if BIG TCP is enabled and the current GSO/GRO maximum sizes are less than 192k it will try to increase them, respectively when BIG TCP is disabled and the current maximum values are more than 64k it will try to decrease them.

BIG TCP doesn’t require network interface MTU changes.

In-place upgrade by just enabling BIG TCP on an existing cluster is currently not possible since Cilium does not have access into Pods after they have been created.

The best way to consume this for an existing cluster is to either restart Pods or to utilize per-node configuration for enabling BIG TCP on newly spawned nodes which join the cluster. See the Per-node configuration page for more details.

eBPF-based kube-proxy replacement

eBPF-based masquerading

Tunneling and encryption disabled

Supported NICs: mlx4, mlx5, ice

To enable IPv4 BIG TCP:

Note that after toggling the IPv4 BIG TCP option the Kubernetes Pods must be restarted for the changes to take effect.

To validate whether your installation is running with IPv4 BIG TCP, run cilium status in any of the Cilium pods and look for the line reporting the status for “IPv4 BIG TCP” which should state “enabled”.

For the case when eBPF Host-Routing cannot be used and thus network packets still need to traverse the regular network stack in the host namespace, iptables can add a significant cost. This traversal cost can be minimized by disabling the connection tracking requirement for all Pod traffic, thus bypassing the iptables connection tracker.

Direct-routing configuration

eBPF-based kube-proxy replacement

eBPF-based masquerading or no masquerading

To enable the iptables connection-tracking bypass:

Running with Hubble observability enabled can come at the expense of performance. The overhead of Hubble is somewhere between 1-15% depending on your network traffic patterns and Hubble aggregation settings.

In clusters with a huge amount of network traffic, cilium-agent might spend a significant portion of CPU time on processing monitored events and Hubble may even lose some events. There are multiple ways to tune Hubble to avoid this.

The Hubble Event Queue buffers events after they have been emitted from datapath and before they are processed by the Hubble subsystem. If this queue is full, because Hubble can’t keep up with the amount of emitted events, Cilium will start dropping events. This does not impact traffic, but the events won’t be processed by Hubble and won’t show up in Hubble flows or metrics.

When this happens you will see log lines similar to the following.

By default the Hubble event queue size is #CPU * 1024, or 16384 if your nodes have more than 16 CPU cores. If you encounter event bursts that result in dropped events, increasing this queue size might help. We recommend gradually doubling the queue length until the drops disappear. If you don’t see any improvements after increasing the queue length to 128k, further increasing the event queue size is unlikely to help.

Be aware that increasing the Hubble event queue size will result in increased memory usage. Depending on your traffic pattern, increasing the queue size by 10,000 may increase the memory usage by up to five Megabytes.

If only certain nodes are effected you may also set the queue length on a per-node basis using a CiliumNodeConfig object.

Increasing the Hubble event queue size can’t mitigate a consistently high rate of events being emitted by Cilium datapath and it does not reduce CPU utilization. For this you should consider increasing the aggregation interval or rate limiting events.

By default Cilium generates a tracing event for send packets only on every new connection, any time a packet contains TCP flags that have not been previously seen for the packet direction, and on average once per monitor-aggregation-interval, which defaults to 5 seconds.

Depending on your network traffic patterns, the re-emitting of trace events per aggregation interval can make up a large part of the total events. Increasing the aggregation interval may decrease CPU utilization and can prevent lost events.

The following will set the aggregation interval to 10 seconds.

To further prevent high CPU utilization caused by Hubble, you can also set limits on how many events can be generated by datapath code. Two limits are possible to configure:

Rate limit - limits how many events on average can be generated

Burst limit - limits the number of events that can be generated in a span of 1 second

When both limits are set to 0, no BPF events rate limiting is imposed.

Helm configuration for BPF events map rate limiting is experimental and might change in upcoming releases.

When BPF events map rate limiting is enabled, Cilium monitor, Hubble observability, Hubble metrics reliability, and Hubble export functionalities might be impacted due to dropped events.

To enable eBPF Event Rate Limiting with a rate limit of 10,000 and a burst limit of 50,000:

You can also choose to stop exposing event types in which you are not interested. For instance if you are mainly interested in dropped traffic, you can disable “trace” events which will likely reduce the overall CPU consumption of the agent.

Suppressing one or more event types will impact cilium monitor as well as Hubble observability capabilities, metrics and exports.

If all this is not sufficient, in order to optimize for maximum performance, you can disable Hubble:

The maximum transfer unit (MTU) can have a significant impact on the network throughput of a configuration. Cilium will automatically detect the MTU of the underlying network devices. Therefore, if your system is configured to use jumbo frames, Cilium will automatically make use of it.

To benefit from this, make sure that your system is configured to use jumbo frames if your network allows for it.

Cilium’s Bandwidth Manager is responsible for managing network traffic more efficiently with the goal of improving overall application latency and throughput.

Aside from natively supporting Kubernetes Pod bandwidth annotations, the Bandwidth Manager, first introduced in Cilium 1.9, is also setting up Fair Queue (FQ) queueing disciplines to support TCP stack pacing (e.g. from EDT/BBR) on all external-facing network devices as well as setting optimal server-grade sysctl settings for the networking stack.

eBPF-based kube-proxy replacement

To enable the Bandwidth Manager:

To validate whether your installation is running with Bandwidth Manager, run cilium status in any of the Cilium pods and look for the line reporting the status for “BandwidthManager” which should state “EDT with BPF”.

The base infrastructure around MQ/FQ setup provided by Cilium’s Bandwidth Manager also allows for use of TCP BBR congestion control for Pods. BBR is in particular suitable when Pods are exposed behind Kubernetes Services which face external clients from the Internet. BBR achieves higher bandwidths and lower latencies for Internet traffic, for example, it has been shown that BBR’s throughput can reach as much as 2,700x higher than today’s best loss-based congestion control and queueing delays can be 25x lower.

In order for BBR to work reliably for Pods, it requires a 5.18 or higher kernel. As outlined in our Linux Plumbers 2021 talk, this is needed since older kernels do not retain timestamps of network packets when switching from Pod to host network namespace. Due to the latter, the kernel’s pacing infrastructure does not function properly in general (not specific to Cilium). We helped fixing this issue for recent kernels to retain timestamps and therefore to get BBR for Pods working.

BBR also needs eBPF Host-Routing in order to retain the network packet’s socket association all the way until the packet hits the FQ queueing discipline on the physical device in the host namespace.

In-place upgrade by just enabling BBR on an existing cluster is not possible since Cilium cannot migrate existing sockets over to BBR congestion control.

The best way to consume this is to either only enable it on newly built clusters, to restart Pods on existing clusters, or to utilize per-node configuration for enabling BBR on newly spawned nodes which join the cluster. See the Per-node configuration page for more details.

Note that the use of BBR could lead to a higher amount of TCP retransmissions and more aggressive behavior towards TCP CUBIC connections.

To enable the Bandwidth Manager with BBR for Pods:

To validate whether your installation is running with BBR for Pods, run cilium status in any of the Cilium pods and look for the line reporting the status for “BandwidthManager” which should then state EDT with BPF as well as [BBR].

Cilium has built-in support for accelerating NodePort, LoadBalancer services and services with externalIPs for the case where the arriving request needs to be pushed back out of the node when the backend is located on a remote node.

In that case, the network packets do not need to be pushed all the way to the upper networking stack, but with the help of XDP, Cilium is able to process those requests right out of the network driver layer. This helps to reduce latency and scale-out of services given a single node’s forwarding capacity is dramatically increased. The kube-proxy replacement at the XDP layer is available from Cilium 1.8.

Kernel >= 4.19.57, >= 5.1.16, >= 5.2

Native XDP supported driver, check our driver list

eBPF-based kube-proxy replacement

To enable the XDP Acceleration, check out our getting started guide which also contains instructions for setting it up on public cloud providers.

To validate whether your installation is running with XDP Acceleration, run cilium status in any of the Cilium pods and look for the line reporting the status for “XDP Acceleration” which should say “Native”.

Changing Cilium’s core BPF map memory configuration from a node-global LRU memory pool to a distributed per-CPU memory pool helps to avoid spinlock contention in the kernel under stress (many CT/NAT element allocation and free operations).

The trade-off is higher memory usage given the per-CPU pools cannot be shared anymore, so if a given CPU pool depletes it needs to recycle elements via LRU mechanism. It is therefore recommended to not only enable bpf.distributedLRU.enabled but to also increase the map sizing which can be done via bpf.mapDynamicSizeRatio:

Note that bpf.distributedLRU.enabled is off by default in Cilium for legacy reasons given enabling this setting on-the-fly is disruptive for in-flight traffic since the BPF maps have to be recreated.

It is recommended to use the per-node configuration to gradually phase in this setting for new nodes joining the cluster. Alternatively, upon initial cluster creation it is recommended to consider enablement.

Also, bpf.distributedLRU.enabled is currently only supported in combination with bpf.mapDynamicSizeRatio as opposed to statically sized map configuration.

All eBPF maps are created with upper capacity limits. Insertion beyond the limit would fail or constrain the scalability of the datapath. Cilium is using auto-derived defaults based on the given ratio of the total system memory.

However, the upper capacity limits used by the Cilium agent can be overridden for advanced users. Please refer to the eBPF Maps guide.

Cilium can probe the underlying kernel to determine whether BPF supports retrieving jiffies instead of ktime. Given Cilium’s CT map does not require high resolution, jiffies is more efficient and the preferred clock source. To enable probing and possibly using jiffies, bpfClockProbe=true can be set:

Note that bpfClockProbe is off by default in Cilium for legacy reasons given enabling this setting on-the-fly means that previous stored CT map entries with ktime as clock source for timestamps would now be interpreted as jiffies.

It is therefore recommended to use the per-node configuration to gradually phase in this setting for new nodes joining the cluster. Alternatively, upon initial cluster creation it is recommended to consider enablement.

To validate whether jiffies is now used run cilium status --verbose in any of the Cilium Pods and look for the line Clock Source for BPF.

In general, we highly recommend using the most recent LTS stable kernel provided by the kernel community or by a downstream distribution of your choice. The newer the kernel, the more likely it is that various datapath optimizations can be used.

In our Cilium release blogs, we also regularly highlight some of the eBPF based kernel work we conduct which implicitly helps Cilium’s datapath performance such as replacing retpolines with direct jumps in the eBPF JIT.

Moreover, the kernel allows to configure several options which will help maximize network performance.

Run a kernel version with CONFIG_PREEMPT_NONE=y set. Some Linux distributions offer kernel images with this option set or you can re-compile the Linux kernel. CONFIG_PREEMPT_NONE=y is the recommended setting for server workloads.

By default, the cilium daemonset is configured with an inter-pod anti-affinity rule. Inter-pod anti-affinity is not recommended for clusters larger than several hundred nodes as it reduces scheduling throughput of kube-scheduler.

If your cilium daemonset uses a host port (e.g. if prometheus metrics are enabled), kube-scheduler guarantees that only a single pod with that port/protocol is scheduled to a node – effectively offering the same guarantee provided by the inter-pod anti-affinity rule.

To leverage this, consider using --set scheduling.mode=kube-scheduler when installing or upgrading cilium.

Use caution when changing changing host port numbers. Changing the host port number removes the kube-scheduler guarantee. When a host port number must change, ensure at least one host port number is shared across the upgrade, or consider using --set scheduling.mode=anti-affinity.

Various additional settings that we recommend help to tune the system for specific workloads and to reduce jitter:

The tuned project offers various profiles to optimize for deterministic performance at the cost of increased power consumption, that is, network-latency and network-throughput, for example. To enable the former, run:

The CPU scaling up and down can impact latency tests and lead to sub-optimal performance. To achieve maximum consistent performance. Set the CPU governor to performance:

In case you are running irqbalance, consider disabling it as it might migrate the NIC’s IRQ handling among CPUs and can therefore cause non-deterministic performance:

We highly recommend to pin the NIC interrupts to specific CPUs in order to allow for maximum workload isolation!

See this script for details and initial pointers on how to achieve this. Note that pinning the queues can potentially vary in setup between different drivers.

We generally also recommend to check various documentation and performance tuning guides from NIC vendors on this matter such as from Mellanox, Intel or others for more information.

---

## CNI Performance Benchmark — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/operations/performance/benchmark/

**Contents:**
- CNI Performance Benchmark
- Introduction
- TCP Throughput (TCP_STREAM)
  - Single-Stream
  - Multi-Stream
- Request/Response Rate (TCP_RR)
  - 1 Process
  - 32 Processes
- Connection Rate (TCP_CRR)
  - 1 Process

This chapter contains performance benchmark numbers for a variety of scenarios. All tests are performed between containers running on two different bare metal nodes connected back-to-back by a 100Gbit/s network interface. Upon popular request we have included performance numbers for Calico for comparison.

You can also watch Thomas Graf, Co-founder of Cilium, dive deep into this chapter in eCHO episode 5: Network performance benchmarking.

To achieve these performance results, follow the Tuning Guide.

For more information on the used system and configuration, see Test Hardware. For more details on all tested configurations, see Test Configurations.

The following metrics are collected and reported. Each metric represents a different traffic pattern that can be required for workloads. See the specific sections for an explanation on what type of workloads are represented by each benchmark.

Maximum transfer rate via a single TCP connection and the total transfer rate of 32 accumulated connections.

The number of request/response messages per second that can be transmitted over a single TCP connection and over 32 parallel TCP connections.

The number of connections per second that can be established in sequence with a single request/response payload message transmitted for each new connection. A single process and 32 parallel processes are tested.

For the various benchmarks netperf has been used to generate the workloads and to collect the metrics. For spawning parallel netperf sessions, super_netperf has been used. Both netperf and super_netperf are also frequently used and well established tools for benchmarking in the Linux kernel networking community.

Throughput testing (TCP_STREAM) is useful to understand the maximum throughput that can be achieved with a particular configuration. All or most configurations can achieve line-rate or close to line-rate if enough CPU resources are thrown at the load. It is therefore important to understand the amount of CPU resources required to achieve a certain throughput as these CPU resources will no longer be available to workloads running on the machine.

This test represents bulk data transfer workloads, e.g. streaming services or services performing data upload/download.

In this test, a single TCP stream is opened between the containers and maximum throughput is achieved:

We can see that eBPF-based solutions can outperform even the node-to-node baseline on modern kernels despite performing additional work (forwarding into the network namespace of the container, policy enforcement, …). This is because eBPF is capable of bypassing the iptables layer of the node which is still traversed for the node to node baseline.

The following graph shows the total CPU consumption across the entire system while running the benchmark, normalized to a 50Gbit throughput:

Kernel wisdom: TCP flow performance is limited by the receiver, since sender can use both TSO super-packets. This can be observed in the increased CPU spending on the server-side above above.

In this test, 32 processes are opening 32 parallel TCP connections. Each process is attempting to reach maximum throughput and the total is reported:

Given multiple processes are being used, all test configurations can achieve transfer rates close to the line-rate of the network interface. The main difference is the CPU resources required to achieve it:

The request/response rate (TCP_RR) primarily measures the latency and efficiency to handle round-trip forwarding of an individual network packet. This benchmark will lead to the most packets per second possible on the wire and stresses the cost performed by a network packet. This is the opposite of the throughput test which maximizes the size of each network packet.

A configuration that is doing well in this test (delivering high requests per second rates) will also deliver better (lower) network latencies.

This test represents services which maintain persistent connections and exchange request/response type interactions with other services. This is common for services using REST or gRPC APIs.

In this test, a single TCP connection is opened between the containers and a single byte is sent back and forth between the containers. For each round-trip, one request is counted:

eBPF on modern kernels can achieve almost the same request/response rate as the baseline while only consuming marginally more CPU resources:

In this test, 32 processes are opening 32 parallel TCP connections. Each process is performing single byte round-trips. The total number of requests per second is reported:

Cilium can achieve close to 1M requests/s in this test while consuming about 30% of the system resources on both the sender and receiver:

The connection rate (TCP_CRR) test measures the efficiency in handling new connections. It is similar to the request/response rate test but will create a new TCP connection for each round-trip. This measures the cost of establishing a connection, transmitting a byte in both directions, and closing the connection. This is more expensive than the TCP_RR test and puts stress on the cost related to handling new connections.

This test represents a workload that receives or initiates a lot of TCP connections. An example where this is the case is a publicly exposed service that receives connections from many clients. Good examples of this are L4 proxies or services opening many connections to external endpoints. This benchmark puts the most stress on the system with the least work offloaded to hardware so we can expect to see the biggest difference between tested configurations.

A configuration that does well in this test (delivering high connection rates) will handle situations with overwhelming connection rates much better, leaving more CPU resources available to workloads on the system.

In this test, a single process opens as many TCP connections as possible in sequence:

The following graph shows the total CPU consumption across the entire system while running the benchmark:

Kernel wisdom: The CPU resources graph makes it obvious that some additional kernel cost is paid at the sender as soon as network namespace isolation is performed as all container workload benchmarks show signs of this cost. We will investigate and optimize this aspect in a future release.

In this test, 32 processes running in parallel open as many TCP connections in sequence as possible. This is by far the most stressful test for the system.

This benchmark outlines major differences between the tested configurations. In particular, it illustrates the overall cost of iptables which is optimized to perform most of the required work per connection and then caches the result. This leads to a worst-case performance scenario when a lot of new connections are expected.

We have not been able to measure stable results for the Calico eBPF datapath. We are not sure why. The network packet flow was never steady. We have thus not included the result. We invite the Calico team to work with us to investigate this and then re-test.

The following graph shows the total CPU consumption across the entire system while running the benchmark:

Cilium supports encryption via WireGuard® and IPsec. This first section will look at WireGuard and compare it against using Calico for WireGuard encryption. If you are interested in IPsec performance and how it compares to WireGuard, please see WireGuard vs IPsec.

Looking at TCP throughput first, the following graph shows results for both 1500 bytes MTU and 9000 bytes MTU:

The Cilium eBPF kube-proxy replacement combined with WireGuard is currently slightly slower than Cilium eBPF + kube-proxy. We have identified the problem and will be resolving this deficit in one of the next releases.

The following graph shows the total CPU consumption across the entire system while running the WireGuard encryption benchmark:

The next benchmark measures the request/response rate while encrypting with WireGuard. See Request/Response Rate (TCP_RR) for details on what this test actually entails.

All tested configurations performed more or less the same. The following graph shows the total CPU consumption across the entire system while running the WireGuard encryption benchmark:

In this section, we compare Cilium encryption using WireGuard and IPsec. WireGuard is able to achieve a higher maximum throughput:

However, looking at the CPU resources required to achieve 10Gbit/s of throughput, WireGuard is less efficient at achieving the same throughput:

IPsec performing better than WireGuard in in this test is unexpected in some ways. A possible explanation is that the IPsec encryption is making use of AES-NI instructions whereas the WireGuard implementation is not. This would typically lead to IPsec being more efficient when AES-NI offload is available and WireGuard being more efficient if the instruction set is not available.

Looking at the request/response rate, IPsec is outperforming WireGuard in our tests. Unlike for the throughput tests, the MTU does not have any effect as the packet sizes remain small:

All tests are performed using regular off-the-shelf hardware.

AMD Ryzen 9 3950x, AM4 platform, 3.5GHz, 16 cores / 32 threads

x570 Aorus Master, PCIe 4.0 x16 support

HyperX Fury DDR4-3200 128GB, XMP clocked to 3.2GHz

Intel E810-CQDA2, dual port, 100Gbit/s per port, PCIe 4.0 x16

Linux 5.10 LTS, see also Tuning Guide

All tests are performed using standardized configuration. Upon popular request, we have included measurements for Calico for direct comparison.

Baseline (Node to Node)

Cilium 1.9.6, eBPF host-routing, kube-proxy replacement, No CT

Cilium (legacy host-routing)

Cilium 1.9.6, legacy host-routing, kube-proxy replacement, No CT

Calico 3.17.3, kube-proxy

Calico 3.17.3, eBPF datapath, No CT

To ease reproducibility, this report is paired with a set of scripts that can be found in cilium/cilium-perf-networking. All scripts in this document refer to this repository. Specifically, we use Terraform and Ansible to setup the environment and execute benchmarks. We use Packet bare metal servers as our hardware platform, but the guide is structured so that it can be easily adapted to other environments.

Download the Cilium performance evaluation scripts:

To evaluate both Encapsulation and Native-Routing, we configure the Packet machines to use a “Mixed/Hybrid” network mode, where the secondary interfaces of the machines share a flat L2 network. While this can be done on the Packet web UI, we include appropriate Terraform (version 0.13) files to automate this process.

The above will provision two servers named knb-0 and knb-1 of type c3.small.x86 and configure them to use a “Mixed/Hybrid” network mode under a common VLAN named knb. The machines will be provisioned with an ubuntu_20_04 OS. We also create a packet-hosts.ini file to use as an inventory file for Ansible.

Verify that the servers are successfully provisioned by executing an ad-hoc uptime command on the servers.

Next, we use the packet-disbond.yaml playbook to configure the network interfaces of the machines. This will destroy the bond0 interface and configure the first physical interface with the public and private IPs (prv_ip) and the second with the node IP (node_ip) that will be used for our evaluations (see Packet documentation and our scripts for more info).

For hardware platforms other than Packet, users need to provide their own inventory file (packet-hosts.ini) and follow the subsequent steps.

Install netperf (used for raw host-to-host measurements):

Install kubeadm and its dependencies:

We use kubenetbench to execute the netperf benchmark in a Kubernetes environment. kubenetbench is a Kubernetes benchmarking project that is agnostic to the CNI or networking plugin that the cluster is deployed with. In this report we focus on pod-to-pod communication between different nodes. To install kubenetbench:

Configure Cilium in tunneling (Encapsulation) mode:

The first command configures Cilium to use tunneling (-e mode=tunneling), which by default uses the VXLAN overlay. The second executes our benchmark suite (the conf variable is used to identify this benchmark run). Once execution is done, a results directory will be copied back in a folder named after the conf variable (in this case, vxlan). This directory includes all the benchmark results as generated by kubenetbench, including netperf output and system information.

We repeat the same operation as before, but configure Cilium to use Native-Routing (-e mode=directrouting).

To use encryption with native routing:

To have a point of reference for our results, we execute the same benchmarks between hosts without Kubernetes running. This provides an effective upper limit to the performance achieved by Cilium.

The first command removes Kubernetes and reboots the machines to ensure that there are no residues in the systems, whereas the second executes the same set of benchmarks between hosts. An alternative would be to run the raw benchmark before setting up Cilium, in which case one would only need the second command.

When done with benchmarking, the allocated Packet resources can be released with:

---

## Configuring Hubble exporter — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/observability/hubble/configuration/export/

**Contents:**
- Configuring Hubble exporter
- Prerequisites
- Basic Configuration
  - Setup
  - Configuration options
- Performance tuning
  - Filters
  - Field mask
- Dynamic exporter configuration

Hubble Exporter is a feature of cilium-agent that lets you write Hubble flows to a file for later consumption as logs. Hubble Exporter supports file rotation, size limits, filters, and field masks.

Setup Helm repository:

Hubble Exporter is enabled with Config Map property. It is disabled until you set a file path value for hubble-export-file-path.

You can use helm to install cilium with hubble exporter enabled:

Wait for cilium pod to become ready:

Verify that flow logs are stored in target files:

Once you have configured the Hubble Exporter, you can configure your logging solution to consume logs from your Hubble export file path.

To get Hubble flows directly exported to the logs instead of written to a rotated file, stdout can be defined as hubble-export-file-path.

To disable the static configuration, you must remove the hubble-export-file-path key in the cilium-config ConfigMap and manually clean up the log files created in the specified location in the container. The below command will restart the Cilium pods. If you edit the ConfigMap manually, you will need to restart the Cilium pods.

Helm chart configuration options include:

hubble.export.static.filePath: file path of target log file. (default /var/run/cilium/hubble/events.log)

hubble.export.fileMaxSizeMb: size in MB at which to rotate the Hubble export file. (default 10)

hubble.export.fileMaxBackups: number of rotated Hubble export files to keep. (default 5)

hubble.export.fileCompress: enable compression of rotated files. (default false)

Configuration options impacting performance of Hubble exporter include:

hubble.export.static.allowList: specify an allowlist as JSON encoded FlowFilters to Hubble exporter.

hubble.export.static.denyList: specify a denylist as JSON encoded FlowFilters to Hubble exporter.

hubble.export.static.fieldMask: specify a list of fields to use for field masking in Hubble exporter.

You can use hubble CLI to generated required filters (see Specifying Raw Flow Filters for more examples).

For example, to filter flows with verdict DENIED or ERROR, run:

Then paste the output to hubble-export-allowlist in cilium-config Config Map:

Or use helm chart to update your cilium installation setting value flag hubble.export.static.allowList.

You can do the same to selectively filter data. For example, to filter all flows in the kube-system namespace, run:

Then paste the output to hubble-export-denylist in cilium-config Config Map:

Or use helm chart to update your cilium installation setting value flag hubble.export.static.denyList.

Field mask can’t be generated with hubble. Field mask is a list of field names from the flow proto definition.

To keep all information except pod labels:

To keep only timestamp, verdict, ports, IP addresses, node name, pod name, and namespace:

The following is a complete example of configuring Hubble Exporter.

Standard hubble exporter configuration accepts only one set of filters and requires cilium pod restart to change config. Dynamic flow logs allow configuring multiple filters at the same time and saving output in separate files. Additionally it does not require cilium pod restarts to apply changed configuration.

Dynamic Hubble Exporter is enabled with Config Map property. It is disabled until you set a file path value for hubble-flowlogs-config-path.

Install cilium with dynamic exporter enabled:

Wait for cilium pod to become ready:

You can change flow log settings without a need for pod to be restarted (changes should be reflected within 60s because of configmap propagation delay):

Dynamic flow logs can be configured with end property which means that it will automatically stop logging after specified date time. It supports the same field masking and filtering as static hubble exporter.

For max output file size and backup files dynamic exporter reuses the same settings as static one: hubble.export.fileMaxSizeMb and hubble.export.fileMaxBackups

Sample dynamic flow logs configs:

---

## Introduction to Cilium & Hubble — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/overview/intro/

**Contents:**
- Introduction to Cilium & Hubble
- What is Cilium?
- What is Hubble?
  - Service dependencies & communication map
  - Network monitoring & alerting
  - Application monitoring
  - Security observability
- Why Cilium & Hubble?
- Functionality Overview
  - Protect and secure APIs transparently

Cilium is open source software for transparently securing the network connectivity between application services deployed using Linux container management platforms like Docker and Kubernetes.

At the foundation of Cilium is a new Linux kernel technology called eBPF, which enables the dynamic insertion of powerful security visibility and control logic within Linux itself. Because eBPF runs inside the Linux kernel, Cilium security policies can be applied and updated without any changes to the application code or container configuration.

If you’d like a video introduction to Cilium, check out this explanation by Thomas Graf, Co-founder of Cilium.

Hubble is a fully distributed networking and security observability platform. It is built on top of Cilium and eBPF to enable deep visibility into the communication and behavior of services as well as the networking infrastructure in a completely transparent manner.

By building on top of Cilium, Hubble can leverage eBPF for visibility. By relying on eBPF, all visibility is programmable and allows for a dynamic approach that minimizes overhead while providing deep and detailed visibility as required by users. Hubble has been created and specifically designed to make best use of these new eBPF powers.

Hubble can answer questions such as:

What services are communicating with each other? How frequently? What does the service dependency graph look like?

What HTTP calls are being made? What Kafka topics does a service consume from or produce to?

Is any network communication failing? Why is communication failing? Is it DNS? Is it an application or network problem? Is the communication broken on layer 4 (TCP) or layer 7 (HTTP)?

Which services have experienced a DNS resolution problem in the last 5 minutes? Which services have experienced an interrupted TCP connection recently or have seen connections timing out? What is the rate of unanswered TCP SYN requests?

What is the rate of 5xx or 4xx HTTP response codes for a particular service or across all clusters?

What is the 95th and 99th percentile latency between HTTP requests and responses in my cluster? Which services are performing the worst? What is the latency between two services?

Which services had connections blocked due to network policy? What services have been accessed from outside the cluster? Which services have resolved a particular DNS name?

If you’d like a video introduction to Hubble, check out eCHO episode 2: Introduction to Hubble.

eBPF is enabling visibility into and control over systems and applications at a granularity and efficiency that was not possible before. It does so in a completely transparent way, without requiring the application to change in any way. eBPF is equally well-equipped to handle modern containerized workloads as well as more traditional workloads such as virtual machines and standard Linux processes.

The development of modern datacenter applications has shifted to a service-oriented architecture often referred to as microservices, wherein a large application is split into small independent services that communicate with each other via APIs using lightweight protocols like HTTP. Microservices applications tend to be highly dynamic, with individual containers getting started or destroyed as the application scales out / in to adapt to load changes and during rolling updates that are deployed as part of continuous delivery.

This shift toward highly dynamic microservices presents both a challenge and an opportunity in terms of securing connectivity between microservices. Traditional Linux network security approaches (e.g., iptables) filter on IP address and TCP/UDP ports, but IP addresses frequently churn in dynamic microservices environments. The highly volatile life cycle of containers causes these approaches to struggle to scale side by side with the application as load balancing tables and access control lists carrying hundreds of thousands of rules that need to be updated with a continuously growing frequency. Protocol ports (e.g. TCP port 80 for HTTP traffic) can no longer be used to differentiate between application traffic for security purposes as the port is utilized for a wide range of messages across services.

An additional challenge is the ability to provide accurate visibility as traditional systems are using IP addresses as primary identification vehicle which may have a drastically reduced lifetime of just a few seconds in microservices architectures.

By leveraging Linux eBPF, Cilium retains the ability to transparently insert security visibility + enforcement, but does so in a way that is based on service / pod / container identity (in contrast to IP address identification in traditional systems) and can filter on application-layer (e.g. HTTP). As a result, Cilium not only makes it simple to apply security policies in a highly dynamic environment by decoupling security from addressing, but can also provide stronger security isolation by operating at the HTTP-layer in addition to providing traditional Layer 3 and Layer 4 segmentation.

The use of eBPF enables Cilium to achieve all of this in a way that is highly scalable even for large-scale environments.

Ability to secure modern application protocols such as REST/HTTP, gRPC and Kafka. Traditional firewalls operate at Layer 3 and 4. A protocol running on a particular port is either completely trusted or blocked entirely. Cilium provides the ability to filter on individual application protocol requests such as:

Allow all HTTP requests with method GET and path /public/.*. Deny all other requests.

Allow service1 to produce on Kafka topic topic1 and service2 to consume on topic1. Reject all other Kafka messages.

Require the HTTP header X-Token: [0-9]+ to be present in all REST calls.

See the section Layer 7 Policy in our documentation for the latest list of supported protocols and examples on how to use it.

Modern distributed applications rely on technologies such as application containers to facilitate agility in deployment and scale out on demand. This results in a large number of application containers being started in a short period of time. Typical container firewalls secure workloads by filtering on source IP addresses and destination ports. This concept requires the firewalls on all servers to be manipulated whenever a container is started anywhere in the cluster.

In order to avoid this situation which limits scale, Cilium assigns a security identity to groups of application containers which share identical security policies. The identity is then associated with all network packets emitted by the application containers, allowing to validate the identity at the receiving node. Security identity management is performed using a key-value store.

Label based security is the tool of choice for cluster internal access control. In order to secure access to and from external services, traditional CIDR based security policies for both ingress and egress are supported. This allows to limit access to and from application containers to particular IP ranges.

A simple flat Layer 3 network with the ability to span multiple clusters connects all application containers. IP allocation is kept simple by using host scope allocators. This means that each host can allocate IPs without any coordination between hosts.

The following multi node networking models are supported:

Overlay: Encapsulation-based virtual network spanning all hosts. Currently, VXLAN and Geneve are baked in but all encapsulation formats supported by Linux can be enabled.

When to use this mode: This mode has minimal infrastructure and integration requirements. It works on almost any network infrastructure as the only requirement is IP connectivity between hosts which is typically already given.

Native Routing: Use of the regular routing table of the Linux host. The network is required to be capable to route the IP addresses of the application containers.

When to use this mode: This mode is for advanced users and requires some awareness of the underlying networking infrastructure. This mode works well with:

In conjunction with cloud network routers

If you are already running routing daemons

Cilium implements distributed load balancing for traffic between application containers and to external services and is able to fully replace components such as kube-proxy. The load balancing is implemented in eBPF using efficient hashtables allowing for almost unlimited scale.

For north-south type load balancing, Cilium’s eBPF implementation is optimized for maximum performance, can be attached to XDP (eXpress Data Path), and supports direct server return (DSR) as well as Maglev consistent hashing if the load balancing operation is not performed on the source host.

For east-west type load balancing, Cilium performs efficient service-to-backend translation right in the Linux kernel’s socket layer (e.g. at TCP connect time) such that per-packet NAT operations overhead can be avoided in lower layers.

Cilium implements bandwidth management through efficient EDT-based (Earliest Departure Time) rate-limiting with eBPF for container traffic that is egressing a node. This allows to significantly reduce transmission tail latencies for applications and to avoid locking under multi-queue NICs compared to traditional approaches such as HTB (Hierarchy Token Bucket) or TBF (Token Bucket Filter) as used in the bandwidth CNI plugin, for example.

The ability to gain visibility and troubleshoot issues is fundamental to the operation of any distributed system. While we learned to love tools like tcpdump and ping and while they will always find a special place in our hearts, we strive to provide better tooling for troubleshooting. This includes tooling to provide:

Event monitoring with metadata: When a packet is dropped, the tool doesn’t just report the source and destination IP of the packet, the tool provides the full label information of both the sender and receiver among a lot of other information.

Metrics export via Prometheus: Key metrics are exported via Prometheus for integration with your existing dashboards.

Hubble: An observability platform specifically written for Cilium. It provides service dependency maps, operational monitoring and alerting, and application and security visibility based on flow logs.

---

## eBPF Program Types — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/internals/hooks/

**Contents:**
- eBPF Program Types

Cilium uses the following eBPF program types to attach programs to the kernel:

BPF_PROG_TYPE_SCHED_ACT

BPF_PROG_TYPE_CGROUP_SOCK_ADDR

---

## 

**URL:** https://docs.cilium.io/en/stable/_images/cilium_http_l3_l4_gsg.png

---

## Welcome to Cilium’s documentation! — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/

**Contents:**
- Welcome to Cilium’s documentation!

The documentation is divided into the following sections:

Cilium Quick Installation: Provides a simple tutorial for running a small Cilium setup on your laptop. Intended as an easy way to get your hands dirty applying Cilium security policies between containers.

Getting Started : Details instructions for installing, configuring, and troubleshooting Cilium in different deployment modes.

Overview of Network Policy : Detailed walkthrough of the policy language structure and the supported formats.

Observability : Provides instructions on setting up and configuring Network Observability with Hubble and configuring metrics collection from Cilium and Hubble.

Troubleshooting : Describes how to troubleshoot Cilium in different deployment modes.

BPF and XDP Reference Guide : Provides a technical deep dive of eBPF and XDP technology, primarily focused at developers.

API Reference : Details the Cilium agent API for interacting with a local Cilium instance.

Development : Gives background to those looking to develop and contribute modifications to the Cilium code or documentation.

Securing Networks with Cilium : Provides a one-page resource of best practices for securing Cilium.

A hands-on tutorial in a live environment is also available for users looking for a way to quickly get started and experiment with Cilium.

Advanced Installation

---

## 

**URL:** https://docs.cilium.io/en/stable/_images/cilium_http_l3_l4_l7_gsg.png

---

## Key-Value Store — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/kvstore/

**Contents:**
- Key-Value Store
- Layout
  - Cluster Nodes
  - Services
  - Identities
  - Endpoints
  - CiliumNetworkPolicyNodeStatus
  - Heartbeat
- Leases
- Caveats and Limitations

Cilium uses an external key-value store to exchange information across multiple Cilium instances:

All data is stored under a common key prefix:

All keys share this common prefix.

State stored by agents, data is automatically recreated on removal or corruption.

Every agent will register itself as a node in the kvstore and make the following information available to other agents:

IP addresses of the node

Health checking IP addresses

Allocation range of endpoints on the node

cilium/state/nodes/v1/<cluster>/<node>

All node keys are attached to a lease owned by the agent of the respective node.

All Kubernetes services are mirrored into the kvstore by the Cilium operator. This is required to implement multi cluster service discovery.

cilium/state/services/v1/<cluster>/<namespace>/<service>

serviceStore.ClusterService

Any time a new endpoint is started on a Cilium node, it will determine whether the labels for the endpoint are unique and allocate an identity for that set of labels. These identities are only meaningful within the local cluster.

cilium/state/identities/v1/id/<identity>

cilium/state/identities/v1/value/<labels>/<node>

identity.NumericIdentity

All endpoint IPs and corresponding identities are mirrored to the kvstore by the agent on the node where the endpoint is launched, to allow peer nodes to configure egress policies to endpoints backed by these IPs.

cilium/state/ip/v1/<cluster>/<ip>

identity.IPIdentityPair

If handover to Kubernetes is enabled, then each cilium-agent will propagate the state of whether it has realized a given CNP to the key-value store instead of directly writing to kube-apiserver. cilium-operator will listen for updates to this prefix from the key-value store, and will be the sole updater of statuses for CNPs in the cluster.

cilium/state/cnpstatuses/v2/<UID>/<namespace>/<name>/<node>

The heartbeat key is periodically updated by the operator to contain the current time and date. It is used by agents to validate that kvstore updates can be received.

Current time and date

With a few exceptions, all keys in the key-value store are owned by a particular agent running on a node. All such keys have a lease attached. The lease is renewed automatically. When the lease expires, the key is removed from the key-value store. This guarantees that keys are removed from the key-value store in the event that an agent dies on a particular and never reappears.

The lease lifetime is set to 15 minutes. The exact expiration behavior is dependent on the kvstore implementation but the expiration typically occurs after double the lease lifetime.

In addition to regular entry leases, all locks in the key-value store are owned by a particular agent running on the node with a separate “lock lease” attached. The lock lease has a default lifetime of 25 seconds.

cilium/.initlock/<random>/<lease-ID>

cilium/state/cnpstatuses/v2/<UID>/<namespace>/<name>/<node>

cilium/state/identities/v1/id/<identity>

Garbage collected by cilium-operator

cilium/state/identities/v1/value/<labels>/<node>

cilium/state/ip/v1/<cluster>/<ip>

cilium/state/nodes/v1/<cluster>/<node>

cilium/state/services/v1/<cluster>/<namespace>/<service>

If you manually remove and recreate kvstore state when IPSec transparent encryption is enabled, then that may cause permanent connectivity disruption for pods managed by Cilium. Refer to XFRM State Staling in Cilium for further details.

The contents stored in the kvstore can be queued and manipulate using the cilium kvstore command. For additional details, see the command reference.

---

## Running Prometheus & Grafana — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/observability/grafana/

**Contents:**
- Running Prometheus & Grafana
- Install Prometheus & Grafana
- Deploy Cilium and Hubble with metrics enabled
- How to access Grafana
- How to access Prometheus
- Examples
  - Generic
  - Network
  - Policy
  - Endpoints

This is an example deployment that includes Prometheus and Grafana in a single deployment.

You can also see Cilium and Grafana in action on eCHO episode 68: Cilium & Grafana.

The default installation contains:

Grafana: A visualization dashboard with Cilium Dashboard pre-loaded.

Prometheus: a time series database and monitoring system.

This example deployment of Prometheus and Grafana will automatically scrape the Cilium and Hubble metrics. See the Monitoring & Metrics configuration guide on how to configure a custom Prometheus instance.

Cilium, Hubble, and Cilium Operator do not expose metrics by default. Enabling metrics for these services will open ports 9962, 9965, and 9963 respectively on all nodes of your cluster where these components are running.

The metrics for Cilium, Hubble, and Cilium Operator can all be enabled independently of each other with the following Helm values:

prometheus.enabled=true: Enables metrics for cilium-agent.

operator.prometheus.enabled=true: Enables metrics for cilium-operator.

hubble.metrics.enabled: Enables the provided list of Hubble metrics. For Hubble metrics to work, Hubble itself needs to be enabled with hubble.enabled=true. See Hubble exported metrics for the list of available Hubble metrics.

Refer to Monitoring & Metrics for more details about the individual metrics.

Setup Helm repository:

Deploy Cilium via Helm as follows to enable all metrics:

You can combine the above Helm options with any of the other installation guides.

Expose the port on your local machine

Access it via your browser: http://localhost:3000

Expose the port on your local machine

Access it via your browser: http://localhost:9090

The port-distribution metric is disabled by default. Refer to Monitoring & Metrics for more details about the individual metrics.

---

## Troubleshooting Cilium deployed with Argo CD — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/configuration/argocd-issues/

**Contents:**
- Troubleshooting Cilium deployed with Argo CD
- Argo CD deletes CustomResourceDefinitions
  - Solution
- Helm template with serviceMonitor enabled fails
  - Solution
- Application chart for Cilium deployed to Talos Linux fails with: field not declared in schema
  - Solution

There have been reports from users hitting issues with Argo CD. This documentation page outlines some of the known issues and their solutions.

When deploying Cilium with Argo CD, some users have reported that Cilium-generated custom resources disappear, causing one or more of the following issues:

ciliumid not found (GitHub issue 17614)

Argo CD Out-of-sync issues for hubble-generate-certs (GitHub issue 14550)

Out-of-sync issues for Cilium using Argo CD (GitHub issue 18298)

To prevent these issues, declare resource exclusions in the Argo CD ConfigMap by following these instructions.

Here is an example snippet:

Also, it has been reported that the problem may affect all workloads you deploy with Argo CD in a cluster running Cilium, not just Cilium itself. If so, you will need the following exclusions in your Argo CD application definition to avoid getting “out of sync” when Hubble rotates its certificates.

After applying the above configurations, for the settings to take effect, you will need to restart the Argo CD deployments.

Some users have reported that when they install Cilium using Argo CD and run helm template with serviceMonitor enabled, it fails. It fails because Argo CD CLI doesn’t pass the --api-versions flag to Helm upon deployment.

This pull request fixed this issue in Argo CD’s v2.3.0 release. Upgrade your Argo CD and check if helm template with serviceMonitor enabled still fails.

When using helm template, it is highly recommended you set --kube-version and --api-versions with the values matching your target Kubernetes cluster. Helm charts such as Cilium’s often conditionally enable certain Kubernetes features based on their availability (beta vs stable) on the target cluster.

By specifying --api-versions=monitoring.coreos.com/v1 you should be able to pass validation with helm template.

If you have an issue with Argo CD that’s not outlined above, check this list of Argo CD related issues on GitHub. If you can’t find an issue that relates to yours, create one and/or seek help on Cilium Slack.

When deploying Cilium to Talos Linux with ArgoCD, some users have reported issues due to Talos Security configuration. ArgoCD may fail to deploy the application with the message:

Add option ServerSideApply=true to list syncPolicy.syncOptions for the Application.

Visit the ArgoCD documentation for further details.

---

## Glossary — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/glossary/

**Contents:**
- Glossary

Cilium has some terms with special meanings. These should all be covered throughout the documentation but for convenience we have also listed some of them below with short descriptions. If you need more information, please ask us on Cilium Slack. Feel free to extend this document with words you expected to see here.

https://github.com/containernetworking/cni

https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/

https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/#customresourcedefinitions

https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/

https://tools.ietf.org/html/rfc8926

https://kubernetes.io/docs/concepts/services-networking/service/#headless-services

https://www.kernel.org/pub/linux/utils/net/iproute2/

https://www.kernel.org/

https://releases.llvm.org/

https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector

https://kubernetes.io/docs/concepts/workloads/pods/pod/

A Cilium policy consists of a list of rules. The security policy can be specified in The Kubernetes NetworkPolicy format or The Cilium policy language.

https://kubernetes.io/docs/reference/access-authn-authz/rbac/

https://kubernetes.io/docs/concepts/services-networking/service/

https://kubernetes.io/docs/tasks/configure-pod-container/configure-volume-storage/

https://tools.ietf.org/html/rfc7348

---
