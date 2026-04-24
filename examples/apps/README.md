# Apps example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<p>
  <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=code-engine-apps-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-code-engine/tree/main/examples/apps">
    <img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics">
  </a><br>
  ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
</p>
<!-- END SCHEMATICS DEPLOY HOOK -->

An end-to-end apps example that will provision the following:
- A new resource group if one is not passed in.
- Code Engine project
- Code Engine App
- Code Engine Config Map
- Code Engine TLS Secret
- Code Engine Domain Mapping
- Secrets Manager Resources (Public Engine, Group, Public Certificate)
- A context-based restriction (CBR) rule to allow Code Engine to be accessible from Schematics.
