---
title: "VirtualBoxクラウドネットワークを使う"
emoji: "💻"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["VirtualBox", "Windows", "OCI", "Network"]
published: true
---

# VirtualBoxクラウドネットワークとは

手元のゲストマシンのNICが、あたかもOracle Cloud Infrastructure(OCI)のネットワークに直接繋がっているかのように振る舞う機能です。これを用いることでクラウドとオンプレのVMを相互に接続できます。

以下のサイトの動画で詳しく説明されています。
https://blogs.oracle.com/scoter/post/virtualbox-7-cloud-network-for-virtualbox-virtual-machines

## 仕組み

クラウドネットワークの設定後、ゲストマシンのネットワークの設定で「クラウドネットワーク」を選択します。この状態でゲストマシンを起動すると、OCI上にProxyとなるVMが起動し、ゲストマシンのNICとして動作します。イメージ的には下図のようにVMがNICとなり、ゲストマシンのPCIスロットに刺さっているかのような感じです。

![outline](/images/articles/a41eb3dbec2b40/outline.png)

したがって、ゲストマシンのネットワーク設定は以下のようにホストオンリー等ネットワークの種類の一つとして設定できます。
![nic](/images/articles/a41eb3dbec2b40/nic.png)

## なにがうれしいの？

クラウドとオンプレの接続もさることながら、個人的にはセキュリティ調査で危険なサイトに接続する際にも活躍すると考えています。VPNとの最大の違いは、OSからのネットワークの見え方です。VPNであればゲストマシンが接続しているローカルネットワークが見えてしまいますが、クラウドネットワークを用いるとNICが直接クラウドのネットワーク環境に接続されているように見えます。なので、誤った操作をして横展開されてしまう危険性がより低いと考えられます。

また、他にはクラウド上に直接VMを作成する方法もありますが、ローカルのゲストマシンを使うことで以下のようなメリットが挙げられます。

- ストレージ費用の削減
- 任意のゲストOSの使用

# セットアップ
私はWindows11 + VirtualBox 7.0.12 r159484 (Qt5.15.2)という環境で試しています。他の環境では結果が異なる可能性があることご了承ください。また、クラウドネットワークが実験的な機能であるため、今後変更が加わる可能性があります。

## 下準備

### OCIアカウントの作成

以下のサイトでアカウントを作成してください。クレジットカードの登録が必要ですが、33000円分の無料枠がついてきます。
https://www.oracle.com/jp/cloud/

### VirtualBoxのインストール

VirtualBoxのインストールに加え、Extension Packも必要です。以下からダウンロードしてインストールしてください。

https://www.virtualbox.org/wiki/Downloads

Extension Packをインストールすると、以下のようにクラウドの設定で追加ボタンが利用可能になります。

![cloud](/images/articles/a41eb3dbec2b40/cloud.png)

## コンパートメントの作成

OCIにはリソースをグループ分けするコンパートメント（Compartment）という仕組みがあります。Azureのリソースグループ、GCPのプロジェクトに近い概念だと考えられます。以下のサイトの解説が詳しいです。

https://solutions.system-exe.co.jp/oracle-cloud/blog/what-is-a-compartment

ルートコンパートメントを使用しても良いですが、せっかくなのでクラウドネットワーク用のコンパートメントを作成します。左上のハンバーガーメニューをクリックし、"Identity & Security"->"Compartments"と進みます。

![compartments00](/images/articles/a41eb3dbec2b40/compartments00.png)

"Create Compartment"ボタンをクリックし、作成します。ここでは"VirtualBox_Cloud_Network"という名称で作成しました。後ほど使用するのでOCIDをコピーしておきます。

![compartments01](/images/articles/a41eb3dbec2b40/compartments01.png)

## APIキーの作成
VirtualBoxからOCIに接続するためのAPIキーを作成します。右上の人型アイコンをクリックし、"My profile"を選択します。

![apikey00](/images/articles/a41eb3dbec2b40/apikey00.png)

開いたページの左側のメニュー”Resources”の中の"API keys"をクリックします。
![apikey01](/images/articles/a41eb3dbec2b40/apikey01.png)

"Add API key"ボタンをクリックし"Generate API key pair"を選択します。"Download private key"、"Download public key"をクリックし、秘密鍵をダウンロードします。最後に"Add"ボタンをクリックして完了です。ダウンロードした鍵ファイルは適切なディレクトリに保存しましょう。ちなみに、私はファイル名をそれぞれ"VirtualBox_Cloud_Network_sk.pem"、"VirtualBox_Cloud_Network_pk.pem"としました。
![apikey02](/images/articles/a41eb3dbec2b40/apikey02.png)

表示されたダイアログの"fingerprint"と"Configuration file preview"の内容をコピーしておきます。
![apikey03](/images/articles/a41eb3dbec2b40/apikey03.png)

## VirtalBoxのクラウド設定
"ツール"->"クラウド"と進みます。

![virtualbox00](/images/articles/a41eb3dbec2b40/virtualbox00.png)

"追加"ボタンをクリックし、"プロファイル名"を決めます。OCIのコンパートメントと同じ"VirtualBox_Cloud_Network"にしましたが、特にどんな名称でもOKです。以下のように作成したプロファイルを選択するとプロパティを設定できます。

![virtualbox01](/images/articles/a41eb3dbec2b40/virtualbox01.png)

以下の項目を設定します。
- compartment: コンパートメントの作成でコピーしておいた、コンパートメントのOCID（コンパートメント名**ではない**ことに注意）
- fingerprint: APIキーの作成でコピーしておいたfingerprint参照
- key_file: APIキーの作成でダウンロードした、秘密鍵ファイルへのフルパス(例: `C:\foobar\VirtualBox_Cloud_Network_sk.pem`)
- region: APIキーの作成でコピーしておいたConfiguration file preview参照
- tenancy: APIキーの作成でコピーしておいたConfiguration file preview参照
- user: APIキーの作成でコピーしておいたConfiguration file preview参照

最後に"適用"ボタンをクリックして完了です。

## トンネルネットワークの作成

コマンドプロンプトを開き、以下のコマンドを実行します。`VBoxManage.exe`へのパスはご自身の環境のものを使用してください。また、`profile`はVirtualBoxのクラウド設定で作成したプロファイル名です。
```cmd
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" cloud --provider="OCI" --profile="VirtualBox_Cloud_Network" network setup
```

以下のような結果が出力されるので、Tunnel network idをコピーしておきます。
```cmd
Cloud network environment was set up successfully. Tunnel network id is: ocid1.subnet.oc1.ap-tokyo-1.aaaaaaaag（以下略）
```

## VirtalBoxのネットワーク設定
ネットワークの設定を開きます。
![virtualbox02](/images/articles/a41eb3dbec2b40/virtualbox02.png)

"クラウドネットワーク"タブを開き、"作成"ボタンをクリックします。"CloudNetwork"が作成されるので、以下の項目を設定します。
- 名前: 変更してもOKです
- プロバイダー: Oracle Cloud Infrastrcture
- プロファイル: VirtualBoxのクラウド設定で作成したプロファイル名（VirtualBox_Cloud_Network）
- Id: トンネルネットワークの作成でコピーしたTunnel network id

"適用"ボタンをクリックして完了です。

## ゲストマシンのネットワーク設定
冒頭で見た通りの設定を行います。
![nic](/images/articles/a41eb3dbec2b40/nic.png)


# 起動
ではゲストマシンを起動します。20%のところで数分間停止しますが、これはOCI上にproxyのVMを作成しているためです。OCI上で"Compute"の"Instances"を見ると、以下のようにVMが作られているのがわかります。また、割り当てられているプライベートIPアドレスがゲストマシン上で見えているIPアドレスと一致しているのがわかります。

![result](/images/articles/a41eb3dbec2b40/result.png)

さらに、ゲストマシンのブラウザから https://ipchicken.com/ 等にアクセスし、OCIのVMのPublic IPとゲストマシンから見えているパブリックIPアドレスが一致していることも確認しましょう。

ゲストマシンを停止すると、OCIで作成されたVMも自動的に削除されます。


# 参考サイト

https://qiita.com/feifo/items/6810b5635854175a0c4f#api%E3%82%AD%E3%83%BC%E3%81%AE%E4%BD%9C%E6%88%90