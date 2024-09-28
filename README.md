## Purpose

ElasticBank is a retail banking application designed to simulate the operations of a traditional bank. The objective of this project is to deploy this mock banking application to the cloud utilizing Amazon Web Services (AWS) while maintaining a fully automated Continuous Integration/Continuous Deployment (CI/CD) pipeline. The primary goal is to streamline the deployment process, minimize manual human intervention, and enhance operational efficiency.

## Systems Overview

![System Design Diagram Updated](/static/images/for-readme/sys_diagram.png)

## Steps Taken

#### High-Level Overview of Actions:

1. Established a GitHub repository for the project and cloned the primary banking application codebase.
2. Generated AWS access keys for Command Line Interface (CLI) access and launched an EC2 instance (t2.micro) to serve as the Jenkins server.
3. Configured a security group to permit traffic on ports 22 (SSH) and 80 (HTTP).
4. Installed Jenkins on the EC2 instance and configured a multi-branch pipeline integrated with the GitHub repository.
5. Developed a `system_resources_test.sh` script to monitor CPU, memory, and disk usage, incorporating error handling and descriptive messages for resource utilization.
6. Installed and configured the AWS CLI on the Jenkins server and set up the AWS Elastic Beanstalk CLI.
7. Integrated a deployment stage into the Jenkinsfile for Elastic Beanstalk deployment.
8. Successfully deployed the application to AWS Elastic Beanstalk.

## Issues Encountered During Optimization

### Jenkins Errors:

- **Initial Build Failures:** Encountered build failures due to the absence of Python 3.7. Reviewed Jenkins build logs to identify the issue. Resolved by installing Python 3.7 and its virtual environment package on the EC2 instance using `sudo apt install python3.7 python3.7-venv -y`.
- **Script Naming Mismatch:** The Jenkinsfile referenced `system_resource.sh`, whereas the actual script was named differently. Renamed the script from `system_resource.sh` to `system_resources_test.sh` to align with the Jenkinsfile, ensuring successful execution.
- **False Positives in Resource Detection:** Addressed false positives in resource usage detection by optimizing the `system_resources_test.sh` script. Replaced the `top` command with `/proc/stat` for CPU usage, eliminated the use of `bc`, implemented a `log_results` function, and added retry logic and timeouts to the Jenkins pipeline. These enhancements improved monitoring accuracy and reduced the incidence of false positives caused by temporary resource spikes during builds.

### Monitoring Errors:

- **Memory Usage Calculation:** Initially calculated memory usage as `used memory / total memory * 100`, which provided inaccurate results. Revised the calculation to `free | awk '/Mem/{printf("%.2f", ($3-$6)/$2*100)}'`, accounting for buffer cache memory and yielding a more precise representation of memory utilization.

  ![Memory Resource Issue](/static/images/for-readme/memory_resource.png)

  ![Jenkins Resource Failure Issue](/static/images/for-readme/resource_failure.png)

- **CPU Usage Reporting:** Addressed unexpectedly high CPU usage values by optimizing the monitoring script to use `/proc/stat` instead of the `top` command. This method offers a more accurate and resource-efficient means of measuring CPU usage over short intervals.
- **Jenkins Performance on t2.micro Instance:** Noted that Jenkins was performing sluggishly on the t2.micro instance due to its limited resources. Collaborated with a colleague to update `/var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml` with the latest IP address and subsequently restarted the Jenkins service, resulting in improved performance.

## Deployed Retail Banking Application

#### Post-Troubleshooting Deployment:

After resolving the aforementioned issues, the retail banking application was successfully deployed and is operational.

![Screenshot of Bank App in Action on Elastic Beanstalk](/static/images/for-readme/retail_bank_app.png)

## Impact of the CI/CD Pipeline on Business Efficiency

Implementing a deployment stage within the CI/CD pipeline enhances business efficiency by:

1. Automating repetitive tasks, thereby reducing human error.
2. Facilitating faster and more frequent deployments.
3. Ensuring consistent and reproducible deployment processes.
4. Allowing developers to concentrate on code development rather than deployment logistics.
5. Simplifying rollback procedures in the event of issues.

## Potential Challenges with Automated Deployments and Mitigation Strategies

1. **Risk of Deploying Untested or Buggy Code:** Without comprehensive guardrails, automated deployments may push unverified code to production.

   - **Mitigation:**
     - Implement robust automated testing within the pipeline, including unit, integration, and security tests.
     - Utilize staging environments that mirror production for final testing before deployment.
     - Incorporate automated performance testing and monitoring.

2. **Introduction of Security Vulnerabilities:** Automated deployments may inadvertently introduce security flaws if security checks are inadequate.

   - **Mitigation:**
     - Conduct CVE scanning and regular security audits to identify and address vulnerabilities.

3. **Configuration Drift:** Automated updates may lead to inconsistencies in configuration over time.
   - **Mitigation:**
     - Establish a comprehensive rollback strategy to revert to previous stable configurations in case of critical issues.

## Final Remarks

This project highlighted the importance of configuration management and optimally allocating resources, especially when working within the limitations of a t2.micro instance. And by transitioning from manual to automated deployments, we not only streamlined the deployment process but also laid foundations for future improvements. Going forward, the CI/CD pipeline can be further enhanced by incorporating advanced monitoring techniques and stringent security checks (see the next iteration of this workload where we implement monitoring here: https://github.com/shafeeshafee/microblog_EC2_deployment). This project provided invaluable practical experience in the DevOps field, emphasizing the crucial role of automation in contemporary software deployment methodologies.
