# Cilium - Network

**Pages:** 107

---

## HTTP Header Modifier Examples — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/header/

**Contents:**
- HTTP Header Modifier Examples
- Deploy the Echo App
- Deploy the Cilium Gateway
- Modify incoming HTTP Requests

The Gateway can modify the headers of HTTP requests from clients.

We will use a deployment made of echo servers.

The application will reply to the client and, in the body of the reply, will include information about the Pod and Node receiving the original request. We will use this information to illustrate how the traffic is manipulated by the Gateway.

Verify the Pods are running as expected.

HTTP header modification is the process of adding, removing, or modifying HTTP headers in incoming requests. To configure HTTP header modification, define a Gateway object with one or more HTTP filters. Each filter specifies a specific modification to make to incoming requests, such as adding a custom header or modifying an existing header.

To add a header to a HTTP request, use a filter of the type RequestHeaderModifier with the add action and the name and value of the header.

You can find an example Gateway and HTTPRoute definition in request-header.yaml:

This example adds a header named my-header-name with the my-header-value value.

Deploy the Gateway and the HTTPRoute:

The preceding kubectl command creates a Gateway named cilium-gw that listens on port 80.

Some providers like EKS use a fully-qualified domain name rather than an IP address.

Now that the Gateway is ready, you can make HTTP requests.

If the curl succeeds, you can see the HTTP Header from the incoming request in the body of the response sent back from the echo server. You can also see that the Gateway added the header.

You can also remove headers with the remove keyword and a list of header names.

Notice that the x-request-id header is removed when you add the remove-a-request-header prefix match to the filter:

To edit an existing header, use the set action to specify the value of the header to modify as well as the new header value to set.

Notice that the x-request-id header is changed when you add the edit-a-request-header prefix match to the filter:

---

## LoadBalancer IP Address Management (LB IPAM) — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/lb-ipam/

**Contents:**
- LoadBalancer IP Address Management (LB IPAM)
- Pools
  - CIDRs, Ranges and reserved IPs
  - Service Selectors
  - Conflicts
  - Disabling a Pool
  - Status
- Services
  - IPv4 / IPv6 families + policy
  - LoadBalancerClass

LB IPAM is a feature that allows Cilium to assign IP addresses to Services of type LoadBalancer. This functionality is usually left up to a cloud provider, however, when deploying in a private cloud environment, these facilities are not always available.

LB IPAM works in conjunction with features such as Cilium BGP Control Plane and L2 Announcements / L2 Aware LB (Beta). Where LB IPAM is responsible for allocation and assigning of IPs to Service objects and other features are responsible for load balancing and/or advertisement of these IPs.

Use Cilium BGP Control Plane to advertise the IP addresses assigned by LB IPAM over BGP and L2 Announcements / L2 Aware LB (Beta) to advertise them locally.

LB IPAM is always enabled but dormant. The controller is awoken when the first IP Pool is added to the cluster.

LB IPAM has the notion of IP Pools which the administrator can create to tell Cilium which IP ranges can be used to allocate IPs from.

A basic IP Pools with both an IPv4 and IPv6 range looks like this:

After adding the pool to the cluster, it appears like so.

Updating an IP pool can result in IP addresses being reassigned and service IPs could change. See GitHub issue 40358

An IP pool can have multiple blocks of IPs. A block can be specified with CIDR notation (<prefix>/<bits>) or a range notation with a start and stop IP. As pictured in Pools.

When CIDRs are used to specify routable IP ranges, you might not want to allocate the first and the last IP of a CIDR. Typically the first IP is the “network address” and the last IP is the “broadcast address”. In some networks these IPs are not usable and they do not always play well with all network equipment. By default, LB-IPAM uses all IPs in a given CIDR.

If you wish to reserve the first and last IPs of CIDRs, you can set the .spec.allowFirstLastIPs field to No.

This option is ignored for /32 and /31 IPv4 CIDRs and /128 and /127 IPv6 CIDRs since these only have 1 or 2 IPs respectively.

This setting only applies to blocks specified with .spec.blocks[].cidr and not to blocks specified with .spec.blocks[].start and .spec.blocks[].stop.

IP Pools have an optional .spec.serviceSelector field which allows administrators to limit which services can get IPs from which pools using a label selector. The pool will allocate to any service if no service selector is specified.

There are a few special purpose selector fields which don’t match on labels but instead on other metadata like .meta.name or .meta.namespace.

io.kubernetes.service.namespace

io.kubernetes.service.name

IP Pools are not allowed to have overlapping CIDRs. When an administrator does create pools which overlap, a soft error is caused. The last added pool will be marked as Conflicting and no further allocation will happen from that pool. Therefore, administrators should always check the status of all pools after making modifications.

For example, if we add 2 pools (blue-pool and red-pool) both with the same CIDR, we will see the following:

The reason for the conflict is stated in the status and can be accessed like so

IP Pools can be disabled. Disabling a pool will stop LB IPAM from allocating new IPs from the pool, but doesn’t remove existing allocations. This allows an administrator to slowly drain pool or reserve a pool for future use.

The IP Pool’s status contains additional counts which can be used to monitor the amount of used and available IPs. A machine parsable output can be obtained like so.

Or human readable output like so

Any service with .spec.type=LoadBalancer can get IPs from any pool as long as the IP Pool’s service selector matches the service.

Lets say we add a simple service.

This service will appear like so.

The ExternalIP field has a value of <pending> which means no LB IPs have been assigned. When LB IPAM is unable to allocate or assign IPs for the service, it will update the service conditions in the status.

The service conditions can be checked like so:

After updating the service labels to match our blue-pool from before we see:

LB IPAM supports IPv4 and/or IPv6 in SingleStack or DualStack mode. Services can use the .spec.ipFamilyPolicy and .spec.ipFamilies fields to change the requested IPs.

If .spec.ipFamilyPolicy isn’t specified, SingleStack mode is assumed. If both IPv4 and IPv6 are enabled in SingleStack mode, an IPv4 address is allocated.

If .spec.ipFamilyPolicy is set to PreferDualStack, LB IPAM will attempt to allocate both an IPv4 and IPv6 address if both are enabled on the cluster. If only IPv4 or only IPv6 is enabled on the cluster, the service is still considered “satisfied”.

If .spec.ipFamilyPolicy is set to RequireDualStack LB IPAM will attempt to allocate both an IPv4 and IPv6 address. The service is considered “unsatisfied” If IPv4 or IPv6 is disabled on the cluster.

The order of .spec.ipFamilies has no effect on LB IPAM but is significant for cluster IP allocation which isn’t handled by LB IPAM.

Kubernetes >= v1.24 supports multiple load balancers in the same cluster. Picking between load balancers is done with the .spec.loadBalancerClass field. When LB IPAM is enabled it allocates and assigns IPs for services with no load balancer class set.

LB IPAM only does IP allocation and doesn’t provide load balancing services by itself. Therefore, users should pick one of the following Cilium load balancer classes, all of which use LB IPAM for allocation (if the feature is enabled):

io.cilium/bgp-control-plane

Cilium BGP Control Plane

io.cilium/l2-announcer

L2 Announcements / L2 Aware LB (Beta)

If the .spec.loadBalancerClass is set to a class which isn’t handled by Cilium’s LB IPAM, then Cilium’s LB IPAM will ignore the service entirely, not even setting a condition in the status.

By default, if the .spec.loadBalancerClass field is not set, Cilium’s LB IPAM will assume it can allocate IPs for the service from its configured pools. If this isn’t the desired behavior, you can configure LB-IPAM to only allocate IPs for services from its configured pools when it has a recognized load balancer class by setting the following configuration in the Helm chart or ConfigMap:

Services can request specific IPs. The legacy way of doing so is via .spec.loadBalancerIP which takes a single IP address. This method has been deprecated in k8s v1.24 but is supported until its future removal.

The new way of requesting specific IPs is to use annotations, lbipam.cilium.io/ips in the case of Cilium LB IPAM. This annotation takes a comma-separated list of IP addresses, allowing for multiple IPs to be requested at once.

The service selector of the IP Pool still applies, requested IPs will not be allocated or assigned if the services don’t match the pool’s selector.

Don’t configure the annotation to request the first or last IP of an IP pool. They are reserved for the network and broadcast addresses respectively.

Services can share the same IP or set of IPs with other services. This is done by setting the lbipam.cilium.io/sharing-key annotation on the service. Services that have the same sharing key annotation will share the same IP or set of IPs. The sharing key is a string that can be any value.

As long as the services do not have conflicting ports, they will be allocated the same IP. If the services have conflicting ports, they will be allocated different IPs, which will be added to the set of IPs belonging to the sharing key. If a service has a sharing key and also requests a specific IP, the service will be allocated the requested IP and it will be added to the set of IPs belonging to that sharing key.

By default, sharing IPs across namespaces is not allowed. To allow sharing across a namespace, set the lbipam.cilium.io/sharing-cross-namespace annotation to the namespaces the service can be shared with. The value must be a comma-separated list of namespaces. The annotation must be present on both services. You can allow all namespaces with *.

---

## Multi-cluster Networking — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/clustermesh/

**Contents:**
- Multi-cluster Networking

---

## eBPF Datapath — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/ebpf/

**Contents:**
- eBPF Datapath

---

## EKS-to-EKS Clustermesh Preparation — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/clustermesh/eks-clustermesh-prep/

**Contents:**
- EKS-to-EKS Clustermesh Preparation
- Install cluster one
- Install cluster two
- Peering virtual networks

This is a step-by-step guide on how to install and prepare AWS EKS (AWS Elastic Kubernetes Service) clusters to meet the requirements for the clustermesh feature.

In this guide you will install two EKS clusters and connect them together via clustermesh.

Create environmental variables that will be appended to each resource name.

Avoid using the 172.17.0.0/16 CIDR range for your VPC to prevent potential issues since certain AWS services utilize this range.

Create an internet gateway and NAT then attach it to the VPC.

Create route tables, routes, and route table associations.

Create a custom security group for the VPC. The default security group created with the EKS cluster only allows originating ingress traffic from the control-plane and other nodes within the cluster.

You now have a virtual private cloud, subnets, nat gateway, internet gateway, and a route table. You can create an EKS cluster without a CNI and request to use our custom VNet and subnet.

Create environmental variables that will be appended to each resource name.

Avoid using the 172.17.0.0/16 CIDR range for your VPC to prevent potential issues since certain AWS services utilize this range.

Create an internet and NAT gateway, then attach it to the VPC.

Create route tables, routes, and route table associations.

Create a custom security group for the VPC. The default security group created with the EKS cluster only allows originating ingress traffic from the control-plane and other nodes within the cluster.

You now have a virtual private cloud, subnets, NAT gateway, internet gateway, and a route table. You can create an EKS cluster without a CNI and request to use our custom VNet and subnet.

Create VPC peering between the two VPCs.

Forward traffic from Cluster 1 VPC to Cluster 2 VPC.

Forward traffic from Cluster 2 VPC to Cluster 1 VPC.

Nodes in different clusters can now communicate directly. All clustermesh requirements are fulfilled. Instructions for enabling clustermesh are detailed in the Setting up Cluster Mesh section.

---

## Defaults certificate for Ingresses — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/tls-default-certificate/

**Contents:**
- Defaults certificate for Ingresses
- Prerequisites
- Installation

Cilium can use a default certificate for ingresses without .spec.tls[].secretName set. It’s still necessary to have .spec.tls[].hosts defined.

Cilium must be configured with Kubernetes Ingress Support. Please refer to Kubernetes Ingress Support for more details.

Defaults certificate for Ingresses can be enabled with helm flags ingressController.defaultSecretNamespace and ingressController.defaultSecretName` set as true. Please refer to Installation using Helm for a fresh installation.

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

Cilium Ingress Controller can be enabled with the following command:

---

## BGP Control Plane Troubleshooting Guide — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/bgp-control-plane/bgp-control-plane-troubleshooting/

**Contents:**
- BGP Control Plane Troubleshooting Guide
- Even though Cilium BGP resources are applied, BGP peering is not established
  - CiliumBGPPeeringPolicy
  - CiliumBGPClusterConfig
- Node is selected by CiliumBGPPeeringPolicy or CiliumBGPClusterConfig, but BGP peer is not established
- The existing BGP session went down immediately after applying the new CiliumBGPPeeringPolicy
- Additional new CiliumBGPClusterConfig is not working
- CiliumBGPPeerConfig doesn’t take effect

This document enumerates typical troubles and their solutions when configuring the BGP Control Plane.

Check if the target Node is correctly selected by the nodeSelector of the CiliumBGPPeeringPolicy. The easiest way to do this is to use the cilium bgp peers command:

If the Node is selected correctly, even if the session is not established, the name of the Node and the BGP state will be displayed. If nothing is displayed, there may be an error in the nodeSelector. If the Node is correctly selected, but the state does not become established, check the settings of both Cilium and the target peer.

Check that the CiliumBGPNodeConfig resource is created for a given Node. If CiliumBGPNodeConfig resource is missing, check the Cilium operator logs for any errors.

Like CiliumBGPPeeringPolicy, check nodeSelector configuration and peering configuration if the BGP state is not established.

Another possibility is that the nodeSelector in the CiliumBGPClusterConfig doesn’t match any nodes due to the missing labels or misconfigured selector. In this case, the following status condition will be set:

You can identify the cause by referring to the logs of your peer router or Cilium. The errors logged by the BGP Control Plane have a field named subsys=bgp-control-plane, which can be used to filter logs for errors specific to BGP Control Plane:

In the example above, it can be seen that the BGP session was not established because there was a mismatch between the configured peerASN and the actual ASN of the peer.

There could be various reasons why BGP peering is not established, such as a mismatch in BGP capability or an incorrect Peer IP address. BGP layer errors are likely to appear in the logs, but there are cases where low-level errors, such as lack of connectivity to the Peer IP or when an eBGP peer is more than 1 hop away, may not be reflected in the logs. In such cases, using tools like WireShark or tcpdump can be effective.

A node may be selected by multiple CiliumBGPPeeringPolicy objects based on the configured nodeSelector fields. If multiple policies are applied, the BGP control plane will clear all pre-existing state configured on the node. First, rollback the last applied CiliumBGPPeeringPolicy and check the logs of the node where the BGP session went down. If multiple policies were applied, there should be logs indicating this:

If you find logs like this, please review the configuration of nodeSelector and make sure that each node only has one associated CiliumBGPPeeringPolicy.

Like the CiliumBGPPeeringPolicy, multiple CiliumBGPClusterConfig can select the same node based on the nodeSelector field. If this is the case, the Cilium operator will reject any additional CiliumBGPClusterConfig from creating the CiliumBGPNodeConfig resource. Following status condition will be set on the CiliumBGPClusterConfig to indicate this:

If the CiliumBGPPeerConfig is not taking effect, it may be because there is a misconfiguration (such as typo) in the peerConfigRef and the reference is not effective. Following status condition will be set if the referenced CiliumBGPPeerConfig is not found:

---

## BGP Peering Policy ( Legacy ) — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/bgp-control-plane/bgp-control-plane-v1/

**Contents:**
- BGP Peering Policy ( Legacy )
- Configure Peering
  - Specifying Router ID (IPv6 single-stack only)
  - Validating Peering Status
- Node Annotations
  - Overriding Router ID
  - Listening on the Local Port
- Advertising PodCIDRs
  - Kubernetes and ClusterPool IPAM
  - MultiPool IPAM

CiliumBGPPeeringPolicy will be discontinued in future. Consider using the new BGP APIs to configure the BGP Control Plane.

All BGP peering topology information is carried in a CiliumBGPPeeringPolicy CRD. A CiliumBGPPeeringPolicy can be applied to one or more nodes based on its nodeSelector field. Only a single CiliumBGPPeeringPolicy can be applied to a node. If multiple policies match a node, Cilium clears all BGP sessions until only one policy matches the node.

Applying another policy over an existing one will cause the BGP session to be cleared and causes immediate connectivity disruption. It is strongly recommended to test the policy in a staging environment before applying it to production.

Each CiliumBGPPeeringPolicy defines one or more virtualRouters. The virtual router defines a BGP router instance which is uniquely identified by its localASN. Each virtual router can have multiple neighbors defined. The neighbor defines a BGP neighbor uniquely identified by its peerAddress and peerASN. When localASN and peerASN are the same, iBGP peering is used. When localASN and peerASN are different, eBGP peering is used.

When Cilium is running on an IPv4 or a dual-stack, the BGP Router ID is automatically derived from the IPv4 address assigned to the node. When Cilium is running on an IPv6 single-stack cluster, the BGP Router ID must be configured manually. This can be done by setting the annotation on the Kubernetes Node resource:

Currently, you must set the annotation for each Node. In the future, automatic assignment of the Router ID may be supported. Follow #30333 for updates.

Once the CiliumBGPPeeringPolicy is applied, you can check the BGP peering status with the Cilium CLI with the following command:

A CiliumBGPPeeringPolicy can apply to multiple nodes. When a CiliumBGPPeeringPolicy applies to one or more nodes each node will instantiate one or more BGP routers as defined in virtualRouters. However, there are times when fine-grained control over an instantiated virtual router’s configuration needs to take place. This can be accomplished by applying a Kubernetes annotation to Kubernetes Node resources.

A single annotation is used to specify a set of configuration attributes to apply to a particular virtual router instantiated on a particular host.

The syntax of the annotation is as follows:

The {asn} portion should be replaced by the virtual router’s local ASN you wish to apply these configuration attributes to. Multiple option key/value pairs can be specified by separating them with a comma. When duplicate keys are defined with different values, the last key’s value will be used.

When Cilium is running on an IPv4 single-stack or a dual-stack, the BGP Control Plane can use the IPv4 address assigned to the node as the BGP Router ID because Router ID is 32bit long, and we can rely on the uniqueness of the IPv4 address to make Router ID unique which is not the case for IPv6. Thus, when running in an IPv6 single-stack, or when the auto assignment of the Router ID is not desired, the administrator needs to manually define it. This can be accomplished by setting the router-id key in the annotation.

By default, the BGP Control Plane instantiates each virtual router without a listening port. This means the BGP router can only initiate connections to the configured peers, but cannot accept incoming connections. This is the default behavior because the BGP Control Plane is designed to function in environments where another BGP router (such as Bird) is running on the same node. When it is required to accept incoming connections, the local-port key can be used to specify the listening port.

BGP Control Plane can advertise PodCIDR prefixes of the nodes selected by the CiliumBGPPeeringPolicy to the BGP peers. This allows the BGP peers to reach the Pods directly without involving load balancers or NAT. There are two ways to advertise PodCIDRs depending on the IPAM mode setting.

When Kubernetes or ClusterPool IPAM is used, set the virtualRouters[*].exportPodCIDR field to true.

With this configuration, the BGP speaker on each node advertises the PodCIDR prefixes assigned to the local node.

When MultiPool IPAM is used, specify the virtualRouters[*].podIPPoolSelector field. The .podIPPoolSelector field is a label selector that selects allocated CIDRs of CiliumPodIPPool matching the specified .matchLabels or .matchExpressions.

This advertises the PodCIDR prefixes allocated from the selected CiliumPodIPPools. Note that the CIDR must be allocated to a CiliumNode that matches the .nodeSelector for the virtual router to announce the PodCIDR as a BGP route.

If you wish to announce ALL CiliumPodIPPool CIDRs within the cluster, a NotIn match expression with a dummy key and value can be used like:

There are two special purpose selector fields that match CiliumPodIPPools based on name and/or namespace metadata instead of labels:

io.cilium.podippool.namespace

io.cilium.podippool.name

For additional details regarding CiliumPodIPPools, see the Multi-Pool (Beta) section.

When using other IPAM types, the BGP Control Plane does not support advertising PodCIDRs and specifying virtualRouters[*].exportPodCIDR doesn’t take any effect.

In Kubernetes, a Service has multiple virtual IP addresses, such as .spec.clusterIP, .spec.clusterIPs, .status.loadBalancer.ingress[*].ip and .spec.externalIPs. The BGP control plane can advertise the virtual IP address of the Service to BGP peers. This allows users to directly access the Service from outside the cluster.

To advertise the virtual IPs, specify the virtualRouters[*].serviceSelector field and the virtualRouters[*].serviceAdvertisements field. The .serviceAdvertisements defaults to the LoadBalancerIP service. You can also specify the .serviceAdvertisements field to advertise specific service types, with options such as LoadBalancerIP, ClusterIP and ExternalIP.

It is worth noting that when you configure virtualRouters[*].serviceAdvertisements as ClusterIP, the BGP Control Plane only considers the configuration of the service’s .spec.internalTrafficPolicy and ignores the configuration of .spec.externalTrafficPolicy. For ExternalIP and LoadBalancerIP, it only considers the configuration of the service’s .spec.externalTrafficPolicy and ignores the configuration of .spec.internalTrafficPolicy.

The .serviceSelector field is a label selector that selects Services matching the specified .matchLabels or .matchExpressions.

When your upstream router supports Equal Cost Multi Path(ECMP), you can use this feature to load balance traffic to the Service across multiple nodes by advertising the same ingress IPs from multiple nodes.

Many routers have a limit on the number of ECMP paths they can hold in their routing table (Juniper). When advertising the Service VIPs from many nodes, you may exceed this limit. We recommend checking the limit with your network administrator before using this feature.

If you wish to use this together with kubeProxyReplacement feature (see Kubernetes Without kube-proxy docs), please make sure the ExternalIP support is enabled.

If you only wish to advertise the .spec.externalIPs of Service, you can specify the virtualRouters[*].serviceAdvertisements field as ExternalIP.

If you wish to use this together with kubeProxyReplacement feature (see Kubernetes Without kube-proxy docs), specific BPF parameters need to be enabled. See External Access To ClusterIP Services section for how to enable it.

If you only wish to advertise the .spec.clusterIP and .spec.clusterIPs of Service, you can specify the virtualRouters[*].serviceAdvertisements field as ClusterIP.

Additionally, when the .spec.clusterIP or .spec.clusterIPs of the Service contains None, this IP address will be ignored and will not be advertised.

You must first allocate ingress IPs to advertise them. By default, Kubernetes doesn’t provide a way to assign ingress IPs to a Service. The cluster administrator is responsible for preparing a controller that assigns ingress IPs. Cilium supports assigning ingress IPs with the Load Balancer IPAM feature.

This advertises the ingress IPs of all Services matching the .serviceSelector.

If you wish to announce ALL services within the cluster, a NotIn match expression with a dummy key and value can be used like:

There are a few special purpose selector fields which don’t match on labels but instead on other metadata like .meta.name or .meta.namespace.

io.kubernetes.service.namespace

io.kubernetes.service.name

Cilium supports the loadBalancerClass. When the load balancer class is set to io.cilium/bgp-control-plane or unspecified, Cilium will announce the ingress IPs of the Service. Otherwise, Cilium will not announce the ingress IPs of the Service.

When the Service has externalTrafficPolicy: Cluster, BGP Control Plane unconditionally advertises the ingress IPs of the selected Service. When the Service has externalTrafficPolicy: Local, BGP Control Plane keeps track of the endpoints for the service on the local node and stops advertisement when there’s no local endpoint.

Get all IPv4 unicast routes available:

Get all IPv4 unicast routes available for a specific vrouter:

Get IPv4 unicast routes advertised to a specific peer:

Each virtualRouters can contain multiple neighbors. You can specify various BGP peering options for each neighbor. This section describes the available options and use cases.

Change of an existing neighbor configuration can cause reset of the existing BGP peering connection, which results in route flaps and transient packet loss while the session reestablishes and peers exchange their routes. To prevent packet loss, it is recommended to configure BGP Graceful Restart.

By default, the BGP Control Plane uses port 179 for BGP peering. When the neighbor is running on a non-standard port, you can specify the port number with the peerPort field.

BGP Control Plane supports modifying the following BGP timer parameters. For more detailed description for each timer parameters, please refer to RFC4271.

connectRetryTimeSeconds

In datacenter networks which Kubernetes clusters are deployed, it is generally recommended to set the HoldTimer and KeepaliveTimer to a lower value for faster possible failure detection. For example, you can set the minimum possible values holdTimeSeconds=9 and keepAliveTimeSeconds=3.

By default, IP TTL of the BGP packets is set to 1 in eBGP. Generally, it is encouraged to not change the TTL, but in some cases, you may need to change the TTL value. For example, when the BGP peer is a Route Server and located in a different subnet, you may need to set the TTL value to more than 1.

By configuring authSecretRef for a neighbor you can configure that a RFC-2385 TCP MD5 password should be configured on the session with this BGP peer.

authSecretRef should reference the name of a secret in the BGP secrets namespace (if using the Helm chart this is kube-system by default). The secret should contain a key with a name of password.

BGP secrets are limited to a configured namespace to keep the permissions needed on each Cilium Agent instance to a minimum. The Helm chart will configure Cilium to be able to read from it by default.

An example of creating a secret is:

If you wish to change the namespace, you can set the bgpControlPlane.secretNamespace.name Helm chart value. To have the namespace created automatically, you can set the bgpControlPlane.secretNamespace.create Helm chart value to true.

Because TCP MD5 passwords sign the header of the packet they cannot be used if the session will be address translated by Cilium (i.e. the Cilium Agent’s pod IP address must be the address the BGP peer sees).

If the password is incorrect, or the header is otherwise changed the TCP connection will not succeed. This will appear as dial: i/o timeout in the Cilium Agent’s logs rather than a more specific error message.

If a CiliumBGPPeeringPolicy is deployed with an authSecretRef that Cilium cannot find, the BGP session will use an empty password and the agent will log an error such as in the following example:

The Cilium BGP Control Plane can be configured to act as a graceful restart Restarting Speaker. When you enable graceful restart, the BGP session will restart and the “graceful restart” capability will be advertised in the BGP OPEN message.

In the event of a Cilium Agent restart, the peering BGP router does not withdraw routes received from the Cilium BGP control plane immediately. The datapath continues to forward traffic during Agent restart, so there is no traffic disruption.

Configure graceful restart on per-neighbor basis, as follows:

Optionally, you can use the RestartTime parameter. RestartTime is the time advertised to the peer within which Cilium BGP control plane is expected to re-establish the BGP session after a restart. On expiration of RestartTime, the peer removes the routes previously advertised by the Cilium BGP control plane.

When the Cilium Agent restarts, it closes the BGP TCP socket, causing the emission of a TCP FIN packet. On receiving this TCP FIN, the peer changes its BGP state to Idle and starts its RestartTime timer.

The Cilium agent boot up time varies depending on the deployment. If using RestartTime, you should set it to a duration greater than the time taken by the Cilium Agent to boot up.

Default value of RestartTime is 120 seconds. More details on graceful restart and RestartTime can be found in RFC-4724 and RFC-8538.

BGP advertisements can be extended with additional BGP Path Attributes - BGP Communities (RFC-1997) or Local Preference. These Path Attributes can be configured selectively for each BGP peer and advertisement type.

The following code block shows an example configuration of AdvertisedPathAttributes for a BGP neighbor, which adds a BGP community attribute with the value 64512:100 to all Service announcements from the matching CiliumLoadBalancerIPPool and sets the Local Preference value for all Pod CIDR announcements to the value 150:

Note that Local Preference Path Attribute is sent only to iBGP peers (not to eBGP peers).

Each AdvertisedPathAttributes configuration item consists of two parts:

SelectorType with Selector define which BGP advertisements will be extended with additional Path Attributes.

Communities and / or LocalPreference define the additional Path Attributes applied on the selected routes.

There are three possible values of the SelectorType which define the object type on which the Selector applies:

PodCIDR: matches CiliumNode custom resources (Path Attributes apply to routes announced for PodCIDRs of selected CiliumNode objects).

CiliumLoadBalancerIPPool: matches CiliumLoadBalancerIPPool custom resources (Path Attributes apply to routes announced for selected CiliumLoadBalancerIPPool objects).

CiliumPodIPPool: matches CiliumPodIPPool custom resources (Path Attributes apply to routes announced for allocated prefixes of selected CiliumPodIPPool objects).

There are two types of additional Path Attributes that can be advertised with the routes: Communities and LocalPreference.

Communities defines a set of community values advertised in the supported BGP Communities Path Attributes. The values can be of three types:

Standard: represents a value of the “standard” 32-bit BGP Communities Attribute (RFC-1997) as a 4-byte decimal number or two 2-byte decimal numbers separated by a colon (e.g. 64512:100).

WellKnown: represents a value of the “standard” 32-bit BGP Communities Attribute (RFC-1997) as a well-known string alias to its numeric value. Allowed values and their mapping to the numeric values:

route-filter-translated-v4

route-filter-translated-v6

Large: represents a value of the BGP Large Communities Attribute (RFC-8092), as three 4-byte decimal numbers separated by colons (e.g. 64512:100:50).

LocalPreference defines the preference value advertised in the BGP Local Preference Path Attribute. As Local Preference is only valid for iBGP peers, this value will be ignored for eBGP peers (no Local Preference Path Attribute will be advertised).

Once configured, the additional Path Attributes advertised with the routes for a peer can be verified using the cilium bgp routes Cilium CLI command, for example:

By default, the BGP Control Plane advertises IPv4 Unicast and IPv6 Unicast Multiprotocol Extensions Capability (RFC-4760) as well as Graceful Restart address families (RFC-4724) if enabled. If you wish to change the default behavior and advertise only specific address families, you can use the families field. The families field is a list of AFI (Address Family Identifier) and SAFI (Subsequent Address Family Identifier) pairs. The only options currently supported are {afi: ipv4, safi: unicast} and {afi: ipv6, safi: unicast}.

Following example shows how to advertise only IPv4 Unicast address family:

---

## HTTP Migration Example — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/ingress-to-gateway/http-migration/

**Contents:**
- HTTP Migration Example
- Review Ingress Configuration
- Create Equivalent Gateway Configuration
- Review Equivalent Gateway Configuration

This example shows you how to migrate an existing Ingress configuration to the equivalent Gateway API resource.

The Cilium Ingress HTTP Example serves as the starting Ingress configuration. The same approach applies to other controllers, though each Ingress controller configuration varies.

The example Ingress configuration routes traffic to backend services from the bookinfo demo microservices app from the Istio project.

You can find the example Ingress definition in basic-ingress.yaml.

This example listens for traffic on port 80, routes requests for the path /details to the details service, and / to the productpage service.

To create the equivalent Gateway configuration, consider the following:

The entry point is a combination of an IP address and port through which external clients access the data plane.

Every Ingress resource has two implicit entry points – one for HTTP and the other for HTTPS traffic. An Ingress controller provides the entry points. Typically, entry points are either shared by all Ingress resources, or every Ingress resource has dedicated entry points.

In the Gateway API, entry points must be explicitly defined in a Gateway resource. For example, for the data plane to handle HTTP traffic on port 80, you must define a listener for that traffic. Typically, a Gateway implementation provides a dedicated data plane for each Gateway resource.

When using Ingress or Gateway API, routing rules must be defined to attach applications to those entry points.

The path-based routing rules are configured in the Ingress resource.

In the Ingress resource, each hostname has separate routing rules:

The routing rules are configured in the HTTPRoute.

Selecting Data Plane to Attach to:

Both Ingress and Gateway API resources must be explicitly attached to a Dataplane.

An Ingress resource must specify a class that selects which Ingress controller to use.

A Gateway resource must also specify a class: in this example, it is always the cilium class. An HTTPRoute must specify which Gateway (or Gateways) to attach to via a parentRef.

You can find the equivalent final Gateway and HTTPRoute definition in http-migration.yaml.

The preceding example creates a Gateway named cilium-gateway that listens on port 80 for HTTP traffic. Two routes are defined, one for /details to the details service, and one for / to the productpage service.

Deploy the resources and verify that the HTTP requests are routed successfully to the services. For more information, consult the Gateway API HTTP Example.

---

## L2 Announcements / L2 Aware LB (Beta) — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/l2-announcements/

**Contents:**
- L2 Announcements / L2 Aware LB (Beta)
- Configuration
- Prerequisites
- Limitations
- Policies
  - Service Selector
  - Node Selector
  - Interfaces
  - IP Types
  - Status

This is a beta feature. Please provide feedback and file a GitHub issue if you experience any problems.

L2 Announcements is a feature which makes services visible and reachable on the local area network. This feature is primarily intended for on-premises deployments within networks without BGP based routing such as office or campus networks.

When used, this feature will respond to ARP queries for ExternalIPs and/or LoadBalancer IPs. These IPs are Virtual IPs (not installed on network devices) on multiple nodes, so for each service one node at a time will respond to the ARP queries and respond with its MAC address. This node will perform load balancing with the service load balancing feature, thus acting as a north/south load balancer.

The advantage of this feature over NodePort services is that each service can use a unique IP so multiple services can use the same port numbers. When using NodePorts, it is up to the client to decide to which host to send traffic, and if a node goes down, the IP+Port combo becomes unusable. With L2 announcements the service VIP simply migrates to another node and will continue to work.

The L2 Announcements feature and all the requirements can be enabled as follows:

Sizing the client rate limit (k8sClientRateLimit.qps and k8sClientRateLimit.burst) is important when using this feature due to increased API usage. See Sizing client rate limit for sizing guidelines.

Kube Proxy replacement mode must be enabled. For more information, see Kubernetes Without kube-proxy.

All devices on which L2 Aware LB will be announced should be enabled and included in the --devices flag or devices Helm option if explicitly set, see NodePort Devices, Port and Bind settings.

The externalIPs.enabled=true Helm option must be set, if usage of externalIPs is desired. Otherwise service load balancing for external IPs is disabled.

The feature currently does not support IPv6/NDP.

Due to the way L3->L2 translation protocols work, one node receives all ARP requests for a specific IP, so no load balancing can happen before traffic hits the cluster.

The feature currently has no traffic balancing mechanism so nodes within the same policy might be asymmetrically loaded. For details see Leader Election.

The feature is incompatible with the externalTrafficPolicy: Local on services as it may cause service IPs to be announced on nodes without pods causing traffic drops.

Policies provide fine-grained control over which services should be announced, where, and how. This is an example policy using all optional fields:

The service selector is a label selector that determines which services are selected by this policy. If no service selector is provided, all services are selected by the policy. A service must have loadBalancerClass unspecified or set to io.cilium/l2-announcer to be selected by a policy for announcement.

There are a few special purpose selector fields which don’t match on labels but instead on other metadata like .meta.name or .meta.namespace.

io.kubernetes.service.namespace

io.kubernetes.service.name

The node selector field is a label selector which determines which nodes are candidates to announce the services from.

It might be desirable to pick a subset of nodes in you cluster, since the chosen node (see Leader Election) will act as the north/south load balancer for all of the traffic for a particular service.

The interfaces field is a list of regular expressions (golang syntax) that determine over which network interfaces the selected services will be announced. This field is optional, if not specified all interfaces will be used.

The expressions are OR-ed together, so any network device matching any of the expressions will be matched.

L2 announcements only work if the selected devices are also part of the set of devices specified in the devices Helm option, see NodePort Devices, Port and Bind settings.

This selector is NOT a security feature, services will still be available via interfaces when not advertised (for example by hard-coding ARP entries).

The externalIPs and loadBalancerIPs fields determine what sort of IPs are announced. They are both set to false by default, so a functional policy should always have one or both set to true.

If externalIPs is true all IPs in .spec.externalIPs field are announced. These IPs are managed by service authors.

If loadBalancerIPs is true all IPs in the service’s .status.loadbalancer.ingress field are announced. These can be assigned by LoadBalancer IP Address Management (LB IPAM) which can be configured by cluster admins for better control over which IPs can be allocated.

If a user intends to use externalIPs, the externalIPs.enable=true Helm option should be set to enable service load balancing for external IPs.

If a policy is invalid for any number of reasons, the status of the policy will reflect that. For example if an invalid match expression is provided:

The status of these error conditions will go to False as soon as the user updates the policy to resolve the error.

Due to the way ARP/NDP works, hosts only store one MAC address per IP, that being the latest reply they see. This means that only one node in the cluster is allowed to reply to requests for a given IP.

To implement this behavior, every Cilium agent resolves which services are selected for its node and will start participating in leader election for every service. We use Kubernetes lease mechanism to achieve this. Each service translates to a lease, the lease holder will start replying to requests on the selected interfaces.

The lease mechanism is a first come, first serve picking order. So the first node to claim a lease gets it. This might cause asymmetric traffic distribution.

The leases are created in the same namespace where Cilium is deployed, typically kube-system. You can inspect the leases with the following command:

The leases starting with cilium-l2announce- are leases used by this feature. The last part of the name is the namespace and service name. The holder indicates the name of the node that currently holds the lease and thus announced the IPs of that given service.

The acquireTime is the time at which the current leader acquired the lease. The holderIdentity is the name of the current holder/leader node. If the leader does not renew the lease for leaseDurationSeconds seconds a new leader is chosen. leaseTransitions indicates how often the lease changed hands and renewTime the last time the leader renewed the lease.

There are three Helm options that can be tuned with regards to leases:

l2announcements.leaseDuration determines the leaseDurationSeconds value of created leases and by extent how long a leader must be “down” before failover occurs. Its default value is 15s, it must always be greater than 1s and be larger than leaseRenewDeadline.

l2announcements.leaseRenewDeadline is the interval at which the leader should renew the lease. Its default value is 5s, it must be greater than leaseRetryPeriod by at least 20% and is not allowed to be below 1ns.

l2announcements.leaseRetryPeriod if renewing the lease fails, how long should the agent wait before it tries again. Its default value is 2s, it must be smaller than leaseRenewDeadline by at least 20% and above 1ns.

The theoretical shortest time between failure and failover is leaseDuration - leaseRenewDeadline and the longest leaseDuration + leaseRenewDeadline. So with the default values, failover occurs between 10s and 20s. For the example below, these times are between 2s and 4s.

There is a trade-off between fast failure detection and CPU + network usage. Each service incurs a CPU and network overhead, so clusters with smaller amounts of services can more easily afford faster failover times. Larger clusters might need to increase parameters if the overhead is too high.

The leader election process continually generates API traffic, the exact amount depends on the configured lease duration, configured renew deadline, and amount of services using the feature.

The default client rate limit is 5 QPS with allowed bursts up to 10 QPS. this default limit is quickly reached when utilizing L2 announcements and thus users should size the client rate limit accordingly.

In a worst case scenario, services are distributed unevenly, so we will assume a peak load based on the renew deadline. In complex scenarios with multiple policies over disjointed sets of node, max QPS per node will be lower.

Setting the base QPS to around the calculated value should be sufficient, given in multi-node scenarios leases are spread around nodes, and non-holders participating in the election have a lower QPS.

The burst QPS should be slightly higher to allow for bursts of traffic caused by other features which also use the API server.

When nodes participating in leader election detect that the lease holder did not renew the lease for leaseDurationSeconds amount of seconds, they will ask the API server to make them the new holder. The first request to be processed gets through and the rest are denied.

When a node becomes the leader/holder, it will send out a gratuitous ARP reply over all of the configured interfaces. Clients who accept these will update their ARP tables at once causing them to send traffic to the new leader/holder. Not all clients accept gratuitous ARP replies since they can be used for ARP spoofing. Such clients might experience longer downtime then configured in the leases since they will only re-query via ARP when TTL in their internal tables has been reached.

Since this feature has no IPv6 support yet, only ARP messages are sent, no Unsolicited Neighbor Advertisements are sent.

This section is a step by step guide on how to troubleshoot L2 Announcements, hopefully solving your issue or narrowing it down to a specific area.

The first thing we need to do is to check that the feature is enabled, kube proxy replacement is active and optionally that external IPs are enabled.

If EnableL2Announcements or KubeProxyReplacement indicates false, make sure to enable the correct settings and deploy the helm chart Configuration. EnableExternalIPs should be set to true if you intend to use external IPs.

Next, ensure you have at least one policy configured, L2 announcements will not work without a policy.

L2 announcements should now create a lease for every service matched by the policy. We can check the leases like so:

If the output is empty, then the policy is not correctly configured or the agent is not running correctly. Check the logs of the agent for error messages:

A common error is that the agent is not able to create leases.

This can happen if the cluster role of the agent is not correct. This tends to happen when L2 announcements is enabled without using the helm chart. Redeploy the helm chart or manually update the cluster role, by running kubectl edit clusterrole cilium and adding the following block to the rules:

Another common error is that the configured client rate limit is too low. This can be seen in the logs as well:

These logs are associated with intermittent failures to renew the lease, connection issues and/or frequent leader changes. See Sizing client rate limit for more information on how to size the client rate limit.

If you find a different L2 related error, please open a GitHub issue with the error message and the steps you took to get there.

Assuming the leases are created, the next step is to check the agent internal state. Pick a service which isn’t working and inspect its lease. Take the holder name and find the cilium agent pod for the holder node. Finally, take the name of the cilium agent pod and inspect the l2-announce state:

The l2 announce state should contain the IP of the service and the network interface it is announced on. If the lease is present but its IP is not in the l2-announce state, or you are missing an entry for a given network device. Double check that the device selector in the policy matches the desired network device (values are regular expressions). If the filter seems correct or isn’t specified, inspect the known devices:

Only devices with Selected set to true can be used for L2 announcements. Typically all physical devices with IPs assigned to them will be considered selected. The --devices flag or devices Helm option can be used to filter out devices. If your desired device is in the list but not selected, check the devices flag/option to see if it filters it out.

Please open a Github issue if your desired device doesn’t appear in the list or it isn’t selected while you believe it should be.

If the L2 state contains the IP and device combination but there are still connection issues, it’s time to test ARP within the cluster. Pick a cilium agent pod other than the lease holder on the same L2 network. Then use the following command to send an ARP request to the service IP:

If the output is as above yet the service is still unreachable, from clients within the same L2 network, the issue might be client related. If you expect the service to be reachable from outside the L2 network, and it is not, check the ARP and routing tables of the gateway device.

If the ARP request fails (the output shows Timeout), check the BPF map of the cilium-agent with the lease:

The responses_sent field is incremented every time the datapath responds to an ARP request. If the field is 0, then the ARP request doesn’t make it to the node. If the field is greater than 0, the issue is on the return path. In both cases, inspect the network and the client.

It is still possible that the service is unreachable even though ARP requests are answered. This can happen for a number of reasons, usually unrelated to L2 announcements, but rather other Cilium features.

One common issue however is caused by the usage of .Spec.ExternalTrafficPolicy: Local on services. This setting normally tells a load balancer to only forward traffic to nodes with at least 1 ready pod to avoid a second hop. Unfortunately, L2 announcements isn’t currently aware of this setting and will announce the service IP on all nodes matching policies. If a node without a pod receives traffic, it will drop it. To fix this, set the policy to .Spec.ExternalTrafficPolicy: Cluster.

Please open a Github issue if none of the above steps helped you solve your issue.

L2 Pod Announcements announce Pod IP addresses on the L2 network using Gratuitous ARP replies. When enabled, the node transmits Gratuitous ARP replies for every locally created pod, on the configured network interface(s). This feature is enabled separately from the above L2 announcements feature.

To enable L2 Pod Announcements, set the following:

The l2podAnnouncements.interface/l2-pod-announcements-interface options allows you to specify one interface use to send announcements. If you would like to send announcements on multiple interfaces, you should use the l2podAnnouncements.interfacePattern/l2-pod-announcements-interface-pattern option instead. This option takes a regex, matching on multiple interfaces.

Since this feature has no IPv6 support yet, only ARP messages are sent, no Unsolicited Neighbor Advertisements are sent.

---

## Using BIRD to run BGP (deprecated) — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/bird/

**Contents:**
- Using BIRD to run BGP (deprecated)
- Install bird
- Basic configuration
- Monitoring
- Advanced Configurations
  - BFD
  - ECMP
  - Graceful restart

BIRD is an open-source implementation for routing Internet Protocol packets on Unix-like operating systems. If you are not familiar with it, you had best have a glance at the User’s Guide first.

BIRD provides a way to advertise routes using traditional networking protocols to allow Cilium-managed endpoints to be accessible outside the cluster. This guide assumes that Cilium is already deployed in the cluster, and that the remaining piece is how to ensure that the pod CIDR ranges are externally routable.

BIRD maintains two release families at present: 1.x and 2.x, and the configuration format varies a lot between them. Unless you have already deployed the 1.x, we suggest using 2.x directly, as the 2.x will live longer. The following examples will denote bird as the bird2 software and use configuration in the format that bird2 understands.

This guide shows how to install and configure bird on CentOS 7.x to make it collaborate with Cilium. Installation and configuration on other platforms should be very similar.

Test the installation:

It’s hard to discuss bird configurations without considering specific BGP schemes. However, BGP scheme design is beyond the scope of this guide. If you are interested in this topic, refer to BGP in the Data Center (O’Reilly, 2017) for a quick start.

In the following, we will restrict our BGP scenario as follows:

physical network: simple 3-tier hierarchical architecture

nodes connect to physical network via layer 2 switches

announcing each node’s PodCIDR to physical network via bird

for each node, do not import route announcements from physical network

In this design, the BGP connections look like this:

This scheme is simple in that:

core routers learn PodCIDRs from bird, which makes the Pod IP addresses routable within the entire network.

bird doesn’t learn routes from core routers and other nodes, which keeps the kernel routing table of each node clean and small, and suffering no performance issues.

In this scheme, each node just sends pod egress traffic to node’s default gateway (the core routers), and lets the latter do the routing.

Below is the a reference configuration for fulfilling the above purposes:

Save the above file as /etc/bird.conf, and replace the placeholders with your own:

Restart bird and check the logs:

Verify the changes, you should get something like this:

This indicates that the PodCIDR 10.5.48.0/24 on this node has been successfully imported into BIRD.

Here we see that the uplink0 BGP session is established and our PodCIDR from above has been exported and accepted by the BGP peer.

bird_exporter could collect bird daemon states, and export Prometheus-style metrics.

It also provides a simple Grafana dashboard, but you could also create your own, e.g. Trip.com’s looks like this:

You may need some advanced configurations to make your BGP scheme production-ready. This section lists some of these parameters, but we will not dive into details, that’s BIRD User’s Guide’s responsibility.

Bidirectional Forwarding Detection (BFD) is a detection protocol designed to accelerate path failure detection.

This feature also relies on peer side’s configuration.

Verify, you should see something like this:

For some special purposes (e.g. L4LB), you may configure a same CIDR on multiple nodes. In this case, you need to configure Equal-Cost Multi-Path (ECMP) routing.

This feature also relies on peer side’s configuration.

See the user manual for more detailed information.

You need to check the ECMP correctness on physical network (Core router in the above scenario):

This feature also relies on peer side’s configuration.

Add graceful restart to each bgp section:

---

## CRD-Backed by Cilium Multi-Pool IPAM (Beta) — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/kubernetes/ipam-multi-pool/

**Contents:**
- CRD-Backed by Cilium Multi-Pool IPAM (Beta)
- Enable Multi-pool IPAM mode
- Validate installation

This is a beta feature. Please provide feedback and file a GitHub issue if you experience any problems.

This is a quick tutorial walking through how to enable multi-pool IPAM backed by the CiliumPodIPPool CRD. The purpose of this tutorial is to show how components are configured and resources interact with each other to enable users to automate or extend on their own.

For more details, see the section Multi-Pool (Beta)

Setup Cilium for Kubernetes using helm with the options:

--set ipam.mode=multi-pool

--set kubeProxyReplacement=true

--set bpf.masquerade=true

For more details on why each of these options are needed, please refer to Limitations.

Create the default pool for IPv4 addresses with the options:

--set ipam.operator.autoCreateCiliumPodIPPools.default.ipv4.cidrs='{10.10.0.0/16}'

--set ipam.operator.autoCreateCiliumPodIPPools.default.ipv4.maskSize=27

Deploy Cilium and Cilium-Operator. Cilium will automatically wait until the podCIDR is allocated for its node by Cilium Operator.

Validate that Cilium has started up correctly

Validate that the CiliumPodIPPool resource for the default pool was created with the CIDRs specified in the ipam.operator.autoCreateCiliumPodIPPools.default.* Helm values:

Create an additional pod IP pool mars using the following CiliumPodIPPool resource:

Validate that both pool resources exist:

Create two deployments with two pods each. One allocating from the default pool and one allocating from the mars pool by way of the ipam.cilium.io/ipam-pool: mars annotation:

Validate that the pods were assigned IPv4 addresses from different CIDRs as specified in the pool definition:

Test connectivity between pods:

Alternatively, the ipam.cilium.io/ipam-pool annotation can also be applied to a namespace:

All new pods created in the namespace cilium-test-1 will be assigned IPv4 addresses from the mars pool. Run the Cilium connectivity tests (which use namespace cilium-test-1 by default to create their workloads) to verify connectivity:

Note: The connectivity test requires a cluster with at least 2 worker nodes to complete successfully.

Verify that the connectivity test pods were assigned IPv4 addresses from the 10.20.0.0/16 CIDR defined in the mars pool:

---

## Google Kubernetes Engine — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/concepts/ipam/gke/

**Contents:**
- Google Kubernetes Engine
- Architecture
- Configuration
- Troubleshooting
  - Validate the exposed PodCIDR field
  - Check the Cilium status

When running Cilium on Google GKE, the native networking layer of Google Cloud will be utilized for address management and IP forwarding.

Cilium running in a GKE configuration mode utilizes the Kubernetes hostscope IPAM mode. It will configure the Cilium agent to wait until the Kubernetes node resource is populated with a spec.podCIDR or spec.podCIDRs as required by the enabled address families (IPv4/IPv6). See Kubernetes Host Scope for additional details of this IPAM mode.

The corresponding datapath is described in section Google Cloud.

See the getting started guide Cilium Quick Installation to install Cilium Google Kubernetes Engine (GKE).

The GKE IPAM mode can be enabled by setting the Helm option ipam.mode=kubernetes or by setting the ConfigMap option ipam: kubernetes.

Check if the Kubernetes nodes contain a value in the podCIDR field:

Run cilium status on the node in question and validate that the CIDR used for IPAM matches the PodCIDR announced in the Kubernetes node:

---

## Kubernetes Ingress Support — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/ingress/

**Contents:**
- Kubernetes Ingress Support
- Prerequisites
- Installation
- Reference
  - How Cilium Ingress and Gateway API differ from other Ingress controllers
  - Cilium’s ingress config and CiliumNetworkPolicy
  - Source IP Visibility
    - externalTrafficPolicy for Loadbalancer or NodePort Services
    - TLS Passthrough and source IP visibility
  - Ingress Path Types and Precedence

Cilium uses the standard Kubernetes Ingress resource definition, with an ingressClassName of cilium. This can be used for path-based routing and for TLS termination. For backwards compatibility, the kubernetes.io/ingress.class annotation with value of cilium is also supported.

The ingress controller creates a Service of LoadBalancer type, so your environment will need to support this.

Cilium allows you to specify load balancer mode for the Ingress resource:

dedicated: The Ingress controller will create a dedicated loadbalancer for the Ingress.

shared: The Ingress controller will use a shared loadbalancer for all Ingress resources.

Each load balancer mode has its own benefits and drawbacks. The shared mode saves resources by sharing a single LoadBalancer config across all Ingress resources in the cluster, while the dedicated mode can help to avoid potential conflicts (e.g. path prefix) between resources.

It is possible to change the load balancer mode for an Ingress resource. When the mode is changed, active connections to backends of the Ingress may be terminated during the reconfiguration due to a new load balancer IP address being assigned to the Ingress resource.

This is a step-by-step guide on how to enable the Ingress Controller in an existing K8s cluster with Cilium installed.

Cilium must be configured with NodePort enabled, using nodePort.enabled=true or by enabling the kube-proxy replacement with kubeProxyReplacement=true. For more information, see kube-proxy replacement.

Cilium must be configured with the L7 proxy enabled using l7Proxy=true (enabled by default).

By default, the Ingress controller creates a Service of LoadBalancer type, so your environment will need to support this. Alternatively, you can change this to NodePort or, since Cilium 1.16+, directly expose the Cilium L7 proxy on the host network.

Cilium Ingress Controller can be enabled with helm flag ingressController.enabled set as true. Please refer to Installation using Helm for a fresh installation.

Cilium can become the default ingress controller by setting the --set ingressController.default=true flag. This will create ingress entries even when the ingressClass is not set.

If you only want to use envoy traffic management feature without Ingress support, you should only enable --enable-envoy-config flag.

Additionally, the proxy load-balancing feature can be configured with the loadBalancer.l7.backend=envoy flag.

Next you can check the status of the Cilium agent and operator:

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

Cilium Ingress Controller can be enabled with the below command

Cilium can become the default ingress controller by setting the --set ingressController.default=true flag. This will create ingress entries even when the ingressClass is not set.

If you only want to use envoy traffic management feature without Ingress support, you should only enable --enable-envoy-config flag.

Additionally, the proxy load-balancing feature can be configured with the loadBalancer.l7.backend=envoy flag.

Next you can check the status of the Cilium agent and operator:

It is also recommended that you install Hubble CLI which will be used used to observe the traffic in later steps.

One of the biggest differences between Cilium’s Ingress and Gateway API support and other Ingress controllers is how closely tied the implementation is to the CNI. For Cilium, Ingress and Gateway API are part of the networking stack, and so behave in a different way to other Ingress or Gateway API controllers (even other Ingress or Gateway API controllers running in a Cilium cluster).

Other Ingress or Gateway API controllers are generally installed as a Deployment or Daemonset in the cluster, and exposed via a Loadbalancer Service or similar (which Cilium can, of course, enable).

Cilium’s Ingress and Gateway API config is exposed with a Loadbalancer or NodePort service, or optionally can be exposed on the Host network also. But in all of these cases, when traffic arrives at the Service’s port, eBPF code intercepts the traffic and transparently forwards it to Envoy (using the TPROXY kernel facility).

This affects things like client IP visibility, which works differently for Cilium’s Ingress and Gateway API support to other Ingress controllers.

It also allows Cilium’s Network Policy engine to apply CiliumNetworkPolicy to traffic bound for and traffic coming from an Ingress.

Ingress and Gateway API traffic bound to backend services via Cilium passes through a per-node Envoy proxy.

The per-node Envoy proxy has special code that allows it to interact with the eBPF policy engine, and do policy lookups on traffic. This allows Envoy to be a Network Policy enforcement point, both for Ingress (and Gateway API) traffic, and also for east-west traffic via GAMMA or L7 Traffic Management.

However, for ingress config, there’s also an additional step. Traffic that arrives at Envoy for Ingress or Gateway API is assigned the special ingress identity in Cilium’s Policy engine.

Traffic coming from outside the cluster is usually assigned the world identity (unless there are IP CIDR policies in the cluster). This means that there are actually two logical Policy enforcement points in Cilium Ingress - before traffic arrives at the ingress identity, and after, when it is about to exit the per-node Envoy.

This means that, when applying Network Policy to a cluster, it’s important to ensure that both steps are allowed, and that traffic is allowed from world to ingress, and from ingress to identities in the cluster (like the productpage identity in the image above).

Please see the Ingress and Network Policy Example for more details for Ingress, although the same principles also apply for Gateway API.

By default, source IP visibility for Cilium ingress config, both Ingress and Gateway API, should just work on most installations. Read this section for more information on requirements and relevant settings.

Having a backend be able to deduce what IP address the actual request came from is important for most applications.

By default, Cilium’s Envoy instances are configured to append the visible source address of incoming HTTP connections to the X-Forwarded-For header, using the usual rules. That is, by default Cilium sets the number of trusted hops to 0, indicating that Envoy should use the address the connection is opened from, rather than a value inside the X-Forwarded-For list. Increasing this count will have Envoy use the n th value from the list, counting from the right.

Envoy will also set the X-Envoy-External-Address header to the trusted client address, whatever that turns out to be, based on X-Forwarded-For.

Backends using Cilium ingress (whether via Ingress or Gateway API) should just see the X-Forwarded-For and X-Envoy-External-Address headers (which are handled transparently by many HTTP libraries).

Cilium’s ingress support (both for Ingress and Gateway API) often uses a Loadbalancer or NodePort Service to expose the Envoy Daemonset.

In these cases, the Service object has one field that is particularly relevant to Client IP visibility - the externalTrafficPolicy field.

It has two relevant settings:

Local: Nodes will only route traffic to Pods running on the local node, without masquerading the source IP. Because of this, in clusters that use kube-proxy, this is the only way to ensure source IP visibility. Part of the contract for externalTrafficPolicy local is also that the node will open a port (the healthCheckNodePort, automatically set by Kubernetes when externalTrafficPolicy: Local is set), and requests to http://<nodeIP>:<healthCheckNodePort>/healthz will return 200 on nodes that have local pods running, and non-200 on nodes that don’t. Cilium implements this for general Loadbalancer Services, but it’s a bit different for Cilium ingress config (both Ingress and Gateway API).

Cluster: Node will route to all endpoints across the cluster evenly. This has a couple of other effects: Firstly, upstream loadbalancers will expect to be able to send traffic to any node and have it end up at a backend Pod, and the node may masquerade the source IP. This means that in many cases, externalTrafficPolicy: Cluster may mean that the backend pod does not see the source IP.

In Cilium’s case, all ingress traffic bound for a Service that exposes Envoy is always going to the local node, and is always forwarded to Envoy using the Linux Kernel TPROXY function, which transparently forwards packets to the backend.

This means that for Cilium ingress config, for both Ingress and Gateway API, things work a little differently in both externalTrafficPolicy cases.

In both externalTrafficPolicy cases, traffic will arrive at any node in the cluster, and be forwarded to Envoy while keeping the source IP intact.

Also, for any Services that exposes Cilium’s Envoy, Cilium will ensure that when externalTrafficPolicy: Local is set, every node in the cluster will pass the healthCheckNodePort check, so that external load balancers will forward correctly.

However, for Cilium’s ingress config, both Ingress and Gateway API, it is not necessary to configure externalTrafficPolicy: Local to keep the source IP visible to the backend pod (via the X-Forwarded-For and X-Envoy-External-Address fields).

Both Ingress and Gateway API support TLS Passthrough configuration (via annotation for Ingress, and the TLSRoute resource for Gateway API). This configuration allows multiple TLS Passthrough backends to share the same TLS port on a loadbalancer, with Envoy inspecting the Server Name Indicator (SNI) field of the TLS handshake, and using that to forward the TLS stream to a backend.

However, this poses problems for source IP visibility, because Envoy is doing a TCP Proxy of the TLS stream.

What happens is that the TLS traffic arrives at Envoy, terminating a TCP stream, Envoy inspects the client hello to find the SNI, picks a backend to forward to, then starts a new TCP stream and forwards the TLS traffic inside the downstream (outside) packets to the upstream (the backend).

Because it’s a new TCP stream, as far as the backends are concerned, the source IP is Envoy (which is often the Node IP, depending on your Cilium config).

When doing TLS Passthrough, backends will see Cilium Envoy’s IP address as the source of the forwarded TLS streams.

The Ingress specification supports three types of paths:

Exact - match the given path exactly.

Prefix - match the URL path prefix split by /. The last path segment must match the whole segment - if you configure a Prefix path of /foo/bar, /foo/bar/baz will match, but /foo/barbaz will not.

ImplementationSpecific - Interpretation of the Path is up to the IngressClass. In Cilium’s case, we define ImplementationSpecific to be “Regex”, so Cilium will interpret any given path as a regular expression and program Envoy accordingly. Notably, some other implementations have ImplementationSpecific mean “Prefix”, and in those cases, Cilium will treat the paths differently. (Since a path like /foo/bar contains no regex characters, when it is configured in Envoy as a regex, it will function as an Exact match instead).

When multiple path types are configured on an Ingress object, Cilium will configure Envoy with the matches in the following order:

ImplementationSpecific (that is, regular expression)

The / Prefix match has special handling and always goes last.

Within each of these path types, the paths are sorted in decreasing order of string length.

If you do use ImplementationSpecific regex support, be careful with using the * operator, since it will increase the length of the regex, but may match another, shorter option.

For example, if you have two ImplementationSpecific paths, /impl, and /impl.*, the second will be sorted ahead of the first in the generated config. But because * is in use, the /impl match will never be hit, as any request to that path will match the /impl.* path first.

See the Ingress Path Types for more information.

ingress.cilium.io/loadbalancer-mode

ingress.cilium.io/loadbalancer-class

ingress.cilium.io/service-type

ingress.cilium.io/service-external-traffic-policy

ingress.cilium.io/insecure-node-port

ingress.cilium.io/secure-node-port

ingress.cilium.io/host-listener-port

ingress.cilium.io/tls-passthrough

ingress.cilium.io/force-https

Additionally, cloud-provider specific annotations for the LoadBalancer Service are supported.

By default, annotations with values beginning with:

service.beta.kubernetes.io

service.kubernetes.io

will be copied from an Ingress object to the generated LoadBalancer Service objects.

This setting is controlled by the Cilium Operator’s ingress-lb-annotation-prefixes config flag, and can be configured in Cilium’s Helm values.yaml using the ingressController.ingressLBAnnotationPrefixes setting.

Please refer to the Kubernetes documentation for more details.

Supported since Cilium 1.16+

Host network mode allows you to expose the Cilium ingress controller (Envoy listener) directly on the host network. This is useful in cases where a LoadBalancer Service is unavailable, such as in development environments or environments with cluster-external loadbalancers.

Enabling the Cilium ingress controller host network mode automatically disables the LoadBalancer/NodePort type Service mode. They are mutually exclusive.

The listener is exposed on all interfaces (0.0.0.0 for IPv4 and/or :: for IPv6).

Host network mode can be enabled via Helm:

Once enabled, host network ports can be specified with the following methods:

ingressController.hostNetwork.sharedListenerPort: Host network port to expose the Cilium ingress controller Envoy listener. The default port is 8080. If you change it, you should choose a port number higher than 1023 (see Bind to privileged port).

ingress.cilium.io/host-listener-port: Host network port to expose the Cilium ingress controller Envoy listener. The default port is 8080 but it can only be used for a single Ingress resource as it needs to be unique per Ingress resource. You should choose a port higher than 1023 (see Bind to privileged port). This annotation is mandatory if the global Cilium ingress controller mode is configured to dedicated (ingressController.loadbalancerMode) or the ingress resource sets the ingress.cilium.io/loadbalancer-mode annotation to dedicated and multiple Ingress resources are deployed.

The default behavior regarding shared or dedicated ingress can be configured via ingressController.loadbalancerMode.

Be aware that misconfiguration might result in port clashes. Configure unique ports that are still available on all Cilium Nodes where Cilium ingress controller Envoy listeners are exposed.

By default, the Cilium L7 Envoy process does not have any Linux capabilities out-of-the-box and is therefore not allowed to listen on privileged ports.

If you choose a port equal to or lower than 1023, ensure that the Helm value envoy.securityContext.capabilities.keepCapNetBindService=true is configured and to add the capability NET_BIND_SERVICE to the respective Cilium Envoy container via Helm values:

Standalone DaemonSet mode: envoy.securityContext.capabilities.envoy

Embedded mode: securityContext.capabilities.ciliumAgent

Configure the following Helm values to allow privileged port bindings in host network mode:

The Cilium ingress controller Envoy listener can be exposed on a specific subset of nodes. This only works in combination with the host network mode and can be configured via a node label selector in the Helm values:

This will deploy the Ingress Controller Envoy listener only on the Cilium Nodes matching the configured labels. An empty selector selects all nodes and continues to expose the functionality on all Cilium nodes.

Please refer to one of the below examples on how to use and leverage Cilium’s Ingress features:

---

## Inspecting Network Flows with the CLI — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/observability/hubble/hubble-cli/

**Contents:**
- Inspecting Network Flows with the CLI
- Pre-Requisites
- Inspecting the cluster’s network traffic with Hubble Relay
- Next Steps

This guide walks you through using the Hubble CLI to inspect network flows and gain visibility into what is happening on the network level.

The best way to get help if you get stuck is to ask a question on Cilium Slack. With Cilium contributors across the globe, there is almost always someone available to help.

This guide uses examples based on the Demo App. If you would like to run them, deploy the Demo App first. Please refer to Identity-Aware and HTTP-Aware Policy Enforcement for more details.

Cilium has been correctly installed in your Kubernetes cluster.

Hubble CLI is installed.

The Hubble API is accessible.

If unsure, run cilium status and validate that Cilium and Hubble are up and running then run hubble status to verify you can communicate with the Hubble API .

Let’s issue some requests to emulate some traffic again. This first request is allowed by the policy.

This next request is accessing an HTTP endpoint which is denied by policy.

Finally, this last request will hang because the xwing pod does not have the org=empire label required by policy. Press Control-C to kill the curl request, or wait for it to time out.

Let’s now inspect this traffic using the CLI. The command below filters all traffic on the application layer (L7, HTTP) to the deathstar pod:

The following command shows all traffic to the deathstar pod that has been dropped:

Feel free to further inspect the traffic. To get help for the observe command, use hubble help observe.

Access the Hubble API with TLS Enabled

---

## IPsec Transparent Encryption — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/network/encryption-ipsec/

**Contents:**
- IPsec Transparent Encryption
- v1.18 Encrypted Overlay
- Generate & Import the PSK
- Enable Encryption in Cilium
- Dependencies
  - Encryption interface
- Validate the Setup
- Key Rotation
- Monitoring
- Troubleshooting

This guide explains how to configure Cilium to use IPsec based transparent encryption using Kubernetes secrets to distribute the IPsec keys. After this configuration is complete, all traffic between Cilium-managed endpoints will be encrypted using IPsec. This guide uses Kubernetes secrets to distribute keys. Alternatively, keys may be manually distributed, but that is not shown here.

Packets are not encrypted when they are destined to the same node from which they were sent. This behavior is intended. Encryption would provide no benefits in that case, given that the raw traffic can be observed on the node anyway.

Prior to v1.18, IPsec encryption was performed before tunnel encapsulation. From Cilium v1.18 and forward, Cilium’s IPsec encryption datapath will send traffic for overlay encapsulation prior to IPsec encryption when tunnel mode is enabled.

With this change, the security identities used for policy enforcement are encrypted on the wire. This is a security benefit.

A disruption-less upgrade from v1.17 to v1.18 can only be achieved by fully patching v1.17 to its latest version. Migration specific code was added to newer v1.17 releases to support a disruption-less upgrade to v1.18.

Once patched to the newest v1.17 stable release, a normal upgrade to v1.18 can be performed.

Because VXLAN is encrypted before being sent, operators see ESP traffic between Kubernetes nodes.

This may result in the need to update firewall rules to allow ESP traffic between nodes. This is especially important in Google Cloud GKE environments. The default firewall rules for the cluster’s subnet may not allow ESP.

First, create a Kubernetes secret for the IPsec configuration to be stored. The example below demonstrates generation of the necessary IPsec configuration which will be distributed as a Kubernetes secret called cilium-ipsec-keys. A Kubernetes secret should consist of one key-value pair where the key is the name of the file to be mounted as a volume in cilium-agent pods, and the value is an IPsec configuration in the following format:

Secret resources need to be deployed in the same namespace as Cilium! In our example, we use kube-system.

In the example below, GCM-128-AES is used. However, any of the algorithms supported by Linux may be used. To generate the secret, you may use the following command:

The + sign in the secret is strongly recommended. It will force the use of per-tunnel IPsec keys. The former global IPsec keys are considered insecure (cf. GHSA-pwqm-x5x6-5586) and were deprecated in v1.16. When using +, the per-tunnel keys will be derived from the secret you generated.

The secret can be seen with kubectl -n kube-system get secrets and will be listed as cilium-ipsec-keys.

If you are deploying Cilium with the Cilium CLI, pass the following options:

If you are deploying Cilium with Helm by following Installation using Helm, pass the following options:

encryption.enabled enables encryption of the traffic between Cilium-managed pods. encryption.type specifies the encryption method and can be omitted as it defaults to ipsec.

When using Cilium in any direct routing configuration, ensure that the native routing CIDR is set properly. This is done using --ipv4-native-routing-cidr=CIDR with the CLI or --set ipv4NativeRoutingCIDR=CIDR with Helm.

At this point the Cilium managed nodes will be using IPsec for all traffic. For further information on Cilium’s transparent encryption, see eBPF Datapath.

When L7 proxy support is enabled (--enable-l7-proxy=true), IPsec requires that the DNS proxy operates in transparent mode (--dnsproxy-enable-transparent-mode=true).

An additional argument can be used to identify the network-facing interface. If direct routing is used and no interface is specified, the default route link is chosen by inspecting the routing tables. This will work in many cases, but depending on routing rules, users may need to specify the encryption interface as follows:

Run a bash shell in one of the Cilium pods with kubectl -n kube-system exec -ti ds/cilium -- bash and execute the following commands:

Check that traffic is encrypted. In the example below, this can be verified by the fact that packets carry the IP Encapsulating Security Payload (ESP). In the example below, eth0 is the interface used for pod-to-pod communication. Replace this interface with e.g. cilium_vxlan if tunneling is enabled.

Key rotations should not be performed during upgrades and downgrades. That is, all nodes in the cluster (or clustermesh) should be on the same Cilium version before rotating keys.

It is not recommended to change algorithms that involve different authentication key lengths during key rotations. If this is attempted, Cilium will delay the application of the new key until the agent restarts and will continue using the previous key. This is designed to maintain uninterrupted IPv6 pod-to-pod connectivity.

To replace cilium-ipsec-keys secret with a new key:

During transition the new and old keys will be in use. The Cilium agent keeps per endpoint data on which key is used by each endpoint and will use the correct key if either side has not yet been updated. In this way encryption will work as new keys are rolled out.

The KEYID environment variable in the above example stores the current key ID used by Cilium. The key variable is a uint8 with value between 1 and 15 included and should be monotonically increasing every re-key with a rollover from 15 to 1. The Cilium agent will default to KEYID of zero if its not specified in the secret.

If you are using Cluster Mesh, you must apply the key rotation procedure to all clusters in the mesh. You might need to increase the transition time to allow for the new keys to be deployed and applied across all clusters, which you can do with the agent flag ipsec-key-rotation-duration.

When monitoring network traffic on a node with IPSec enabled, it is normal to observe in the same interface both the outer packet (node-to-node) carrying the ESP-encrypted payload and then the decrypted inner packet (pod-to-pod). This occurs as, once a packet is decrypted, it is recirculated back to the same interface for further processing. Therefore, depending on the tcpdump filter applied, the capture might differ, but this does not indicate that encryption is not functioning correctly. In particular, to observe:

Only the encrypted packet: use the filter esp.

Only the decrypted packet: use a specific filter for the protocol used by the pods (such as icmp for ping).

Both encrypted and decrypted packets: use no filter or combine the filters for both (such as esp or icmp).

The following capture was taken on a Kind cluster with no filter applied (replace eth0 with cilium_vxlan if tunneling is enabled). The nodes have IP addresses 10.244.2.92 and 10.244.1.148, while the pods have IP addresses 10.244.2.189 and 10.244.1.7, using ping (ICMP) for communication.

If the cilium Pods fail to start after enabling encryption, double-check if the IPsec Secret and Cilium are deployed in the same namespace together.

Check for level=warning and level=error messages in the Cilium log files

If there is a warning message similar to Device eth0 does not exist, use --set encryption.ipsec.interface=ethX to set the encryption interface.

Run cilium-dbg encrypt status in the Cilium Pod:

If the error counter is non-zero, additional information will be displayed with the specific errors the kernel encountered.

The number of keys in use should be 2 per remote node per enabled IP family. During a key rotation, it can double to 4 per remote node per IP family. For example, in a 3-nodes cluster, if both IPv4 and IPv6 are enabled and no key rotation is ongoing, there should be 8 keys in use on each node.

The list of decryption interfaces should have all native devices that may receive pod traffic (for example, ENI interfaces).

All XFRM errors correspond to a packet drop in the kernel. The following details operational mistakes and expected behaviors that can cause those errors.

When a node reboots, the key used to communicate with it is expected to change on other nodes. You may notice the XfrmInNoStates and XfrmOutNoStates counters increase while the new node key is being deployed.

After a key rotation, if the old key is cleaned up before the configuration of the new key is installed on all nodes, it results in XfrmInNoStates errors. The old key is removed from nodes after a default interval of 5 minutes by default. By default, all agents watch for key updates and update their configuration within 1 minute after the key is changed, leaving plenty of time before the old key is removed. If you expect the key rotation to take longer for some reason (for example, in the case of Cluster Mesh where several clusters need to be updated), you can increase the delay before cleanup with agent flag ipsec-key-rotation-duration.

XfrmInStateProtoError errors can happen for the following reasons: 1. If the key is updated without incrementing the SPI (also called KEYID in Key Rotation instructions above). It can be fixed by performing a new key rotation, properly. 2. If the source node encrypts the packets using a different anti-replay seq from the anti-reply oseq on the destination node. This can be fixed by properly performing a new key rotation.

XfrmFwdHdrError and XfrmInError happen when the kernel fails to lookup the route for a packet it decrypted. This can legitimately happen when a pod was deleted but some packets are still in transit. Note these errors can also happen under memory pressure when the kernel fails to allocate memory.

XfrmInStateInvalid can happen on rare occasions if packets are received while an XFRM state is being deleted. XFRM states get deleted as part of node scale-downs and for some upgrades and downgrades.

The following table documents the known explanations for several XFRM errors that were observed in the past. Many other error types exist, but they are usually for Linux subfeatures that Cilium doesn’t use (e.g., XFRM expiration).

The kernel (1) decrypted and tried to route a packet for a pod that was deleted or (2) failed to allocate memory.

Bug in the XFRM configuration for decryption.

XfrmInStateProtoError

There is a key or anti-replay seq mismatch between nodes.

A received packet matched an XFRM state that is being deleted.

Bug in the XFRM configuration for decryption.

Bug in the XFRM configuration for decryption.

Explicit drop, not used by Cilium.

Bug in the XFRM configuration for encryption.

The sequence number of an encryption XFRM configuration reached its maximum value.

Cilium dropped packets that would have otherwise left the node in plain-text.

The kernel (1) decrypted and tried to route a packet for a pod that was deleted or (2) failed to allocate memory.

In addition to the above XFRM errors, packet drops of type No node ID found (code 197) may also occur under normal operations. These drops can happen if a pod attempts to send traffic to a pod on a new node for which the Cilium agent didn’t yet receive the CiliumNode object or to a pod on a node that was recently deleted. It can also happen if the IP address of the destination node changed and the agent didn’t receive the updated CiliumNode object yet. In both cases, the IPsec configuration in the kernel isn’t ready yet, so Cilium drops the packets at the source. These drops will stop once the CiliumNode information is propagated across the cluster.

Control plane disruptions can lead to connectivity issues due to stale XFRM states with out-of-sync IPsec anti-replay counters. This typically results in permanent connectivity disruptions between pods managed by Cilium. This section explains how these issues occur and what you can do about them.

In KVStore Mode (e.g., etcd), you might encounter stale XFRM states:

If a Cilium agent is down for prolonged time, the corresponding node entry in the kvstore will be deleted due to lease expiration (see Leases), resulting in stale XFRM states.

If you manually recreate your key-value store, a Cilium agent might connect too late to the new instance. This delay can cause the agent to miss crucial node delete and create events, leading Cilium to retain outdated XFRM states for those nodes.

In CRD Mode, stale XFRM states can occur if you delete a CiliumNode resource and restart the Cilium agent DaemonSet. While other agents create fresh XFRM states for the new CiliumNode, the agent on that new node may retain obsolete XFRM states for all the other peer nodes.

To restore connectivity in those cases, perform a key rotation (see Key Rotation). This action ensures new consistent and valid XFRM states across all your nodes.

To disable the encryption, regenerate the YAML with the option encryption.enabled=false

Transparent encryption is not currently supported when chaining Cilium on top of other CNI plugins. For more information, see GitHub issue 15596.

Host Policies are not currently supported with IPsec encryption.

IPsec encryption currently does not work with BPF Host Routing.

IPsec encryption is not supported on clusters or clustermeshes with more than 65535 nodes.

Decryption with Cilium IPsec is limited to a single CPU core per IPsec tunnel. This may affect performance in case of high throughput between two nodes.

---

## Configuring IPAM Modes — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/kubernetes/ipam/

**Contents:**
- Configuring IPAM Modes

Cilium supports multiple IP Address Management (IPAM) modes to meet the needs of different environments and cloud providers.

The following sections provide documentation for each supported IPAM mode:

---

## GatewayClass Parameters Support — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/parameterized-gatewayclass/

**Contents:**
- GatewayClass Parameters Support
- Deploy the Demo App
- Deploy the Cilium Gateway with customized parameters
- Reference

The default behavior of Gateway API can be modified by providing parameters to the GatewayClass. The parameters are defined in the GatewayClass and can be referenced in the Gateway object. The GatewayClass parameters are defined in the CiliumGatewayClassConfig CRD.

The demo application is from the bookinfo demo microservices app from the Istio project.

This is just deploying the demo app, it’s not adding any Istio components. You can confirm that with Cilium Service Mesh there is no Envoy sidecar created alongside each of the demo app microservices.

With the sidecar implementation the output would show 2/2 READY. One for the microservice and one for the Envoy sidecar.

In this example, we will deploy a Cilium Gateway with NodePort service instead of the default LoadBalancer type.

Apply the configuration:

Once the Gateway is deployed, you can access the service using via NodePort service.

The full list of supported parameters can be found in the CiliumGatewayClassConfig CRD.

The CiliumGatewayClassConfig CRD is an alpha API, and per the standard Kubernetes object versioning, is subject to breaking changes. If you use it, please read the release notes carefully in case there are breaking changes. Please also consider reporting both your usage of the CRD and any issues either on Github or in Slack.

---

## BGP Control Plane Resources — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/bgp-control-plane/bgp-control-plane-v2/

**Contents:**
- BGP Control Plane Resources
- BGP Cluster Configuration
  - Auto-Discovery
    - Default Gateway Auto-Discovery
    - Multi-homing with Default Gateway Auto-Discovery
      - Verification
      - Limitations
- BGP Peer Configuration
  - MD5 Password
  - Timers

Cilium BGP control plane is managed by a set of custom resources which provide a flexible way to configure BGP peers, policies, and advertisements.

The following resources are used to manage the BGP Control Plane:

CiliumBGPClusterConfig: Defines BGP instances and peer configurations that are applied to multiple nodes.

CiliumBGPPeerConfig: A common set of BGP peering setting. It can be used across multiple peers.

CiliumBGPAdvertisement: Defines prefixes that are injected into the BGP routing table.

CiliumBGPNodeConfigOverride: Defines node-specific BGP configuration to provide a finer control.

The relationship between various resources is shown in the below diagram:

CiliumBGPClusterConfig resource is used to define BGP configuration for one or more nodes in the cluster based on its nodeSelector field. Each CiliumBGPClusterConfig defines one or more BGP instances, which are uniquely identified by their name field.

A BGP instance can have one or more peers. Each peer is uniquely identified by its name field. The Peer autonomous system number and peer address are defined by the peerASN and peerAddress fields, respectively. The configuration of the peers is defined by the peerConfigRef field, which is a reference to a peer configuration resource. Group and kind in peerConfigRef are optional and default to cilium.io and CiliumBGPPeerConfig, respectively.

By default, the BGP Control Plane instantiates each router instance without a listening port. This means the BGP router can only initiate connections to the configured peers, but cannot accept incoming connections. This is the default behavior because the BGP Control Plane is designed to function in environments where another BGP router (such as Bird) is running on the same node. When it is required to accept incoming connections, the localPort field can be used to specify the listening port.

The CiliumBGPPeeringPolicy and CiliumBGPClusterConfig should not be used together. If both resources are present and Cilium agent matches with both based on the node selector, CiliumBGPPeeringPolicy will take precedence.

Listening on the default BGP port (179) requires CAP_NET_BIND_SERVICE. If you wish to use the default port, you must grant the CAP_NET_BIND_SERVICE capability with securityContext.capabilities.ciliumAgent Helm value.

Here is an example configuration of the CiliumBGPClusterConfig with a BGP instance named instance-65000 and two peers configured under this BGP instance.

Cilium BGP Control Plane also supports automatic discovery of BGP peers.

When enabled, the auto-discovery feature self-configures the BGP peer’s IP address automatically. Selection of the specific address is dependent on the mode enabled.

Cilium BGP Control Plane currently supports DefaultGateway mode for auto-discovery under autoDiscovery field in CiliumBGPClusterConfig.

The default gateway auto-discovery mode allows Cilium to automatically discover and establish BGP session with the default gateway (typically a Top-of-Rack (ToR) switch) for a specified address family.

To enable default gateway auto-discovery, configure the autoDiscovery field in the peer configuration:

Here are the ToR switch BGP configuration requirements:

ToR switches must be configured with “bgp listen range” to support dynamic BGP neighbors. This configuration enables the ToR switch to accept BGP sessions from Cilium nodes by listening for connections from a specific IP prefix range, eliminating the need to know the exact peer address of each Cilium node.

For more details, see the FRR documentation.

Configure each ToR switch with the same local ASN (Autonomous System Number) to ensure Cilium configuration remains consistent across all cluster nodes.

Once this configuration is applied:

Cilium determines the default gateway for the specified address family on each node

It automatically establishes a BGP session with the discovered gateway

It uses the peer configuration referenced by peerConfigRef for session parameters

Link-local address as default gateway is not supported.

In multi-homing setups, the Cilium node connects to two different Top-of-Rack switches. It discovers both the default gateways, but it picks the default route with the lower metric to establish the BGP session. It’s important to note that Cilium creates only one BGP session per address family at a time. A failure or a change of the default route with the lower metric triggers a reconciliation to establish the BGP session with the default gateway of the other default route.

Example configuration:

To verify that BGP sessions are established with the auto-discovered peers, use the cilium bgp peers command:

Auto Discovery with DefaultGateway mode in multi-homing setup can not be used to create multiple BGP sessions for the same address family. Currently, the only workaround is to configure the peer address manually for each peer.

The CiliumBGPPeerConfig resource is used to define a BGP peer configuration. Multiple peers can share the same configuration and provide reference to the common CiliumBGPPeerConfig resource.

The CiliumBGPPeerConfig resource contains configuration options for:

Here is an example configuration of the CiliumBGPPeerConfig resource. In the next section, we will go over each configuration option.

AuthSecretRef in CiliumBGPPeerConfig can be used to configure an RFC-2385 TCP MD5 password on the session with the BGP peer which references this configuration.

Here is an example of setting authSecretRef:

AuthSecretRef should reference the name of a secret in the BGP secrets namespace (if using the Helm chart this is kube-system by default). The secret should contain a key with a name of password.

BGP secrets are limited to a configured namespace to keep the permissions needed on each Cilium Agent instance to a minimum. The Helm chart will configure Cilium to be able to read from it by default.

An example of creating a secret is:

If you wish to change the namespace, you can set the bgpControlPlane.secretNamespace.name Helm chart value. To have the namespace created automatically, you can set the bgpControlPlane.secretNamespace.create Helm chart value to true.

Because TCP MD5 passwords sign the header of the packet they cannot be used if the session is address-translated by Cilium (in other words, the Cilium Agent’s pod IP address must be the address that the BGP peer sees).

If the password is incorrect, or if the header is otherwise changed, then the TCP connection will not succeed. This will appear as dial: i/o timeout in the Cilium Agent’s logs rather than a more specific error message.

If a CiliumBGPPeerConfig is deployed with an authSecretRef that Cilium cannot find, the BGP session will use an empty password and the agent will log an error such as in the following example:

BGP Control Plane supports modifying the following BGP timer parameters. For more detailed description for each timer parameters, please refer to RFC4271.

connectRetryTimeSeconds

In datacenter networks where Kubernetes clusters are deployed, it is generally recommended to set the HoldTimer and KeepaliveTimer to a lower value for faster possible failure detection. For example, you can set the minimum possible values holdTimeSeconds=9 and keepAliveTimeSeconds=3.

To ensure a fast reconnection after losing connectivity with the peer, reduce the connectRetryTimeSeconds (for example to 5 or less). As random jitter is applied to the configured value internally, the actual value used for the ConnectRetryTimer is within the interval [ConnectRetryTimeSeconds, 2 * ConnectRetryTimeSeconds).

By default, IP TTL of the BGP packets is set to 1 in eBGP. Generally, it is encouraged to not change the TTL, but in some cases, you may need to change the TTL value. For example, when the BGP peer is a Route Server and located in a different subnet, you may need to set the TTL value to more than 1.

The Cilium BGP Control Plane can be configured to act as a graceful restart Restarting Speaker. When you enable graceful restart, the BGP session restarts and the “graceful restart” capability is advertised in the BGP OPEN message.

In the event of a Cilium Agent restart, the peering BGP router does not withdraw routes received from the Cilium BGP control plane immediately. The datapath continues to forward traffic during Agent restart, so there is no traffic disruption.

Optionally, you can use the restartTimeSeconds parameter. RestartTime is the time advertised to the peer within which Cilium BGP control plane is expected to re-establish the BGP session after a restart. On expiration of RestartTime, the peer removes the routes previously advertised by the Cilium BGP control plane.

When the Cilium Agent restarts, it closes the BGP TCP socket, causing the emission of a TCP FIN packet. On receiving this TCP FIN, the peer changes its BGP state to Idle and starts its RestartTime timer.

The Cilium agent boot up time varies depending on the deployment. If using RestartTime, you should set it to a duration greater than the time taken by the Cilium Agent to boot up.

Default value of RestartTime is 120 seconds. More details on graceful restart and RestartTime can be found in RFC-4724 and RFC-8538.

The transport section of CiliumBGPPeerConfig can be used to configure a custom destination port for a peer’s BGP session.

By default, when BGP is operating in active mode (with the Cilium agent initiating the TCP connection), the destination port is 179 and the source port is ephemeral.

Here is an example of setting the transport configuration:

The families field is a list of AFI (Address Family Identifier), SAFI (Subsequent Address Family Identifier) pairs, and advertisement selector. The only AFI/SAFI options currently supported are {afi: ipv4, safi: unicast} and {afi: ipv6, safi: unicast}.

By default, if no address families are specified, BGP Control Plane sends both IPv4 Unicast and IPv6 Unicast Multiprotocol Extensions Capability (RFC-4760) to the peer.

In each address family, you can control the route publication via the advertisements label selector. Various advertisements types are defined here.

Without matching advertisements, no prefix will be advertised to the peer. Default configuration is to not advertise any prefix.

The CiliumBGPAdvertisement resource is used to define various advertisement types and attributes associated with them. The advertisements label selector defined in the families field of a peer configuration may match with one or more of the CiliumBGPAdvertisement resources.

You can configure BGP path attributes for the prefixes advertised by Cilium BGP control plane using attributes field in advertisements[*]. There are two types of Path Attributes that can be advertised: Communities and LocalPreference.

Here is an example configuration of the CiliumBGPAdvertisement resource that advertises pod prefixes with the community value of “65000:99” and local preference of 99.

Communities defines a set of community values advertised in the supported BGP Communities Path Attributes.

The values can be of three types:

Standard: represents a value of the “standard” 32-bit BGP Communities Attribute (RFC-1997) as a 4-byte decimal number or two 2-byte decimal numbers separated by a colon (for example: 64512:100).

WellKnown: represents a value of the “standard” 32-bit BGP Communities Attribute (RFC-1997) as a well-known string alias to its numeric value. Allowed values and their mapping to the numeric values are displayed in the following table:

route-filter-translated-v4

route-filter-translated-v6

Large: represents a value of the BGP Large Communities Attribute (RFC-8092), as three 4-byte decimal numbers separated by colons (for example: 64512:100:50).

LocalPreference defines the preference value advertised in the BGP Local Preference Path Attribute. As Local Preference is only valid for iBGP peers, this value will be ignored for eBGP peers (no Local Preference Path Attribute will be advertised).

The following advertisement types are supported by Cilium:

The BGP Control Plane can advertise the Pod CIDR prefixes of the nodes. This allows the BGP peers and the connected network to reach the Pods directly without involving load balancers or NAT. There are two ways to advertise PodCIDRs depending on the IPAM mode setting.

Cilium BGP control plane advertises pod CIDR allocated to the node and not the entire range.

When Kubernetes or ClusterPool IPAM is used, set advertisement type to PodCIDR.

With this configuration, the BGP instance on the node advertises the Pod CIDR prefixes assigned to the local node.

When MultiPool IPAM is used, specify the advertisementType field to CiliumPodIPPool. The selector field is a label selector that selects CiliumPodIPPool matching the specified .matchLabels or .matchExpressions.

This configuration advertises the PodCIDR prefixes allocated from the selected Cilium pod IP pools. Note that the CIDR must be allocated to a CiliumNode resource.

If you wish to announce all CiliumPodIPPool CIDRs within the cluster, a NotIn match expression with a dummy key and value can be used like this:

There are two special-purpose selector fields that match CiliumPodIPPools based on name and/or namespace metadata instead of labels:

io.cilium.podippool.namespace

io.cilium.podippool.name

For additional details regarding CiliumPodIPPools, see the Multi-Pool (Beta) section.

When using other IPAM types, the BGP Control Plane does not support advertising PodCIDRs and specifying advertisementType: "PodCIDR" doesn’t have any effect.

In Kubernetes, a Service can have multiple virtual IP addresses, such as .spec.clusterIP, .spec.clusterIPs, .status.loadBalancer.ingress[*].ip or .spec.externalIPs.

The BGP control plane can advertise the virtual IP address of the Service to BGP peers. This allows you to directly access the Service from outside the cluster.

Cilium BGP Control Plane advertises exact routes for the VIPs ( /32 or /128 prefixes ).

To advertise the service virtual IPs, specify the advertisementType field to Service and the service.addresses field to LoadBalancerIP, ClusterIP or ExternalIP.

The .selector field is a label selector that selects Services matching the specified .matchLabels or .matchExpressions.

When your upstream router supports Equal Cost Multi Path (ECMP), you can use this feature to load-balance traffic to the Service across multiple nodes by advertising the same virtual IPs from multiple nodes.

Many routers have a limit on the number of ECMP paths they can hold in their routing table (Juniper). When advertising the Service VIPs from many nodes, you may exceed this limit. We recommend checking the limit with your network administrator before using this feature.

If you wish to use this together with kubeProxyReplacement feature (see Kubernetes Without kube-proxy docs), please make sure the ExternalIP support is enabled.

If you only wish to advertise the .spec.externalIPs of a Service, you can specify the service.addresses field as ExternalIP.

If you wish to use this together with kubeProxyReplacement feature (see Kubernetes Without kube-proxy docs), specific BPF parameters need to be enabled. See External Access To ClusterIP Services section for how to enable it.

If you only wish to advertise the .spec.clusterIP and .spec.clusterIPs of a Service, you can specify the virtualRouters[*].serviceAdvertisements field as ClusterIP.

You must first allocate ingress IPs to advertise them. By default, Kubernetes doesn’t provide a way to assign ingress IPs to a Service. The cluster administrator is responsible for preparing a controller that assigns ingress IPs. Cilium supports assigning ingress IPs with the Load Balancer IPAM feature.

This advertises the ingress IPs of all Services matching the .selector.

If you wish to announce all services within the cluster, a NotIn match expression with a dummy key and value can be used like this:

There are a few special purpose selector fields that don’t match on labels but instead on other metadata like .meta.name or .meta.namespace.

io.kubernetes.service.namespace

io.kubernetes.service.name

Cilium supports the loadBalancerClass. When the load balancer class is set to io.cilium/bgp-control-plane or unspecified, Cilium announces the ingress IPs of the Service. Otherwise, Cilium does not announce the ingress IPs of the Service.

In the case of a load-balancer ingress IP or external IP advertisements, if the Service has externalTrafficPolicy: Cluster, BGP Control Plane unconditionally advertises the IPs of the selected Service. When the Service has externalTrafficPolicy: Local, BGP Control Plane keeps track of the endpoints for the service on the local node and stops advertisement when there’s no local endpoint.

Similarly, internalTrafficPolicy is considered for ClusterIP advertisements.

It is worth noting that when you configure service.addresses as ClusterIP, the BGP Control Plane only considers the configuration of the matching service’s .spec.internalTrafficPolicy and ignores the configuration of .spec.externalTrafficPolicy. For ExternalIP and LoadBalancerIP, it only considers the configuration of the service’s .spec.externalTrafficPolicy and ignores the configuration of .spec.internalTrafficPolicy.

When configuring CiliumBGPAdvertisement, it is possible that two or more advertisements match the same Service. Prior to Cilium 1.18, overlapping matches were not expected and the last sequential match was used. Today, overlapping advertisement selectors are supported. Overlap handling varies by attribute:

Communities: the union of elements is taken across all matches

Local Preference: the largest value is selected

As an example, below we have two advertisements which each define a selector match. One matches on the label vpc1 while the other on vpc2.

We have a deployment named hello-world which exposes a LoadBalancer Service. Initially, there were no labels configured. This resulted in no matches, and no BGP advertisements.

Labels were then configured using:

The resulting BGP advertisement set both communities 1111:1111:1111 and 2222:2222:2222. All possible combinations of communities (Standard, Large, WellKnown) are supported. Had Local Preference been set, it would have been the largest value observed across all matches. This is in line with RFC4271 which states The higher degree of preference MUST be preferred.

Cilium BGP Control Plane supports Routing Aggregation RFC4632.

If the Service has externalTrafficPolicy: Local then BGP Control Plane will ignore routing aggregation parameter

The CiliumBGPNodeConfigOverride resource can be used to override some of the auto-generated configuration on a per-node basis.

Here is an example of the CiliumBGPNodeConfigOverride resource, that sets Router ID, local address and local autonomous system number used in each peer for the node with a name bgpv2-cplane-dev-multi-homing-worker.

The name of CiliumBGPNodeConfigOverride resource must match the name of the node for which the configuration is intended. Similarly, the names of the BGP instance and peers must match with what is defined under CiliumBGPClusterConfig.

This is a per node configuration.

There is bgpControlPlane.routerIDAllocation.mode Helm chart value, which stipulates how the Router ID is allocated. Currently, default and ip-pool are supported. The default allocation mode is default.

In default mode, when Cilium runs on an IPv4 single-stack or a dual-stack, the BGP Control Plane can use the IPv4 address assigned to the node as the BGP Router ID because the Router ID is 32 bit-long, and we can rely on the uniqueness of the IPv4 address to make the Router ID unique. When running in an IPv6 single-stack, the lower 32 bits of MAC address of cilium_host interface are used as Router ID.

In ip-pool mode, you must provide an IPv4 IP pool like 10.0.0.0/24 to Cilium through the helm value bgpControlPlane.routerIDAllocation.ipPool. Cilium will then assign Router IDs to BGP instances from this configured pool.

If the auto assignment of the Router ID is not desired, you must manually define it. In order to configure custom Router ID, you can set routerID field in an IPv4 address format. In default mode, you can manually set any Router ID, and Cilium does not validate it. In ip-pool mode, if the Router ID is within the pool range, you must ensure it does not conflict with others. If the Router ID is outside the pool, you can set it freely.

The localPort field in the CiliumBGPClusterConfig can be used to specify the listening port. If you wish to override it on a per-node basis, you can set the localPort field in the CiliumBGPNodeConfigOverride resource. This also works even if the localPort field is not set in the CiliumBGPClusterConfig.

The source interface and the address used by the BGP Control Plane in order to setup peering with the neighbor are based on a route lookup of the peer address defined in CiliumBGPClusterConfig. There may be use cases where multiple links are present on the node and you want tighter control over which link BGP peering should be setup.

To configure the source address, the peers[*].localAddress field can be set. It should be an address configured on one of the links on the node.

It is possible to override the Autonomous System Number (ASN) of a node using the field LocalASN of the CiliumBGPNodeConfigOverride resource. When this field is not defined, the LocalASN from the matching CiliumBGPClusterConfig is used as local ASN for the node. This customization allows individual nodes to operate with a different ASN when required by the network design.

Please refer to container lab examples in Cilium repository under contrib/containerlab/bgpv2.

---

## Identity-Based — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/network/identity/

**Contents:**
- Identity-Based

Container management systems such as Kubernetes deploy a networking model which assigns an individual IP address to each pod (group of containers). This ensures simplicity in architecture, avoids unnecessary network address translation (NAT) and provides each individual container with a full range of port numbers to use. The logical consequence of this model is that depending on the size of the cluster and total number of pods, the networking layer has to manage a large number of IP addresses.

Traditionally security enforcement architectures have been based on IP address filters. Let’s walk through a simple example: If all pods with the label role=frontend should be allowed to initiate connections to all pods with the label role=backend then each cluster node which runs at least one pod with the label role=backend must have a corresponding filter installed which allows all IP addresses of all role=frontend pods to initiate a connection to the IP addresses of all local role=backend pods. All other connection requests should be denied. This could look like this: If the destination address is 10.1.1.2 then allow the connection only if the source address is one of the following [10.1.2.2,10.1.2.3,20.4.9.1].

Every time a new pod with the label role=frontend or role=backend is either started or stopped, the rules on every cluster node which run any such pods must be updated by either adding or removing the corresponding IP address from the list of allowed IP addresses. In large distributed applications, this could imply updating thousands of cluster nodes multiple times per second depending on the churn rate of deployed pods. Worse, the starting of new role=frontend pods must be delayed until all servers running role=backend pods have been updated with the new security rules as otherwise connection attempts from the new pod could be mistakenly dropped. This makes it difficult to scale efficiently.

In order to avoid these complications which can limit scalability and flexibility, Cilium entirely separates security from network addressing. Instead, security is based on the identity of a pod, which is derived through labels. This identity can be shared between pods. This means that when the first role=frontend pod is started, Cilium assigns an identity to that pod which is then allowed to initiate connections to the identity of the role=backend pod. The subsequent start of additional role=frontend pods only requires to resolve this identity via a key-value store, no action has to be performed on any of the cluster nodes hosting role=backend pods. The starting of a new pod must only be delayed until the identity of the pod has been resolved which is a much simpler operation than updating the security rules on all other cluster nodes.

---

## CiliumCIDRGroup — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/kubernetes/ciliumcidrgroup/

**Contents:**
- CiliumCIDRGroup

CiliumCIDRGroup (CCG) is a feature that allows administrators to reference a group of CIDR blocks in a CiliumNetworkPolicy. Unlike Endpoint CRD resources, which are managed by the Cilium agent, CiliumCIDRGroup resources are intended to be managed directly by administrators. It is particularly useful for enforcing policies on groups of external CIDR blocks. Additionally, any traffic to CIDRs referenced in the CiliumCIDRGroup will have their Hubble flows annotated with the CCG’s name and labels.

The following is an example of a CiliumCIDRGroup object:

The CCG can be referenced in a CiliumNetworkPolicy by using the fromCIDRSet directive. CCGs may be selected by names or labels.

In this example, the fromCIDRSet directive in the CNP references the vpn-example-1 group defined in the CiliumCIDRGroup. This allows the CNP to apply ingress rules based on the CIDRs grouped under the vpn-example-1 name.

---

## Identity Management Mode — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/kubernetes/identity-management-mode/

**Contents:**
- Identity Management Mode
- Enable Identity Management by the Cilium Operator (Beta)
  - Enable Operator Managing Identities on a New Cluster
  - How to Migrate from Cilium Agent to Cilium Operator Managing Identities
  - How to Downgrade from Cilium Operator to Cilium Agent Managing Identities
- Metrics

Cilium supports Cilium Identity (CID) management by either the Cilium Agents (default) or the Cilium Operator.

When the Operator manages identities, identity creation is centralized. This provides benefits such as reduced CID duplication, which can occur when multiple Agents simultaneously create identities for the same set of labels. Given that there is a limitation on the maximum number of identities in a cluster and eBPF Policy Map size (see eBPF Maps), when the operator manages identities, we can improve the reliability of network policies and cluster scalability.

Labels relevant to identity management may be configured in the Cilium ConfigMap (see: Limiting Identity-Relevant Labels). If the Cilium Operator is managing identities, both the Operator and Agents must be restarted to pick up the new label pattern setting.

This is a beta feature. Please provide feedback and file a GitHub issue if you experience any problems.

The Cilium Agents manage CIDs by default. This section describes the steps necessary for enabling CID management by the Cilium Operator.

To enable the Cilium Operator to manage identities on a new cluster, set the identityManagementMode value to operator in your Helm chart or set the identity-management-mode flag to operator in the cilium-config configmap.

In order to minimize disruptions to connections or workload management, the following procedure should be followed. Note that in order to prevent disruptions to the cluster, there is an intermediate state where both the Cilium Agents and the Operator manage identities. As long as the Cilium Agents are creating identities, the CID duplication issue may occur. The transitional state is intended to only be used temporarily for the purpose of migrating identity management modes.

Allow the Operator to also manage identities by setting the identityManagementMode value to both in your Helm chart or by setting the identity-management-mode flag to both in the cilium-config configmap. Restart the Operator.

Once the operator is running, upgrade the Cilium Agents by setting the identityManagementMode value to operator or by setting the identity-management-mode flag to operator and restarting the Cilium Agent DaemonSet.

For a safe downgrade, the following procedure should be followed.

First, downgrade the Cilium Agents by setting the identityManagementMode value to both in your Helm chart or by setting the identity-management-mode flag to both in the cilium-config configmap. Restart the Cilium Agent DaemonSet.

Once the Cilium Agents are running, downgrade the Operator by setting the identityManagementMode value to agent and restarting the Operator.

Metrics for identity management by the operator are documented in the Identity Management Mode section of the metric documentation.

---

## Networking Concepts — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/concepts/

**Contents:**
- Networking Concepts

---

## Network Policy — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/clustermesh/policy/

**Contents:**
- Network Policy
- Prerequisites
- Security Policies
  - Allowing Specific Communication Between Clusters

This tutorial will guide you how to define NetworkPolicies affecting multiple clusters.

You need to have a functioning Cluster Mesh setup, please follow the guide Setting up Cluster Mesh to set it up.

As addressing and network security are decoupled, network security enforcement automatically spans across clusters. Note that Kubernetes security policies are not automatically distributed across clusters, it is your responsibility to apply CiliumNetworkPolicy or NetworkPolicy in all clusters.

The following policy illustrates how to allow particular pods to communicate between two clusters. The cluster name refers to the name given via the --cluster-name agent option or cluster-name ConfigMap option.

Note that by default policies automatically select endpoints from all the clusters unless it is explicitly specified. To restrict endpoint selection to the local cluster by default you can enable the option --policy-default-local-cluster via the ConfigMap option policy-default-local-cluster or the Helm value clustermesh.policyDefaultLocalCluster. Changing this option is a breaking change for existing policies. To migrate this setting safely read Preparing for a policy-default-local-cluster change for more details.

The following policy illustrates how to explicitly allow pods to communicate to all clusters.

---

## Routing — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/concepts/routing/

**Contents:**
- Routing
- Encapsulation
  - Requirements on the network
  - Advantages of the model
  - Disadvantages of the model
  - Configuration
- Native-Routing
  - Requirements on the network
  - Configuration
- AWS ENI

When no configuration is provided, Cilium automatically runs in this mode as it is the mode with the fewest requirements on the underlying networking infrastructure.

In this mode, all cluster nodes form a mesh of tunnels using the UDP-based encapsulation protocols VXLAN or Geneve. All traffic between Cilium nodes is encapsulated.

Encapsulation relies on normal node to node connectivity. This means that if Cilium nodes can already reach each other, all routing requirements are already met.

The underlying network and firewalls must allow encapsulated packets:

Port Range / Protocol

If using an IPv6 underlay, the cluster must be IPv6-only. Dual-stack clusters are not supported.

The network which connects the cluster nodes does not need to be made aware of the PodCIDRs. Cluster nodes can spawn multiple routing or link-layer domains. The topology of the underlying network is irrelevant as long as cluster nodes can reach each other using IP/UDP.

Due to not depending on any underlying networking limitations, the available addressing space is potentially much larger and allows to run any number of pods per node if the PodCIDR size is configured accordingly.

When running together with an orchestration system such as Kubernetes, the list of all nodes in the cluster including their associated allocation prefix node is made available to each agent automatically. New nodes joining the cluster will automatically be incorporated into the mesh.

Encapsulation protocols allow for the carrying of metadata along with the network packet. Cilium makes use of this ability to transfer metadata such as the source security identity. The identity transfer is an optimization designed to avoid one identity lookup on the remote node.

Due to adding encapsulation headers, the effective MTU available for payload is lower than with native-routing (50 bytes per network packet for VXLAN). This results in a lower maximum throughput rate for a particular network connection. This can be largely mitigated by enabling jumbo frames (50 bytes of overhead for each 1500 bytes vs 50 bytes of overhead for each 9000 bytes).

The following options can be used to configure encapsulation:

tunnel-protocol: Set the encapsulation protocol to vxlan or geneve, defaults to vxlan.

underlay-protocol: Set the IP family for the underlay. Defaults to ipv4. The underlying network must support that protocol. ipv6 is only supported in IPv6-only clusters.

tunnel-port: Set the port for the encapsulation protocol. Defaults to 8472 for vxlan and 6081 for geneve.

The native routing datapath is enabled with routing-mode: native and enables the native packet forwarding mode. The native packet forwarding mode leverages the routing capabilities of the network Cilium runs on instead of performing encapsulation.

In native routing mode, Cilium will delegate all packets which are not addressed to another local endpoint to the routing subsystem of the Linux kernel. This means that the packet will be routed as if a local process would have emitted the packet. As a result, the network connecting the cluster nodes must be capable of routing PodCIDRs.

Cilium automatically enables IP forwarding in the Linux kernel when native routing is configured.

In order to run the native routing mode, the network connecting the hosts on which Cilium is running on must be capable of forwarding IP traffic using addresses given to pods or other workloads.

The Linux kernel on the node must be aware on how to forward packets of pods or other workloads of all nodes running Cilium. This can be achieved in two ways:

The node itself does not know how to route all pod IPs but a router exists on the network that knows how to reach all other pods. In this scenario, the Linux node is configured to contain a default route to point to such a router. This model is used for cloud provider network integration. See Google Cloud, AWS ENI, and Azure IPAM for more details.

Each individual node is made aware of all pod IPs of all other nodes and routes are inserted into the Linux kernel routing table to represent this. If all nodes share a single L2 network, then this can be taken care of by enabling the option auto-direct-node-routes: true. Otherwise, an additional system component such as a BGP daemon must be run to distribute the routes. See the guide Using Kube-Router to Run BGP (deprecated) on how to achieve this using the kube-router project.

The following configuration options must be set to run the datapath in native routing mode:

routing-mode: native: Enable native routing mode.

ipv4-native-routing-cidr: x.x.x.x/y: Set the CIDR in which native routing can be performed.

The following configuration options are optional when running the datapath in native routing mode:

direct-routing-skip-unreachable: If a BGP daemon is running and there is multiple native subnets to the cluster network, direct-routing-skip-unreachable: true can be added alongside auto-direct-node-routes to give each node L2 connectivity in each zone without traffic always needing to be routed by the BGP routers.

The AWS ENI datapath is enabled when Cilium is run with the option --ipam=eni. It is a special purpose datapath that is useful when running Cilium in an AWS environment.

Pods are assigned ENI IPs which are directly routable in the AWS VPC. This simplifies communication of pod traffic within VPCs and avoids the need for SNAT.

Pod IPs are assigned a security group. The security groups for pods are configured per node which allows to create node pools and give different security group assignments to different pods. See section AWS ENI for more details.

The number of ENI IPs is limited per instance. The limit depends on the EC2 instance type. This can become a problem when attempting to run a larger number of pods on very small instance types.

Allocation of ENIs and ENI IPs requires interaction with the EC2 API which is subject to rate limiting. This is primarily mitigated via the operator design, see section AWS ENI for more details.

Traffic is received on one of the ENIs attached to the instance which is represented on the node as interface ethN.

An IP routing rule ensures that traffic to all local pod IPs is done using the main routing table:

The main routing table contains an exact match route to steer traffic into a veth pair which is hooked into the pod:

All traffic passing lxc5a4def8d96c5 on the way into the pod is subject to Cilium’s eBPF program to enforce network policies, provide service reverse load-balancing, and visibility.

The pod’s network namespace contains a default route which points to the node’s router IP via the veth pair which is named eth0 inside of the pod and lxcXXXXXX in the host namespace. The router IP is allocated from the ENI space, allowing for sending of ICMP errors from the router IP for Path MTU purposes.

After passing through the veth pair and before reaching the Linux routing layer, all traffic is subject to Cilium’s eBPF program to enforce network policies, implement load-balancing and provide networking features.

An IP routing rule ensures that traffic from individual endpoints are using a routing table specific to the ENI from which the endpoint IP was allocated:

The ENI specific routing table contains a default route which redirects to the router of the VPC via the ENI interface:

The AWS ENI datapath is enabled by setting the following option:

ipam: eni Enables the ENI specific IPAM backend and indicates to the datapath that ENI IPs will be used.

enable-endpoint-routes: "true" enables direct routing to the ENI veth pairs without requiring to route via the cilium_host interface.

auto-create-cilium-node-resource: "true" enables the automatic creation of the CiliumNode custom resource with all required ENI parameters. It is possible to disable this and provide the custom resource manually.

egress-masquerade-interfaces: eth+ is the interface selector of all interfaces which are subject to masquerading. Masquerading can be disabled entirely with enable-ipv4-masquerade: "false".

See the section AWS ENI for details on how to configure ENI IPAM specific parameters.

When running Cilium on Google Cloud via either Google Kubernetes Engine (GKE) or self-managed, it is possible to utilize the Google Cloud’s networking layer with Cilium running in a Native-Routing configuration. This provides native networking performance while benefiting from many additional Cilium features such as policy enforcement, load-balancing with DSR, efficient NodePort/ExternalIP/HostPort implementation, extensive visibility features, and so on.

Cilium will assign IPs to pods out of the PodCIDR assigned to the specific Kubernetes node. By using Alias IP ranges, these IPs are natively routable on Google Cloud’s network without additional encapsulation or route distribution.

All traffic not staying with the ipv4-native-routing-cidr (defaults to the Cluster CIDR) will be masqueraded to the node’s IP address to become publicly routable.

ClusterIP load-balancing will be performed using eBPF for all version of GKE.

All NetworkPolicy enforcement and visibility is provided using eBPF.

The following configuration options must be set to run the datapath on GKE:

gke.enabled: true: Enables the Google Kubernetes Engine (GKE) datapath. Setting this to true will enable the following options:

ipam: kubernetes: Enable Kubernetes Host Scope IPAM

routing-mode: native: Enable native routing mode

enable-endpoint-routes: true: Enable per-endpoint routing on the node (automatically disables the local node route).

ipv4-native-routing-cidr: x.x.x.x/y: Set the CIDR in which native routing is supported.

See the getting started guide Cilium Quick Installation to install Cilium on Google Kubernetes Engine (GKE).

---

## Migrating from Ingress to Gateway — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/ingress-to-gateway/ingress-to-gateway/

**Contents:**
- Migrating from Ingress to Gateway
- Ingress API Limitations
- Benefits of the Gateway API
- Migration Methods
- Ingress Annotations Migration
- Examples

The Gateway API is not only the long-term successor to the Ingress API, it also supports use cases beyond HTTP/HTTPS-based applications.

This section highlights some of the limitations with Ingress, explains some of the benefits of the Gateway API, and describes some of the options available with migrating from Ingress API to Gateway API.

Development of the Gateway API stemmed from the realization that the Kubernetes Ingress API has some limitations.

Limited support for advanced routing

The Ingress API supports basic routing based on path and host rules, but it lacks native support for more advanced routing features such as traffic splitting, header modification, and URL rewriting.

Limited protocol support

The Ingress API only supports HTTP and HTTPS traffic, and does not natively support other protocols like TCP or UDP. The Ingress API specification was too limited and not extensible enough. To address these technical limitations, software vendors and developers created vendor-specific annotations. However, using annotations created inconsistencies from one Ingress Controller to another. For example, issues often arise when switching from one Ingress Controller to another because annotations are often vendor-specific.

Operational constraints

Finally, the Ingress API suffers from operational constraints: it is not well suited for multi-team clusters with shared load-balancing infrastructure.

The Gateway API was designed to address the limitations of Ingress API. The Kubernetes SIG-Network team designs and maintains the Gateway API.

For more information about the Gateway API, see the Gateway API project page.

The Gateway API provides a centralized mechanism for managing and enforcing policies for external traffic, including HTTP routing, TLS termination, traffic splitting/weighting, and header modification.

Native support of policies for external traffic means that annotations are no longer required to support ingress traffic patterns. This means that Gateway API resources are more portable from one Gateway API implementation to another.

When customization is required, Gateway API provides several flexible models, including specific extension points to enable diverse traffic patterns. As the Gateway API team adds extensions, the team looks for common denominators and promotes features of API conformance to maximize the ease of extending Ingress API resources.

Finally, the Gateway API is designed with role-based personas in mind. The Ingress model is based on a persona where developers manage and create ingress and service resources themselves.

In more complex deployments, more personas are involved:

Infrastructure Providers administrate the managed services of a cloud provider, or the infrastructure/network team when running Kubernetes on-premises.

Cluster Operators are responsible for the administration of a cluster.

Application Developers are responsible for defining application configuration and service composition.

By deconstructing the Ingress API into several Gateway API objects, personas gain the specific access and privileges that their responsibilities require.

For example, application developers in a specific team could be assigned permissions to create Route objects in a specified namespace without also gaining permissions to modify the Gateway configuration or edit Route objects in namespaces other than theirs.

There are two primary methods to migrate Ingress API resources to Gateway API:

manual: manually creating Gateway API resources based on existing Ingress API resources.

automated: creating rules using the ingress2gateway tool. The ingress2gateway project reads Ingress resources from a Kubernetes cluster based on your current Kube Config. It outputs YAML for equivalent Gateway API resources to stdout.

The ingress2gateway tool remains experimental and is not recommended for production.

Most Ingress controllers use annotations to provide support for specific features, such as HTTP request manipulation and routing. As noted in Benefits of the Gateway API, the Gateway API avoids implementation-specific annotations in order to provide a portable configuration.

As a consequence, it’s rare to port implementation-specific Ingress annotations to a Gateway API resource. Instead, the Gateway API provides native support for some of these features, including:

Request/response manipulation

Header, query parameter, or method-based routing

For examples of migrating to Cilium’s Gateway API features, see:

---

## Proxy Load Balancing for Kubernetes Services (beta) — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/envoy-load-balancing/

**Contents:**
- Proxy Load Balancing for Kubernetes Services (beta)
- Deploy Test Applications
- Start Observing Traffic with Hubble
- Add Proxy Load Balancing Annotations to the Services
- Supported Annotations

This guide explains how to configure Proxy Load Balancing for Kubernetes services using Cilium, which is useful for use cases such as gRPC load-balancing. Once enabled, the traffic to a Kubernetes service will be redirected to a Cilium-managed Envoy proxy for load balancing. This feature is independent of the Kubernetes Ingress Support feature.

This is a beta feature. Please provide feedback and file a GitHub issue if you experience any problems.

The test workloads consist of:

one client deployment client

one service echo-service with two backend pods.

View information about these pods:

Enable Hubble in your cluster with the step mentioned in Setting up Hubble Observability.

Start a second terminal, then enable hubble port forwarding and observe traffic for the service echo-service:

You should be able to get a response from both of the backend services individually from client:

Notice that Hubble shows all the flows between the client pod and the backend pods via echo-service service.

Adding a Layer 7 policy introduces the Envoy proxy into the path for this traffic.

Make a request to a backend service and observe the traffic with Hubble again:

The request is now proxied through the Envoy proxy and then flows to the backend.

service.cilium.io/lb-l7

Enable L7 Load balancing for kubernetes service.

service.cilium.io/lb-l7-algorithm

The LB algorithm to be used for services.

round_robin, least_request, random

Defaults to Helm option loadBalancer.l7.algorithm value.

---

## Mutual Authentication Example — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/mutual-authentication/mutual-authentication-example/

**Contents:**
- Mutual Authentication Example
- Verify SPIRE Health
- Verify SPIFFE Identities
- Enforce Mutual Authentication
- Verify Mutual Authentication

This example shows you how to enforce mutual authentication between two Pods.

Deploy a client (pod-worker) and a server (echo) using the following manifest:

Verify that the Pods have been successfully deployed:

Verify that the network policy has been deployed successfully and filters the traffic as expected.

Run the following commands:

The first request should be successful (the pod-worker Pod is able to connect to the echo Service over a specific HTTP path and the HTTP status code is 200). The second one should be denied (the pod-worker Pod is unable to connect to the echo Service over a specific HTTP path other than ‘/headers’).

Before we enable mutual authentication between pod-worker and echo, let’s verify that the SPIRE server is healthy.

Assuming you have followed the installation instructions and have a SPIRE server serving Cilium, adding mutual authentication simply requires adding authentication.mode: "required" in the ingress/egress block in your network policies.

This example assumes a default SPIRE installation.

Let’s first verify that the SPIRE server and agents automatically deployed are working as expected.

The SPIRE server is deployed as a StatefulSet and the SPIRE agents are deployed as a DaemonSet (you should therefore see one SPIRE agent per node).

Run a healthcheck on the SPIRE server.

Verify the list of attested agents:

Notice that the SPIRE Server uses Kubernetes Projected Service Account Tokens (PSATs) to verify the Identity of a SPIRE Agent running on a Kubernetes Cluster. Projected Service Account Tokens provide additional security guarantees over traditional Kubernetes Service Account Tokens and when supported by a Kubernetes cluster, PSAT is the recommended attestation strategy.

Now that we know the SPIRE service is healthy, let’s verify that the Cilium and SPIRE integration has been successful:

The Cilium agent and operator should have a registered delegate Identity with the SPIRE Server.

The Cilium operator should have registered Identities with the SPIRE server on behalf of the workloads (Kubernetes Pods).

Verify that the Cilium agent and operator have Identities on the SPIRE server:

Next, verify that the echo Pod has an Identity registered with the SPIRE server.

To do this, you must first construct the Pod’s SPIFFE ID. The SPIFFE ID for a workload is based on the spiffe://spiffe.cilium/identity/$IDENTITY_ID format, where $IDENTITY_ID is a workload’s Cilium Identity.

Grab the Cilium Identity for the echo Pod;

Use the Cilium Identity for the echo pod to construct its SPIFFE ID and check it is registered on the SPIRE server:

You can see the that the cilium-operator was listed in the Parent ID. That is because the Cilium operator creates SPIRE entries for Cilium Identities as they are created.

To get all registered entries, execute the following command:

There are as many entries as there are identities. Verify that these match by running the command:

The identify ID listed under NAME should match with the digits at the end of the SPIFFE ID executed in the previous command.

Rolling out mutual authentication with Cilium is as simple as adding the following block to an existing or new CiliumNetworkPolicy egress or ingress rules:

Update the existing rule to only allow ingress access to mutually authenticated workloads to access echo using:

Re-try your connectivity tests. They should give similar results as before:

Verify that mutual authentication has happened by accessing the logs on the agent.

Start by enabling debug level:

Examine the logs on the Cilium agent located in the same node as the echo Pod. For brevity, you can search for some specific log messages:

When you apply a mutual authentication policy, the agent retrieves the identity of the source Pod, connects to the node where the destination Pod is running and performs a mutual TLS handshake (with the log above showing one side of the mutual TLS handshake). As the handshake succeeded, the connection was authenticated and the traffic protected by policy could proceed.

Packets between the two Pods can flow until the network policy is removed or the entry expires.

---

## HTTPS Example — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/https/

**Contents:**
- HTTPS Example
- Create TLS Certificate and Private Key
- Deploy the Gateway and HTTPRoute
- Make HTTPS Requests

This example builds on the previous HTTP Example and add TLS termination for two HTTP routes. For simplicity, the second route to productpage is omitted.

For demonstration purposes we will use a TLS certificate signed by a made-up, self-signed certificate authority (CA). One easy way to do this is with mkcert. We want a certificate that will validate bookinfo.cilium.rocks and hipstershop.cilium.rocks, as these are the host names used in this example.

Create a Kubernetes secret with this demo key and certificate:

Let us install cert-manager:

Now, create a CA Issuer:

The Gateway configuration for this demo provides the similar routing to the details and productpage services.

To tell cert-manager that this Ingress needs a certificate, annotate the Gateway with the name of the CA issuer we previously created:

This creates a Certificate object along with a Secret containing the TLS certificate.

External IP address will be shown up in Gateway. Also, the host names should be shown up in related HTTPRoutes.

Update /etc/hosts with the host names and IP address of the Gateway:

By specifying the CA’s certificate on a curl request, you can say that you trust certificates signed by that CA.

If you prefer, instead of supplying the CA you can specify -k to tell the curl client not to validate the server’s certificate. Without either, you will get an error that the certificate was signed by an unknown authority.

Specifying -v on the curl request, you can see that the TLS handshake took place successfully.

---

## gRPC Example — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/grpc/

**Contents:**
- gRPC Example
- Deploy the Gateway and GRPCRoute
- Make gRPC Requests

This example demonstrates how to set up a Gateway that terminates TLS traffic and routes requests to a gRPC service (i.e. using HTTP/2). In order for this example to work, ALPN support needs to be enabled with the Helm flag gatewayAPI.enableAlpn set to true. This enables clients to request HTTP/2 through the TLS negotiation.

This example uses a TLS certificate signed by a made-up, self-signed certificate authority (CA). One easy way to do this is with mkcert. The certificate will validate the hostname grpc-echo.cilium.rocks used in this example.

Create a Kubernetes secret with this demo key and certificate:

Install cert-manager:

Now, create a CA Issuer:

This sets up a simple gRPC echo server and a Gateway to expose it.

The self-signed certificate Secrets from the previous step will be used by this Gateway.

To tell cert-manager that this Gateway needs a certificate, annotate the Gateway with the name of the CA issuer you created previously:

This creates a Certificate object along with a Secret containing the TLS certificate.

External IP address will be shown up in Gateway. Also, the host names should show up in related HTTPRoutes.

Update /etc/hosts with the host names and IP address of the Gateway:

You can use the grpcurl cli tool to verify that the service works correctly. The echo server used in this example will respond with information about the HTTP/2 request the client made.

By specifying the CA’s certificate on a curl request, you can say that you trust certificates signed by that CA.

If you prefer, instead of supplying the CA you can specify -insecure to tell the curl client not to validate the server’s certificate. Without either, you will get an error that the certificate was signed by an unknown authority.

---

## Troubleshooting — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/kubernetes/troubleshooting/

**Contents:**
- Troubleshooting
- Verifying the installation
- Apiserver outside of cluster

Check the status of the DaemonSet and verify that all desired instances are in “ready” state:

In this example, we see a desired state of 1 with 0 being ready. This indicates a problem. The next step is to list all cilium pods by matching on the label k8s-app=cilium and also sort the list by the restart count of each pod to easily identify the failing pods:

Pod cilium-813gf is failing and has already been restarted 2 times. Let’s print the logfile of that pod to investigate the cause:

In this example, the cause for the failure is a Linux kernel running on the worker node which is not meeting System Requirements.

If the cause for the problem is not apparent based on these simple steps, please come and seek help on Cilium Slack.

If you are running Kubernetes Apiserver outside of your cluster for some reason (like keeping master nodes behind a firewall), make sure that you run Cilium on master nodes too. Otherwise Kubernetes pod proxies created by Apiserver will not be able to route to pod IPs and you may encounter errors when trying to proxy traffic to pods.

You may run Cilium as a static pod or set tolerations for Cilium DaemonSet to ensure that Cilium pods will be scheduled on your master nodes. The exact way to do it depends on your setup.

---

## Kubernetes Host Scope — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/concepts/ipam/kubernetes/

**Contents:**
- Kubernetes Host Scope
- Configuration

The Kubernetes host-scope IPAM mode is enabled with ipam: kubernetes and delegates the address allocation to each individual node in the cluster. IPs are allocated out of the PodCIDR range associated to each node by Kubernetes.

In this mode, the Cilium agent will wait on startup until the PodCIDR range is made available via the Kubernetes v1.Node object for all enabled address families via one of the following methods:

via v1.Node resource field

IPv4 and/or IPv6 PodCIDR range

IPv4 or IPv6 PodCIDR range

It is important to run the kube-controller-manager with the flag --allocate-node-cidrs flag to indicate to Kubernetes that PodCIDR ranges should be allocated.

via v1.Node annotation

network.cilium.io/ipv4-pod-cidr

network.cilium.io/ipv6-pod-cidr

network.cilium.io/ipv4-cilium-host

IPv4 address of the cilium host interface

network.cilium.io/ipv6-cilium-host

IPv6 address of the cilium host interface

network.cilium.io/ipv4-health-ip

IPv4 address of the cilium-health endpoint

network.cilium.io/ipv6-health-ip

IPv6 address of the cilium-health endpoint

network.cilium.io/ipv4-Ingress-ip

IPv4 address of the cilium-ingress endpoint

network.cilium.io/ipv6-Ingress-ip

IPv6 address of the cilium-ingress endpoint

The annotation-based mechanism is primarily useful in combination with older Kubernetes versions which do not support spec.podCIDRs yet but support for both IPv4 and IPv6 is enabled.

The following ConfigMap options exist to configure Kubernetes hostscope:

ipam: kubernetes: Enables Kubernetes IPAM mode. Enabling this option will automatically enable k8s-require-ipv4-pod-cidr if enable-ipv4 is true and k8s-require-ipv6-pod-cidr if enable-ipv6 is true.

k8s-require-ipv4-pod-cidr: true: instructs the Cilium agent to wait until an IPv4 PodCIDR is made available via the Kubernetes node resource.

k8s-require-ipv6-pod-cidr: true: instructs the Cilium agent to wait until an IPv6 PodCIDR is made available via the Kubernetes node resource.

With helm the previous options can be defined as:

ipam: kubernetes: --set ipam.mode=kubernetes.

k8s-require-ipv4-pod-cidr: true: --set k8s.requireIPv4PodCIDR=true, which only works with --set ipam.mode=kubernetes

k8s-require-ipv6-pod-cidr: true: --set k8s.requireIPv6PodCIDR=true, which only works with --set ipam.mode=kubernetes

---

## Egress Gateway — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/egress-gateway-toc/

**Contents:**
- Egress Gateway

---

## Load-balancing & Service Discovery — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/clustermesh/services/

**Contents:**
- Load-balancing & Service Discovery
- Prerequisites
- Load-balancing with Global Services
- Disabling Global Service Sharing
- Synchronizing Kubernetes EndpointSlice (Beta)
  - Known Limitations
    - Deploying a Simple Example Service
- Global and Shared Services Reference
- Limitations

This tutorial will guide you to perform load-balancing and service discovery across multiple Kubernetes clusters when using Cilium.

You need to have a functioning Cluster Mesh setup, please follow the guide Setting up Cluster Mesh to set it up.

Establishing load-balancing between clusters is achieved by defining a Kubernetes service with identical name and namespace in each cluster and adding the annotation service.cilium.io/global: "true" to declare it global. Cilium will automatically perform load-balancing to pods in both clusters.

By default, a Global Service will load-balance across backends in multiple clusters. This implicitly configures service.cilium.io/shared: "true". To prevent service backends from being shared to other clusters, this option should be disabled.

Below example will expose remote endpoint without sharing local endpoints.

This is a beta feature. Please provide feedback and file a GitHub issue if you experience any problems.

By default Kubernetes EndpointSlice synchronization is disabled on non Headless Global services. To have Cilium discover remote clusters endpoints of a Global Service from DNS or any third party controllers, enable synchronization by adding the annotation service.cilium.io/global-sync-endpoint-slices: "true". This will allow Cilium to create Kubernetes EndpointSlices belonging to a remote cluster for services that have that annotation. Regarding Global Headless services this option is enabled by default unless explicitly opted-out by adding the annotation service.cilium.io/global-sync-endpoint-slices: "false".

Note that this feature does not complement/is not required by any other Cilium features and is only required if you need to discover EndpointSlice from remote cluster on third party controllers. For instance, the Cilium ingress controller works in a Cluster Mesh without enabling this feature, although if you use any other ingress controller you may need to enable this.

This feature is currently disabled by default via a feature flag. To install Cilium with EndpointSlice Cluster Mesh synchronization, run:

To enable EndpointSlice Cluster Mesh synchronization on an existing Cilium installation, run:

This is a beta feature, you may experience bugs or shortcomings.

Hostnames are synchronized as is without any form of conflict resolution mechanisms. This means that multiple StatefulSets with a single governing Service that synchronize EndpointSlices across multiple clusters should have different names. For instance, you can add the cluster name to the StatefulSet name (cluster1-my-statefulset instead of my-statefulset).

In cluster 1, deploy:

In cluster 2, deploy:

From either cluster, access the global service:

You will see replies from pods in both clusters.

In cluster 1, add service.cilium.io/shared="false" to existing global service

From cluster 1, access the global service one more time:

You will still see replies from pods in both clusters.

From cluster 2, access the global service again:

You will see replies from pods only from cluster 2, as the global service in cluster 1 is no longer shared.

In cluster 1, remove service.cilium.io/shared annotation of existing global service

From either cluster, access the global service:

You will see replies from pods in both clusters again.

The flow chart below summarizes the overall behavior considering a service present in two clusters (i.e., Cluster1 and Cluster2), and different combinations of the service.cilium.io/global and service.cilium.io/shared annotation values. The terminating nodes represent the endpoints used in each combination by the two clusters for the service under examination.

Global NodePort services load balance across both local and remote backends only if Cilium is configured to replace kube-proxy (either kubeProxyReplacement=true or nodePort.enabled=true). Otherwise, only local backends are eligible for load balancing when accessed through the NodePort.

Global services accessed by a Node, or a Pod running in host network, load balance across both local and remote backends only if Cilium is configured to replace kube-proxy (kubeProxyReplacement=true). This limitation can be overcome enabling SocketLB in the host namespace: socketLB.enabled=true, socketLB.hostNamespaceOnly=true. Otherwise, only local backends are eligible for load balancing.

---

## Ingress gRPC Example — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/grpc/

**Contents:**
- Ingress gRPC Example
- Deploy the Demo App
- Deploy GRPC Ingress
- Make gRPC Requests to Backend Services

The example ingress configuration in grpc-ingress.yaml shows how to route gRPC traffic to backend services.

For this demo we will use GCP’s microservices demo app.

Since gRPC is binary-encoded, you also need the proto definitions for the gRPC services in order to make gRPC requests. Download this for the demo app:

You’ll find the example Ingress definition in examples/kubernetes/servicemesh/grpc-ingress.yaml.

This defines paths for requests to be routed to the productcatalogservice and currencyservice microservices.

Just as in the previous HTTP Ingress Example, this creates a LoadBalancer service, and it may take a little while for your cloud provider to provision an external IP address.

To issue client gRPC requests you can use grpcurl.

---

## Local Redirect Policy — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/kubernetes/local-redirect-policy/

**Contents:**
- Local Redirect Policy
- Prerequisites
- Create backend and client pods
- Create Cilium Local Redirect Policy Custom Resources
  - AddressMatcher
  - ServiceMatcher
- Limitations
- Use Cases
  - Node-local DNS cache
- Advanced configurations

This document explains how to configure Cilium’s Local Redirect Policy, that enables pod traffic destined to an IP address and port/protocol tuple or Kubernetes service to be redirected locally to backend pod(s) within a node, using eBPF. The namespace of backend pod(s) need to match with that of the policy. The CiliumLocalRedirectPolicy is configured as a CustomResourceDefinition.

Aside from this document, you can watch a video explanation of Cilium’s Local Redirect Policy on eCHO episode 39: Local Redirect Policy.

There are two types of Local Redirect Policies supported. When traffic for a Kubernetes service needs to be redirected, use the ServiceMatcher type. The service needs to be of type clusterIP. When traffic matching IP address and port/protocol, that doesn’t belong to any Kubernetes service, needs to be redirected, use the AddressMatcher type.

The policies can be gated by Kubernetes Role-based access control (RBAC) framework. See the official RBAC documentation.

When policies are applied, matched pod traffic is redirected. If desired, RBAC configurations can be used such that application developers can not escape the redirection.

Setup Helm repository:

Enable the feature by setting the localRedirectPolicies.enabled value to true.

Rollout the operator and agent pods to make the changes effective:

Verify that Cilium agent and operator pods are running.

Validate that the Cilium Local Redirect Policy CRD has been registered.

Local Redirect Policy supports either the socket-level loadbalancer or the tc loadbalancer. The configuration depends on your specific use case and the type of service handling required. Below are the Helm setups to work with localRedirectPolicies.enabled=true:

Enable full kube-proxy replacement:

This setup is for users who want to replace kube-proxy with Cilium’s eBPF implementation and leverage Local Redirect Policy.

Bypass the socket-level loadbalancer in pod namespaces:

This setup is for users who want to disable the socket-level loadbalancer in pod namespaces. For example, this might be needed if there are custom redirection rules in the pod namespace that would conflict with the socket-level load balancer.

Enable the socket-level loadbalancer only:

This setup is for users who prefer to retain kube-proxy for overall service handling but still want to leverage Cilium’s Local Redirect Policy.

Disable any service handling except for ClusterIP services accessed from pods:

If you want to fully rely on kube-proxy for the service handling, you can disable all kube-proxy replacement functionality expect ClusterIP services accessed from pod namespace. Note that the pod traffic from host namespace isn’t handled by Local Redirect Policy with this setup.

Deploy a backend pod where traffic needs to be redirected to based on the configurations specified in a CiliumLocalRedirectPolicy. The metadata labels and container port and protocol respectively match with the labels, port and protocol fields specified in the CiliumLocalRedirectPolicy custom resources that will be created in the next step.

Verify that the pod is running.

Deploy a client pod that will generate traffic which will be redirected based on the configurations specified in the CiliumLocalRedirectPolicy.

There are two types of configurations supported in the CiliumLocalRedirectPolicy in order to match the traffic that needs to be redirected.

This type of configuration is specified using an IP address and a Layer 4 port/protocol. When multiple ports are specified for frontend in toPorts, the ports need to be named. The port names will be used to map frontend ports with backend ports.

Verify that the ports specified in toPorts under redirectBackend exist in the backend pod spec.

The example shows how to redirect from traffic matching, IP address 169.254.169.254 and Layer 4 port 8080 with protocol TCP, to a backend pod deployed with labels app=proxy and Layer 4 port 80 with protocol TCP. The localEndpointSelector set to app=proxy in the policy is used to select the backend pods where traffic is redirected to.

Create a custom resource of type CiliumLocalRedirectPolicy with addressMatcher configuration.

Verify that the custom resource is created.

Verify that Cilium’s eBPF kube-proxy replacement created a LocalRedirect service entry with the backend IP address of that of the lrp-pod that was selected by the policy. Make sure that cilium-dbg service list is run in Cilium pod running on the same node as lrp-pod.

Invoke a curl command from the client pod to the IP address and port configuration specified in the lrp-addr custom resource above.

Verify that the traffic was redirected to the lrp-pod that was deployed. tcpdump should be run on the same node that lrp-pod is running on.

The allowed addresses can be constrained clusterwide using the localRedirectPolicies.addressMatcherCIDRs helm option:

The above would only allow traffic going to 169.254.169.254 to be redirected with an AddressMatcher rule. A policy with a disallowed address will be rejected and a warning log message is emitted by cilium-agent.

This type of configuration is specified using Kubernetes service name and namespace for which traffic needs to be redirected. The service must be of type clusterIP. When toPorts under redirectFrontend are not specified, traffic for all the service ports will be redirected. However, if traffic destined to only a subset of ports needs to be redirected, these ports need to be specified in the spec. Additionally, when multiple service ports are specified in the spec, they must be named. The port names will be used to map frontend ports with backend ports. Verify that the ports specified in toPorts under redirectBackend exist in the backend pod spec. The localEndpointSelector set to app=proxy in the policy is used to select the backend pods where traffic is redirected to.

When a policy of this type is applied, the existing service entry created by Cilium’s eBPF kube-proxy replacement will be replaced with a new service entry of type LocalRedirect. This entry may only have node-local backend pods.

The example shows how to redirect from traffic matching my-service, to a backend pod deployed with labels app=proxy and Layer 4 port 80 with protocol TCP. The localEndpointSelector set to app=proxy in the policy is used to select the backend pods where traffic is redirected to.

Deploy the Kubernetes service for which traffic needs to be redirected.

Verify that the service is created.

Verify that Cilium’s eBPF kube-proxy replacement created a ClusterIP service entry.

Create a custom resource of type CiliumLocalRedirectPolicy with serviceMatcher configuration.

Verify that the custom resource is created.

Verify that entry Cilium’s eBPF kube-proxy replacement updated the service entry with type LocalRedirect and the node-local backend selected by the policy. Make sure to run cilium-dbg service list in Cilium pod running on the same node as lrp-pod.

Invoke a curl command from the client pod to the Cluster IP address and port of my-service specified in the lrp-svc custom resource above.

Verify that the traffic was redirected to the lrp-pod that was deployed. tcpdump should be run on the same node that lrp-pod is running on.

When you create a Local Redirect Policy, traffic for all the new connections that get established after the policy is enforced will be redirected. But if you have existing active connections to remote pods that match the configurations specified in the policy, then these might not get redirected. To ensure all such connections are redirected locally, restart the client pods after configuring the CiliumLocalRedirectPolicy.

Local Redirect Policy updates are currently not supported. If there are any changes to be made, delete the existing policy, and re-create a new one.

Local Redirect Policy allows Cilium to support the following use cases:

DNS node-cache listens on a static IP to intercept traffic from application pods to the cluster’s DNS service VIP by default, which will be bypassed when Cilium is handling service resolution at or before the veth interface of the application pod. To enable the DNS node-cache in a Cilium cluster, the following example steers traffic to a local DNS node-cache which runs as a normal pod.

Deploy DNS node-cache in pod namespace.

Deploy DNS node-cache.

The example yaml is populated with default values for __PILLAR_LOCAL_DNS__ and __PILLAR_DNS_DOMAIN__.

If you have a different deployment, please follow the official NodeLocal DNSCache Configuration to fill in the required template variables __PILLAR__LOCAL__DNS__, __PILLAR__DNS__DOMAIN__, and __PILLAR__DNS__SERVER__ before applying the yaml.

Follow the official NodeLocal DNSCache Configuration to fill in the required template variables __PILLAR__LOCAL__DNS__, __PILLAR__DNS__DOMAIN__, and __PILLAR__DNS__SERVER__ before applying the yaml.

Make sure to use a Node-local DNS image with a release version >= 1.15.16. This is to ensure that we have a knob to disable dummy network interface creation/deletion in Node-local DNS when we deploy it in non-host namespace.

Modify Node-local DNS cache’s deployment yaml to pass these additional arguments to node-cache: -skipteardown=true, -setupinterface=false, and -setupiptables=false.

Modify Node-local DNS cache’s deployment yaml to put it in non-host namespace by setting hostNetwork: false for the daemonset.

In the Corefile, bind to 0.0.0.0 instead of the static IP.

In the Corefile, let CoreDNS serve health-check on its own IP instead of the static IP by removing the host IP string after health plugin.

Modify Node-local DNS cache’s deployment yaml to point readiness probe to its own IP by removing the host field under readinessProbe.

Deploy Local Redirect Policy (LRP) to steer DNS traffic to the node local dns cache.

The LRP above uses kube-dns for the cluster DNS service, however if your cluster DNS service is different, you will need to modify this example LRP to specify it.

The namespace specified in the LRP above is set to the same namespace as the cluster’s dns service.

The LRP above uses the same port names dns and dns-tcp as the example quick deployment yaml, you will need to modify those to match your deployment if they are different.

After all node-local-dns pods are in ready status, DNS traffic will now go to the local node-cache first. You can verify by checking the DNS cache’s metrics coredns_dns_request_count_total via curling <node-local-dns pod IP>:9253/metrics, the metric should increment as new DNS requests being issued from application pods are now redirected to the node-local-dns pod.

In the absence of a node-local DNS cache, DNS queries from application pods will get directed to cluster DNS pods backed by the kube-dns service.

If DNS requests are failing to resolve, check the following:

Ensure that the node-local DNS cache pods are running and ready.

Check if the local redirect policy has been applied correctly on all the cilium agent pods.

Check if the corresponding local redirect service entry has been created. If the service entry is missing, there might have been a race condition in applying the policy and the node-local DNS DaemonSet pod resources. As a workaround, you can restart the node-local DNS DaemonSet pods. File a GitHub issue with a sysdump if the issue persists.

When a local redirect policy is applied, cilium BPF datapath redirects traffic going to the policy frontend (identified by ip/port/protocol tuple) address to a node-local backend pod selected by the policy. However, for traffic originating from a node-local backend pod destined to the policy frontend, users may want to skip redirecting the traffic back to the node-local backend pod, and instead forward the traffic to the original frontend. This behavior can be enabled by setting the skipRedirectFromBackend flag to true in the local redirect policy spec. This configuration requires the use of getsockopt() with the SO_NETNS_COOKIE option, which is available in Linux kernel version >= 5.12. Note that SO_NETNS_COOKIE was introduced in 5.7 (available to BPF programs), and exposed to user space in versions >= 5.12.

In order to enable this configuration starting Cilium version 1.16.0, previously applied local redirect policies and policies selected backend pods need to be deleted, and re-created.

---

## Introduction — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/ebpf/intro/

**Contents:**
- Introduction

The Linux kernel supports a set of BPF hooks in the networking stack that can be used to run BPF programs. The Cilium datapath uses these hooks to load BPF programs that when used together create higher level networking constructs.

The following is a list of the hooks used by Cilium and a brief description. For a more thorough documentation on specifics of each hook see BPF and XDP Reference Guide.

XDP: The XDP BPF hook is at the earliest point possible in the networking driver and triggers a run of the BPF program upon packet reception. This achieves the best possible packet processing performance since the program runs directly on the packet data before any other processing can happen. This hook is ideal for running filtering programs that drop malicious or unexpected traffic, and other common DDOS protection mechanisms.

Traffic Control Ingress/Egress: BPF programs attached to the traffic control (tc) ingress hook are attached to a networking interface, same as XDP, but will run after the networking stack has done initial processing of the packet. The hook is run before the L3 layer of the stack but has access to most of the metadata associated with a packet. This is ideal for doing local node processing, such as applying L3/L4 endpoint policy and redirecting traffic to endpoints. For network-facing devices the tc ingress hook can be coupled with above XDP hook. When this is done it is reasonable to assume that the majority of the traffic at this point is legitimate and destined for the host.

Containers typically use a virtual device called a veth pair which acts as a virtual wire connecting the container to the host. By attaching to the TC ingress hook of the host side of this veth pair Cilium can monitor and enforce policy on all traffic exiting a container. By attaching a BPF program to the veth pair associated with each container and routing all network traffic to the host side virtual devices with another BPF program attached to the tc ingress hook as well Cilium can monitor and enforce policy on all traffic entering or exiting the node.

Socket operations: The socket operations hook is attached to a specific cgroup and runs on TCP events. Cilium attaches a BPF socket operations program to the root cgroup and uses this to monitor for TCP state transitions, specifically for ESTABLISHED state transitions. When a socket transitions into ESTABLISHED state if the TCP socket has a node local peer (possibly a local proxy) a socket send/recv program is attached.

Socket send/recv: The socket send/recv hook runs on every send operation performed by a TCP socket. At this point the hook can inspect the message and either drop the message, send the message to the TCP layer, or redirect the message to another socket. Cilium uses this to accelerate the datapath redirects as described below.

Combining the above hooks with virtual interfaces (cilium_host, cilium_net), an optional overlay interface (cilium_vxlan), Linux kernel crypto support and a userspace proxy (Envoy) Cilium creates the following networking objects.

Prefilter: The prefilter object runs an XDP program and provides a set of prefilter rules used to filter traffic from the network for best performance. Specifically, a set of CIDR maps supplied by the Cilium agent are used to do a lookup and the packet is either dropped, for example when the destination is not a valid endpoint, or allowed to be processed by the stack. This can be easily extended as needed to build in new prefilter criteria/capabilities.

Endpoint Policy: The endpoint policy object implements the Cilium endpoint enforcement. Using a map to lookup a packet’s associated identity and policy, this layer scales well to lots of endpoints. Depending on the policy this layer may drop the packet, forward to a local endpoint, forward to the service object or forward to the L7 Policy object for further L7 rules. This is the primary object in the Cilium datapath responsible for mapping packets to identities and enforcing L3 and L4 policies.

Service: The Service object performs a map lookup on the destination IP and optionally destination port for every packet received by the object. If a matching entry is found, the packet will be forwarded to one of the configured L3/L4 endpoints. The Service block can be used to implement a standalone load balancer on any interface using the TC ingress hook or may be integrated in the endpoint policy object.

L3 Encryption: On ingress the L3 Encryption object marks packets for decryption, passes the packets to the Linux xfrm (transform) layer for decryption, and after the packet is decrypted the object receives the packet then passes it up the stack for further processing by other objects. Depending on the mode, direct routing or overlay, this may be a BPF tail call or the Linux routing stack that passes the packet to the next object. The key required for decryption is encoded in the IPsec header so on ingress we do not need to do a map lookup to find the decryption key.

On egress a map lookup is first performed using the destination IP to determine if a packet should be encrypted and if so what keys are available on the destination node. The most recent key available on both nodes is chosen and the packet is marked for encryption. The packet is then passed to the Linux xfrm layer where it is encrypted. Upon receiving the now encrypted packet it is passed to the next layer either by sending it to the Linux stack for routing or doing a direct tail call if an overlay is in use.

Socket Layer Enforcement: Socket layer enforcement uses two hooks (the socket operations hook and the socket send/recv hook) to monitor and attach to all TCP sockets associated with Cilium managed endpoints, including any L7 proxies. The socket operations hook will identify candidate sockets for accelerating. These include all local node connections (endpoint to endpoint) and any connection to a Cilium proxy. These identified connections will then have all messages handled by the socket send/recv hook. The fast redirect ensures all policies implemented in Cilium are valid for the associated socket/endpoint mapping and assuming they are sends the message directly to the peer socket.

L7 Policy: The L7 Policy object redirects proxy traffic to a Cilium userspace proxy instance. Cilium uses an Envoy instance as its userspace proxy. Envoy will then either forward the traffic or generate appropriate reject messages based on the configured L7 policy.

These components are connected to create the flexible and efficient datapath used by Cilium. Below we show the following possible flows connecting endpoints on a single node, ingress to an endpoint, and endpoint to egress networking device. In each case there is an additional diagram showing the TCP accelerated path available when socket layer enforcement is enabled.

---

## Introduction — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/kubernetes/intro/

**Contents:**
- Introduction
- What does Cilium provide in your Kubernetes Cluster?
- Pod-to-Pod Connectivity
- Service Load-balancing
- Further Reading

The following functionality is provided as you run Cilium in your Kubernetes cluster:

CNI plugin support to provide pod_connectivity with Multi-cluster Networking.

Identity based implementation of the NetworkPolicy resource to isolate pod to pod connectivity on Layer 3 and 4.

An extension to NetworkPolicy in the form of a CustomResourceDefinition which extends policy control to add:

Layer 7 policy enforcement on ingress and egress for the following application protocols:

Egress support for CIDRs to secure access to external services

Enforcement to external headless services to automatically restrict to the set of Kubernetes endpoints configured for a service.

ClusterIP implementation to provide distributed load-balancing for pod to pod traffic.

Fully compatible with existing kube-proxy model

If you’d like to learn more about Kubernetes networking and Cilium, check out eCHO episode 99: Explain Kubernetes Networking and Cilium to Network Engineers.

In Kubernetes, containers are deployed within units referred to as Pods, which include one or more containers reachable via a single IP address. With Cilium, each Pod gets an IP address from the node prefix of the Linux node running the Pod. See IP Address Management (IPAM) for additional details. In the absence of any network security policies, all Pods can reach each other.

Pod IP addresses are typically local to the Kubernetes cluster. If pods need to reach services outside the cluster as a client, the network traffic is automatically masqueraded as it leaves the node.

Kubernetes has developed the Services abstraction which provides the user the ability to load balance network traffic to different pods. This abstraction allows the pods reaching out to other pods by a single IP address, a virtual IP address, without knowing all the pods that are running that particular service.

Without Cilium, kube-proxy is installed on every node, watches for endpoints and services addition and removal on the kube-master which allows it to apply the necessary enforcement on iptables. Thus, the received and sent traffic from and to the pods are properly routed to the node and port serving for that service. For more information you can check out the kubernetes user guide for Services.

When implementing ClusterIP, Cilium acts on the same principles as kube-proxy, it watches for services addition or removal, but instead of doing the enforcement on the iptables, it updates eBPF map entries on each node. For more information, see the Pull Request.

The Kubernetes documentation contains more background on the Kubernetes Networking Model and Kubernetes Network Plugins.

---

## Kubernetes Without kube-proxy — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/kubernetes/kubeproxy-free/

**Contents:**
- Kubernetes Without kube-proxy
- Quick-Start
- Validate the Setup
- Advanced Configuration
  - Client Source IP Preservation
  - Internal Traffic Policy
  - Selective Service Type Exposure
  - Host Proxy Delegation
  - Selective Service Node Exposure
  - Maglev Consistent Hashing

This guide explains how to provision a Kubernetes cluster without kube-proxy, and to use Cilium to fully replace it. For simplicity, we will use kubeadm to bootstrap the cluster.

For help with installing kubeadm and for more provisioning options please refer to the official Kubeadm documentation.

Cilium’s kube-proxy replacement depends on the socket-LB feature.

Initialize the control-plane node via kubeadm init and skip the installation of the kube-proxy add-on:

Depending on what CRI implementation you are using, you may need to use the --cri-socket flag with your kubeadm init ... command. For example: if you’re using Docker CRI you would use --cri-socket unix:///var/run/cri-dockerd.sock.

Afterwards, join worker nodes by specifying the control-plane node IP address and the token returned by kubeadm init (for this tutorial, you will want to add at least one worker node to the cluster):

Please ensure that kubelet’s --node-ip is set correctly on each worker if you have multiple interfaces. Cilium’s kube-proxy replacement may not work correctly otherwise. You can validate this by running kubectl get nodes -o wide to see whether each node has an InternalIP which is assigned to a device with the same name on each node.

For existing installations with kube-proxy running as a DaemonSet, remove it by using the following commands below.

Be aware that removing kube-proxy will break existing service connections. It will also stop service related traffic until the Cilium replacement has been installed.

When deploying the eBPF kube-proxy replacement under co-existence with kube-proxy on the system, be aware that both mechanisms operate independent of each other. Meaning, if the eBPF kube-proxy replacement is added or removed on an already running cluster in order to delegate operation from respectively back to kube-proxy, then it must be expected that existing connections will break since, for example, both NAT tables are not aware of each other. If deployed in co-existence on a newly spawned up node/cluster which does not yet serve user traffic, then this is not an issue.

Setup Helm repository:

Next, generate the required YAML files and deploy them.

Make sure you correctly set your API_SERVER_IP and API_SERVER_PORT below with the control-plane node IP address and the kube-apiserver port number reported by kubeadm init (Kubeadm will use port 6443 by default).

Specifying this is necessary as kubeadm init is run explicitly without setting up kube-proxy and as a consequence, although it exports KUBERNETES_SERVICE_HOST and KUBERNETES_SERVICE_PORT with a ClusterIP of the kube-apiserver service to the environment, there is no kube-proxy in our setup provisioning that service. Therefore, the Cilium agent needs to be made aware of this information with the following configuration:

Cilium will automatically mount cgroup v2 filesystem required to attach BPF cgroup programs by default at the path /run/cilium/cgroupv2. To do that, it needs to mount the host /proc inside an init container launched by the DaemonSet temporarily. If you need to disable the auto-mount, specify --set cgroup.autoMount.enabled=false, and set the host mount point where cgroup v2 filesystem is already mounted by using --set cgroup.hostRoot. For example, if not already mounted, you can mount cgroup v2 filesystem by running the below command on the host, and specify --set cgroup.hostRoot=/sys/fs/cgroup.

This will install Cilium as a CNI plugin with the eBPF kube-proxy replacement to implement handling of Kubernetes services of type ClusterIP, NodePort, LoadBalancer and services with externalIPs. As well, the eBPF kube-proxy replacement also supports hostPort for containers such that using portmap is not necessary anymore.

Finally, as a last step, verify that Cilium has come up correctly on all nodes and is ready to operate:

Note, in above Helm configuration, the kubeProxyReplacement has been set to true mode. This means that the Cilium agent will bail out in case the underlying Linux kernel support is missing.

By default, Helm sets kubeProxyReplacement=false, which only enables per-packet in-cluster load-balancing of ClusterIP services.

Cilium’s eBPF kube-proxy replacement is supported in direct routing as well as in tunneling mode.

After deploying Cilium with above Quick-Start guide, we can first validate that the Cilium agent is running in the desired mode:

Use --verbose for full details:

As an optional next step, we will create an Nginx Deployment. Then we’ll create a new NodePort service and validate that Cilium installed the service correctly.

The following YAML is used for the backend pods:

Verify that the Nginx pods are up and running:

In the next step, we create a NodePort service for the two instances:

Verify that the NodePort service has been created:

With the help of the cilium-dbg service list command, we can validate that Cilium’s eBPF kube-proxy replacement created the new NodePort service. In this example, services with port 31940 were created (one for each of devices eth0 and eth1):

Create a variable with the node port for testing:

At the same time we can verify, using iptables in the host namespace, that no iptables rule for the service is present:

Last but not least, a simple curl test shows connectivity for the exposed NodePort as well as for the ClusterIP:

As can be seen, Cilium’s eBPF kube-proxy replacement is set up correctly.

This section covers a few advanced configuration modes for the kube-proxy replacement that go beyond the above Quick-Start guide and are entirely optional.

Cilium’s eBPF kube-proxy replacement implements various options to avoid performing SNAT on NodePort requests where the client source IP address would otherwise be lost on its path to the service endpoint.

externalTrafficPolicy=Local: The Local policy is generally supported through the eBPF implementation. In-cluster connectivity for services with externalTrafficPolicy=Local is possible and can also be reached from nodes which have no local backends, meaning, given SNAT does not need to be performed, all service endpoints are available for load balancing from in-cluster side.

externalTrafficPolicy=Cluster: For the Cluster policy which is the default upon service creation, multiple options exist for achieving client source IP preservation for external traffic, that is, operating the kube-proxy replacement in DSR or Hybrid mode if only TCP-based services are exposed to the outside world for the latter.

Similar to externalTrafficPolicy described above, Cilium’s eBPF kube-proxy replacement supports internalTrafficPolicy, which translates the above semantics to in-cluster traffic.

For services with internalTrafficPolicy=Local, traffic originated from pods in the current cluster is routed only to endpoints within the same node the traffic originated from.

internalTrafficPolicy=Cluster is the default, and it doesn’t restrict the endpoints that can handle internal (in-cluster) traffic.

The following table gives an idea of what backends are used to serve connections to a service, depending on the external and internal traffic policies:

Service backends used

for North-South traffic

for East-West traffic

By default, for a LoadBalancer service Cilium exposes corresponding NodePort and ClusterIP services. Likewise, for a new NodePort service, Cilium exposes the corresponding ClusterIP service.

If this behavior is not desired, then the service.cilium.io/type annotation can be used to pin the service creation only to a specific service type:

In the above example only the LoadBalancer service is created without corresponding NodePort and ClusterIP services. If the annotation would be set to e.g. service.cilium.io/type: NodePort, then only the NodePort service would be installed.

If the selected service backend IP for a given service matches the local node IP, the annotation service.cilium.io/proxy-delegation: delegate-if-local will pass the received packet unmodified to the upper stack, so that a L7 proxy such as Envoy (if present) can handle the request in the host namespace.

If the selected service backend is a remote IP, then the received packet is not pushed to the upper stack and instead the BPF code forwards the packet natively with the configured forwarding method to the remote IP.

In combination with externalTrafficPolicy=Local this mechanism also allows for pushing all traffic to the upper proxy.

Non-presence of the service.cilium.io/proxy-delegation annotation leaves all forwarding to BPF natively which is also the default for the kube-proxy replacement case.

By default, Cilium exposes Kubernetes services on all nodes in the cluster. To expose a service only on a subset of the nodes instead, use the service.cilium.io/node label for the relevant nodes. For example, label a node as follows:

To add a new service that should only be exposed to nodes with label service.cilium.io/node=beefy, install the service as follows:

It’s also possible to control the service node exposure via the annotation service.cilium.io/node-selector - where the annotation value contains the label selector. This way, the service is only exposed on nodes that match the node label selector. The annotation service.cilium.io/node-selector always has priority over service.cilium.io/node if both exist on the same service.

Note that changing a node label after a service has been exposed matching that label does not automatically update the list of nodes where the service is exposed. To update exposure of the service after changing node labels, restart the Cilium agent. Generally it is advised to fixate the node label upon joining the Kubernetes cluster and retain it throughout the node’s lifetime.

Cilium’s eBPF kube-proxy replacement supports consistent hashing by implementing a variant of The Maglev hashing in its load balancer for backend selection. This improves resiliency in case of failures. As well, it provides better load balancing properties since Nodes added to the cluster will make consistent backend selection throughout the cluster for a given 5-tuple without having to synchronize state with the other Nodes. Similarly, upon backend removal the backend lookup tables are reprogrammed with minimal disruption for unrelated backends (at most 1% difference in the reassignments) for the given service.

Maglev hashing for services load balancing can be enabled by setting loadBalancer.algorithm=maglev:

Note that Maglev hashing is applied only to external (N-S) traffic. For in-cluster service connections (E-W), sockets are assigned to service backends directly, e.g. at TCP connect time, without any intermediate hop and thus are not subject to Maglev. Maglev hashing is also supported for Cilium’s XDP acceleration.

There are two more Maglev-specific configuration settings: maglev.tableSize and maglev.hashSeed.

maglev.tableSize specifies the size of the Maglev lookup table for each single service. Maglev recommends the table size (M) to be significantly larger than the number of maximum expected backends (N). In practice that means that M should be larger than 100 * N in order to guarantee the property of at most 1% difference in the reassignments on backend changes. M must be a prime number. Cilium uses a default size of 16381 for M. The following sizes for M are supported as maglev.tableSize Helm option:

maglev.tableSize value

For example, a maglev.tableSize of 16381 is suitable for a maximum of ~160 backends per service. If a higher number of backends are provisioned under this setting, then the difference in reassignments on backend changes will increase. Note that changing the table size (M) triggers a recalculation of the lookup table and can temporarily lead to inconsistent backend selection for new traffic until all nodes have converged and completed their agent restart.

The maglev.hashSeed option is recommended to be set in order for Cilium to not rely on the fixed built-in seed. The seed is a base64-encoded 12 byte-random number, and can be generated once through head -c12 /dev/urandom | base64 -w0, for example. Every Cilium agent in the cluster must use the same hash seed for Maglev to work.

The below deployment example is generating and passing such seed to Helm as well as setting the Maglev table size to 65521 to allow for ~650 maximum backends for a given service (with the property of at most 1% difference on backend reassignments):

Note that enabling Maglev will have a higher memory consumption on each Cilium-managed Node compared to the default of loadBalancer.algorithm=random given random does not need the extra lookup tables. However, random won’t have consistent backend selection.

By default, Cilium’s eBPF NodePort implementation operates in SNAT mode. That is, when node-external traffic arrives and the node determines that the backend for the LoadBalancer, NodePort, or services with externalIPs is at a remote node, then the node is redirecting the request to the remote backend on its behalf by performing SNAT. This does not require any additional MTU changes. The cost is that replies from the backend need to make the extra hop back to that node to perform the reverse SNAT translation there before returning the packet directly to the external client.

This setting can be changed through the loadBalancer.mode Helm option to dsr in order to let Cilium’s eBPF NodePort implementation operate in DSR mode. In this mode, the backends reply directly to the external client without taking the extra hop, meaning, backends reply by using the service IP/port as a source.

Another advantage in DSR mode is that the client’s source IP is preserved, so policy can match on it at the backend node. In the SNAT mode this is not possible. Given a specific backend can be used by multiple services, the backends need to be made aware of the service IP/port which they need to reply with. Cilium encodes this information into the packet (using one of the dispatch mechanisms described below), at the cost of advertising a lower MTU. For TCP services, Cilium only encodes the service IP/port for the SYN packet, but not subsequent ones. This optimization also allows to operate Cilium in a hybrid mode as detailed in the later subsection where DSR is used for TCP and SNAT for UDP in order to avoid an otherwise needed MTU reduction.

In some public cloud provider environments that implement source / destination IP address checking (e.g. AWS), the checking has to be disabled in order for the DSR mode to work.

By default Cilium uses special ExternalIP mitigation for CVE-2020-8554 MITM vulnerability. This may affect connectivity targeted to ExternalIP on the same cluster. This mitigation can be disabled by setting bpf.disableExternalIPMitigation to true.

For help to choice the Dispatch, the following table specifies DSR Dispatch Mode supported following Routing mode (Native/Tunnel) and Tunnel Protocol.

In this DSR dispatch mode, the service IP/port information is transported to the backend through a Cilium-specific IPv4 Option or IPv6 Destination Option extension header. It requires Cilium to be deployed in Native-Routing, i.e. it will not work in Encapsulation mode.

This DSR mode might not work in some public cloud provider environments due to the Cilium-specific IP options that could be dropped by an underlying network fabric. In case of connectivity issues to services where backends are located on a remote node from the node that is processing the given NodePort request, first check whether the NodePort request actually arrived on the node containing the backend. If this was not the case, then consider either switching to DSR with Geneve (as described below), or switching back to the default SNAT mode.

The above Helm example configuration in a kube-proxy-free environment with DSR-only mode enabled would look as follows:

By default, Cilium with DSR mode encodes the service IP/port in a Cilium-specific IPv4 option or IPv6 Destination Option extension so that the backends are aware of the service IP/port, which they need to reply with.

However, some data center routers pass packets with unknown IP options to software processing called “Layer 2 slow path”. Those routers drop the packets if the amount of packets with IP options exceeds a given threshold, which may significantly affect network performance.

Cilium offers another dispatch mode, DSR with Geneve, to avoid this problem. In DSR with Geneve, Cilium encapsulates packets to the Loadbalancer with the Geneve header that includes the service IP/port in the Geneve option and redirects them to the backends.

The Helm example configuration in a kube-proxy-free environment with DSR and Geneve dispatch enabled would look as follows:

DSR with Geneve is compatible with the Geneve encapsulation mode (Encapsulation). It works with either the direct routing mode or the Geneve tunneling mode. Unfortunately, it doesn’t work with the vxlan encapsulation mode.

The example configuration in DSR with Geneve dispatch and tunneling mode is as follows.

Cilium also supports a hybrid DSR and SNAT mode, that is, DSR is performed for TCP and SNAT for UDP connections.

This removes the need for manual MTU changes in the network while still benefiting from the latency improvements through the removed extra hop for replies, in particular, when TCP is the main transport for workloads.

The mode setting loadBalancer.mode allows to control the behavior through the options dsr, snat, annotation, and hybrid. By default the snat mode is used in the agent.

A Helm example configuration in a kube-proxy-free environment with DSR enabled in hybrid mode would look as follows:

Cilium also supports an annotation-based DSR and SNAT mode, that is, services can be exposed by default via SNAT and on-demand as DSR (or vice versa):

Note that the forwarding-mode annotation must be set at service creation time and should not be changed during the lifetime of that service. Changing the value of the annotation or removing the annotation while the service is installed breaks connections.

The above example installs the Kubernetes service only as type LoadBalancer, that is, without the corresponding NodePort and ClusterIP services, and uses the configured DSR method to forward the packets instead of default SNAT. The Helm setting loadBalancer.mode=snat defines the default as SNAT in this example. A loadBalancer.mode=dsr would have switched the default to DSR instead and then service.cilium.io/forwarding-mode: snat annotation can be used to switch to SNAT instead.

A Helm example configuration in a kube-proxy-free environment with DSR enabled in annotation mode with SNAT default would look as follows:

When using annotation-based DSR mode (bpf.lbModeAnnotation=true), as in the previous example, you must explicitly specify the loadBalancer.dsrDispatch parameter to define how DSR packets are dispatched to backends. Valid options are opt, ipip, and geneve.

Cilium has the ability to specify the load balancing algorithm on a per-service basis through the service.cilium.io/lb-algorithm annotation. Setting bpf.lbAlgorithmAnnotation=true opts into this ability for the BPF and corresponding agent code. A typical use-case is to reduce the memory footprint which comes with Maglev given the latter requires large lookup tables for each service. Thus, if not all services need consistent hashing, then these can fallback to a random selection instead.

By default, if no service annotation is provided, the logic falls back to use whichever method was specified globally through loadBalancer.algorithm. The latter supports either random or maglev as values today with random being the default if loadBalancer.algorithm was not explicitly set via Helm.

To add a new service which must use random as its load balancing algorithm:

Similarly, for opting into maglev, use the following:

All north-south traffic is now subsequently subject to maglev-based load balancing for the latter example.

Note that service.cilium.io/lb-algorithm only takes effect upon initial service creation and cannot be changed during the lifetime of the given Kubernetes service. Switching between load balancing algorithms requires recreation of a service.

The socket-level loadbalancer acts transparent to Cilium’s lower layer datapath in that upon connect (TCP, connected UDP), sendmsg (UDP), or recvmsg (UDP) system calls, the destination IP is checked for an existing service IP and one of the service backends is selected as a target. This means that although the application assumes it is connected to the service address, the corresponding kernel socket is actually connected to the backend address and therefore no additional lower layer NAT is required.

Cilium has built-in support for bypassing the socket-level loadbalancer and falling back to the tc loadbalancer at the veth interface when a custom redirection/operation relies on the original ClusterIP within pod namespace (e.g., Istio sidecar) or due to the Pod’s nature the socket-level loadbalancer is ineffective (e.g., KubeVirt, Kata Containers, gVisor).

Setting socketLB.hostNamespaceOnly=true enables this bypassing mode. When enabled, this circumvents socket rewrite in the connect() and sendmsg() syscall bpf hook and will pass the original packet to next stage of operation (e.g., stack in per-endpoint-routing mode) and re-enables service lookup in the tc bpf program.

A Helm example configuration in a kube-proxy-free environment with socket LB bypass looks as follows:

Cilium has built-in support for accelerating NodePort, LoadBalancer services and services with externalIPs for the case where the arriving request needs to be forwarded and the backend is located on a remote node. This feature was introduced in Cilium version 1.8 at the XDP (eXpress Data Path) layer where eBPF is operating directly in the networking driver instead of a higher layer.

Setting loadBalancer.acceleration to option native enables this acceleration. The option disabled is the default and disables the acceleration. The majority of drivers supporting 10G or higher rates also support native XDP on a recent kernel. For cloud based deployments most of these drivers have SR-IOV variants that support native XDP as well. For on-prem deployments the Cilium XDP acceleration can be used in combination with LoadBalancer service implementations for Kubernetes such as MetalLB. The acceleration can be enabled only on a single device which is used for direct routing.

For high-scale environments, also consider tweaking the default map sizes to a larger number of entries e.g. through setting a higher config.bpfMapDynamicSizeRatio. See eBPF Maps for further details.

The loadBalancer.acceleration setting is supported for DSR, SNAT and hybrid modes and can be enabled as follows for loadBalancer.mode=hybrid in this example:

In case of a multi-device environment, where Cilium’s device auto-detection selects more than a single device to expose NodePort or a user specifies multiple devices with devices, the XDP acceleration is enabled on all devices. This means that each underlying device’s driver must have native XDP support on all Cilium managed nodes. If you have an environment where some devices support XDP but others do not you can have XDP enabled on the supported devices by setting loadBalancer.acceleration to best-effort.

A list of drivers supporting XDP can be found in the XDP documentation.

The current Cilium kube-proxy XDP acceleration mode can also be introspected through the cilium-dbg status CLI command. If it has been enabled successfully, Native is shown:

Note that packets which have been pushed back out of the device for NodePort handling right at the XDP layer are not visible in tcpdump since packet taps come at a much later stage in the networking stack. Cilium’s monitor command or metric counters can be used instead for gaining visibility.

In order to run with NodePort XDP on AWS, follow the instructions in the Cilium Quick Installation guide to set up an EKS cluster or use any other method of your preference to set up a Kubernetes cluster.

If you are following the EKS guide, make sure to create a node group with SSH access, since we need few additional setup steps as well as create a larger instance type which supports the Elastic Network Adapter (ena). As an instance example, m5n.xlarge is used in the config nodegroup-config.yaml:

Please make sure to read and understand the documentation page on taint effects and unmanaged pods.

The nodegroup is created with:

Each of the nodes need the kernel-ng and ethtool package installed. The former is needed in order to run a sufficiently recent kernel for eBPF in general and native XDP support on the ena driver. The latter is needed to configure channel parameters for the NIC.

Once the nodes come back up their kernel version should say 5.4.58-27.104.amzn2.x86_64 or similar through uname -r. In order to run XDP on ena, make sure the driver version is at least 2.2.8. The driver version can be inspected through ethtool -i eth0. For the given kernel version the driver version should be reported as 2.2.10g.

Before Cilium’s XDP acceleration can be deployed, there are two settings needed on the network adapter side, that is, MTU needs to be lowered in order to be able to operate with XDP, and number of combined channels need to be adapted.

The default MTU is set to 9001 on the ena driver. Given XDP buffers are linear, they operate on a single page. A driver typically reserves some headroom for XDP as well (e.g. for encapsulation purpose), therefore, the highest possible MTU for XDP would be 3498.

In terms of ena channels, the settings can be gathered via ethtool -l eth0. For the m5n.xlarge instance, the default output should look like:

In order to use XDP the channels must be set to at most 1/2 of the value from Combined above. Both, MTU and channel changes are applied as follows:

In order to deploy Cilium, the Kubernetes API server IP and port is needed:

Finally, the deployment can be upgraded and later rolled-out with the loadBalancer.acceleration=native setting to enable XDP in Cilium:

To enable NodePort XDP on Azure AKS or a self-managed Kubernetes running on Azure, the virtual machines running Kubernetes must have Accelerated Networking enabled. In addition, the Linux kernel on the nodes must also have support for native XDP in the hv_netvsc driver, which is available in kernel >= 5.6 and was backported to the Azure Linux kernel in 5.4.0-1022.

On AKS, make sure to use the AKS Ubuntu 22.04 node image with Kubernetes version v1.26 which will provide a Linux kernel with the necessary backports to the hv_netvsc driver. Please refer to the documentation on how to configure an AKS cluster for more details.

To enable accelerated networking when creating a virtual machine or virtual machine scale set, pass the --accelerated-networking option to the Azure CLI. Please refer to the guide on how to create a Linux virtual machine with Accelerated Networking using Azure CLI for more details.

When Accelerated Networking is enabled, lspci will show a Mellanox ConnectX NIC:

XDP acceleration can only be enabled on NICs ConnectX-4 Lx and onwards.

In order to run XDP, large receive offload (LRO) needs to be disabled on the hv_netvsc device. If not the case already, this can be achieved by:

It is recommended to use Azure IPAM for the pod IP address allocation, which will automatically configure your virtual network to route pod traffic correctly:

When running Azure IPAM on a self-managed Kubernetes cluster, each v1.Node must have the resource ID of its VM in the spec.providerID field. Refer to the Azure IPAM reference for more information.

NodePort XDP on the Google Cloud Platform is currently not supported. Both virtual network interfaces available on Google Compute Engine (the older virtIO-based interface and the newer gVNIC) are currently lacking support for native XDP.

When running Cilium’s eBPF kube-proxy replacement, by default, a NodePort or LoadBalancer service or a service with externalIPs will be accessible through the IP addresses of native devices which have the default route on the host or have Kubernetes InternalIP or ExternalIP assigned. InternalIP is preferred over ExternalIP if both exist. To change the devices, set their names in the devices Helm option, e.g. devices='{eth0,eth1,eth2}'. Each listed device has to be named the same on all Cilium managed nodes. Alternatively if the devices do not match across different nodes, the wildcard option can be used, e.g. devices=eth+, which would match any device starting with prefix eth. If no device can be matched the Cilium agent will try to perform auto detection.

When multiple devices are used, only one device can be used for direct routing between Cilium nodes. By default, if a single device was detected or specified via devices then Cilium will use that device for direct routing. Otherwise, Cilium will use a device with Kubernetes InternalIP or ExternalIP set. InternalIP is preferred over ExternalIP if both exist. To change the direct routing device, set the nodePort.directRoutingDevice Helm option, e.g. nodePort.directRoutingDevice=eth1. The wildcard option can be used as well as the devices option, e.g. directRoutingDevice=eth+. If more than one devices match the wildcard option, Cilium will sort them in increasing alphanumerical order and pick the first one. If the direct routing device does not exist within devices, Cilium will add the device to the latter list. The direct routing device is used for the NodePort XDP acceleration as well (if enabled).

In addition, thanks to the socket-LB feature, the NodePort service can be accessed by default from a host or a pod within a cluster via its public, any local (except for docker* prefixed names) or loopback address, e.g. 127.0.0.1:NODE_PORT.

If kube-apiserver was configured to use a non-default NodePort port range, then the same range must be passed to Cilium via the nodePort.range option, for example, as nodePort.range="10000\,32767" for a range of 10000-32767. The default Kubernetes NodePort range is 30000-32767.

If the NodePort port range overlaps with the ephemeral port range (net.ipv4.ip_local_port_range), Cilium will append the NodePort range to the reserved ports (net.ipv4.ip_local_reserved_ports). This is needed to prevent a NodePort service from hijacking traffic of a host local application which source port matches the service port. To disable the modification of the reserved ports, set nodePort.autoProtectPortRanges to false.

By default, the NodePort implementation prevents application bind(2) requests to NodePort service ports. In such case, the application will typically see a bind: Operation not permitted error. By default this happens only for the host namespace and therefore does not affect any application pod bind(2) requests. In order to opt-out from this behavior in general, this setting can be changed for expert users by switching nodePort.bindProtection to false.

For high-scale environments, Cilium’s BPF maps can be configured to have higher limits on the number of entries. Overriding Helm options can be used to tweak these limits.

To increase the number of entries in Cilium’s BPF LB service, backend and affinity maps consider overriding bpf.lbMapMax Helm option. The default value of this LB map size is 65536.

Although not part of kube-proxy, Cilium’s eBPF kube-proxy replacement also natively supports hostPort service mapping without having to use the Helm CNI chaining option of cni.chainingMode=portmap.

By specifying kubeProxyReplacement=true the native hostPort support is automatically enabled and therefore no further action is required.

If the hostPort is specified without an additional hostIP, then the Pod will be exposed to the outside world with the same local addresses from the node that were detected and used for exposing NodePort services, e.g. the Kubernetes InternalIP or ExternalIP if set.

Additionally, the Pod is also accessible through the loopback address on the node such as 127.0.0.1:hostPort. If in addition to hostPort also a hostIP has been specified for the Pod, then the Pod will only be exposed on the given hostIP instead. A hostIP of 0.0.0.0 will have the same behavior as if a hostIP was not specified.

The hostPort must not reside in the configured NodePort port range to avoid collisions.

Note that hostPort support relies on Cilium’s eBPF kube-proxy replacement and in the background plumbs service entries to direct traffic to the local host port backend. Given host port is not configured through a Kubernetes service object, the full feature set of Kubernetes services (such as custom Cilium service annotations) is not available. Instead, host port piggy-backs on user-configured defaults of the service handling behavior.

An example deployment in a kube-proxy-free environment therefore is the same as in the earlier getting started deployment:

Also, ensure that each node IP is known via INTERNAL-IP or EXTERNAL-IP, for example:

If this is not the case, then kubelet needs to be made aware of it through specifying --node-ip through KUBELET_EXTRA_ARGS. Assuming eth0 is the public facing interface, this can be achieved by:

After updating /etc/default/kubelet, kubelet needs to be restarted.

In order to verify whether the HostPort feature has been enabled in Cilium, the cilium-dbg status CLI command provides visibility through the KubeProxyReplacement info line. If it has been enabled successfully, HostPort is shown as Enabled, for example:

The following modified example yaml from the setup validation with an additional hostPort: 8080 parameter can be used to verify the mapping:

After deployment, we can validate that Cilium’s eBPF kube-proxy replacement exposed the container as HostPort under the specified port 8080:

Similarly, we can inspect through iptables in the host namespace that no iptables rule for the HostPort service is present:

Last but not least, a simple curl test shows connectivity for the exposed HostPort container under the node’s IP:

Removing the deployment also removes the corresponding HostPort from the cilium-dbg service list dump:

Cilium’s eBPF kube-proxy replacement supports graceful termination of service endpoint pods. The Cilium agent detects such terminating Pod events, and increments the metric k8s_terminating_endpoints_events_total.

When Cilium agent receives a Kubernetes update event that marks an endpoint as terminating Cilium will retain the datapath state necessary for existing connections. The terminating endpoint will be used as fallback for new connections only if 1) no active endpoints exist for the service and 2) terminating endpoint has condition serving (e.g. pod is still passing readinessProbes).

If publishNotReadyAddresses is set on the Service the endpoints received by Cilium may have both the ready and terminating conditions set. In this case Cilium follows kube-proxy and uses these for new connections, ignoring the terminating condition.

The endpoint state is fully removed when the agent receives a Kubernetes delete event for the endpoint. The Kubernetes pod termination documentation contains more background on the behavior and configuration using terminationGracePeriodSeconds. There are some special cases, like zero disruption during rolling updates, that require to be able to send traffic to Terminating Pods that are still Serving traffic during the Terminating period, the Kubernetes blog Advancements in Kubernetes Traffic Engineering explains it in detail.

To learn more about Cilium’s graceful termination support, check out eCHO Episode 49: Graceful Termination Support with Cilium 1.11.

Cilium’s eBPF kube-proxy replacement supports Kubernetes service session affinity. Each connection from the same pod or host to a service configured with sessionAffinity: ClientIP will always select the same service endpoint. The default timeout for the affinity is three hours (updated by each request to the service), but it can be configured through Kubernetes’ sessionAffinityConfig if needed.

The source for the affinity depends on the origin of a request. If a request is sent from outside the cluster to the service, the request’s source IP address is used for determining the endpoint affinity. If a request is sent from inside the cluster, then the source depends on whether the socket-LB feature is used to load balance ClusterIP services. If yes, then the client’s network namespace cookie is used as the source - it allows to implement affinity at the socket layer at which the socket-LB operates (a source IP is not available there, as the endpoint selection happens before a network packet has been built by the kernel). If the socket-LB is not used (i.e. the loadbalancing is done at the pod network interface, on a per-packet basis), then the request’s source IP address is used as the source.

The session affinity support is enabled by default. To disable the feature, set config.sessionAffinity=false.

The session affinity of a service with multiple ports is per service IP and port. Meaning that all requests for a given service sent from the same source and to the same service port will be routed to the same service endpoints; but two requests for the same service, sent from the same source but to different service ports may be routed to distinct service endpoints.

Note that if the session affinity feature is used in combination with Maglev consistent hashing to select backends, then Maglev will not take the source port as input for its hashing in order to respect the user’s ClientIP choice (see also GH#26709 for further details).

To enable health check server for the kube-proxy replacement, the kubeProxyReplacementHealthzBindAddr option has to be set (disabled by default). The option accepts the IP address with port for the health check server to serve on. E.g. to enable for IPv4 interfaces set kubeProxyReplacementHealthzBindAddr='0.0.0.0:10256', for IPv6 - kubeProxyReplacementHealthzBindAddr='[::]:10256'. The health check server is accessible via the HTTP /healthz endpoint.

When a LoadBalancer service is configured with spec.loadBalancerSourceRanges, Cilium’s eBPF kube-proxy replacement restricts access from outside (e.g. external world traffic) to the service to the white-listed CIDRs specified in the field. If the field is empty, no restrictions for the access will be applied.

When accessing the service from inside a cluster, the kube-proxy replacement will ignore the field regardless whether it is set. This means that any pod or any host process in the cluster will be able to access the LoadBalancer service internally.

By default the specified white-listed CIDRs in spec.loadBalancerSourceRanges only apply to the LoadBalancer service, but not the corresponding NodePort or ClusterIP service which get installed along with the LoadBalancer service.

If this behavior is not desired, then there are two options available: One possibility is to avoid the creation of corresponding NodePort and ClusterIP services via service.cilium.io/type annotation:

The other possibility is to propagate the white-listed CIDRs to all externally exposed service types. Meaning, NodePort as well as ClusterIP (if externally accessible, see External Access To ClusterIP Services section) also filter traffic based on the source IP addresses. This option can be enabled in Helm via bpf.lbSourceRangeAllTypes=true.

The loadBalancerSourceRanges by default specifies an allow-list of CIDRs, meaning, traffic originating not from those CIDRs is automatically dropped.

Cilium also supports the option to turn this list into a deny-list, in order to block traffic from certain CIDRs while allowing everything else. This behavior can be achieved through the service.cilium.io/src-ranges-policy annotation which accepts the values of allow or deny.

The default loadBalancerSourceRanges behavior equals to service.cilium.io/src-ranges-policy: allow:

In order to turn the CIDR list into a deny-list while allowing traffic not originating from this set, this can be changed into service.cilium.io/src-ranges-policy: deny:

Like kube-proxy, Cilium also honors the service.kubernetes.io/service-proxy-name service annotation and only manages services that contain a matching service-proxy-name label. This name can be configured by setting k8s.serviceProxyName option and the behavior is identical to that of kube-proxy. The service proxy name defaults to an empty string which instructs Cilium to only manage services not having service.kubernetes.io/service-proxy-name label.

For more details on the usage of service.kubernetes.io/service-proxy-name label and its working, take a look at this KEP.

If Cilium with a non-empty service proxy name is meant to manage all services in kube-proxy free mode, make sure that default Kubernetes services like kube-dns and kubernetes have the required label value.

The kube-proxy replacement implements both Kubernetes Topology Aware Routing, and the more recent Traffic Distribution features.

Both of these features work by setting hints on EndpointSlices that enable Cilium to route to endpoints residing in the same zone. To enable the feature, set loadBalancer.serviceTopology=true.

When kube-proxy replacement and XDP acceleration are enabled, Cilium does L2 neighbor discovery of nodes and service backends in the cluster. This is required for the service load-balancing to populate L2 addresses for backends since it is not possible to dynamically resolve neighbors on demand in the fast-path.

L2 neighbor discovery is automatically enabled when the agent detects that XDP is in use, but can also be manually turned on by setting the --enable-l2-neigh-discovery=true flag or l2NeighDiscovery.enabled=true Helm option.

The agent fully relies on the Linux kernel to discover gateways or hosts on the same L2 network. Both IPv4 and IPv6 neighbor discovery is supported in the Cilium agent. As per our kernel work presented at Plumbers, “managed” neighbor entries have been upstreamed and will be available in Linux kernel v5.16 or later which the Cilium agent will detect and transparently use. In this case, the agent pushes down L3 addresses of new nodes joining the cluster as externally learned “managed” neighbor entries. For introspection, iproute2 displays them as “managed extern_learn”. The extern_learn attribute prevents garbage collection of the entries by the kernel’s neighboring subsystem. Such “managed” neighbor entries are dynamically resolved and periodically refreshed by the Linux kernel itself in case there is no active traffic for a certain period of time. That is, the kernel attempts to always keep them in REACHABLE state. For Linux kernels v5.15 or earlier where “managed” neighbor entries are not present, the Cilium agent similarly pushes L3 addresses of new nodes into the kernel for dynamic resolution. For introspection, iproute2 displays them only as extern_learn in this case. If there is no active traffic for a certain period of time and entries become state, the Cilium agent triggers the Linux kernel-based re-resolution for attempting to keep them in REACHABLE state.

The Cilium agent actively monitors devices, routes, and neighbors and reconciles the neighbor entries in the kernel. For example if a device is added new neighbor entries for the device are added. When routes change, such as a change to the next-hop, the Cilium agent updates the neighbor entries accordingly. And when neighbor entries are flushed due to for example a carrier-down event, the Cilium agent restores the neighbor entries as soon as possible.

The neighbor discovery supports multi-device environments where each node has multiple devices and multiple next-hops to another node. The Cilium agent pushes neighbor entries for all target devices, including the direct routing device. Currently, it supports one next-hop per device. The following example illustrates how the neighbor discovery works in a multi-device environment. Each node has two devices connected to different L3 networks (10.69.0.64/26 and 10.69.0.128/26), and global scope addresses each (10.69.0.1/26 and 10.69.0.2/26). A next-hop from node1 to node2 is either 10.69.0.66 dev eno1 or 10.69.0.130 dev eno2. The Cilium agent pushes neighbor entries for both 10.69.0.66 dev eno1 and 10.69.0.130 dev eno2 in this case.

As per k8s Service, Cilium’s eBPF kube-proxy replacement by default disallows access to a ClusterIP service from outside the cluster. This can be allowed by setting bpf.lbExternalClusterIP=true.

If you are running multiple instances of Kubernetes API servers in your cluster, you can set the k8s-api-server-urls flag so that Cilium can fail over to an active instance. Cilium switches to the kubernetes service address so that API requests are load-balanced to API server endpoints during runtime. However, if the initially configured API servers are rotated while the agent is down, you can update the k8s-api-server-urls flag with the updated API servers.

You can trace socket LB related datapath events using Hubble and cilium monitor.

Apply the following pod and service:

Deploy a client pod to start traffic.

Follow the Hubble Inspecting Network Flows with the CLI guide to see the network flows. The Hubble output prints datapath events before and after socket LB translation between service and selected service endpoint.

Socket LB tracing with Hubble requires cilium agent to detect pod cgroup paths. If you see a message in cilium agent Failed to setup socket load-balancing tracing with Hubble., you can trace packets using cilium-dbg monitor instead.

If you observe the message about socket load-balancing setup failure in the logs, please file a GitHub issue with the cgroup path for any of your pods, obtained by running the following command on a Kubernetes node in your cluster: sudo crictl inspectp -o=json $POD_ID | grep cgroup.

You can identify the client pod using its printed cgroup id metadata. The pod cgroup path corresponding to the cgroup id has its UUID. The socket cookie is a unique socket identifier allocated in the Linux kernel. The socket cookie metadata can be used to identify all the trace events from a socket.

Cilium attaches BPF cgroup programs to enable socket-based load-balancing (aka host-reachable services). If you see connectivity issues for clusterIP services, check if the programs are attached to the host cgroup root. The default cgroup root is set to /run/cilium/cgroupv2. Run the following commands from a Cilium agent pod as well as the underlying kubernetes node where the pod is running. If the container runtime in your cluster is running in the cgroup namespace mode, Cilium agent pod can attach BPF cgroup programs to the virtualized cgroup root. In such cases, Cilium kube-proxy replacement based load-balancing may not be effective leading to connectivity issues. For more information, ensure that you have the fix Pull Request.

If a given backend endpoint is reachable through multiple services (i.e., via different VIPs or NodePorts), a new connection from a client to a different VIP or NodePort may reuse an existing connection tracking state from a connection to a different VIP or NodePort. This can happen if the client selects the same source port. In such cases, the connection might be dropped.

The following scenarios are prone to this problem:

With DSR: A client running outside a cluster sends requests CLIENT_IP:SRC_PORT -> LB1_IP:LB1_PORT and CLIENT_IP:SRC_PORT -> LB2_IP:LB2_PORT via an intermediate K8s node(s). The intermediate node selects BACKEND_IP:BACKEND_PORT for each request and forwards them to the backend endpoint. Each request appears identical as CLIENT_IP:SRC_PORT -> BACKEND_IP:BACKEND_PORT, so the backend cannot distinguish between them.

With or without DSR: A client running outside a cluster sends requests CLIENT_IP:SRC_PORT -> LB1_IP:LB1_PORT and CLIENT_IP:SRC_PORT -> LB2_IP:LB2_PORT to a K8s node that runs the selected backend endpoint. Again, each request appears the same: CLIENT_IP:SRC_PORT -> BACKEND_IP:BACKEND_PORT.

Without Socket LB: A client running in a Pod sends requests CLIENT_IP:SRC_PORT -> LB1_IP:LB1_PORT and CLIENT_IP:SRC_PORT -> LB2_IP:LB2_PORT. The per-packet load-balancer then DNATs each request to the backend, resulting in CLIENT_IP:SRC_PORT -> BACKEND_IP:BACKEND_PORT.

Therefore, it is highly recommended not to expose a backend endpoint via multiple VIPs GitHub issue 11810 GitHub issue 18632.

Cilium’s eBPF kube-proxy replacement relies upon the socket-LB feature which uses eBPF cgroup hooks to implement the service translation. Using it with libceph deployments currently requires support for the getpeername(2) hook address translation in eBPF.

NFS and SMB mounts may break when mounted to a Service cluster IP while using socket-LB. This issue is known to impact Longhorn, Portworx, and Robin, but may impact other storage systems that implement ReadWriteMany volumes using this pattern. To avoid this problem, ensure that the following commits are part of your underlying kernel:

0bdf399342c5 ("net: Avoid address overwrite in kernel_connect")

86a7e0b69bd5 ("net: prevent rewrite of msg_name in sock_sendmsg()")

01b2885d9415 ("net: Save and restore msg_namelen in sock_sendmsg")

cedc019b9f26 ("smb: use kernel_connect() and kernel_bind()") (SMB only)

These patches have been backported to all stable kernels and some distro-specific kernels:

Ubuntu: 5.4.0-187-generic, 5.15.0-113-generic, 6.5.0-41-generic or newer.

RHEL 8: 4.18.0-553.8.1.el8_10.x86_64 or newer (RHEL 8.10+).

RHEL 9: kernel-5.14.0-427.31.1.el9_4 or newer (RHEL 9.4+).

For a more detailed discussion see GitHub issue 21541.

Cilium’s DSR NodePort mode currently does not operate well in environments with TCP Fast Open (TFO) enabled. It is recommended to switch to snat mode in this situation.

Cilium’s eBPF kube-proxy replacement does not support the SCTP transport protocol except in a few basic cases. For more information, see SCTP support (beta). Only TCP and UDP are fully supported as a transport for services at this time.

Cilium’s eBPF kube-proxy replacement does not allow hostPort port configurations for Pods that overlap with the configured NodePort range. In such case, the hostPort setting will be ignored and a warning emitted to the Cilium agent log. Similarly, explicitly binding the hostIP to the loopback address in the host namespace is currently not supported and will log a warning to the Cilium agent log.

The neighbor discovery in a multi-device environment doesn’t work with the runtime device detection which means that the target devices for the neighbor discovery doesn’t follow the device changes.

When socket-LB feature is enabled, pods sending (connected) UDP traffic to services can continue to send traffic to a service backend even after it’s deleted. Cilium agent handles such scenarios by forcefully terminating application sockets that are connected to deleted backends, so that the applications can be load-balanced to active backends. This functionality requires these kernel configs to be enabled: CONFIG_INET_DIAG, CONFIG_INET_UDP_DIAG and CONFIG_INET_DIAG_DESTROY.

Cilium’s BPF-based masquerading is recommended over iptables when using the BPF-based NodePort. Otherwise, there is a risk for port collisions between BPF and iptables SNAT, which might result in dropped NodePort connections GitHub issue 23604.

The following presentations describe inner-workings of the kube-proxy replacement in eBPF in great details:

“Liberating Kubernetes from kube-proxy and iptables” (KubeCon North America 2019, slides, video)

“Kubernetes service load-balancing at scale with BPF & XDP” (Linux Plumbers 2020, slides, video)

“eBPF as a revolutionary technology for the container landscape” (Fosdem 2020, slides, video)

“Kernel improvements for Cilium socket LB” (LSF/MM/BPF 2020, slides)

---

## Bandwidth Manager — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/kubernetes/bandwidth-manager/

**Contents:**
- Bandwidth Manager
- BBR for Pods
- BBR for The Host
- Limitations

This guide explains how to configure Cilium’s bandwidth manager to optimize TCP and UDP workloads and efficiently rate limit individual Pods if needed through the help of EDT (Earliest Departure Time) and eBPF. Cilium’s bandwidth manager is also prerequisite for enabling BBR congestion control for Pods as outlined below.

The bandwidth manager does not rely on CNI chaining and is natively integrated into Cilium instead. Hence, it does not make use of the bandwidth CNI plugin. Due to scalability concerns in particular for multi-queue network interfaces, it is not recommended to use the bandwidth CNI plugin which is based on TBF (Token Bucket Filter) instead of EDT.

It is strongly recommended to use Bandwidth Manager in combination with BPF Host Routing as otherwise legacy routing through the upper stack could potentially result in undesired high latency (see this comparison for more details).

Cilium’s bandwidth manager supports both kubernetes.io/egress-bandwidth and kubernetes.io/ingress-bandwidth Pod annotations. The egress-bandwidth is enforced on egress at the native host networking devices using EDT (Earliest Departure Time), while the ingress-bandwidth is enforced using an eBPF-based token bucket implementation. The bandwidth enforcement is supported for direct routing as well as tunneling mode in Cilium.

Setup Helm repository:

Cilium’s bandwidth manager is disabled by default on new installations. To install Cilium with the bandwidth manager enabled, run

To enable the bandwidth manager on an existing installation, run

The native host networking devices are auto detected as native devices which have the default route on the host or have Kubernetes InternalIP or ExternalIP assigned. InternalIP is preferred over ExternalIP if both exist. To change and manually specify the devices, set their names in the devices helm option (e.g. devices='{eth0,eth1,eth2}'). Each listed device has to be named the same on all Cilium-managed nodes.

Verify that the Cilium Pods have come up correctly:

In order to verify whether the bandwidth manager feature has been enabled in Cilium, the cilium status CLI command provides visibility through the BandwidthManager info line. It also dumps a list of devices on which the egress bandwidth limitation is enforced:

To verify that bandwidth limits are indeed being enforced, one can deploy two netperf Pods in different nodes:

Once up and running, the netperf-client Pod can be used to test bandwidth enforcement on the netperf-server Pod. First test the egress bandwidth:

As can be seen, egress traffic of the netperf-server Pod has been limited to 10Mbit per second. Then test the ingress bandwidth.

As can be seen, ingress traffic of the netperf-server Pod has been limited to 20Mbit per second.

In order to introspect current endpoint bandwidth settings from BPF side, the following command can be run (replace cilium-xxxxx with the name of the Cilium Pod that is co-located with the netperf-server Pod):

Each Pod is represented in Cilium as an Endpoint which has an identity. The above identity can then be correlated with the cilium-dbg endpoint list command.

Bandwidth limits apply on a per-Pod scope. In our example, if multiple replicas of the Pod are created, then each of the Pod instances receives a 10M bandwidth limit.

The base infrastructure around MQ/FQ setup provided by Cilium’s bandwidth manager also allows for use of TCP BBR congestion control for Pods.

BBR is in particular suitable when Pods are exposed behind Kubernetes Services which face external clients from the Internet. BBR achieves higher bandwidths and lower latencies for Internet traffic, for example, it has been shown that BBR’s throughput can reach as much as 2,700x higher than today’s best loss-based congestion control and queueing delays can be 25x lower.

BBR for Pods requires a v5.18.x or more recent Linux kernel.

To enable the bandwidth manager with BBR congestion control, deploy with the following:

In order for BBR to work reliably for Pods, it requires a 5.18 or higher kernel. As outlined in our Linux Plumbers 2021 talk, this is needed since older kernels do not retain timestamps of network packets when switching from Pod to host network namespace. Due to the latter, the kernel’s pacing infrastructure does not function properly in general (not specific to Cilium).

We helped with fixing this issue for recent kernels to retain timestamps and therefore to get BBR for Pods working. Prior to that kernel, BBR was only working for sockets which are in the initial network namespace (hostns). BBR also needs eBPF Host-Routing in order to retain the network packet’s socket association all the way until the packet hits the FQ queueing discipline on the physical device in the host namespace. (Without eBPF Host-Routing the packet’s socket association would otherwise be orphaned inside the host stacks forwarding/routing layer.).

In order to verify whether the bandwidth manager with BBR has been enabled in Cilium, the cilium status CLI command provides visibility again through the BandwidthManager info line:

Once this setting is enabled, it will use BBR as a default for all newly spawned Pods. Ideally, BBR is selected upon initial Cilium installation when the cluster is created such that all nodes and Pods in the cluster homogeneously use BBR as otherwise there could be potential unfairness issues for other connections still using CUBIC. Also note that due to the nature of BBR’s probing you might observe a higher rate of TCP retransmissions compared to CUBIC.

We recommend to use BBR in particular for clusters where Pods are exposed as Services which serve external clients connecting from the Internet.

In legacy routing mode, it is not possible to enable BBR for Cilium-managed pods (hostNetwork: false) for the reasons mentioned above; however, it is possible to enable BBR for only the host network namespace by adding the bandwidthManager.bbrHostNamespaceOnly=true flag.

With bandwidthManager.bbrHostNamespaceOnly, processes in the host network namespace, including pods that set hostNetwork to true, will use BBR.

Bandwidth enforcement currently does not work in combination with L7 Cilium Network Policies. In case they select the Pod at egress, then the bandwidth enforcement will be disabled for those Pods.

Bandwidth enforcement doesn’t work with nested network namespace environments like Kind. This is because they typically don’t have access to the global sysctl under /proc/sys/net/core and the bandwidth enforcement depends on them.

For more insights on Cilium’s bandwidth manager, check out this KubeCon talk on Better Bandwidth Management with eBPF and eCHO episode 98: Exploring the bandwidth manager with Cilium.

---

## Using Kube-Router to Run BGP (deprecated) — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/kube-router/

**Contents:**
- Using Kube-Router to Run BGP (deprecated)
- Deploy kube-router
- Deploy Cilium
- Verify Installation
  - Validate the Installation

This guide explains how to configure Cilium and kube-router to co-operate to use kube-router for BGP peering and route propagation and Cilium for policy enforcement and load-balancing.

This is a beta feature. Please provide feedback and file a GitHub issue if you experience any problems.

Download the kube-router DaemonSet template:

Open the file generic-kuberouter-only-advertise-routes.yaml and edit the args: section. The following arguments are required to be set to exactly these values:

The following arguments are optional and may be set according to your needs. For the purpose of keeping this guide simple, the following values are being used which require the least preparations in your cluster. Please see the kube-router user guide for more information.

The following arguments are optional and should be set if you want BGP peering with an external router. This is useful if you want externally routable Kubernetes Pod and Service IPs. Note the values used here should be changed to whatever IPs and ASNs are configured on your external router.

Apply the DaemonSet file to deploy kube-router and verify it has come up correctly:

In order for routing to be delegated to kube-router, tunneling/encapsulation must be disabled. This is done by setting the routing-mode=native in the ConfigMap cilium-config or by adjusting the DaemonSet to run the cilium-agent with the argument --routing-mode=native. Moreover, in the same ConfigMap, we must explicitly set ipam: kubernetes since kube-router pulls the pod CIDRs directly from K8s:

You can then install Cilium according to the instructions in section Requirements.

Ensure that Cilium is up and running:

Verify that kube-router has installed routes:

In the above example, we see three categories of routes that have been installed:

Local PodCIDR: This route points to all pods running on the host and makes these pods available to * 10.2.0.0/24 via 10.2.0.172 dev cilium_host src 10.2.0.172

BGP route: This type of route is installed if kube-router determines that the remote PodCIDR can be reached via a router known to the local host. It will instruct pod to pod traffic to be forwarded directly to that router without requiring any encapsulation. * 10.2.1.0/24 via 172.0.51.175 dev eth0 proto 17

IPIP tunnel route: If no direct routing path exists, kube-router will fall back to using an overlay and establish an IPIP tunnel between the nodes. * 10.2.2.0/24 dev tun-172011760 proto 17 src 172.0.50.227 * 10.2.3.0/24 dev tun-1720186231 proto 17 src 172.0.50.227

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

## Service Mesh — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/

**Contents:**
- Service Mesh
- What is Service Mesh?
- Why Cilium Service Mesh?

With the introduction of distributed applications, additional visibility, connectivity, and security requirements have surfaced. Application components communicate over untrusted networks across cloud and premises boundaries, load-balancing is required to understand application protocols, resiliency is becoming crucial, and security must evolve to a model where sender and receiver can authenticate each other’s identity. In the early days of distributed applications, these requirements were resolved by directly embedding the required logic into the applications. A service mesh extracts these features out of the application and offers them as part of the infrastructure for all applications to use and thus no longer requires to change each application.

Looking at the feature set of a service mesh today, it can be summarized as follows:

Resilient Connectivity: Service to service communication must be possible across boundaries such as clouds, clusters, and premises. Communication must be resilient and fault tolerant.

L7 Traffic Management: Load balancing, rate limiting, and resiliency must be L7-aware (HTTP, REST, gRPC, WebSocket, …).

Identity-based Security: Relying on network identifiers to achieve security is no longer sufficient, both the sending and receiving services must be able to authenticate each other based on identities instead of a network identifier.

Observability & Tracing: Observability in the form of tracing and metrics is critical to understanding, monitoring, and troubleshooting application stability, performance, and availability.

Transparency: The functionality must be available to applications in a transparent manner, i.e. without requiring to change application code.

If you’d like a video explanation of Cilium’s Service Mesh implementation, check out eCHO episode 27: eBPF-enabled Service Mesh and eCHO episode 100: Next-gen mutual authentication in Cilium.

Since its early days, Cilium has been well aligned with the service mesh concept by operating at both the networking and the application protocol layer to provide connectivity, load-balancing, security, and observability. For all network processing including protocols such as IP, TCP, and UDP, Cilium uses eBPF as the highly efficient in-kernel datapath. Protocols at the application layer such as HTTP, Kafka, gRPC, and DNS are parsed using a proxy such as Envoy.

---

## TLS Migration — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/ingress-to-gateway/tls-migration/

**Contents:**
- TLS Migration
- Review Ingress Configuration
- Create Equivalent Gateway Configuration
- Review Equivalent Gateway Configuration

This migration example builds on the previous HTTP Migration Example and adds TLS termination for two HTTP routes. For simplicity, this example omits the second route to productpage.

You can find the example Ingress definition in tls-ingress.yaml.

listens for HTTPS traffic on port 443.

terminates TLS for the hipstershop.cilium.rocks and bookinfo.cilium.rocks hostnames using the TLS certificate and key from the Secret demo-cert.

routes HTTPS requests for the hipstershop.cilium.rocks hostname with the URI prefix /hipstershop.ProductCatalogService to the productcatalogservice Service.

routes HTTPS requests for the hipstershop.cilium.rocks hostname with the URI prefix /hipstershop.CurrencyService to the currencyservice Service.

routes HTTPS requests for the bookinfo.cilium.rocks hostname with the URI prefix /details to the details Service.

routes HTTPS requests for the bookinfo.cilium.rocks hostname with any other prefix to the productpage Service.

To create the equivalent TLS termination configuration, consider the following:

The Ingress resource supports TLS termination via the TLS section, where the TLS certificate and key are stored in a Kubernetes Secret.

In the Gateway API, TLS termination is a property of the Gateway listener, and similarly to the Ingress, a TLS certificate and key are also stored in a Secret.

Host-header-based Routing Rules

The Ingress API uses the term host. With Ingress, each host has separate routing rules.

The Gateway API uses the hostname term. The host-header-based routing rules map to the hostnames of the HTTPRoute. In the HTTPRoute, the routing rules apply to all hostnames.

The hostnames of an HTTPRoute must match the hostname of the Gateway listener. Otherwise, the listener will ignore the routing rules for the unmatched hostnames.

You can find the equivalent final Gateway and HTTPRoute definition in tls-migration.yaml.

Deploy the resources and verify that HTTPS requests are routed successfully to the services. For more information, consult the Gateway API HTTPS Example.

---

## Life of a Packet — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/ebpf/lifeofapacket/

**Contents:**
- Life of a Packet
- Endpoint to Endpoint
- Egress from Endpoint
- Ingress to Endpoint

This documentation page overviews the life of a packet from an eBPF datapath perspective by explaining three different scenarios.

You can also watch a video explanation of this topic that also explores the tools available within Cilium to help you understand the life of a packet in eCHO Episode 51: Life of a Packet with Cilium.

First we show the local endpoint to endpoint flow with optional L7 Policy on egress and ingress. Followed by the same endpoint to endpoint flow with socket layer enforcement enabled. With socket layer enforcement enabled for TCP traffic the handshake initiating the connection will traverse the endpoint policy object until TCP state is ESTABLISHED. Then after the connection is ESTABLISHED only the L7 Policy object is still required.

Next we show local endpoint to egress with optional overlay network. In the optional overlay network traffic is forwarded out the Linux network interface corresponding to the overlay. In the default case the overlay interface is named cilium_vxlan. Similar to above, when socket layer enforcement is enabled and a L7 proxy is in use we can avoid running the endpoint policy block between the endpoint and the L7 Policy for TCP traffic. An optional L3 encryption block will encrypt the packet if enabled.

Finally we show ingress to local endpoint also with optional overlay network. Similar to above socket layer enforcement can be used to avoid a set of policy traversals between the proxy and the endpoint socket. If the packet is encrypted upon receive it is first decrypted and then handled through the normal flow.

This completes the datapath overview. More BPF specifics can be found in the BPF and XDP Reference Guide. Additional details on how to extend the L7 Policy exist in the Envoy section.

---

## Technical Deep Dive — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/concepts/ipam/deep_dive/

**Contents:**
- Technical Deep Dive
- Cilium Container Networking Control Flow

The control flow diagram below gives an overview on how endpoints obtain their IP address from the IPAM for each different mode of Address Management that Cilium Supports.

---

## L7 Traffic Shifting — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/envoy-traffic-shifting/

**Contents:**
- L7 Traffic Shifting
- Deploy Test Applications
- Apply weight-based routing
- Cleaning up

Cilium Service Mesh defines a CiliumEnvoyConfig CRD which allows users to set the configuration of the Envoy component built into Cilium agents.

This example sets up an Envoy listener which load balances requests to the helloworld Service by sending 90% of incoming requests to the backend helloworld-v1 and 10% of incoming requests to the backend helloworld-v2.

The test workloads consist of:

One client Deployment, client

Two server Deployments, helloworld-v1 and helloworld-v2

View information about these Pods and the helloworld Service:

Make an environment variable with the Pod name for client:

Try making several requests to the helloworld Service.

The test results are as follows:

The test results were as expected. Of the requests sent to the helloworld service, 50% of them were sent to the backend helloworld-v1 and 50% of them were sent to the backend helloworld-v2.

CiliumEnvoyConfig can be used to load balance traffic destined to one Service to a group of backend Services. To load balance traffic to the helloworld Service, first create individual Services for each backend Deployment.

Apply the envoy-helloworld-v1-90-v2-10.yaml file, which defines a CiliumEnvoyConfig to send 90% of traffic to the helloworld-v1 Service backend and 10% of traffic to the helloworld-v2 Service backend:

View information about these Pods and Services:

Note that these Envoy resources are not validated by K8s at all, so any errors in the Envoy resources will only be seen by the Cilium Agent observing these CRDs. This means that kubectl apply will report success, while parsing and/or installing the resources for the node-local Envoy instance may have failed. Currently the only way of verifying this is by observing Cilium Agent logs for errors and warnings. Additionally, Cilium Agent will print warning logs for any conflicting Envoy resources in the cluster.

Note that Cilium Ingress Controller will configure required Envoy resource under the hood. Please check Cilium Agent logs if you are creating Envoy resources explicitly to make sure there is no conflict.

Try making several requests to the helloworld Service again.

The test results are as follows:

The test results were as expected. Of the requests sent to the helloworld service, 90% of them were sent to the backend helloworld-v1 and 10% of them were sent to the backend helloworld-v2.

Remove the test application.

---

## Multi-Cluster Services API (Beta) — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/clustermesh/mcsapi/

**Contents:**
- Multi-Cluster Services API (Beta)
- Prerequisites
  - Installing CoreDNS multicluster
- Exporting a Service
  - Deploying a Simple Example Service using MCS-API
- Gateway-API

This is a beta feature. Please provide feedback and file a GitHub issue if you experience any problems.

This tutorial will guide you to through the support of Multi-Cluster Services API (MCS-API) in Cilium.

You need to have a functioning Cluster Mesh setup, please follow the Setting up Cluster Mesh guide to set it up.

You first need to install the required MCS-API CRDs:

To install Cilium with MCS-API support, run:

To enable MCS-API support on an existing Cilium installation, run:

Also checkout the EndpointSlice synchronization feature if you need Headless Services support.

You also need to install and configure the multicluster CoreDNS plugin.

The multicluster CoreDNS plugin is currently not provided by default in CoreDNS so you will have to recompile it yourself.

To rebuild the CoreDNS image you need to first clone the CoreDNS repo:

Then you need add the multicluster plugin to the plugins.cfg file. The ordering of plugins matters, add it just below kubernetes plugin that has very similar functionality:

Then you can build your image simply by running make and then docker build . with the right docker tag and upload it to your preferred registry.

You also need to make sure that CoreDNS is able to read and watch the relevant MCS-API resources (ServiceImports). You can do so by running the following command on each cluster:

After that you will need to update the CoreDNS’s Corefile to also enable the multicluster plugin, for instance by executing the following command on each cluster:

And you can finally deploy the CoreDNS image you previously built. Doing so will also rollout the CoreDNS deployment and activate the Corefile change you previously made.

To export a service you should create a ServiceExport resource. As a result your Service will be exported to all clusters, provided that the Service Namespace is present on those clusters.

In all the clusters and for each set of exported Services that have the same name and namespace, a ServiceImport resource will be automatically created. All the Endpoints from those exported Services with the same name and namespace will be merged and made globally available.

An exported Service through MCS-API is available by default on the <svc>.<ns>.svc.clusterset.local domain. If you have defined any hostname (via a Statefulset for instance) on your pods each pods would also be available available through the <hostname>.<clustername>.<svc>.<ns>.svc.clusterset.local domain.

The <clustername>.<svc>.<ns>.svc.clusterset.local domain that would allow to get all the endpoints of a Service in a specific cluster is not allowed!

We recommend creating one service per cluster and/or region and exporting it accordingly if you do want to have this kind of behavior, for instance creating and exporting services mysvc-eu and mysvc-us instead of only one service. For more information checkout the dedicated section in the MCS-API KEP explaining this behavior.

The ServiceImport has also a logic to merge different Service properties:

Ports (Union of the different ServiceExports)

Type (ClusterSetIP/Headless)

Annotations & Labels (via the ServiceExport exportedLabels and exportedAnnotations fields)

If any conflict arises on any of these properties, the oldest ServiceExport will have precedence to resolve the conflict. This means that you should get a consistent behavior globally for the same set of exported Services that has the same name and namespace. If any conflicts arises, you would be able to see details about it in the ServiceExport status Conditions.

In cluster 1, deploy:

In cluster 2, deploy:

From either cluster, access the exported service:

You will see replies from pods in both clusters.

Gateway-API has optional support for MCS-API via GEP1748 by specifying a ServiceImport backend, for example:

The Gateway API implementation of Cilium fully support its own MCS-API implementation.

If you want to use another Gateway API implementation with the Cilium MCS-API implementation, the Gateway API implementation you are using should officially support MCS-API / GEP1748.

On the other hands, the Cilium Gateway API implementation only supports MCS-API implementations using an underlying Service associated with a ServiceImport, and with the annotation multicluster.kubernetes.io/derived-service on ServiceImport resources.

---

## Endpoint CRD — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/kubernetes/ciliumendpoint/

**Contents:**
- Endpoint CRD

When managing pods in Kubernetes, Cilium will create a Custom Resource Definition (CRD) of Kind CiliumEndpoint. One CiliumEndpoint is created for each pod managed by Cilium, with the same name and in the same namespace. The CiliumEndpoint objects contain the same information as the json output of cilium-dbg endpoint get under the .status field, but can be fetched for all pods in the cluster. Adding the -o json will export more information about each endpoint. This includes the endpoint’s labels, security identity and the policy in effect on it.

Each cilium-agent pod will create a CiliumEndpoint to represent its own inter-agent health-check endpoint. These are not pods in Kubernetes and are in the kube-system namespace. They are named as cilium-health-<node-name>

---

## Iptables Usage — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/ebpf/iptables/

**Contents:**
- Iptables Usage
- kube-proxy Interoperability

Depending on the Linux kernel version being used, the eBPF datapath can implement a varying feature set fully in eBPF. If certain required capabilities are not available, the functionality is provided using a legacy iptables implementation. See Requirements for IPsec for more details.

The following diagram shows the integration of iptables rules as installed by kube-proxy and the iptables rules as installed by Cilium.

---

## GKE-to-GKE Clustermesh Preparation — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/clustermesh/gke-clustermesh-prep/

**Contents:**
- GKE-to-GKE Clustermesh Preparation
- Create VPC
- Deploy clusters
- Peering VPC networks

This is a step-by-step guide on how to install and prepare Google Kubernetes Engine (GKE) clusters to meet the requirements for the clustermesh feature.

This guide describes how to deploy two zonal, single node GKE clusters in different regions for the express purpose of creating a cost-effective environment to deploy a clustermesh to. Ideal for development/learning purposes.

The steps below require the gcloud CLI tool

Create a VPC network in your GCP project. Environment variables are recommended as their values will be referenced in later steps.

Set additional environment variables for values that will be reused in later steps.

Below is an example to deploy one GKE cluster. To create more clusters, follow the steps again, using distinct cluster names, zones, pod CIDRs, and services CIDRs.

You can use different pod and services CIDRs than in the example, but make sure they meet the IP address range rules. But most importantly, make sure they do not overlap with the pods and services CIDRs in your other cluster(s).

The node taint is used to prevent pods from being deployed/started until Cilium has been installed.

Be sure to assign a unique cluster.id to each cluster.

Check the status of Cilium.

For each GKE cluster, save its context in an environment variable for use in the clustermesh setup process.

GKE cluster context is a combination of project ID, location, and cluster name.

Google Cloud’s VPCs are global in scope, so subnets within the same VPC can already communicate with each other internally – regardless of region. So there is no VPC peering required!

Node-to-node traffic between clusters is now possible. All requirements for clustermesh are met. Enabling clustermesh is explained in Setting up Cluster Mesh.

Please reference environment variables exported in step 4 for any commands that require the Kubernetes context.

---

## Integration with Istio — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/istio/

**Contents:**
- Integration with Istio
- Cilium Configuration
- Istio configuration
- Demo Application (Using Cilium with Istio ambient mode)
  - Prerequisites
- Demo Application (Istio sidecar mode)
  - Prerequisites

This page helps you get started using Istio with a Cilium-enabled Kubernetes cluster. This document covers the following common aspects of Cilium’s integration with Istio:

You can run Cilium with Istio in two ways:

With kube-proxy present (recommended):

Set kubeProxyReplacement: false (the default).

Cilium does not fully replace kube-proxy; kube-proxy continues to handle ClusterIP routing.

This is the recommended setup for using Istio with minimal disruption, particularly in sidecar or ambient mode.

With kube-proxy removed (full replacement):

Set kubeProxyReplacement: true, socketLB.hostNamespaceOnly: true, and cni.exclusive: false.

These settings prevent Cilium’s socket-based load balancing from interfering with Istio’s proxying.

kube-proxy can be removed in this mode, but these configurations are required to ensure compatibility.

In summary, you can run Istio with Cilium and kube-proxy by setting kubeProxyReplacement: false (the default and recommended for most Istio installs); or you can run without kube-proxy by setting kubeProxyReplacement: true, but you must carefully configure Cilium to avoid conflicts with Istio.

The main goal of Cilium configuration is to ensure that traffic redirected to Istio’s sidecar proxies (sidecar mode) or node proxy (ambient mode) is not disrupted. Disruptions can happen when you enable Cilium’s kubeProxyReplacement feature (see Kubernetes Without kube-proxy docs), which enables socket based load balancing inside a Pod.

To ensure that Cilium does not interfere with Istio, it is important to set the bpf-lb-sock-hostns-only parameter in the Cilium ConfigMap to true. This can be achieved by using the --set flag with the socketLB.hostNamespaceOnly Helm value set to true. You can confirm the result with the following command:

Istio uses a CNI plugin to implement functionality for both sidecar and ambient modes. To ensure that Cilium does not interfere with other CNI plugins on the node, it is important to set the cni-exclusive parameter in the Cilium ConfigMap to false. This can be achieved by using the --set flag with the cni.exclusive Helm value set to false. You can confirm the result with the following command:

When you deploy Cilium and Istio together, be aware of:

Either Cilium or Istio L7 HTTP policy controls can be used, but it is not recommended to use both Cilium and Istio L7 HTTP policy controls at the same time, to avoid split-brain problems.

In order to use Cilium L7 HTTP policy controls (for example, Layer 7 Examples) with Istio (sidecar or ambient modes), you must:

Sidecar: Disable Istio mTLS for the workloads you wish to manage with Cilium L7 policy by configuring mtls.mode=DISABLE under Istio’s PeerAuthentication.

Ambient: Remove the workloads you wish to manage with Cilium L7 policy from Istio ambient by removing either the istio.io/dataplane-mode label from the namespace, or annotating the pods you wish to manage with Cilium L7 with ambient.istio.io/redirection: disabled.

as otherwise the traffic between Istio-managed workloads will be encrypted by Istio with mTLS, and not accessible to Cilium for the purposes of L7 policy enforcement.

If using Istio L7 HTTP policy controls, policy will be managed in Istio and disabling mTLS between workloads is not required.

If using Istio mTLS in ambient mode with Istio L7 HTTP policy controls, traffic between ambient workloads will be encrypted and tunneled in and out of the pods by Istio over port 15008. In this scenario, Cilium NetworkPolicy will still apply to the encrypted and tunneled L4 traffic entering and leaving the Istio-managed pods, but Cilium will have no visibility into the actual source and destination of that tunneled and encrypted L4 traffic, or any L7 information. This means that Istio should be used to enforce policy for traffic between Istio-managed, mTLS-secured workloads at L4 or above. Traffic ingressing to Istio-managed workloads from non-Istio-managed workloads will continue to be fully subjected to Cilium-enforced Kubernetes NetworkPolicy, as it would not be tunneled or encrypted.

When using Istio in sidecar mode with automatic sidecar injection, together with Cilium overlay mode (VXLAN or GENEVE), istiod pods must be running with hostNetwork: true in order to be reachable by the API server.

The following guide demonstrates the interaction between Istio’s ambient mTLS mode and Cilium network policies when using Cilium L7 HTTP policy controls instead of Istio L7 HTTP policy controls, including the caveat described in the Istio configuration section.

Istio is already installed on the local Kubernetes cluster.

Cilium is already installed with the socketLB.hostNamespaceOnly and cni.exclusive=false Helm values.

Istio’s istioctl is installed on the local host.

Start by deploying a set of web servers and client applications across three different namespaces:

By default, Istio works in PERMISSIVE mode, allowing both Istio-ambient-managed and Istio-unmanaged pods to send and receive unsecured traffic between each other. You can test the connectivity between client and server applications deployed in the preceding example by entering the following commands:

All commands should complete successfully:

You can apply Cilium-enforced L4 NetworkPolicy to restrict communication between namespaces. The following command applies an L4 network policy that restricts communication in the blue namespace to clients located only in blue and red namespaces.

Re-run the same connectivity checks to confirm the expected result:

You can then decide to enhance the same network policy to perform additional HTTP-based checks. The following command applies a Cilium L7 network policy allowing communication only with the /ip URL path:

At this point, all communication with the blue namespace is broken since the Cilium proxy (HTTP) interferes with Istio’s mTLS-based HTTPS connections:

To solve the problem and allow Cilium to manage L7 policy, you must remove the workloads or namespaces you want Cilium to manage L7 policy for from the Istio ambient mesh:

Re-run a connectivity check to confirm that communication with the blue namespaces has been restored. You can verify that Cilium is enforcing the L7 network policy by accessing a different URL path, for example /deny:

The following guide demonstrates the interaction between Istio’s sidecar-based mTLS mode and Cilium network policies when using Cilium L7 HTTP policy controls instead of Istio L7 HTTP policy controls, including the caveat described in the Istio configuration section around disabling mTLS

Istio is already installed on the local Kubernetes cluster.

Cilium is already installed with the socketLB.hostNamespaceOnly and cni.exclusive=false Helm values.

Istio’s istioctl is installed on the local host.

Start by deploying a set of web servers and client applications across three different namespaces:

By default, Istio works in PERMISSIVE mode, allowing both Istio-managed and Pods without sidecars to send and receive traffic between each other. You can test the connectivity between client and server applications deployed in the preceding example by entering the following commands:

All commands should complete successfully:

You can apply network policies to restrict communication between namespaces. The following command applies a Cilium-managed L4 network policy that restricts communication in the blue namespace to clients located only in blue and red namespaces.

Re-run the same connectivity checks to confirm the expected result:

You can then decide to enhance the L4 network policy to perform additional Cilium-managed HTTP-based checks. The following command applies Cilium L7 network policy allowing communication only with the /ip URL path:

At this point, all communication with the blue namespace is broken since the Cilium proxy (HTTP) interferes with Istio’s mTLS-based HTTPs connections:

To solve the problem and allow Cilium to manage L7 policy, you must disable Istio’s mTLS authentication by configuring a new policy:

You must apply this policy to the same namespace where you implement the HTTP-based network policy:

Re-run a connectivity check to confirm that communication with the blue namespaces has been restored. You can verify that Cilium is enforcing the L7 network policy by accessing a different URL path, for example /deny:

---

## Multi-Pool (Beta) — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/concepts/ipam/multi-pool/

**Contents:**
- Multi-Pool (Beta)
- Architecture
- Configuration
  - Updating existing CiliumPodIPPools
  - Per-Node Default Pool
  - Allocation Parameters
  - Routing to Allocated PodCIDRs
- Limitations

This is a beta feature. Please provide feedback and file a GitHub issue if you experience any problems.

The Multi-Pool IPAM mode supports allocating PodCIDRs from multiple different IPAM pools, depending on workload annotations and node labels defined by the user.

When running in the Multi-Pool IPAM mode, Cilium will use the ipam.cilium.io/ip-pool annotation on pods and namespaces to determine the IPAM pool from which a pod’s IP is allocated from.

If there is an ipam.cilium.io/ip-pool=A annotation on the pod itself, Cilium will allocate the pod’s IP from the pool named A.

If there is no annotation on the pod, but the namespace of the pod has an ipam.cilium.io/ip-pool=B annotation, Cilium will allocate the pod’s IP from the pool named B.

If neither the pod nor the namespace have a ipam.cilium.io/ip-pool annotation, the pod’s IP will be allocated from the pool named default.

The annotation is only considered when a pod is created. Changing the ip-pool annotation on an already running pod has no effect.

The CiliumNode resource is extended with an additional spec.ipam.pools section:

List of IPAM pool requests for this node. Each entry specifies the pool and the number of requested IP addresses. This field is owned and written to by the Cilium agent running on the particular node. It is read by the Cilium operator to fulfill the requests.

List of CIDRs allocated to this node and the pool they were allocated from. Cilium operator adds new PodCIDRs to this field. Cilium agent removes PodCIDRs it has released and is no longer using.

IP pools are managed using the cluster-wide CiliumPodIPPool custom resource. Each CiliumPodIPPool contains the cluster-wide CIDR from which per-node PodCIDRs are allocated:

New pools can be added at run-time. The list of CIDRs in each pool can also be extended at run-time. In-use CIDRs may not be removed from an existing pool, and existing pools may not be deleted if they are still in use by a Cilium node. The mask size of a pool is immutable and the same for all nodes. Neither restriction is enforced until GitHub issue 26966 is resolved. The first and last address of a CiliumPodIPPool are reserved and cannot be allocated. Pools with less than 3 addresses (/31, /32, /127, /128) do not have this limitation.

Multi-Pool IPAM can be enabled using the ipam.mode=multi-pool Helm value. To have the Cilium operator automatically create CiliumPodIPPools custom resources at startup, use the ipam.operator.autoCreateCiliumPodIPPools Helm value. It contains a map which follows the CiliumPodIPPools CRD schema described above.

For a practical tutorial on how to enable this mode in Cilium, see CRD-Backed by Cilium Multi-Pool IPAM (Beta).

Once you configure the CiliumPodIPPools, you cannot update the existing pool. For example, you can’t change the default pool to a different CIDR or add an IPv6 CIDR to the default pool. This restriction prevents pods from receiving IPs from a new range while some pods still use the old IP pool on the same nodes. If you need to update the existing CiliumPodIPPools, Please use these steps as the references.

Let’s assume you have a Kubernetes cluster and are using the multi-pool as the IPAM mode. You would like to change the existing default pool CIDR to something else and pods will take the IP address from the new CIDR. You hope the change will cause the least disruption to your clusters while updating the default pool to another CIDR.

We will pick some of your nodes where you would like to update the CIDR first and call them Node Group 1. The other nodes, which will update the CIDR later than Node Group 1, will be called Node Group 2.

Update your existing pool through autoCreateCiliumPodIPPools in helm values.

Delete the existing CiliumPodIPPools from CR and restart the Cilium operator to create new CiliumPodIPPools.

Cordon the Node Group 1 and evict pods to the Node Group 2.

Delete CiliumNodes for Node Group 1, restart the Cilium agents and uncordon for Node Group 1.

Cordon Node Group 2, and evict pods to Node Group 1 so they can get IPs from the new CIDR from the pool.

Delete CiliumNodes for Node Group 2, restart the Cilium agents and uncordon for Node Group 2.

(Optional) Reschedule pods to ensure workload is evenly distributed across nodes in cluster.

Cilium can allocate specific IP pools to nodes based on their labels. This feature is particularly useful in multi-datacenter environments where different nodes require IP ranges that align with their respective datacenter’s subnets. For instance, nodes in DC1 might use the range 10.1.0.0/16, while nodes in DC2 might use the range 10.2.0.0/16.

In particular, it is possible to set a per-node default pool by setting the ipam-default-ip-pool in a CiliumNodeConfig resource on nodes matching certain node labels.

Cilium agent can be configured to pre-allocate IPs from each pool. This behavior can be controlled using the ipam-multi-pool-pre-allocation flag. It contains a key-value map of the form <pool-name>=<preAllocIPs> where preAllocIPs specifies how many IPs are to be pre-allocated to the local node. The same number of IPs are pre-allocated for each address family. This means that a pool which contains both IPv4 and IPv6 CIDRs will pre-allocate preAllocIPs IPv4 addresses and preAllocIPs IPv6 addresses.

The flag defaults to default=8, which means it will pre-allocate 8 IPs from the default pool. All other pools which do not have an entry in the ipam-multi-pool-pre-allocation map are assumed to have a preAllocIPs of zero, i.e. no IPs are pre-allocated for that pool.

Depending on the number of in-use IPs and the number of pending IP allocation requests, Cilium agent might pre-allocate more than preAllocIPs IPs. The formula Cilium agent uses to compute the absolute number of needed IPs from each pool is:

Where inUseIPs is the number of IPs that are currently in use, pendingIPs number of IPs that have a pending pod (i.e. pods which have been scheduled on the node, but not yet received an IP), and preAllocIPs is the minimum number of IPs that we want to pre-allocate as a buffer, i.e. the value taken from the ipam-multi-pool-pre-allocation map.

PodCIDRs allocated from CiliumPodIPPools can be announced to the network by the Cilium BGP Control Plane (MultiPool IPAM). Alternatively, the autoDirectNodeRoutes Helm option can be used to enable automatic routing between nodes on a L2 network.

Multi-Pool IPAM is a preview feature. The following limitations apply to Cilium running in Multi-Pool IPAM mode:

IPsec is not supported in native routing mode. IPsec in tunnel mode and WireGuard (both in native routing and tunnel mode) are supported.

IPAM pools with overlapping CIDRs are not supported. Each pod IP must be unique in the cluster due the way Cilium determines the security identity of endpoints by way of the IPCache.

iptables-based masquerading requires egressMasqueradeInterfaces to be set (see masquerading Implementation Modes and GitHub issue 22273 for details). Alternatively, eBPF-based masquerading is fully supported and may be used instead. Note that if the used IPAM pools do not belong to a common native-routing CIDR, you may want to use ip-masq-agent, which allows multiple disjunct non-masquerading CIDRs to be defined. See Masquerading for details on how to use the ip-masq-agent feature.

---

## Azure IPAM — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/concepts/ipam/azure/

**Contents:**
- Azure IPAM
- Architecture
- Configuration
  - Azure Allocation Parameters
- Operational Details
  - Cache of Interfaces, Subnets, and VirtualNetworks
  - Publication of available IPs
  - Determination of IP deficits or excess
  - IP Allocation
  - IP Release

While still maintained for now, Azure IPAM is considered legacy and is not compatible with AKS clusters created in Bring your own CNI mode. The recommended way to install cilium on AKS are Bring your own CNI or Azure CNI Powered by Cilium.

The Azure IPAM allocator is specific to Cilium deployments running in the Azure cloud and performs IP allocation based on Azure Private IP addresses.

The architecture ensures that only a single operator communicates with the Azure API to avoid rate-limiting issues in large clusters. A pre-allocation watermark allows to maintain a number of IP addresses to be available for use on nodes at all time without requiring to contact the Azure API when a new pod is scheduled in the cluster.

The Azure IPAM allocator builds on top of the CRD-backed allocator. Each node creates a ciliumnodes.cilium.io custom resource matching the node name when Cilium starts up for the first time on that node. The Cilium agent running on each node will retrieve the Kubernetes v1.Node resource and extract the .Spec.ProviderID field in order to derive the Azure instance ID. Azure allocation parameters are provided as agent configuration option and are passed into the custom resource as well.

The Cilium operator listens for new ciliumnodes.cilium.io custom resources and starts managing the IPAM aspect automatically. It scans the Azure instances for existing interfaces with associated IPs and makes them available via the spec.ipam.available field. It will then constantly monitor the used IP addresses in the status.ipam.used field and allocate more IPs as needed to meet the IP pre-allocation watermark. This ensures that there are always IPs available

The Cilium agent and operator must be run with the option --ipam=azure or the option ipam: azure must be set in the ConfigMap. This will enable Azure IPAM allocation in both the node agent and operator.

In most scenarios, it makes sense to automatically create the ciliumnodes.cilium.io custom resource when the agent starts up on a node for the first time. To enable this, specify the option --auto-create-cilium-node-resource or set auto-create-cilium-node-resource: "true" in the ConfigMap.

It is generally a good idea to enable metrics in the Operator as well with the option --enable-metrics. See the section Running Prometheus & Grafana for additional information how to install and run Prometheus including the Grafana dashboard.

The following parameters are available to control the IP allocation:

The minimum number of IPs that must be allocated when the node is first bootstrapped. It defines the minimum base socket of addresses that must be available. After reaching this watermark, the PreAllocate and MaxAboveWatermark logic takes over to continue allocating IPs.

If unspecified, no minimum number of IPs is required.

The number of IP addresses that must be available for allocation at all times. It defines the buffer of addresses available immediately without requiring for the operator to get involved.

If unspecified, this value defaults to 8.

The maximum number of addresses to allocate beyond the addresses needed to reach the PreAllocate watermark. Going above the watermark can help reduce the number of API calls to allocate IPs.

If let unspecified, the value defaults to 0.

The operator maintains a list of all Azure ScaleSets, Instances, Interfaces, VirtualNetworks, and Subnets associated with the Azure subscription in a cache.

The cache is updated once per minute or after an IP allocation has been performed. When triggered based on an allocation, the operation is performed at most once per second.

Following the update of the cache, all CiliumNode custom resources representing nodes are updated to publish eventual new IPs that have become available.

In this process, all interfaces are scanned for all available IPs. All IPs found are added to spec.ipam.available. Each interface is also added to status.azure.interfaces.

If this update caused the custom resource to change, the custom resource is updated using the Kubernetes API methods Update() and/or UpdateStatus() if available.

The operator constantly monitors all nodes and detects deficits in available IP addresses. The check to recognize a deficit is performed on two occasions:

When a CiliumNode custom resource is updated

All nodes are scanned in a regular interval (once per minute)

When determining whether a node has a deficit in IP addresses, the following calculation is performed:

For excess IP calculation:

Upon detection of a deficit, the node is added to the list of nodes which require IP address allocation. When a deficit is detected using the interval based scan, the allocation order of nodes is determined based on the severity of the deficit, i.e. the node with the biggest deficit will be at the front of the allocation queue. Nodes that need to release IPs are behind nodes that need allocation.

The allocation queue is handled on demand but at most once per second.

When performing IP allocation for a node with an address deficit, the operator first looks at the interfaces already attached to the instance represented by the CiliumNode resource.

The operator will then pick the first interface which meets the following criteria:

The interface has addresses associated which are not yet used or the number of addresses associated with the interface is lesser than maximum number of addresses that can be associated to an interface.

The subnet associated with the interface has IPs available for allocation

The following formula is used to determine how many IPs are allocated on the interface:

This means that the number of IPs allocated in a single allocation cycle can be less than what is required to fulfill spec.ipam.pre-allocate.

When performing IP release for a node with IP excess, the operator scans the interface attached to the node. The following formula is used to determine how many IPs are available for release on the interface:

When a node or instance terminates, the Kubernetes apiserver will send a node deletion event. This event will be picked up by the operator and the operator will delete the corresponding ciliumnodes.cilium.io custom resource.

The following Azure API calls are being performed by the Cilium operator. The Service Principal provided must have privileges to perform these within the scope of the AKS cluster node resource group:

Network Interfaces - Create Or Update

NetworkInterface In VMSS - List Virtual Machine Scale Set Network Interfaces

Virtual Networks - List

Virtual Machine Scale Sets - List All

The node resource group is not the resource group of the AKS cluster. A single resource group may hold multiple AKS clusters, but each AKS cluster regroups all resources in an automatically managed secondary resource group. See Why are two resource groups created with AKS? for more details.

The metrics are documented in the section IPAM.

---

## Proxy Injection — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/network/proxy/

**Contents:**
- Proxy Injection

Cilium is capable of transparently injecting a Layer 4 proxy into any network connection. This is used as the foundation to enforce higher level network policies (see DNS based and Layer 7 Examples).

The following proxies can be injected:

---

## Overview of Network Policy — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/policy/

**Contents:**
- Overview of Network Policy

This page documents the policy language used to configure network policies in Cilium. Security policies can be specified and imported via the following mechanisms:

Using Kubernetes NetworkPolicy, CiliumNetworkPolicy and CiliumClusterwideNetworkPolicy resources. See the section Network Policy for more details. In this mode, Kubernetes will automatically distribute the policies to all agents.

Directly imported into the agent via CLI or API Reference of the agent. This method does not automatically distribute policies to all agents. It is in the responsibility of the user to import the policy in all required agents. (This method is deprecated as of v1.18 and will be removed in v1.19.)

---

## Mutual Authentication (Beta) — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/mutual-authentication/mutual-authentication/

**Contents:**
- Mutual Authentication (Beta)
- Mutual Authentication and mTLS Background
- Mutual Authentication in Cilium
- Identity Management
  - SPIFFE benefits
  - Cilium and SPIFFE
- Prerequisites
- Installation
- Examples
- Limitations

This is a beta feature. Please provide feedback and file a GitHub issue if you experience any problems.

This feature is still incomplete, see Detailed Roadmap Status below for more details.

Mutual Transport Layer Security (mTLS) is a mechanism that ensures the authenticity, integrity, and confidentiality of data exchanged between two entities over a network.

Unlike traditional TLS, which involves a one-way authentication process where the client verifies the server’s identity, mutual TLS adds an additional layer of security by requiring both the client and the server to authenticate each other.

Mutual TLS aims at providing authentication, confidentiality and integrity to service-to-service communications.

Cilium’s mTLS-based Mutual Authentication support brings the mutual authentication handshake out-of-band for regular connections.

For Cilium to meet most of the common requirements for service-to-service authentication and encryption, users must enable encryption.

Cilium’s encryption features, WireGuard Transparent Encryption and IPsec Transparent Encryption, can be enabled to automatically create and maintain encrypted connections between Pods.

To address the challenge of identity verification in dynamic and heterogeneous environments, mutual authentication requires a framework secure identity verification for distributed systems.

To learn more about the Mutual Authentication architecture for the Cilium Service Mesh, read the CFP.

In Cilium’s current mutual authentication support, identity management is provided through the use of SPIFFE (Secure Production Identity Framework for Everyone).

Here are some of the benefits provided by SPIFFE :

Trustworthy identity issuance: SPIFFE provides a standardized mechanism for issuing and managing identities. It ensures that each service in a distributed system receives a unique and verifiable identity, even in dynamic environments where services may scale up or down frequently.

Identity attestation: SPIFFE allows services to prove their identities through attestation. It ensures that services can demonstrate their authenticity and integrity by providing verifiable evidence about their identity, like digital signatures or cryptographic proofs.

Dynamic and scalable environments: SPIFFE addresses the challenges of identity management in dynamic environments. It supports automatic identity issuance, rotation, and revocation, which are critical in cloud-native architectures where services may be constantly deployed, updated, or retired.

SPIFFE provides an API model that allows workloads to request an identity from a central server. In our case, a workload means the same thing that a Cilium Security Identity does - a set of pods described by a label set. A SPIFFE identity is a subclass of URI, and looks something like this: spiffe://trust.domain/path/with/encoded/info.

There are two main parts of a SPIFFE setup:

A central SPIRE server, which forms the root of trust for the trust domain.

A per-node SPIRE agent, which first gets its own identity from the SPIRE server, then validates the identity requests of workloads running on its node.

When a workload wants to get its identity, usually at startup, it connects to the local SPIRE agent using the SPIFFE workload API, and describes itself to the agent.

The SPIRE agent then checks that the workload is really who it says it is, and then connects to the SPIRE server and attests that the workload is requesting an identity, and that the request is valid.

The SPIRE agent checks a number of things about the workload, that the pod is actually running on the node it’s coming from, that the labels match, and so on.

Once the SPIRE agent has requested an identity from the SPIRE server, it passes it back to the workload in the SVID (SPIFFE Verified Identity Document) format. This document includes a TLS keypair in the X.509 version.

In the usual flow for SPIRE, the workload requests its own information from the SPIRE server. In Cilium’s support for SPIFFE, the Cilium agents get a common SPIFFE identity and can themselves ask for identities on behalf of other workloads.

This is demonstrated in the following example.

Mutual authentication is only currently supported with SPIFFE APIs for certificate management.

The Cilium Helm chart includes an option to deploy a SPIRE server for mutual authentication. You may also deploy your own SPIRE server and configure Cilium to use it.

The default installation requires PersistentVolumeClaim support in the cluster, so please check with your cluster provider if it’s supported or how to enable it.

For lab or local cluster, you can switch to in-memory storage by passing authentication.mutual.spire.install.server.dataStorage.enabled=false to the installation command, at the cost of re-creating all data when the SPIRE server pod is restarted.

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

You can enable mutual authentication and its associated SPIRE server with the following command. This command requires the Cilium CLI Helm mode version 0.15 or later.

Next, you can check the status of the Cilium agent and operator:

The Cilium Helm chart includes an option to deploy SPIRE server for mutual authentication. You may also deploy your own SPIRE server and configure Cilium to use it. Please refer to Installation using Helm for a fresh installation.

Next, you can check the status of the Cilium agent and operator:

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

Please refer to the following example on how to use and leverage the mutual authentication feature:

If you’d like a video explanation and demo of Mutual Authentication in Cilium, check out eCHO episode 100: Next-gen mutual authentication in Cilium.

Cilium Mutual Authentication is still in development and considered beta. Several planned security features have not been implemented yet, see below for details.

Cilium’s Mutual authentication has only been validated with SPIRE, the production-ready implementation of SPIFFE. As Cilium uses SPIFFE APIs, it’s possible that other SPIFFE implementations may work. However, Cilium is currently only tested with the supplied SPIRE install, and using any other SPIFFE implementation is currently not supported.

There is no current option to build a single trust domain across multiple clusters for combining Cluster Mesh and Service Mesh. Therefore clusters connected in a Cluster Mesh are not currently compatible with Mutual Authentication.

The current support of mutual authentication only works within a Cilium-managed cluster and is not compatible with an external mTLS solution.

The following table shows the roadmap status of the mutual authentication feature. There are several work items outstanding before the feature is complete from a security model perspective. For details, see the [roadmap issue](https://github.com/cilium/cilium/issues/28986).

SPIFFE/SPIRE Integration

Authentication API for agent

mTLS handshake between agents

Auth cache to enable per-identity handshake

CiliumNetworkPolicy support

Integrate with WireGuard

Per-connection handshake

Sync ipcache with auth data

Detailed documentation of security model

Conduct penetration test of model

Minimize packet drops

Use auth secret for network encryption

Review maturity and consider for stable

---

## Network Policy — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/kubernetes/policy/

**Contents:**
- Network Policy
- NetworkPolicy
- CiliumNetworkPolicy
- Examples
- CiliumClusterwideNetworkPolicy

If you are running Cilium on Kubernetes, you can benefit from Kubernetes distributing policies for you. In this mode, Kubernetes is responsible for distributing the policies across all nodes and Cilium will automatically apply the policies. Three formats are available to configure network policies natively with Kubernetes:

The standard NetworkPolicy resource which supports L3 and L4 policies at ingress or egress of the Pod.

The extended CiliumNetworkPolicy format which is available as a CustomResourceDefinition which supports specification of policies at Layers 3-7 for both ingress and egress.

The CiliumClusterwideNetworkPolicy format which is a cluster-scoped CustomResourceDefinition for specifying cluster-wide policies to be enforced by Cilium. The specification is same as that of CiliumNetworkPolicy with no specified namespace.

Cilium supports running multiple of these policy types at the same time. However caution should be applied when using multiple policy types at the same time, as it can be confusing to understand the complete set of allowed traffic across multiple policy types. If close attention is not applied this may lead to unintended policy allow behavior.

For more information, see the official NetworkPolicy documentation.

Known missing features for Kubernetes Network Policy:

ipBlock set with a pod IP

The CiliumNetworkPolicy is very similar to the standard NetworkPolicy. The purpose is to provide the functionality which is not yet supported in NetworkPolicy. Ideally all of the functionality will be merged into the standard resource format and this CRD will no longer be required.

The raw specification of the resource in Go looks like this:

Describes the policy. This includes:

Name of the policy, unique within a namespace

Namespace of where the policy has been injected into

Set of labels to identify a resource in Kubernetes

Field which contains a Rule Basics.

Field which contains a list of Rule Basics. This field is useful if multiple rules must be removed or added automatically.

Provides visibility into whether the policy has been successfully applied.

See Layer 3 Examples, Layer 4 Examples and Layer 7 Examples for detailed lists of example policies.

CiliumClusterwideNetworkPolicy is similar to CiliumNetworkPolicy, except (1) policies defined by CiliumClusterwideNetworkPolicy are non-namespaced and are cluster-scoped, and (2) it enables the use of Node Selector. Internally the policy is identical to CiliumNetworkPolicy and thus the effects of this policy specification are also same.

The raw specification of the resource in Go looks like this:

---

## Ingress Path Types Example — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/path-types/

**Contents:**
- Ingress Path Types Example
- Deploy the example app
- Review the Ingress
- Check that the Ingress has provisioned correctly
- Check that paths perform as expected
- Clean up the example

This example walks through how various path types interact and allows you to test that Cilium is working as it should.

This example requires that Cilium Ingress is enabled, and kubectl and jq must be installed.

This deploys five copies of the ingress-conformance-echo tool, that will allow us to see what paths are forwarded to what backends.

Here is the Ingress used:

You can see here that there are five matches, one for each of our deployments.

The Ingress deliberately has the rules in a different order to what they will be configured in Envoy.

For Exact matches, we only match /exact and send that to the exactpath Service.

For Prefix matches, we match /, send that to the prefixpath Service, and match /prefix and send that to the prefixpath2 Service.

For ImplementationSpecific matches, we match /impl.+ (a full regex), and send that to the implpath2 Service. We also match /impl (without regex characters) and send that to the implpath Service.

The intent here is to allow us to tell which rule we have matched by consulting the echoed response from the ingress-conformance-echo containers.

Firstly, we need to check that the Ingress has been provisioned correctly.

Here you can see that the Ingress has been provisioned correctly and is responding to requests. Also, you can see that the / path has been served by the prefixpath deployment, which is as expected from the Ingress.

The following example uses jq to extract the first element out of the pod field, which is the name of the associated deployment. So, prefixpath-7cb697f5cd-wvv7b will return prefixpath.

(You can use the “Copy Commands” button above to do less copy-and-paste.)

The most interesting example here is the last one, where we send /implementation to the implpath2 Service, while /impl goes to implpath. This is because /implementation matches the /impl.+ regex, and /impl matches the /impl regex.

If we now patch the Ingress object to use the regex /impl.* instead (note the *, which matches zero or more characters of the type instead of the previous +, which matches one or more characters), then we will get a different result for the last two checks:

The request to /impl now matches the longer pattern /impl.*.

The moral here is to be careful with your regular expressions!

Finally, we clean up our example:

---

## CRD-Backed by Cilium Cluster-Pool IPAM — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/kubernetes/ipam-cluster-pool/

**Contents:**
- CRD-Backed by Cilium Cluster-Pool IPAM
- Enable Cluster-pool IPAM mode
- Validate installation

This is a quick tutorial walking through how to enable CRD-backed by Cilium cluster-pool IPAM. The purpose of this tutorial is to show how components are configured and resources interact with each other to enable users to automate or extend on their own.

For more details, see the section Cluster Scope (Default)

Setup Cilium for Kubernetes using helm with the options: --set ipam.mode=cluster-pool.

Depending if you are using IPv4 and / or IPv6, you might want to adjust the podCIDR allocated for your cluster’s pods with the options:

--set ipam.operator.clusterPoolIPv4PodCIDRList=<IPv4CIDR>

--set ipam.operator.clusterPoolIPv6PodCIDRList=<IPv6CIDR>

To adjust the CIDR size that should be allocated for each node you can use the following options:

--set ipam.operator.clusterPoolIPv4MaskSize=<IPv4MaskSize>

--set ipam.operator.clusterPoolIPv6MaskSize=<IPv6MaskSize>

Deploy Cilium and Cilium-Operator. Cilium will automatically wait until the podCIDR is allocated for its node by Cilium Operator.

Validate that Cilium has started up correctly

Validate the spec.ipam.podCIDRs section:

---

## Policy Enforcement — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/network/policyenforcement/

**Contents:**
- Policy Enforcement
- Default Security Policy

All security policies are described assuming stateful policy enforcement for session based protocols. This means that the intent of the policy is to describe allowed direction of connection establishment. If the policy allows A => B then reply packets from B to A are automatically allowed as well. However, B is not automatically allowed to initiate connections to A. If that outcome is desired, then both directions must be explicitly allowed.

Security policies may be enforced at ingress or egress. For ingress, this means that each cluster node verifies all incoming packets and determines whether the packet is allowed to be transmitted to the intended endpoint. Correspondingly, for egress each cluster node verifies outgoing packets and determines whether the packet is allowed to be transmitted to its intended destination.

In order to enforce identity based security in a multi host cluster, the identity of the transmitting endpoint is embedded into every network packet that is transmitted in between cluster nodes. The receiving cluster node can then extract the identity and verify whether a particular identity is allowed to communicate with any of the local endpoints.

If no policy is loaded, the default behavior is to allow all communication unless policy enforcement has been explicitly enabled. As soon as the first policy rule is loaded, policy enforcement is enabled automatically and any communication must then be white listed or the relevant packets will be dropped.

Similarly, if an endpoint is not subject to an L4 policy, communication from and to all ports is permitted. Associating at least one L4 policy to an endpoint will block all connectivity to ports unless explicitly allowed.

---

## Kubernetes Compatibility — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/kubernetes/compatibility/

**Contents:**
- Kubernetes Compatibility
- Cilium CRD schema validation

Cilium is compatible with multiple Kubernetes API Groups. Some are deprecated or beta, and may only be available in specific versions of Kubernetes.

All Kubernetes versions listed are e2e tested and guaranteed to be compatible with Cilium. Older and newer Kubernetes versions, while not listed, will depend on the forward / backward compatibility offered by Kubernetes.

k8s NetworkPolicy API

1.30, 1.31, 1.32, 1.33

cilium.io/v2 has a CustomResourceDefinition

As a general rule, Cilium aims to run e2e tests using the latest build from the development branch against currently supported Kubernetes versions defined in Kubernetes Patch Releases page.

Once a release branch gets created from the development branch, Cilium typically does not change the Kubernetes versions it uses to run e2e tests for the entire maintenance period of that particular release.

Additionally, Cilium runs e2e tests against various cloud providers’ managed Kubernetes offerings using multiple Kubernetes versions. See the following links for the current test matrix for each cloud provider:

Cilium uses a CRD for its Network Policies in Kubernetes. This CRD might have changes in its schema validation, which allows it to verify the correctness of a Cilium Clusterwide Network Policy (CCNP) or a Cilium Network Policy (CNP).

The CRD itself has an annotation, io.cilium.k8s.crd.schema.version, with the schema definition version. By default, Cilium automatically updates the CRD, and its validation, with a newer one.

The following table lists all Cilium versions and their expected schema validation version:

CNP and CCNP Schema Version

---

## L7 Circuit Breaking — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/envoy-circuit-breaker/

**Contents:**
- L7 Circuit Breaking
- Deploy Test Applications
- Configuring Envoy Circuit Breaker
- Tripping Envoy Circuit Breaker
- Cleaning up

Cilium Service Mesh defines a CiliumClusterwideEnvoyConfig CRD which allows users to set the configuration of the Envoy component built into Cilium agents.

Circuit breaking is an important pattern for creating resilient microservice applications. Circuit breaking allows you to write applications that limit the impact of failures, latency spikes, and other undesirable effects of network peculiarities.

You will configure Circuit breaking rules with CiliumClusterwideEnvoyConfig and then test the configuration by intentionally “tripping” the circuit breaker in this example.

The test workloads consist of:

One client Deployment, fortio-deploy

One Service, echo-service

View information about these Pods:

Apply the envoy-circuit-breaker.yaml file, which defines a CiliumClusterwideEnvoyConfig.

Note that these Envoy resources are not validated by K8s at all, so any errors in the Envoy resources will only be seen by the Cilium Agent observing these CRDs. This means that kubectl apply will report success, while parsing and/or installing the resources for the node-local Envoy instance may have failed. Currently the only way of verifying this is by observing Cilium Agent logs for errors and warnings. Additionally, Cilium Agent will print warning logs for any conflicting Envoy resources in the cluster.

Note that Cilium Ingress Controller will configure required Envoy resource under the hood. Please check Cilium Agent logs if you are creating Envoy resources explicitly to make sure there is no conflict.

Verify the CiliumClusterwideEnvoyConfig was created correctly.

In the CiliumClusterwideEnvoyConfig settings, you specified max_pending_requests: 1 and max_requests: 2. These rules indicate that if you exceed more than one connection and request concurrently, you will see some failures when the envoy opens the circuit for further requests and connections.

Make an environment variable with the Pod name for fortio:

Use the following command to call the Service with two concurrent connections using the -c 2 flag and send 20 requests using -n 20 flag:

From the above output, you can see that the response code of some requests is 503, which triggers a circuit breaker.

Bring the number of concurrent connections up to 4.

Now you can start to see the expected Circuit breaking behavior. Only 35% of the requests succeeded and the rest were trapped by Circuit breaking.

Remove the test application.

---

## Ingress Example with TLS Termination — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/tls-termination/

**Contents:**
- Ingress Example with TLS Termination
- Create TLS Certificate and Private Key
- Deploy the Ingress
- Make HTTPS Requests

This example builds on the HTTP and gRPC ingress examples, adding TLS termination.

For demonstration purposes we will use a TLS certificate signed by a made-up, self-signed certificate authority (CA). One easy way to do this is with mkcert. We want a certificate that will validate bookinfo.cilium.rocks and hipstershop.cilium.rocks, as these are the host names used in this example.

Create a Kubernetes secret with this demo key and certificate:

Let us install cert-manager:

Now, create a CA Issuer:

The Ingress configuration for this demo provides the same routing as those demos but with the addition of TLS termination.

To tell cert-manager that this Ingress needs a certificate, annotate the Ingress with the name of the CA issuer we previously created:

This creates a Certificate object along with a Secret containing the TLS certificate.

External IP address will be shown up in Ingress

In this Ingress configuration, the host names hipstershop.cilium.rocks and bookinfo.cilium.rocks are specified in the path routing rules. The client needs to specify which host it wants to access. This can be achieved by editing your local /etc/hosts` file. (You will almost certainly need to be superuser to edit this file.) Add entries using the IP address assigned to the ingress service, so your file looks something like this:

By specifying the CA’s certificate on a curl request, you can say that you trust certificates signed by that CA.

If you prefer, instead of supplying the CA you can specify -k to tell the curl client not to validate the server’s certificate. Without either, you will get an error that the certificate was signed by an unknown authority.

Specifying -v on the curl request, you can see that the TLS handshake took place successfully.

Similarly you can specify the CA on a gRPC request like this:

Similarly you can specify the CA on a gRPC request like this:

See the gRPC Ingress example if you don’t already have the demo.proto file downloaded.

You can also visit https://bookinfo.cilium.rocks in your browser. The browser might warn you that the certificate authority is unknown but if you proceed past this, you should see the bookstore application home page.

Note that requests will time out if you don’t specify https://.

---

## Use a Specific MAC Address for a Pod — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/pod-mac-address/

**Contents:**
- Use a Specific MAC Address for a Pod
- Configuring the address

Some applications bind software licenses to network interface MAC addresses. Cilium provides the ability to specific MAC addresses for pods at deploy time instead of letting the operating system allocate them.

Cilium will configure the MAC address for the primary interface inside a Pod if you specify the MAC address in the cni.cilium.io/mac-address annotation before deploying the Pod. This MAC address is isolated to the container so it will not collide with any other MAC addresses assigned to other Pods on the same node. The MAC address must be specified before deploying the Pod.

Annotate the pod with cni.cilium.io/mac-address set to the desired MAC address. For example:

Deploy the Pod. Cilium will configure the mac address to the first interface in the Pod automatically. Check whether its mac address is the specified mac address.

---

## VXLAN Tunnel Endpoint (VTEP) Integration (beta) — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/vtep/

**Contents:**
- VXLAN Tunnel Endpoint (VTEP) Integration (beta)
- Enable VXLAN Tunnel Endpoint (VTEP) integration
- How to test VXLAN Tunnel Endpoint (VTEP) Integration
- Limitations

This is a beta feature. Please provide feedback and file a GitHub issue if you experience any problems.

The VTEP integration allows third party VTEP devices to send and receive traffic to and from Cilium-managed pods directly using VXLAN. This allows for example external load balancers like BIG-IP to load balance traffic to Cilium-managed pods using VXLAN.

This document explains how to enable VTEP support and configure Cilium with VTEP endpoint IPs, CIDRs, and MAC addresses.

This guide assumes that Cilium has been correctly installed in your Kubernetes cluster. Please see Cilium Quick Installation for more information. If unsure, run cilium status and validate that Cilium is up and running. This guide also assumes VTEP devices has been configured with VTEP endpoint IP, VTEP CIDRs, VTEP MAC addresses (VTEP MAC). The VXLAN network identifier (VNI) must be configured as VNI 2, which represents traffic from the VTEP as the world identity. See Special Identities for more details.

This feature is disabled by default. When enabling the VTEP integration, you must also specify the IPs, CIDR ranges and MACs for each VTEP device as part of the configuration.

If you installed Cilium via helm install, you may enable the VTEP support with the following command:

VTEP support can be enabled by setting the following options in the cilium-config ConfigMap:

Restart Cilium daemonset:

Start up a Linux VM with node network connectivity to Cilium node. To configure the Linux VM, you will need to be root user or run the commands below using sudo.

If you are managing multiple VTEPs, follow the above process for each instance. Once the VTEPs are configured, you can configure Cilium to use the MAC, IP and CIDR ranges that you have configured on the VTEPs. Follow the instructions to VXLAN Tunnel Endpoint (VTEP) Integration (beta).

To test the VTEP network connectivity:

This feature does not work with ipsec encryption between Cilium managed pod and VTEPs.

---

## L7-Aware Traffic Management — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/l7-traffic-management/

**Contents:**
- L7-Aware Traffic Management
- Prerequisites
- Caveats
- Installation
  - Supported Envoy API Versions
  - Supported Envoy Extension Resource Types
- Examples

Cilium provides a way to control L7 traffic via CRDs (e.g. CiliumEnvoyConfig and CiliumClusterwideEnvoyConfig).

Cilium must be configured with NodePort enabled, using nodePort.enabled=true or by enabling the kube-proxy replacement with kubeProxyReplacement=true. For more information, see kube-proxy replacement.

CiliumEnvoyConfig resources have only minimal validation performed, and do not have a defined conflict resolution behavior. This means that if you create multiple CECs that modify the same parts of Envoy’s config, the results may be unpredictable.

In addition to this minimal validation, CiliumEnvoyConfig has minimal feedback to the user about the correctness of the configuration. So in the event a CEC does produce an undesirable outcome, troubleshooting will require inspecting the Envoy config and logs, rather than being able to look at the CiliumEnvoyConfig in question.

CiliumEnvoyConfig is used by Cilium’s Ingress and Gateway API support to direct traffic through the per-node Envoy proxies. If you create CECs that conflict with or modify the autogenerated config, results may be unpredictable. Be very careful using CECs for these use cases. The above risks are managed by ensuring that all config generated by Cilium is semantically valid, as far as possible.

If you create a CiliumEnvoyConfig resource directly (ie, not via the Cilium Ingress or Gateway API controllers), if the CEC is intended to manage E/W traffic, set the label cilium.io/use-original-source-address: "false". Otherwise, Envoy will bind the sockets for the upstream connection pools to the original source address/port. This may cause 5-tuple collisions when pods send multiple requests over the same pipelined HTTP/1.1 or HTTP/2 connection. (The Cilium agent assumes all CECs with parentRefs pointing to the Cilium Ingress or Gateway API controllers have cilium.io/use-original-source-address set to "false", but all other CECs are assumed to have this label set to "true".)

Cilium Ingress Controller can be enabled with helm flag ingressController.enabled set as true. Please refer to Installation using Helm for a fresh installation.

Cilium can become the default ingress controller by setting the --set ingressController.default=true flag. This will create ingress entries even when the ingressClass is not set.

If you only want to use envoy traffic management feature without Ingress support, you should only enable --enable-envoy-config flag.

Additionally, the proxy load-balancing feature can be configured with the loadBalancer.l7.backend=envoy flag.

Next you can check the status of the Cilium agent and operator:

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

Cilium Ingress Controller can be enabled with the below command

Cilium can become the default ingress controller by setting the --set ingressController.default=true flag. This will create ingress entries even when the ingressClass is not set.

If you only want to use envoy traffic management feature without Ingress support, you should only enable --enable-envoy-config flag.

Additionally, the proxy load-balancing feature can be configured with the loadBalancer.l7.backend=envoy flag.

Next you can check the status of the Cilium agent and operator:

It is also recommended that you install Hubble CLI which will be used used to observe the traffic in later steps.

As of now only the Envoy API v3 is supported.

Envoy extensions are resource types that may or may not be built in to an Envoy build. The standard types referred to in Envoy documentation, such as type.googleapis.com/envoy.config.listener.v3.Listener, and type.googleapis.com/envoy.config.route.v3.RouteConfiguration, are always available.

Cilium nodes deploy an Envoy image to support Cilium HTTP policy enforcement and observability. This build of Envoy has been optimized for the needs of the Cilium Agent and does not contain many of the Envoy extensions available in the Envoy code base.

To see which Envoy extensions are available, please have a look at the Envoy extensions configuration file. Only the extensions that have not been commented out with # are built in to the Cilium Envoy image. We will evolve the list of built-in extensions based on user feedback.

Please refer to one of the below examples on how to use and leverage Cilium’s Ingress features:

---

## Transparent Encryption — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/network/encryption/

**Contents:**
- Transparent Encryption
- Known Issues and Workarounds
  - Egress traffic to not yet discovered remote endpoints may be unencrypted

Cilium supports the transparent encryption of Cilium-managed host traffic and traffic between Cilium-managed endpoints either using IPsec or WireGuard®:

You can also see a demo of Cilium Transparent Encryption in eCHO episode 79: Transparent Encryption with IPsec and WireGuard.

To determine if a packet needs to be encrypted or not, transparent encryption relies on the same mechanisms as policy enforcement to decide if the destination of an outgoing packet belongs to a Cilium-managed endpoint on a remote node. This means that if an endpoint is allowed to initiate traffic to targets outside of the cluster, it is possible for that endpoint to send packets to arbitrary IP addresses before Cilium learns that a particular IP address belongs to a remote Cilium-managed endpoint or newly joined remote Cilium host in the cluster. In such a case there is a time window during which Cilium will send out the initial packets unencrypted, as it has to assume the destination IP address is outside of the cluster. Once the information about the newly created endpoint has propagated in the cluster and Cilium knows that the IP address is an endpoint on a remote node, it will start encrypting packets using the encryption key of the remote node.

One workaround for this issue is to ensure that the endpoint is not allowed to send unencrypted traffic to arbitrary targets outside of the cluster. This can be achieved by defining an egress policy which either completely disallows traffic to reserved:world identities, or only allows egress traffic to addresses outside of the cluster to a certain subset of trusted IP addresses using toCIDR, toCIDRSet and toFQDN rules. See Layer 3 Examples for more details about how to write network policies that restrict egress traffic to certain endpoints.

Another way to mitigate this issue is to set encryption.strictMode.enabled to true and the expected pod CIDR as encryption.strictMode.cidr. This encryption strict mode enforces that traffic exiting a node to the set CIDR is always encrypted. Be aware that information about new pod endpoints must propagate to the node before the node can send traffic to them.

Encryption strict mode has the following limitations:

Only WireGuard encryption is supported.

The pod CIDR and therefore the encryption strict mode CIDR must be IPv4. IPv6 traffic is not protected by the strict mode and can be leaked.

To disable all dynamic lookups, you must use direct routing mode and the node CIDR and pod CIDR must not overlap. Otherwise, encryption.strictMode.allowRemoteNodeIdentities must be set to true. This allows unencrypted traffic sent from or to an IP address associated with a node identity.

---

## WireGuard Transparent Encryption — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/network/encryption-wireguard/

**Contents:**
- WireGuard Transparent Encryption
- Enable WireGuard in Cilium
- Validate the Setup
- Troubleshooting
- Cluster Mesh
- Node-to-Node Encryption (beta)
- Which traffic is encrypted
- Known Issues
- Legal

This guide explains how to configure Cilium with transparent encryption of traffic between Cilium-managed endpoints using WireGuard®.

Aside from this guide, you can also watch eCHO episode 3: WireGuard on how WireGuard can encrypt network traffic.

When WireGuard is enabled in Cilium, the agent running on each cluster node will establish a secure WireGuard tunnel between it and all other known nodes in the cluster. Each node automatically creates its own encryption key-pair and distributes its public key via the network.cilium.io/wg-pub-key annotation in the Kubernetes CiliumNode custom resource object. Each node’s public key is then used by other nodes to decrypt and encrypt traffic from and to Cilium-managed endpoints running on that node.

Packets are not encrypted when they are destined to the same node from which they were sent. This behavior is intended. Encryption would provide no benefits in that case, given that the raw traffic can be observed on the node anyway.

The WireGuard tunnel endpoint is exposed on UDP port 51871 on each node. If you run Cilium in an environment that requires firewall rules to enable connectivity, you will have to ensure that all Cilium cluster nodes can reach each other via that port.

When running in tunnel routing mode, pod to pod traffic is encapsulated twice. It is first sent to the VXLAN / Geneve tunnel interface, and then subsequently also encapsulated by the WireGuard tunnel.

Before you enable WireGuard in Cilium, please ensure that the Linux distribution running on your cluster nodes has support for WireGuard in kernel mode (i.e. CONFIG_WIREGUARD=m on Linux 5.6 and newer, or via the out-of-tree WireGuard module on older kernels). See WireGuard Installation for details on how to install the kernel module on your Linux distribution.

If you are deploying Cilium with the Cilium CLI, pass the following options:

If you are deploying Cilium with Helm by following Installation using Helm, pass the following options:

WireGuard may also be enabled manually by setting the enable-wireguard: true option in the Cilium ConfigMap and restarting each Cilium agent instance.

When running with the CNI chaining (e.g., AWS VPC CNI plugin), set the Helm option cni.enableRouteMTUForCNIChaining to true to force Cilium to set a correct MTU for Pods. Otherwise, Pod traffic encrypted with WireGuard might get fragmented, which can lead to a network performance degradation.

Run a bash shell in one of the Cilium pods with kubectl -n kube-system exec -ti ds/cilium -- bash and execute the following commands:

Check that WireGuard has been enabled (number of peers should correspond to a number of nodes subtracted by one):

Check that traffic is sent via the cilium_wg0 tunnel device:

When troubleshooting dropped or unencrypted packets between pods, the following commands can be helpful:

For pod to pod packets to be successfully encrypted and decrypted, the following must hold:

WireGuard public key of a remote node in the peers[*].public-key section matches the actual public key of the remote node (public-key retrieved via the same command on the remote node).

peers[*].allowed-ips should contain a list of pod IP addresses running on the remote.

WireGuard enabled Cilium clusters can be connected via Multi-Cluster (Cluster Mesh). The clustermesh-apiserver will forward the necessary WireGuard public keys automatically to remote clusters. In such a setup, it is important to note that all participating clusters must have WireGuard encryption enabled, i.e. mixed mode is currently not supported. In addition, UDP traffic between nodes of different clusters on port 51871 must be allowed.

By default, WireGuard-based encryption only encrypts traffic between Cilium-managed pods. To enable node-to-node encryption, which additionally also encrypts node-to-node, pod-to-node and node-to-pod traffic, use the following configuration options:

If you are deploying Cilium with the Cilium CLI, pass the following options:

If you are deploying Cilium with Helm by following Installation using Helm, pass the following options:

Cilium automatically disables node-to-node encryption from and to Kubernetes control-plane nodes, i.e. any node with the node-role.kubernetes.io/control-plane label will opt-out of node-to-node encryption.

This is done to ensure worker nodes are always able to communicate with the Kubernetes API to update their WireGuard public keys. With node-to-node encryption enabled, the connection to the kube-apiserver would also be encrypted with WireGuard. This creates a bootstrapping problem where the connection used to update the WireGuard public key is itself encrypted with the public key about to be replaced. This is problematic if a node needs to change its public key, for example because it generated a new private key after a node reboot or node re-provisioning.

Therefore, by not encrypting the connection from and to the kube-apiserver host network with WireGuard, we ensure that worker nodes are never accidentally locked out from the control plane. Note that even if WireGuard node-to-node encryption is disabled on those nodes, the Kubernetes control-plane itself is usually still encrypted by Kubernetes itself using mTLS and that pod-to-pod traffic for any Cilium-manged pods on the control-plane nodes are also still encrypted via Cilium’s WireGuard implementation.

The label selector for matching the control-plane nodes which shall not participate in node-to-node encryption can be configured using the node-encryption-opt-out-labels ConfigMap option. It defaults to node-role.kubernetes.io/control-plane. You may force node-to-node encryption from and to control-plane nodes by using an empty label selector with that option. Note that doing so is not recommended, as it will require you to always manually update a node’s public key in its corresponding CiliumNode CRD when a worker node’s public key changes, given that the worker node will be unable to do so itself.

N/S load balancer traffic isn’t encrypted when an intermediate node redirects a request to a different node with the following load balancer configuration:

LoadBalancer & NodePort XDP Acceleration

Direct Server Return (DSR) in non-Geneve dispatch mode

Egress Gateway replies are not encrypted when XDP Acceleration is enabled.

The following table denotes which packets are encrypted with WireGuard depending on the mode. Configurations or communication pairs not present in the following table are not subject to encryption with WireGuard and therefore assumed to be unencrypted.

remote Pod via ClusterIP Service

remote Pod via non ClusterIP Service (e.g., NodePort)

remote Pod via non ClusterIP Service

Client outside cluster

remote Pod via Service

KPR, overlay routing, without DSR, without XDP

Client outside cluster

remote Pod via Service

native routing, without XDP

Client outside cluster

remote Pod or remote Node via Service

DSR in Geneve mode, without XDP

remote Pod via L7 Proxy or L7 Ingress Service

Egress Gateway without XDP

Pod: Cilium-managed K8s Pod running in non-host network namespace.

Node: K8s host running Cilium, or Pod running in host network namespace managed by Cilium.

Service: K8s Service (ClusterIP, NodePort, LoadBalancer, ExternalIP).

Client outside cluster: Any client which runs outside K8s cluster. Request between client and Node is not encrypted. Depending on Cilium configuration (see the table at the beginning of this section), it might be encrypted only between intermediate Node (which received client request first) and destination Node.

Packets may be dropped when configuring the WireGuard device leading to connectivity issues. This happens when endpoints are added or removed or when node updates occur. In some cases this may lead to failed calls to sendmsg and sendto. See GitHub issue 33159 for more details.

“WireGuard” is a registered trademark of Jason A. Donenfeld.

---

## Ingress HTTP Example — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/http/

**Contents:**
- Ingress HTTP Example
- Deploy the Demo App
- Deploy the First Ingress
- Make HTTP Requests

The example ingress configuration routes traffic to backend services from the bookinfo demo microservices app from the Istio project.

This is just deploying the demo app, it’s not adding any Istio components. You can confirm that with Cilium Service Mesh there is no Envoy sidecar created alongside each of the demo app microservices.

With the sidecar implementation the output would show 2/2 READY. One for the microservice and one for the Envoy sidecar.

You’ll find the example Ingress definition in basic-ingress.yaml.

This example routes requests for the path /details to the details service, and / to the productpage service.

Getting the list of services, you’ll see a LoadBalancer service is automatically created for this ingress. Your cloud provider will automatically provision an external IP address, but it may take around 30 seconds.

The external IP address should also be populated into the Ingress:

Some providers e.g. EKS use a fully-qualified domain name rather than an IP address.

Check (with curl or in your browser) that you can make HTTP requests to that external address. The / path takes you to the home page for the bookinfo application.

From outside the cluster you can also make requests directly to the details service using the path /details. But you can’t directly access other URL paths that weren’t defined in basic-ingress.yaml.

For example, you can get JSON data from a request to <address>/details/1 and get back some data, but you will get a 404 error if you make a request to <address>/ratings.

---

## Multicast Support in Cilium (Beta) — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/multicast/

**Contents:**
- Multicast Support in Cilium (Beta)
- Prerequisites
- Enable Multicast Feature
- Configure Multicast and Subscriber IPs
- Limitations

This is a beta feature. Please provide feedback and file a GitHub issue if you experience any problems.

The multicast capability allows user application to distribute data feeds to multiple consumers in the Kubernetes cluster. The container network multicast transmission technology based on eBPF focuses on solving the problem of efficient multicast transmission in the container network and provides support for multiple multicast protocols.

This document explains how to enable multicast support and configure Cilium and CiliumNode with multicast group IP addresses and subscribers.

This guide assumes that Cilium has been correctly installed in your Kubernetes cluster. Please see Cilium Quick Installation for more information. If unsure, run cilium status and validate that Cilium is up and running. This guide also assumes Cilium is configured with vxlan mode, which is required when using multicast capability.

Multicast only works on kernels >= 5.10 for AMD64, and on kernels >= 6.0 for AArch64.

Multicast support can be enabled by updating cilium-config ConfigMap as following:

To use multicast with Cilium, we need to configure multicast group IP addresses and subscriber list based on the application requirements. This is done by running cilium-dbg command in each cilium-agent pod. Then, multicast subscriber pods can send out IGMP join and multicast sender pods can start sending multicast stream.

As an example, the following guide uses 239.255.0.1 multicast group address.

Get all CiliumNode IP addresses to be set as multicast subscribers:

To set multicast IP address, enable multicast BPF maps in each cilium-agent:

Then, set the subscriber IP addresses in each cilium-agent:

This multicast subscriber IP addresses are different CiliumNode IP addresses than your own one.

To make all nodes join a specified multicast group, use the cilium multicast command. You can also get information about multicast groups and subscribers cluster-wide.

When you want to remove multicast IP addresses and subscriber list, run the following commands in the cilium-agent.

The operation needs to be done on each CiliumNode that uses multicast feature.

This feature does not work with ipsec encryption between Cilium managed pod.

---

## Multi-Cluster (Cluster Mesh) — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/clustermesh/intro/

**Contents:**
- Multi-Cluster (Cluster Mesh)
- KVStoreMesh

Cluster mesh extends the networking datapath across multiple clusters. It allows endpoints in all connected clusters to communicate while providing full policy enforcement. Load-balancing is available via Kubernetes annotations.

See Setting up Cluster Mesh for instructions on how to set up cluster mesh.

KVStoreMesh is an extension of Cluster Mesh. It caches the information obtained from the remote clusters in a local kvstore (such as etcd), to which all local Cilium agents connect. This is different from vanilla Cluster Mesh, where each agent directly pulls the information from the remote clusters. KVStoreMesh enables improved scalability and isolation.

Starting from v1.16 KVStoreMesh is enabled by default. If you wish to disable it, please refer to Enable Cluster Mesh for instructions on how to disable KVStoreMesh.

---

## CRD-Backed IPAM — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/kubernetes/ipam-crd/

**Contents:**
- CRD-Backed IPAM
- Enable CRD IPAM mode
- Create a CiliumNode CR

This is a quick tutorial walking through how to enable CRD-backed IPAM. The purpose of this tutorial is to show how components are configured and resources interact with each other to enable users to automate or extend on their own.

For more details, see the section CRD-Backed

Setup Cilium for Kubernetes using any of the available guides.

Run Cilium with the --ipam=crd option or set ipam: crd in the cilium-config ConfigMap.

Restart Cilium. Cilium will automatically register the CRD if not available already

Validate that the CRD has been registered:

Import the following custom resource to make IPs available in the Cilium agent.

Validate that Cilium has started up correctly

Validate the status.IPAM.used section:

At the moment only single IP addresses are allowed. CIDR’s are not supported.

---

## Node IPAM LB — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/node-ipam/

**Contents:**
- Node IPAM LB
- Enable and use Node IPAM

Node IPAM LoadBalancer is a feature inspired by k3s “ServiceLB” that allows you to “advertise” the node’s IPs directly inside a Service LoadBalancer. This feature is especially useful if you don’t control the network you are running on and can’t use either the L2 or BGP capabilities of Cilium.

It works by getting the Node addresses of the selected Nodes and advertising them. It will respect the .spec.ipFamilies to decide if IPv4 or IPv6 addresses shall be used and will use the ExternalIP addresses if any or the InternalIP addresses otherwise.

If the Service has .spec.externalTrafficPolicy set to Cluster, Node IPAM considers all nodes as candidates for selection. Otherwise, if .spec.externalTrafficPolicy is set to Local, then Node IPAM considers all the Pods selected by the Service (via their EndpointSlices) as candidates.

Node IPAM does not work properly if .spec.externalTrafficPolicy is set to Local but no EndpointSlice (or dummy EndpointSlice) is linked to the corresponding Service.

As a result, you cannot set .spec.externalTrafficPolicy to Local with the Cilium implementations for GatewayAPI or Ingress, because Cilium currently uses a dummy Endpoints for the Service LoadBalancer (see here). Only the Cilium implementation is known to be affected by this limitation. Most other implementations are expected to work with this configuration. If they don’t, check if the matching EndpointSlices look correct and/or try setting .spec.externalTrafficPolicy to Cluster.

Node IPAM honors the Node label node.kubernetes.io/exclude-from-external-load-balancers and the Node taint ToBeDeletedByClusterAutoscaler. Node IPAM doesn’t consider a node as a candidate for load balancing if the label node.kubernetes.io/exclude-from-external-load-balancers or the taint ToBeDeletedByClusterAutoscaler is present.

To restrict the Nodes that should listen for incoming traffic, add annotation io.cilium.nodeipam/match-node-labels to the Service. The value of the annotation is a Label Selector.

To use this feature your Service must be of type LoadBalancer and have the loadBalancerClass set to io.cilium/node. You can also allow set defaultLBServiceIPAM to nodeipam to use this feature on a Service that doesn’t specify a loadBalancerClass.

Cilium’s node IPAM is disabled by default. To install Cilium with the node IPAM, run:

To enable node IPAM on an existing installation, run:

---

## L7 Load Balancing and URL re-writing — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/envoy-traffic-management/

**Contents:**
- L7 Load Balancing and URL re-writing
- Deploy Test Applications
- Start Observing Traffic with Hubble
- Add Layer 7 Policy
- Test Layer 7 Policy Enforcement
- Add Envoy load-balancing and URL re-writing

Cilium Service Mesh defines a CiliumEnvoyConfig CRD which allows users to set the configuration of the Envoy component built into Cilium agents.

This example sets up an Envoy listener which load balances requests between two backend services.

The test workloads consist of:

two client deployments, client and client2

two services, echo-service-1 and echo-service-2

View information about these pods:

Only client2 is labeled with other=client - we will use this in a CiliumNetworkPolicy definition later in this example.

Make an environment variable with the pod ID for client2:

We are going to use Envoy configuration to load-balance requests between these two services echo-service-1 and echo-service-2.

Enable Hubble in your cluster with the step mentioned in Setting up Hubble Observability.

Start a second terminal, then enable hubble port forwarding and observe traffic from the client2 pod:

You should be able to get a response from both of the backend services individually from client2:

Notice that Hubble shows all the flows between these pods as being either to/from-stack, to/from-overlay or to/from-endpoint - there is no traffic marked as flowing to or from the proxy at this stage. (This assumes you don’t already have any Layer 7 policies in place affecting this traffic.)

Verify that you get a 404 error response if you curl to the non-existent URL /foo on these services:

Adding a Layer 7 policy introduces the Envoy proxy into the path for this traffic.

Make a request to a backend service (either will do):

Adding a Layer 7 policy enables Layer 7 visibility. Notice that the Hubble output now includes flows to-proxy, and also shows the HTTP protocol information at level 7 (for example HTTP/1.1 GET http://echo-service-1:8080/)

Note that Envoy may sanitize some headers.

Instead, you can make Envoy trust previous hops and prevent Envoy from rewriting some of these HTTP headers. Trust previous hops by setting Helm values envoy.xffNumTrustedHopsL7PolicyIngress and envoy.xffNumTrustedHopsL7PolicyEgress to the number of hops to trust.

For an egress policy the previous hop is the source pod, whereas for an ingress policy it can be either the source pod, the “egress policy transparent proxy”, Cilium Ingress Controller, Cilium Gateway API, or any other Ingress proxy or infrastructure.

Depending on your environment, you should consider the security implications of trusting previous hops.

The policy only permits GET requests to the / path, so you will see requests to any other URL being dropped. For example, try:

The Hubble output will show the HTTP request being dropped, like this:

And the curl should show a 403 Forbidden response.

Apply the envoy-traffic-management-test.yaml file, which defines a CiliumClusterwideEnvoyConfig.

Note that these Envoy resources are not validated by K8s at all, so any errors in the Envoy resources will only be seen by the Cilium Agent observing these CRDs. This means that kubectl apply will report success, while parsing and/or installing the resources for the node-local Envoy instance may have failed. Currently the only way of verifying this is by observing Cilium Agent logs for errors and warnings. Additionally, Cilium Agent will print warning logs for any conflicting Envoy resources in the cluster.

Note that Cilium Ingress Controller will configure required Envoy resource under the hood. Please check Cilium Agent logs if you are creating Envoy resources explicitly to make sure there is no conflict.

This configuration listens for traffic intended for either of the two echo- services and:

load-balances 50/50 between the two backend echo- services

rewrites the path /foo to /

A request to /foo should now succeed, because of the path re-writing:

But the network policy still prevents requests to any path that is not rewritten to /. For example, this request will result in a packet being dropped and a 403 Forbidden response code:

Try making several requests to one backend service. You should see in the Hubble output approximately half the time, they are handled by the other backend.

---

## BGP Control Plane Operation Guide — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/bgp-control-plane/bgp-control-plane-operation/

**Contents:**
- BGP Control Plane Operation Guide
- BGP Cilium CLI
  - Installation
  - Peers
  - Routes
  - Policies
- CiliumBGPClusterConfig Status
- CiliumBGPPeerConfig Status
- CiliumBGPNodeConfig Status
- Disabling CRD Status Report

This document provides guidance on how to operate the BGP Control Plane.

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

Cilium BGP state can be inspected via cilium bgp subcommand.

cilium bgp peers command displays current peering states from all nodes in the kubernetes cluster.

In the following example, peering status is displayed for two nodes in the cluster.

Using this command, you can validate BGP session state is established and expected number of routes are being advertised to the peers.

cilium bgp routes command displays detailed information about local BGP routing table and per peer advertised routing information.

In the following example, the local BGP routing table for IPv4/Unicast address family is shown for two nodes in the cluster.

Similarly, you can inspect per peer advertisements using following command.

You can validate the BGP attributes are advertised based on configured CiliumBGPAdvertisement resources.

Cilium BGP installs GoBGP policies for managing per peer advertisement and BGP attributes. As this is an internal implementation detail, it is not exposed via Cilium CLI. However, for debugging purpose you can inspect installed BGP policies using cilium-dbg CLI from the Cilium agent pod.

CiliumBGPClusterConfig may report some configuration errors in the .status.conditions caught at runtime. Currently, the following conditions are defined.

cilium.io/NoMatchingNode

.spec.nodeSelector doesn’t select any node.

cilium.io/MissingPeerConfigs

The PeerConfig specified in the spec.bgpInstances[].peers[].peerConfigRef doesn’t exist.

cilium.io/ConflictingClusterConfig

There is an another CiliumBGPClusterConfig selecting the same node.

CiliumBGPPeerConfig may report some configuration errors in the .status.conditions caught at runtime. Currently, the following conditions are defined.

cilium.io/MissingAuthSecret

The Secret specified in the .spec.authSecretRef doesn’t exist.

Each Cilium node on which BGP control plane is enabled based on CiliumBGPClusterConfig node selector gets associated CiliumBGPNodeConfig resource. CiliumBGPNodeConfig resource is the source of BGP configuration for the node, it is managed by Cilium operator.

Status field of CiliumBGPNodeConfig maintains real-time BGP operational state. This can be used for automation or monitoring purposes.

In the following example, you can see BGP instance state from node bgpv2-cplane-dev-service-worker.

CRD status reporting is useful for troubleshooting, making it useful to enable in general. However, for large clusters with a lot of nodes or BGP policies, CRD status reporting may add a significant API server load. To disable status reporting, set the bgpControlPlane.statusReport.enabled Helm value to false. Doing so disables status reporting and clears the currently reported status.

BGP Control Plane logs can be found in the Cilium operator (only for BGPv2) and the Cilium agent logs.

The operator logs are tagged with subsys=bgp-cp-operator. You can use this tag to filter the logs as in the following example:

The agent logs are tagged with subsys=bgp-control-plane. You can use this tag to filter the logs as in the following example:

Metrics exposed by BGP Control Plane are listed in the metrics document.

When you restart the Cilium agent, the BGP session will be lost because the BGP speaker is integrated within the Cilium agent. The BGP session will be restored once the Cilium agent is restarted. However, while the Cilium agent is down, the advertised routes will be removed from the BGP peer. As a result, you may temporarily lose connectivity to the Pods or Services. You can enable the Graceful Restart to continue forwarding traffic to the Pods or Services during the agent restart.

When you upgrade or downgrade Cilium, you must restart the Cilium agent. For more details about the agent restart, see Restarting an Agent section.

Note that with BGP Control Plane, it’s especially important to pre-pull the agent image by following the preflight process before upgrading Cilium. Image pull is time-consuming and error-prone because it involves network communication. If the image pull takes longer, it may exceed the Graceful Restart time (restartTimeSeconds) and cause the BGP peer to withdraw routes.

When you need to shut down a node for maintenance, you can follow the steps below to avoid packet loss as much as possible.

Drain the node to evict all workloads. This will remove all Pods on the node from the Service endpoints and prevent Services with externalTrafficPolicy=Cluster from redirecting traffic to the node.

Reconfigure the BGP sessions by modifying or removing the CiliumBGPPeeringPolicy or CiliumBGPClusterConfig node selector label on the Node object. This will shut down all BGP sessions on the node.

Wait for a while until the BGP peer removes routes towards the node. During this period, the BGP peer may still send traffic to the node. If you shut down the node without waiting for the BGP peer to remove routes, it will break the ongoing traffic of externalTrafficPolicy=Cluster Services.

In step 3, you may not be able to check the peer status and may want to wait for a specific period of time without checking the actual peer status. In this case, you can roughly estimate the time like the following:

If you disable the BGP Graceful Restart feature, the BGP peer should withdraw routes immediately after step 2.

If you enable the BGP Graceful Restart feature, there are two possible cases.

If the BGP peer supports the Graceful Restart with Notification (RFC 8538), it will withdraw routes after the Stale Timer (defined in the RFC 8538#section-4.1) expires.

If the BGP peer does not support the Graceful Restart with Notification, it will withdraw routes immediately after step 2 because the BGP Control Plane sends the BGP Notification to the peer when you unselect the node.

The above estimation is a theoretical value, and the actual time always depends on the BGP peer’s implementation. Ideally, you should check the peer router’s actual behavior in advance with your network administrator.

Even if you follow the above steps, some ongoing Service traffic originally destined for the node may be reset because, after the route withdrawal and ECMP rehashing, the traffic is redirected to a different node, and the new node may select a different endpoint.

This document describes common failure scenarios that you may encounter when using the BGP Control Plane and provides guidance on how to mitigate them.

If the Cilium agent goes down, the BGP session will be lost because the BGP speaker is integrated within the Cilium agent. The BGP session will be restored once the Cilium agent is restarted. However, while the Cilium agent is down, the advertised routes will be removed from the BGP peer. As a result, you may temporarily lose connectivity to the Pods or Services.

The recommended way to address this issue is by enabling the Graceful Restart feature. This feature allows the BGP peer to retain routes for a specific period of time after the BGP session is lost. Since the datapath remains active even when the agent is down, this will prevent the loss of connectivity to the Pods or Services.

When you can’t use BGP Graceful Restart, you can take the following actions, depending on the kind of routes you are using:

If you are advertising PodCIDR routes, pods on the failed node will be unreachable from the external network. If the failure only occurs on a subset of the nodes in the cluster, you can drain the unhealthy nodes to migrate the pods to other nodes.

If you are advertising service routes, the load balancer (KubeProxy or Cilium KubeProxyReplacement) may become unreachable from the external network. Additionally, ongoing connections may be redirected to different nodes due to ECMP rehashing on the upstream routers. When the load balancer encounters unknown traffic, it will select a new endpoint. Depending on the load balancer’s backend selection algorithm, the traffic may be directed to a different endpoint than before, potentially causing the connection to be reset.

If your upstream routers support ECMP with Resilient Hashing, enabling it may help to keep the ongoing connections forwarded to the same node. Enabling the Maglev Consistent Hashing feature in Cilium may also help since it increases the probability that all nodes select the same endpoint for the same flow. However, it only works for the externalTrafficPolicy: Cluster. If the Service’s externalTrafficPolicy is set to Local, it is inevitable that all ongoing connections with the endpoints on the failed node, and connections forwarded to a different node than before, will be reset.

If the node goes down, the BGP sessions from this node will be lost. The peer will withdraw the routes advertised by the node immediately or takes some time to stop forwarding traffic to the node depending on the Graceful Restart settings. The latter case is problematic when you advertise the route to a Service with externalTrafficPolicy=Cluster because the peer will continue to forward traffic to the unavailable node until the restart timer (which is 120s by default) expires.

When a node is involuntarily shut down, there’s no direct mitigation. You can choose to not use the BGP Graceful Restart feature, depending on the trade-off between the failure detection time vs stability provided by graceful restart in cases of Cilium pod restarts.

Disabling the Graceful Restart allows the BGP peer to withdraw routes faster. Even if the node is shut down without BGP Notification or TCP connection close, the worst case time for peer to withdraw routes is the BGP hold time. When the Graceful Restart is enabled, the BGP peer may need hold time + restart time to withdraw routes received from the node.

When you voluntarily shut down a node, you can follow the steps described in the Shutting Down a Node section to avoid packet loss as much as possible.

If the peering link between the BGP peers goes down, usually, both the BGP session and datapath connectivity will be lost. However, there may be a period during which the datapath connectivity is lost while the BGP session remains up and routes are still being advertised. This can cause the BGP peer to send traffic over the failed link, resulting in dropped packets. The length of this period depends on which link is down and the BGP configuration.

If the link directly connected to the Node goes down, the BGP session will likely be lost immediately because the Linux kernel detects the link failure and shuts down the TCP session right away. If a link not directly connected to the Node goes down, the BGP session will be lost after the hold timer expires, which is set to 90 seconds by default.

To make link detection failure fast, you can adjust holdTimeSeconds and keepAliveTimeSeconds in the BGP configuration to the shorter value. However, the minimal possible values are holdTimeSeconds=3 and keepAliveTimeSeconds=1. The general approach to make failure detection faster is to use BFD (Bidirectional Forwarding Detection), but currently, Cilium does not support it.

The Cilium operator is responsible for translating CiliumBGPClusterConfig to the per node CiliumBGPNodeConfig resource. If the Cilium operator is down, provisioning of BGP control plane will be stopped.

Similarly, PodCIDR allocation by IPAM, and LoadBalancer IP allocation by LB-IPAM are stopped. Therefore, the advertisement of new and withdrawal of old PodCIDR and Service VIP routes will be stopped as well.

There’s no direct mitigation in terms of the BGP. However, running the Cilium Operator with a high-availability setup will make the Cilium Operator more resilient to failures.

If all service backends are gone due to an outage or a configuration mistake, BGP Control Plane behaves differently depending on the Service’s externalTrafficPolicy. When the externalTrafficPolicy is set to Cluster, the Service’s VIP remains advertised from all nodes selected by the CiliumBGPPeeringPolicy or CiliumBGPClusterConfig. When the externalTrafficPolicy is set to Local, the advertisement stops entirely because the Service’s VIP is only advertised from the node where the Service backends are running.

There’s no direct mitigation in terms of the BGP. In general, you should prevent the Service backends from being all gone by Kubernetes features like PodDisruptionBudget.

---

## Envoy — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/network/proxy/envoy/

**Contents:**
- Envoy
- Deployment as DaemonSet
  - Background
  - Enable and configure Envoy DaemonSet
  - Potential Benefits
- Go Extensions
  - Step 1: Decide on a Basic Policy Model
  - Step 2: Understand Protocol, Encoding, Framing and Types
  - Step 3: Search for Existing Parser Code / Libraries
  - Step 4: Follow the Cilium Developer Guide

Envoy proxy shipped with Cilium is built with minimal Envoy extensions and custom policy enforcement filters. Cilium uses this minimal distribution as its host proxy for enforcing HTTP and other L7 policies as specified in network policies for the cluster. Cilium proxy is distributed within the Cilium images.

For more information on the version compatibility matrix, see Cilium Proxy documentation.

When Cilium L7 functionality (Ingress, Gateway API, Network Policies with L7 functionality, L7 Protocol Visibility) is enabled or installed in a Kubernetes cluster, the Cilium agent starts an Envoy proxy as separate process within the Cilium agent pod.

That Envoy proxy instance becomes responsible for proxying all matching L7 requests on that node. As a result, L7 traffic targeted by policies depends on the availability of the Cilium agent pod.

Alternatively, it’s possible to deploy the Envoy proxy as independently life-cycled DaemonSet called cilium-envoy instead of running it from within the Cilium Agent Pod.

The communication between Cilium agent and Envoy proxy takes place via UNIX domain sockets in both deployment modes. Be that streaming the access logs (e.g. L7 Protocol Visibility), updating the configuration via xDS or accessing the admin interface. Due to the use of UNIX domain sockets, Envoy DaemonSet and the Cilium Agent need to have compatible types when SELinux is enabled on the host. This is the case if not specified otherwise, both using the highly privileged type: spc_t. SELinux is enabled by default on Red Hat OpenShift Container Platform.

To enable the dedicated Envoy proxy DaemonSet, install Cilium with the Helm value envoy.enabled set to true.

Please see the Helm Reference (keys with envoy.*) for detailed information on how to configure the Envoy proxy DaemonSet.

Cilium Agent restarts (e.g. for upgrades) without impacts for the live traffic proxied via Envoy.

Envoy patch release upgrades without impacts for the Cilium Agent.

Separate CPU and memory limits for Envoy and Cilium Agent for performance isolation.

Envoy application log not mixed with the one of the Cilium Agent.

Dedicated health probes for the Envoy proxy.

Explicit deployment of Envoy proxy during Cilium installation (compared to on demand in the embedded mode).

If you’d like to see Cilium Envoy in action, check out eCHO episode 127: Cilium & Envoy.

This feature is currently in beta phase.

The Go extensions proxylib framework is residing in cilium/proxy repository.

This is a guide for developers who are interested in writing a Go extension to the Envoy proxy as part of Cilium.

As depicted above, this framework allows a developer to write a small amount of Go code (green box) focused on parsing a new API protocol, and this Go code is able to take full advantage of Cilium features including high-performance redirection to/from Envoy, rich L7-aware policy language and access logging, and visibility into encrypted traffic via kTLS (coming soon!). In sum, you as the developer need only worry about the logic of parsing the protocol, and Cilium + Envoy + eBPF do the heavy-lifting.

This guide uses simple examples based on a hypothetical “r2d2” protocol (see proxylib/r2d2/r2d2parser.go) that might be used to talk to a simple protocol droid a long time ago in a galaxy far, far away. But it also points to other real protocols like Memcached and Cassandra that already exist in the cilium/proxylib directory.

To get started, take some time to think about what it means to provide protocol-aware security in the context of your chosen protocol. Most protocols follow a common pattern of a client who performs an ‘’operation’’ on a ‘’resource’’. For example:

A standard RESTful HTTP request has a GET/POST/PUT/DELETE methods (operation) and URLs (resource).

A database protocol like MySQL has SELECT/INSERT/UPDATE/DELETE actions (operation) on a combined database + table name (resource).

A queueing protocol like Kafka has produce/consume (operation) on a particular queue (resource).

A common policy model is to allow the user to whitelist certain operations on one or more resources. In some cases, the resources need to support regexes to avoid explicit matching on variable content like ids (e.g., /users/<uuid> would match /users/.*)

In our examples, the ‘’r2d2’’ example, we’ll use a basic set of operations (READ/WRITE/HALT/RESET). The READ and WRITE commands also support a ‘filename’ resource, while HALT and RESET have no resource.

Next, get your head wrapped around how a protocol looks terms of the raw data, as this is what you’ll be parsing.

Try looking for official definitions of the protocol or API. Official docs will not only help you quickly learn how the protocol works, but will also help you by documenting tricky corner cases that wouldn’t be obvious just from regular use of the protocol. For example, here are example specs for Redis Protocol , Cassandra Protocol, and AWS SQS .

These specs help you understand protocol aspects like:

encoding / framing : how to recognize the beginning/end of individual requests/replies within a TCP stream. This typically involves reading a header that encodes the overall request length, though some simple protocols use a delimiter like ‘’rn'’ to separate messages.

request/reply fields : for most protocols, you will need to parse out fields at various offsets into the request data in order to extract security-relevant values for visibility + filtering. In some cases, access control requires filtering requests from clients to servers, but in some cases, parsing replies will also be required if reply data is required to understand future requests (e.g., prepared-statements in database protocols).

message flow : specs often describe various dependencies between different requests. Basic protocols tend to follow a simple serial request/reply model, but more advanced protocols will support pipelining (i.e., sending multiple requests before any replies have been received).

protocol errors : when a Cilium proxy denies a request based on policy, it should return a protocol-specific error to the client (e.g., in HTTP, a proxy should return a ‘’403 Access Denied’’ error). Looking at the protocol spec will typically indicate how you should return an equivalent ‘’Access Denied’’ error.

Sometimes, the protocol spec does not give you a full sense of the set of commands that can be sent over the protocol. In that case, looking at higher-level user documentation can fill in some of these knowledge gaps. Here are examples for Redis Commands and Cassandra CQL Commands .

Another great trick is to use Wireshark to capture raw packet data between a client and server. For many protocols, the Wireshark Sample Captures has already saved captures for us. Otherwise, you can easily use tcpdump to capture a file. For example, for MySQL traffic on port 3306, you could run the following in a container running the MySQL client or server: “tcpdump -s 0 port 3306 -w mysql.pcap”. More Info

In our example r2d2 protocol, we’ll keep the spec as simple as possible. It is a text-only based protocol, with each request being a line terminated by ‘’rn’’. A request starts with a case-insensitive string command (“READ”,”WRITE”,”HALT”,”RESET”). If the command is “READ” or “WRITE”, the command must be followed by a space, and a non-empty filename that contains only non whitespace ASCII characters.

Look for open source Go library/code that can help. Is there existing open source Go code that parse your protocol that you can leverage, either directly as library or a motivating example? For example, the tidwall/recon library parses Redis in Go, and Vitess parses MySQL in Go. Wireshark dissectors also has a wealth of protocol parsers written in C that can serve as useful guidance. Note: finding client-only protocol parsing code is typically less helpful than finding a proxy implementation, or a full parser library. This is because the set of requests a client parsers is typically the inverse set of the requests a Cilium proxy needs to parse, since the proxy mimics the server rather than the client. Still, viewing a Go client can give you a general idea of how to parse the general serialization format of the protocol.

It is easiest to start Cilium development by following the Development

After cloning cilium/proxy repo:

While this dev VM is running, you can open additional terminals to the cilium/proxy dev VM by running vagrant ssh from within the cilium/proxy source directory.

From inside the proxylib directory, copy the rd2d directory and rename the files. Replace ‘’newproto’’ with your protocol:

Within both newproto.go and newproto_test.go update references to r2d2 with your protocol name. Search for both ‘’r2d2’’ and ‘’R2D2’’.

Also, edit proxylib.go and add the following import line:

Implementing a parser requires you as the developer to implement three primary functions, shown as blue in the diagram below. We will cover OnData() in this section, and the other functions in section Step 9: Add Policy Loading and Matching.

The beating heart of your parsing is implementing the onData function. You can think of any proxy as have two data streams, one in the request direction (i.e., client to server) and one in the reply direction (i.e., server to client). OnData is called when there is data to process, and the value of the boolean ‘reply’ parameter indicates the direction of the stream for a given call to OnData. The data passed to OnData is a slice of byte slices (i.e., an array of byte arrays).

The return values of the OnData function tell the Go framework tell how data in the stream should be processed, with four primary outcomes:

PASS x : The next x bytes in the data stream passed to OnData represent a request/reply that should be passed on to the server/client. The common case here is that this is a request that should be allowed by policy, or that no policy is applied. Note: x bytes may be less than the total amount of data passed to OnData, in which case the remaining bytes will still be in the data stream when onData is invoked next. x bytes may also be more than the data that has been passed to OnData. For example, in the case of a protocol where the parser filters only on values in a protocol header, it is often possible to make a filtering decision, and then pass (or drop) the size of the full request/reply without having the entire request passed to Go.

MORE x : The buffers passed to OnData to do not represent all of the data required to frame and filter the request/reply. Instead, the parser needs to see at least x additional bytes beyond the current data to make a decision. In some cases, the full request must be read to understand framing and filtering, but in others a decision can be made simply by reading a protocol header. When parsing data, be defensive, and recognize that it is technically possible that data arrives one byte at a time. Two common scenarios exist here:

Text-based Protocols : For text-based protocols that use a delimiter like “rn”, it is common to simply check if the delimiter exists, and return MORE 1 if it does not, as technically one more character could result in the delimiter being present. See the sample r2d2 parser as a basic example of this.

Binary-based protocols : Many binary protocols have a fixed header length, which containers a field that then indicates the remaining length of the request. In the binary case, first check to make sure a full header is received. Typically the header will indicate both the full request length (i.e., framing), as well as the request type, which indicates how much of the full request must be read in order to perform filtering (in many cases, this is less than the full request). A binary parser will typically return MORE if the data passed to OnData is less than the header length. After reading a full header, the simple approach is for the parser to return MORE to wait for the full request to be received and parsed (see the existing CassandraParser as an example). However, as an optimization, the parser can attempt to only request the minimum number of bytes required beyond the header to make a policy decision, and then PASS or DROP the remaining bytes without requiring them to be passed to the Go parser.

DROP x : Remove the first x bytes from the data stream passed to OnData, as they represent a request/reply that should not be forwarded to the client or server based on policy. Don’t worry about making onData return a drop right away, as we’ll return to DROP in a later step below.

ERROR y : The connection contains data that does not match the protocol spec, and prevents you from further parsing the data stream. The framework will terminate the connection. An example would be a request length that falls outside the min/max specified by the protocol spec, or values for a field that fall outside the values indicated by the spec (e.g., wrong versions, unknown commands). If you are still able to properly frame the requests, you can also choose to simply drop the request and return a protocol error (e.g., similar to an ‘’HTTP 400 Bad Request’’ error. But in all cases, you should write your parser defensively, such that you never forward a request that you do not understand, as such a request could become an avenue for subverting the intended security visibility and filtering policies. See proxylib/types.h for the set of valid error codes.

See proxylib/proxylib/parserfactory.go for the official OnData interface definition.

Keep it simple, and work iteratively. Start out just getting the framing right. Can you write a parser that just prints out the length and contents of a request, and then PASS each request with no policy enforcement?

One simple trick is to comment out the r2d2 parsing logic in OnData, but leave it in the file as a reference, as your protocol will likely require similar code as we add more functionality below.

Use unit tests to drive your development. Its tempting to want to first test your parser by firing up a client and server and developing on the fly. But in our experience you’ll iterate faster by using the great unit test framework created along with the Go proxy framework. This framework lets you pass in an example set of requests as byte arrays to a CheckOnDataOK method, which are passed to the parser’s OnData method. CheckOnDataOK takes a set of expected return values, and compares them to the actual return values from OnData processing the byte arrays.

Take some time to look at the unit tests for the r2d2 parser, and then for more complex parsers like Cassandra and Memcached. For simple text-based protocols, you can simply write ASCII strings to represent protocol messages, and convert them to []byte arrays and pass them to CheckOnDataOK. For binary protocols, one can either create byte arrays directly, or use a mechanism to convert a hex string to byte[] array using a helper function like hexData in cassandra/cassandraparser_test.go

A great way to get the exact data to pass in is to copy the data from the Wireshark captures mentioned above in Step #2. You can see the full application layer data streams in Wireshark by right-clicking on a packet and selecting “Follow As… TCP Stream”. If the protocol is text-based, you can copy the data as ASCII (see r2d2/r2d2parser_test.go as an example of this). For binary data, it can be easier to instead select “raw” in the drop-down, and use a basic utility to convert from ascii strings to binary raw data (see cassandra/cassandraparser_test.go for an example of this).

To run the unit tests, go to proxylib/newproto and run:

This will build the latest version of your parser and unit test files and run the unit tests.

Thinking back to step #1, what are the critical fields to parse out of the request in order to understand the “operation” and “resource” of each request. Can you print those out for each request?

Use the unit test framework to pass in increasingly complex requests, and confirm that the parser prints out the right values, and that the unit tests are properly slicing the datastream into requests and parsing out the required fields.

A couple scenarios to make sure your parser handles properly via unit tests:

data chunks that are less than a full request (return MORE)

requests that are spread across multiple data chunks. (return MORE ,then PASS)

multiple requests that are bundled into a single data chunk (return PASS, then another PASS)

rejection of malformed requests (return ERROR).

For certain advanced cases, it is required for a parser to store state across requests. In this case, data can be stored using data structures that are included as part of the main parser struct. See CassandraParser in cassandra/cassandraparser.go as an example of how the parser uses a string to store the current ‘keyspace’ in use, and uses Go maps to keep state required for handling prepared queries.

Once you have the parsing of most protocol messages ironed out, its time to start enforcing policy.

First, create a Go object that will represent a single rule in the policy language. For example, this is the rule for the r2d2 protocol, which performs exact match on the command string, and a regex on the filename:

There are two key methods to update:

Matches : This function implements the basic logic of comparing data from a single request against a single policy rule, and return true if that rule matches (i.e., allows) that request.

<NewProto>RuleParser : Reads key value pairs from policy, validates those entries, and stores them as a <NewProto>Rule object.

See r2d2/r2d2parser.go for examples of both functions for the r2d2 protocol.

You’ll also need to update OnData to call p.connection.Matches(), and if this function return false, return DROP for a request. Note: despite the similar names between the Matches() function you create in your newprotoparser.go and p.connection.Matches(), do not confuse the two. Your OnData function should always call p.connection.Matches() rather than invoking your own Matches() directly, as p.connection.Matches() calls the parser’s Matches() function only on the subset of L7 rules that apply for the given Cilium source identity for this particular connection.

Once you add the logic to call Matches() and return DROP in OnData, you will need to update unit tests to have policies that allow the traffic you expect to be passed. The following is an example of how r2d2/r2d2parser_test.go adds an allow-all policy for a given test:

The following is an example of a policy that would allow READ commands with a file regex of “.*”:

Simply dropping the request from the request data stream prevents the request from reaching the server, but it would leave the client hanging, waiting for a response that would never come since the server did not see the request.

Instead, the proxy should return an application-layer reply indicating that access was denied, similar to how an HTTP proxy would return a ‘’403 Access Denied’’ error. Look back at the protocol spec discussed in Step 2 to understand what an access denied message looks like for this protocol, and use the p.connection.Inject() method to send this error reply back to the client. See r2d2/r2d2parser.go for an example.

Note: p.connection.Inject() will inject the data it is passed into the reply datastream. In order for the client to parse this data correctly, it must be injected at a proper framing boundary (i.e., in between other reply messages that may be in the reply data stream). If the client is following a basic serial request/reply model per connection, this is essentially guaranteed as at the time of a request that is denied, there are no other replies potentially in the reply datastream. But if the protocol supports pipelining (i.e., multiple requests in flight) replies must be properly framed and PASSed on a per request basis, and the timing of the call to p.connection.Inject() must be controlled such that the client will properly match the Error response with the correct request. See the Memcached parser as an example of how to accomplish this.

Cilium also has the notion of an ‘’Access Log’’, which records each request handled by the proxy and indicates whether the request was allowed or denied.

A call to p.connection.Log() implements access logging. See the OnData function in r2d2/r2d2parser.go as an example:

Find the standard docker container for running the protocol server. Often the same image also has a CLI client that you can use as a client.

Start both a server and client container running in the cilium dev VM, and attach them to the already created “cilium-net”. For example, with Cassandra, we run:

Note that we run both containers with labels that will make it easy to refer to these containers in a cilium network policy. Note that we have the client container run the sleep command, as we will use ‘docker exec’ to access the client CLI.

Use cilium-dbg endpoint list to identify the IP address of the protocol server.

One can then invoke the client CLI using that server IP address (10.11.51.247 in the above example):

Note that in the above example, ingress policy is not enforced for the Cassandra server endpoint, so no data will flow through the Cassandra parser. A simple ‘’allow all’’ L7 Cassandra policy can be used to send all data to the Cassandra server through the Go Cassandra parser. This policy has a single empty rule, which matches all requests. An allow all policy looks like:

A policy can be imported into cilium using cilium policy import, after which another call to cilium-dbg endpoint list confirms that ingress policy is now in place on the server. If the above policy was saved to a file cass-allow-all.json, one would run:

Note that policy is now showing as ‘’Enabled’’ for the Cassandra server on ingress.

To remove this or any other policy, run:

To install a new policy, first delete, and then run cilium policy import again. For example, the following policy would allow select statements on a specific set of tables to this Cassandra server, but deny all other queries.

When performing manual testing, remember that each time you change your Go proxy code, you must re-run make and sudo make install and then restart the cilium-agent process. If the only changes you have made since last compiling cilium are in your cilium/proxylib directory, you can safely just run make and sudo make install in that directory, which saves time. For example:

If you rebase or other files change, you need to run both commands from the top level directory.

Cilium agent default to running as a service in the development VM. However, the default options do not include the --debug-verbose=flow flag, which is critical to getting visibility in troubleshooting Go proxy frameworks. So it is easiest to stop the cilium service and run the cilium-agent directly as a command in a terminal window, and adding the --debug-verbose=flow flag.

Before submitting this change to the Cilium community, it is recommended that you add runtime tests that will run as part of Cilium’s continuous integration testing. Usually these runtime test can be based on the same container images and test commands you used for manual testing.

The best approach for adding runtime tests is typically to start out by copying-and-pasting an existing L7 protocol runtime test and then updating it to run the container images and CLI commands specific to the new protocol. See cilium/test/runtime/cassandra.go as an example that matches the use of Cassandra described above in the manual testing section. Note that the json policy files used by the runtime tests are stored in cilium/test/runtime/manifests, and the Cassandra example policies in those directories are easy to use as a based for similar policies you may create for your new protocol.

Many protocols have advanced features or corner cases that will not manifest themselves as part of basic testing. Once you have written a first rev of the parser, it is a good idea to go back and review the protocol’s spec or list of commands to see what if any aspects may fall outside the scope of your initial parser. For example, corner cases like the handling of empty or nil lists may not show up in your testing, but may cause your parser to fail. Add more unit tests to cover these corner cases. It is OK for the first rev of your parser not to handle all types of requests, or to have a simplified policy structure in terms of which fields can be matched. However, it is important to know what aspects of the protocol you are not parsing, and ensure that it does not lead to any security concerns. For example, failing to parse prepared statements in a database protocol and instead just passing PREPARE and EXECUTE commands through would lead to gaping security whole that would render your other filtering meaningless in the face of a sophisticated attacker.

At a minimum, the policy examples included as part of the runtime tests serve as basic documentation of the policy and its expected behavior. But we also encourage adding more user friendly examples and documentation, for example, Getting Started Guides. For a good example to follow, see GitHub issue 5661. Also be sure to update Documentation/security/index.rst with a link to this new getting started guide.

With that, you are ready to post this change for feedback from the Cilium community. Congrats!

---

## Service Affinity — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/clustermesh/affinity/

**Contents:**
- Service Affinity
- Prerequisites
- Enabling Global Service Affinity

This tutorial will guide you to enable service affinity across multiple Kubernetes clusters.

You need to have a functioning Cluster Mesh with a Global Service, please follow the guide Setting up Cluster Mesh and Load-balancing & Service Discovery to set it up.

Load-balancing across multiple clusters might not be ideal in some cases. The annotation service.cilium.io/affinity: "local|remote|none" can be used to specify the preferred endpoint destination.

For example, if the value of annotation service.cilium.io/affinity is local, the Global Service will load-balance across healthy local backends, and only user remote endpoints if and only if all of local backends are not available or unhealthy.

In cluster 1, add service.cilium.io/affinity="local" to existing global service

From cluster 1, access the global service:

You will see replies from pods in cluster 1 only.

From cluster 2, access the global service:

You will see replies from pods in both clusters as usual.

From cluster 1, check the service endpoints, the local endpoints are marked as preferred.

In cluster 1, change service.cilium.io/affinity value to remote for existing global service

From cluster 1, access the global service:

This time, the replies are coming from pods in cluster 2 only.

From cluster 1, check the service endpoints, now the remote endpoints are marked as preferred.

From cluster 2, access the global service:

You will see replies from pods in both clusters as usual.

In cluster 1, remove service.cilium.io/affinity annotation for existing global service

From either cluster, access the global service:

You will see replies from pods in both clusters again.

---

## Egress Gateway Advanced Troubleshooting — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/egress-gateway/egress-gateway-troubleshooting/

**Contents:**
- Egress Gateway Advanced Troubleshooting
- SNAT Connection Limits
- Example Scenario

This document explains various issues users may encounter using egress-gateway.

In use-cases where egress-gateway is being used to masquerade traffic to a small set of remote endpoints, it’s possible to cause issues by exceeding the max number of source IPs that can be allocated by Cilium’s NAT mapping per remote endpoint. This can cause issues with existing connections, as old connections are automatically evicted to accommodate new connections.

Imagine you have a Kubernetes cluster using Cilium’s egress-gateway with policy configured such that egress-IP 10.1.0.0 is used to masquerade external connections to a server on address 10.2.0.0:8080, which is behind a firewall.

The firewall only allows connections through that match the source IP 10.1.0.0. Many clients on the cluster will connect to the backend server via the same tuple of {egress-IP, remote endpoint IP, remote endpoint Port} => {10.1.0.0, 10.2.0.0, 8080}. These connections will have the same source IP and destination IP & port. In Cilium’s datapath, each connection to this destination will be mapped using a unique source port.

If too many connections are made through the egress-gateway node, Cilium’s SNAT map can reach capacity, which will result in old connections not being tracked, causing connectivity issues.

The limit is equal to the difference between max NAT node port value (65535) and the upper bound of --node-port-range (default: 32767). By default, an egress-gateway Node can handle 65535 - 32767 = 32768 possible connections to a common remote endpoint address, using the same egress IP.

High SNAT port mapping utilization can also result in egress-gateway connection failures as Cilium’s SNAT mapping fails to find available source ports for masquerade SNAT.

Cilium agent stores stats about the top 30 such connection tuples, this can be accessed inside a cilium agent container using the cilium-dbg utility.

Note: These stats are re-calculated every 30 seconds by default. So there is a delay between new connections occurring and when the stats are updated.

If you observe one or more row having a very large connection count (i.e. approaching the default connection limit: 32768), then this may indicate SNAT connection overflow issues.

Because this problem is a result of hitting a hard limit on Cilium’s Egress Gateway functionality, the only solution is to reduce the number of connections that are being SNATed through an egress-gateway, This can be done by having clients avoid creating as many new connections, or by lowering the amount of connections going to the same remote address (with a common egress IP) by splitting up traffic via different egress IPs and/or remote endpoint addresses.

For alerting and observability on SNAT source port utilization please see the NAT endpoint max connection metric which tracks the top saturation (as a percentage of total the max available) of a Cilium Agent.

---

## AWS ENI — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/concepts/ipam/eni/

**Contents:**
- AWS ENI
- Architecture
- Configuration
  - Custom ENI Configuration
    - Create a CNI configuration
    - Configure Cilium with subnet-tags-filter
  - ENI Allocation Parameters
- Operational Details
  - Cache of ENIs, Subnets, and VPCs
  - Publication of available ENI IPs

The AWS ENI allocator is specific to Cilium deployments running in the AWS cloud and performs IP allocation based on IPs of AWS Elastic Network Interfaces (ENI) by communicating with the AWS EC2 API.

The architecture ensures that only a single operator communicates with the EC2 service API to avoid rate-limiting issues in large clusters. A pre-allocation watermark is used to maintain a number of IP addresses to be available for use on nodes at all time without needing to contact the EC2 API when a new pod is scheduled in the cluster.

Note that Cilium currently does not support IPv6-only ENIs. Cilium support for IPv6 ENIs is being tracked in GitHub issue 18405, and the related feature of assigning IPv6 prefixes in GitHub issue 19251.

The AWS ENI allocator builds on top of the CRD-backed allocator. Each node creates a ciliumnodes.cilium.io custom resource matching the node name when Cilium starts up for the first time on that node. It contacts the EC2 metadata API to retrieve the instance ID, instance type, and VPC information, then it populates the custom resource with this information. ENI allocation parameters are provided as agent configuration option and are passed into the custom resource as well.

The Cilium operator listens for new ciliumnodes.cilium.io custom resources and starts managing the IPAM aspect automatically. It scans the EC2 instances for existing ENIs with associated IPs and makes them available via the spec.ipam.available field. It will then constantly monitor the used IP addresses in the status.ipam.used field and automatically create ENIs and allocate more IPs as needed to meet the IP pre-allocation watermark. This ensures that there are always IPs available.

The selection of subnets to use for allocation as well as attachment of security groups to new ENIs can be controlled separately for each node. This makes it possible to hand out pod IPs with differing security groups on individual nodes.

The corresponding datapath is described in section AWS ENI.

The Cilium agent and operator must be run with the option --ipam=eni or the option ipam: eni must be set in the ConfigMap. This will enable ENI allocation in both the node agent and operator.

In most scenarios, it makes sense to automatically create the ciliumnodes.cilium.io custom resource when the agent starts up on a node for the first time. To enable this, specify the option --auto-create-cilium-node-resource or set auto-create-cilium-node-resource: "true" in the ConfigMap.

If IPs are limited, run the Operator with option --aws-release-excess-ips=true. When enabled, operator checks the number of IPs regularly and attempts to release excess free IPs from ENI.

It is generally a good idea to enable metrics in the Operator as well with the option --enable-metrics. See the section Running Prometheus & Grafana for additional information how to install and run Prometheus including the Grafana dashboard.

By default, ENIs will be tagged with the cluster name, to allow Cilium Operator to garbage collect these ENIs if left dangling. The cluster name is either extracted from Cilium’s own cluster-name flag or from the aws:eks:cluster-name tag on the operator’s EC2 instance. If neither cluster names are available, a static default cluster name is assumed and ENI garbage collection will be performed across all such unnamed clusters. You may override this behavior by setting a cluster-specific --eni-gc-tags tag set.

Custom ENI configuration can be defined with a custom CNI configuration ConfigMap:

Create a cni-config.yaml file based on the template below. Fill in the subnet-tags field, assuming that the subnets in AWS have the tags applied to them:

Additional parameters may be configured in the eni or ipam section of the CNI configuration file. See the list of ENI allocation parameters below for a reference of the supported options.

Deploy the ConfigMap:

Using the instructions above to deploy Cilium and CNI config, specify the following additional arguments to Helm:

The following parameters are available to control the ENI creation and IP allocation:

The AWS EC2 instance type

This field is automatically populated when using ``–auto-create-cilium-node-resource``

The VPC identifier used to create ENIs and select AWS subnets for IP allocation.

This field is automatically populated when using ``–auto-create-cilium-node-resource``

The availability zone used to create ENIs and select AWS subnets for IP allocation.

This field is automatically populated when using ``–auto-create-cilium-node-resource``

The subnet ID of the first ENI of a node. Used as a fallback for subnet selection in the case where no subnet IDs or tags are configured.

This field is automatically populated when using ``–auto-create-cilium-node-resource``

The minimum number of IPs that must be allocated when the node is first bootstrapped. It defines the minimum base socket of addresses that must be available. After reaching this watermark, the PreAllocate and MaxAboveWatermark logic takes over to continue allocating IPs.

If unspecified, no minimum number of IPs is required.

The maximum number of IPs that can be allocated to the node. When the current amount of allocated IPs will approach this value, the considered value for PreAllocate will decrease down to 0 in order to not attempt to allocate more addresses than defined.

If unspecified, no maximum number of IPs will be enforced.

The number of IP addresses that must be available for allocation at all times. It defines the buffer of addresses available immediately without requiring for the operator to get involved.

If unspecified, this value defaults to 8.

The maximum number of addresses to allocate beyond the addresses needed to reach the PreAllocate watermark. Going above the watermark can help reduce the number of API calls to allocate IPs, e.g. when a new ENI is allocated, as many secondary IPs as possible are allocated. Limiting the amount can help reduce waste of IPs.

If let unspecified, the value defaults to 0.

The index of the first ENI to use for IP allocation, e.g. if the node has eth0, eth1, eth2 and FirstInterfaceIndex is set to 1, then only eth1 and eth2 will be used for IP allocation, eth0 will be ignored for PodIP allocation.

If unspecified, this value defaults to 0 which means that eth0 will be used for pod IPs.

The list tags which will be used to filter the security groups to attach to any ENI that is created and attached to the instance.

If unspecified, the security group ids passed in spec.eni.security-groups field will be used.

The list of security group ids to attach to any ENI that is created and attached to the instance.

If unspecified, the security group ids of eth0 will be used.

The subnet IDs used to select the AWS subnets for IP allocation. This is an additional requirement on top of requiring to match the availability zone and VPC of the instance. This parameter is mutually exclusive and has priority over spec.eni.subnet-tags.

If unspecified, it will let the operator pick any available subnet in the AZ with the most IP addresses available.

The tags used to select the AWS subnets for IP allocation. This is an additional requirement on top of requiring to match the availability zone and VPC of the instance.

If unspecified, no tags are required.

The tags used to exclude interfaces from IP allocation. Any ENI attached to a node which matches this set of tags will be ignored by Cilium and may be used for other purposes. This parameter can be used in combination with subnet-tags or first-interface-index to exclude additional interfaces.

If unspecified, no tags are used to exclude interfaces.

Remove the ENI when the instance is terminated

If unspecified, this option is enabled.

The operator maintains a list of all EC2 ENIs, VPCs and subnets associated with the AWS account in a cache. For this purpose, the operator performs the following three EC2 API operations:

DescribeNetworkInterfaces

The cache is updated once per minute or after an IP allocation or ENI creation has been performed. When triggered based on an allocation or creation, the operation is performed at most once per second.

Following the update of the cache, all CiliumNode custom resources representing nodes are updated to publish eventual new IPs that have become available.

In this process, all ENIs with an interface index greater than spec.eni.first-interface-index are scanned for all available IPs. All IPs found are added to spec.ipam.available. Each ENI meeting this criteria is also added to status.eni.enis.

If this update caused the custom resource to change, the custom resource is updated using the Kubernetes API methods Update() and/or UpdateStatus() if available.

The operator constantly monitors all nodes and detects deficits in available ENI IP addresses. The check to recognize a deficit is performed on two occasions:

When a CiliumNode custom resource is updated

All nodes are scanned in a regular interval (once per minute)

If --aws-release-excess-ips is enabled, the check to recognize IP excess is performed at the interval based scan.

When determining whether a node has a deficit in IP addresses, the following calculation is performed:

For excess IP calculation:

Upon detection of a deficit, the node is added to the list of nodes which require IP address allocation. When a deficit is detected using the interval based scan, the allocation order of nodes is determined based on the severity of the deficit, i.e. the node with the biggest deficit will be at the front of the allocation queue. Nodes that need to release IPs are behind nodes that need allocation.

The allocation queue is handled on demand but at most once per second.

When performing IP allocation for a node with an address deficit, the operator first looks at the ENIs which are already attached to the instance represented by the CiliumNode resource. All ENIs with an interface index greater than spec.eni.first-interface-index are considered for use.

In order to not use eth0 for IP allocation, set spec.eni.first-interface-index to 1 to skip the first interface in line.

The operator will then pick the first already allocated ENI which meets the following criteria:

The ENI has addresses associated which are not yet used or the number of addresses associated with the ENI is lesser than the instance type specific limit.

The subnet associated with the ENI has IPs available for allocation

The following formula is used to determine how many IPs are allocated on the ENI:

In scenarios where the pre-allocated number is lower than the number of pending pods on the node, the operator will pro-actively allocate more than the pre-allocated number of IPs to avoid having to wait for the next allocation cycles.

This means that the number of IPs allocated in a single allocation cycle can be less than what is required to fulfill spec.ipam.pre-allocate.

In order to allocate the IPs, the method AssignPrivateIpAddresses of the EC2 service API is called. When no more ENIs are available meeting the above criteria, a new ENI is created.

When performing IP release for a node with IP excess, the operator scans ENIs attached to the node with an interface index greater than spec.eni.first-interface-index and selects an ENI with the most free IPs available for release. The following formula is used to determine how many IPs are available for release on the ENI:

Operator releases IPs from the selected ENI, if there is still excess free IP not released, operator will attempt to release in next release cycle.

In order to release the IPs, the method UnassignPrivateIpAddresses of the EC2 service API is called. There is no limit on ENIs per subnet so ENIs are remained on the node.

As long as an instance type is capable allocating additional ENIs, ENIs are allocated automatically based on demand.

When allocating an ENI, the first operation performed is to identify the best subnet. This is done by searching through all subnets and finding a subnet that matches the following criteria:

The VPC ID of the subnet matches spec.eni.vpc-id

The Availability Zone of the subnet matches spec.eni.availability-zone

If set, spec.eni.subnet-ids or spec.eni.subnet-tags are used to further narrow down the set of candidate subnets. Any subnet with an ID in subnet-ids is a candidate, whereas a subnet must match all subnet-tags to be candidate. Note that when subnet-ids is set, subnet-tags are ignored. If multiple subnets match, the subnet with the most available addresses is selected.

If neither subnet-ids nor subnet-tags are set, the operator consults spec.eni.node-subnet-id, attempting to create the ENI in the same subnet as the primary ENI of the instance. If this is not possible (e.g. if there are not enough IPs in said subnet), the operator will look for the subnet in the same route table with the node’s subnet. If it’s not possible, falls back to allocating the IP in the largest subnet matching VPC and Availability Zone.

After selecting the subnet, operator will check selected subnets is in the same route table with the node’s subnet. It will generate the warning log if there is mismatch to prevent the unexpected routing behavior.

After selecting the subnet, the interface index is determined. For this purpose, all existing ENIs are scanned and the first unused index greater than spec.eni.first-interface-index is selected.

After determining the subnet and interface index, the ENI is created and attached to the EC2 instance using the methods CreateNetworkInterface and AttachNetworkInterface of the EC2 API.

The security group ids attached to the ENI are computed in the following order:

The field spec.eni.security-groups is consulted first. If this is set then these will be the security group ids attached to the newly created ENI.

The filed spec.eni.security-group-tags is consulted. If this is set then the operator will list all security groups in the account and will attach to the ENI the ones that match the list of tags passed.

Finally if none of the above fields are set then the newly created ENI will inherit the security group ids of eth0 of the machine.

The description will be in the following format:

If the ENI tagging feature is enabled then the ENI will be tagged with the provided information.

ENIs can be marked for deletion when the EC2 instance to which the ENI is attached to is terminated. In order to enable this, the option spec.eni.delete-on-termination can be enabled. If enabled, the ENI is modified after creation using ModifyNetworkInterfaceAttribute to specify this deletion policy.

When a node or instance terminates, the Kubernetes apiserver will send a node deletion event. This event will be picked up by the operator and the operator will delete the corresponding ciliumnodes.cilium.io custom resource.

The following EC2 privileges are required by the Cilium operator in order to perform ENI creation and IP allocation:

DeleteNetworkInterface

DescribeNetworkInterfaces

DescribeSecurityGroups

CreateNetworkInterface

AttachNetworkInterface

ModifyNetworkInterfaceAttribute

AssignPrivateIpAddresses

If ENI GC is enabled (which is the default), and --cluster-name and --eni-gc-tags are not set to custom values:

If release excess IP enabled:

UnassignPrivateIpAddresses

If --instance-tags-filter is used:

The EC2 Instance ENI limits is only fetched from the EC2 API dynamically from 1.18 onwards.

This requires the EC2 having DescribeInstanceTypes IAM permission, which is included in the EKS built-in policy AmazonEKSWorkerNodePolicy. you can find more details at AmazonEKSWorkerNodePolicy.

The IPAM metrics are documented in the section IPAM.

The IP address and routes on ENIs attached to the instance will be managed by the Cilium agent. Therefore, any system service trying to manage newly attached network interfaces will interfere with Cilium’s configuration. Common scenarios are NetworkManager or systemd-networkd automatically performing DHCP on these interfaces or removing Cilium’s IP address when the carrier is temporarily lost. Be sure to disable these services or configure your Linux distribution to not manage the newly attached ENI devices. The following examples configure all Linux network devices named eth* except eth0 as unmanaged.

---

## Concepts — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/kubernetes/concepts/

**Contents:**
- Concepts
- Deployment
- Networking For Existing Pods
- Default Ingress Allow from Local Host

The configuration of a standard Cilium Kubernetes deployment consists of several Kubernetes resources:

A DaemonSet resource: describes the Cilium pod that is deployed to each Kubernetes node. This pod runs the cilium-agent and associated daemons. The configuration of this DaemonSet includes the image tag indicating the exact version of the Cilium docker container (e.g., v1.0.0) and command-line options passed to the cilium-agent.

A ConfigMap resource: describes common configuration values that are passed to the cilium-agent, such as the kvstore endpoint and credentials, enabling/disabling debug mode, etc.

ServiceAccount, ClusterRole, and ClusterRoleBindings resources: the identity and permissions used by cilium-agent to access the Kubernetes API server when Kubernetes RBAC is enabled.

A Secret resource: describes the credentials used to access the etcd kvstore, if required.

In case pods were already running before the Cilium DaemonSet was deployed, these pods will still be connected using the previous networking plugin according to the CNI configuration. A typical example for this is the kube-dns service which runs in the kube-system namespace by default.

A simple way to change networking for such existing pods is to rely on the fact that Kubernetes automatically restarts pods in a Deployment if they are deleted, so we can simply delete the original kube-dns pod and the replacement pod started immediately after will have networking managed by Cilium. In a production deployment, this step could be performed as a rolling update of kube-dns pods to avoid downtime of the DNS service.

Running kubectl get pods will show you that Kubernetes started a new set of kube-dns pods while at the same time terminating the old pods:

Kubernetes has functionality to indicate to users the current health of their applications via Liveness Probes and Readiness Probes. In order for kubelet to run these health checks for each pod, by default, Cilium will always allow all ingress traffic from the local host to each pod.

---

## L7 Path Translation — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/envoy-custom-listener/

**Contents:**
- L7 Path Translation
- Apply Example CRD
- Test the Listener Port
- Clean-up

This example replicates the Prometheus metrics listener which is already available via the command line option --proxy-prometheus-port. So the point of this example is not to add new functionality, but to show how a feature that previously required Cilium Agent code changes can be implemented with the new Cilium Envoy Config CRD.

This example adds a new Envoy listener envoy-prometheus-metrics-listener on the standard Prometheus port (e.g. 9090) to each Cilium node, translating the default Prometheus metrics path /metrics to Envoy’s Prometheus metrics path /stats/prometheus.

Apply this Cilium Envoy Config CRD:

This version of the CiliumClusterwideEnvoyConfig CRD is Cluster-scoped, (i.e., not namespaced), so the name needs to be unique in the cluster, unless you want to replace a CRD with a new one.

Note that these Envoy resources are not validated by K8s at all, so any errors in the Envoy resources will only be seen by the Cilium Agent observing these CRDs. This means that kubectl apply will report success, while parsing and/or installing the resources for the node-local Envoy instance may have failed. Currently the only way of verifying this is by observing Cilium Agent logs for errors and warnings. Additionally, Cilium Agent will print warning logs for any conflicting Envoy resources in the cluster.

Note that Cilium Ingress Controller will configure required Envoy resource under the hood. Please check Cilium Agent logs if you are creating Envoy resources explicitly to make sure there is no conflict.

Test that the new port is responding to the metrics requests:

Where <node-IP> is the IP address of one of your k8s cluster nodes.

Remove the prometheus listener with:

---

## IP Address Management (IPAM) — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/concepts/ipam/

**Contents:**
- IP Address Management (IPAM)

IP Address Management (IPAM) is responsible for the allocation and management of IP addresses used by network endpoints (container and others) managed by Cilium. Various IPAM modes are supported to meet the needs of different users:

Kubernetes Host Scope

Cluster Scope (default)

Multiple CIDRs per cluster

Multiple CIDRs per node

Dynamic CIDR/IP allocation

Don’t change the IPAM mode of an existing cluster. Changing the IPAM mode in a live environment may cause persistent disruption of connectivity for existing workloads. The safest path to change IPAM mode is to install a fresh Kubernetes cluster with the new IPAM configuration. If you are interested in extending Cilium to support migration between IPAM modes, see GitHub issue 27164.

---

## eBPF Maps — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/ebpf/maps/

**Contents:**
- eBPF Maps
- Service LB Map Sizing

All BPF maps are created with upper capacity limits. Insertion beyond the limit will fail and thus limits the scalability of the datapath. The following table shows the default values of the maps. Each limit can be bumped in the source code. Configuration options will be added on request if demand arises.

Max 512k authenticated relations per node

Max 1M concurrent TCP connections, max 256k expected UDP answers

Max 512k neighbor entries

Max 64k local endpoints + host IPs per node

Max 256k endpoints (IPv4+IPv6), max 512k endpoints (IPv4 or IPv6) across all clusters

Service Load Balancer

Max ~3k clusterIP/nodePort Services across all clusters (see: service map sizing section for details).

Max 64k cumulative unique backends across all services across all clusters

Max 16k allowed identity + port + protocol pairs for specific endpoint

Max 512k concurrent redirected TCP connections to proxy

Max 32k nodes (IPv4+IPv6) or 64k nodes (IPv4 or IPv6) across all clusters

Max 8k fragmented datagrams in flight simultaneously on the node

Max 64k affinities from different clients

Max 16k IPv4 cidrs used by BPF-based ip-masq-agent

Max 16k IPv6 cidrs used by BPF-based ip-masq-agent

Service Source Ranges

Max 64k cumulative LB source ranges across all services

Max 16k endpoints across all destination CIDRs across all clusters

Max 16k distinct node IPs (IPv4 & IPv6) across all clusters.

For some BPF maps, the upper capacity limit can be overridden using command line options for cilium-agent. A given capacity can be set using --bpf-auth-map-max, --bpf-ct-global-tcp-max, --bpf-ct-global-any-max, --bpf-nat-global-max, --bpf-neigh-global-max, --bpf-policy-map-max, --bpf-fragments-map-max and --bpf-lb-map-max.

In case the --bpf-ct-global-tcp-max and/or --bpf-ct-global-any-max are specified, the NAT table size (--bpf-nat-global-max) must not exceed 2/3 of the combined CT table size (TCP + UDP). This will automatically be set if either --bpf-nat-global-max is not explicitly set or if dynamic BPF map sizing is used (see below).

Using the --bpf-map-dynamic-size-ratio flag, the upper capacity limits of several large BPF maps are determined at agent startup based on the given ratio of the total system memory. For example, a given ratio of 0.0025 leads to 0.25% of the total system memory to be used for these maps.

This flag affects the following BPF maps that consume most memory in the system: cilium_ct_{4,6}_global, cilium_ct_{4,6}_any, cilium_nodeport_neigh{4,6}, cilium_snat_v{4,6}_external and cilium_lb{4,6}_reverse_sk.

kube-proxy sets as the maximum number entries in the linux’s connection tracking table based on the number of cores the machine has. kube-proxy has a default of 32768 maximum entries per core with a minimum of 131072 entries regardless of the number of cores the machine has.

Cilium has its own connection tracking tables as BPF Maps and the number of entries of such maps is calculated based on the amount of total memory in the node with a minimum of 131072 entries regardless the amount of memory the machine has.

The following table presents the value that kube-proxy and Cilium sets for their own connection tracking tables when Cilium is configured with --bpf-map-dynamic-size-ratio: 0.0025.

Kube-proxy CT entries

Cilium uses the LB services maps named cilium_lb{4,6}_services_v2 to hold Service load balancer entries for clusterIP and nodePort service types. These maps are configured via the --bpf-lb-map-max flag and are set to 64k by default. If this map is full, Cilium may be unable to reconcile Service updates which may affect connectivity to service IPs or the ability to create new services.

The required size of service LB maps depends on multiple factors. Each clusterIP/nodePort service will create a number of entries equal to the number of Pods backends selected by the service, times the number of port/protocol entries in the respective Service spec.

\(\text{LB map entries per Service} = (\text{number of endpoints per service}) * (\text{number of port/protocols per service})\)

Using this, we can roughly the required map size as:

\(\text{LB map entries} \approx (\text{number of LB services}) * (\text{avg number of endpoints per service}) * (\text{avg number of port/protocols per service})\)

This heuristic assumes that number of selected Pods and ports/protocol entries per service are roughly normally distributed. If your use case has large outliers (ex. such as a service that selects a very large set of Pod backends) it may be necessary to do a more detailed estimate.

Once Cilium has created the service LB maps for a Node (i.e. upon first running Cilium agent on a Node), attempting to resize the map size parameter and restarting Cilium results in connection disruptions as the new map is repopulated with existing service entries. Therefore it is important to carefully consider map requirements prior to installing Cilium if such disruptions are a concern.

---

## Gateway API Support — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/gateway-api/

**Contents:**
- Gateway API Support
- What is Gateway API?
- Cilium Gateway API Support
- Prerequisites
- Installation
- Reference
  - How Cilium Ingress and Gateway API differ from other Ingress controllers
  - Cilium’s ingress config and CiliumNetworkPolicy
  - Source IP Visibility
    - externalTrafficPolicy for Loadbalancer or NodePort Services

Gateway API is a Kubernetes SIG-Network subproject to design a successor for the Ingress object. It is a set of resources that model service networking in Kubernetes, and is designed to be role-oriented, portable, expressive, and extensible.

See the Gateway API site for more details.

Cilium supports Gateway API v1.2.0 for below resources, all the Core conformance tests are passed.

TLSRoute (experimental)

Additionally, Cilium provides CiliumGatewayClassConfig CRD, which can be referenced in GatewayClass.parametersRef.

If you’d like more insights on Cilium’s Gateway API support, check out eCHO episode 58: Cilium Service Mesh and Ingress.

Cilium must be configured with NodePort enabled, using nodePort.enabled=true or by enabling the kube-proxy replacement with kubeProxyReplacement=true. For more information, see kube-proxy replacement.

Cilium must be configured with the L7 proxy enabled using l7Proxy=true (enabled by default).

The below CRDs from Gateway API v1.2.0 must be pre-installed. Please refer to this docs for installation steps. Alternatively, the below snippet could be used.

If you wish to use the TLSRoute functionality, you’ll also need to install the TLSRoute resource. If this CRD is not installed, then Cilium will disable TLSRoute support.

TLSRoute (experimental)

You can install the required CRDs like this:

By default, the Gateway API controller creates a service of LoadBalancer type, so your environment will need to support this. Alternatively, since Cilium 1.16+, you can directly expose the Cilium L7 proxy on the host network.

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

Cilium Gateway API Controller can be enabled with helm flag gatewayAPI.enabled set as true. Please refer to Installation using Helm for a fresh installation.

Next you can check the status of the Cilium agent and operator:

Cilium Gateway API Controller can be enabled with the below command

Next you can check the status of the Cilium agent and operator:

One of the biggest differences between Cilium’s Ingress and Gateway API support and other Ingress controllers is how closely tied the implementation is to the CNI. For Cilium, Ingress and Gateway API are part of the networking stack, and so behave in a different way to other Ingress or Gateway API controllers (even other Ingress or Gateway API controllers running in a Cilium cluster).

Other Ingress or Gateway API controllers are generally installed as a Deployment or Daemonset in the cluster, and exposed via a Loadbalancer Service or similar (which Cilium can, of course, enable).

Cilium’s Ingress and Gateway API config is exposed with a Loadbalancer or NodePort service, or optionally can be exposed on the Host network also. But in all of these cases, when traffic arrives at the Service’s port, eBPF code intercepts the traffic and transparently forwards it to Envoy (using the TPROXY kernel facility).

This affects things like client IP visibility, which works differently for Cilium’s Ingress and Gateway API support to other Ingress controllers.

It also allows Cilium’s Network Policy engine to apply CiliumNetworkPolicy to traffic bound for and traffic coming from an Ingress.

Ingress and Gateway API traffic bound to backend services via Cilium passes through a per-node Envoy proxy.

The per-node Envoy proxy has special code that allows it to interact with the eBPF policy engine, and do policy lookups on traffic. This allows Envoy to be a Network Policy enforcement point, both for Ingress (and Gateway API) traffic, and also for east-west traffic via GAMMA or L7 Traffic Management.

However, for ingress config, there’s also an additional step. Traffic that arrives at Envoy for Ingress or Gateway API is assigned the special ingress identity in Cilium’s Policy engine.

Traffic coming from outside the cluster is usually assigned the world identity (unless there are IP CIDR policies in the cluster). This means that there are actually two logical Policy enforcement points in Cilium Ingress - before traffic arrives at the ingress identity, and after, when it is about to exit the per-node Envoy.

This means that, when applying Network Policy to a cluster, it’s important to ensure that both steps are allowed, and that traffic is allowed from world to ingress, and from ingress to identities in the cluster (like the productpage identity in the image above).

Please see the Ingress and Network Policy Example for more details for Ingress, although the same principles also apply for Gateway API.

By default, source IP visibility for Cilium ingress config, both Ingress and Gateway API, should just work on most installations. Read this section for more information on requirements and relevant settings.

Having a backend be able to deduce what IP address the actual request came from is important for most applications.

By default, Cilium’s Envoy instances are configured to append the visible source address of incoming HTTP connections to the X-Forwarded-For header, using the usual rules. That is, by default Cilium sets the number of trusted hops to 0, indicating that Envoy should use the address the connection is opened from, rather than a value inside the X-Forwarded-For list. Increasing this count will have Envoy use the n th value from the list, counting from the right.

Envoy will also set the X-Envoy-External-Address header to the trusted client address, whatever that turns out to be, based on X-Forwarded-For.

Backends using Cilium ingress (whether via Ingress or Gateway API) should just see the X-Forwarded-For and X-Envoy-External-Address headers (which are handled transparently by many HTTP libraries).

Cilium’s ingress support (both for Ingress and Gateway API) often uses a Loadbalancer or NodePort Service to expose the Envoy Daemonset.

In these cases, the Service object has one field that is particularly relevant to Client IP visibility - the externalTrafficPolicy field.

It has two relevant settings:

Local: Nodes will only route traffic to Pods running on the local node, without masquerading the source IP. Because of this, in clusters that use kube-proxy, this is the only way to ensure source IP visibility. Part of the contract for externalTrafficPolicy local is also that the node will open a port (the healthCheckNodePort, automatically set by Kubernetes when externalTrafficPolicy: Local is set), and requests to http://<nodeIP>:<healthCheckNodePort>/healthz will return 200 on nodes that have local pods running, and non-200 on nodes that don’t. Cilium implements this for general Loadbalancer Services, but it’s a bit different for Cilium ingress config (both Ingress and Gateway API).

Cluster: Node will route to all endpoints across the cluster evenly. This has a couple of other effects: Firstly, upstream loadbalancers will expect to be able to send traffic to any node and have it end up at a backend Pod, and the node may masquerade the source IP. This means that in many cases, externalTrafficPolicy: Cluster may mean that the backend pod does not see the source IP.

In Cilium’s case, all ingress traffic bound for a Service that exposes Envoy is always going to the local node, and is always forwarded to Envoy using the Linux Kernel TPROXY function, which transparently forwards packets to the backend.

This means that for Cilium ingress config, for both Ingress and Gateway API, things work a little differently in both externalTrafficPolicy cases.

In both externalTrafficPolicy cases, traffic will arrive at any node in the cluster, and be forwarded to Envoy while keeping the source IP intact.

Also, for any Services that exposes Cilium’s Envoy, Cilium will ensure that when externalTrafficPolicy: Local is set, every node in the cluster will pass the healthCheckNodePort check, so that external load balancers will forward correctly.

However, for Cilium’s ingress config, both Ingress and Gateway API, it is not necessary to configure externalTrafficPolicy: Local to keep the source IP visible to the backend pod (via the X-Forwarded-For and X-Envoy-External-Address fields).

Both Ingress and Gateway API support TLS Passthrough configuration (via annotation for Ingress, and the TLSRoute resource for Gateway API). This configuration allows multiple TLS Passthrough backends to share the same TLS port on a loadbalancer, with Envoy inspecting the Server Name Indicator (SNI) field of the TLS handshake, and using that to forward the TLS stream to a backend.

However, this poses problems for source IP visibility, because Envoy is doing a TCP Proxy of the TLS stream.

What happens is that the TLS traffic arrives at Envoy, terminating a TCP stream, Envoy inspects the client hello to find the SNI, picks a backend to forward to, then starts a new TCP stream and forwards the TLS traffic inside the downstream (outside) packets to the upstream (the backend).

Because it’s a new TCP stream, as far as the backends are concerned, the source IP is Envoy (which is often the Node IP, depending on your Cilium config).

When doing TLS Passthrough, backends will see Cilium Envoy’s IP address as the source of the forwarded TLS streams.

Supported since Cilium 1.16+

Host network mode allows you to expose the Cilium Gateway API Gateway directly on the host network. This is useful in cases where a LoadBalancer Service is unavailable, such as in development environments or environments with cluster-external loadbalancers.

Enabling the Cilium Gateway API host network mode automatically disables the LoadBalancer type Service mode. They are mutually exclusive.

The listener is exposed on all interfaces (0.0.0.0 for IPv4 and/or :: for IPv6).

Host network mode can be enabled via Helm:

Once enabled, the host network port for a Gateway can be specified via spec.listeners.port. The port must be unique per Gateway resource and you should choose a port number higher than 1023 (see Bind to privileged port).

Be aware that misconfiguration might result in port clashes. Configure unique ports that are still available on all Cilium Nodes where Gateway API listeners are exposed.

By default, the Cilium L7 Envoy process does not have any Linux capabilities out-of-the-box and is therefore not allowed to listen on privileged ports.

If you choose a port equal to or lower than 1023, ensure that the Helm value envoy.securityContext.capabilities.keepCapNetBindService=true is configured and to add the capability NET_BIND_SERVICE to the respective Cilium Envoy container via Helm values:

Standalone DaemonSet mode: envoy.securityContext.capabilities.envoy

Embedded mode: securityContext.capabilities.ciliumAgent

Configure the following Helm values to allow privileged port bindings in host network mode:

The Cilium Gateway API Envoy listener can be exposed on a specific subset of nodes. This only works in combination with the host network mode and can be configured via a node label selector in the Helm values:

This will deploy the Gateway API Envoy listener only on the Cilium Nodes matching the configured labels. An empty selector selects all nodes and continues to expose the functionality on all Cilium nodes.

Cilium Gateway supports Addresses provided by the Gateway API specification. The spec.addresses field is used to specify the IP address of the gateway.

The feature only supports IPAddress type of addresses, and works with the LB-IPAM. Please see LoadBalancer IP Address Management (LB IPAM) for more information.

The output of the above configuration will be:

If you are already using the io.cilium/lb-ipam-ips in the spec.infrastructure.annotations to specify the IP, the spec.addresses field will be ignored.

The output of the above configuration will be:

At a future date the use of the io.cilium/lb-ipam-ips will be deprecated, and then after that, this annotation will be ignored if no spec.addresses are set. In both cases, warning logs will be added to the Cilium agent logs, and a warning Condition will be placed on the Gateway.

Please refer to one of the below examples on how to use and leverage Cilium’s Gateway API features:

More examples can be found in the upstream repository.

This page guides you through the different mechanics of Gateway API and how to troubleshoot them.

Be sure to follow the Generic and Setup Verification steps from the Troubleshooting Ingress & Service Mesh page.

Check the Gateway resource

The preceding command returns an overview of all the Gateways in the cluster. Check the following:

Is the Gateway programmed?

A programmed Gateway means that Cilium prepared a configuration for it.

If the Programmed true indicator is missing, make sure that Gateway API is enabled in the Cilium configuration.

Does the gateway have an address?

You can check the service with kubectl get service. If the gateway has an address, it means that a LoadBalancer service is assigned to the gateway. If no IP appears, you might be missing a LoadBalancer implementation.

Cilium only programs Gateways with the class cilium.

If the Gateway API resource type (Gateway, HTTPRoute, etc.) is not found, make sure that the Gateway API CRDs are installed.

You can use kubectl describe gateway to investigate issues more thoroughly.

You can see the general status of the gateway as well as the status of the configured listeners.

Listener status displays the number of routes successfully attached to the listener.

You can see status conditions for both gateway and listener:

Accepted: the Gateway configuration was accepted.

Programmed: the Gateway configuration was programmed into Envoy.

ResolvedRefs: all referenced secrets were found and have permission for use.

If any of these conditions are set to false, the Message and Reason fields give more information.

Check the HTTPRoute resource

When the Gateway is functional, you can check the routes to verify if they are configured correctly. The way to check route status is similar to checking the status of a gateway resource.

While these instructions are written for HTTPRoute, they also apply to other route types.

To get more information, enter kubectl describe httproute <name>.

Status lists the conditions that are relevant for the specific HTTPRoute. Conditions are listed by parent reference to the gateway. If you linked the route to multiple gateways, multiple entries appear. Conditions include Reason, Type, Status and Message. Type indicates the condition type, and Status indicates with a boolean whether the condition type is met. Optionally, Message gives you more information about the condition.

Notice the following condition types:

Accepted: The HTTPRoute configuration was correct and accepted.

ResolvedRefs: The referenced services were found and are valid references.

If any of these are set to false, you can get more information by looking at the Message and Reason fields.

Check Cilium Operator logs

The Cilium Operator logs may contain further debugging information. For example, if the required Custom Resource Definitions (CRDs) are not installed, an error will be logged:

Gateway API is a recent addition to Kubernetes, and the Cilium project has not yet received much user feedback. If you encounter an issue that is not yet listed in this section, consider opening a PR to add your issue to the list.

The backend service does not exist.

To verify whether the backend service was found, run kubectl describe httproute <name> and inspect the conditions field:

The gateway specified under parentRefs does not exist.

To verify whether the gateway was found, run kubectl describe httproute <name> and inspect the conditions field:

A Cilium deployment has two parts that handle Gateway API resources: the Cilium agent and the Cilium operator.

The Cilium operator watches all Gateway API resources and verifies whether the resources are valid. If resources are valid, the operator marks them as accepted. That starts the process of translation into Cilium Envoy Configuration resources.

The Cilium agent then picks up the Cilium Envoy Configuration resources.

The Cilium agent uses the resources to supply the configuration to the built in Envoy or the Envoy DaemonSet. Envoy handles traffic.

---

## Cluster Scope (Default) — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/concepts/ipam/cluster-pool/

**Contents:**
- Cluster Scope (Default)
- Architecture
- Configuration
  - Expanding the cluster pool
- Troubleshooting
  - Look for allocation errors
  - Check for conflicting node CIDRs

The cluster-scope IPAM mode assigns per-node PodCIDRs to each node and allocates IPs using a host-scope allocator on each node. It is thus similar to the Kubernetes Host Scope mode. The difference is that instead of Kubernetes assigning the per-node PodCIDRs via the Kubernetes v1.Node resource, the Cilium operator will manage the per-node PodCIDRs via the v2.CiliumNode resource. The advantage of this mode is that it does not depend on Kubernetes being configured to hand out per-node PodCIDRs.

This is useful if Kubernetes cannot be configured to hand out PodCIDRs or if more control is needed.

In this mode, the Cilium agent will wait on startup until the podCIDRs range are made available via the Cilium Node v2.CiliumNode object for all enabled address families via the resource field set in the v2.CiliumNode:

IPv4 and/or IPv6 PodCIDR range

For a practical tutorial on how to enable this mode in Cilium, see CRD-Backed by Cilium Cluster-Pool IPAM.

Don’t change any existing elements of the clusterPoolIPv4PodCIDRList list, as changes cause unexpected behavior. If the pool is exhausted, add a new element to the list instead. The minimum mask length is /30, with a recommended minimum mask length of at least /29. The reason to add new elements rather than change existing elements is that the allocator reserves 2 IPs per CIDR block for the network and broadcast addresses. Changing clusterPoolIPv4MaskSize is also not possible.

Check the Error field in the status.ipam.operator-status field:

10.0.0.0/8 is the default pod CIDR. If your node network is in the same range you will lose connectivity to other nodes. All egress traffic will be assumed to target pods on a given node rather than other nodes.

You can solve it in two ways:

Explicitly set clusterPoolIPv4PodCIDRList to a non-conflicting CIDR

Use a different CIDR for your nodes

---

## Traffic Splitting Example — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/splitting/

**Contents:**
- Traffic Splitting Example
- Deploy the Echo App
- Deploy the Cilium Gateway
- Even traffic split
- Uneven (99/1) traffic split

HTTP traffic splitting is the process of sending incoming traffic to multiple backend services, based on predefined weights or other criteria. The Cilium Gateway API includes built-in support for traffic splitting, allowing users to easily distribute incoming traffic across multiple backend services. This is very useful for canary testing or A/B scenarios.

This particular example uses the Gateway API to load balance incoming traffic to different backends, starting with the same weights before testing with a 99/1 weight distribution.

We will use a deployment made of echo servers.

The application will reply to the client and, in the body of the reply, will include information about the Pod and Node receiving the original request. We will use this information to illustrate how the traffic is manipulated by the Gateway.

Verify the Pods are running as expected.

You can find an example Gateway and HTTPRoute definition in splitting.yaml:

Notice the even 50/50 split between the two Services.

Deploy the Gateway and the HTTPRoute:

The preceding example creates a Gateway named cilium-gw that listens on port 80. A single route is defined and includes two different backendRefs (echo-1 and echo-2) and weights associated with them.

Some providers like EKS use a fully-qualified domain name rather than an IP address.

Now that the Gateway is ready, you can make HTTP requests to the services.

Notice that the reply includes the name of the Pod that received the query. For example:

Repeat the command several times. You should see the reply balanced evenly across both Pods and Nodes. Verify that traffic is evenly split across multiple Pods by running a loop and counting the requests:

Stop the loop with Ctrl+C. Verify that the responses are more or less evenly distributed.

Update the HTTPRoute weights, either by using kubectl edit httproute or by updating the value in the original manifest before reapplying it to. For example, set 99 for echo-1 and 1 for echo-2:

Verify that traffic is unevenly split across multiple Pods by running a loop and counting the requests:

Stop the loop with Ctrl+C. Verify that responses are more or less evenly distributed.

---

## Egress Gateway — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/egress-gateway/egress-gateway/

**Contents:**
- Egress Gateway
- Preliminary Considerations
  - Delay for enforcement of egress policies on new pods
  - Incompatibility with other features
- Enable egress gateway
- Writing egress gateway policies
  - Metadata
  - Selecting source pods
  - Selecting the destination
  - Selecting and configuring the gateway node

The egress gateway feature routes all IPv4 and IPv6 connections originating from pods and destined to specific cluster-external CIDRs through particular nodes, from now on called “gateway nodes”.

When the egress gateway feature is enabled and egress gateway policies are in place, matching packets that leave the cluster are masqueraded with selected, predictable IPs associated with the gateway nodes. As an example, this feature can be used in combination with legacy firewalls to allow traffic to legacy infrastructure only from specific pods within a given namespace. The pods typically have ever-changing IP addresses, and even if masquerading was to be used as a way to mitigate this, the IP addresses of nodes can also change frequently over time.

This document explains how to enable the egress gateway feature and how to configure egress gateway policies to route and SNAT the egress traffic for a specific workload.

This guide assumes that Cilium has been correctly installed in your Kubernetes cluster. Please see Cilium Quick Installation for more information. If unsure, run cilium status and validate that Cilium is up and running.

For more insights on Cilium’s Egress Gateway, check out eCHO episode 76: Cilium Egress Gateway.

Cilium must make use of network-facing interfaces and IP addresses present on the designated gateway nodes. These interfaces and IP addresses must be provisioned and configured by the operator based on their networking environment. The process is highly-dependent on said networking environment. For example, in AWS/EKS, and depending on the requirements, this may mean creating one or more Elastic Network Interfaces with one or more IP addresses and attaching them to instances that serve as gateway nodes so that AWS can adequately route traffic flowing from and to the instances. Other cloud providers have similar networking requirements and constructs.

Additionally, the enablement of the egress gateway feature requires that both BPF masquerading and the kube-proxy replacement are enabled.

When new pods are started, there is a delay before egress gateway policies are applied for those pods. That means traffic from those pods may leave the cluster with a source IP address (pod IP or node IP) that doesn’t match the egress gateway IP. That egressing traffic will also not be redirected through the gateway node.

Because egress gateway isn’t compatible with identity allocation mode kvstore, you must use Kubernetes as Cilium’s identity store (identityAllocationMode set to crd). This is the default setting for new installations.

Egress gateway is not compatible with the Cluster Mesh feature. The gateway selected by an egress gateway policy must be in the same cluster as the selected pods.

Egress gateway is not compatible with the CiliumEndpointSlice feature (see GitHub issue 24833 for details).

The egress gateway feature and all the requirements can be enabled as follow:

Rollout both the agent pods and the operator pods to make the changes effective:

The API provided by Cilium to drive the egress gateway feature is the CiliumEgressGatewayPolicy resource.

CiliumEgressGatewayPolicy is a cluster-scoped custom resource definition, so a .metadata.namespace field should not be specified.

To target pods belonging to a given namespace only labels/expressions should be used instead (as described below).

The selectors field of a CiliumEgressGatewayPolicy resource is used to select source pods via a label selector. This can be done using matchLabels:

It can also be done using matchExpressions:

Moreover, multiple podSelector can be specified:

To select pods belonging to a given namespace, the special io.kubernetes.pod.namespace label should be used.

To only select pods on certain nodes, you can use the nodeSelector:

Only security identities will be taken into account. See Limiting Identity-Relevant Labels for more information. nodeSelector cannot be used alone, it must be used together with podSelector.

One or more destination CIDRs can be specified with destinationCIDRs:

Any IP belonging to these ranges which is also an internal cluster IP (e.g. pods, nodes, Kubernetes API server) will be excluded from the egress gateway SNAT logic.

It’s possible to specify exceptions to the destinationCIDRs list with excludedCIDRs:

In this case traffic destined to the a.b.0.0/16 CIDR, except for the a.b.c.0/24 destination, will go through egress gateway and leave the cluster with the designated egress IP.

The node that should act as gateway node for a given policy can be configured with the egressGateway field. The node is matched based on its labels, with the nodeSelector field:

In case multiple nodes are a match for the given set of labels, the first node in lexical ordering based on their name will be selected.

If there is no match for the given set of labels, Cilium drops the traffic that matches the destination CIDR(s).

The IP address that should be used to SNAT traffic must also be configured. There are 3 different ways this can be achieved:

By specifying the interface:

In this case the first IPv4 and IPv6 addresses assigned to the ethX interface will be used.

By explicitly specifying the egress IP:

The egress IP must be assigned to a network device on the node.

By omitting both egressIP and interface properties, which will make the agent use the first IPv4 and IPv6 addresses assigned to the interface for the default route.

Regardless of which way the egress IP is configured, the user must ensure that Cilium is running on the device that has the egress IP assigned to it, by setting the --devices agent option accordingly.

The egressIP and interface properties cannot both be specified in the egressGateway spec. Egress Gateway Policies that contain both of these properties will be ignored by Cilium.

When Cilium is unable to select the Egress IP for an Egress Gateway policy (for example because the specified egressIP is not configured for any network interface on the gateway node), then the gateway node will drop traffic that matches the policy with the reason No Egress IP configured.

After Cilium has selected the Egress IP for an Egress Gateway policy (or failed to do so), it does not automatically respond to a change in the gateway node’s network configuration (for example if an IP address is added or deleted). You can force a fresh selection by re-applying the Egress Gateway policy.

It’s possible to select multiple gateway nodes in the same policy. In this case, the gateway nodes can be configured using the egressGateways list field. Entries on this list have the exact same configuration options as the egressGateway field:

The same restrictions as with the egressGateway field apply to each item of the egressGateways list.

When using multiple gateways the source endpoints matched by the policy will still egress traffic through a single gateway, not all of them. The endpoints will be assigned to a gateway based on its CiliumEndpoint’s UID. Hence, an endpoint should use the same gateway during its lifetime as long as the gateway nodes matched by the nodeSelector fields don’t change. If a nodeSelector field is added, removed, or modified, or if a node matching one of the nodeSelector fields is added or removed, the list of gateways will change and the endpoints will be reassigned.

As with single-gateway policies, changing the gateway node will break existing egress connections. Please read the following GitHub issue 39245 which tracks this issue.

Below is an example of a CiliumEgressGatewayPolicy resource that conforms to the specification above:

Creating the CiliumEgressGatewayPolicy resource above would cause all traffic originating from pods with the org: empire and class: mediabot labels in the default namespace on node node1 and destined to 0.0.0.0/0 or ::/0 (i.e. all traffic leaving the cluster) to be routed through the gateway node with the node.kubernetes.io/name: node2 label, which will then SNAT said traffic with the 10.168.60.100 egress IP.

For gateway nodes with multiple network interfaces, Cilium selects the egress network interface based on the node’s routing setup (ip route get <externalIP> from <egressIP>).

In this section we are going to show the necessary steps to test the feature. First we deploy a pod that connects to a cluster-external service. Then we apply a CiliumEgressGatewayPolicy and observe that the pod’s connection gets redirected through the Gateway node. We assume a 2-node cluster with IPs 192.168.60.11 (node1) and 192.168.60.12 (node2). The client pod gets deployed to node1, and the CEGP selects node2 as Gateway node.

If you don’t have an external service to experiment with, you can use Nginx, as the server access logs will show from which IP address the request is coming.

Create an nginx service on a Linux node that is external to the existing Kubernetes cluster, and use it as the destination of the egress traffic:

In this example, the IP associated with the host running the Nginx instance will be 192.168.60.13.

Deploy a client pod that will be used to connect to the Nginx instance:

Verify from the Nginx access log (or other external services) that the request is coming from one of the nodes in the Kubernetes cluster. In this example the access logs should contain something like:

since the client pod is running on the node 192.168.60.11 it is expected that, without any Cilium egress gateway policy in place, traffic will leave the cluster with the IP of the node.

Download the egress-sample Egress Gateway Policy yaml:

Modify the destinationCIDRs to include the IP of the host where your designated external service is running on.

Specifying an IP address in the egressIP field is optional. To make things easier in this example, it is possible to comment out that line. This way, the agent will use the first IPv4 and IPv6 addresses assigned to the interface for the default route.

To let the policy select the node designated to be the Egress Gateway, apply the label egress-node: true to it:

Note that the Egress Gateway node should be a different node from the one where the mediabot pod is running on.

Apply the egress-sample egress gateway Policy, which will cause all traffic from the mediabot pod to leave the cluster with the IP of the Egress Gateway node:

We can now verify with the client pod that the policy is working correctly:

The access log from Nginx should show that the request is coming from the selected Egress IP rather than the one of the node where the pod is running:

To troubleshoot a policy that is not behaving as expected, you can view the egress configuration in a cilium agent (the configuration is propagated to all agents, so it shouldn’t matter which one you pick).

The Source IP address matches the IP address of each pod that matches the policy’s podSelector. The Gateway IP address matches the (internal) IP address of the egress node that matches the policy’s nodeSelector. The Egress IP is 0.0.0.0 on all agents except for the one running on the egress gateway node, where you should see the Egress IP address being used for this traffic (which will be the egressIP from the policy, if specified).

If the egress list shown does not contain entries as expected to match your policy, check that the pod(s) and egress node are labeled correctly to match the policy selectors.

For more advanced troubleshooting topics please see advanced egress gateway troubleshooting topic for SNAT connection limits.

---

## Overview of Network Security — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/network/

**Contents:**
- Overview of Network Security

---

## Masquerading — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/concepts/masquerading/

**Contents:**
- Masquerading
- Configuration
- Implementation Modes
  - eBPF-based
  - iptables-based

IPv4 addresses used for pods are typically allocated from RFC1918 private address blocks and thus, not publicly routable. Cilium will automatically masquerade the source IP address of all traffic that is leaving the cluster to the IPv4 address of the node as the node’s IP address is already routable on the network.

This behavior can be disabled with the option enable-ipv4-masquerade: false for IPv4 and enable-ipv6-masquerade: false for IPv6 traffic leaving the host.

The default behavior is to exclude any destination within the IP allocation CIDR of the local node. If the pod IPs are routable across a wider network, that network can be specified with the option: ipv4-native-routing-cidr: 10.0.0.0/8 (or ipv6-native-routing-cidr: fd00::/100 for IPv6 addresses) in which case all destinations within that CIDR will not be masqueraded.

In the public cloud environment, if you don’t configure ipv4-native-routing-cidr, Cilium will automatically detect the VPC CIDR range as the native routing range. Cilium does not masquerade the source address for traffic that is natively routable in the network, because it is possible for the endpoints to communicate directly without NAT. As a result, if masquerading is enabled, traffic from pods to other non-cluster resources within the same VPC (e.g., virtual machines) will be routed directly without masquerading the source IP address.

See Implementation Modes for configuring the masquerading interfaces.

IPv6 BPF masquerading is a beta feature. Please provide feedback and file a GitHub issue if you experience any problems. IPv4 BPF masquerading is production-ready.

The eBPF-based implementation is the most efficient implementation. It can be enabled with the bpf.masquerade=true helm option.

By default, BPF masquerading also enables the BPF Host-Routing mode. See eBPF Host-Routing for benefits and limitations of this mode.

The current implementation depends on the BPF NodePort feature. The dependency will be removed in the future (GitHub issue 13732).

Masquerading can take place only on those devices which run the eBPF masquerading program. This means that a packet sent from a pod to an outside address will be masqueraded (to an output device IPv4 address), if the output device runs the program. If not specified, the program will be automatically attached to the devices selected by the BPF NodePort device detection mechanism. To manually change this, use the devices helm option. Use cilium status to determine which devices the program is running on:

From the output above, the program is running on the eth0 and eth1 devices.

The eBPF-based masquerading can masquerade packets of the following L4 protocols:

For ICMP, support is limited to Echo request, Echo reply, and the error message “Destination unreachable, fragmentation required, and DF flag set”.

By default, all packets from a pod destined to an IP address outside of the ipv4-native-routing-cidr range are masqueraded, except for packets destined to other cluster nodes (as with ipv6-native-routing-cidr for IPv6). The preceding output shows the exclusion CIDR of cilium status (10.0.0.0/16).

When eBPF-masquerading is enabled, traffic from pods to the External IP of cluster nodes will also not be masqueraded. The eBPF implementation differs from the iptables-based masquerading on that aspect. This limitation is tracked at GitHub issue 17177.

To allow more fine-grained control, Cilium implements ip-masq-agent in eBPF which can be enabled with the ipMasqAgent.enabled=true helm option.

The eBPF-based ip-masq-agent supports the nonMasqueradeCIDRs, masqLinkLocal, and masqLinkLocalIPv6 options set in a configuration file. A packet sent from a pod to a destination which belongs to any CIDR from the nonMasqueradeCIDRs is not going to be masqueraded. If the configuration file is empty, the agent will provision the following non-masquerade CIDRs:

In addition, if the masqLinkLocal is not set or set to false, then 169.254.0.0/16 is appended to the non-masquerade CIDRs list. For IPv6, if masqLinkLocalIPv6 is not set or set to false, fe80::/10 is appended.

The agent uses Fsnotify to track updates to the configuration file, so the original resyncInterval option is unnecessary.

The example below shows how to configure the agent via ConfigMap and to verify it:

Alternatively, you can pass --set ipMasqAgent.config.nonMasqueradeCIDRs='{10.0.0.0/8,172.16.0.0/12,192.168.0.0/16}' and --set ipMasqAgent.config.masqLinkLocal=false (or with the corresponding option, for IPv6) when installing Cilium via Helm to configure the ip-masq-agent as above.

This is the legacy implementation that will work on all kernel versions.

The default behavior will masquerade all traffic leaving on a non-Cilium network device. This typically leads to the correct behavior. In order to limit the network interface on which masquerading should be performed, the option egress-masquerade-interfaces: eth0 can be used.

It is possible to specify an interface prefix as well, by specifying eth+, all interfaces matching the prefix eth will be used for masquerading.

For the advanced case where the routing layer would select different source addresses depending on the destination CIDR, the option enable-masquerade-to-route-source: "true" can be used in order to masquerade to the source addresses rather than to the primary interface address. The latter is then only considered as a catch-all fallback, and for the default routes. For these advanced cases the user needs to ensure that there are no overlapping destination CIDRs as routes on the relevant masquerading interfaces.

With the enable-masquerade-to-route-source: "true" option, Cilium will, by default, use interfaces listed in the devices field as the egress masquerade interfaces when egress-masquerade-interfaces is empty. When egress-masquerade-interfaces is set, it takes precedence over devices to choose which network interface should perform masquerading. You can set egress-masquerade-interfaces to match multiple interfaces like this: eth+ ens+.

---

## CiliumEndpointSlice — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/kubernetes/ciliumendpointslice/

**Contents:**
- CiliumEndpointSlice
- Deploy Cilium with CES
  - Pre-Requisites
  - Migration Procedure
- Configuration Options

This is a beta feature. Please provide feedback and file a GitHub issue if you experience any problems.

The tasks needed for graduating this feature “Stable” are documented in GitHub issue 31904.

This document describes CiliumEndpointSlices (CES), which enable batching of CiliumEndpoint (CEP) objects in the cluster to achieve better scalability.

When enabled, Cilium Operator watches CEP objects and groups/batches slim versions of them into CES objects. Cilium Agent watches CES objects to learn about remote endpoints in this mode. API-server stress due to remote endpoint info propagation should be reduced in this case, allowing for better scalability, at the cost of potentially longer delay before identities of new endpoints are recognized throughout the cluster.

CiliumEndpointSlice is a concept that is specific to Cilium and is not related to Kubernetes’ EndpointSlice. Although the names are similar, and even though the concept of slices in each feature brings similar improvements for scalability, they address different problems.

Kubernetes’ Endpoints and EndpointSlices allow Cilium to make load-balancing decisions for a particular Service object; Kubernetes’ EndpointSlices offer a scalable way to track Service back-ends within a cluster.

By contrast, CiliumEndpoints and CiliumEndpointSlices are used to make network routing and policy decisions. So CiliumEndpointSlices focus on tracking Pods, batching CEPs to reduce the number of updates to propagate through the API-server on large clusters.

Enabling one does not affect the other.

CES are disabled by default. This section describes the steps necessary for enabling them.

Make sure that CEPs are enabled (the --disable-endpoint-crd flag is not set to true)

Make sure you are not relying on the Egress Gateway which is not compatible with CES (see Egress Gateway Incompatibility with other features)

In order to minimize endpoint propagation delays, it is recommended to upgrade the Operator first, let it create all CES objects, and then upgrade the Agents afterwards.

Enable CES on the Operator by setting the ciliumEndpointSlice.enabled value to true in your Helm chart or by directly setting the --enable-cilium-endpoint-slice flag to true on the Operator. Re-deploy the Operator.

Once the Operator is running, verify that the CiliumEndpointSlice CRD has been successfully registered:

Verify that the Operator has started creating CES objects:

Let the Operator create CES objects for all existing CEPs in the cluster. This may take some time, depending on the size of the cluster. You can monitor the progress by checking the rate of CES object creation in the cluster, for example by looking at the apiserver_storage_objects Kubernetes metric or by looking at ciliumendpointslices resource creation requests in Kubernetes Audit Logs. You can also monitor the metrics emitted by the Operator, such as cilium_operator_ces_sync_total. All CES-related metrics are documented in the CiliumEndpointSlices (CES) section of the metric documentation.

Once the metrics have stabilized (in other words, when the Operator has created CES objects for all existing CEPs), upgrade the Cilium Agents on all nodes by setting the --enable-cilium-endpoint-slice flag to true and re-deploying them.

Several options are available to adjust the performance and behavior of the CES feature:

You can configure the way CEPs are batched into CES by changing the maximum number of CEPs in a CES (--ces-max-cilium-endpoints-per-ces).

You can also fine-tune rate-limiting settings for the Operator communications with the API-server. Refer to the --ces-* flags for the cilium-operator binary.

You can annotate priority namespaces by setting annotation cilium.io/ces-namespace to the value “priority”. When dealing with large clusters, the propagation of changes during Network Policy updates can be significantly delayed. When namespace’s annotation cilium.io/ces-namespace is set to “priority”, the updates from this namespace will be processed before non-priority updates. This allows to quicker enforce updated network policy in critical namespaces.

---

## Securing Networks with Cilium — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/

**Contents:**
- Securing Networks with Cilium

The 2022 security audits for Cilium are available:

Cilium Security Audit 2022

Cilium Fuzzing Audit 2022

---

## Setting up Cluster Mesh — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/clustermesh/clustermesh/

**Contents:**
- Setting up Cluster Mesh
- Prerequisites
  - Cluster Addressing Requirements
    - Additional Requirements for Native-routed Datapath Modes
  - Scaling Limitations
  - Install the Cilium CLI
- Prepare the Clusters
  - Specify the Cluster Name and ID
  - Shared Certificate Authority
  - Enable Cluster Mesh

This is a step-by-step guide on how to build a mesh of Kubernetes clusters by connecting them together, enable pod-to-pod connectivity across all clusters, define global services to load-balance between clusters and enforce security policies to restrict access.

Aside from this step-by-step guide, if you would like to watch how Cilium’s Clustermesh feature works, check out eCHO Episode 41: Cilium Clustermesh.

All clusters must be configured with the same datapath mode. Cilium install may default to Encapsulation or Native-Routing mode depending on the specific cloud environment.

PodCIDR ranges in all clusters and all nodes must be non-conflicting and unique IP addresses.

Nodes in all clusters must have IP connectivity between each other using the configured InternalIP for each node. This requirement is typically met by establishing peering or VPN tunnels between the networks of the nodes of each cluster.

The network between clusters must allow the inter-cluster communication. The exact ports are documented in the Firewall Rules section.

For cloud-specific deployments, you can check out the AKS-to-AKS Clustermesh Preparation guide for Azure Kubernetes Service (AKS), the EKS-to-EKS Clustermesh Preparation guide for Amazon Elastic Kubernetes Service (EKS) or the GKE-to-GKE Clustermesh Preparation guide for Google Kubernetes Engine (GKE) clusters for instructions on how to meet the above requirements.

Cilium in each cluster must be configured with a native routing CIDR that covers all the PodCIDR ranges across all connected clusters. Cluster CIDRs are typically allocated from the 10.0.0.0/8 private address space. When this is the case a native routing CIDR such as 10.0.0.0/8 should cover all clusters:

ConfigMap option ipv4-native-routing-cidr=10.0.0.0/8

Helm option --set ipv4NativeRoutingCIDR=10.0.0.0/8

cilium install option --set ipv4NativeRoutingCIDR=10.0.0.0/8

In addition to nodes, pods in all clusters must have IP connectivity between each other. This requirement is typically met by establishing peering or VPN tunnels between the networks of the nodes of each cluster

The network between clusters must allow pod-to-pod inter-cluster communication across any ports that the pods may use. This is typically accomplished with firewall rules allowing pods in different clusters to reach each other on all ports.

By default, the maximum number of clusters that can be connected together using Cluster Mesh is 255. By using the option maxConnectedClusters this limit can be set to 511, at the expense of lowering the maximum number of cluster-local identities. Reference the following table for valid configurations and their corresponding cluster-local identity limits:

Maximum cluster-local identities

All clusters across a Cluster Mesh must be configured with the same maxConnectedClusters value.

ConfigMap option max-connected-clusters=511

Helm option --set clustermesh.maxConnectedClusters=511

cilium install option --set clustermesh.maxConnectedClusters=511

This option controls the bit allocation of numeric identities and will affect the maximum number of cluster-local identities that can be allocated. By default, cluster-local Security Identities are limited to 65535, regardless of whether Cluster Mesh is used or not.

MaxConnectedClusters can only be set once during Cilium installation and should not be changed for existing clusters. Changing this option on a live cluster may result in connection disruption and possible incorrect enforcement of network policies

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

Don’t use the Cilium CLI helm mode to enable Cluster Mesh or connect clusters configured using the Cilium CLI operating in classic mode, as the two modes are not compatible with each other.

For the rest of this tutorial, we will assume that you intend to connect two clusters together with the kubectl configuration context stored in the environment variables $CLUSTER1 and $CLUSTER2. This context name is the same as you typically pass to kubectl --context.

Cilium needs to be installed onto each cluster.

Each cluster must be assigned a unique human-readable name as well as a numeric cluster ID (1-255). The cluster name must respect the following constraints:

It must contain at most 32 characters;

It must begin and end with a lower case alphanumeric character;

It may contain lower case alphanumeric characters and dashes between.

It is best to assign both the cluster name and the cluster ID at installation time:

ConfigMap options cluster-name and cluster-id

Helm options cluster.name and cluster.id

Cilium CLI install options --set cluster.name and --set cluster.id

Review Cilium Quick Installation for more details and use cases.

Example install using the Cilium CLI:

If you change the cluster ID and/or cluster name in a cluster with running workloads, you will need to restart all workloads. The cluster ID is used to generate the security identity and it will need to be re-created in order to establish access across clusters.

If you are planning to run Hubble Relay across clusters, it is best to share a certificate authority (CA) between the clusters as it will enable mTLS across clusters to just work.

You can propagate the CA copying the Kubernetes secret containing the CA from one cluster to another:

Enable all required components by running cilium clustermesh enable in the context of both clusters. This will deploy the clustermesh-apiserver into the cluster and generate all required certificates and import them as Kubernetes secrets. It will also attempt to auto-detect the best service type for the LoadBalancer to expose the Cluster Mesh control plane to other clusters.

Starting from v1.16 KVStoreMesh is enabled by default. You can opt out of KVStoreMesh when enabling the Cluster Mesh.

In some cases, the service type cannot be automatically detected and you need to specify it manually. This can be done with the option --service-type. The possible values are:

A Kubernetes service of type LoadBalancer is used to expose the control plane. This uses a stable LoadBalancer IP and is typically the best option.

A Kubernetes service of type NodePort is used to expose the control plane. This requires stable Node IPs. If a node disappears, the Cluster Mesh may have to reconnect to a different node. If all nodes have become unavailable, you may have to re-connect the clusters to extract new node IPs.

A Kubernetes service of type ClusterIP is used to expose the control plane. This requires the ClusterIPs are routable between clusters.

Wait for the Cluster Mesh components to come up by invoking cilium clustermesh status --wait. If you are using a service of type LoadBalancer then this will also wait for the LoadBalancer to be assigned an IP.

Finally, connect the clusters. This step only needs to be done in one direction. The connection will automatically be established in both directions:

It may take a bit for the clusters to be connected. You can run cilium clustermesh status --wait to wait for the connection to be successful:

The output will look something like this:

If this step does not complete successfully, proceed to the troubleshooting section.

Congratulations, you have successfully connected your clusters together. You can validate the connectivity by running the connectivity test in multi cluster mode:

Logical next steps to explore from here are:

Load-balancing & Service Discovery

Use the following list of steps to troubleshoot issues with ClusterMesh:

Validate that Cilium pods are healthy and ready:

Validate that Cluster Mesh is enabled and operational:

If you cannot resolve the issue with the above commands, see the Cluster Mesh Troubleshooting for a more detailed troubleshooting guide.

---

## Azure Delegated IPAM — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/concepts/ipam/azure-delegated-ipam/

**Contents:**
- Azure Delegated IPAM
- Architecture
- Cilium Configuration
- Cilium CNI Configuration

The Azure CNI powered by Cilium cluster utilizes a delegated IPAM (IP Address Manager) approach to allocate IP addresses for pods that are created using the Cilium CNI. This delegated IPAM component manages IP allocation within individual nodes of the cluster. It collaborates closely with the AKS (Azure Kubernetes Service) control plane components to seamlessly integrate with the broader Azure Virtual Network stack.

Azure Delegated Ipam allocator builds on top of CRD-backed allocator. AKS control plane creates NodeNetworkConfig custom resource on each node matching node name. This custom resource contains unique ip prefix for node status.primaryIP in overlay mode or block of unique IP addresses in PodSubnet mode. Delegated Ipam Agent running on each node receives this resource and manages the IP Allocation for pods within node. It makes sure IPs are programmed on Azure Network stack before giving out IPs to Cilium CNI.

The cilium agent must run with ipam: delegated-plugin. Since cilium agent not managing IPs for pods, its also required to specify local-router-ipv4: 169.254.23.0 to configure IP for cilium_host interface.

Cilium CNI is specifically configured with delegated IPAM details in its configuration, allowing it to interact with the delegated Azure IPAM. This configuration ensures that the Cilium CNI triggers the delegated IPAM during both pod addition and deletion operations. Upon receiving an Add request, the delegated IPAM allocates an available IP address from its cache. Similarly on a Delete request, the delegated IPAM marks the IP as available.

The following JSON snippet represents Cilium CNI config with Azure Delegated IPAM configuration.

---

## Kata Containers with Cilium — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/kubernetes/kata/

**Contents:**
- Kata Containers with Cilium
- Setup Kubernetes with CRI
- Deploy Cilium
- Validate the Installation
- Run Kata Containers with Cilium CNI
- Limitations

Kata Containers is an open source project that provides a secure container runtime with lightweight virtual machines that feel and perform like containers, but provide stronger workload isolation using hardware virtualization technology as a second layer of defense. Kata Containers implements OCI runtime spec, just like runc that is used by Docker. Cilium can be used along with Kata Containers, using both enables higher degree of security. Kata Containers enhances security in the compute layer, while Cilium provides policy and observability in the networking layer.

Due to the different Kata Containers Networking model, there are limitations that can cause connectivity disruptions in Cilium. Please refer to the below Limitations section.

This guide shows how to install Cilium along with Kata Containers. It assumes that you have already followed the official Kata Containers installation user guide to get the Kata Containers runtime up and running on your platform of choice but that you haven’t yet setup Kubernetes.

This guide has been validated by following the Kata Containers guide for Google Compute Engine (GCE) and using Ubuntu 18.04 LTS with the packaged version of Kata Containers, CRI-containerd and Kubernetes 1.18.3.

Kata Containers runtime is an OCI compatible runtime and cannot directly interact with the CRI API level. For this reason, it relies on a CRI implementation to translate CRI into OCI. At the time of writing this guide, there are two supported ways called CRI-O and CRI-containerd. It is up to you to choose the one that you want, but you have to pick one.

Refer to the section Requirements for detailed instruction on how to prepare your Kubernetes environment and make sure to use Kubernetes >= 1.12. Then, follow the official guide to run Kata Containers with Kubernetes.

Minimum version of kubernetes 1.12 is required to use the RuntimeClass Feature for Kata Container runtime described below.

With your Kubernetes cluster ready, you can now proceed to deploy Cilium.

Setup Helm repository:

Deploy Cilium release via Helm:

When using kube-proxy-replacement or its socket-level loadbalancer with Kata containers, the socket-level loadbalancer should be disabled for pods by setting socketLB.hostNamespaceOnly=true. See Socket LoadBalancer Bypass in Pod Namespace for more details.

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

Now that your Kubernetes cluster is configured with the Kata Containers runtime and Cilium as the CNI, you can run a sample workload by following these instructions.

Due to its different Networking Design Architecture, the Kata runtime adds an additional layer of abstraction inside the Container Networking Namespace created by Cilium (referred to as “outer”). In that namespace, Kata creates an isolated VM with an additional Container Networking Namespace (referred to as “inside”) to host the requested Pod, as depicted below.

Upon the outer Container Networking Namespace creation, the Cilium CNI performs the following two actions:

creates the eth0 interface with the same device MTU of either the detected underlying network, or the MTU specified in the Cilium ConfigMap;

adjusts the default route MTU (computed as device MTU - overhead) to account for the additional networking overhead given by the Cilium configuration (ex. +50B for VXLAN, +80B for WireGuard, etc.).

However, during the inner Container Networking Namespace creation (i.e., the pod inside the VM), only the outer eth0 device MTU (1) is copied over by Kata to the inner eth0, while the default route MTU (2) is ignored. For this reason, depending on the types of connections, users might experience performance degradation or even packet drops between traditional pods and KataPod connections due to multiple (unexpected) fragmentation.

There are currently two possible workarounds, with (b) being preferred:

set a lower MTU value in the Cilium ConfigMap to account for the overhead. This would allow the KataPod to have a lower device MTU and prevent unwanted fragmentation. However, this is not recommended as it would have a relevant impact on all the other types of communications (ex. traditional pod-to-pod, pod-to-node, etc.) due to the lower device MTU value being set on all the Cilium-managed interfaces.

modify the KataPod deployment by adding an initContainer (with NET_ADMIN) to adjust the route MTU inside the inner pod. This would not only align the KataPod configuration to all the other pods, but also it would not harm all the other types of connections, given that it is a self-contained solution in the KataPod itself. The correct route MTU value to set can be either manually computed or retrieved by issuing ip route on a Cilium Pod (or inside a traditional pod). Here follows an example of a KataPod deployment (runtimeClassName: kata-clh) on a cluster with only Cilium VXLAN enabled (route MTU = 1500B - 50B = 1450):

---

## CRD-Backed — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/concepts/ipam/crd/

**Contents:**
- CRD-Backed
- Architecture
- Configuration
  - Privileges
- CRD Definition
  - IPAM Specification
  - IPAM Status

The CRD-backed IPAM mode provides an extendable interface to control the IP address management via a Kubernetes Custom Resource Definition (CRD). This allows to delegate IPAM to external operators or make it user configurable per node.

When this mode is enabled, each Cilium agent will start watching for a Kubernetes custom resource ciliumnodes.cilium.io with a name matching the Kubernetes node on which the agent is running.

Whenever the custom resource is updated, the per node allocation pool is updated with all addresses listed in the spec.ipam.available field. When an IP is removed that is currently allocated, the IP will continue to be used but will not be available for re-allocation after release.

Upon allocation of an IP in the allocation pool, the IP is added to the status.ipam.inuse field.

The node status update is limited to run at most once every 15 seconds. Therefore, if several pods are scheduled at the same time, the update of the status section can lag behind.

The CRD-backed IPAM mode is enabled by setting ipam: crd in the cilium-config ConfigMap or by specifying the option --ipam=crd. When enabled, the agent will wait for a CiliumNode custom resource matching the Kubernetes node name to become available with at least one IP address listed as available. When connectivity health-checking is enabled, at least two IP addresses must be available.

While waiting, the agent will print the following log message:

For a practical tutorial on how to enable CRD IPAM mode with Cilium, see the section CRD-Backed IPAM.

In order for the custom resource to be functional, the following additional privileges are required. These privileges are automatically granted when using the standard Cilium deployment artifacts:

The CiliumNode custom resource is modeled after a standard Kubernetes resource and is split into a spec and status section:

The spec section embeds an IPAM specific field which allows to define the list of all IPs which are available to the node for allocation:

The status section contains an IPAM specific field. The IPAM status reports all used addresses on that node:

---

## GAMMA Support — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/gamma/

**Contents:**
- GAMMA Support
- What is GAMMA?
- Types of GAMMA configuration
- Cilium GAMMA Support
- Prerequisites
- Installation

(From the GAMMA page on the Gateway API site):

The GAMMA initiative is a dedicated workstream within the Gateway API subproject, shepherded by the GAMMA leads, rather than being a separate subproject. GAMMA’s goal is to define how Gateway API can be used to configure a service mesh, with the intention of making minimal changes to Gateway API and always preserving the role-oriented nature of Gateway API. Additionally, GAMMA strives to advocate for consistency between implementations of Gateway API by service mesh projects, regardless of their technology stack or proxy.

In Gateway API v1.0, GAMMA supports adding extra HTTP routing to Services by binding a HTTPRoute to a Service as a parent (as opposed to the north/south Gateway API usage of binding a HTTPRoute to a Gateway as a parent).

This allows Cilium to intercept layer 7 traffic flowing to a parent Service and route the traffic through the per-node Envoy proxy. Because of this, GAMMA performs the same function as Cilium’s Layer 7 traffic management, without the user needing to know anything about configuring Envoy directly.

In GAMMA, there are two types of HTTPRoutes: “producer” and “consumer” Routes.

“Producer” routes are HTTPRoutes that bind to a Service that lives in the same namespace and have the same owner as the owner of the Service whose traffic is being managed. So, for an application foo, in the namespace foo, with a Service called foo-svc, the owner of foo would create a HTTPRoute in the foo namespace that lists foo-svc as its parent. The routing then affects all traffic coming to the foo service from the whole cluster, and is controlled by the “producer” of the foo service - its owner.

“Consumer” routes are HTTPRoutes that bind to a Service that lives in a different namespace than that Service. These Routes are called “consumer” Routes because they are owned by the _consumer_ of the Service they bind to. For the foo Service above, a Route in the bar namespace, to be used by the app in that namespace, that binds to the foo-svc Service in the foo namespace is a _consumer_ Service because it changes the routing for the bar service, which _consumes_ the foo Service.

Cilium currently supports only “Producer” Routes, and so HTTPRoutes must be in the same namespace as the Service that they are binding to.

Cilium supports GAMMA v1.0.0 for the following resources:

Cilium support is limited to passing the Core conformance tests and two out of three Extended Mesh tests. Note that GAMMA is itself experimental as at Gateway API v1.0.0.

Cilium currently does not support “consumer” HTTPRoutes, and so does not support the MeshConsumerRoute feature of the Mesh conformance profile.

Cilium must be configured with NodePort enabled, using nodePort.enabled=true or by enabling the kube-proxy replacement with kubeProxyReplacement=true. For more information, see kube-proxy replacement.

Cilium must be configured with the L7 proxy enabled using l7Proxy=true (enabled by default).

The below CRDs from Gateway API v1.2.0 must be pre-installed. Please refer to this docs for installation steps. Alternatively, the below snippet could be used.

If you wish to use the TLSRoute functionality, you’ll also need to install the TLSRoute resource. If this CRD is not installed, then Cilium will disable TLSRoute support.

TLSRoute (experimental)

You can install the required CRDs like this:

By default, the Gateway API controller creates a service of LoadBalancer type, so your environment will need to support this. Alternatively, since Cilium 1.16+, you can directly expose the Cilium L7 proxy on the host network.

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

Cilium Gateway API Controller can be enabled with helm flag gatewayAPI.enabled set as true. Please refer to Installation using Helm for a fresh installation.

Next you can check the status of the Cilium agent and operator:

Cilium Gateway API Controller can be enabled with the below command

Next you can check the status of the Cilium agent and operator:

---

## Fragment Handling — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/concepts/fragmentation/

**Contents:**
- Fragment Handling

By default, Cilium configures the eBPF datapath to perform IP fragment tracking to allow protocols that do not support segmentation (such as UDP) to transparently transmit large messages over the network. This feature may be configured using the following options:

--enable-ipv4-fragment-tracking: Enable or disable IPv4 fragment tracking. Enabled by default.

--enable-ipv6-fragment-tracking: Enable or disable IPv6 fragment tracking. Enabled by default.

--bpf-fragments-map-max: Control the maximum number of active concurrent connections using IP fragmentation. For the defaults, see eBPF Maps.

To check whether fragmentation occurred, check the value of the following metrics:

cilium_bpf_map_pressure{map_name="cilium_ipv4_frag_datagrams"}

cilium_bpf_map_pressure{map_name="cilium_ipv6_frag_datagrams"}

If they’re non-zero, it means that fragmented packets were processed.

This is a beta feature. Please provide feedback and file a GitHub issue if you experience any problems.

---

## Configuration — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/kubernetes/configuration/

**Contents:**
- Configuration
- ConfigMap Options
  - CNI
- Adjusting CNI configuration
  - CRD Validation
  - Mounting BPFFS with systemd
  - Container Runtimes
- CRIO
- Common CRIO issues

In the ConfigMap there are several options that can be configured according to your preferences:

debug - Sets to run Cilium in full debug mode, which enables verbose logging and configures eBPF programs to emit more visibility events into the output of cilium-dbg monitor.

enable-ipv4 - Enable IPv4 addressing support

enable-ipv6 - Enable IPv6 addressing support

clean-cilium-bpf-state - Removes all eBPF state from the filesystem on startup. Endpoints will be restored with the same IP addresses, but ongoing connections may be briefly disrupted and loadbalancing decisions will be lost, so active connections via the loadbalancer will break. All eBPF state will be reconstructed from their original sources (for example, from Kubernetes or the kvstore). This may be used to mitigate serious issues regarding eBPF maps. This option should be turned off again after restarting the daemon.

clean-cilium-state - Removes all Cilium state, including unrecoverable information such as all endpoint state, as well as recoverable state such as eBPF state pinned to the filesystem, CNI configuration files, library code, links, routes, and other information. This operation is irreversible. Existing endpoints currently managed by Cilium may continue to operate as before, but Cilium will no longer manage them and they may stop working without warning. After using this operation, endpoints must be deleted and reconnected to allow the new instance of Cilium to manage them.

monitor-aggregation - This option enables coalescing of tracing events in cilium-dbg monitor to only include periodic updates from active flows, or any packets that involve an L4 connection state change. Valid options are none, low, medium, maximum.

none - Generate a tracing event on every receive and send packet.

low - Generate a tracing event on every send packet.

medium - Generate a tracing event for send packets only on every new connection, any time a packet contains TCP flags that have not been previously seen for the packet direction, and on average once per monitor-aggregation-interval (assuming that a packet is seen during the interval). Each direction tracks TCP flags and report interval separately. If Cilium drops a packet, it will emit one event per packet dropped.

maximum - An alias for the most aggressive aggregation level. Currently this is equivalent to setting monitor-aggregation to medium.

monitor-aggregation-interval - Defines the interval to report tracing events. Only applicable for monitor-aggregation levels medium or higher. Assuming new packets are sent at least once per interval, this ensures that on average one event is sent during the interval.

preallocate-bpf-maps - Pre-allocation of map entries allows per-packet latency to be reduced, at the expense of up-front memory allocation for the entries in the maps. Set to true to optimize for latency. If this value is modified, then during the next Cilium startup connectivity may be temporarily disrupted for endpoints with active connections.

Any changes that you perform in the Cilium ConfigMap and in cilium-etcd-secrets Secret will require you to restart any existing Cilium pods in order for them to pick the latest configuration.

When updating keys or values in the ConfigMap, the changes might take up to 2 minutes to be propagated to all nodes running in the cluster. For more information see the official Kubernetes docs: Mounted ConfigMaps are updated automatically

The following ConfigMap is an example where the etcd cluster is running in 2 nodes, node-1 and node-2 with TLS, and client to server authentication enabled.

CNI - Container Network Interface is the plugin layer used by Kubernetes to delegate networking configuration. You can find additional information on the CNI project website.

CNI configuration is automatically taken care of when deploying Cilium via the provided DaemonSet. The cilium pod will generate an appropriate CNI configuration file and write it to disk on startup.

In order for CNI installation to work properly, the kubelet task must either be running on the host filesystem of the worker node, or the /etc/cni/net.d and /opt/cni/bin directories must be mounted into the container where kubelet is running. This can be achieved with Volumes mounts.

The CNI auto installation is performed as follows:

The /etc/cni/net.d and /opt/cni/bin directories are mounted from the host filesystem into the pod where Cilium is running.

The binary cilium-cni is installed to /opt/cni/bin. Any existing binary with the name cilium-cni is overwritten.

The file /etc/cni/net.d/05-cilium.conflist is written.

The CNI configuration file is automatically written and maintained by the cilium pod. It is written after the agent has finished initialization and is ready to handle pod sandbox creation. In addition, the agent will remove any other CNI configuration files by default.

There are a number of Helm variables that adjust CNI configuration management. For a full description, see the helm documentation. A brief summary:

Disable CNI configuration management

Remove other CNI configuration files

Install CNI configuration and binaries

If you want to provide your own custom CNI configuration file, you can do so by passing a path to a cni template file, either on disk or provided via a configMap. The Helm options that configure this are:

Path (inside the agent) to a source CNI configuration file

Name of a ConfigMap containing a source CNI configuration file

Install CNI configuration and binaries

These Helm variables are converted to a smaller set of cilium ConfigMap keys:

write-cni-conf-when-ready

Path to write the CNI configuration file

Path to read the source CNI configuration file

Whether or not to remove other CNI configuration files

Custom Resource Validation was introduced in Kubernetes since version 1.8.0. This is still considered an alpha feature in Kubernetes 1.8.0 and beta in Kubernetes 1.9.0.

Since Cilium v1.0.0-rc3, Cilium will create, or update in case it exists, the Cilium Network Policy (CNP) Resource Definition with the embedded validation schema. This allows the validation of CiliumNetworkPolicy to be done on the kube-apiserver when the policy is imported with an ability to provide direct feedback when importing the resource.

To enable this feature, the flag --feature-gates=CustomResourceValidation=true must be set when starting kube-apiserver. Cilium itself will automatically make use of this feature and no additional flag is required.

In case there is an invalid CNP before updating to Cilium v1.0.0-rc3, which contains the validator, the kube-apiserver validator will prevent Cilium from updating that invalid CNP with Cilium node status. By checking Cilium logs for unable to update CNP, retrying..., it is possible to determine which Cilium Network Policies are considered invalid after updating to Cilium v1.0.0-rc3.

To verify that the CNP resource definition contains the validation schema, run the following command:

In case the user writes a policy that does not conform to the schema, Kubernetes will return an error, e.g.:

In this case, the policy has a port out of the 0-65535 range.

Due to how systemd mounts filesystems, the mount point path must be reflected in the unit filename.

If you want to use CRIO, use the instructions below.

Setup Helm repository:

The Helm flag --set bpf.autoMount.enabled=false might not be required for your setup. For more info see Common CRIO issues.

Since CRI-O does not automatically detect that a new CNI plugin has been installed, you will need to restart the CRI-O daemon for it to pick up the Cilium CNI configuration.

First make sure Cilium is running:

After that you can restart CRI-O:

Some CRI-O environments automatically mount the bpf filesystem in the pods, which is something that Cilium avoids doing when --set bpf.autoMount.enabled=false is set. However, some CRI-O environments do not mount the bpf filesystem automatically which causes Cilium to print the following message:

If you see this warning in the Cilium pod logs with your CRI-O environment, please remove the flag --set bpf.autoMount.enabled=false from your Helm setup and redeploy Cilium.

---

## Ingress and Network Policy Example — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/ingress-and-network-policy/

**Contents:**
- Ingress and Network Policy Example
- Deploy the Demo App
- Deploy the First Ingress
- External Lock-down Policy
- Default Deny Ingress Policy

This example uses the same configuration as the base HTTP Ingress example, using the bookinfo demo microservices app from the Istio project, and then adds CiliumNetworkPolicy on the top.

This is just deploying the demo app, it’s not adding any Istio components. You can confirm that with Cilium Service Mesh there is no Envoy sidecar created alongside each of the demo app microservices.

With the sidecar implementation the output would show 2/2 READY. One for the microservice and one for the Envoy sidecar.

You’ll find the example Ingress definition in basic-ingress.yaml.

This example routes requests for the path /details to the details service, and / to the productpage service.

Getting the list of services, you’ll see a LoadBalancer service is automatically created for this ingress. Your cloud provider will automatically provision an external IP address, but it may take around 30 seconds.

The external IP address should also be populated into the Ingress:

Some providers e.g. EKS use a fully-qualified domain name rather than an IP address.

Confirm that your Ingress is working:

By default, all the external traffic is allowed. Let’s apply a CiliumNetworkPolicy to lock down external traffic.

With this policy applied, any request originating from outside the cluster will be rejected with a 403 Forbidden

Let’s check if in-cluster traffic to the Ingress endpoint is still allowed:

Another common use case is to allow only a specific set of IP addresses to access the Ingress. This can be achieved via the below policy

Let’s apply a CiliumClusterwideNetworkPolicy to deny all traffic by default:

With this policy applied, the request to the /details endpoint will be denied for external and in-cluster traffic.

Now let’s check if in-cluster traffic to the same endpoint is denied:

The next step is to allow ingress traffic to the /details endpoint:

NetworkPolicy that selects reserved:ingress and allows egress to specific identities could also be used. But in general, it’s probably more reliable to allow all traffic from the reserved:ingress identity to all cluster identities, given that Cilium Ingress is part of the networking infrastructure.

---

## Introduction — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/network/intro/

**Contents:**
- Introduction

Cilium provides security on multiple levels. Each can be used individually or combined together.

Identity-Based: Connectivity policies between endpoints (Layer 3), e.g. any endpoint with label role=frontend can connect to any endpoint with label role=backend.

Restriction of accessible ports (Layer 4) for both incoming and outgoing connections, e.g. endpoint with label role=frontend can only make outgoing connections on port 443 (https) and endpoint role=backend can only accept connections on port 443 (https).

Fine grained access control on application protocol level to secure HTTP and remote procedure call (RPC) protocols, e.g the endpoint with label role=frontend can only perform the REST API call GET /userdata/[0-9]+, all other API interactions with role=backend are restricted.

---

## HTTP Example — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/http/

**Contents:**
- HTTP Example
- Deploy the Demo App
- Deploy the Cilium Gateway
- Make HTTP Requests

In this example, we will deploy a simple HTTP service and expose it to the Cilium Gateway API.

The demo application is from the bookinfo demo microservices app from the Istio project.

This is just deploying the demo app, it’s not adding any Istio components. You can confirm that with Cilium Service Mesh there is no Envoy sidecar created alongside each of the demo app microservices.

With the sidecar implementation the output would show 2/2 READY. One for the microservice and one for the Envoy sidecar.

You’ll find the example Gateway and HTTPRoute definition in basic-http.yaml.

The above example creates a Gateway named my-gateway that listens on port 80. Two routes are defined, one for /details to the details service, and one for / to the productpage service.

Your cloud provider will automatically provision an external IP address for the gateway, but it may take up to 20 minutes.

Some providers e.g. EKS use a fully-qualified domain name rather than an IP address.

Now that the Gateway is ready, you can make HTTP requests to the services.

---

## Kubernetes Networking — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/kubernetes/

**Contents:**
- Kubernetes Networking

---

## Requirements — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/kubernetes/requirements/

**Contents:**
- Requirements
- Kubernetes Version
- System Requirements
- Enable CNI in Kubernetes
- Enable automatic node CIDR allocation (Recommended)

All Kubernetes versions listed are e2e tested and guaranteed to be compatible with this Cilium version. Older Kubernetes versions not listed here do not have Cilium support. Newer Kubernetes versions, while not listed, will depend on the backward compatibility offered by Kubernetes.

Additionally, Cilium runs e2e tests against various cloud providers’ managed Kubernetes offerings using multiple Kubernetes versions. See the following links for the current test matrix for each cloud provider:

See System Requirements for all of the Cilium system requirements.

CNI - Container Network Interface is the plugin layer used by Kubernetes to delegate networking configuration and is enabled by default in Kubernetes 1.24 and later. Previously, CNI plugins were managed by the kubelet using the --network-plugin=cni command-line parameter. For more information, see the Kubernetes CNI network-plugins documentation.

Kubernetes has the capability to automatically allocate and assign a per node IP allocation CIDR. Cilium automatically uses this feature if enabled. This is the easiest method to handle IP allocation in a Kubernetes cluster. To enable this feature, simply add the following flag when starting kube-controller-manager:

This option is not required but highly recommended.

---

## Cilium BGP Control Plane — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/bgp-control-plane/bgp-control-plane/

**Contents:**
- Cilium BGP Control Plane
- Installation
- Configuring BGP Control Plane
- Troubleshooting and Operation Guide

BGP Control Plane provides a way for Cilium to advertise routes to connected routers by using the Border Gateway Protocol (BGP). BGP Control Plane makes Pod networks and/or Services reachable from outside the cluster for environments that support BGP. Because BGP Control Plane does not program the datapath, do not use it to establish reachability within the cluster.

For more insights on Cilium’s BGP, check out eCHO episode 101: More BGP fun with Cilium.

Cilium BGP Control Plane can be enabled with Helm flag bgpControlPlane.enabled set as true.

Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

See the full page of releases.

Cilium BGP Control Plane can be enabled with the following command

IPv4/IPv6 single-stack and dual-stack setup are supported. Note that the BGP Control Plane can only advertise the route of the address family that the Cilium is configured to use. You cannot advertise IPv4 routes when the Cilium Agent is configured to use only IPv6 address family. Conversely, you cannot advertise IPv6 routes when Cilium Agent is configured to use only IPv4 address family.

There are two ways to configure the BGP Control Plane. Using legacy CiliumBGPPeeringPolicy resource, or using newer BGP resources like CiliumBGPClusterConfig. Currently, both configuration options are supported, however CiliumBGPPeeringPolicy will be deprecated in the future.

---

## Network Observability with Hubble — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/observability/hubble/

**Contents:**
- Network Observability with Hubble

Observability is provided by Hubble which enables deep visibility into the communication and behavior of services as well as the networking infrastructure in a completely transparent manner. Hubble is able to provide visibility at the node level, cluster level or even across clusters in a Multi-Cluster (Cluster Mesh) scenario. For an introduction to Hubble and how it relates to Cilium, read the section Introduction to Cilium & Hubble.

By default, Hubble API operates within the scope of the individual node on which the Cilium agent runs. This confines the network insights to the traffic observed by the local Cilium agent. Hubble CLI (hubble) can be used to query the Hubble API provided via a local Unix Domain Socket. The Hubble CLI binary is installed by default on Cilium agent pods.

Upon deploying Hubble Relay, network visibility is provided for the entire cluster or even multiple clusters in a ClusterMesh scenario. In this mode, Hubble data can be accessed by directing Hubble CLI (hubble) to the Hubble Relay service or via Hubble UI. Hubble UI is a web interface which enables automatic discovery of the services dependency graph at the L3/L4 and even L7 layer, allowing user-friendly visualization and filtering of data flows as a service map.

---

## BGP — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/bgp-toc/

**Contents:**
- BGP

---

## AKS-to-AKS Clustermesh Preparation — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/network/clustermesh/aks-clustermesh-prep/

**Contents:**
- AKS-to-AKS Clustermesh Preparation
- Install cluster one
- Install cluster two
- Peering virtual networks

This is a step-by-step guide on how to install and prepare AKS (Azure Kubernetes Service) clusters in BYOCNI mode to meet the requirements for the clustermesh feature.

This guide describes how to install two AKS clusters in BYOCNI (Bring Your Own CNI) mode and connect them together via clustermesh. This guide is not applicable for cross-cloud clustermesh since this guide doesn’t expose the node IPs outside of the Azure cloud.

BYOCNI requires the aks-preview CLI extension with version >= 0.5.55, which itself requires an az CLI version >= 2.32.0.

Create a resource group for the cluster (or set the environment variables to an existing resource group).

Create a VNet (virtual network). Creating a custom VNet is required to ensure that the Node, Pod, and Service CIDRs are unique and they don’t overlap with other clusters.

The example below uses range 192.168.10.0/24 range, but you could use any range except for 169.254.0.0/16, 172.30.0.0/16, 172.31.0.0/16, or 192.0.2.0/24 which are reserved by Azure.

You now have a virtual network and a subnet with the same CIDR. Create an AKS cluster without a CNI and request to use a custom VNet and subnet.

During creation request to use "10.10.0.0/16" as the pod CIDR and "10.11.0.0/16" as the services CIDR. These can be changed to any range except for Azure reserved ranges and ranges used by other clusters you intend to add to the clustermesh.

Install Cilium, it is important to give the cluster a unique cluster ID and to tell Cilium to use our custom pod CIDR.

Check the status of Cilium.

Before configuring cluster two, store the name of the current cluster.

Installing the second cluster uses the same commands but with slightly different arguments.

Create a new resource group.

Create a VNet in this resource group. Make sure to use a non-overlapping prefix.

The example below uses range 192.168.20.0/24, but you could use any range except for 169.254.0.0/16, 172.30.0.0/16, 172.31.0.0/16, or 192.0.2.0/24 which are reserved by Azure.

Create an AKS cluster without CNI and request to use your custom VNet and subnet.

During creation use "10.20.0.0/16" as the pod CIDR and "10.21.0.0/16" as the services CIDR. These can be changed to any range except for Azure reserved ranges and ranges used by other clusters you intend to add to the clustermesh.

Install Cilium, it is important to give the cluster a unique cluster ID and to tell Cilium to use your custom pod CIDR.

Check the status of Cilium.

Before configuring peering and clustermesh, store the current cluster name.

Virtual networks can’t connect to each other by default. You can enable cross VNet communication by creating bi-directional “peering”.

Create a peering from cluster one to cluster two using the following commands.

This allows outbound traffic from cluster one to cluster two. To allow bi-directional traffic, add a peering to the other direction as well.

Node-to-node traffic between clusters is now possible. All requirements for clustermesh are met. Enabling clustermesh is explained in Setting up Cluster Mesh.

---
