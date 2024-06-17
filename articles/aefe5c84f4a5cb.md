---
title: "Mapbox Docs AI (AIチャットボット) を使ってみる"
emoji: "🤖"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Mapbox", "GIS", "AIチャットボット", "サポート"]
published: false
publication_name: "mapbox_japan"
---

# はじめに

もうすでに利用された方もいらっしゃるかもしれませんが、[Mapbox, Inc.のドキュメントサイト](https://docs.mapbox.com/)にはAIチャットボットがあります。

![docs](/images/articles/aefe5c84f4a5cb/docs.png)

右下の「Ask AI」をクリックすると以下のようなチャット画面が表示されます。

![chat](/images/articles/aefe5c84f4a5cb/chat.png)

このAIチャットボットはRAG (Retrieval Augmentented Generation)を用いているため。ドキュメントサイトの内容に関する質問については正確な回答が期待できます。また、日本語にも対応しています。そこで、この記事ではいくつか技術的な質問をしてどれぐらい使えるAIか試してみます。


# 試してみる
それでは実際にいくつかの質問を試してみます。

## 似ているサービスの違いを聞く

### 質問
Uploads APIとMTSの違いについて教えて下さい。


### 回答
MapboxのUploads APIとMapbox Tiling Service（MTS）は、データをタイルセットに変換し、地図上で視覚化するための2つの異なるサービスです。

Uploads APIは、データを一時的なS3バケットにアップロードし、タイルセットに変換するためのサービスです。このAPIは、設定オプションを選択することはできません。したがって、ラスターデータをアップロードする必要がある場合を除き、データのアップロードにはMTSがより適しています。Uploads APIは、特定のプレゼンテーションの詳細について自動的に決定を行います。これには、最小および最大のズームレベルや、アップロードするデータに基づいた単純化が含まれます。Uploads APIは、MBTiles、KML、GPX、GeoJSON、Shapefile（zipped）、CSVファイル、GeoTIFFなど、多くの一般的な地理空間ファイルタイプを受け入れます。^1^

一方、MTSは、ベクターデータをタイル化するためのサービスで、カスタム設定ルールを使用してベクターデータをタイル化するためのいくつかのベータエンドポイントがあります。MTSまたはUploads APIを使用してタイルセットを更新すると、データの変更量に関係なく、完全なタイルセットを再タイル化する必要があります。^3^

Uploads APIとMTSの使用は、タイルセットの処理とホスティングによって課金されます。これらの各項目のコストは、タイル化されたデータの領域とタイルセットの精度レベルに依存します。^5^


### 考察
よくある質問のUploads APIとMTS (Mapbox Tiling Service)の違いについて質問しました。それぞれの特徴がわかりやすくまとまっています。

また、回答に使用したドキュメントへのリンクが以下のように表示されます。更に詳細に調べる際に便利です。
![link](/images/articles/aefe5c84f4a5cb/link.png)


## APIの使い方を聞く

### 質問
GeoJSONをMTSでアップロードする手順を教えて下さい。


### 回答
Mapbox Tiling Service (MTS)を使用してGeoJSONをアップロードするには、以下の手順を実行します。

まず、GeoJSONをライン区切りのGeoJSONに変換します。これは、MTSがタイルセットソースをライン区切りのGeoJSONとしてフォーマットすることを要求するためです。^1^

次に、MTS Data SyncまたはTilesets CLIを使用してGeoJSONをアップロードします。これらのツールは自動的にGeoJSONをライン区切りのGeoJSONに変換します。^2^

MTS Data Syncを使用する場合、--configコマンドと他のMTS Data Syncコマンドについて学ぶには、MTS Data Syncドキュメンテーションを参照してください。^2^

Tilesets CLIを使用する場合、upload-sourceコマンドと他のTilesets CLI関数について学ぶには、Tilesets CLIドキュメンテーションを参照してください。^3^

MTSはタイルを作成するために2つの入力を必要とします：タイルセットソース（あなたの地理空間データ）とタイルセットレシピ（タイルセットソースをタイルに変換するための設定オプションを指定するJSONドキュメント）。タイルセットソースについては、タイルセットソースガイドを参照してください。タイルセットレシピのフォーマットについては、レシピ仕様を参照してください。[^4^]

MTS Data Syncは、コードを書くことなくデータを直接MTSに公開するためのコマンドラインツールです。多くのユースケースでは、MTS Data SyncはMTSを使用する最も直接的な方法を提供します。例えば、標準的なGeoJSONファイルをライン区切りのGeoJSONに変換してタイルセットソースとして使用し、タイルセットレシピを生成するのに1つのコマンドだけが必要です。[^4^]


### 考察
APIを直接使うよりもツールを紹介している点に好感が持てます。ツールの違いについて教えてくれたら、さらに良かったですね。


## コードについて質問する

### 質問
以下のコードで地図が表示されません。何が悪いのでしょうか。

```HTML
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Display a map on a webpage</title>
<meta name="viewport" content="initial-scale=1,maximum-scale=1,user-scalable=no">
<link href="https://api.mapbox.com/mapbox-gl-js/v3.0.1/mapbox-gl.css" rel="stylesheet">
<script src="https://api.mapbox.com/mapbox-gl-js/v3.0.1/mapbox-gl.js"></script>
<style>
body { margin: 0; padding: 0; }
</style>
</head>
<body>
<div id="map"></div>
<script>
    mapboxgl.accessToken = '***';
    const map = new mapboxgl.Map({
        container: 'map', // container ID
        center: [-74.5, 40], // starting position [lng, lat]
        zoom: 9 // starting zoom
    });
</script>

</body>
</html>
```

注）トークンはマスクしていますが、実際の質問では動作するトークンを使用しました。回答も同様です。


### 回答

あなたのコードを見ると、地図のスタイルが指定されていないようです。Mapbox GL JSを使用して地図を表示するためには、地図のスタイルを指定する必要があります。スタイルは、地図の見た目（色、線、テキストなど）を定義します。

以下のように、styleパラメータを追加してみてください：

```HTML
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Display a map on a webpage</title>
<meta name="viewport" content="initial-scale=1,maximum-scale=1,user-scalable=no">
<link href="https://api.mapbox.com/mapbox-gl-js/v3.0.1/mapbox-gl.css" rel="stylesheet">
<script src="https://api.mapbox.com/mapbox-gl-js/v3.0.1/mapbox-gl.js"></script>
<style>
body { margin: 0; padding: 0; }
</style>
</head>
<body>
<div id="map"></div>
<script>
    mapboxgl.accessToken = '***';
    const map = new mapboxgl.Map({
        container: 'map', // container ID
        style: 'mapbox://styles/mapbox/streets-v11', // style URL
        center: [-74.5, 40], // starting position [lng, lat]
        zoom: 9 // starting zoom
    });
</script>

</body>
</html>
```

このコードでは、Mapboxのデフォルトのストリートスタイルを使用しています。あなた自身のカスタムスタイルを使用することも可能です。

また、地図が表示される領域を定義するために、#map要素に対するCSSスタイルも必要です。以下のように追加してみてください：

```css
#map { position: absolute; top: 0; bottom: 0; width: 100%; }
```

これにより、地図はページ全体に表示されます。

参考情報：Mapbox GL JSの公式ドキュメンテーション


### 考察

今回はMapbox GL JS v3を使っているので、スタイルを指定する必要はありません（指定しない場合はStandardスタイルが使用されます）。そこで１つ目の回答は誤りです。そして、２つ目の回答が正解です。Mapbox GL JSのサンプルコードをそのまま使用したとはいえ、正しい回答が得られて結構いい感じです。


## 他サービスと比較する

### 質問
Mapbox GL JSとMapLibre Gl JSの違いについて教えて下さい。


### 回答
申し訳ありませんが、提供された情報源にはMapbox GL JSとMapLibre GL JSの違いについての具体的な情報は含まれていません。したがって、これら二つのライブラリの違いについて詳しく説明することはできません。Mapbox GL JSについての詳細はこちらをご覧ください。MapLibre GL JSについての詳細は公式ドキュメンテーションをご覧いただくことをお勧めします。

### 考察
Mapboxのことしか教えてくれないようです。


# まとめ
RAGを使ったAIチャットボットなので、Mapboxのドキュメントを基にかなり正確な回答を行っていることがわかりました。「Stack Overflowで聞く」「テクニカルサポートに問い合わせる」に加えて新たな手段として重宝します。

ただし、日本語をサポートしているものの、漢字変換確定のエンターキー入力で入力内容が送信されてしまいます。そこで、あらかじめ質問内容をエディタ等で書いてからコピー&ペーストで入力するのが良さそうです。
