AIジョブカレ分析基盤構築・インフラ基礎講座 <br>
https://www.aijobcolle.com/infrastructure

### References
- コードは以下のブログ・リポジトリの紹介のものを参考にしています
  - [Terraform Module Registry](https://registry.terraform.io/)
  - [Terraformにおけるディレクトリ構造のベストプラクティス](https://dev.classmethod.jp/devops/directory-layout-bestpractice-in-terraform/)
  - [Terraform Best Practices in 2017](https://qiita.com/shogomuranushi/items/e2f3ff3cfdcacdd17f99)
  - [shogomuranushi/oreno-terraform](https://github.com/shogomuranushi/oreno-terraform)

### Usage
- environments/variable.tf.exampleをコピーします
  - variable.tfはキー情報などが含まれるためGithubにcommitしては :no_good_woman:
```
cp environments/vpc/variable.tf.example environments/vpc/variable.tf
cp environments/wordpress_web/variable.tf.example environments/wordpress_web/variable.tf
```
- variable.tfにAWS Credentialsなどの変数を設定する

#### VPCの生成
- environments/vpc に移動し実行
```
cd environements/vpc

terraform init
terraform plan # 変更内容を確認
terraform apply # 実行 

terraform destroy # 削除
```

#### Wordpress Webの生成
- environments/vpcのtfstatusからvpc_idなどを取得するため、予めVPCを上記コマンドで実行し、s3上にvpc_idが記載されたtfstate.tfが必要です
```
cd environements/wordpress_web

terraform init
terraform workspace new develop # develop環境を作成、移る
terraform plan # 変更内容を確認
terraform apply # 実行 

terraform destroy # 削除
```

