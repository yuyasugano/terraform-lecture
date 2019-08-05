### References
  - [Terraform Module Registry](https://registry.terraform.io/)
  - [Terraform Structure Best Practices](https://dev.classmethod.jp/devops/directory-layout-bestpractice-in-terraform/)
  - [Terraform Best Practices in 2017](https://qiita.com/shogomuranushi/items/e2f3ff3cfdcacdd17f99)
  - [shogomuranushi/oreno-terraform](https://github.com/shogomuranushi/oreno-terraform)

### Usage
- copy environments/variable.tf.example as environments/variable.tf
```
cp environments/vpc/variable.tf.example environments/vpc/variable.tf
cp environments/wordpress_web/variable.tf.example environments/wordpress_web/variable.tf
```
- configure AWS credential information in variable.tf

#### Build Infrastructure
- move to environments and run
```
cd environements

terraform init
terraform plan # confirm
terraform apply # run

terraform destroy # destroy
```

