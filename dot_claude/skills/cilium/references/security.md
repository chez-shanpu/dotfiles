# Cilium - Security

**Pages:** 19

---

## Restricting privileged Cilium pod access — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/restrict-pod-access/

**Contents:**
- Restricting privileged Cilium pod access
- Setup Cilium
  - Background
  - Restrict authorization for kubernetes exec pod
  - References

This page shows you how to restrict privileged access to Cilium pods by limiting access from the Kubernetes API, specifically from kubernetes exec pod.

If you haven’t read the Introduction to Cilium & Hubble yet, we’d encourage you to do that first.

The best way to get help if you get stuck is to ask a question on Cilium Slack. With Cilium contributors across the globe, there is almost always someone available to help.

If you have not set up Cilium yet, follow the guide Cilium Quick Installation for instructions on how to quickly bootstrap a Kubernetes cluster and install Cilium. If in doubt, pick the minikube route, you will be good to go in less than 5 minutes.

The Cilium agent needs some specific Linux capabilities to perform essential system and network operations.

Cilium relies on Kubernetes and containers to set up the environment and mount the corresponding volumes. Cilium doesn’t perform any extra operations that could result in an unsafe volume mount.

Cilium needs kernel interfaces to properly configure the environment. Some kernel interfaces are part of the /proc filesystem, which includes host and machine configurations that can’t be virtualized or namespaced.

If pod exec operations aren’t restricted, then remote exec into pods and containers defeats Linux namespace restrictions.

The Linux kernel restricts joining other namespaces by default. To enter the Cilium container, the CAP_SYS_ADMIN capability is required in both the current user namespace and in the Cilium user namespace (the initial namespace). If both namespaces have the CAP_SYS_ADMIN capability, then this is already a privileged access.

To prevent privileged access to Cilium pods, restrict access to the Kubernetes API and arbitrary pod exec operations.

To restrict access to Cilium pods through kubernetes exec pod:

Configure RBAC authorization in Kubernetes.

Limit access to the proxy subresource of Nodes.

For more information about namespace security, visit:

https://man7.org/linux/man-pages/man7/user_namespaces.7.html

https://man7.org/linux/man-pages/man1/nsenter.1.html

https://man7.org/linux/man-pages/man2/setns.2.html

---

## Locking Down External Access with DNS-Based Policies — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/dns/

**Contents:**
- Locking Down External Access with DNS-Based Policies
- Setup Cilium
- Deploy the Demo Application
- Apply DNS Egress Policy
- DNS Policies Using Patterns
- Combining DNS, Port and L7 Rules
- Clean-up

This document serves as an introduction for using Cilium to enforce DNS-based security policies for Kubernetes pods.

If you haven’t read the Introduction to Cilium & Hubble yet, we’d encourage you to do that first.

The best way to get help if you get stuck is to ask a question on Cilium Slack. With Cilium contributors across the globe, there is almost always someone available to help.

If you have not set up Cilium yet, follow the guide Cilium Quick Installation for instructions on how to quickly bootstrap a Kubernetes cluster and install Cilium. If in doubt, pick the minikube route, you will be good to go in less than 5 minutes.

DNS-based policies are very useful for controlling access to services running outside the Kubernetes cluster. DNS acts as a persistent service identifier for both external services provided by AWS, Google, Twilio, Stripe, etc., and internal services such as database clusters running in private subnets outside Kubernetes. CIDR or IP-based policies are cumbersome and hard to maintain as the IPs associated with external services can change frequently. The Cilium DNS-based policies provide an easy mechanism to specify access control while Cilium manages the harder aspects of tracking DNS to IP mapping.

In this guide we will learn about:

Controlling egress access to services outside the cluster using DNS-based policies

Using patterns (or wildcards) to whitelist a subset of DNS domains

Combining DNS, port and L7 rules for restricting access to external service

In line with our Star Wars theme examples, we will use a simple scenario where the Empire’s mediabot pods need access to GitHub for managing the Empire’s git repositories. The pods shouldn’t have access to any other external service.

The following Cilium network policy allows mediabot pods to only access api.github.com.

OpenShift users will need to modify the policies to match the namespace openshift-dns (instead of kube-system), remove the match on the k8s:k8s-app=kube-dns label, and change the port to 5353.

Let’s take a closer look at the policy:

The first egress section uses toFQDNs: matchName specification to allow egress to api.github.com. The destination DNS should match exactly the name specified in the rule. The endpointSelector allows only pods with labels class: mediabot, org:empire to have the egress access.

The second egress section (toEndpoints) allows mediabot pods to access kube-dns service. Note that rules: dns instructs Cilium to inspect and allow DNS lookups matching specified patterns. In this case, inspect and allow all DNS queries.

Note that with this policy the mediabot doesn’t have access to any internal cluster service other than kube-dns. Refer to Overview of Network Policy to learn more about policies for controlling access to internal cluster services.

Let’s apply the policy:

Testing the policy, we see that mediabot has access to api.github.com but doesn’t have access to any other external service, e.g., support.github.com.

The above policy controlled DNS access based on exact match of the DNS domain name. Often, it is required to allow access to a subset of domains. Let’s say, in the above example, mediabot pods need access to any GitHub sub-domain, e.g., the pattern *.github.com. We can achieve this easily by changing the toFQDN rule to use matchPattern instead of matchName.

Test that mediabot has access to multiple GitHub services for which the DNS matches the pattern *.github.com. It is important to note and test that this doesn’t allow access to github.com because the *. in the pattern requires one subdomain to be present in the DNS name. You can simply add more matchName and matchPattern clauses to extend the access. (See DNS based policies to learn more about specifying DNS rules using patterns and names.)

The DNS-based policies can be combined with port (L4) and API (L7) rules to further restrict the access. In our example, we will restrict mediabot pods to access GitHub services only on ports 443. The toPorts section in the policy below achieves the port-based restrictions along with the DNS-based policies.

Testing, the access to https://support.github.com on port 443 will succeed but the access to http://support.github.com on port 80 will be denied.

Refer to Layer 4 Examples and Layer 7 Examples to learn more about Cilium L4 and L7 network policies.

---

## 

**URL:** https://docs.cilium.io/en/stable/_downloads/9615617f6682a506cb8e18b1033218e3/CiliumSecurityAudit2022.pdf

---

## Using Kubernetes Constructs In Policy — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/policy/kubernetes/

**Contents:**
- Using Kubernetes Constructs In Policy
- Namespaces
- Known Pitfalls
  - Considerations Of Namespace Boundaries
    - Example
  - Policies Only Apply Within The Namespace
    - Example
  - Specifying Namespace In EndpointSelector, FromEndpoints, ToEndpoints
    - Example
  - Namespace Specific Information

This section covers Kubernetes specific network policy aspects.

Namespaces are used to create virtual clusters within a Kubernetes cluster. All Kubernetes objects including NetworkPolicy and CiliumNetworkPolicy belong to a particular namespace.

This section covers known pitfalls when using Kubernetes constructs in policy.

Depending on how a policy is defined and created, Kubernetes namespaces are automatically taken into account.

Network policies imported directly with the API Reference apply to all namespaces unless a namespace selector is specified as described in Example.

This example demonstrates how to enforce Kubernetes namespace-based boundaries for the namespaces ns1 and ns2 by enabling default-deny on all pods of either namespace and then allowing communication from all pods within the same namespace.

The example locks down ingress of the pods in ns1 and ns2. This means that the pods can still communicate egress to anywhere unless the destination is in either ns1 or ns2 in which case both source and destination have to be in the same namespace. In order to enforce namespace boundaries at egress, the same example can be used by specifying the rules at egress in addition to ingress.

Network policies created and imported as CiliumNetworkPolicy CRD and NetworkPolicy apply within the namespace. In other words, the policy only applies to pods within that namespace. It’s possible, however, to grant access to and from pods in other namespaces as described in Example.

The following example exposes all pods with the label name=leia in the namespace ns1 to all pods with the label name=luke in the namespace ns2.

Refer to the example YAML files for a fully functional example including pods deployed to different namespaces.

Specifying the namespace by way of the label k8s:io.kubernetes.pod.namespace in the fromEndpoints and toEndpoints fields is supported as described in Example. However, Kubernetes prohibits specifying the namespace in the endpointSelector, as it would violate the namespace isolation principle of Kubernetes. The endpointSelector always applies to pods in the namespace associated with the CiliumNetworkPolicy resource itself.

The following example allows all pods in the public namespace in which the policy is created to communicate with kube-dns on port 53/UDP in the kube-system namespace.

Using namespace-specific information like io.cilium.k8s.namespace.labels within a fromEndpoints or toEndpoints is supported only for a CiliumClusterwideNetworkPolicy and not a CiliumNetworkPolicy. Hence, io.cilium.k8s.namespace.labels will be ignored in CiliumNetworkPolicy resources.

When using matchExpressions in a CiliumNetworkPolicy or a CiliumClusterwideNetworkPolicy, the list values are treated as a logical AND. If you want to match multiple keys with a logical OR, you must use multiple matchExpressions.

This example demonstrates how to enforce a policy with multiple matchExpressions that achieves a logical OR between the keys and its values.

The following example shows a logical AND using a single matchExpression.

Kubernetes Service Accounts are used to associate an identity to a pod or process managed by Kubernetes and grant identities access to Kubernetes resources and secrets. Cilium supports the specification of network security policies based on the service account identity of a pod.

The service account of a pod is either defined via the service account admission controller or can be directly specified in the Pod, Deployment, ReplicationController resource like this:

The following example grants any pod running under the service account of “luke” to issue a HTTP GET /public request on TCP port 80 to all pods running associated to the service account of “leia”.

Refer to the example YAML files for a fully functional example including deployment and service account resources.

When operating multiple cluster with cluster mesh, the cluster name is exposed via the label io.cilium.k8s.policy.cluster and can be used to restrict policies to a particular cluster.

Note the io.kubernetes.pod.namespace: default in the policy rule. It makes sure the policy applies to rebel-base in the default namespace of cluster2 regardless of the namespace in cluster1 where x-wing is deployed in.

If the namespace label of policy rules is omitted it defaults to the same namespace where the policy itself is applied in, which may be not what is wanted when deploying cross-cluster policies. To allow access from/to any namespace, use matchExpressions combined with an Exists operator.

CiliumNetworkPolicy only allows to bind a policy restricted to a particular namespace. There can be situations where one wants to have a cluster-scoped effect of the policy, which can be done using Cilium’s CiliumClusterwideNetworkPolicy Kubernetes custom resource. The specification of the policy is same as that of CiliumNetworkPolicy except that it is not namespaced.

In the cluster, this policy will allow ingress traffic from pods matching the label name=luke from any namespace to pods matching the labels name=leia in any namespace.

The following example allows all Cilium managed endpoints in the cluster to communicate with kube-dns on port 53/UDP in the kube-system namespace.

The following example adds the health entity to all Cilium managed endpoints in order to check cluster connectivity health.

---

## Endpoint Lifecycle — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/policy/lifecycle/

**Contents:**
- Endpoint Lifecycle
- Init Identity
- Lockdown Mode

This section specifies the lifecycle of Cilium endpoints.

Every endpoint in Cilium is in one of the following states:

restoring: The endpoint was started before Cilium started, and Cilium is restoring its networking configuration.

waiting-for-identity: Cilium is allocating a unique identity for the endpoint.

waiting-to-regenerate: The endpoint received an identity and is waiting for its networking configuration to be (re)generated.

regenerating: The endpoint’s networking configuration is being (re)generated. This includes programming eBPF for that endpoint.

ready: The endpoint’s networking configuration has been successfully (re)generated.

disconnecting: The endpoint is being deleted.

disconnected: The endpoint has been deleted.

The state of an endpoint can be queried using the cilium-dbg endpoint list and cilium-dbg endpoint get CLI commands.

While an endpoint is running, it transitions between the waiting-for-identity, waiting-to-regenerate, regenerating, and ready states. A transition into the waiting-for-identity state indicates that the endpoint changed its identity. A transition into the waiting-to-regenerate or regenerating state indicates that the policy to be enforced on the endpoint has changed because of a change in identity, policy, or configuration.

An endpoint transitions into the disconnecting state when it is being deleted, regardless of its current state.

In some situations, Cilium can’t determine the labels of an endpoint immediately when the endpoint is created, and therefore can’t allocate an identity for the endpoint at that point. Until the endpoint’s labels are known, Cilium temporarily associates a special single label reserved:init to the endpoint. When the endpoint’s labels become known, Cilium then replaces that special label with the endpoint’s labels and allocates a proper identity to the endpoint.

This may occur during endpoint creation in the following cases:

Running Cilium with docker via libnetwork

With Kubernetes when the Kubernetes API server is not available

In etcd mode when the corresponding kvstore is not available

To allow traffic to/from endpoints while they are initializing, you can create policy rules that select the reserved:init label, and/or rules that allow traffic to/from the special init entity.

For instance, writing a rule that allows all initializing endpoints to receive connections from the host and to perform DNS queries may be done as follows:

Likewise, writing a rule that allows an endpoint to receive DNS queries from initializing endpoints may be done as follows:

If any ingress (resp. egress) policy rules selects the reserved:init label, all ingress (resp. egress) traffic to (resp. from) initializing endpoints that is not explicitly allowed by those rules will be dropped. Otherwise, if the policy enforcement mode is never or default, all ingress (resp. egress) traffic is allowed to (resp. from) initializing endpoints. Otherwise, all ingress (resp. egress) traffic is dropped.

If the Cilium agent option enable-lockdown-endpoint-on-policy-overflow is set to “true” Cilium will put an endpoint into “lockdown” if the policy map cannot accommodate all of the required policy map entries required (that is, the policy map for the endpoint is overflowing). Cilium will put the endpoint out of “lockdown” when it detects that the policy map is no longer overflowing. When an endpoint is locked down all network traffic, both egress and ingress, will be dropped. Cilium will log a warning that the endpoint has been locked down.

If this option is enabled, cluster operators should closely monitor the metric the bpf map pressure metric of the cilium_policy_* maps. See Policymap pressure and overflow for more details. They can use this metric to create an alert for increased memory pressure on the policy map as well as alert for a lockdown if enable-lockdown-endpoint-on-policy-overflow is set to “true” (any bpf_map_pressure above a value of 1.0).

---

## Inspecting TLS Encrypted Connections with Cilium — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/tls-visibility/

**Contents:**
- Inspecting TLS Encrypted Connections with Cilium
- Setup Cilium
- A Brief Overview of the TLS Certificate Model
- How TLS Inspection works
  - Network Policy Discovery Service (NPDS)
  - Secret Discovery Service (SDS)
- Configuring TLS Interception
  - Configuring the three available modes for TLS Interception
    - SDS Mode (recommended, default for new clusters):
    - Read all Secrets in the Cluster mode (not recommended)

This document serves as an introduction for how network security teams can use Cilium to transparently inspect TLS-encrypted connections. This TLS-aware inspection allows Cilium API-aware visibility and policy to function even for connections where client to server communication is protected by TLS, such as when a client accesses the API service via HTTPS. This capability is similar to what is possible to traditional hardware firewalls, but is implemented entirely in software on the Kubernetes worker node, and is policy driven, allowing inspection to target only selected network connectivity.

This type of visibility is extremely valuable to be able to monitor how external API services are being used, for example, understanding which S3 buckets are being accessed by an given application.

If you haven’t read the Introduction to Cilium & Hubble yet, we’d encourage you to do that first.

The best way to get help if you get stuck is to ask a question on Cilium Slack. With Cilium contributors across the globe, there is almost always someone available to help.

If you have not set up Cilium yet, follow the guide Cilium Quick Installation for instructions on how to quickly bootstrap a Kubernetes cluster and install Cilium. If in doubt, pick the minikube route, you will be good to go in less than 5 minutes.

TLS is a protocol that “wraps” other protocols like HTTP and ensures that communication between client and server has confidentiality (no one can read the data except the intended recipient), integrity (recipient can confirm that the data has not been modified in transit), and authentication (sender can confirm that it is talking with the intended destination, not an impostor). We will provide a highly simplified overview of TLS in this document, but for full details, please see https://en.wikipedia.org/wiki/Transport_Layer_Security .

From an authentication perspective, the TLS model relies on a “Certificate Authority” (CA) which is an entity that is trusted to create proof that a given network service (e.g., www.cilium.io) is who they say they are. The goal is to prevents a malicious party in the network between the client and the server from intercepting the traffic and pretending to be the destination server.

In the case of “friendly interception” for network security monitoring, Cilium uses a model similar to traditional firewalls with TLS inspection capabilities: the network security team creates their own “internal certificate authority” that can be used to create alternative certificates for external destinations. This model requires each client workload to also trust this new certificate, otherwise the client’s TLS library will reject the connection as invalid. In this model, the network firewall uses the certificate signed by the internal CA to act like the destination service and terminate the TLS connection. This allows the firewall to inspect and even modify the application layer data, and then initiate another TLS connect to the actual destination service.

The CA model within TLS is based on cryptographic keys and certificates. Realizing the above model requires four primary steps:

Create an internal certificate authority by generating a CA private key and CA certificate.

For any destination where TLS inspection is desired (e.g., httpbin.org in the example below), generate a private key and certificate signing request with a common name that matches the destination DNS name.

Use the CA private key to create a signed certificate.

Ensure that all clients where TLS inspection is have the CA certificate installed so that they will trust all certificates signed by that CA.

Given that Cilium will be terminating the initial TLS connection from the client and creating a new TLS connection to the destination, Cilium must be told the set of CAs that it should trust when validating the new TLS connection to the destination service.

In a non-demo environment it is EXTREMELY important that you keep the above private keys safe, as anyone with access to this private key will be able to inspect TLS-encrypted traffic (certificates on the other hand are public information, and are not at all sensitive). In the guide below, the CA private key does not need to be provided to Cilium at all (it is used only to create certificates, which can be done offline) and private keys for individual destination services are stored as Kubernetes secrets. These secrets should be stored in a namespace where they can be accessed by Cilium, but not general purpose workloads.

All TLS inspection relies on terminating the originating connection with a certificate that will be accepted, then originating a new TLS connection using a client certificate if necessary.

Because of this, the Network Policy requires configuring a terminatingTLS and optionally an originatingTLS stanza.

When the Network Policy contains these details, then Cilium will redirect TLS connections to Envoy, and allow connections that complete a TLS handshake and pass the configured Network Policy.

One of the most important parts of the configuration for this is how the certificates get to Envoy.

In the current version, Cilium has two options, NPDS (the original) and SDS (the new and better version).

In this version, certificates and keys are sent inline as Base64 encoded text in dedicated fields in the Cilium-owned Network Policy Discovery Service.

This had the advantage that it was straightforward to build, but does come with a big disadvantage:

Each Network Policy rule that does TLS Interception keeps its own copy of each secret inline in the NPDS config in Envoy. So, if (as is likely for a larger installation), you have the same secret reused multiple times (for example if you generate one certificate that will terminate for many SANs, but you have multiple rules using that certificate, or you include a valid root certificate bundle in the originatingTLS config), then multiple copies of the certificate will be stored in Envoy’s memory. This memory use can really add up in a large installation.

It also means that we don’t benefit from work that has been done to protect secrets when they are sent using Secret Discovery Service (.

Both of the above reasons are why Envoy supports SDS for Network Policy secrets as of Cilium 1.17.

In this configuration, Cilium reads relevant Secrets from a configured secrets namespace, and exposes those secrets to Envoy using the core Envoy SDS API. Those secrets are then referenced in the NPDS config that’s sent to Envoy to configure the Network Policy filter there by name, rather than being included directly as Base64 encoded text.

This means that Envoy looks up the SDS secrets for NPDS in the same way as it does the secrets for Ingress or Gateway API config.

This method also allows Envoy to deduplicate the storage of the secrets, since they are essentially being passed by reference instead of being passed by value.

Because of these advantages over the older NPDS method, SDS is the default for new Cilium installations as at Cilium 1.17.

There are three ways to use Cilium in 1.17 and later:

Using SDS, Secrets referenced in Network Policy can be located anywhere in the cluster, and are copied into a configured namespace (cilium-secrets by default) by the Cilium Operator, synchronized from there into SDS, then referenced in NPDS using that name. This is the default for new clusters, and the recommended method of operation.

Secrets can be located anywhere in the cluster, and the Cilium Agent can be granted read access to all Secrets in the cluster. In this case, Secrets are read directly from their original location by the Cilium Agent and sent inline in NPDS. This deployment method is included for backwards compatibility purposes and is not recommended, as it significantly expands the security scope of the agent.

Secrets can be added directly to the cilium-secrets namespace, then referenced in that namespace from Network Policy. This is also included for backwards compatibility based on user feedback about how this feature was actually being used. It is the default for upgraded clusters that have not configured any settings and are using the upgradeCompatibility setting in Helm, set to 1.16 or below.

There are three settings in Helm that affect TLS Interception:

tls.secretsNamespace.name - default cilium-secrets. Configures the secrets namespace that will be used for Policy secrets. Note that this is set to the same value as a similar setting for Ingress, Gateway API, and BGP configuration by default, but may be set to a different value.

tls.readSecretsOnlyFromSecretsNamespace - default true. This setting tells the Helm chart and Cilium whether the Cilium Agent should only read secrets from the configured Secrets namespace, or if the Cilium Agent should attempt to read Secrets directly from their location in the cluster. Previous versions of Cilium used the item tls.secretsBackend, which could be set to local (meaning only read from the Secrets namespace) or k8s (meaning read from any namespace), but that field is now deprecated, as its naming had become detached from its function. Previous installations that set tls.secretsBackend to k8s should migrate to setting tls.readSecretsOnlyFromSecretsNamespace to false instead, although the setting will continue to work for Cilium 1.17. tls.secretsBackend will be removed in a future Cilium version.

tls.secretSync.enabled - default true for new clusters. Configures secret synchronization and SDS use for Network Policy secrets. SDS use requires this to be set to true, and must be disabled when this field is set to false, so having an additional field for SDS config added no value.

Set the following settings in your Helm Values:

Set the following settings in your Helm Values:

Set the following settings in your Helm Values:

If you are using this mode, then you will need to replace all references to kube-system in the validation instructions on this page with cilium-secrets (or whatever value you have set that namespace to).

Once you’ve chosen an option and configured your Cilium installation accordingly, proceed with verifying your install using the rest of these instructions.

To demonstrate TLS-interception we will use the same mediabot application that we used for the DNS-aware policy example. This application will access the Star Wars API service using HTTPS, which would normally mean that network-layer mechanisms like Cilium would not be able to see the HTTP-layer details of the communication, since all application data is encrypted using TLS before that data is sent on the network.

In this guide we will learn about:

Creating an internal Certificate Authority (CA) and associated certificates signed by that CA to enable TLS interception.

Using Cilium network policy to select the traffic to intercept using DNS-based policy rules.

Inspecting the details of the HTTP request using cilium monitor (accessing this visibility data via Hubble, and applying Cilium network policies to filter/modify the HTTP request is also possible, but is beyond the scope of this simple Getting Started Guide)

First off, we will create a single pod mediabot application:

Now that we understand TLS and have configured Cilium to use TLS interception, we will walk through the concrete steps to generate the appropriate keys and certificates using the openssl utility.

The following image describes the different files containing cryptographic data that are generated or copied, and what components in the system need access to those files:

You can use openssl on your local system if it is already installed, but if not a simple shortcut is to use kubectl exec to execute /bin/bash within any of the cilium pods, and then run the resulting openssl commands. Use kubectl cp to copy the resulting files out of the cilium pod when it is time to use them to create Kubernetes secrets of copy them to the mediabot pod.

Generate CA private key named ‘myCA.key’:

Enter any password, just remember it for some of the later steps.

Generate CA certificate from the private key:

The values you enter for each prompt do not need to be any specific value, and do not need to be accurate.

Generate an internal private key and certificate signing with a common name that matches the DNS name of the destination service to be intercepted for inspection (in this example, use httpbin.org).

First create the private key:

Next, create a certificate signing request, specifying the DNS name of the destination service for the common name field when prompted. All other prompts can be filled with any value.

The only field that must be a specific value is ensuring that Common Name is the exact DNS destination httpbin.org that will be provided to the client.

This example workflow will work for any DNS name as long as the toFQDNs rule in the policy YAML (below) is also updated to match the DNS name in the certificate.

Use the internal CA private key to create a signed certificate for httpbin.org named internal-httpbin.crt.

Next we create a Kubernetes secret that includes both the private key and signed certificates for the destination service:

Once the CA certificate is inside the client pod, we still must make sure that the CA file is picked up by the TLS library used by your application. Most Linux applications automatically use a set of trusted CA certificates that are bundled along with the Linux distro. In this guide, we are using an Ubuntu container as the client, and so will update it with Ubuntu specific instructions. Other Linux distros will have different mechanisms. Also, individual applications may leverage their own certificate stores rather than use the OS certificate store. Java applications and the aws-cli are two common examples. Please refer to the application or application runtime documentation for more details.

For Ubuntu, we first copy the additional CA certificate to the client pod filesystem

Then run the Ubuntu-specific utility that adds this certificate to the global set of trusted certificate authorities in /etc/ssl/certs/ca-certificates.crt .

This command will issue a WARNING, but this can be ignored.

Next, we will provide Cilium with the set of CAs that it should trust when originating the secondary TLS connections. This list should correspond to the standard set of global CAs that your organization trusts. A logical option for this is the standard CAs that are trusted by your operating system, since this is the set of CAs that were being used prior to introducing TLS inspection.

To keep things simple, in this example we will simply copy this list out of the Ubuntu filesystem of the mediabot pod, though it is important to understand that this list of trusted CAs is not specific to a particular TLS client or server, and so this step need only be performed once regardless of how many TLS clients or servers are involved in TLS inspection.

We then will create a Kubernetes secret using this certificate bundle so that Cilium can read the certificate bundle and use it to validate outgoing TLS connections.

Up to this point, we have created keys and certificates to enable TLS inspection, but we have not told Cilium which traffic we want to intercept and inspect. This is done using the same Cilium Network Policy constructs that are used for other Cilium Network Policies.

The following Cilium network policy indicates that Cilium should perform HTTP-aware inspect of communication between the mediabot pod to httpbin.org.

Let’s take a closer look at the policy:

The endpointSelector means that this policy will only apply to pods with labels class: mediabot, org:empire to have the egress access.

The first egress section uses toFQDNs: matchName specification to allow TCP port 443 egress to httpbin.org.

The http section below the toFQDNs rule indicates that such connections should be parsed as HTTP, with a policy of {} which will allow all requests.

The terminatingTLS and originatingTLS sections indicate that TLS interception should be used to terminate the initial TLS connection from mediabot and initiate a new out-bound TLS connection to httpbin.org.

The second egress section allows mediabot pods to access kube-dns service. Note that rules: dns instructs Cilium to inspect and allow DNS lookups matching specified patterns. In this case, inspect and allow all DNS queries.

Note that with this policy the mediabot doesn’t have access to any internal cluster service other than kube-dns and will have no access to any other external destinations either. Refer to Overview of Network Policy to learn more about policies for controlling access to internal cluster services.

Let’s apply the policy:

Recall that the policy we pushed will allow all HTTPS requests from mediabot to httpbin.org, but will parse all data at the HTTP-layer, meaning that cilium monitor will report each HTTP request and response.

To see this, open a new window and run the following command to identity the name of the cilium pod (e.g, cilium-97s78) that is running on the same Kubernetes worker node as the mediabot pod.

Then start running cilium-dbg monitor in “L7 mode” to monitor for HTTP requests being reported by Cilium:

Next in the original window, from the mediabot pod we can access httpbin.org via HTTPS:

Looking back at the cilium-dbg monitor window, you will see each individual HTTP request and response. For example:

Refer to Layer 4 Examples and Layer 7 Examples to learn more about Cilium L4 and L7 network policies.

---

## Policy Enforcement Modes — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/policy/intro/

**Contents:**
- Policy Enforcement Modes
- Endpoint default policy
- Rule Basics
- Endpoint Selector
- Node Selector

The configuration of the Cilium agent and the Cilium Network Policy determines whether an endpoint accepts traffic from a source or not. The agent can be put into the following three policy enforcement modes:

This is the default behavior for policy enforcement. In this mode, endpoints have unrestricted network access until selected by policy. Upon being selected by a policy, the endpoint permits only allowed traffic. This state is per-direction and can be adjusted on a per-policy basis. For more details, see the dedicated section on default mode.

With always mode, policy enforcement is enabled on all endpoints even if no rules select specific endpoints.

If you want to configure health entity to check cluster-wide connectivity when you start cilium-agent with enable-policy: always, you will likely want to enable communications to and from the health endpoint. See Example: Add Health Endpoint.

With never mode, policy enforcement is disabled on all endpoints, even if rules do select specific endpoints. In other words, all traffic is allowed from any source (on ingress) or destination (on egress).

To configure the policy enforcement mode, adjust the Helm value policyEnforcementMode or the corresponding configuration flag enable-policy.

By default, all egress and ingress traffic is allowed for all endpoints. When an endpoint is selected by a network policy, it transitions to a default-deny state, where only explicitly allowed traffic is permitted. This state is per-direction:

If any rule selects an Endpoint and the rule has an ingress section, the endpoint goes into default deny-mode for ingress.

If any rule selects an Endpoint and the rule has an egress section, the endpoint goes into default-deny mode for egress.

This means that endpoints start without any restrictions, and the first policy will switch the endpoint’s default enforcement mode (per direction).

It is possible to create policies that do not enable the default-deny mode for selected endpoints. The field EnableDefaultDeny configures this. Rules with EnableDefaultDeny disabled are ignored when determining the default mode.

For example, this policy causes all DNS traffic to be intercepted, but does not block any traffic, even if it is the first policy to apply to an endpoint. An administrator can safely apply this policy cluster-wide, without the risk that it transitions an endpoint in to default-deny and causes legitimate traffic to be dropped.

EnableDefaultDeny does not apply to layer-7 policy. Adding a layer-7 rule that does not include a layer-7 allow-all will cause drops, even when default-deny is explicitly disabled.

All policy rules are based upon a whitelist model, that is, each rule in the policy allows traffic that matches the rule. If two rules exist, and one would match a broader set of traffic, then all traffic matching the broader rule will be allowed. If there is an intersection between two or more rules, then traffic matching the union of those rules will be allowed. Finally, if traffic does not match any of the rules, it will be dropped pursuant to the Policy Enforcement Modes.

Policy rules share a common base type which specifies which endpoints the rule applies to and common metadata to identify the rule. Each rule is split into an ingress section and an egress section. The ingress section contains the rules which must be applied to traffic entering the endpoint, and the egress section contains rules applied to traffic coming from the endpoint matching the endpoint selector. Either ingress, egress, or both can be provided. If both ingress and egress are omitted, the rule has no effect.

Selects the endpoints or nodes which the policy rules apply to. The policy rules will be applied to all endpoints which match the labels specified in the selector. For additional details, see the Endpoint Selector and Node Selector sections.

List of rules which must apply at ingress of the endpoint, i.e. to all network packets which are entering the endpoint.

List of rules which must apply at egress of the endpoint, i.e. to all network packets which are leaving the endpoint.

Labels are used to identify the rule. Rules can be listed and deleted by labels. Policy rules which are imported via kubernetes automatically get the label io.cilium.k8s.policy.name=NAME assigned where NAME corresponds to the name specified in the NetworkPolicy or CiliumNetworkPolicy resource.

Description is a string which is not interpreted by Cilium. It can be used to describe the intent and scope of the rule in a human readable form.

The Endpoint Selector is based on the Kubernetes LabelSelector. It is called Endpoint Selector because it only applies to labels associated with an Endpoint.

Like the Endpoint Selector, the Node Selector is based on the Kubernetes LabelSelector, although rather than matching on labels associated with Endpoints, it applies to labels associated with Nodes in the cluster.

Node Selectors can only be used in CiliumClusterwideNetworkPolicies. For details on the scope of node-level policies, see Host Policies.

---

## Securing gRPC — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/grpc/

**Contents:**
- Securing gRPC
- Setup Cilium
- Deploy the Demo Application
- Test Access Between gRPC Client and Server
- Securing Access to a gRPC Service with Cilium
- Clean-Up

This document serves as an introduction to using Cilium to enforce gRPC-aware security policies. It is a detailed walk-through of getting a single-node Cilium environment running on your machine. It is designed to take 15-30 minutes.

If you haven’t read the Introduction to Cilium & Hubble yet, we’d encourage you to do that first.

The best way to get help if you get stuck is to ask a question on Cilium Slack. With Cilium contributors across the globe, there is almost always someone available to help.

If you have not set up Cilium yet, follow the guide Cilium Quick Installation for instructions on how to quickly bootstrap a Kubernetes cluster and install Cilium. If in doubt, pick the minikube route, you will be good to go in less than 5 minutes.

It is important for this demo that kube-dns is working correctly. To know the status of kube-dns you can run the following command:

Where at least one pod should be available.

Now that we have Cilium deployed and kube-dns operating correctly we can deploy our demo gRPC application. Since our first demo of Cilium + HTTP-aware security policies was Star Wars-themed, we decided to do the same for gRPC. While the HTTP-aware Cilium Star Wars demo showed how the Galactic Empire used HTTP-aware security policies to protect the Death Star from the Rebel Alliance, this gRPC demo shows how the lack of gRPC-aware security policies allowed Leia, Chewbacca, Lando, C-3PO, and R2-D2 to escape from Cloud City, which had been overtaken by empire forces.

gRPC is a high-performance RPC framework built on top of the protobuf serialization/deserialization library popularized by Google. There are gRPC bindings for many programming languages, and the efficiency of the protobuf parsing as well as advantages from leveraging HTTP 2 as a transport make it a popular RPC framework for those building new microservices from scratch.

For those unfamiliar with the details of the movie, Leia and the other rebels are fleeing storm troopers and trying to reach the space port platform where the Millennium Falcon is parked, so they can fly out of Cloud City. However, the door to the platform is closed, and the access code has been changed. However, R2-D2 is able to access the Cloud City computer system via a public terminal, and disable this security, opening the door and letting the Rebels reach the Millennium Falcon just in time to escape.

In our example, Cloud City’s internal computer system is built as a set of gRPC-based microservices (who knew that gRPC was actually invented a long time ago, in a galaxy far, far away?).

With gRPC, each service is defined using a language independent protocol buffer definition. Here is the definition for the system used to manage doors within Cloud City:

To keep the setup small, we will just launch two pods to represent this setup:

cc-door-mgr: A single pod running the gRPC door manager service with label app=cc-door-mgr.

terminal-87: One of the public network access terminals scattered across Cloud City. R2-D2 plugs into terminal-87 as the rebels are desperately trying to escape. This terminal uses the gRPC client code to communicate with the door management services with label app=public-terminal.

The file cc-door-app.yaml contains a Kubernetes Deployment for the door manager service, a Kubernetes Pod representing terminal-87, and a Kubernetes Service for the door manager services. To deploy this example app, run:

Kubernetes will deploy the pods and service in the background. Running kubectl get svc,pods will inform you about the progress of the operation. Each pod will go through several states until it reaches Running at which point the setup is ready.

First, let’s confirm that the public terminal can properly act as a client to the door service. We can test this by running a Python gRPC client for the door service that exists in the terminal-87 container.

We’ll invoke the ‘cc_door_client’ with the name of the gRPC method to call, and any parameters (in this case, the door-id):

Exposing this information to public terminals seems quite useful, as it helps travelers new to Cloud City identify and locate different doors. But recall that the door service also exposes several other methods, including SetAccessCode. If access to the door manager service is protected only using traditional IP and port-based firewalling, the TCP port of the service (50051 in this example) will be wide open to allow legitimate calls like GetName and GetLocation, which also leave more sensitive calls like SetAccessCode exposed as well. It is this mismatch between the course granularity of traditional firewalls and the fine-grained nature of gRPC calls that R2-D2 exploited to override the security and help the rebels escape.

Once the legitimate owners of Cloud City recover the city from the empire, how can they use Cilium to plug this key security hole and block requests to SetAccessCode and GetStatus while still allowing GetName, GetLocation, and RequestMaintenance?

Since gRPC build on top of HTTP, this can be achieved easily by understanding how a gRPC call is mapped to an HTTP URL, and then applying a Cilium HTTP-aware filter to allow public terminals to only invoke a subset of all the total gRPC methods available on the door service.

Each gRPC method is mapped to an HTTP POST call to a URL of the form /cloudcity.DoorManager/<method-name>.

As a result, the following CiliumNetworkPolicy rule limits access of pods with label app=public-terminal to only invoke GetName, GetLocation, and RequestMaintenance on the door service, identified by label app=cc-door-mgr:

A CiliumNetworkPolicy contains a list of rules that define allowed requests, meaning that requests that do not match any rules (e.g., SetAccessCode) are denied as invalid.

The above rule applies to inbound (i.e., “ingress”) connections to cc-door-mgr pods (as indicated by app: cc-door-mgr in the “endpointSelector” section). The rule will apply to connections from pods with label app: public-terminal as indicated by the “fromEndpoints” section. The rule explicitly matches gRPC connections destined to TCP 50051, and white-lists specifically the permitted URLs.

Apply this gRPC-aware network security policy using kubectl in the main window:

After this security policy is in place, access to the innocuous calls like GetLocation still works as intended:

However, if we then again try to invoke SetAccessCode, it is denied:

This is now blocked, thanks to the Cilium network policy. And notice that unlike a traditional firewall which would just drop packets in a way indistinguishable from a network failure, because Cilium operates at the API-layer, it can explicitly reply with a custom gRPC status code 7 PERMISSION_DENIED, indicating that the request was intentionally denied for security reasons.

Thank goodness that the empire IT staff hadn’t had time to deploy Cilium on Cloud City’s internal network prior to the escape attempt, or things might have turned out quite differently for Leia and the other Rebels!

You have now installed Cilium, deployed a demo app, and tested L7 gRPC-aware network security policies. To clean-up, run:

After this, you can re-run the tutorial from Step 1.

---

## Identity-Aware and HTTP-Aware Policy Enforcement — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/http/

**Contents:**
- Identity-Aware and HTTP-Aware Policy Enforcement
- Setup Cilium

If you haven’t read the Introduction to Cilium & Hubble yet, we’d encourage you to do that first.

The best way to get help if you get stuck is to ask a question on Cilium Slack. With Cilium contributors across the globe, there is almost always someone available to help.

If you have not set up Cilium yet, follow the guide Cilium Quick Installation for instructions on how to quickly bootstrap a Kubernetes cluster and install Cilium. If in doubt, pick the minikube route, you will be good to go in less than 5 minutes.

When you have Cilium installed, follow the Getting Started with the Star Wars Demo tutorial to walk you through Identity-Aware and HTTP-Aware Policy Enforcement.

---

## Host Firewall — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/host-firewall/

**Contents:**
- Host Firewall
- Enable the Host Firewall in Cilium
- Attach a Label to the Node
- Enable Policy Audit Mode for the Host Endpoint
- Apply a Host Network Policy
- Adjust the Host Policy to Your Environment
- Disable Policy Audit Mode
- Clean up
- Further Reading
- Emergency Recovery

This document serves as an introduction to Cilium’s host firewall, to enforce security policies for Kubernetes nodes.

You can also watch a video of Cilium’s host firewall in action on eCHO Episode 40: Cilium Host Firewall.

Setup Helm repository:

Deploy Cilium release via Helm:

The devices flag refers to the network devices Cilium is configured on, such as eth0. If you omit this option, Cilium auto-detects what interfaces the host firewall applies to. The resulting interfaces are shown in the output of the cilium-dbg status command:

At this point, the Cilium-managed nodes are ready to enforce network policies.

In this guide, host policies only apply to nodes with the label node-access=ssh. Therefore, you first need to attach this label to a node in the cluster:

Host Policies enforce access control over connectivity to and from nodes. Particular care must be taken to ensure that when host policies are imported, Cilium does not block access to the nodes or break the cluster’s normal behavior (for example by blocking communication with kube-apiserver).

To avoid such issues, switch the host firewall in audit mode and validate the impact of host policies before enforcing them.

When Policy Audit Mode is enabled, no network policy is enforced so this setting is not recommended for production deployment.

Audit mode does not persist across cilium-agent restarts. Once the agent is restarted, it will immediately enforce any existing host policies.

Enable and check status for the Policy Audit Mode on the host endpoint for a given node with the following commands:

Host Policies match on node labels using a Node Selector to identify the nodes to which the policies applies. They apply only to the host namespace, including host-networking pods. They don’t apply to communications between pods or between pods and the outside of the cluster, except if those pods are host-networking pods.

The following policy applies to all nodes with the node-access=ssh label. It allows communications from outside the cluster only for TCP/22 and for ICMP (ping) echo requests. All communications from the cluster to the hosts are allowed.

To apply this policy, run:

The host is represented as a special endpoint, with label reserved:host, in the output of command cilium-dbg endpoint list. Use this command to inspect the status of host policies:

In this example, one can observe that policy enforcement on the host endpoint is in audit mode for ingress traffic, and disabled for egress traffic.

As long as the host endpoint runs in audit mode, communications disallowed by the policy are not dropped. Nevertheless, they are reported by cilium-dbg monitor, as action audit. With these reports, the audit mode allows you to adjust the host policy to your environment in order to avoid unexpected connection breakages.

For details on deriving the network policies from the output of cilium monitor, refer to Observe policy verdicts and Create the Network Policy in the Creating Policies from Verdicts guide.

Note that Entities based rules are convenient when combined with host policies, for example to allow communication to entire classes of destinations, such as all remotes nodes (remote-node) or the entire cluster (cluster).

Make sure that none of the communications required to access the cluster or for the cluster to work properly are denied. Ensure they all appear as action allow before disabling the audit mode.

Once you are confident all required communications to the host from outside the cluster are allowed, disable the policy audit mode to enforce the host policy:

Ingress host policies should now appear as enforced:

Communications that are not explicitly allowed by the host policy are now dropped:

Read the documentation on Host Policies for additional details on how to use the policies. In particular, refer to the Troubleshooting Host Policies subsection to understand how to debug issues with Host Policies, or to the section on Host Policies known issues to understand the current limitations of the feature.

As host policies control access to the node, it is possible to create a policy that drops all access to nodes. In particular, if the Cilium agent loses access to the apiserver, it will not learn of any policy updates or deletes. This makes recovery complicated.

If you have out-of-band access to the node(s), then it is possible to force-disable host policy enforcement and recover control. Start by deleting the offending host-firewall policy. Then, disable host policy enforcement manually on a node-by-node basis.

You will need to access the Cilium agent container. If kubelet still has network access, use kubectl exec:

If this is unavailable, you will need ssh or console access to the node (e.g. via IPMI). Then, use crictl exec:

This only disables host policy enforcement temporarily. Once cilium-agent is restarted, it will once again enforce host policies.

Once you have access to the Cilium container, you can temporary disable host policy enforcement by enabling audit mode for the internal host endpoint. Audit mode converts policy drops in to a warning.

At this point, cilium-agent on the node will re-connect to the apiserver and synchronize policies. To re-enable host policy enforcement, either re-start the Cilium daemonset via kubectl rollout restart or manually:

---

## Caveats — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/policy/caveats/

**Contents:**
- Caveats
- Security Identity for N/S Service Traffic
- Differences From Kubernetes Network Policies

When accessing a Kubernetes service from outside the cluster, the Identity-Based assignment depends on the routing mode.

In the tunneling mode (i.e., --tunnel-protocol=vxlan or --tunnel-protocol=geneve), the request to the service will have the reserved:world security identity.

In the native-routing mode (i.e., --routing-mode=native), the security identity will be set to the reserved:world if the request was sent to the node which runs the selected endpoint by the LB. If not, i.e., the request needs to be forwarded to another node after the service endpoint selection, then it will have the reserved:remote-node.

The latter traffic will match fromEntities: cluster policies.

When creating Cilium Network Policies it is important to keep in mind that Cilium Network Policies do not perfectly replicate the functionality of Kubernetes Network Policies. See this table for differences.

---

## Locking Down External Access Using AWS Metadata — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/aws/

**Contents:**
- Locking Down External Access Using AWS Metadata
- Setup Cilium
- Create AWS secrets
  - AWS Access keys and IAM role
- Configure AWS Security Groups
- Create a sample policy
  - Deploy a demo application:
  - Policy Language:
  - Validate that derived policy is in place

This document serves as an introduction to using Cilium to enforce policies based on AWS metadata. It provides a detailed walk-through of running a single-node Cilium environment on your machine. It is designed to take 15-30 minutes for users with some experience running Kubernetes.

This guide will work with any approach to installing Cilium, including minikube, as long as the cilium-operator pod in the deployment can reach the AWS API server However, since the most common use of this mechanism is for Kubernetes clusters running in AWS, we recommend trying it out along with the guide: Cilium Quick Installation .

Before installing Cilium, a new Kubernetes Secret with the AWS Tokens needs to be added to your Kubernetes cluster. This Secret will allow Cilium to gather information from the AWS API which is needed to implement ToGroups policies.

To create a new access token the following guide can be used. These keys need to have certain permissions set:

As soon as you have the access tokens, the following secret needs to be added, with each empty string replaced by the associated value as a base64-encoded string:

The base64 command line utility can be used to generate each value, for example:

This secret stores the AWS credentials, which will be used to connect the AWS API.

To validate that the credentials are correct, the following pod can be created for debugging purposes:

To list all of the available AWS instances, the following command can be used:

Once the secret has been created and validated, the cilium-operator pod must be restarted in order to pick up the credentials in the secret. To do this, identify and delete the existing cilium-operator pod, which will be recreated automatically:

It is important for this demo that coredns is working correctly. To know the status of coredns you can run the following command:

Where at least one pod should be available.

Cilium’s AWS Metadata filtering capability enables explicit whitelisting of communication between a subset of pods (identified by Kubernetes labels) with a set of destination EC2 ENIs (identified by membership in an AWS security group).

In this example, the destination EC2 elastic network interfaces are attached to EC2 instances that are members of a single AWS security group (‘sg-0f2146100a88d03c3’). Pods with label class=xwing should only be able to make connections outside the cluster to the destination network interfaces in that security group.

To enable this, the VMs acting as Kubernetes worker nodes must be able to send traffic to the destination VMs that are being accessed by pods. One approach for achieving this is to put all Kubernetes worker VMs in a single ‘k8s-worker’ security group, and then ensure that any security group that is referenced in a Cilium toGroups policy has an allow all ingress rule (all ports) for connections from the ‘k8s-worker’ security group. Cilium filtering will then ensure that the only pods allowed by policy can reach the destination VMs.

In this case we’re going to use a demo application that is used in other guides. These manifests will create three microservices applications: deathstar, tiefighter, and xwing. In this case, we are only going to use our xwing microservice to secure communications to existing AWS instances.

Kubernetes will deploy the pods and service in the background. Running kubectl get pods,svc will inform you about the progress of the operation. Each pod will go through several states until it reaches Running at which point the pod is ready.

ToGroups rules can be used to define policy in relation to cloud providers, like AWS.

This policy allows traffic from pod xwing to any AWS elastic network interface in the security group with ID sg-0f2146100a88d03c3.

Every time that a new policy with ToGroups rules is added, an equivalent policy (also called “derivative policy”), will be created. This policy will contain the set of CIDRs that correspond to the specification in ToGroups, e.g., the IPs of all network interfaces that are part of a specified security group. The list of IPs is updated periodically.

Eventually, the derivative policy will contain IPs in the ToCIDR section:

The derivative rule should contain the following information:

metadata.OwnerReferences: that contains the information about the ToGroups policy.

specs.Egress.ToCIDRSet: the list of private and public IPs of the instances that correspond to the spec of the parent policy.

status: whether or not the policy is enforced yet, and when the policy was last updated.

The endpoint status for the xwing should have policy enforcement enabled only for egress connectivity:

In this example, xwing pod can only connect to 34.254.113.42/32 and 172.31.44.160/32 and connectivity to other IP will be denied.

---

## Security Identities — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/internals/security-identities/

**Contents:**
- Security Identities
- Cluster-local
- Clustermesh
- CIDR-based identity
- Node-local identity

Security identities are generated from labels. They are stored as uint32, which means the maximum limit for a security identity is 2^32 - 1. The minimum security identity is 1.

Identity 0 is not a valid value. If it shows up in Hubble output, this means the identity was not found. In the eBPF datapath, it has a special role where it denotes “any identity”, i.e. as a wildcard allow in policy maps.

Security identities span over several ranges, depending on the context:

Identities generated from CIDR-based policies

Identities generated for remote nodes (optional)

Cluster-local identities (1) range from 1 to 2^16 - 1. The lowest values, from 1 to 255, correspond to the reserved identity range. See the internal code documentation for details.

For ClusterMesh (2), 8 bits are used as the cluster-id which identifies the cluster in the ClusterMesh, into the 3rd octet as shown by 0x00FF0000. The 4th octet (uppermost bits) must be set to 0 as well. Neither of these constraints apply CIDR identities however, see (3).

CIDR identities (3) are local to each node. CIDR identities begin from 1 and end at 16777215, however since they’re shifted by 24, this makes their effective range 1 | (1 << 24) to 16777215 | (1 << 24) or from 16777217 to 33554431. When CIDR policies are applied, the identity generated is local to each node. In other words, the identity may not be the same for the same CIDR policy across two nodes.

Remote-node identities (4) are also local to each node. Functionally, they work much the same as CIDR identities: they are local to each node, potentially differing across nodes on the cluster. They are used when the option policy-cidr-match-mode includes nodes or when enable-node-selector-labels is set to true.

Node-local identities (CIDR or remote-node) are never used for traffic between Cilium-managed nodes, so they do not need to fit inside of a VXLAN or Geneve virtual network field. Non-CIDR identities are limited to 24 bits so that they will fit in these fields on the wire, but since CIDR identities will not be encoded in these packets, they can start with a higher value. Hence, the minimum value for a CIDR identity is 2^24 + 1.

Overall, the following represents the different ranges:

---

## Threat Model — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/threat-model/

**Contents:**
- Threat Model
- Scope and Prerequisites
- Methodology
- Reference Architecture
  - The Threat Surface
- The Threat Model
  - Kubernetes Workload Attacker
    - Recommended Controls
  - Limited-privilege Host Attacker
    - Recommended Controls

This section presents a threat model for Cilium. This threat model allows interested parties to understand:

security-specific implications of Cilium’s architecture

controls that are in place to secure data flowing through Cilium’s various components

recommended controls for running Cilium in a production environment

This threat model considers the possible attacks that could affect an up-to-date version of Cilium running in a production environment; it will be refreshed when there are significant changes to Cilium’s architecture or security posture.

This model does not consider supply-chain attacks, such as attacks where a malicious contributor is able to intentionally inject vulnerable code into Cilium. For users who are concerned about supply-chain attacks, Cilium’s security audit assessed Cilium’s supply chain controls against the SLSA framework.

In order to understand the following threat model, readers will need familiarity with basic Kubernetes concepts, as well as a high-level understanding of Cilium’s architecture and components.

This threat model considers eight different types of threat actors, placed at different parts of a typical deployment stack. We will primarily use Kubernetes as an example but the threat model remains accurate if deployed with other orchestration systems, or when running Cilium outside of Kubernetes. The attackers will have different levels of initial privileges, giving us a broad overview of the security guarantees that Cilium can provide depending on the nature of the threat and the extent of a previous compromise.

For each threat actor, this guide uses the the STRIDE methodology to assess likely attacks. Where one attack type in the STRIDE set can lead to others (for example, tampering leading to denial of service), we have described the attack path under the most impactful attack type. For the potential attacks that we identify, we recommend controls that can be used to reduce the risk of the identified attacks compromising a cluster. Applying the recommended controls is strongly advised in order to run Cilium securely in production.

For ease of understanding, consider a single Kubernetes cluster running Cilium, as illustrated below:

In the above scenario, the aim of Cilium’s security controls is to ensure that all the components of the Cilium platform are operating correctly, to the extent possible given the abilities of the threat actor that Cilium is faced with. The key components that need to be protected are:

the Cilium agent running on a node, either as a Kubernetes pod, a host process, or as an entire virtual machine

Cilium state (either stored via CRDs or via an external key-value store like etcd)

eBPF programs loaded by Cilium into the kernel

network packets managed by Cilium

observability data collected by Cilium and stored by Hubble

For each type of attacker, we consider the plausible types of attacks available to them, how Cilium can be used to protect against these attacks, as well as the security controls that Cilium provides. For attacks which might arise as a consequence of the high level of privileges required by Cilium, we also suggest mitigations that users should apply to secure their environments.

For the first scenario, consider an attacker who has been able to gain access to a Kubernetes pod, and is now able to run arbitrary code inside a container. This could occur, for example, if a vulnerable service is exposed externally to a network. In this case, let us also assume that the compromised pod does not have any elevated privileges (in Kubernetes or on the host) or direct access to host files.

In this scenario, there is no potential for compromise of the Cilium stack; in fact, Cilium provides several features that would allow users to limit the scope of such an attack:

Identified STRIDE threats

Cilium security benefits

Potential denial of service if the compromised

Kubernetes workload does not have defined resource limits.

Cilium can enforce bandwidth limitations on pods to limit the network resource utilization.

Cilium’s network policy can be used to provide least-privilege isolation between Kubernetes workloads, and between Kubernetes workloads and “external” endpoints running outside the Kubernetes cluster, or running on the Kubernetes worker nodes. Users should ideally define specific allow rules that only permit expected communication between services.

Cilium’s network connectivity will prevent an attacker from observing the traffic intended for other workloads, or sending traffic that “spoofs” the identity of another pod, even if transparent encryption is not in use. Pods cannot send traffic that “spoofs” other pods due to limits on the use of source IPs and limits on sending tunneled traffic.

Cilium’s Hubble flow-event observability can be used to provide reliable audit of the attacker’s L3/L4 and L7 network connectivity.

Kubernetes workloads should have defined resource limits. This will help in ensuring that Cilium is not starved of resources due to a misbehaving deployment in a cluster.

Cilium can be given prioritized access to system resources either via Kubernetes, cgroups, or other controls.

Runtime security solutions such as Tetragon should be deployed to ensure that container compromises can be detected as they occur.

In this scenario, the attacker is someone with the ability to run arbitrary code with direct access to the host PID or network namespace (or both), but without “root”-equivalent privileges that would allow them to disable Cilium components or undermine the eBPF and other kernel state Cilium relies on.

This level of access could exist for a variety of reasons, including:

Pods or other containers running in the host PID or network namespace, but without “root” privileges or capabilities. This includes hostNetwork: true and hostPID: true containers.

Non-“root” SSH or other console access to a node.

A containerized workload that has “escaped” the container namespace but as a non-privileged user.

In this case, an attacker would be able to bypass some of Cilium’s network controls, as described below:

Identified STRIDE threats

Cilium security benefits

If the non-privileged attacker is able to access the container runtime and Cilium is running as a container, the attacker will be able to tamper with the Cilium agent running on the node.

Denial of service is also possible via spawning workloads directly on the host.

Same as for the Cilium agent.

Same as for the Cilium agent.

Elevation of privilege: traffic sent by the attacker will no longer be subject to Kubernetes or container-networked Cilium network policies. Host-networked Cilium policies will continue to apply. Other traffic within the cluster remains unaffected.

Cilium’s network connectivity will prevent an attacker from observing the traffic intended for other workloads, or sending traffic that spoofs the identity of another pod, even if transparent encryption is not in use.

Cilium’s Hubble flow-event observability can be used to provide reliable audit of the attacker’s L3/L4 and L7 network connectivity. Traffic sent by the attacker will be attributed to the worker node, and not to a specific Kubernetes workload.

In addition to the recommended controls against the Kubernetes Workload Attacker:

Container images should be regularly patched to reduce the chance of compromise.

Minimal container images should be used where possible.

Host-level privileges should be avoided where possible.

Ensure that the container users do not have access to the underlying container runtime.

A “root” privilege host attacker has full privileges to do everything on the local host. This access could exist for several reasons, including:

Root SSH or other console access to the Kubernetes worker node.

A containerized workload that has escaped the container namespace as a privileged user.

Pods running with privileged: true or other significant capabilities like CAP_BPF, CAP_NET_ADMIN, CAP_NET_RAW, or CAP_SYS_ADMIN.

Identified STRIDE threats

In this situation, all potential attacks covered by STRIDE are possible. Of note:

The attacker would be able to disable eBPF on the node, disabling Cilium’s network and runtime visibility and enforcement. All further operations by the attacker will be unlimited and unaudited.

The attacker would be able to observe network connectivity across all workloads on the host.

The attacker can spoof traffic from the node such that it appears to come from pods with any identity.

If the physical network allows ARP poisoning, or if any other attack allows a compromised node to “attract” traffic destined to other nodes, the attacker can potentially intercept all traffic in the cluster, even if this traffic is encrypted using IPsec, since we use a cluster-wide pre-shared key.

The attacker can also use Cilium’s credentials to attack the Kubernetes API server, as well as Cilium’s etcd key-value store (if in use).

If the compromised node is running the cilium-operator pod, the attacker would be able to carry out denial of service attacks against other nodes using the cilium-operator service account credentials found on the node.

This attack scenario emphasizes the importance of securing Kubernetes nodes, minimizing the permissions available to container workloads, and monitoring for suspicious activity on the node, container, and API server levels.

In addition to the controls against a Limited-privilege Host Attacker:

Workloads with privileged access should be reviewed; privileged access should only be provided to deployments if essential.

Network policies should be configured to limit connectivity to workloads with privileged access.

Kubernetes audit logging should be enabled, with audit logs being sent to a centralized external location for automated review.

Detections should be configured to alert on suspicious activity.

cilium-operator pods should not be scheduled on nodes that run regular workloads, and should instead be configured to run on control plane nodes.

In this scenario, our attacker has access to the underlying network between Kubernetes worker nodes, but not the Kubernetes worker nodes themselves. This attacker may inspect, modify, or inject malicious network traffic.

The threat matrix for such an attacker is as follows:

Identified STRIDE threats

Without transparent encryption, an attacker could inspect traffic between workloads in both overlay and native routing modes.

An attacker with knowledge of pod network configuration (including pod IP addresses and ports) could inject traffic into a cluster by forging packets.

Denial of service could occur depending on the behavior of the attacker.

TLS is required for all connectivity between Cilium components, as well as for exporting data to other destinations, removing the scope for spoofing or tampering.

Without transparent encryption, the attacker could re-create the observability data as available on the network level.

Information leakage could occur via an attacker scraping Hubble Prometheus metrics. These metrics are disabled by default, and can contain sensitive information on network flows.

Denial of service could occur depending on the behavior of the attacker.

Transparent Encryption should be configured to ensure the confidentiality of communication between workloads.

TLS should be configured for communication between the Prometheus metrics endpoints and the Prometheus server.

Network policies should be configured such that only the Prometheus server is allowed to scrape Hubble metrics in particular.

In our threat model, a generic network attacker has access to the same underlying IP network as Kubernetes worker nodes, but is not inline between the nodes. The assumption is that this attacker is still able to send IP layer traffic that reaches a Kubernetes worker node. This is a weaker variant of the man-in-the-middle attack described above, as the attacker can only inject traffic to worker nodes, but not see the replies.

For such an attacker, the threat matrix is as follows:

Identified STRIDE threats

An attacker with knowledge of pod network configuration (including pod IP addresses and ports) could inject traffic into a cluster by forging packets.

Denial of service could occur depending on the behavior of the attacker.

Denial of service could occur depending on the behavior of the attacker.

Information leakage could occur via an attacker scraping Cilium or Hubble Prometheus metrics, depending on the specific metrics enabled.

Transparent Encryption should be configured to ensure the confidentiality of communication between workloads.

This type of attack could be carried out by any user or code with network access to the Kubernetes API server and credentials that allow Kubernetes API requests. Such permissions would allow the user to read or manipulate the API server state (for example by changing CRDs).

This section is intended to cover any attack that might be exposed via Kubernetes API server access, regardless of whether the access is full or limited.

For such an attacker, our threat matrix is as follows:

Identified STRIDE threats

A Kubernetes API user with kubectl exec access to the pod running Cilium effectively becomes a root-equivalent host attacker, since Cilium runs as a privileged pod.

An attacker with permissions to configure workload settings effectively becomes a Kubernetes Workload Attacker.

The ability to modify the Cilium* CustomResourceDefinitions, as well as any CustomResource from Cilium, in the cluster could have the following effects:

The ability to create or modify CiliumIdentity and CiliumEndpoint or CiliumEndpointSlice resources would allow an attacker to tamper with the identities of pods.

The ability to delete Kubernetes or Cilium NetworkPolicies would remove policy enforcement.

Creating a large number of CiliumIdentity resources could result in denial of service.

Workloads external to the cluster could be added to the network.

Traffic routing settings between workloads could be modified

The cumulative effect of such actions could result in the escalation of a single-node compromise into a multi-node compromise.

An attacker with kubectl exec access to the Cilium agent pod will be able to modify eBPF programs.

Privileged Kubernetes API server access (exec access to Cilium pods or access to view Kubernetes secrets) could allow an attacker to access the pre-shared key used for IPsec. When used by a man-in-the-middle attacker, this could undermine the confidentiality and integrity of workload communication. Depending on the attacker’s level of access, the ability to spoof identities or tamper with policy enforcement could also allow them to view network data.

Users with permissions to configure workload settings could cause denial of service.

Kubernetes RBAC should be configured to only grant necessary permissions to users and service accounts. Access to resources in the kube-system and cilium namespaces in particular should be highly limited.

Kubernetes audit logs should be used to automatically review requests made to the API server, and detections should be configured to alert on suspicious activity.

Cilium can use an external key-value store such as etcd to store state. In this scenario, we consider a user with network access to the Cilium etcd endpoints and credentials to access those etcd endpoints. The credentials to the etcd endpoints are stored as Kubernetes secrets; any attacker would first have to compromise these secrets before gaining access to the key-value store.

Identified STRIDE threats

The ability to create or modify Identities or Endpoints in etcd would allow an attacker to “give” any pod any identity. The ability to spoof identities in this manner might be used to escalate a single node compromise to a multi-node compromise, for example by spoofing identities to undermine ingress segmentation rules that would be applied on remote nodes.

An attacker would be able to modify the routing of traffic within a cluster, and as a consequence gain the privileges of a Man-in-the-middle Attacker.

The etcd instance deployed to store Cilium configuration should be independent of the instance that is typically deployed as part of configuring a Kubernetes cluster. This separation reduces the risk of a Cilium etcd compromise leading to further cluster-wide impact.

Kubernetes RBAC controls should be applied to restrict access to Kubernetes secrets.

Kubernetes audit logs should be used to detect access to secret data and alert if such access is suspicious.

This is an attacker with network reachability to Kubernetes worker nodes, or other systems that store or expose Hubble data, with the goal of gaining access to potentially sensitive Hubble flow or process data.

Identified STRIDE threats

None, assuming correct configuration of the following:

Network policy to limit access to hubble-relay or hubble-ui services

Limited access to cilium, hubble-relay, or hubble-ui pods

TLS for external data export

Security controls at the destination of any exported data

Network policies should limit access to the hubble-relay and hubble-ui services

Kubernetes RBAC should be used to limit access to any cilium-* or hubble-`* pods

TLS should be configured for access to the Hubble Relay API and Hubble UI

TLS should be correctly configured for any data export

The destination data stores for exported data should be secured (such as by applying encryption at rest and cloud provider specific RBAC controls, for example)

To summarize the recommended controls to be used when configuring a production Kubernetes cluster with Cilium:

Ensure that Kubernetes roles are scoped correctly to the requirements of your users, and that service account permissions for pods are tightly scoped to the needs of the workloads. In particular, access to sensitive namespaces, exec actions, and Kubernetes secrets should all be highly controlled.

Use resource limits for workloads where possible to reduce the chance of denial of service attacks.

Ensure that workload privileges and capabilities are only granted when essential to the functionality of the workload, and ensure that specific controls to limit and monitor the behavior of the workload are in place.

Use network policies to ensure that network traffic in Kubernetes is segregated.

Use Transparent Encryption in Cilium to ensure that communication between workloads is secured.

Enable Kubernetes audit logging, forward the audit logs to a centralized monitoring platform, and define alerting for suspicious activity.

Enable TLS for access to any externally-facing services, such as Hubble Relay and Hubble UI.

Use Tetragon as a runtime security solution to rapidly detect unexpected behavior within your Kubernetes cluster.

If you have questions, suggestions, or would like to help improve Cilium’s security posture, reach out to security@cilium.io.

---

## Securing a Kafka Cluster — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/kafka/

**Contents:**
- Securing a Kafka Cluster
- Setup Cilium
- Deploy the Demo Application
- Setup Client Terminals
- Test Basic Kafka Produce & Consume
- The Danger of a Compromised Kafka Client
- Securing Access to Kafka with Cilium
- Clean Up

This document serves as an introduction to using Cilium to enforce Kafka-aware security policies. It is a detailed walk-through of getting a single-node Cilium environment running on your machine. It is designed to take 15-30 minutes.

If you haven’t read the Introduction to Cilium & Hubble yet, we’d encourage you to do that first.

The best way to get help if you get stuck is to ask a question on Cilium Slack. With Cilium contributors across the globe, there is almost always someone available to help.

If you have not set up Cilium yet, follow the guide Cilium Quick Installation for instructions on how to quickly bootstrap a Kubernetes cluster and install Cilium. If in doubt, pick the minikube route, you will be good to go in less than 5 minutes.

Now that we have Cilium deployed and kube-dns operating correctly we can deploy our demo Kafka application. Since our first demo of Cilium + HTTP-aware security policies was Star Wars-themed we decided to do the same for Kafka. While the HTTP-aware Cilium Star Wars demo showed how the Galactic Empire used HTTP-aware security policies to protect the Death Star from the Rebel Alliance, this Kafka demo shows how the lack of Kafka-aware security policies allowed the Rebels to steal the Death Star plans in the first place.

Kafka is a powerful platform for passing datastreams between different components of an application. A cluster of “Kafka brokers” connect nodes that “produce” data into a data stream, or “consume” data from a datastream. Kafka refers to each datastream as a “topic”. Because scalable and highly-available Kafka clusters are non-trivial to run, the same cluster of Kafka brokers often handles many different topics at once (read this Introduction to Kafka for more background).

In our simple example, the Empire uses a Kafka cluster to handle two different topics:

empire-announce : Used to broadcast announcements to sites spread across the galaxy

deathstar-plans : Used by a small group of sites coordinating on building the ultimate battlestation.

To keep the setup small, we will just launch a small number of pods to represent this setup:

kafka-broker : A single pod running Kafka and Zookeeper representing the Kafka cluster (label app=kafka).

empire-hq : A pod representing the Empire’s Headquarters, which is the only pod that should produce messages to empire-announce or deathstar-plans (label app=empire-hq).

empire-backup : A secure backup facility located in Scarif , which is allowed to “consume” from the secret deathstar-plans topic (label app=empire-backup).

empire-outpost-8888 : A random outpost in the empire. It needs to “consume” messages from the empire-announce topic (label app=empire-outpost).

empire-outpost-9999 : Another random outpost in the empire that “consumes” messages from the empire-announce topic (label app=empire-outpost).

All pods other than kafka-broker are Kafka clients, which need access to the kafka-broker container on TCP port 9092 in order to send Kafka protocol messages.

The file kafka-sw-app.yaml contains a Kubernetes Deployment for each of the pods described above, as well as a Kubernetes Service for both Kafka and Zookeeper.

Kubernetes will deploy the pods and service in the background. Running kubectl get svc,pods will inform you about the progress of the operation. Each pod will go through several states until it reaches Running at which point the setup is ready.

First we will open a set of windows to represent the different Kafka clients discussed above. For consistency, we recommend opening them in the pattern shown in the image below, but this is optional.

In each window, use copy-paste to have each terminal provide a shell inside each pod.

empire-backup terminal:

outpost-8888 terminal:

outpost-9999 terminal:

First, let’s start the consumer clients listening to their respective Kafka topics. All of the consumer commands below will hang intentionally, waiting to print data they consume from the Kafka topic:

In the empire-backup window, start listening on the top-secret deathstar-plans topic:

In the outpost-8888 window, start listening to empire-announcement:

Do the same in the outpost-9999 window:

Now from the empire-hq, first produce a message to the empire-announce topic:

This message will be posted to the empire-announce topic, and shows up in both the outpost-8888 and outpost-9999 windows who consume that topic. It will not show up in empire-backup.

empire-hq can also post a version of the top-secret deathstar plans to the deathstar-plans topic:

This message shows up in the empire-backup window, but not for the outposts.

Congratulations, Kafka is working as expected :)

But what if a rebel spy gains access to any of the remote outposts that act as Kafka clients? Since every client has access to the Kafka broker on port 9092, it can do some bad stuff. For starters, the outpost container can actually switch roles from a consumer to a producer, sending “malicious” data to all other consumers on the topic.

To prove this, kill the existing kafka-consume.sh command in the outpost-9999 window by typing control-C and instead run:

Uh oh! Outpost-8888 and all of the other outposts in the empire have now received this fake announcement.

But even more nasty from a security perspective is that the outpost container can access any topic on the kafka-broker.

In the outpost-9999 container, run:

We see that any outpost can actually access the secret deathstar plans. Now we know how the rebels got access to them!

Obviously, it would be much more secure to limit each pod’s access to the Kafka broker to be least privilege (i.e., only what is needed for the app to operate correctly and nothing more).

We can do that with the following Cilium security policy. As with Cilium HTTP policies, we can write policies that identify pods by labels, and then limit the traffic in/out of this pod. In this case, we’ll create a policy that identifies the exact traffic that should be allowed to reach the Kafka broker, and deny the rest.

As an example, a policy could limit containers with label app=empire-outpost to only be able to consume topic empire-announce, but would block any attempt by a compromised container (e.g., empire-outpost-9999) from producing to empire-announce or consuming from deathstar-plans.

Here is the CiliumNetworkPolicy rule that limits access of pods with label app=empire-outpost to only consume on topic empire-announce:

A CiliumNetworkPolicy contains a list of rules that define allowed requests, meaning that requests that do not match any rules are denied as invalid.

The above rule applies to inbound (i.e., “ingress”) connections to kafka-broker pods (as indicated by “app: kafka” in the “endpointSelector” section). The rule will apply to connections from pods with label “app: empire-outpost” as indicated by the “fromEndpoints” section. The rule explicitly matches Kafka connections destined to TCP 9092, and allows consume/produce actions on various topics of interest. For example we are allowing consume from topic empire-announce in this case.

The full policy adds two additional rules that permit the legitimate “produce” (topic empire-announce and topic deathstar-plans) from empire-hq and the legitimate consume (topic = “deathstar-plans”) from empire-backup. The full policy can be reviewed by opening the URL in the command below in a browser.

Apply this Kafka-aware network security policy using kubectl in the main window:

If we then again try to produce a message from outpost-9999 to empire-annnounce, it is denied. Type control-c and then run:

This is because the policy does not allow messages with role = “produce” for topic “empire-announce” from containers with label app = empire-outpost. Its worth noting that we don’t simply drop the message (which could easily be confused with a network error), but rather we respond with the Kafka access denied error (similar to how HTTP would return an error code of 403 unauthorized).

Likewise, if the outpost container ever tries to consume from topic deathstar-plans, it is denied, as role = consume is only allowed for topic empire-announce.

To test, from the outpost-9999 terminal, run:

This is blocked as well, thanks to the Cilium network policy. Imagine how different things would have been if the empire had been using Cilium from the beginning!

You have now installed Cilium, deployed a demo app, and tested both L7 Kafka-aware network security policies. To clean up, run:

After this, you can re-run the tutorial from Step 1.

---

## Troubleshooting — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/policy/troubleshooting/

**Contents:**
- Troubleshooting
- Policy Rule to Endpoint Mapping
- Troubleshooting toFQDNs rules
  - Monitoring toFQDNs identity usage

To determine which policy rules are currently in effect for an endpoint the data from cilium-dbg endpoint list and cilium-dbg endpoint get can be paired with the data from cilium-dbg policy get. cilium-dbg endpoint get will list the labels of each rule that applies to an endpoint. The list of labels can be passed to cilium-dbg policy get to show that exact source policy. Note that rules that have no labels cannot be fetched alone (a no label cilium-dbg policy get returns the complete policy on the node). Rules with the same labels will be returned together.

In the above example, for one of the deathstar pods the endpoint id is 568. We can print all policies applied to it with:

The effect of toFQDNs may change long after a policy is applied, as DNS data changes. This can make it difficult to debug unexpectedly blocked connections, or transient failures. Cilium provides CLI tools to introspect the state of applying FQDN policy in multiple layers of the daemon:

cilium-dbg policy get should show the FQDN policy that was imported:

After making a DNS request, the FQDN to IP mapping should be available via cilium-dbg fqdn cache list:

If the traffic is allowed, then these IPs should have corresponding local identities via cilium-dbg ip list | grep <IP>:

When using toFQDNs selectors, every IP observed by a matching DNS lookup will be labeled with that selector. As a DNS name might be matched by multiple selectors, and because an IP might map to multiple names, an IP might be labeled by multiple selectors. As with regular cluster identities, every unique combination of labels will allocate its own numeric security identity. This can lead to many different identities being allocated, as described in Limiting Identity-Relevant Labels.

To detect potential identity exhaustion for toFQDNs identities, the number allocated FQDN identities can be monitored using the identity_label_sources{type="fqdn"} metric. As a comparative reference the fqdn_selectors metric monitors the number of registered toFQDNs selectors. For more details on metrics, please refer to Monitoring & Metrics.

---

## Creating Policies from Verdicts — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/policy-creation/

**Contents:**
- Creating Policies from Verdicts
- Setup Cilium
- Deploy the Demo Application
- Scale down the deathstar Deployment
- Enable Policy Audit Mode (Entire Daemon)
- Enable Policy Audit Mode (Specific Endpoint)
- Observe policy verdicts
- Create the Network Policy
- Disable Policy Audit Mode (Entire Daemon)
- Disable Policy Audit Mode (Specific Endpoint)

Policy Audit Mode configures Cilium to allow all traffic while logging all connections that would otherwise be dropped by network policies. Policy Audit Mode may be configured for the entire daemon using --policy-audit-mode=true or for individual Cilium Endpoints. When Policy Audit Mode is enabled, no network policy is enforced so this setting is not recommended for production deployment. Policy Audit Mode supports auditing network policies implemented at networks layers 3 and 4. This guide walks through the process of creating policies using Policy Audit Mode.

If you haven’t read the Introduction to Cilium & Hubble yet, we’d encourage you to do that first.

The best way to get help if you get stuck is to ask a question on Cilium Slack. With Cilium contributors across the globe, there is almost always someone available to help.

If you have not set up Cilium yet, follow the guide Cilium Quick Installation for instructions on how to quickly bootstrap a Kubernetes cluster and install Cilium. If in doubt, pick the minikube route, you will be good to go in less than 5 minutes.

When we have Cilium deployed and kube-dns operating correctly we can deploy our demo application.

In our Star Wars-inspired example, there are three microservices applications: deathstar, tiefighter, and xwing. The deathstar runs an HTTP webservice on port 80, which is exposed as a Kubernetes Service to load-balance requests to deathstar across two pod replicas. The deathstar service provides landing services to the empire’s spaceships so that they can request a landing port. The tiefighter pod represents a landing-request client service on a typical empire ship and xwing represents a similar service on an alliance ship. They exist so that we can test different security policies for access control to deathstar landing services.

Application Topology for Cilium and Kubernetes

The file http-sw-app.yaml contains a Kubernetes Deployment for each of the three services. Each deployment is identified using the Kubernetes labels (org=empire, class=deathstar), (org=empire, class=tiefighter), and (org=alliance, class=xwing). It also includes a deathstar-service, which load-balances traffic to all pods with label (org=empire, class=deathstar).

Kubernetes will deploy the pods and service in the background. Running kubectl get pods,svc will inform you about the progress of the operation. Each pod will go through several states until it reaches Running at which point the pod is ready.

Each pod will be represented in Cilium as an Endpoint in the local cilium agent. We can invoke the cilium-dbg tool inside the Cilium pod to list them (in a single-node installation kubectl -n kube-system exec ds/cilium -- cilium-dbg endpoint list lists them all, but in a multi-node installation, only the ones running on the same node will be listed):

Both ingress and egress policy enforcement is still disabled on all of these pods because no network policy has been imported yet which select any of the pods.

In this guide we’re going to scale down the deathstar Deployment in order to simplify the next steps:

To observe policy audit messages for all endpoints managed by this Daemonset, modify the Cilium ConfigMap and restart all daemons:

If you installed Cilium via helm install, then you can use helm upgrade to enable Policy Audit Mode:

Cilium can enable Policy Audit Mode for a specific endpoint. This may be helpful when enabling Policy Audit Mode for the entire daemon is too broad. Enabling per endpoint will ensure other endpoints managed by the same daemon are not impacted.

This approach is meant to be temporary. Restarting Cilium pod will reset the Policy Audit Mode to match the daemon’s configuration.

Policy Audit Mode is enabled for a given endpoint by modifying the endpoint configuration via the cilium-dbg tool on the endpoint’s Kubernetes node. The steps include:

Determine the endpoint id on which Policy Audit Mode will be enabled.

Identify the Cilium pod running on the same Kubernetes node corresponding to the endpoint.

Using the Cilium pod above, modify the endpoint configuration by setting PolicyAuditMode=Enabled.

The following shell commands perform these steps:

We can check that Policy Audit Mode is enabled for this endpoint with

In this example, we are tasked with applying security policy for the deathstar. First, from the Cilium pod we need to monitor the notifications for policy verdicts using the Hubble CLI. We’ll be monitoring for inbound traffic towards the deathstar to identify it and determine whether to extend the network policy to allow that traffic.

Apply a default-deny policy:

CiliumNetworkPolicies match on pod labels using an endpointSelector to identify the sources and destinations to which the policy applies. The above policy denies traffic sent to any pods with label (org=empire). Due to the Policy Audit Mode enabled above (either for the entire daemon, or for just the deathstar endpoint), the traffic will not actually be denied but will instead trigger policy verdict notifications.

To apply this policy, run:

With the above policy, we will enable a default-deny posture on ingress to pods with the label org=empire and enable the policy verdict notifications for those pods. The same principle applies on egress as well.

Now let’s send some traffic from the tiefighter to the deathstar:

We can check the policy verdict from the Cilium Pod:

In the above example, we can see that the Pod deathstar-6fb5694d48-5hmds has received traffic from the tiefighter Pod which doesn’t match the policy (policy-verdict:none AUDITED).

We can get more information about the flow with

Given the above information, we now know the labels of the source and destination Pods, the traffic direction, and the destination port. In this case, we can see clearly that the source (i.e. the tiefighter Pod) is an empire aircraft (as it has the org=empire label) so once we’ve determined that we expect this traffic to arrive at the deathstar, we can form a policy to match the traffic:

To apply this L3/L4 policy, run:

Now if we run the landing requests again,

we can then observe that the traffic which was previously audited to be dropped by the policy is reported as allowed:

Now the policy verdict states that the traffic would be allowed: policy-verdict:L3-L4 ALLOWED. Success!

These steps should be repeated for each connection in the cluster to ensure that the network policy allows all of the expected traffic. The final step after deploying the policy is to disable Policy Audit Mode again:

These steps are nearly identical to enabling Policy Audit Mode.

Alternatively, restarting the Cilium pod will set the endpoint Policy Audit Mode to the daemon set configuration.

Now if we run the landing requests again, only the tiefighter pods with the label org=empire should succeed:

And we can observe that the traffic was allowed by the policy:

This works as expected. Now the same request from an xwing Pod should fail:

This curl request should timeout after three seconds, we can observe the policy verdict with:

We hope you enjoyed the tutorial. Feel free to play more with the setup, follow the Identity-Aware and HTTP-Aware Policy Enforcement guide, and reach out to us on Cilium Slack with any questions!

---

## Layer 3 Examples — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/policy/language/

**Contents:**
- Layer 3 Examples
- Endpoints based
  - Ingress
  - Simple Ingress Allow
  - Ingress Allow All Endpoints
  - Egress
  - Simple Egress Allow
  - Egress Allow All Endpoints
  - Ingress/Egress Default Deny
  - Additional Label Requirements

The layer 3 policy establishes the base connectivity rules regarding which endpoints can talk to each other. Layer 3 policies can be specified using the following methods:

Endpoints based: This is used to describe the relationship if both endpoints are managed by Cilium and are thus assigned labels. The advantage of this method is that IP addresses are not encoded into the policies and the policy is completely decoupled from the addressing.

Services based: This is an intermediate form between Labels and CIDR and makes use of the services concept in the orchestration system. A good example of this is the Kubernetes concept of Service endpoints which are automatically maintained to contain all backend IP addresses of a service. This allows to avoid hardcoding IP addresses into the policy even if the destination endpoint is not controlled by Cilium.

Entities based: Entities are used to describe remote peers which can be categorized without knowing their IP addresses. This includes connectivity to the local host serving the endpoints or all connectivity to outside of the cluster.

Node based: This is an extension of remote-node entity. Optionally nodes can have unique identity that can be used to allow/block access only from specific ones.

IP/CIDR based: This is used to describe the relationship to or from external services if the remote peer is not an endpoint. This requires to hardcode either IP addresses or subnets into the policies. This construct should be used as a last resort as it requires stable IP or subnet assignments.

DNS based: Selects remote, non-cluster, peers using DNS names converted to IPs via DNS lookups. It shares all limitations of the IP/CIDR based rules above. DNS information is acquired by routing DNS traffic via a proxy. DNS TTLs are respected.

Endpoints-based L3 policy is used to establish rules between endpoints inside the cluster managed by Cilium. Endpoints-based L3 policies are defined by using an Endpoint Selector inside a rule to select what kind of traffic can be received (on ingress), or sent (on egress). An empty Endpoint Selector allows all traffic. The examples below demonstrate this in further detail.

Kubernetes: See section Namespaces for details on how the Endpoint Selector applies in a Kubernetes environment with regard to namespaces.

An endpoint is allowed to receive traffic from another endpoint if at least one ingress rule exists which selects the destination endpoint with the Endpoint Selector in the endpointSelector field. To restrict traffic upon ingress to the selected endpoint, the rule selects the source endpoint with the Endpoint Selector in the fromEndpoints field.

The following example illustrates how to use a simple ingress rule to allow communication from endpoints with the label role=frontend to endpoints with the label role=backend.

An empty Endpoint Selector will select all endpoints, thus writing a rule that will allow all ingress traffic to an endpoint may be done as follows:

Note that while the above examples allow all ingress traffic to an endpoint, this does not mean that all endpoints are allowed to send traffic to this endpoint per their policies. In other words, policy must be configured on both sides (sender and receiver).

An endpoint is allowed to send traffic to another endpoint if at least one egress rule exists which selects the destination endpoint with the Endpoint Selector in the endpointSelector field. To restrict traffic upon egress to the selected endpoint, the rule selects the destination endpoint with the Endpoint Selector in the toEndpoints field.

The following example illustrates how to use a simple egress rule to allow communication to endpoints with the label role=backend from endpoints with the label role=frontend.

An empty Endpoint Selector will select all egress endpoints from an endpoint based on the CiliumNetworkPolicy namespace (default by default). The following rule allows all egress traffic from endpoints with the label role=frontend to all other endpoints in the same namespace:

Note that while the above examples allow all egress traffic from an endpoint, the receivers of the egress traffic may have ingress rules that deny the traffic. In other words, policy must be configured on both sides (sender and receiver).

An endpoint can be put into the default deny mode at ingress or egress if a rule selects the endpoint and contains the respective rule section ingress or egress.

Any rule selecting the endpoint will have this effect, this example illustrates how to put an endpoint into default deny mode without whitelisting other peers at the same time.

The fromRequires and toRequires fields are deprecated as of Cilium 1.17.x. They will be dropped from support in Cilium 1.18.

It is often required to apply the principle of separation of concern when defining policies. For this reason, an additional construct exists which allows to establish base requirements for any connectivity to happen.

For this purpose, the fromRequires field can be used to establish label requirements which serve as a foundation for any fromEndpoints relationship. fromRequires is a list of additional constraints which must be met in order for the selected endpoints to be reachable. These additional constraints do not grant access privileges by themselves, so to allow traffic there must also be rules which match fromEndpoints. The same applies for egress policies, with toRequires and toEndpoints.

The purpose of this rule is to allow establishing base requirements such as, any endpoint in env=prod can only be accessed if the source endpoint also carries the label env=prod.

toRequires and fromRequires apply to all rules that share the same endpoint selector and are not limited by other egress or ingress rules. As a result toRequires and fromRequires limits all ingress and egress traffic that applies to its endpoint selector. An important implication of the fact that toRequires and fromRequires limit all ingress and egress traffic that applies to an endpoint selector is that the other egress and ingress rules (such as fromEndpoints, fromPorts, toEntities, toServices, and the rest) do not limit the scope of the toRequires of fromRequires fields. Pairing other ingress and egress rules with a toRequires or fromRequires will result in valid policy, but the requirements set in toRequires and fromRequires stay in effect no matter what would otherwise be allowed by the other rules.

This example shows how to require every endpoint with the label env=prod to be only accessible if the source endpoint also has the label env=prod.

This fromRequires rule doesn’t allow anything on its own and needs to be combined with other rules to allow traffic. For example, when combined with the example policy below, the endpoint with label env=prod will become accessible from endpoints that have both labels env=prod and role=frontend.

Traffic from endpoints to services running in your cluster can be allowed via toServices statements in Egress rules. Policies can reference Kubernetes Services by name or label selector.

This feature uses the discovered services’ label selector as an endpoint selector within the policy.

Services without selectors are handled differently. The IPs in the service’s EndpointSlices are, converted to CIDR selectors. CIDR selectors cannot select pods, and that limitation applies here as well.

The special Kubernetes Service default/kubernetes does not use a label selector. It is not recommended to grant access to the Kubernetes API server with a toServices-based policy. Use instead the kube-apiserver entity.

This example shows how to allow all endpoints with the label id=app2 to talk to all endpoints of Kubernetes Service myservice in kubernetes namespace default as well as all services with label env=staging in namespace another-namespace.

fromEntities is used to describe the entities that can access the selected endpoints. toEntities is used to describe the entities that can be accessed by the selected endpoints.

The following entities are defined:

The host entity includes the local host. This also includes all containers running in host networking mode on the local host.

Any node in any of the connected clusters other than the local host. This also includes all containers running in host-networking mode on remote nodes.

The kube-apiserver entity represents the kube-apiserver in a Kubernetes cluster. This entity represents both deployments of the kube-apiserver: within the cluster and outside of the cluster.

The ingress entity represents the Cilium Envoy instance that handles ingress L7 traffic. Be aware that this also applies for pod-to-pod traffic within the same cluster when using ingress endpoints (also known as hairpinning).

Cluster is the logical group of all network endpoints inside of the local cluster. This includes all Cilium-managed endpoints of the local cluster, unmanaged endpoints in the local cluster, as well as the host, remote-node, and init identities. This also includes all remote nodes in a clustermesh scenario.

The init entity contains all endpoints in bootstrap phase for which the security identity has not been resolved yet. This is typically only observed in non-Kubernetes environments. See section Endpoint Lifecycle for details.

The health entity represents the health endpoints, used to check cluster connectivity health. Each node managed by Cilium hosts a health endpoint. See Checking cluster connectivity health for details on health checks.

The unmanaged entity represents endpoints not managed by Cilium. Unmanaged endpoints are considered part of the cluster and are included in the cluster entity.

The world entity corresponds to all endpoints outside of the cluster. Allowing to world is identical to allowing to CIDR 0.0.0.0/0. An alternative to allowing from and to world is to define fine grained DNS or CIDR based policies.

The all entity represents the combination of all known clusters as well world and whitelists all communication.

The kube-apiserver entity may not work for ingress traffic in some Kubernetes distributions, such as Azure AKS and GCP GKE. This is due to the fact that ingress control-plane traffic is being tunneled through worker nodes, which does not preserve the original source IP. You may be able to use a broader fromEntities: cluster rule instead. Restricting egress traffic via toEntities: kube-apiserver however is expected to work on these Kubernetes distributions.

Allow all endpoints with the label env=dev to access the kube-apiserver.

Allow all endpoints with the label env=dev to access the host that is serving the particular endpoint.

Kubernetes will automatically allow all communication from the local host of all local endpoints. You can run the agent with the option --allow-localhost=policy to disable this behavior which will give you control over this via policy.

Allow all endpoints with the label env=dev to receive traffic from any host in the cluster that Cilium is running on.

This example shows how to enable access from outside of the cluster to all endpoints that have the label role=public.

Example below with fromNodes/toNodes fields will only take effect when enable-node-selector-labels flag is set to true (or equivalent Helm value nodeSelectorLabels: true).

When --enable-node-selector-labels=true is specified, every cilium-agent allocates a different local security identity for all other nodes. But instead of using local scoped identity it uses remote-node scoped identity identity range.

By default all labels that Node object has attached are taken into account, which might result in allocation of unique identity for each remote-node. For these cases it is also possible to filter only security relevant labels with --node-labels flag.

This example shows how to allow all endpoints with the label env=prod to receive traffic only from control plane (labeled node-role.kubernetes.io/control-plane="") nodes in the cluster (or clustermesh).

Note that by default policies automatically select nodes from all the clusters in a Cluster Mesh environment unless it is explicitly specified. To restrict node selection to the local cluster by default you can enable the option --policy-default-local-cluster via the ConfigMap option policy-default-local-cluster or the Helm value clustermesh.policyDefaultLocalCluster.

CIDR policies are used to define policies to and from endpoints which are not managed by Cilium and thus do not have labels associated with them. These are typically external services, VMs or metal machines running in particular subnets. CIDR policy can also be used to limit access to external services, for example to limit external access to a particular IP range. CIDR policies can be applied at ingress or egress.

CIDR rules apply if Cilium cannot map the source or destination to an identity derived from endpoint labels, ie the Special Identities. For example, CIDR rules will apply to traffic where one side of the connection is:

A network endpoint outside the cluster

The host network namespace where the pod is running.

Within the cluster prefix but the IP’s networking is not provided by Cilium.

(optional) Node IPs within the cluster

Conversely, CIDR rules do not apply to traffic where both sides of the connection are either managed by Cilium or use an IP belonging to a node in the cluster (including host networking pods). This traffic may be allowed using labels, services or entities -based policies as described above.

List of source prefixes/CIDRs that are allowed to talk to all endpoints selected by the endpointSelector.

List of source prefixes/CIDRs that are allowed to talk to all endpoints selected by the endpointSelector, along with an optional list of prefixes/CIDRs per source prefix/CIDR that are subnets of the source prefix/CIDR from which communication is not allowed.

fromCIDRSet may also reference prefixes/CIDRs indirectly via a CiliumCIDRGroup.

List of destination prefixes/CIDRs that endpoints selected by endpointSelector are allowed to talk to. Note that endpoints which are selected by a fromEndpoints are automatically allowed to reply back to the respective destination endpoints.

List of destination prefixes/CIDRs that endpoints selected by endpointSelector are allowed to talk to, along with an optional list of prefixes/CIDRs per source prefix/CIDR that are subnets of the destination prefix/CIDR to which communication is not allowed.

toCIDRSet may also reference prefixes/CIDRs indirectly via a CiliumCIDRGroup.

This example shows how to allow all endpoints with the label app=myService to talk to the external IP 20.1.1.1, as well as the CIDR prefix 10.0.0.0/8, but not CIDR prefix 10.96.0.0/12

This is a beta feature. Please provide feedback and file a GitHub issue if you experience any problems.

By default, CIDR-based selectors do not match in-cluster entities (pods or nodes). Optionally, you can direct the policy engine to select nodes by CIDR / ipBlock. This requires you to configure Cilium with --policy-cidr-match-mode=nodes or the equivalent Helm value policyCIDRMatchMode: nodes. It is safe to toggle this option on a running cluster, and toggling the option affects neither upgrades nor downgrades.

When --policy-cidr-match-mode=nodes is specified, every agent allocates a distinct local security identity for all other nodes. This slightly increases memory usage – approximately 1MB for every 1000 nodes in the cluster.

This is particularly relevant to self-hosted clusters – that is, clusters where the apiserver is hosted on in-cluster nodes. Because CIDR-based selectors ignore nodes by default, you must ordinarily use the kube-apiserver entity as part of a CiliumNetworkPolicy. Setting --policy-cidr-match-mode=nodes permits selecting the apiserver via an ipBlock peer in a KubernetesNetworkPolicy.

DNS policies are used to define Layer 3 policies to endpoints that are not managed by Cilium, but have DNS queryable domain names. The IP addresses provided in DNS responses are allowed by Cilium in a similar manner to IPs in CIDR based policies. They are an alternative when the remote IPs may change or are not know prior, or when DNS is more convenient. To enforce policy on DNS requests themselves, see Layer 7 Examples.

In order to associate domain names with IP addresses, Cilium intercepts DNS responses per-Endpoint using a DNS Proxy. This requires Cilium to be configured with --enable-l7-proxy=true and an L7 policy allowing DNS requests. For more details, see Obtaining DNS Data for use by toFQDNs.

An L3 CIDR based rule is generated for every toFQDNs rule and applies to the same endpoints. The IP information is selected for insertion by matchName or matchPattern rules, and is collected from all DNS responses seen by Cilium on the node. Multiple selectors may be included in a single egress rule.

The DNS Proxy is provided in each Cilium agent. As a result, DNS requests targeted by policies depend on the availability of the Cilium agent pod. This includes DNS policies (Layer 7 Protocol Visibility).

toFQDNs egress rules cannot contain any other L3 rules, such as toEndpoints (under Endpoints Based) and toCIDRs (under CIDR Based). They may contain L4/L7 rules, such as toPorts (see Layer 4 Examples) with, optionally, HTTP and Kafka sections (see Layer 7 Examples).

DNS based rules are intended for external connections and behave similarly to CIDR based rules. See Services based and Endpoints based for cluster-internal traffic.

IPs to be allowed are selected via:

Inserts IPs of domains that match matchName exactly. Multiple distinct names may be included in separate matchName entries and IPs for domains that match any matchName will be inserted.

Inserts IPs of domains that match the pattern in matchPattern, accounting for wildcards. Patterns are composed of literal characters that are allowed in domain names: a-z, 0-9, . and -.

* is allowed as a wildcard with a number of convenience behaviors:

* within a domain allows 0 or more valid DNS characters, except for the . separator. *.cilium.io will match sub.cilium.io but not cilium.io or sub.sub.cilium.io. part*ial.com will match partial.com and part-extra-ial.com.

* alone matches all names, and inserts all cached DNS IPs into this rule.

The example below allows all DNS traffic on port 53 to the DNS service and intercepts it via the DNS Proxy. If using a non-standard DNS port for a DNS application behind a Kubernetes Service, the port must match the backend port. When the application makes a request for my-remote-service.com, Cilium learns the IP address and will allow traffic due to the match on the name under the toFQDNs.matchName rule.

Many short-lived connections can grow the number of IPs mapping to an FQDN quickly. In order to limit the number of IP addresses that map a particular FQDN, each FQDN has a per-endpoint max capacity of IPs that will be retained (default: 50). Once this limit is exceeded, the oldest IP entries are automatically expired from the cache. This capacity can be changed using the --tofqdns-endpoint-max-ip-per-hostname option.

As with long-lived connections above, live connections are not expired until they terminate. It is safe to mix long- and short-lived connections from the same Pod. IPs above the limit described above will only be removed if unused by a connection.

Layer 4 policy can be specified in addition to layer 3 policies or independently. It restricts the ability of an endpoint to emit and/or receive packets on a particular port using a particular protocol. If no layer 4 policy is specified for an endpoint, the endpoint is allowed to send and receive on all layer 4 ports and protocols including ICMP. If any layer 4 policy is specified, then ICMP will be blocked unless it’s related to a connection that is otherwise allowed by the policy. Layer 4 policies apply to ports after service port mapping has been applied.

Layer 4 policy can be specified at both ingress and egress using the toPorts field. The toPorts field takes a PortProtocol structure which is defined as follows:

The following rule limits all endpoints with the label app=myService to only be able to emit packets using TCP on port 80, to any layer 3 destination:

The following rule limits all endpoints with the label app=myService to only be able to emit packets using TCP on ports 80-444, to any layer 3 destination:

Layer 7 rules support port ranges, except for DNS rules.

This example enables all endpoints with the label role=frontend to communicate with all endpoints with the label role=backend, but they must communicate using TCP on port 80. Endpoints with other labels will not be able to communicate with the endpoints with the label role=backend, and endpoints with the label role=frontend will not be able to communicate with role=backend on ports other than 80.

This example enables all endpoints with the label role=crawler to communicate with all remote destinations inside the CIDR 192.0.2.0/24, but they must communicate using TCP on port 80. The policy does not allow Endpoints without the label role=crawler to communicate with destinations in the CIDR 192.0.2.0/24. Furthermore, endpoints with the label role=crawler will not be able to communicate with destinations in the CIDR 192.0.2.0/24 on ports other than port 80.

ICMP policy can be specified in addition to layer 3 policies or independently. It restricts the ability of an endpoint to emit and/or receive packets on a particular ICMP/ICMPv6 type (both type (integer) and corresponding CamelCase message (string) are supported). If any ICMP policy is specified, layer 4 and ICMP communication will be blocked unless it’s related to a connection that is otherwise allowed by the policy.

ICMP policy can be specified at both ingress and egress using the icmps field. The icmps field takes a ICMPField structure which is defined as follows:

The following rule limits all endpoints with the label app=myService to only be able to emit packets using ICMP with type 8 and ICMPv6 with message EchoRequest, to any layer 3 destination:

When multiple websites are hosted on the same server with a shared IP address, Server Name Indication (SNI), an extension of the TLS protocol, ensures that the client receives the correct SSL certificate for the website they are trying to access. SNI allows the hostname or domain name of the website to be specified during the TLS handshake, rather than after the handshake when the HTTP connection is established.

Cilium Network Policy can limit an endpoint’s ability to establish a TLS handshake to a specified list of SNIs. The SNI policy is always configured at the egress level and is usually set up alongside port policies.

TLS SNI policy enforcement requires L7 proxy enabled.

The following rule limits all endpoints with the label app=myService to only be able to establish TLS connections with one.one.one.one SNI. Any other attempt to another SNI (for example, with cilium.io) will be rejected.

Below is the same SSL error while trying to connect to cilium.io from curl.

Layer 7 policy rules are embedded into Layer 4 Examples rules and can be specified for ingress and egress. L7Rules structure is a base type containing an enumeration of protocol specific fields.

The structure is implemented as a union, i.e. only one member field can be used per port. If multiple toPorts rules with identical PortProtocol select an overlapping list of endpoints, then the layer 7 rules are combined together if they are of the same type. If the type differs, the policy is rejected.

Each member consists of a list of application protocol rules. A layer 7 request is permitted if at least one of the rules matches. If no rules are specified, then all traffic is permitted.

If a layer 4 rule is specified in the policy, and a similar layer 4 rule with layer 7 rules is also specified, then the layer 7 portions of the latter rule will have no effect.

Unlike layer 3 and layer 4 policies, violation of layer 7 rules does not result in packet drops. Instead, if possible, an application protocol specific access denied message is crafted and returned, e.g. an HTTP 403 access denied is sent back for HTTP requests which violate the policy, or a DNS REFUSED response for DNS requests.

Layer 7 rules support port ranges, except for DNS rules.

In Host Policies, i.e. policies that use Node Selector, only DNS layer 7 rules are currently supported. Other types of layer 7 rules are not supported in Host Policies.

Layer 7 policies will proxy traffic through a node-local Envoy instance, which will either be deployed as a DaemonSet or embedded in the agent pod. When Envoy is embedded in the agent pod, Layer 7 traffic targeted by policies will therefore depend on the availability of the Cilium agent pod.

L7 policies for SNATed IPv6 traffic (e.g., pod-to-world) require a kernel with the fix applied. The stable kernel versions with the fix are 6.14.1, 6.12.22, 6.6.86, 6.1.133, 5.15.180, 5.10.236. See GitHub issue 37932 for the reference.

The following fields can be matched on:

Path is an extended POSIX regex matched against the path of a request. Currently it can contain characters disallowed from the conventional “path” part of a URL as defined by RFC 3986. Paths must begin with a /. If omitted or empty, all paths are all allowed.

Method is an extended POSIX regex matched against the method of a request, e.g. GET, POST, PUT, PATCH, DELETE, … If omitted or empty, all methods are allowed.

Host is an extended POSIX regex matched against the host header of a request, e.g. foo.com. If omitted or empty, the value of the host header is ignored.

Headers is a list of HTTP headers which must be present in the request. If omitted or empty, requests are allowed regardless of headers present.

It’s also possible to do some more advanced header matching against header values. HeaderMatches is a list of HTTP headers which must be present and match against the given values. Mismatch field can be used to specify what to do when there is no match.

The following example allows GET requests to the URL /public from the endpoints with the labels env=prod to endpoints with the labels app=service, but requests to any other URL, or using another method, will be rejected. Requests on ports other than port 80 will be dropped.

The following example limits all endpoints which carry the labels app=myService to only be able to receive packets on port 80 using TCP. While communicating on this port, the only API endpoints allowed will be GET /path1, and PUT /path2 with the HTTP header X-My-Header set to true:

This is a beta feature. Please provide feedback and file a GitHub issue if you experience any problems.

PortRuleKafka is a list of Kafka protocol constraints. All fields are optional, if all fields are empty or missing, the rule will match all Kafka messages. There are two ways to specify the Kafka rules. We can choose to specify a high-level “produce” or “consume” role to a topic or choose to specify more low-level Kafka protocol specific apiKeys. Writing rules based on Kafka roles is easier and covers most common use cases, however if more granularity is needed then users can alternatively write rules using specific apiKeys.

The following fields can be matched on:

Role is a case-insensitive string which describes a group of API keys necessary to perform certain higher-level Kafka operations such as “produce” or “consume”. A Role automatically expands into all APIKeys required to perform the specified higher-level operation. The following roles are supported:

“produce”: Allow producing to the topics specified in the rule.

“consume”: Allow consuming from the topics specified in the rule.

This field is incompatible with the APIKey field, i.e APIKey and Role cannot both be specified in the same rule. If omitted or empty, and if APIKey is not specified, then all keys are allowed.

APIKey is a case-insensitive string matched against the key of a request, for example “produce”, “fetch”, “createtopic”, “deletetopic”. For a more extensive list, see the Kafka protocol reference. This field is incompatible with the Role field.

APIVersion is the version matched against the api version of the Kafka message. If set, it must be a string representing a positive integer. If omitted or empty, all versions are allowed.

ClientID is the client identifier as provided in the request.

From Kafka protocol documentation: This is a user supplied identifier for the client application. The user can use any identifier they like and it will be used when logging errors, monitoring aggregates, etc. For example, one might want to monitor not just the requests per second overall, but the number coming from each client application (each of which could reside on multiple servers). This id acts as a logical grouping across all requests from a particular client.

If omitted or empty, all client identifiers are allowed.

Topic is the topic name contained in the message. If a Kafka request contains multiple topics, then all topics in the message must be allowed by the policy or the message will be rejected.

This constraint is ignored if the matched request message type does not contain any topic. The maximum length of the Topic is 249 characters, which must be either a-z, A-Z, 0-9, -, . or _.

If omitted or empty, all topics are allowed.

Policy may be applied to DNS traffic, allowing or disallowing specific DNS query names or patterns of names (other DNS fields, such as query type, are not considered). This policy is effected via a DNS proxy, which is also used to collect IPs used to populate L3 DNS based toFQDNs rules.

While Layer 7 DNS policy can be applied without any other Layer 3 rules, the presence of a Layer 7 rule (with its Layer 3 and 4 components) will block other traffic.

DNS policy may be applied via:

Allows queries for domains that match matchName exactly. Multiple distinct names may be included in separate matchName entries and queries for domains that match any matchName will be allowed.

Allows queries for domains that match the pattern in matchPattern, accounting for wildcards. Patterns are composed of literal characters that that are allowed in domain names: a-z, 0-9, . and -.

* is allowed as a wildcard with a number of convenience behaviors:

* within a domain allows 0 or more valid DNS characters, except for the . separator. *.cilium.io will match sub.cilium.io but not cilium.io. part*ial.com will match partial.com and part-extra-ial.com.

* alone matches all names, and inserts all IPs in DNS responses into the cilium-agent DNS cache.

In this example, L7 DNS policy allows queries for cilium.io, any subdomains of cilium.io, and any subdomains of api.cilium.io. No other DNS queries will be allowed.

The separate L3 toFQDNs egress rule allows connections to any IPs returned in DNS queries for cilium.io, sub.cilium.io, service1.api.cilium.io and any matches of special*service.api.cilium.io, such as special-region1-service.api.cilium.io but not region1-service.api.cilium.io. DNS queries to anothersub.cilium.io are allowed but connections to the returned IPs are not, as there is no L3 toFQDNs rule selecting them. L4 and L7 policy may also be applied (see DNS based), restricting connections to TCP port 80 in this case.

When applying DNS policy in kubernetes, queries for service.namespace.svc.cluster.local. must be explicitly allowed with matchPattern: *.*.svc.cluster.local..

Similarly, queries that rely on the DNS search list to complete the FQDN must be allowed in their entirety. e.g. A query for servicename that succeeds with servicename.namespace.svc.cluster.local. must have the latter allowed with matchName or matchPattern. See Alpine/musl deployments and DNS Refused.

DNS policies do not support port ranges.

IPs are obtained via intercepting DNS requests with a proxy. These IPs can be selected with toFQDN rules. DNS responses are cached within Cilium agent respecting TTL.

A DNS Proxy intercepts egress DNS traffic and records IPs seen in the responses. This interception is, itself, a separate policy rule governing the DNS requests, and must be specified separately. For details on how to enforce policy on DNS requests and configuring the DNS proxy, see Layer 7 Examples.

Only IPs in intercepted DNS responses to an application will be allowed in the Cilium policy rules. For a given domain name, IPs from responses to all pods managed by a Cilium instance are allowed by policy (respecting TTLs). This ensures that allowed IPs are consistent with those returned to applications. The DNS Proxy is the only method to allow IPs from responses allowed by wildcard L7 DNS matchPattern rules for use in toFQDNs rules.

The following example obtains DNS data by interception without blocking any DNS requests. It allows L3 connections to cilium.io, sub.cilium.io and any subdomains of sub.cilium.io.

DNS policies do not support port ranges.

Some common container images treat the DNS Refused response when the DNS Proxy rejects a query as a more general failure. This stops traversal of the search list defined in /etc/resolv.conf. It is common for pods to search by appending .svc.cluster.local. to DNS queries. When this occurs, a lookup for cilium.io may first be attempted as cilium.io.namespace.svc.cluster.local. and rejected by the proxy. Instead of continuing and eventually attempting cilium.io. alone, the Pod treats the DNS lookup is treated as failed.

This can be mitigated with the --tofqdns-dns-reject-response-code option. The default is refused but nameError can be selected, causing the proxy to return a NXDomain response to refused queries.

A more pod-specific solution is to configure ndots appropriately for each Pod, via dnsConfig, so that the search list is not used for DNS lookups that do not need it. See the Kubernetes documentation for instructions.

Deny policies, available and enabled by default since Cilium 1.9, allows to explicitly restrict certain traffic to and from a Pod.

Deny policies take precedence over allow policies, regardless of whether they are a Cilium Network Policy, a Clusterwide Cilium Network Policy or even a Kubernetes Network Policy.

Similarly to “allow” policies, Pods will enter default-deny mode as soon a single policy selects it.

If multiple allow and deny policies are applied to the same pod, the following table represents the expected enforcement for that Pod:

Set of Ingress Policies Deployed to Server Pod

Layer 3 (Pod: Client)

Layer 3 (Pod: Client)

Result for Traffic Connections (Allowed / Denied)

If we pick the second column in the above table, the bottom section shows the forwarding behaviour for a policy that selects curl or ping traffic between the client and server:

Curl to port 81 is allowed because there is an allow policy on port 81, and no deny policy on that port;

Curl to port 80 is denied because there is a deny policy on that port;

Ping to the server is allowed because there is a Layer 3 allow policy and no deny.

The following policy will deny ingress from “world” on all namespaces on all Pods managed by Cilium. Existing inter-cluster policies will still be allowed as this policy is allowing traffic from everywhere except from “world”.

Deny policies do not support: policy enforcement at L7, i.e., specifically denying an URL and toFQDNs, i.e., specifically denying traffic to a specific domain name.

This functionality enables users to place network policy YAML files directly into the node’s filesystem, bypassing the need for definition via k8s CRD. By setting the config field static-cnp-path, users specify the directory from which policies will be loaded. The Cilium agent then processes all policy YAML files present in this directory, transforming them into rules that are incorporated into the policy engine. Additionally, the Cilium agent monitors this directory for any new policy YAML files as well as any updates or deletions, making corresponding updates to the policy engine’s rules. It is important to note that this feature only supports CiliumNetworkPolicy and CiliumClusterwideNetworkPolicy.

The directory that the Cilium agent needs to monitor should be mounted from the host using volume mounts. For users deploying via Helm, this can be enabled via extraArgs and extraHostPathMounts as follows:

To determine whether a policy was established via Kubernetes CRD or directly from a directory, execute the command cilium policy get and examine the source attribute within the policy. In output, you could notice policies that have been sourced from a directory will have the source field set as directory. Additionally, cilium endpoint get <endpoint_id> also have fields to show the source of policy associated with that endpoint.

For Cilium versions prior to 1.14 deny-policies for peers outside the cluster sometimes did not work because of GitHub issue 15198. Make sure that you are using version 1.14 or later if you are relying on deny policies to manage external traffic to your cluster.

Host policies take the form of a CiliumClusterwideNetworkPolicy with a Node Selector instead of an Endpoint Selector. Host policies can have layer 3 and layer 4 rules on both ingress and egress. They cannot have layer 7 rules.

Host policies apply to all the nodes selected by their Node Selector. In each selected node, they apply only to the host namespace, including host-networking pods. They don’t apply to communications between non-host-networking pods and locations outside of the cluster.

Installation of Host Policies requires the addition of the following helm flags when installing Cilium:

--set devices='{interface}' where interface refers to the network device Cilium is configured on, for example eth0. If you omit this option, Cilium auto-detects what interface the host firewall applies to.

--set hostFirewall.enabled=true

As an example, the following policy allows ingress traffic for any node with the label type=ingress-worker on TCP ports 22, 6443 (kube-apiserver), 2379 (etcd), and 4240 (health checks), as well as UDP port 8472 (VXLAN).

To reuse this policy, replace the port: values with ports used in your environment.

If you have troubles with Host Policies, try the following steps:

Ensure the helm options listed in the Host Policies description were applied during installation.

To verify that your policy has been accepted and applied by the Cilium agent, run kubectl get CiliumClusterwideNetworkPolicy -o yaml and make sure the policy is listed.

If policies don’t seem to be applied to your nodes, verify the nodeSelector is labeled correctly in your environment. In the example configuration, you can run kubectl get nodes -o custom-columns=NAME:.metadata.name,LABELS:.metadata.labels | grep type:ingress-worker to verify labels match the policy.

To troubleshoot policies for a given node, try the following steps. For all steps, run cilium-dbg in the relevant namespace, on the Cilium agent pod for the node, for example with:

Retrieve the endpoint ID for the host endpoint on the node with cilium-dbg endpoint get -l reserved:host -o jsonpath='{[0].id}'. Use this ID to replace $HOST_EP_ID in the next steps:

If policies are applied, but not enforced for the node, check the status of the policy audit mode with cilium-dbg endpoint config $HOST_EP_ID | grep PolicyAuditMode. If necessary, disable the audit mode.

Run cilium-dbg endpoint list, and look for the host endpoint, with $HOST_EP_ID and the reserved:host label. Ensure that policy is enabled in the selected direction.

Run cilium-dbg status list and check the devices listed in the Host firewall field. Verify that traffic actually reaches the listed devices.

Use cilium-dbg monitor with --related-to $HOST_EP_ID to examine traffic for the host endpoint.

The first time Cilium enforces Host Policies in the cluster, it may drop reply traffic for legitimate connections that should be allowed by the policies in place. Connections should stabilize again after a few seconds. One workaround is to enable, disable, then re-enable Host Policies enforcement. For details, see GitHub issue 25448.

In the context of ClusterMesh, the following combination of options is not supported:

Cilium operating in CRD mode (as opposed to KVstore mode),

Host Policies enabled,

kube-proxy-replacement enabled, and

This combination results in a failure to connect to the clustermesh-apiserver. For details, refer to GitHub issue 31209.

Host Policies do not work on host WireGuard interfaces. For details, see GitHub issue 17636.

When Host Policies are enabled, hosts drop traffic from layer-2 protocols that they consider as unknown, even if no Host Policies are loaded. For example, this affects LLC traffic (see GitHub issue 17877) or VRRP traffic (see GitHub issue 18347).

When kube-proxy-replacement is disabled, or configured not to implement services for the native device (such as NodePort), hosts will enforce Host Policies on service addresses rather than the service endpoints. For details, refer to GitHub issue 12545.

Host Firewall and thus Host Policies do not work together with IPsec. For details, refer to GitHub issue 41854.

---

## Securing Elasticsearch — Cilium 1.18.5 documentation

**URL:** https://docs.cilium.io/en/stable/security/elasticsearch/

**Contents:**
- Securing Elasticsearch
- Setup Cilium
- Deploy the Demo Application
- Security Risks for Elasticsearch Access
- Securing Elasticsearch Using Cilium
- Clean Up

This document serves as an introduction for using Cilium to enforce Elasticsearch-aware security policies. It is a detailed walk-through of getting a single-node Cilium environment running on your machine. It is designed to take 15-30 minutes.

If you haven’t read the Introduction to Cilium & Hubble yet, we’d encourage you to do that first.

The best way to get help if you get stuck is to ask a question on Cilium Slack. With Cilium contributors across the globe, there is almost always someone available to help.

If you have not set up Cilium yet, follow the guide Cilium Quick Installation for instructions on how to quickly bootstrap a Kubernetes cluster and install Cilium. If in doubt, pick the minikube route, you will be good to go in less than 5 minutes.

Following the Cilium tradition, we will use a Star Wars-inspired example. The Empire has a large scale Elasticsearch cluster which is used for storing a variety of data including:

index: troop_logs: Stormtroopers performance logs collected from every outpost which are used to identify and eliminate weak performers!

index: spaceship_diagnostics: Spaceships diagnostics data collected from every spaceship which is used for R&D and improvement of the spaceships.

Every outpost has an Elasticsearch client service to upload the Stormtroopers logs. And every spaceship has a service to upload diagnostics. Similarly, the Empire headquarters has a service to search and analyze the troop logs and spaceship diagnostics data. Before we look into the security concerns, let’s first create this application scenario in minikube.

Deploy the app using command below, which will create

An elasticsearch service with the selector label component:elasticsearch and a pod running Elasticsearch.

Three Elasticsearch clients one each for empire-hq, outpost and spaceship.

For Elasticsearch clusters the least privilege security challenge is to give clients access only to particular indices, and to limit the operations each client is allowed to perform on each index. In this example, the outpost Elasticsearch clients only need access to upload troop logs; and the empire-hq client only needs search access to both the indices. From the security perspective, the outposts are weak spots and susceptible to be captured by the rebels. Once compromised, the clients can be used to search and manipulate the critical data in Elasticsearch. We can simulate this attack, but first let’s run the commands for legitimate behavior for all the client services.

outpost client uploading troop logs

spaceship uploading diagnostics

empire-hq running search queries for logs and diagnostics

Now imagine an outpost captured by the rebels. In the commands below, the rebels first search all the indices and then manipulate the diagnostics data from a compromised outpost.

Rebels manipulate spaceship diagnostics data so that the spaceship defects are not known to the empire-hq! (Hint: Rebels have changed the stats for the tiefighter spaceship, a change hard to detect but with adverse impact!)

Following the least privilege security principle, we want to the allow the following legitimate actions and nothing more:

outpost service only has upload access to index: troop_logs

spaceship service only has upload access to index: spaceship_diagnostics

empire-hq service only has search access for both the indices

Fortunately, the Empire DevOps team is using Cilium for their Kubernetes cluster. Cilium provides L7 visibility and security policies to control Elasticsearch API access. Cilium follows the white-list, least privilege model for security. That is to say, a CiliumNetworkPolicy contains a list of rules that define allowed requests and any request that does not match the rules is denied.

In this example, the policy rules are defined for inbound traffic (i.e., “ingress”) connections to the elasticsearch service. Note that endpoints selected as backend pods for the service are defined by the selector labels. Selector labels use the same concept as Kubernetes to define a service. In this example, label component: elasticsearch defines the pods that are part of the elasticsearch service in Kubernetes.

In the policy file below, you will see the following rules for controlling the indices access and actions performed:

fromEndpoints with labels app:spaceship only HTTP PUT is allowed on paths matching regex ^/spaceship_diagnostics/stats/.*$

fromEndpoints with labels app:outpost only HTTP PUT is allowed on paths matching regex ^/troop_logs/log/.*$

fromEndpoints with labels app:empire only HTTP GET is allowed on paths matching regex ^/spaceship_diagnostics/_search/??.*$ and ^/troop_logs/search/??.*$

Apply this Elasticsearch-aware network security policy using kubectl:

Let’s test the security policies. Firstly, the search access is blocked for both outpost and spaceship. So from a compromised outpost, rebels will not be able to search and obtain knowledge about troops and spaceship diagnostics. Secondly, the outpost clients don’t have access to create or update the index: spaceship_diagnostics.

We can re-run any of the below commands to show that the security policy still allows all legitimate requests (i.e., no 403 errors are returned).

You have now installed Cilium, deployed a demo app, and finally deployed & tested Elasticsearch-aware network security policies. To clean up, run:

---
