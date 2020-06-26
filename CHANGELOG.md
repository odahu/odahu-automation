## [1.2.0] - 2020-06-26

### Added

- PostgreSQL deployment using Zalando operator [#123](https://git.epam.com/epmd-legn/legion-cicd/issues/123).
- ELK deployment [#153](https://git.epam.com/epmd-legn/legion-cicd/-/issues/153).
- Fluentd daemonset deployment [#95](https://git.epam.com/epmd-legn/legion-cicd/-/issues/95).
- Airflow deployment with DAG sync via git ([#144](https://git.epam.com/epmd-legn/legion-cicd/-/issues/144),[118](https://git.epam.com/epmd-legn/legion-cicd/issues/118)).
- Cloud storage syncer for Airflow .
- Type constraints for Terraform variables.
- Terraform modules caching to speed up CI pipelines.
- GPU monitoring agent and Grafana dashboard [#171](https://github.com/odahu/odahu-flow/issues/171).
- Configurable helm timeout for all `helm_release` resources.
- Configurable training timeout for `odahuflow` module.

### Changed
- Long object name strings fomatted to be more readable.
- Normalize ingress headers that passed to oauth proxy.
- Fix public docker repo deployment [#184](https://github.com/odahu/odahu-flow/issues/184).
- Project resources moved to `odahu.org` domain.
- Fix GKE Service Account Assigner & and kube2iam tolerations.
- Fix suspend/resume function to correctly restore k8s clusters node count.
- Fix Azure stucked destroy [#152](https://git.epam.com/epmd-legn/legion-cicd/-/issues/152).
- Fix AWS environment destroy failures with new cleanup script [#114](https://git.epam.com/epmd-legn/legion-cicd/-/issues/114).
- storage sized and retention options added for `monitoring` module.
- Prometheus memory limits/requests increased.
- Azure prerequisites documentation updated.
- Kubernetes version updated to 1.16.
- Helm version updated to 3.2.14.
- Terraform version updated to 0.12.26.
- Terragrunt version updated to v0.23.4
- Kubectl version updated to 1.16.10.
- Airflow Helm chart version updated to v6.5.0.
- Oauth helm chart version updated to v3.1.0.
- Oauth image version updated to v5.1.1.
