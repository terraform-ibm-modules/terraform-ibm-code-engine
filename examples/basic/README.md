# Basic example

<!--
The basic example should call the module(s) stored in this repository with a basic configuration.
Note, there is a pre-commit hook that will take the title of each example and include it in the repos main README.md.
The text below should describe exactly what resources are provisioned / configured by the example.
-->

An end-to-end basic example that will provision the following:
- A new resource group if one is not passed in.
- 2 Code Engine projects, where:
    - Project #1 includes: Code Engine Job, App, Config Map, Secret, Build
    - Project #2 includes: Code Engine App
