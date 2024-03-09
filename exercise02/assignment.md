## Exercise 1: Cloud-Based File Storage System in Kubernetes

### Introduction

This exercise assesses your comprehension of the Kubernetes environment and its primary resources, evaluates your capability to apply this knowledge in the real-world scenario of deploying a straightforward service, and validates your proficiency with Kubernetes. The exercise consists of a replication of the deployment of the service done in exercise one. This deployment must be achieved using either a HELM chart with appropriate values or by writing custom manifests. 

### Requirements

- the cluster must run `k8s`; one node is sufficient,
- the pods must have all the probes necessary to handle miss-behaviors,
- the volumes must survive a pod crash and accidental deletion, local pv are sufficient,
- the service must be accessible from the user via IP or FQDN,
- eventual databases or third-party services necessary for the deployed software must run in their pod.


### Submission detail

Documentation:

- Extend the report of exercise one, including all the declining arguments for the case of the Kubernetes platform.
- Discuss the limits of the back-end storage choice, which steps should be taken to overcome such limitations,
- Discuss all the steps that should be taken to have the service in high availability.
- Discuss the advantages and disadvantages of this deployment concerning the docker solution. 

Code:

- publish all the value files used in your helm charts, the developed manifests, and any code eventually developed/modified  
necessary to deploy your cloud-based file storage system in a vanilla clean cluster.
- Include a README file with instructions on how to deploy and use your system.

Presentation:

- Extend the presentation for exercise one, summarizing your design, implementation, and any **interesting** challenges you faced. (no more than seven extra slides)
- Be ready to answer questions about your design choices and on the topics discussed during the Cloud Course Lectures
  

### Evaluation Criteria:

- Design Clarity: Is the system design well-documented and clear?
- Functionality: Does the system meet the specified requirements?
- Resilience: Is the system implementing basic HA correctly?
- Security: Are any security measures implemented or discussed?
