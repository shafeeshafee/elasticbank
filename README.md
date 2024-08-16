## Purpose

ElasticBank is a retail bank application. The purpose of this project is to deploy this mock bank app to the cloud using AWS services while maintaining a fully automated CI/CD pipeline. The goal is to make the deployment process more streamlined and reduce manual human intervention.

## Systems Overview

![System Design Diagram](/static/images/for-readme/temp_diagram.png)

## Steps Taken:

#### Here's what I did at a high level:

1. Set up a GitHub repository for the project and cloned the main bank application code.
2. Created AWS access keys for CLI access and launched an EC2 instance (t2.micro) for the Jenkins server.
3. Created a security group to allow ports 22 for SSH and 80 for HTTP.
4. Installed Jenkins on the EC2 instance and set up a multi-branch pipeline connected to the GitHub repository.
5. Created a `system_resources_test.sh` script to monitor CPU, memory, and disk usage with error handling and descriptive messages for resource usage.
6. Installed and configured AWS CLI on the Jenkins server and set up AWS Elastic Beanstalk CLI.
7. Added a deploy stage to the Jenkinsfile for Elastic Beanstalk deployment.
8. Successfully deployed the application to AWS Elastic Beanstalk.

## Issues Around Optimization During The Process

#### Jenkins Errors:

- I had a minor hiccup where my initial builds were failing. Checked Jenkins build logs to identify the cause of the failure, showed Python 3.7 was missing. Installed Python 3.7 and its virtual environment package on the EC2 instance using `sudo apt install python3.7 python3.7-venv -y`.

- Dealt with an incorrect name of the system resources script which caused failures. In short, Jenkinsfile was looking for a specific script filename but I had named the script something else. So I renamed the script from `system_resource.sh` to `system_resources_test.sh` as per the instructions. Correcting the name ensured that Jenkins could find and execute the script.

- False positives in usage detection were leading to build failures. I optimized the `system_resource.sh` script by replacing the `top` command with `/proc/stat` reading, removing `bc` usage, implementing a `log_results` function, and adding retry logic and timeouts to the Jenkins pipeline. This helps prevent false positives by improving accuracy of the actual resources it was monitoring, and reduces temporary spikes during the build itself.

#### Monitoring Errors:

- Writing the system resources script, I used logic that might not have gotten an accurate representation of the memory usage in our instance. My approach was initially calculating used memory / total memory * 100, which could lead to inaccurate results. To arrive at a more accurate representation of memory usage, I used `free | awk '/Mem/{printf("%.2f", ($3-$6)/$2*100)}'` - which means: used memory - buffer cache memory / total memory, multiplied by 100. The way I was doing it was used memory / total \* 100.

![Memory Resource Issue](/static/images/for-readme/memory_resource.png)

![Jenkins Resource Failure Issue](/static/images/for-readme/resource_failure.png)

- CPU issue reported unexpectedly high values. Resolved this as part of the overall script optimization, particularly by replacing the `top` command with `/proc/stat` reading. In essence, the `/proc/stat` method provides a more accurate and less resource-intensive way of measuring CPU usage over a short period.

- Jenkins running extremely slowly on the t2.micro instance was another issue. Since a t2.micro is the lowest specs an instance can have in terms of resource allocation, Jenkins can be taxing on it. With the help of a colleague, I updated `/var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml` with the latest IP, then restarted the Jenkins service. Things ran a bit better after doing this.

## How CICD Pipeline Increases Business Efficiency

Using a deploy stage in the CICD pipeline increases business efficiency by:

1. Automating repetitive tasks, reducing human error.
2. Enabling faster and more frequent deployments.
3. Providing consistent and reproducible deployment processes.
4. Allowing developers to focus on writing code rather than deployment logistics.
5. Making it easier to rollback in case of issues.

## Potential Issues with Automating Code And What To Do

1. With automated deployments, unless there are guard rails in your pipeline and/or development lifecycle that cover a lot of edge cases, there's risk of pushing untested or buggy code to production. To prevent this:
   - have strategies to implement robust automated testing in the pipeline, including unit, integration, and security tests.
   - use staging environments that mirror production for final testing before deployment.
   - use automated performance testing and monitoring.
2. Security vulnerabilities might be introduced if security checks are not properly done. CVE scanning and audits help mitigate this.
3. Automated updates might introduce configuration drift in some cases. Have a fully fleshed out rollback strategy in case of critical issues. <sub><sup>**cough** lest we forget CrowdStrike 2024 **cough**.</sup></sub>

## Final Remarks

Troubleshooting helped me realize how careful one needs to be when working with configurations, as well as how to work with limited resources (like the t2.micro). Going forward, we now have a solid foundation to refine the pipeline, add more monitoring processes, as well as security checks. Ultimately, working on this project provided valuable hands-on experience in the devops realm.
