# Jobs example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<p>
  <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=code-engine-jobs-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-code-engine/tree/main/examples/jobs">
    <img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics">
  </a><br>
  ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
</p>
<!-- END SCHEMATICS DEPLOY HOOK -->

An end-to-end jobs example that will provision the following:
- A new resource group if one is not passed in.
- Code Engine project
- Code Engine Job
- Code Engine Generic Secret
- Code Engine Build
- Run Code Engine Build
