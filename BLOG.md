# How I’m Using Google Cloud’s Enterprise Landing Zone Blueprints to Build a Scalable E-Commerce Retail Business from Day One

## A step-by-step architectural journey for building a modern, secure, scalable retail business, aligned with official Google Cloud best practices guidance.

## Part 1: The Story — The Business Idea: Rebuilt

For three years, I ran a small cozy modern cafe in Indonesia (as a side job, on top of my main job as Google Cloud Solutions Consultant in Southeast Asia). It was a real field experience, practical, hands-on education in the realities of running a business — teaching me invaluable lessons in everything Business & Entrepreneurship from leadership, innovating & executing ideas, inventory management, to the most important thing in business: obsessing on “customer satisfaction”. That experience sparked my interest in the joy of building a business.

Life has since brought me to Kuala Lumpur Malaysia, which meant closing the cafe in Indonesia due to multiple considerations. But the interest in entrepreneurship remains. I’m now “thinking” into a new idea: a digital- food company called “in a stealth mode", but let’s just say do-foodstore. The vision is to build a trusted e-commerce platform for unique foods, snacks, and high-quality food packaging for B2B & consumers.

Having run a physical business, I learned that a solid foundation is everything. This time, my foundation won’t be made of physical kitchen and furnitures, but of a well-architected cloud platform. This is my blueprint for building do-foodstore for the future, based on lessons from the past, I have these 3 technical principles that I elaborate in phases.

* Phase 1: Building a Trusted Foundation: My experience taught me that customers notice the details. A professional, reliable experience builds trust. Our new online store must reflect that same principle from day one. It has to be trusted (secure, fast, and reliable).
* Phase 2: Using Data to Understand the Customer: In a physical shop, you get to know your regulars. Online, that connection must be built with data. This requires a secure, isolated “digital office” to analyze data without compromising privacy using the power of Artificial Intelligence to understand your customer better!
* Phase 3: Architecting for High-Volume Demand: Any retail business hopes for a “viral moment.” Our digital platform must be able to handle a massive, sudden surge in traffic.

## Part 2: What is a “Landing Zone”? From Business Idea to Technical Foundation

Before we dive into the technical “how,” let’s connect the business goals to the core technical concepts. What does it actually mean to build a “professional digital trusted foundation”?

Think of it like setting up a physical retail business. You could start with an empty plot of land and build everything from scratch. Or, you could start with a pre-built commercial space that already has a solid foundation, is built to code, and has all the essential utilities ready to go.

A Google Cloud Landing Zone is that pre-built commercial space for your digital business.

Google’s documentation outlines several starting points. For do-foodstore, even though we are starting small, we are planning for future complexity—multiple teams, AI workloads, and strict security needs. Therefore, we made the strategic decision to build our platform on the comprehensive Enterprise Foundations Blueprint from day one. This allows us to scale without having to re-architect our core foundation later.

This blueprint provides security through a defense-in-depth model:

> 1. Architecture Controls: A secure network (VPC) and resource hierarchy.
> 2. Policy Controls: Programmatic constraints (Organization Policies) that prevent risky configurations.
> 3. Detective Controls: Tools like Security Command Center that detect and alert on anomalous behavior.

By starting with a landing zone, we get speed, security, and scalability from day one, allowing us to focus on building the do-foodstore application itself, not the underlying plumbing.

## Part 3: The Technical Story — A Multi-Blueprint Architecture

This is the technical deep-dive into the architectural blueprints we’re using to build do-foodstore. We will create Terraform Scripts using official guidance from the Google Cloud team to implement our foundations and applications!

Our strategy is not to build a single, monolithic platform, but to use a portfolio of specialized blueprints that evolve with our business.

## Blueprint 1: The Foundational Landing Zone for Security & Governance

This first blueprint builds the secure, governed environment our application will live in. It establishes the “Architecture,” “Policy,” and “Detective” controls we discussed. We use the official terraform-example-foundation to establish this core.

> Purpose: To provide a secure, governed, and automated environment for all other blueprints to build upon.

### A Visual Architecture

The blueprint creates a clean, hierarchical structure, including a restricted folder for our most sensitive workloads.

```
+--------------------------------------+
|     Google Cloud Organization        |
|            (do-foodstore)            |
+--------------------------------------+
                   |
+------------+-----+------------+------------+
|            |                  |            |
[Folder:    [Folder:           [Folder:     [Folder:
 common]     network]           environments] restricted]
                                     |            | (AI Vault)
                     +--- [Folder: development]   | (See BP 4)
                     |      +-- [Project: webapp-dev] <-+
                     +--- [Folder: staging]       | Central
                     |      +-- [Project: webapp-stg] <-+ VPC
                     +--- [Folder: production]    | Network
                            +-- [Project: webapp-prod]<-+
```

### What Foundational Services Does It Provide?

* **IaC & CI/CD (The “Seed Project”)**: The 0-bootstrap step creates a secure GCS bucket for Terraform state and a Cloud Build pipeline. This "brain" enforces that all infrastructure changes are automated and auditable.
* **Organization Hierarchy**: Creates the folder structure and project factory to ensure new projects are created in a compliant way.
* **Policy Controls & IAM**: Configures Organization Policies to enforce guardrails, such as restricting resource locations and disabling static service account keys.
* **Networking**: Builds a secure Shared VPC network, configuring Private Google Access and Cloud DNS for internal service communication.
* **Security Operations & Encryption**: Configures Security Command Center and centralizes key management with dedicated encryption keys for different environments.

### A Practical Code Example

```hcl
# main.tf
# Creates a new project for a customer reviews service.
module "reviews_service_project" {
  source    = "terraform-google-modules/project-factory/google"
  version   = "~> 14.0"
  name      = "dofoodstore-reviews-prod"
  folder_id = module.environments.folders.production
  # ... other configuration
}
```

* **Official Blueprint**: terraform-google-modules/terraform-example-foundation

---

## Blueprint 2: The Core E-Commerce Application Stack

This blueprint details a modern, scalable application architecture deployed into the projects created by Blueprint 1.

> Purpose: To run the live, customer-facing e-commerce application with best-in-class features for user experience and security.

### A Visual Architecture

```
+------------------+
| Customer's       |
| Browser/App      |
+------------------+
       |
       V
+------------------------------------+
|   Global Load Balancer             |
|   (with Cloud CDN & Cloud Armor)   |
+------------------------------------+
       |
       V
+------------------+
| Cloud Run        |
| (Frontend Web)   |
+------------------+
       |
       | API Calls to Backend
       V
+------------------+
| Cloud Run        |
| (Backend API)    |
+------------------+
     /    |    \
    /     |     \
(Search)  |      | (DB)
+-----------+    +-------------+
| Vertex AI |<---+        +--->| AlloyDB for |
| Search    |            |    | PostgreSQL  |
+-----------+            +-------------+
```

### The Components

* **Global Load Balancer & Cloud CDN**: The secure front door providing global presence and asset caching.
* **Cloud Armor**: Protects the store from DDoS attacks and common web vulnerabilities.
* **Cloud Run**: Independently scaling services for the Frontend (Next.js) and Backend API.
* **Product Search (Vertex AI Search)**: AI-powered search and recommendations.
* **AlloyDB for PostgreSQL**: Managed, high-performance database for transactions.
* **Memorystore for Redis**: In-memory cache for session data.

---

## Blueprint 3: The Business Intelligence & Analytics Platform

> Purpose: To consolidate and analyze business data without impacting the performance of the live transactional application.

### A Visual Architecture

```
+------------------------------------+     +-----------------------------------------+
|      CORE E-COMMERCE PLATFORM      |     |     BUSINESS INTELLIGENCE PLATFORM      |
|                                    |     |                                         |
| +----------------+  (Scheduled ETL)|---->| +-----------------+  (Queries)  +-------+
| | AlloyDB for    |   or Datastream |     | |   BigQuery      |<------------| Looker|
| | PostgreSQL     |                 |     | | (Data Warehouse)|             +-------+
| +----------------+                 |     | +-----------------+               ^
|                                    |     |                                   |
| +----------------+ (Log Sink)      |---->| (Ingests Logs)                    |
| | Cloud Logging  |                 |     +-----------------------------------------+
| +----------------+                 |                                         |
+------------------------------------+                                     (Business Users)
```

### A Practical Code Example

```hcl
# bigquery.tf
resource "google_bigquery_dataset" "sales_analytics" {
  project     = "dofoodstore-analytics-prod"
  dataset_id  = "sales_data"
  location    = "US"
  description = "Contains cleaned sales and transaction data for BI."
}
```

---

## Blueprint 4: The Secure Vault for the AI Team

> Purpose: To enable AI/ML experimentation on sensitive data while preventing data exfiltration using VPC Service Controls.

### A Visual Architecture

```
+------------------------------------------+       +-----------------------------------------+
|      CORE E-COMMERCE PLATFORM            |       |        SECURE DATA VAULT                |
| (In 'production' folder)                 |       |      (In 'restricted' folder)           |
+------------------------------------------+       +-----------------------------------------+
                                           |-----------------------------------------|
                                           |      VPC SERVICE CONTROLS PERIMETER     |
                                           |-----------------------------------------|
```

### A Practical Code Example

```hcl
# workbench.tf
module "workbench" {
  source       = "terraform-google-modules/vertex-ai/google//modules/workbench"
  version      = "~> 1.0"
  project_id   = "dofoodstore-ai-lab-prod"
  instance_id  = "data-scientist-1"
  network      = "projects/dofoodstore-vpc-host/global/networks/vpc-sc-network"
}
```

---

## Blueprint 5: The High-Performance Engine for Peak Demand

> Purpose: To provide a cost-effective, auto-scaling platform for specific, high-traffic microservices like shopping cart or checkout.

### A Visual Architecture & Microservice Strategy

```
+-----------------------------+      +-------------------------------------------+
|    Main Website & Catalog   |      |   HIGH-SCALE CHECKOUT ENGINE              |
|  (Running on Cloud Run)     |----->| (Built with accelerated-platforms)        |
|                             | API  |                                           |
| Handles browsing traffic    | Call | +---------------------------------------+ |
|                             |      | | GKE Cluster (Autoscaling)             | |
+-----------------------------+      | +---------------------------------------+ |
                                     +-------------------------------------------+
```

### A Practical Code Example

```hcl
# gke.tf
module "gke_checkout_cluster" {
  source  = "github.com/GoogleCloudPlatform/accelerated-platforms/terraform/gke/gke-cluster"
  project_id = "dofoodstore-webapp-prod"
  name       = "checkout-cluster"
  node_pools = [{
    name         = "checkout-pool"
    min_count    = 1
    max_count    = 100
  }]
}
```

---

## The Payoff: Why This Architecture Matters

*   **Speed & Agility**: Pre-configured projects allow teams to build faster.
*   **Security by Default**: Isolated vaults for sensitive workloads reduce risk.
*   **Scalability & Cost Control**: Handle traffic spikes on-demand and scale back to save costs.
*   **Governance & Auditability**: Every change is tracked and reviewed via GitOps.

## Conclusion: Start Your Own Blueprint

Building a business like *do-foodstore* starts with an architectural blueprint. By understanding business goals and implementing a multi-blueprint strategy, you build a business ready for the future.
