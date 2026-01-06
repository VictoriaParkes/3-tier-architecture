# 3-tier-architecture

1. Title and Introduction
2. Architectural Diagram (Visual)
3. Technologies/Dependencies (The stack, including versions)
4. Dev process

## Introduction

This repository contains a fully containerized, three-tier application built and deployed using modern DevOps practices. The goal was to showcase hands-on experience with [Terraform](https://developer.hashicorp.com/terraform) for infrastructure provisioning, [Docker](https://www.docker.com/) for containerization, and [Kubernetes](https://kubernetes.io/) orchestrated via [Amazon Elastic Kubernetes Service (EKS)](https://aws.amazon.com/eks/) for a highly available and scalable deployment.

The project was developed with a focus on the practical application of infrastructure as code (IaC) methodologies, as well as containerization and orchestration principles. It served as a practical exercise to demonstrate my skills and understanding of automated infrastructure and container orchestration. By leveraging Terraform, I provisioned and managed the underlying AWS infrastructure, including the VPC, subnets, and an EKS cluster. The application is containerized with Docker and orchestrated by Kubernetes, showcasing a repeatable and automated deployment process from infrastructure to application code.





Here is a guide for creating the architecture and features sections for your README file, complete with templates and examples.
Architecture
The architecture section should provide a high-level overview of how your application's different components fit together, from the infrastructure provisioned by Terraform to the application deployed on EKS. A diagram is highly recommended here to make the explanation visual and easy to understand. 
Template
Architecture
The application is deployed using a modern, cloud-native architecture on AWS. The entire infrastructure is provisioned as code using Terraform, ensuring a repeatable and automated setup. The core application runs as a containerized, three-tier service orchestrated by Kubernetes on an Amazon EKS cluster. 
An Amazon Elastic Load Balancer (ELB) handles incoming traffic, directing it to the frontend service. The architecture is composed of the following tiers:
1. Presentation Tier (Frontend)
Purpose: Manages the user interface and serves the static assets of the application.
Implementation: [E.g., A React.js application running in a Docker container.]
Deployment: Deployed as a Kubernetes Deployment and exposed via an Ingress resource.
2. Application Tier (Backend)
Purpose: Handles the business logic, processes user requests, and communicates with the database.
Implementation: [E.g., A Node.js API built with Express.js running in a Docker container.]
Deployment: Deployed as a Kubernetes Deployment and exposed as a Service for internal communication.
3. Data Tier (Database)
Purpose: Stores and retrieves all application data persistently.
Implementation: [E.g., A PostgreSQL database running as a StatefulSet in Kubernetes.]
Deployment: Deployed as a StatefulSet with persistent volume claims (PVCs) for data storage. 
List of features
The features section should outline both the user-facing functionality of the application and the technical achievements of the project. This highlights the "what" and the "how."
Template
Key features
This project showcases a range of both application-level and technical features.
Application features
[Feature 1]: [Describe a core function, e.g., "User authentication (signup, login, and logout)."]
[Feature 2]: [Describe another key function, e.g., "Basic CRUD operations for managing a task list."]
[Feature 3]: [Describe a different function, e.g., "Real-time updates via WebSocket (if applicable)."] 
Technical features
Infrastructure as Code (IaC): Complete infrastructure for the EKS cluster, networking, and necessary AWS services is managed by Terraform.
Containerization: All application components are containerized using Docker for consistency across development and production environments.
Container Orchestration: Kubernetes manages the deployment, scaling, and self-healing of all application pods.
Cloud Deployment: The application is deployed on a managed AWS EKS cluster, leveraging the scalability and reliability of the AWS cloud.
High Availability: The architecture is designed for high availability by running multiple replicas of the application services across different availability zones.
Dynamic Scaling: The Kubernetes deployment can automatically scale up or down based on traffic load.
CI/CD Pipeline: [If applicable, mention automated deployment, e.g., "Deployment is automated via a CI/CD pipeline triggered by a Git push."]


An architectural diagram is a great way to visually represent your project. Here is a simple, text-based diagram that you can easily generate using a markdown-friendly language called Mermaid, which GitHub supports natively.
Just copy and paste the code below into a new section in your README file.
Mermaid diagram code
mermaid
graph TD
    subgraph "Client"
        A[Web Browser]
    end

    subgraph "AWS Cloud (VPC)"
        subgraph "Terraform Provisioned Infrastructure"
            B[Public Subnets]
            C[Private Subnets]
            D[Internet Gateway]
            E[NAT Gateway]
            B -- D
            C -- E
        end

        subgraph "Amazon EKS Cluster"
            F[Load Balancer] --> |Ingress| G[Frontend Service]
            G --|> H[Backend Service]
            H --|> I[Database StatefulSet]
            G -- F
            H -- C
            I -- C
            F -- B
        end
    end

    A -- "HTTPS" --> F
Use code with caution.

Explanation of the diagram
Client: Represents the end-user's web browser interacting with your application.
AWS Cloud (VPC): The outer box represents your project's Virtual Private Cloud, a logically isolated network where your AWS resources are located.
Terraform Provisioned Infrastructure: This group contains the networking components managed by Terraform:
Internet Gateway: Allows communication between the VPC and the internet.
NAT Gateway: Enables resources in private subnets to securely connect to the internet.
Amazon EKS Cluster: This shows the services running within your managed Kubernetes cluster.
Load Balancer: Manages incoming traffic from the internet and routes it to the frontend service.
Frontend Service: A Kubernetes Deployment of your frontend application.
Backend Service: A Kubernetes Deployment of your backend API.
Database StatefulSet: A Kubernetes StatefulSet for your database, ensuring data persistence and ordered deployment.
This diagram is simple, effective, and directly ties into the technologies you mentioned.

In addition to Mermaid, there are several other excellent options for creating architectural diagrams, each with its own strengths. They generally fall into two categories: diagram-as-code tools and visual editors. 
Diagram-as-code tools
These tools generate diagrams from text files, which can be versioned alongside your code. They are excellent for technical audiences and for maintaining a diagram that stays in sync with changes to your infrastructure.
PlantUML
Best for: Developers who want to embed diagrams directly in documentation using simple, text-based code.
Syntax: Uses a domain-specific language (DSL) to create various diagram types, including sequence diagrams, component diagrams, and more.
Pros: Supports a wide range of diagram types and can include official AWS icons using a special library.
Cons: Can be more verbose than Mermaid for simple diagrams.
Example for a README: You would typically include the PlantUML source code in your README, but you would need a tool to render it into an image for it to display on GitHub. Many CI/CD pipelines can do this for you. 
Diagrams.net (formerly draw.io)
Best for: Creating more polished and professional-looking diagrams with full support for AWS icons. It's a great middle ground between visual editors and pure code.
Syntax: Has a code-based feature, but is primarily a visual editor. You would create the diagram visually and then export it as an image file (e.g., SVG or PNG) to embed in your README.
Pros: Free, open-source, and has a massive library of cloud provider icons.
Cons: The diagram is an image file and won't auto-update if your code or infrastructure changes.
Example for a README: You would export the final image and add it to your repository, then link to it using standard Markdown image syntax (![Diagram alt text](path/to/diagram.png)). 
Visual editors
These are graphical user interface (GUI) applications or web services where you drag and drop icons and elements to build your diagram.
Lucidchart
Best for: Creating diagrams quickly with a drag-and-drop interface, especially for business-focused or less technical audiences.
Pros: Offers a vast library of templates and shapes for every major cloud provider, and supports collaboration.
Cons: Not free for advanced features and is a less direct way to link your diagram to your infrastructure code.
Example for a README: Create your diagram in Lucidchart, export it as an image, and embed it in your README. 
CloudSkew
Best for: Web-based drawing specifically for cloud and network diagrams. It includes a huge library of icons for AWS, Kubernetes, and others.
Pros: Clean, easy-to-use interface that is purpose-built for cloud architecture diagrams.
Cons: Requires a login and is a visual editor, so it does not auto-update from your code.
Example for a README: Same as with Lucidchart—export the image and embed it. 
Recommendation
For a project like yours, which emphasizes DevOps and Infrastructure as Code, using a text-based tool like Mermaid or PlantUML is often the best choice. It keeps your diagrams in version control, making it easier to track changes. If you prefer a more visual and polished look, Diagrams.net is a powerful and free option.

